[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('siemens-tia-engineering-assistant')]
    [string]$SkillName = 'siemens-tia-engineering-assistant',
    [string]$InstallRoot = $(
        if ([string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
            Join-Path $env:USERPROFILE '.codex\skills'
        } else {
            Join-Path $env:CODEX_HOME 'skills'
        }
    ),
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Assert-NoReparsePoint([string]$Path) {
    $current = $Path
    while (-not [string]::IsNullOrEmpty($current)) {
        if (Test-Path -LiteralPath $current) {
            $item = Get-Item -LiteralPath $current -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "No se permiten enlaces o junctions en la ruta: $current"
            }
        }
        $current = Split-Path -Parent $current
    }
}

function Assert-ChildPath([string]$Path, [string]$Parent) {
    $prefix = $Parent.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if (-not $Path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "La ruta queda fuera del directorio permitido: $Path"
    }
}

$packageRoot = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $PSScriptRoot) "skill\$SkillName"))
if ([string]::IsNullOrWhiteSpace($InstallRoot)) {
    throw 'InstallRoot no puede estar vacio.'
}
$providerInfo = $null
$driveInfo = $null
$resolvedInstallRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InstallRoot, [ref]$providerInfo, [ref]$driveInfo)
if ($providerInfo.Name -ne 'FileSystem') {
    throw 'InstallRoot debe pertenecer al sistema de archivos.'
}
$InstallRoot = [IO.Path]::GetFullPath($resolvedInstallRoot).TrimEnd('\', '/')
if ([string]::IsNullOrEmpty((Split-Path -Parent $InstallRoot))) {
    throw 'InstallRoot debe ser una carpeta, no la raiz de una unidad.'
}
$destination = [IO.Path]::GetFullPath((Join-Path $InstallRoot $SkillName))
$installParent = Split-Path -Parent $InstallRoot
$backupRoot = Join-Path $installParent '.skill-backups'
if ($backupRoot.Equals($InstallRoot, [StringComparison]::OrdinalIgnoreCase)) {
    $backupRoot = Join-Path $installParent '.skill-backups-archive'
}
$stage = Join-Path $installParent ('.skill-stage-' + [Guid]::NewGuid().ToString('N'))
$backup = Join-Path $backupRoot ($SkillName + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N'))

# Check all recursive move/delete boundaries before any filesystem mutation.
Assert-ChildPath $destination $InstallRoot
Assert-ChildPath $stage $installParent
Assert-ChildPath $backup $backupRoot
foreach ($path in @($packageRoot, $InstallRoot, $backupRoot)) {
    Assert-NoReparsePoint $path
}
foreach ($pair in @(@($destination, $packageRoot), @($packageRoot, $destination))) {
    if ($pair[0].Equals($pair[1], [StringComparison]::OrdinalIgnoreCase) -or
        $pair[0].StartsWith($pair[1].TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'El origen y el destino no pueden coincidir ni estar contenidos uno en otro.'
    }
}

if (-not (Test-Path -LiteralPath $packageRoot -PathType Container)) {
    throw "No se encontro el paquete de la skill: $packageRoot"
}
$sourceFiles = @(Get-ChildItem -LiteralPath $packageRoot -Recurse -File -Force)
if (@(Get-ChildItem -LiteralPath $packageRoot -Recurse -Force | Where-Object {
    ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
}).Count -gt 0) {
    throw 'El paquete contiene un enlace o junction; no se instalara.'
}
foreach ($relativePath in @('SKILL.md', 'agents\openai.yaml', 'LICENSE')) {
    if (-not (Test-Path -LiteralPath (Join-Path $packageRoot $relativePath) -PathType Leaf)) {
        throw "Falta un archivo requerido del paquete: $relativePath"
    }
}
if ((Test-Path -LiteralPath $destination) -and -not $Force) {
    throw "La skill ya existe en $destination. Usa -Force para actualizarla."
}
if (-not $PSCmdlet.ShouldProcess($destination, 'instalar skill; conservar la instalacion anterior como respaldo si existe')) {
    return
}

# A named mutex prevents simultaneous installers from interleaving the swap.
$hasher = [Security.Cryptography.SHA256]::Create()
try {
    $lockHash = [BitConverter]::ToString($hasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($destination.ToLowerInvariant()))).Replace('-', '')
} finally {
    $hasher.Dispose()
}
$mutex = [Threading.Mutex]::new($false, "SiemensTIA.SkillInstall.$lockHash")
$locked = $false
$movedExisting = $false
try {
    try {
        $locked = $mutex.WaitOne(0)
    } catch [Threading.AbandonedMutexException] {
        $locked = $true
    }
    if (-not $locked) {
        throw 'Otra instalacion de esta skill esta en curso para el mismo destino.'
    }
    Assert-NoReparsePoint $destination
    if (Test-Path -LiteralPath $destination) {
        if (-not $Force) {
            throw 'El destino aparecio durante la preparacion. Usa -Force para actualizarlo.'
        }
        if (-not (Test-Path -LiteralPath $destination -PathType Container)) {
            throw 'El destino existente no es una carpeta.'
        }
        if (@(Get-ChildItem -LiteralPath $destination -Recurse -Force | Where-Object {
            ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
        }).Count -gt 0) {
            throw 'La instalacion existente contiene enlaces o junctions; revisala antes de actualizar.'
        }
    }
    New-Item -ItemType Directory -Force -Path $InstallRoot -Confirm:$false | Out-Null
    Copy-Item -LiteralPath $packageRoot -Destination $stage -Recurse -Force -Confirm:$false
    $stagedFiles = @(Get-ChildItem -LiteralPath $stage -Recurse -File -Force)
    if ($sourceFiles.Count -ne $stagedFiles.Count) {
        throw 'La copia preparada no contiene todos los archivos del paquete.'
    }
    foreach ($file in $sourceFiles) {
        $relativePath = $file.FullName.Substring($packageRoot.Length).TrimStart('\', '/')
        $copyPath = Join-Path $stage $relativePath
        if (-not (Test-Path -LiteralPath $copyPath -PathType Leaf) -or
            (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $copyPath -Algorithm SHA256).Hash) {
            throw "La copia preparada no coincide con el paquete: $relativePath"
        }
    }
    if (Test-Path -LiteralPath $destination) {
        New-Item -ItemType Directory -Force -Path $backupRoot -Confirm:$false | Out-Null
        Move-Item -LiteralPath $destination -Destination $backup -Confirm:$false
        $movedExisting = $true
    }
    try {
        Move-Item -LiteralPath $stage -Destination $destination -Confirm:$false
    } catch {
        $activationError = $_
        if ($movedExisting) {
            if (Test-Path -LiteralPath $destination) {
                throw "Fallo la activacion y el destino ya existe. La instalacion anterior esta preservada en: $backup"
            }
            try {
                Move-Item -LiteralPath $backup -Destination $destination -Confirm:$false
            } catch {
                throw "Fallo la activacion y la restauracion automatica. La instalacion anterior esta preservada en: $backup"
            }
        }
        throw $activationError
    }
    Write-Output "Skill instalada en: $destination"
    if ($movedExisting) {
        Write-Output "Respaldo anterior: $backup"
    }
} finally {
    try {
        if (Test-Path -LiteralPath $stage) {
            Assert-ChildPath $stage $installParent
            Assert-NoReparsePoint $stage
            Remove-Item -LiteralPath $stage -Recurse -Force -Confirm:$false
        }
    } finally {
        if ($locked) {
            $mutex.ReleaseMutex()
        }
        $mutex.Dispose()
    }
}
