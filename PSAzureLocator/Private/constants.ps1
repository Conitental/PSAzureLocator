Set-Variable -Option Constant -Name constant_CacheFile -Value "$PSScriptRoot\..\cache.json"

Enum ServiceTagSource {
    WeeklyJson
    AzureNetworkServiceTagApi
}