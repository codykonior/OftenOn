Configuration ooManagementStudio {
    param (
        [Parameter(Mandatory)]
        [string] $ResourceLocation
    )
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

    <#
        ProductId is critical to get right and changes each version. If it's wrong the computer will keep rebooting.
        You can find it AFTER install of SSMS like so:
            Get-ChildItem -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
                Where-Object { $_.Property -contains 'DisplayName' -and $_.GetValue('DisplayName') -like "*17.9*" } |
                ForEach-Object { $_.GetValue('BundleProviderKey') }
    #>
    xPackage 'SSMS1791' {
        Name      = 'SSMS1791'
        Path      = $ResourceLocation
        ProductId = '91a1b895-c621-4038-b34a-01e7affbcb6b'
        Arguments = '/install /quiet'
    }
}
