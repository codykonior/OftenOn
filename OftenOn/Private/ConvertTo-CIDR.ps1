function ConvertTo-CIDR {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [string] $IPAddress,
        [Parameter(Mandatory)]
        [string] $SubnetMask
    )

    $ip = [IPAddress] $IPAddress
    $mask = [IPAddress] $SubnetMask
    [void] ($mask.IPAddressToString -match '(.*)\.(.*)\.(.*)\.(.*)')
    $suffix = ""
    $Matches[1..4] | ForEach-Object {
        $suffix += [Convert]::ToString([int] $_, 2) + ("0" * (8 - [Convert]::ToString([int] $_, 2).Length))
    }
    $suffix = ($suffix -split "[^1]")[0].Length

    @{
        IPAddres   = $IPAddress
        CIDR       = "$IPAddress/$suffix"
        CIDRSuffix = $suffix
        NetworkID  = ([IPAddress] ($ip.Address -band $mask.Address)).IPAddressToString
        SubnetMask = $mask.IPAddressToString
    }
}
