<#
.SYNOPSIS
    Reads the content of a saved service tag cache.

.DESCRIPTION
    Reads the content of a saved service tag cache and returns the converted psobject.

.PARAMETER Path
    The filepath to load the cache from.

.EXAMPLE
    Get-AzServiceTagCache -Path '~/cache.json'
#>
Function Get-AzServiceTagCache {
    Param(
        [String]$Path
    )

    If (-not (Test-Path $Path)) {
        Return $false
    }

    Return (Get-Content $Path -Encoding utf8 | ConvertFrom-Json)
}