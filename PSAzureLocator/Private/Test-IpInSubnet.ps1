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