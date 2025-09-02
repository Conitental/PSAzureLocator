Function Get-AzResourceLocation {
    [CmdletBinding()]
    Param(
        [String]$DnsName
    )

    $IpAddresses = [System.Net.Dns]::GetHostAddresses($DnsName).IPAddressToString

    $Cache = Get-Variable -Scope Script -Name ServiceTagCache -ValueOnly -ErrorAction SilentlyContinue

    If (-not $Cache) {
        Write-Verbose "No cache loaded yet. Try reading from file"

        $Cache = Get-AzServiceTagCache -Path $constant_CacheFile
        Set-Variable -Scope Script -Name ServiceTagCache -Value $Cache

        If (-not $Cache) {
            Write-Verbose "No saved cache found. Creating it now."
            $Cache = New-AzServiceTagCache -Path $constant_CacheFile
        } Else {
            Write-Verbose "Use saved cache"
        }
    } Else {
        Write-Verbose "Use session cache"
    }

    Foreach($IPAddress in $IpAddresses) {
        Foreach ($ServiceTag in $Cache) {
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
