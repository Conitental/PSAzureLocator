<#
.SYNOPSIS
    Finds the Azure region of a given resource.

.DESCRIPTION
    Resolves a target to get its ip address and finds matching subnets from Azure network service tags.

.PARAMETER Target
    The target DnsName or IpAddress of the resource.

.PARAMETER UpdateCache
    Choose to update the existing service tag cache.

.PARAMETER IgnoreCacheDate
    Don't prompt for a cache update if it is older than 7 days.

.PARAMETER ServiceTagSource
    The source of the service tags. They can either be fetched through Graph API or by downloading a weekly Json file from Microsoft (default).

.EXAMPLE
    Get-AzResourceLocation -Target 'resource.contoso.com'
#>
Function Get-AzResourceLocation {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    Param(
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Alias('DnsName', 'IpAddress', 'Host')]
        [String]$Target,
        [Switch]$UpdateCache,
        [Switch]$IgnoreCacheDate,
        [ServiceTagSource]$ServiceTagSource = [ServiceTagSource]::WeeklyJson
    )

    Begin {
        # Try to load cache from a previous invocation
        $Cache = Get-Variable -Scope Script -Name ServiceTagCache -ValueOnly -ErrorAction SilentlyContinue

        If ($UpdateCache) {
            Write-Verbose "$($MyInvocation.MyCommand): -UpdateCache used: Force cache update"
            $Cache = New-AzServiceTagCache -Path $constant_CacheFile -Source $ServiceTagSource
        }
    
        If (-not $Cache) {
            Write-Verbose "$($MyInvocation.MyCommand): No cache has been loaded yet. Searching for saved cache."
            
            # Check if we have a saved cache
            $Cache = Get-AzServiceTagCache -Path $constant_CacheFile
            Set-Variable -Scope Script -Name ServiceTagCache -Value $Cache
            
            # Do we need to create a new cache?
            If (-not $Cache) {
                Write-Verbose "$($MyInvocation.MyCommand): No saved cache has been found. Creating it now."
                $Cache = New-AzServiceTagCache -Path $constant_CacheFile -Source $ServiceTagSource
            } Else {
                Write-Verbose "$($MyInvocation.MyCommand): Saved cache has been found"
            }

        } Else {
            Write-Verbose "$($MyInvocation.MyCommand): Session cache will be used."
        }

        # Check cache age and decide if we fetch a new one
        If($Cache.Date -lt (Get-Date).AddDays(-7) -and -not $IgnoreCacheDate) {
            Write-Verbose "$($MyInvocation.MyCommand): Cache is outdated. Date: $($Cache.Date)"
            # TODO: Take actual age of downloaded data into account
            If($PSCmdlet.ShouldContinue("Your saved cache file is older than 7 days. Would you like to update it?`nUse -IgnoreCacheDate to prevent this message", "Cache out of date")) {
                $Cache = New-AzServiceTagCache -Path $constant_CacheFile -Source $ServiceTagSource
            } Else {
                Write-Verbose "$($MyInvocation.MyCommand): We will use the existing cache"
            }
        }
    }

    Process {
        # Check what kind of target we are dealing with
        # Simple regex test
        # [System.Net.IPAddress]::TryParse() might be a better option
        Write-Verbose "$($MyInvocation.MyCommand): Target: $Target"
        If($Target -notmatch '^(\d+\.){3}\d+') {
            # Get host addresses
            $IpAddresses = [System.Net.Dns]::GetHostAddresses($Target).IPAddressToString
        } Else {
            # Take target as is
            $IpAddresses = $Target
        }
        
        # We are treating the target address as collection multiple dns records could have been returned
        # TODO: Think of a better way to find matches than three loops
        Foreach($IpAddress in $IpAddresses) {
            Write-Verbose "$($MyInvocation.MyCommand): Find subnet for address: $IpAddress"

            Foreach ($ServiceTag in $Cache.Cache) {
                Foreach ($Subnet in $ServiceTag.Subnets) {
                    If(Test-IpInSubnet -IpAddress $IpAddress -Subnet $Subnet.Subnet -SubnetMask $Subnet.SubnetMask) {
                        [pscustomobject]@{
                            Target        = $Target
                            IpAddress     = $IpAddress
                            Region        = $ServiceTag.Name
                            SystemService = $ServiceTag.SystemService
                            ChangeNumber  = $ServiceTag.ChangeNumber
                            CidrBlock     = $Subnet.Subnet + '/' + $Subnet.Cidr
                        }
                    }
                }
            }
        }
    }
}
