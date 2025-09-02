Function New-AzServiceTagCache {
    Param(
        [String]$Path,
        [ServiceTagSource]$Source = [ServiceTagSource]::WeeklyJson
    )

    If ($Source -eq 'WeeklyJson') {
        Write-Progress -Activity "Building service tag cache" -Status "Downloading weekly JSON file" -PercentComplete 0
        Write-Verbose "$($MyInvocation.MyCommand): Fetching cache from weekly json"

        $JsonData = Get-ServiceTagJson
        $ServiceTags = (ConvertFrom-Json -InputObject $JsonData).values.properties | Where-Object { -not [String]::IsNullOrEmpty($_.region) }
    } Else {
        Write-Progress -Activity "Building service tag cache" -Status "Fetching service tags from API" -PercentComplete 0
        Write-Verbose "$($MyInvocation.MyCommand): Fetching cache using service tag API"

        If (-not (Get-AzContext).Subscription.Id) {
            Write-Error "$($MyInvocation.MyCommand): You are trying to fetch service tags from the API but no AzContext with SubscriptionId could be found. Make sure to run Connect-AzAccount with an account that has permissions on a subscription."
            Return $null
        }
        $ServiceTags = (Get-AzNetworkServiceTag -Location 'eastus').Values.Properties | Where-Object { -not [String]::IsNullOrEmpty($_.Region) }
    }

    $i = 0
    $CalculatedRanges = Foreach ($ServiceTag in $ServiceTags) {
        $Progress = $i * 80 / $ServiceTags.Count
        $i += 1
        Write-Progress -Activity "Building service tag cache" -Status "$([math]::Round($Progress, 0))% Calculating $($ServiceTag.Region) ranges" -PercentComplete $Progress

        # TODO: Remove the regex and support IPv6
        $AddressPrefixes = $ServiceTag.AddressPrefixes | Where-Object { $_ -match '(\d+\.){3}\d+/\d+' }

        [pscustomobject]@{
            Name = $ServiceTag.Region
            SystemService = $ServiceTag.SystemService
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

    # Add timestamp to cache
    $Cache = [pscustomobject]@{
        Date = Get-Date
        Cache = $CalculatedRanges
    }

    # Save cache to location
    If($Path) {
        Write-Verbose "$($MyInvocation.MyCommand): Saving cache to $Path"
        $Cache | ConvertTo-Json -Depth 10 | Out-File $Path -Encoding utf8
    }

    # Make cache usable in module
    Set-Variable -Scope Script -Name ServiceTagCache -Value $Cache

    # For direct use in case we are creating the cache the first time
    Return $Cache

    Write-Progress -Completed
}
