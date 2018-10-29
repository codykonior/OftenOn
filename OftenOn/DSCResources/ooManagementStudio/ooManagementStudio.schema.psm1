Configuration ooManagementStudio {
    param (
        [Parameter(Mandatory)]
        [string] $ResourceLocation
    )

    <#
        ProductId is critical to get right and changes each version. If it's wrong the computer will keep rebooting.
        You can find it AFTER install of SSMS like so:
            Get-ChildItem -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
                Where-Object { $_.Property -contains 'DisplayName' -and $_.GetValue('DisplayName') -like "*17.9*" } |
                ForEach-Object { $_.GetValue('BundleProviderKey') }
    #>
    xPackage 'SSMS179' {
        Name = 'SSMS179'
        Path = $ResourceLocation
        ProductId = 'a0010c7f-d2e9-486b-a658-a1a1106847da'
        Arguments = '/install /quiet'
    }
}
