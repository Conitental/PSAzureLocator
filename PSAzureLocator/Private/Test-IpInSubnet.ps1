<#
.SYNOPSIS
    Checks if a given ip address is in a subnet.

.EXAMPLE
    Test-IpInSubnet -IpAddress 192.168.18.7 -Subnet 192.168.18.0 -SubnetMask 255.255.255.0
#>
Function Test-IpInSubnet {
    Param(
        [Parameter(Mandatory)]
        [ipaddress]$IpAddress,
        [Parameter(Mandatory)]
        [ipaddress]$Subnet,
        [Parameter(Mandatory)]
        [ipaddress]$SubnetMask
    )

    Return $Subnet.Address -eq ($Ipaddress.Address -band $SubnetMask.Address)
}