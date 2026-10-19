[CmdletBinding()]
param(
    [string]$Tc3BuildExe = $env:TC3_BUILD_EXE
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$outputDirectory = Join-Path $repoRoot 'artifacts'
$solution = Join-Path $repoRoot 'tc3-base.sln'

if ([string]::IsNullOrWhiteSpace($Tc3BuildExe)) {
    $command = Get-Command Tc3Build.exe -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw @'
Tc3Build.exe was not found on the buildserver.
1. Download the Windows x64 CLI ZIP from danielwiege/tc3-build and extract
   the entire archive, for example to C:\Tools\tc3-build.
2. Install the .NET 10 Runtime (x64).
3. In a web browser, open the repository settings on the GitHub website:
   https://github.com/danielwiege/tc3-base/settings/variables/actions
   Select New repository variable and enter TC3_BUILD_EXE as the name.
   Set its value to the full executable path on the Windows buildserver, such as
   C:\Tools\tc3-build\Tc3Build.exe (without quotation marks).
For complete setup instructions, including runner registration and checks, see:
docs/Buildserver-Setup.md
'@
    }
    $Tc3BuildExe = $command.Source
}
if (-not (Test-Path -LiteralPath $Tc3BuildExe -PathType Leaf)) {
    throw "Tc3Build.exe was not found at the configured path: $Tc3BuildExe. This path must exist on the buildserver. See docs/Buildserver-Setup.md."
}

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
$library = Join-Path $outputDirectory 'Tc3_Base.library'
# Never upload a previous run's library after a failed build.
if (Test-Path -LiteralPath $library) {
    Remove-Item -LiteralPath $library
}

function Invoke-Tc3Build {
    param([string]$LogName, [string[]]$CommandArguments)
    & $Tc3BuildExe @CommandArguments 2>&1 |
        Tee-Object -FilePath (Join-Path $outputDirectory $LogName)
    if ($LASTEXITCODE -ne 0) {
        throw "tc3-build failed with exit code $LASTEXITCODE. See $LogName."
    }
}

$common = @('--project', $solution, '--configuration', 'Debug',
    '--platform', 'TwinCAT RT (x64)', '--host', 'vs2019', '--silent')

# tc3-test resolves Tc3_Base from the installed library repository.
Invoke-Tc3Build -LogName 'library-build.log' -CommandArguments (
    @('install-library') + $common + @('--project-name', 'tc3-base', '--library-output', $library))
if (-not (Test-Path -LiteralPath $library -PathType Leaf)) {
    throw "tc3-build succeeded but did not produce $library"
}
Invoke-Tc3Build -LogName 'test-project-build.log' -CommandArguments (
    @('build') + $common + @('--project-name', 'tc3-test'))
