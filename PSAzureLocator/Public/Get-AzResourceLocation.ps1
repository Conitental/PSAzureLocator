Function Get-AzResourceLocation {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Alias('DnsName', 'IpAddress', 'Host')]
        [String]$Target
    )

    Begin {
        # $Cache = Get-Variable -Scope Script -Name ServiceTagCache -ValueOnly -ErrorAction SilentlyContinue
    
        If (-not $Cache) {
            Write-Verbose "$($MyInvocation.MyCommand): No cache has been loaded yet. Searching for saved cache."
    
            $Cache = Get-AzServiceTagCache -Path $constant_CacheFile
            Set-Variable -Scope Script -Name ServiceTagCache -Value $Cache
    
            If (-not $Cache) {
                Write-Verbose "$($MyInvocation.MyCommand): No saved cache has been found. Creating it now."
                $Cache = New-AzServiceTagCache -Path $constant_CacheFile
            } Else {
                Write-Verbose "$($MyInvocation.MyCommand): Saved cache has been found"
            }


        } Else {
            Write-Verbose "$($MyInvocation.MyCommand): Session cache will be used."
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
        Foreach($IpAddress in $IpAddresses) {
            Write-Verbose "$($MyInvocation.MyCommand): Find subnet for address: $IpAddress"

            Foreach ($ServiceTag in $Cache.Cache) {
                Foreach ($Subnet in $ServiceTag.Subnets) {
                    If(Test-IpInSubnet -IpAddress $IpAddress -Subnet $Subnet.Subnet -SubnetMask $Subnet.SubnetMask) {
                        [pscustomobject]@{
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
