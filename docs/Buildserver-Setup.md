# Set up the buildserver for GitHub push builds

Once configured, pushing changes to `tc3-base` on GitHub sends a build job to
your Windows buildserver. There, `tc3-build` uses **Visual Studio 2019** to build
the library first, followed by the example project. Results and logs appear
under **Actions → TwinCAT build** on GitHub.

Perform all Windows installations and PowerShell commands in this guide
**on the buildserver**. You can change the GitHub settings in a browser on
your development PC.

## 1. Prepare the buildserver

Sign in with the Windows account that will run the builds. Install Visual
Studio 2019 and a compatible TwinCAT XAE version with **Visual Studio 2019**
integration. The projects currently specify TwinCAT `3.1.4026.21`; the installed
version must be able to open and build them. Installing only the XAE Shell
does not satisfy our explicit `--host vs2019` selection.

Open Visual Studio 2019 once as this user and complete its initial setup.
Check that TwinCAT is available and that you can open `tc3-base.sln`.
Install any missing Beckhoff libraries through the TwinCAT installation.
The pipeline does not activate a configuration or start a PLC runtime.

## 2. Download and extract tc3-build

1. Open the [tc3-build releases](https://github.com/danielwiege/tc3-build/releases).
2. Select an approved release, version `0.4.0` or a compatible newer version.
3. Under **Assets**, download the **Windows x64 CLI ZIP**. For version `0.4.0`,
   the packaging script produces `Tc3Build-v0.4.0-win-x64.zip`. Use the ready-to-run
   CLI distribution rather than the source archive, GUI ZIP, or NuGet package.
4. Extract the **entire archive**, for example to `C:\Tools\tc3-build`.
   Keep the EXE, DLLs, configuration files, and all other supplied files together.
5. Check the actual executable path in File Explorer. If extraction creates
   another subfolder, include that subfolder in the path configured below.

Example directory structure:

```text
C:\Tools\tc3-build\
  Tc3Build.exe
  Tc3Build.dll
  Tc3Build.deps.json
  Tc3Build.runtimeconfig.json
  ... additional supplied DLLs and files
```

If no suitable release ZIP is available, a CLI package must first be built
and published from the `tc3-build` repository. A source archive does not
contain an installed, ready-to-run CLI.

## 3. Install the .NET Runtime and check the CLI

The current CLI distribution requires the **.NET 10 Runtime for Windows x64**.
Download it from the [official .NET 10 download page](https://dotnet.microsoft.com/en-us/download/dotnet/10.0)
and run the installer on the buildserver. The regular .NET Runtime is sufficient
for the CLI; the SDK is needed only to compile `tc3-build` itself.

Then open a new PowerShell window on the buildserver:

```powershell
dotnet --list-runtimes
Test-Path -LiteralPath 'C:\Tools\tc3-build\Tc3Build.exe'
& 'C:\Tools\tc3-build\Tc3Build.exe' --help
& 'C:\Tools\tc3-build\Tc3Build.exe' build --help
```

Expected results: `Microsoft.NETCore.App 10.0.x` appears in the runtime list,
`Test-Path` returns `True`, and the CLI displays its help. Displaying help
does not yet verify the TwinCAT or Visual Studio installation.

## 4. Tell GitHub where Tc3Build.exe is installed

In a web browser, open the repository on the **GitHub website**:
[danielwiege/tc3-base](https://github.com/danielwiege/tc3-base).
These settings are on github.com, not in GitHub Desktop or a Windows folder.
You can also open the [Actions variables settings directly](https://github.com/danielwiege/tc3-base/settings/variables/actions).

1. Go to **Settings → Secrets and variables → Actions**.
2. Select the **Variables** tab.
3. Under **Repository variables**, click **New repository variable**.
4. Enter exactly `TC3_BUILD_EXE` as the **Name**.
5. Enter `C:\Tools\tc3-build\Tc3Build.exe` as the **Value**, if that is where
   you extracted the archive. Do not add quotation marks, even if the path
   contains spaces.
6. Click **Add variable** to save it.

This value is a file path on the buildserver. The workflow passes it to the
build script. With this configuration, you do not need to change Windows `PATH`.

## 5. Connect the buildserver to GitHub

The GitHub Actions runner receives build jobs. Install it in addition to
`tc3-build`.

1. In the repository, go to **Settings → Actions → Runners → New self-hosted runner**.
2. Select **Windows** and **x64**.
3. Open PowerShell on the buildserver as the build user. Run the download and
   extraction commands shown by GitHub in order, for example in `C:\actions-runner`.
   Use the commands currently displayed so that the version and checksum match.
4. Run the displayed `config.cmd` command. It includes the repository URL and
   a short-lived registration token. Do not copy this token into the repository
   or this documentation.
5. When prompted, choose a recognizable runner name, such as `Tc3BuildServer01`.
   Accept the default runner group.
6. When asked for additional labels, add exactly **`twincat-vs2019`**. Keep the
   default labels `self-hosted`, `Windows`, and `X64`. All four labels must
   match the workflow's `runs-on` selection.
7. Accept the default work folder. Answer **No** when asked to install the
   runner as a Windows service: this setup uses an interactive user session
   for Visual Studio automation.
8. Start the runner from its directory:

   ```powershell
   .\run.cmd
   ```

Leave this window open. Once it displays `Listening for Jobs`, GitHub should
show the runner as **Idle**. If the program stops or the user signs out, the
runner cannot accept jobs. After a restart, start it again as the build user.
Automatic startup after sign-in can be configured later; this guide does not
configure it.

The runner and Visual Studio must use the same Windows account and elevation
level. Avoid manual TwinCAT work on this server during a build. Other CI jobs
must not install libraries in the shared TwinCAT library repository concurrently.

See also GitHub's [instructions for adding a self-hosted runner](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)
for registration and status checks.

## 6. Start and check the first build

Commit and push the repository files, including
`.github/workflows/twincat-build.yml` and `scripts/Build-TwinCat.ps1`.
The push starts the workflow automatically. On GitHub, select
**Actions → TwinCAT build** and open the run for your commit.

The **Build library and example project** step should show
`Automation host selection: vs2019` in its logs. It first builds and installs
the current library on the buildserver, then builds `tc3-test`.
Under **Artifacts**, download `twincat-build-<run number>` to retrieve the
library and logs produced by the completed steps. A green run confirms
compilation; it does not confirm that PLC runtime tests were executed.

The **Run workflow** button is available for manual runs once the workflow
exists on the default branch.

## Troubleshooting

| Message or symptom | What to check |
| --- | --- |
| `Tc3Build.exe was not found on the buildserver` | Complete steps 2–4. The GitHub variable must be named `TC3_BUILD_EXE`. |
| Executable missing at the configured path | Run `Test-Path` on the buildserver with the exact configured value. Check for an extra ZIP subfolder or quotation marks in the variable value. |
| Missing .NET Runtime | Install the .NET 10 Runtime for **x64**, open a new PowerShell window, and retry `--help`. |
| Missing DLLs or startup errors | Extract the entire CLI ZIP, keeping all files together. |
| Job stays `Queued` | The runner must be online and have all four labels. Keep `run.cmd` running on the buildserver. |
| No usable DTE/COM interface | Check VS2019, its TwinCAT integration, and initial setup. The runner and IDE must use the same account and elevation level. |
| TwinCAT reports missing libraries | Check the server's TwinCAT dependencies. Read the specific error in `library-build.log` or `test-project-build.log` first. |
| No workflow run after a push | Confirm that the pushed commit includes the workflow file and that GitHub Actions is enabled for the repository. |
