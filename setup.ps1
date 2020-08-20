$ErrorActionPreference = "Stop"

$versions = $args[0] -Split ","

# Collect installed SDKs.
$installed = & dotnet --list-sdks | ForEach-Object {
  $_.Split(" ")[0]
}

# If any of our required sdks aren't installed
# then install the whole lot. We install all of them rather than just the
# ones that aren't installed because on linux, installing SDKs to a new path overrides
# the old path, and it'll treat it as ONLY having the new sdks.
$install_sdk = $false

$versions | Foreach-Object {
  if (!($installed -contains $_)) {
    $install_sdk = $true
  }
}

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

  # Install any other SDKs required. Only bother installing if not installed already.
  $versions | Foreach-Object {
    Write-Host Installing $_
    . $installer -i $dotnet_path -v $_
  }

  # Tell github about the new SDK location and add it to path for the next step in the pipeline.
  Write-Output "::add-path::$dotnet_path"
}
else {
  Write-Host "SDKs already installed"
}
