function Remove-OftenOnLab {
    [CmdletBinding()]
    param (
        [switch] $MasterVirtualHardDisk
    )

    Remove-Item "$PSScriptRoot\..\MOF\*.mof"
    Remove-LabConfiguration -ConfigurationData (Get-OftenOnLabConfiguration) -ErrorAction:Continue -Confirm:$false

    if ($MasterVirtualHardDisk) {
        Remove-Item "$((Get-LabHostDefault).ParentVhdPath)\*.*"
    }
}
