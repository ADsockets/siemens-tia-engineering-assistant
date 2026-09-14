[CmdletBinding()]
param(
    [string]$RepositoryRoot
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $scriptRoot
}
$violations = [System.Collections.Generic.List[string]]::new()

$forbiddenExtensions = @('.ap18','.ap19','.ap20','.ap21','.zap18','.zap19','.zap20','.zap21','.als18','.als19','.als20','.als21','.s7p','.s7dcl','.s7res','.dll','.exe','.msi','.pfx','.pem','.key')
$files = Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -File -Force | Where-Object { $_.FullName -notmatch '\\.git\\' }

foreach ($file in $files) {
    if ($forbiddenExtensions -contains $file.Extension.ToLowerInvariant()) {
        $violations.Add("Archivo no publicable por extensión: $($file.FullName)")
    }
}

$textFiles = $files | Where-Object {
    $_.Extension -in @('.md','.yaml','.yml','.json','.ps1','.py','.txt','.xml','.scl') -and
    $_.FullName -ne $PSCommandPath
}
$secretPattern = '(?i)(api[_-]?key|access[_-]?token|client[_-]?secret|password\s*[:=]|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,})'
$privatePathPattern = '(?i)([A-Z]:\\Users\\|Google Drive|OneDrive|confidential|internal-only)'

foreach ($file in $textFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match $secretPattern) {
        $violations.Add("Posible secreto en: $($file.FullName)")
    }
    if ($content -match $privatePathPattern) {
        $violations.Add("Posible dato o ruta privada en: $($file.FullName)")
    }
}

if ($violations.Count -gt 0) {
    $violations | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "Public repository validation passed: no forbidden artifacts or obvious secret patterns found."
