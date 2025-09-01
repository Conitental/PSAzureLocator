Function New-AzServiceTagCache {
    Param(
        [String]$Path
    )

    Write-Progress -Activity "Building service tag cache. This can take a moment." -PercentComplete 0
    $ServiceTags = (Get-AzNetworkServiceTag -Location 'eastus').Values.Properties | Where-Object { -not [String]::IsNullOrEmpty($_.Region) }

    $i = 0
    $Cache = Foreach ($ServiceTag in $ServiceTags) {
        $Progress = $i * 80 / $ServiceTags.Count
        $i += 1
        Write-Progress -Activity "Building service tag cache. This can take a moment." -Status "$([math]::Round($Progress, 0))% Calculating $($ServiceTag.Region) ranges" -PercentComplete $Progress

        # TODO: Remove the regex and support IPv6
        $AddressPrefixes = $ServiceTag.AddressPrefixes | Where-Object { $_ -match '(\d+\.){3}\d+/\d+' }

        [pscustomobject]@{
            Name = $ServiceTag.Region
            Service = $ServiceTag.SystemService
            ChangeNumber = $ServiceTag.ChangeNumber
            Subnets = Foreach($Prefix in $AddressPrefixes) {
                $NetworkAddress = $Prefix -replace '/\d+'
                $Cidr = $Prefix -replace '^.*?/'

                [pscustomobject]@{
                    Subnet = $NetworkAddress
                    Cidr = $Cidr
                    SubnetMask = Get-SubnetMask -Cidr $Cidr
                }
            }
        }
    }

    # Save cache to location
    If($Path) {
        $Cache | ConvertTo-Json -Depth 5 | Out-File $Path -Encoding utf8
    }

    # Make cache usable in module
    Set-Variable -Scope Script -Name ServiceTagCache -Value $Cache

    # For direct use in case we are creating the cache the first time
    Return $Cache

    Write-Progress -Completed
}