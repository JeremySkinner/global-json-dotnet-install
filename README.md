# global-json-dotnet-install

Github action that installs .NET SDKs.

Allows optional additional SDKs to be installed (for example, if you install the .NET 3.1 SDK, you can't run .NET Core 2 apps unless you have the .NET Core 2 runtime installed too)

For example, given this global.json, the .NET 5 preview 7 SDK will be installed if it isn't present on the system, along with .NET Core 3.1 and 2.1 SDKs.

(The "others" property is not part of the global.json spec, it's just used by this task)

```json
{
    "sdk": {
      "version": "5.0.100-preview.7.20366.6",
      "rollForward": "latestFeature"
    },
    "others": ["3.1.201", "2.2.105"]
}
```

In your Github Actions yaml file you can then specify the following to extract these version numbers and then install the relevant SDKS.

```yaml
jobs:
  build:
    steps:
    - name: Checkout
      uses: actions/checkout@v2
      with:
        fetch-depth: 0

    - name: Get SDKs to install
      shell: pwsh
      # Collect the SDKs we need by parsing global.json
      # Supplementary sdks are stored in an "others" array.
      run: |
        $json = ConvertFrom-Json (Get-Content global.json -Raw)
        $sdks = ($json.others + $json.sdk.version) -join ","
        Write-Output "::set-env name=REQUIRED_SDKS::$sdks"

    - name: Install .NET SDKs
      uses: JeremySkinner/global-json-dotnet-install@master
      with:
        versions: ${{ env.REQUIRED_SDKS }}

```

The SDKs are installed into the `.dotnetsdk` directory and this is added to the PATH.

This task is a temporary workaround until `setup-dotnet` supports side-by-side SDK installation (see https://github.com/actions/setup-dotnet/issues/25)
