function Stop-OftenOnLab {
    [CmdletBinding()]
    param (
        [switch] $TurnOff
    )

    $configurationData = Get-OftenOnLabConfiguration
    if (!$TurnOff) {
        Stop-Lab -ConfigurationData $configurationData -ErrorAction:Continue
    } else {
        $configurationData.AllNodes.NodeName -ne "*" | ForEach-Object {
            Stop-VM -Name $_ -TurnOff -ErrorAction:SilentlyContinue
        }
    }
}
