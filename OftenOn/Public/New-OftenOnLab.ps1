function New-OftenOnLab {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
    param (
        [switch] $SkipConfiguration,
        [switch] $SkipStart
    )

    <#
        If these registry keys don't exist then PSDesiredStateConfiguration spams the $Error
        variable with hundreds of SilentlyContinue errors. So instead I set them to the safe
        default value if they don't exist - that way $Error will be clean and it's easier to
        pick up any real errors.
    #>
    if (!(Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShell\3\DSC')) {
        New-Item -Path 'HKLM:\SOFTWARE\Microsoft\PowerShell\3\DSC' -ItemType Directory | Out-Null
    }
    if (!(Get-Item 'HKLM:\SOFTWARE\Microsoft\PowerShell\3\DSC' | Where-Object { $_.Property -eq 'PSDscAllowDomainUser' })) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\PowerShell\3\DSC' -Name 'PSDscAllowDomainUser' -Value "False" | Out-Null
    }
    if (!(Get-Item 'HKLM:\SOFTWARE\Microsoft\PowerShell\3\DSC' | Where-Object { $_.Property -eq 'PSDscAllowPlainTextPassword' })) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\PowerShell\3\DSC' -Name 'PSDscAllowPlainTextPassword' -Value "False" | Out-Null
    }

    # https://johnlouros.com/blog/enabling-strong-cryptography-for-all-dot-net-applications
    if (!([Net.ServicePointManager]::SecurityProtocol -band [System.Net.SecurityProtocolType]::Tls12)) {
        Write-Warning 'Enabling TLS protocols during this session for GitHub downloads as SchUseStrongCrypto is not enabled'
        [Net.ServicePointManager]::SecurityProtocol = 'Tls', 'Tls11', 'Tls12'
    }

    <#
        It's important the configuration data is only retrieved once here because it contains some
        random MAC addresses, and these must be the same between compiling the MOF and starting the
        lab configuration (as Lability will use those to create the VMs and can't read it from the
        MOF)
    #>
    $configurationData = Get-OftenOnLabConfiguration
    OftenOn -ConfigurationData $configurationData -OutputPath "$PSScriptRoot\..\MOF"

    if (!$SkipConfiguration) {
        if (!(Test-LabHostConfiguration -IgnorePendingReboot)) {
            "This is the first run, executing Start-LabHostCpnfiguration to enable Lability prerequisites which are installed to C:\Lability"
            Start-LabHostConfiguration -IgnorePendingReboot
            Write-Error "Start-LabHostConfiguration has completed once. You MUST reboot now before continuing."
        }

        $administrator = New-Object System.Management.Automation.PSCredential('Administrator', ('Admin2019!' | ConvertTo-SecureString -AsPlainText -Force))
        Start-LabConfiguration -ConfigurationData $configurationData -IgnorePendingReboot -Credential $administrator -NoSnapshot -Path "$PSScriptRoot\..\MOF"

        if (!$SkipStart) {
            Start-OftenOnLab
        }
    }
}
