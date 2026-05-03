$ErrorActionPreference = "Stop"

$petId = "peacemaker"
$repoUrl = $env:CODEX_PETS_BASE_URL
if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    $repoUrl = "https://raw.githubusercontent.com/CratesSo/Codex_Pets/main"
}

$petsRoot = Join-Path $HOME ".codex/pets"
$installPath = Join-Path $petsRoot $petId
$workDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
$newPetDir = Join-Path $workDir $petId

New-Item -ItemType Directory -Force -Path $newPetDir | Out-Null

try {
    Invoke-WebRequest -Uri "$repoUrl/pets/$petId/pet.json" -OutFile (Join-Path $newPetDir "pet.json")
    Invoke-WebRequest -Uri "$repoUrl/pets/$petId/spritesheet.webp" -OutFile (Join-Path $newPetDir "spritesheet.webp")

    $manifest = Get-Content (Join-Path $newPetDir "pet.json") -Raw | ConvertFrom-Json
    if ($manifest.id -ne $petId) {
        throw "Downloaded manifest does not look like the $petId pet."
    }

    New-Item -ItemType Directory -Force -Path $petsRoot | Out-Null

    if (Test-Path $installPath) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backupPath = "$installPath.backup.$timestamp"
        $backupNumber = 1
        while (Test-Path $backupPath) {
            $backupPath = "$installPath.backup.$timestamp.$backupNumber"
            $backupNumber += 1
        }
        Move-Item $installPath $backupPath
        Write-Output "Backed up existing $petId to $backupPath"
    }

    Move-Item $newPetDir $installPath
    Write-Output "Installed $petId to $installPath"
}
finally {
    if (Test-Path $workDir) {
        Remove-Item -Recurse -Force $workDir
    }
}
