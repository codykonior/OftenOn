function Checkpoint-OftenOnLab {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $SnapshotName = 'Default'
    )

    Checkpoint-Lab -ConfigurationData (Get-OftenOnLabConfiguration) -SnapshotName $SnapshotName
}
