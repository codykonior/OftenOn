function ConvertFrom-CIDR {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( { $_ -match "(.*)\/(\d+)" })]
        [string] $IPAddress
    )

    [void] ($IPAddress -match "(.*)\/(\d+)")
    $ip = [IPAddress] $Matches[1]
    $suffix = [int] $Matches[2]
    $mask = ("1" * $suffix) + ("0" * (32 - $suffix))
    $mask = [IPAddress] ([Convert]::ToUInt64($mask, 2))

    @{
        IPAddress  = $ip.ToString()
        CIDR       = $IPAddress
        CIDRSuffix = $suffix
        NetworkID  = ([IPAddress] ($ip.Address -band $mask.Address)).IPAddressToString
        SubnetMask = $mask.IPAddressToString
    }
}
