function New-OftenOnLab {
    [CmdletBinding()]
    param(
    )

    OftenOn -ConfigurationData (Get-OftenOnLabConfiguration) -OutputPath "$PSScriptRoot\..\MOF"

    $administrator = New-Object System.Management.Automation.PSCredential('Administrator', ('Admin2018!' | ConvertTo-SecureString -AsPlainText -Force))
    Start-LabConfiguration -ConfigurationData (Get-OftenOnLabConfiguration) -IgnorePendingReboot -Credential $administrator -NoSnapshot -Path "$PSScriptRoot\..\MOF"
}
