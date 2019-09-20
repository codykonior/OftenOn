Configuration ooManagementStudio {
    param (
        [Parameter(Mandatory)]
        [string] $ResourceLocation
    )
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.10.0.0

    <#
        ProductId is critical to get right and changes each version. If it's wrong the computer will keep rebooting.
        You can find it AFTER install of SSMS like so:
            Get-ChildItem -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
                Where-Object { $_.Property -contains 'DisplayName' -and $_.GetValue('DisplayName') -like "*17.9*" } |
                ForEach-Object { $_.GetValue('BundleProviderKey') }
    #>
    xPackage 'SSMS182' {
        Name      = 'SSMS182'
        Path      = "$ResourceLocation\SSMS-Setup-ENU-18.2.exe"
        ProductId = 'e8c8574b-63f8-4b80-8e4c-157a75f00be6'
        Arguments = '/install /quiet'
    }
}
