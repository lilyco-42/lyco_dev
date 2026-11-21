param(
    [switch]$AllAgents
)

$ErrorActionPreference = "Stop"
$SkillName = "lyco_dev"
$RepoUrl = "https://github.com/lilyco-42/lyco_dev.git"
$TarballUrl = "https://github.com/lilyco-42/lyco_dev/archive/refs/heads/main.zip"

if ($AllAgents) {
    if (Get-Command skills -ErrorAction SilentlyContinue) {
        skills add lilyco-42/lyco_dev --global --agent '*' --yes
    } elseif (Get-Command npx -ErrorAction SilentlyContinue) {
        npx --yes skills add lilyco-42/lyco_dev --global --agent '*' --yes
    } else {
        throw "需要 skills CLI 或 Node.js/npx"
    }
    Write-Host "[lyco_dev] 已安装到所有支持的 Agent。" -ForegroundColor Green
    exit 0
}

$tmp = Join-Path $env:TEMP ("lyco_dev_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp | Out-Null

if (Get-Command git -ErrorAction SilentlyContinue) {
    git clone --depth 1 $RepoUrl (Join-Path $tmp "skill") | Out-Null
} else {
    $zip = Join-Path $tmp "lyco_dev.zip"
    Invoke-WebRequest -Uri $TarballUrl -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    Move-Item (Join-Path $tmp "lyco_dev-main") (Join-Path $tmp "skill")
}

$targets = @(
    (Join-Path $HOME ".agents\skills\$SkillName"),
    (Join-Path $HOME ".claude\skills\$SkillName")
)

foreach ($t in $targets) {
    $parent = Split-Path -Parent $t
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    if (Test-Path $t) { Remove-Item -Recurse -Force $t }
    New-Item -ItemType Directory -Path $t -Force | Out-Null
    Copy-Item (Join-Path $tmp "skill\SKILL.md") $t -Force
    if (Test-Path (Join-Path $tmp "skill\resources")) { Copy-Item -Recurse (Join-Path $tmp "skill\resources") $t -Force }
    if (Test-Path (Join-Path $tmp "skill\docs")) { Copy-Item -Recurse (Join-Path $tmp "skill\docs") $t -Force }
    Write-Host "[lyco_dev] 已安装 -> $t" -ForegroundColor Green
}

Remove-Item -Recurse -Force $tmp
