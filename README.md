# JSON-LD
[![JSON-LD](https://img.shields.io/powershellgallery/dt/JSON-LD)](https://www.powershellgallery.com/packages/JSON-LD/)
## Get JSON Linked Data with PowerShell
Get JSON Linked Data with PowerShell

Gets information stored in a page's [json-ld](https://json-ld.org/) (json linked data)

Many pages expose this information for search engine optimization.

This module lets you easily get and work with JSON-LD objects.

## Installing and Importing

You can install JSON-LD from the [PowerShell gallery](https://powershellgallery.com/)

~~~PowerShell
Install-Module JSON-LD -Scope CurrentUser -Force
~~~

Once installed, you can import the module with:

~~~PowerShell
Import-Module JSON-LD -PassThru
~~~


You can also clone the repo and import the module locally:

~~~PowerShell
git clone https://github.com/PoshWeb/JSON-LD
cd ./JSON-LD
Import-Module ./ -PassThru
~~~

## Functions
JSON-LD has 1 function
### Get-JsonLD
#### Gets JSON-LD data from a given URL.
Gets JSON Linked Data from a given URL.

This is a format used by many websites to provide structured data about their content.
##### Examples
###### Example 1
Want to get information about a movie?  Linked Data to the rescue!
~~~PowerShell
Get-JsonLD -Url https://letterboxd.com/film/amelie/
~~~
###### Example 2
Want information about an article?  Lots of news sites use this format.
~~~PowerShell
Get-JsonLD https://www.thebulwark.com/p/mahmoud-khalil-immigration-detention-first-amendment-free-speech-rights
~~~
###### Example 3
Want to get information about a schema?
~~~PowerShell
jsonld https://schema.org/Movie
# Get-JSONLD will output the contents of a `@Graph` object if no `@type` is found.
~~~
##### Parameters

|Name|Type|Description|
|-|-|-|
|Url|Uri|The URL that may contain JSON-LD data|
|as|String|If set, will the output as:<br/><br/>|as|is|<br/>|-|-|<br/>|html|the response as text|<br/>|json|the match as json|<br/>|*jsonld`|ld`|linkedData*|the match as linked data|'<br/>|script|the script tag|<br/>|xml|the script tag, as xml||
|Force|SwitchParameter|If set, will force the request to be made even if the URL has already been cached.|

> (c) 2025-2026 Start-Automating.

> [LICENSE](https://github.com/PoshWeb/JSON-LD/blob/main/LICENSE)
