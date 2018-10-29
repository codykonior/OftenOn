function New-OftenOnCompositeResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $ResourceName
    )

    New-Item -ItemType Directory "$PSScriptRoot\..\DSCResources\$ResourceName"
    New-ModuleManifest "$PSScriptRoot\..\DSCResources\$ResourceName\$($ResourceName).psd1" -RootModule ".\$($ResourceName).schema.psm1" -Author "Cody Konior" -CompanyName ""
    $content = "Configuration $ResourceName {

}
"
    [System.IO.File]::WriteAllLines("$PSScriptRoot\..\DSCResources\$ResourceName\$($ResourceName).schema.psm1", $content)
    code "$PSScriptRoot\..\DSCResources\$ResourceName\$($ResourceName).schema.psm1"
}
