Configuration ooManagementStudio {
    param (
        [Parameter(Mandatory)]
        [string] $ResourceLocation
    )
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0

    <#
        ProductId is critical to get right and changes each version. If it's wrong the computer will keep rebooting.
        You can find it AFTER install of SSMS like so:
            Get-ChildItem -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
                Where-Object { $_.Property -contains 'DisplayName' -and $_.GetValue('DisplayName') -like "Microsoft SQL Server Management Studio - *.*" } |
                ForEach-Object { $_.GetValue("DisplayName"); $_.GetValue('BundleProviderKey'); }
    #>
    xPackage 'SSMS190' {
        Name      = 'SSMS190'
        Path      = "$ResourceLocation\SSMS-Setup-ENU-19.0.exe"
        ProductId = '508117ed-3115-4574-a3fc-688cef55e748'
        Arguments = '/install /quiet'
    }
}
