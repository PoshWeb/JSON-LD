function Get-JsonLD {
    <#
    .SYNOPSIS
        Gets JSON-LD data from a given URL.
    .DESCRIPTION
        Gets JSON Linked Data from a given URL.
        
        This is a format used by many websites to provide structured data about their content.
    .EXAMPLE
        # Want to get information about a movie?  Linked Data to the rescue!
        Get-JsonLD -Url https://letterboxd.com/film/amelie/
    .EXAMPLE
        # Want information about an article?  Lots of news sites use this format.
        Get-JsonLD https://www.thebulwark.com/p/mahmoud-khalil-immigration-detention-first-amendment-free-speech-rights    
    .EXAMPLE
        # Want to get information about a schema?
        jsonld https://schema.org/Movie
        # Get-JSONLD will output the contents of a `@Graph` object if no `@type` is found.        
    #>
    [Alias('jsonLD','json-ld')]
    param(
    # The URL that may contain JSON-LD data
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('href','uri')]
    [Uri]
    $Url,

    <#
    
    If set, will the output as:

    |as|is|
    |-|-|
    |html|the response as text|
    |json|the match as json|
    |*jsonld`|ld`|linkedData*|the match as linked data|'
    |script|the script tag|
    |xml|the script tag, as xml|
    
    #>    
    [ValidateSet('html', 'json', 'jsonld', 'ld', 'linkedData', 'script', 'xml')]
    [string]
    $as = 'jsonld',

    # If set, will force the request to be made even if the URL has already been cached.
    [Alias('IgnoreCache')]
    [switch]
    $Force
    )

    begin {
        # Create a pattern to match the JSON-LD script tag
        $linkedDataRegex = [Regex]::new(@'
(?<HTML_LinkedData>
<script                                       # Match <script tag
\s{1,}                                        # Then whitespace
type=                                         # Then the type= attribute (this regex will only match if it is first)
[\"\']                                        # Double or Single Quotes
application/ld\+json                          # The type that indicates linked data
[\"\']                                        # Double or Single Quotes
[^>]{0,}                                      # Match anything until the end of the start tag
\>                                            # Match the end of the start tag
(?<JsonContent>(?:.|\s){0,}?(?=\z|</script>)) # Anything until the end tag is JSONContent
)        
'@, 'IgnoreCase,IgnorePatternWhitespace','00:00:00.1')

        # Initialize the cache for JSON-LD requests
        if (-not $script:Cache) {
            $script:Cache = [Ordered]@{}
        }

        # Construct a filter to match and output 
        filter matchAndOutput {
            
            $contentToMatch = $_
            if ($contentToMatch -match '^\s{0,}\{') {
                $contentToMatch = "<script type='application/ld+json'>$($contentToMatch)</script>"                
            }
            
            if ($as -eq 'html') {            
                return $contentToMatch
            }            
            
            # Find all linked data tags within the response
            foreach ($match in $linkedDataRegex.Matches("$($contentToMatch)")) {
                # If we want the result as xml
                if ($As -eq 'xml') {
                    # try to cast it
                    $matchXml ="$match" -as [xml]
                    if ($matchXml) {
                        # and output it if found.
                        $matchXml
                        continue
                    } else {
                        # otherwise, fall back to the `<script>` tag
                        $As = 'script'
                    }
                }

                # If we want the tag, that should be the whole match
                if ($As -eq 'script') {
                    "$match"
                    continue
                }
                
                # If we want it as json, we have a match group.
                if ($As -eq 'json') {
                    $match.Groups['JsonContent'].Value
                    continue
                }
                # Otherwise, we want it as linked data, so convert from the json
                foreach ($jsonObject in 
                    $match.Groups['JsonContent'].Value | 
                        ConvertFrom-Json
                ) {
                    # If there was a `@type` or `@graph` property
                    if (
                        $jsonObject.'@type' -or 
                        $jsonObject.'@graph'
                    ) {
                        # output the object as jsonld
                        $jsonObject | output
                        continue                    
                    }                
                    # If there is neither a `@type` or a `@graph`
                    else {
                        # just output the object.
                        $jsonObject
                    }                
                }
            }

        }

        # Construct a filter to output out content
        
        filter output {
            # We want JSON-LD types to become .pstypenames, and this should happen recursively.
            $in = $_
            # we can use `MyInvocation.MyCommand` to anonymously recurse
            # (this makes it easier if the name of this command changes)
            $mySelf = $MyInvocation.MyCommand

            # Context could be a string or an object
            # When it is a string, it is a root type.
            if ($in.'@context' -is [string]) {
                $context  = $in.'@context' # so set the context
                # ( this variable will leek down into lower scopes )
                # ( so we can reuse common contexts (like `schema.org` ))
            }
            
            # If we have a graph of outputs
            if ($in.'@graph') {
                # decorate the entire graph as `application/ld+json`
                if ($in.pstypenames -ne 'application/ld+json') {
                    $in.pstypenames.insert(0,'application/ld+json')
                }
                # and then call ourself
                foreach ($graphObject in $in.'@graph') {
                    # (null the return so we only output the topmost object)
                    $null = $graphObject |
                        & $mySelf
                }
            }
            # If we have a single type of object
            elseif ($in.'@type') {
                # combine it with the context to get our typename
                $typeName = if ($context) {
                    $context, $in.'@type' -join '/'
                } else {
                    $in.'@type'
                }

                # Decorate the type as `application/ld+json`
                if ($in.pstypenames -ne 'application/ld+json') {
                    $in.pstypenames.insert(0,'application/ld+json')
                }
                # and decocate the item as the `$typeName`
                if ($in.pstypenames -ne $typeName) {
                    $in.pstypenames.insert(0,$typeName)
                }

                # Then go over each property
                foreach ($property in $in.psobject.properties) {
                    # if the property had a `@type`
                    if ($property.value.'@type') {
                        # call ourself on the value
                        # (null the return so we only output the topmost object)
                        $null = $property.value |
                            & $mySelf
                    }
                }
            }

            # Now that we've finished decorating out graph or type
            # output our modified input.
            $in
        }

        # Files will be treated as .json
        $foreachFile = {
            $inFile = $_.FullName
            try {                
                Get-Content -LiteralPath $_.FullName -Raw | 
                    matchAndOutput
            } catch {
                Write-Verbose "$($inFile.FullName) : $_"
            }
        }
    }

    process {        
        if ($url.IsFile -or 
            -not $url.AbsoluteUri
        ) {
            if (Test-Path $url.OriginalString) {
                Get-ChildItem $url.OriginalString -File |
                    Foreach-Object $foreachFile
            } elseif ($MyInvocation.MyCommand.Module -and 
                (Test-Path (
                    Join-Path (
                        $MyInvocation.MyCommand.Module | Split-Path
                    ) $url.OriginalString
                ))
            ) {
                Get-ChildItem -Path (
                    Join-Path (
                        $MyInvocation.MyCommand.Module | Split-Path
                    ) $url.OriginalString  
                ) -File |
                    Foreach-Object $foreachFile
            }
            
            return
        }
            
        $restResponse = 
            if ($Force -or -not $script:Cache[$url]) {
                $script:Cache[$url] = Invoke-WebRequest -Uri $Url
                $script:Cache[$url]
            } else {
                $script:Cache[$url]
            }
        
        
        if ($restResponse.Headers['Content-Type'] -match 'json') {
            if ($restResponse.Content -is [byte[]]) {                    
                [Text.Encoding]::UTF8.GetString($restResponse.Content) | matchAndOutput
            } else {
                $restResponse.Content | matchAndOutput
            }                
        } elseif ($restResponse.Content -is [string]) {
            $restResponse.Content | matchAndOutput
        } else {
            ""
        }                
    }
}
