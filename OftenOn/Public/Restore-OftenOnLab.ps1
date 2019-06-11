function Restore-OftenOnLab {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $SnapshotName = 'Default'
    )

    Restore-Lab -ConfigurationData (Get-OftenOnLabConfiguration) -SnapshotName $SnapshotName -Force
}
