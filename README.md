# global-json-dotnet-install

Github action that installs .NET SDKs specified in global.json.

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

The SDKs are installed into the `.dotnetsdk` directory and this is added to the PATH.

This task is a temporary workaround until `setup-dotnet` supports side-by-side SDK installation (see https://github.com/actions/setup-dotnet/issues/25)
