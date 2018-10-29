function Repair-OftenOnRemoteDesktop {
    [CmdletBinding()]
    param(
    )

    #region Apply a local RDP fix so that it can connect to unpatched RDP servers such as will be in our VMs.
    if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP)) {
        New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP
    }
    if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters)) {
        New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters
    }
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -Name 'AllowEncryptionOracle' -Value 2 -Type DWord
    #endregion
}
