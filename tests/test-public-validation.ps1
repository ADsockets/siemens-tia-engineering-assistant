[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$validator = Join-Path $PSScriptRoot 'validate-public-repo.ps1'
$engine = (Get-Process -Id $PID).Path
$temporaryParent = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd([char[]]'\/')
$testRoot = Join-Path $temporaryParent ('siemens-public-validation-' + [Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $testRoot
$utf8 = [System.Text.UTF8Encoding]::new($false)
$passed = 0
$junction = $null

function New-Case([string]$Name) {
    $path = Join-Path $testRoot $Name
    $null = New-Item -ItemType Directory -Path $path
    return $path
}

function Write-Fixture([string]$Root, [string]$Name, [string]$Content) {
    [System.IO.File]::WriteAllText((Join-Path $Root $Name), $Content, $utf8)
}

function Assert-Validation {
    param(
        [string]$Name,
        [string]$Root,
        [int]$ExpectedExit,
        [string[]]$ExpectedCategories = @(),
        [string[]]$ExpectedFindings = @(),
        [string]$ScriptPath = $validator,
        [string]$ForbiddenOutput
    )
    $output = @(& $engine -NoLogo -NoProfile -NonInteractive -File $ScriptPath -RepositoryRoot $Root 2>&1)
    $code = $LASTEXITCODE
    $result = $output -join "`n"
    if ($code -ne $ExpectedExit) { throw "Case $Name returned unexpected exit code $code." }
    foreach ($category in $ExpectedCategories) {
        if (-not $result.Contains("[$category]")) { throw "Case $Name missed category $category." }
    }
    foreach ($finding in $ExpectedFindings) {
        if (-not $result.Contains($finding)) { throw "Case $Name missed an expected file/category finding." }
    }
    if (-not [string]::IsNullOrEmpty($ForbiddenOutput) -and $result.Contains($ForbiddenOutput)) {
        throw "Case $Name exposed fixture content."
    }
    $script:passed++
    Write-Output "PASS $Name"
}

try {
    $valid = New-Case 'valid'
    Write-Fixture $valid 'README.md' '# Public instructions'
    Write-Fixture $valid 'LICENSE' 'MIT License'
    Copy-Item -LiteralPath $validator -Destination (Join-Path $valid 'validate-public-repo.ps1')
    Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $valid 'test-public-validation.ps1')
    Assert-Validation 'valid-including-validator-and-tests' $valid 0

    $dotenv = New-Case 'dotenv'
    Write-Fixture $dotenv '.env' 'local configuration'
    Assert-Validation 'dotenv' $dotenv 1 @('forbidden-artifact')

    $dotenvVariant = New-Case 'dotenv-variant'
    Write-Fixture $dotenvVariant '.env.production' 'local configuration'
    Assert-Validation 'dotenv-variant' $dotenvVariant 1 @('forbidden-artifact')

    $database = New-Case 'database'
    Write-Fixture $database 'project.db' 'private database fixture'
    Assert-Validation 'database' $database 1 @('forbidden-artifact')

    $artifacts = New-Case 'artifacts'
    $artifactNames = @('project.plf', 'project.ap99', 'archive.zap99', 'library.als99', 'manual.pdf', 'certificate.p12')
    foreach ($name in $artifactNames) {
        Write-Fixture $artifacts $name 'artifact fixture'
    }
    $expectedArtifacts = @($artifactNames | ForEach-Object { '[forbidden-artifact] ' + $_ })
    Assert-Validation 'proprietary-artifacts-and-certificates' $artifacts 1 -ExpectedFindings $expectedArtifacts

    $key = New-Case 'private-header'
    $headerKinds = @('RSA', 'OPENSSH', 'EC', 'DSA', 'ENCRYPTED')
    foreach ($kind in $headerKinds) {
        $keyHeader = '-----BEGIN ' + $kind + ' ' + 'PRIVATE KEY-----'
        Write-Fixture $key ($kind.ToLowerInvariant() + '.txt') $keyHeader
    }
    $expectedHeaders = @($headerKinds | ForEach-Object { '[possible-private-key] ' + $_.ToLowerInvariant() + '.txt' })
    Assert-Validation 'private-key-headers-in-text' $key 1 -ExpectedFindings $expectedHeaders -ForbiddenOutput $keyHeader

    $token = 'gh' + 'p_' + ('a' * 40)
    $tokenCase = New-Case 'token'
    Write-Fixture $tokenCase 'notes.md' $token
    Assert-Validation 'token-in-text' $tokenCase 1 @('possible-github-token') -ForbiddenOutput $token

    $extensionless = New-Case 'extensionless'
    Write-Fixture $extensionless 'LICENSE' $token
    Assert-Validation 'extensionless-token' $extensionless 1 @('possible-github-token') -ForbiddenOutput $token

    $self = New-Case 'self-scan'
    $selfValidator = Join-Path $self 'validate-public-repo.ps1'
    Copy-Item -LiteralPath $validator -Destination $selfValidator
    [System.IO.File]::AppendAllText($selfValidator, ("`n# " + $token), $utf8)
    Assert-Validation 'validator-scans-itself' $self 1 @('possible-github-token') -ScriptPath $selfValidator -ForbiddenOutput $token

    $unreadable = New-Case 'unreadable'
    Write-Fixture $unreadable 'locked.txt' 'locked fixture'
    $lock = [System.IO.File]::Open((Join-Path $unreadable 'locked.txt'), 'Open', 'ReadWrite', 'None')
    try { Assert-Validation 'unreadable-file-fails-closed' $unreadable 1 @('unreadable-file') }
    finally { $lock.Dispose() }

    if ($env:OS -eq 'Windows_NT') {
        $linked = New-Case 'linked'
        $target = New-Case 'link-target'
        Write-Fixture $target 'notes.txt' $token
        $junction = Join-Path $linked 'linked-directory'
        $null = New-Item -ItemType Junction -Path $junction -Target $target
        Assert-Validation 'junction-not-followed' $linked 1 @('reparse-point') -ForbiddenOutput $token
        [System.IO.Directory]::Delete($junction)
        $junction = $null
    }

    Write-Output "Public validation tests passed: $passed cases ($($PSVersionTable.PSVersion))."
}
finally {
    # Delete only this run's verified temporary tree; unlink a junction without recursion.
    if ($null -ne $junction -and (Test-Path -LiteralPath $junction)) {
        [System.IO.Directory]::Delete($junction)
    }
    $resolvedRoot = [System.IO.Path]::GetFullPath($testRoot)
    $expectedParent = [System.IO.Path]::GetDirectoryName($resolvedRoot)
    if ($expectedParent -ne $temporaryParent -or
        [System.IO.Path]::GetFileName($resolvedRoot) -notmatch '^siemens-public-validation-[a-f0-9]{32}$') {
        throw 'Refusing cleanup outside the owned temporary directory.'
    }
    if ((Get-Item -LiteralPath $resolvedRoot -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw 'Refusing recursive cleanup of a linked temporary root.'
    }
    Remove-Item -LiteralPath $resolvedRoot -Recurse -Force
}
