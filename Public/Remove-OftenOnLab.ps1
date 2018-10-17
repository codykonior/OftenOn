function Remove-OftenOnLab {
    [CmdletBinding()]
    param(
        [switch] $MasterVirtualHardDisk
    )

    Remove-Item "$PSScriptRoot\..\MOF\*"
    Remove-LabConfiguration -ConfigurationData (Get-OftenOnLabConfiguration) -ErrorAction:Continue -Confirm:$false
    # Remove-Item C:\Lability\VMVirtualHardDisks\*

    if ($MasterVirtualHardDisk) {
        Remove-Item C:\Lability\MasterVirtualHardDisks\*
    }
}
