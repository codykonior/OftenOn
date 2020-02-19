Configuration ooManagementStudio {
    param (
        [Parameter(Mandatory)]
        [string] $ResourceLocation
    )
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.0.0

    <#
        ProductId is critical to get right and changes each version. If it's wrong the computer will keep rebooting.
        You can find it AFTER install of SSMS like so:
            Get-ChildItem -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
                Where-Object { $_.Property -contains 'DisplayName' -and $_.GetValue('DisplayName') -like "*Studio - 18.*" } |
                ForEach-Object { $_.GetValue('BundleProviderKey') }
    #>
    xPackage 'SSMS184' {
        Name      = 'SSMS184'
        Path      = "$ResourceLocation\SSMS-Setup-ENU-18.4.exe"
        ProductId = '7871da56-98b6-4ef8-b4d4-b7c310e14146'
        Arguments = '/install /quiet'
    }
}
