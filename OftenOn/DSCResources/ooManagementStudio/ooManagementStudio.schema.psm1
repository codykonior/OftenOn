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
                Where-Object { $_.Property -contains 'DisplayName' -and $_.GetValue('DisplayName') -like "*Studio - 18.*" } |
                ForEach-Object { $_.GetValue('BundleProviderKey') }
    #>
    xPackage 'SSMS183' {
        Name      = 'SSMS183'
        Path      = "$ResourceLocation\SSMS-Setup-ENU-18.3.exe"
        ProductId = '96e72e74-386a-4bcf-ac35-88c7bb6f3103'
        Arguments = '/install /quiet'
    }
}
