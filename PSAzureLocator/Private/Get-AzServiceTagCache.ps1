Function Get-AzServiceTagCache {
    Param(
        [String]$Path
    )

    If (-not (Test-Path $Path)) {
        Return $false
    }

    Return (Get-Content $Path -Encoding utf8 | ConvertFrom-Json)
}