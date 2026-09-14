[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SkillName = 'siemens-tia-engineering-assistant',
    [string]$InstallRoot = (Join-Path $env:USERPROFILE '.codex\skills'),
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$packageRoot = Join-Path (Split-Path -Parent $PSScriptRoot) "skill\$SkillName"
$destination = Join-Path $InstallRoot $SkillName
$backupRoot = Join-Path $InstallRoot '.skill-backups'

if (-not (Test-Path -LiteralPath $packageRoot -PathType Container)) {
    throw "No se encontró el paquete de la skill: $packageRoot"
}

$requiredFiles = @(
    'SKILL.md',
    'agents\openai.yaml'
)
foreach ($relativePath in $requiredFiles) {
    $requiredPath = Join-Path $packageRoot $relativePath
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Falta un archivo requerido del paquete: $requiredPath"
    }
}

New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null

if (Test-Path -LiteralPath $destination) {
    if (-not $Force) {
        throw "La skill ya existe en $destination. Usa -Force para actualizarla."
    }
    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    $backup = Join-Path $backupRoot ("{0}-{1}" -f $SkillName, (Get-Date -Format 'yyyyMMdd-HHmmss'))
    if ($PSCmdlet.ShouldProcess($destination, "crear respaldo en $backup")) {
        Move-Item -LiteralPath $destination -Destination $backup
    }
}

if ($PSCmdlet.ShouldProcess($destination, 'instalar skill')) {
    Copy-Item -LiteralPath $packageRoot -Destination $destination -Recurse -Force
}

Write-Output "Skill instalada en: $destination"
