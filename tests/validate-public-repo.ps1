[CmdletBinding()]
param(
    [string]$RepositoryRoot
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$violations = [System.Collections.Generic.List[string]]::new()
$files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()

try {
    $root = Get-Item -LiteralPath ([System.IO.Path]::GetFullPath($RepositoryRoot)) -Force
    if (-not $root.PSIsContainer -or $root.PSProvider.Name -ne 'FileSystem') {
        throw 'Invalid repository directory.'
    }
    # Reject a linked root or ancestor before enumerating potentially foreign files.
    for ($ancestor = $root; $null -ne $ancestor; $ancestor = $ancestor.Parent) {
        if (($ancestor.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'Linked repository path.'
        }
    }
    $rootPrefix = $root.FullName.TrimEnd([char[]]'\/') + [System.IO.Path]::DirectorySeparatorChar
}
catch {
    Write-Output '[invalid-root] Repository directory cannot be inspected safely.'
    exit 1
}

function Get-RelativeName([string]$FullName) {
    if (-not $FullName.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Path outside repository directory.'
    }
    return $FullName.Substring($rootPrefix.Length)
}

$directories = [System.Collections.Generic.Stack[System.IO.DirectoryInfo]]::new()
$directories.Push($root)
while ($directories.Count -gt 0) {
    $directory = $directories.Pop()
    try {
        $children = @(Get-ChildItem -LiteralPath $directory.FullName -Force -ErrorAction Stop)
    }
    catch {
        $relativeDirectory = if ($directory.FullName -eq $root.FullName) { '.' } else { Get-RelativeName $directory.FullName }
        $violations.Add("[unreadable-directory] $relativeDirectory")
        continue
    }

    foreach ($child in $children) {
        # Git metadata is outside the public file tree, including worktree .git files.
        if ($directory.FullName -eq $root.FullName -and $child.Name -eq '.git') { continue }
        $relativeName = Get-RelativeName $child.FullName
        if (($child.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            $violations.Add("[reparse-point] $relativeName")
            continue
        }
        if ($child.PSIsContainer) { $directories.Push($child) }
        else { $files.Add($child) }
    }
}

$forbiddenExtensions = @(
    '.s7p', '.s7dcl', '.s7res', '.db', '.plf', '.idx', '.cfs',
    '.dll', '.exe', '.msi', '.pem', '.key', '.pfx', '.p12', '.crt', '.cer', '.der',
    '.pdf', '.log'
)
$textExtensions = @(
    '.md', '.yaml', '.yml', '.json', '.ps1', '.psm1', '.psd1', '.py', '.txt', '.xml', '.scl',
    '.toml', '.ini', '.cfg', '.conf', '.config', '.csv', '.tsv', '.js', '.ts', '.sh', '.bat', '.cmd'
)
$secretPatterns = [ordered]@{
    'private-key' = '-----BEGIN (?:RSA |DSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----'
    'github-token' = '\b(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,})\b'
    'provider-token' = '\b(?:sk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{20,}|(?:AKIA|ASIA)[A-Z0-9]{16}|xox[baprs]-[A-Za-z0-9-]{16,})\b'
    'credential-assignment' = '(?im)["'']?(?:api[_-]?key|access[_-]?token|client[_-]?secret|password|passwd|secret[_-]?key)["'']?\s*[:=]\s*["'']?[^\s"''`,;#]{8,}'
    'bearer-token' = '(?i)\bBearer\s+[A-Za-z0-9._~+/-]{16,}={0,2}'
    'url-credentials' = '(?i)https?://[^\s/<>]+:[^\s/@<>]+@'
}
$privatePathPattern = '(?i)([A-Z]:\\Users\\|Google [D]rive|One[D]rive|confiden[t]ial|internal[-]only)'

foreach ($file in $files) {
    $relativeName = Get-RelativeName $file.FullName
    if ($forbiddenExtensions -contains $file.Extension.ToLowerInvariant() -or
        $file.Name -match '(?i)\.(?:ap|zap|als|pma)\d*$' -or
        $file.Name -match '(?i)(^|[.])env($|[.])') {
        $violations.Add("[forbidden-artifact] $relativeName")
    }

    $stream = $null
    $reader = $null
    try {
        # Opening every file also makes unreadable non-text artifacts fail closed.
        $stream = [System.IO.File]::OpenRead($file.FullName)
        if ($textExtensions -contains $file.Extension.ToLowerInvariant() -or
            [string]::IsNullOrEmpty($file.Extension) -or $file.Name.StartsWith('.')) {
            $encoding = [System.Text.UTF8Encoding]::new($false, $true)
            $reader = [System.IO.StreamReader]::new($stream, $encoding, $true)
            $content = $reader.ReadToEnd()
            foreach ($kind in $secretPatterns.Keys) {
                if ($content -match $secretPatterns[$kind]) {
                    $violations.Add("[possible-$kind] $relativeName")
                }
            }
            if ($content -match $privatePathPattern) {
                $violations.Add("[possible-private-path] $relativeName")
            }
        }
    }
    catch {
        $violations.Add("[unreadable-file] $relativeName")
    }
    finally {
        if ($null -ne $reader) { $reader.Dispose() }
        elseif ($null -ne $stream) { $stream.Dispose() }
    }
}

if ($violations.Count -gt 0) {
    # Report file and category only, never matching text or exception messages.
    $violations | Sort-Object -Unique | ForEach-Object { Write-Output $_ }
    exit 1
}

Write-Output 'Public repository validation passed: no forbidden artifacts or obvious secret patterns found.'
