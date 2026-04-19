@{
    RootModule = 'JSON-LD.psm1'
    ModuleVersion = '0.1.2'
    GUID = '4e65477c-012c-4077-87c7-3e07964636ce'
    Author = 'James Brundage'
    CompanyName = 'Start-Automating'
    Copyright = '(c) 2025-2026 Start-Automating.'
    Description = 'Get JSON Linked Data with PowerShell'
    FunctionsToExport = 'Get-JsonLD'
    AliasesToExport = 'jsonLD', 'json-ld'
    TypesToProcess = 'JSON-LD.types.ps1xml'
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('json-ld','SEO','Web','PoshWeb','LinkedData','schema.org')
            # A URL to the license for this module.
            ProjectURI = 'https://github.com/PoshWeb/JSON-LD'
            LicenseURI = 'https://github.com/PoshWeb/JSON-LD/blob/main/LICENSE'
            PSIntro = @'
Get JSON Linked Data with PowerShell

Gets information stored in a page's [json-ld](https://json-ld.org/) (json linked data)

Many pages expose this information for search engine optimization.

This module lets you easily get and work with JSON-LD objects.
'@
            ReleaseNotes = @'
---

## JSON-LD 0.1.2

* Aliasing Url to Uri (#12)
* Supporting direct JSON-LD content links (#27)

Thanks @AniTexs for the suggestion!

---

Please:

* [Like, Share, and Subscribe](https://github.com/PowerShellWeb/JSON-LD)
* [Support Us](https://github.com/sponsors/StartAutomating)

Additional History in [CHANGELOG](https://github.com/PoshWeb/JSON-LD/blob/main/CHANGELOG.md)
'@
        }
    }
    
}