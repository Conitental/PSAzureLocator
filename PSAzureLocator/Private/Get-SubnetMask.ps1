Function Get-SubnetMask {
    Param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 32)]
        [int]$Cidr
    )

    # Create a 32-character string of '1's for the network portion and '0's for the host portion
    $binaryString = ('1' * $Cidr).PadRight(32, '0')

    # Split the binary string into four 8-bit octets
    $octet1 = $binaryString.Substring(0, 8)
    $octet2 = $binaryString.Substring(8, 8)
    $octet3 = $binaryString.Substring(16, 8)
    $octet4 = $binaryString.Substring(24, 8)

    # Convert each binary octet to a decimal number
    $decimalOctet1 = [convert]::ToInt32($octet1, 2)
    $decimalOctet2 = [convert]::ToInt32($octet2, 2)
    $decimalOctet3 = [convert]::ToInt32($octet3, 2)
    $decimalOctet4 = [convert]::ToInt32($octet4, 2)

    # Format and return the subnet mask string
    return "$decimalOctet1.$decimalOctet2.$decimalOctet3.$decimalOctet4"
}