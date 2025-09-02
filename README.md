<div align="center">

# PSAzureLocator
PSAzureLocator is a module to locate an Azure resource based on its DNS name or IP address to find the service tag it is located in. This gives information about the Azure region and (if available) the service that it is running.

</div>

## Installation
*PSAzureLocator* is available on the PowerShell Gallery. Use the following command to install it:

```powershell
Install-Module -Name PSAzureLocator -Scope CurrentUser
```

## Usage
Call `Get-AzResourceLocation` and specify the resource you want to locate:
```powershell
# Locate a single resource by DnsName
Get-AzResourceLocation -Target 'myresource.azurewebsites.net'

# Locate a single resource by IpAddress
Get-AzResourceLocation -Target '20.111.18.7'

# Locate multiple resources by providing them as pipeline value
$Resources = @(
  'resource1.azurewebsites.net',
  'resource2.azurewebsites.net',
  'resource3.azurewebsites.net'
)

$Resources | Get-AzResourceLocation
```

## Service Tag Cache
The module will automatically fetch the Azure regions by either using `Az.Network` to get all available service tags or by downloading a weekly JSON file from Microsoft (default).
This behavior can be controlled by using the `UpdateCache`, `IgnoreCacheDate` and `ServiceTagSource` parameters:
```powershell
# Freshly fetch the service tags
Get-AzResourceLocation -Target 'resource.azurewebsites.net' -UpdateCache

# Don't warn about a cache that has not been updated since 7 days
Get-AzResourceLocation -Target 'resource.azurewebsites.net' -IgnoreCacheDate

# Get service tag information using Az.Network
# This requires an AzContext having access to a subscription
Get-AzResourceLocation -Target 'resource.azurewebsites.net' -ServiceTagSource AzureNetworkServiceTagApi
```
