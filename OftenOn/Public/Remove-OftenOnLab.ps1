function Remove-OftenOnLab {
    [CmdletBinding()]
    param (
        [switch] $MasterVirtualHardDisk
    )

    Stop-OftenOnLab -TurnOff

    Remove-Item "$PSScriptRoot\..\MOF\*.mof"
    Remove-LabConfiguration -ConfigurationData (Get-OftenOnLabConfiguration) -ErrorAction:Continue -Confirm:$false

    if ($MasterVirtualHardDisk) {
        Remove-Item "$((Get-LabHostDefault).ParentVhdPath)\*.*"
    }
}
