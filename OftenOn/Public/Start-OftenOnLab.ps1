function Start-OftenOnLab {
    [CmdletBinding()]
    param (
    )

    Start-Lab -ConfigurationData (Get-OftenOnLabConfiguration)
}
