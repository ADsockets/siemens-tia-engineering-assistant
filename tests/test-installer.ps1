[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installer = Join-Path (Split-Path -Parent $PSScriptRoot) 'scripts\instalar-siemens-tia-scl.ps1'
$package = Join-Path (Split-Path -Parent $PSScriptRoot) 'skill\siemens-tia-engineering-assistant'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('siemens-installer-tests-' + [Guid]::NewGuid().ToString('N'))
$installRoot = Join-Path $testRoot 'codex home with spaces\skills'
$destination = Join-Path $installRoot 'siemens-tia-engineering-assistant'
$originalCodexHome = $env:CODEX_HOME
$priorFailureVariable = Get-Variable -Name SiemensInstallerTestFailureMode -Scope Global -ErrorAction SilentlyContinue
$hadFailureVariable = $null -ne $priorFailureVariable
$priorFailureValue = if ($hadFailureVariable) { $priorFailureVariable.Value } else { $null }
$global:SiemensInstallerTestFailureMode = $null
$passed = 0

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "ASSERT: $Message" }
}

function Assert-Throws([scriptblock]$Action, [string]$Pattern) {
    $caught = $false
    try { & $Action | Out-Null } catch {
        if ($_.Exception.Message -notmatch $Pattern) { throw }
        $caught = $true
    }
    Assert-True $caught "Expected failure matching: $Pattern"
}

function Get-Snapshot([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return '' }
    $entries = foreach ($file in Get-ChildItem -LiteralPath $Path -File -Recurse -Force) {
        $file.FullName.Substring($Path.Length) + ':' + (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    }
    return (($entries | Sort-Object) -join "`n")
}

# Inject failures in filesystem operations only; the actual installer and package run unchanged.
function Copy-Item {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$LiteralPath, [string]$Destination, [switch]$Recurse, [switch]$Force)
    if ($global:SiemensInstallerTestFailureMode -eq 'copy' -and $Destination -match '\.skill-stage-') {
        throw 'INJECTED_COPY_FAILURE'
    }
    Microsoft.PowerShell.Management\Copy-Item @PSBoundParameters
}

function Move-Item {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$LiteralPath, [string]$Destination)
    if ($global:SiemensInstallerTestFailureMode -eq 'activate' -and (Split-Path -Leaf $LiteralPath) -like '.skill-stage-*') {
        throw 'INJECTED_ACTIVATION_FAILURE'
    }
    Microsoft.PowerShell.Management\Move-Item @PSBoundParameters
}

try {
    # WhatIf must not even create the requested root or its parents.
    $whatIfRoot = Join-Path $testRoot 'missing parent\skills'
    $output = @(& $installer -InstallRoot $whatIfRoot -WhatIf)
    Assert-True (-not (Test-Path -LiteralPath $testRoot)) 'WhatIf created filesystem entries.'
    Assert-True ($output.Count -eq 0) 'WhatIf reported an installation.'
    $passed++

    # CODEX_HOME and paths containing spaces must produce an exact package copy.
    $env:CODEX_HOME = Split-Path -Parent $installRoot
    & $installer | Out-Null
    Assert-True ((Get-Snapshot $package) -eq (Get-Snapshot $destination)) 'Installed package differs from source.'
    Assert-True (Test-Path -LiteralPath (Join-Path $destination 'LICENSE')) 'MIT notice was not installed.'
    $passed++

    $extra = Join-Path $destination 'local-note.txt'
    Set-Content -LiteralPath $extra -Value 'preserve this prior installation' -Encoding UTF8
    $before = Get-Snapshot $destination
    Assert-Throws { & $installer -InstallRoot $installRoot } 'ya existe'
    Assert-True ($before -eq (Get-Snapshot $destination)) 'Rejected install modified the existing package.'
    $passed++

    $rootBefore = Get-Snapshot $testRoot
    & $installer -InstallRoot $installRoot -Force -WhatIf | Out-Null
    Assert-True ($rootBefore -eq (Get-Snapshot $testRoot)) 'Force WhatIf changed an existing installation.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path (Split-Path -Parent $installRoot) '.skill-backups'))) 'WhatIf created backups.'
    $passed++

    $global:SiemensInstallerTestFailureMode = 'copy'
    Assert-Throws { & $installer -InstallRoot $installRoot -Force } 'INJECTED_COPY_FAILURE'
    Assert-True ($before -eq (Get-Snapshot $destination)) 'Copy failure modified the existing installation.'
    $global:SiemensInstallerTestFailureMode = $null
    $passed++

    $global:SiemensInstallerTestFailureMode = 'activate'
    Assert-Throws { & $installer -InstallRoot $installRoot -Force } 'INJECTED_ACTIVATION_FAILURE'
    Assert-True ($before -eq (Get-Snapshot $destination)) 'Activation failure did not restore the prior installation.'
    $global:SiemensInstallerTestFailureMode = $null
    $passed++

    & $installer -InstallRoot $installRoot -Force | Out-Null
    Assert-True ((Get-Snapshot $package) -eq (Get-Snapshot $destination)) 'Force installation did not activate exact package.'
    $backupRoot = Join-Path (Split-Path -Parent $installRoot) '.skill-backups'
    $backups = @(Get-ChildItem -LiteralPath $backupRoot -Directory)
    Assert-True ($backups.Count -eq 1) 'Successful upgrade did not create one backup outside skills.'
    Assert-True ($before -eq (Get-Snapshot $backups[0].FullName)) 'Prior installation backup changed.'
    Assert-True (@(Get-ChildItem -LiteralPath (Split-Path -Parent $installRoot) -Directory -Filter '.skill-stage-*').Count -eq 0) 'Staging residue remains.'
    $passed++

    Assert-Throws { & $installer -SkillName '..\other' -InstallRoot $installRoot -Force } 'ValidateSet|validation|validaci|does not belong'
    Assert-Throws { & $installer -InstallRoot (Split-Path -Parent $package) -Force } 'origen y el destino'
    Assert-Throws { & $installer -InstallRoot (Join-Path $package 'nested') -Force } 'origen y el destino'
    Assert-Throws { & $installer -InstallRoot '' -Force } 'vacio'
    Assert-Throws { & $installer -InstallRoot 'HKCU:\Software' -Force } 'sistema de archivos'
    $passed++

    # A directory junction must be rejected without touching its target.
    $linkTarget = Join-Path $testRoot 'junction target'
    New-Item -ItemType Directory -Path $linkTarget | Out-Null
    $link = Join-Path $testRoot 'junction'
    New-Item -ItemType Junction -Path $link -Target $linkTarget | Out-Null
    try {
        Assert-Throws { & $installer -InstallRoot (Join-Path $link 'skills') -Force } 'enlaces o junctions'
        Assert-True (@(Get-ChildItem -LiteralPath $linkTarget -Force).Count -eq 0) 'Junction target was modified.'
    } finally {
        # Directory.Delete removes only the junction itself, never its target.
        [IO.Directory]::Delete($link)
    }
    $passed++

    # A second process cannot swap this destination while its installer mutex is held.
    $hasher = [Security.Cryptography.SHA256]::Create()
    try {
        $lockHash = [BitConverter]::ToString($hasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($destination.ToLowerInvariant()))).Replace('-', '')
    } finally {
        $hasher.Dispose()
    }
    $mutex = [Threading.Mutex]::new($false, "SiemensTIA.SkillInstall.$lockHash")
    $held = $mutex.WaitOne(0)
    Assert-True $held 'Could not acquire installer mutex for concurrency test.'
    try {
        $before = Get-Snapshot $testRoot
        $shell = (Get-Process -Id $PID).Path
        $priorErrorAction = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $childOutput = & $shell -NoProfile -ExecutionPolicy Bypass -File $installer -InstallRoot $installRoot -Force 2>&1
        } finally {
            $ErrorActionPreference = $priorErrorAction
        }
        Assert-True ($LASTEXITCODE -ne 0) 'Concurrent installer unexpectedly succeeded.'
        Assert-True (($childOutput | Out-String) -match 'Otra instalacion') 'Concurrent installer failed for a different reason.'
        Assert-True ($before -eq (Get-Snapshot $testRoot)) 'Concurrent installer changed filesystem content.'
    } finally {
        $mutex.ReleaseMutex()
        $mutex.Dispose()
    }
    $passed++

    Write-Output "Installer tests passed: $passed cases. PowerShell $($PSVersionTable.PSVersion)."
} finally {
    $env:CODEX_HOME = $originalCodexHome
    if ($hadFailureVariable) {
        $global:SiemensInstallerTestFailureMode = $priorFailureValue
    } else {
        Remove-Variable -Name SiemensInstallerTestFailureMode -Scope Global
    }
    # Delete only this run's verified, uniquely named temporary root.
    $resolvedRoot = [IO.Path]::GetFullPath($testRoot)
    $tempPrefix = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if (-not $resolvedRoot.StartsWith($tempPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path -Leaf $resolvedRoot) -notlike 'siemens-installer-tests-*') {
        throw 'Unsafe test cleanup path.'
    }
    if (Test-Path -LiteralPath $resolvedRoot) {
        if (@(Get-ChildItem -LiteralPath $resolvedRoot -Recurse -Force | Where-Object {
            ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
        }).Count -gt 0) {
            throw "Refusing recursive cleanup containing a reparse point: $resolvedRoot"
        }
        Remove-Item -LiteralPath $resolvedRoot -Recurse -Force
    }
}
