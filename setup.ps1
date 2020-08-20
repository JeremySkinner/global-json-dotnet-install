$ErrorActionPreference = "Stop"

$path = Join-Path $env:GITHUB_WORKSPACE $args[0]

if (! (Test-Path "$path/global.json")) {
  throw "Path $path not found"
}
cd $path
$json = ConvertFrom-Json (Get-Content "global.json" -Raw)
$required_version = $json.sdk.version
# If there's a version mismatch with what's defined in global.json then a
# call to dotnet --version will generate an error.
try { dotnet --version 2>&1>$null } catch { $install_sdk = $true }

# its also possible that an exception won't be thrown, and exit code will be set instead
# dependent on OS & pwsh version.
if ($global:LASTEXITCODE) {
  $install_sdk = $true;
  $global:LASTEXITCODE = 0;
}

# Couldn't find the required SDK, install it.
if ($install_sdk) {
  $installer = $null;
  if ($IsWindows) {
    # For windows use System.Net.WebClient.
    $installer = "$PWD/dotnet-installer.ps1"
    (New-Object System.Net.WebClient).DownloadFile("https://dot.net/v1/dotnet-install.ps1", $installer);
  }
  else {
    # For linux, use curl as WebClient throws an exception.
    $installer = "$PWD/dotnet-installer"
    write-host Downloading installer to $installer
    curl https://dot.net/v1/dotnet-install.sh -L --output $installer
    chmod +x $installer
  }

  $dotnet_path = "$PWD/.dotnetsdk"
  Write-Host Installing $json.sdk.version to $dotnet_path
  . $installer -i $dotnet_path -v $json.sdk.version

  # Collect installed SDKs.
  $sdks = & "$dotnet_path/dotnet" --list-sdks | ForEach-Object {
    $_.Split(" ")[0]
  }

  # Install any other SDKs required. Only bother installing if not installed already.
  $json.others | Foreach-Object {
    if (!($sdks -contains $_)) {
      Write-Host Installing $_
      . $installer -i $dotnet_path -v $_
    }
  }

  # Tell github about the new SDK location and add it to path for the next step in the pipeline.
  Write-Output "::add-path::$dotnet_path"
}
else {
  Write-Host "SDK $required_version already installed"
}
