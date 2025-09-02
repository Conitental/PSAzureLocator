<#
.SYNOPSIS
    Downloads the weekl service tag json from Microsoft.

.DESCRIPTION
    This function parses the download page for the weekly json file for the correct download link and returns the file content.

.PARAMETER DownloadPage
    The download page to look for the download link.

.PARAMETER Pattern
    The pattern to match the download link in the page.

.EXAMPLE
    Get-ServiceTagJson
#>
Function Get-ServiceTagJson {
    Param(
        [String]$DownloadPage = 'https://www.microsoft.com/en-us/download/details.aspx?id=56519',
        [String]$Pattern = 'https://download\.microsoft\.com.*?/ServiceTags_Public_\d+.json'
    )

    Write-Verbose "$($MyInvocation.MyCommand): Parsing content of $DownloadPage using pattern $Pattern"
    $PageContent = Invoke-WebRequest -Uri $DownloadPage -UseBasicParsing

    $Match = [Regex]::Match($PageContent.RawContent, $Pattern)

    if ($Match.Success -eq $false) {
        Write-Error "Could not find download link on page $DownloadPage"
        Return $null
    }

    Write-Verbose "$($MyInvocation.MyCommand): Downloading file from $($Match.Value)"
    $DataBytes = Invoke-WebRequest -Uri $Match.Value -UseBasicParsing | Select-Object -ExpandProperty Content

    Return [System.Text.Encoding]::UTF8.GetString($DataBytes)
}
