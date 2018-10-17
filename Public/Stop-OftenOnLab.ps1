function Stop-OftenOnLab {
    [CmdletBinding()]
    param(
    )

    Stop-Lab -ConfigurationData (Get-OftenOnLabConfiguration) -ErrorAction:Continue
}
