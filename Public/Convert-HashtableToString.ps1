<#
    Copyright (c) 2018 Adrian Rodriguez, Cody Konior

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

function Convert-HashtableToString {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable] $Hashtable,
        [switch] $Flatten
    )

    begin {
        $stringBuilder = [System.Text.StringBuilder]::new()
    }

    process {
        if ($Flatten -or $Hashtable.Keys.Count -eq 0) {
            $Mode = 'Append'
            $RecursiveIndenting = ''
        } else {
            $Mode = 'Appendline'
            $RecursiveIndenting = '    ' * (Get-PSCallStack).Where({ $_.Command -match 'Convert-ArrayToString|Convert-HashtableToString' }).Count
        }

        if ($Hashtable.Keys.Count -ge 1) {
            [void] $stringBuilder.$Mode('@{')
        } else {
            [void] $stringBuilder.Append('@{')
        }

        foreach ($Key in $Hashtable.Keys) {
            $value = $Hashtable[$Key]

            if ($Key -match '\s') {
                $Key = "'$Key'"
            }

            if ($value -is [string]) {
                [void] $stringBuilder.$Mode($RecursiveIndenting + "$Key = '$value'")
            } elseif ($value -is [int] -or $value -is [double] -or $value -is [int64]) {
                [void] $stringBuilder.$Mode($RecursiveIndenting + "$Key = $($value.ToString())")
            } elseif ($value -is [bool]) {
                [void] $stringBuilder.$Mode($RecursiveIndenting + "$Key = `$$($value.ToString().ToLower())")
            } elseif ($value -is [array]) {
                $value = Convert-ArrayToString -Array $value -Flatten:$Flatten
                [void] $stringBuilder.$Mode($RecursiveIndenting + "$Key = $value")
            } elseif ($value -is [hashtable]) {
                $value = Convert-HashtableToString -Hashtable $value -Flatten:$Flatten
                [void] $stringBuilder.$Mode($RecursiveIndenting + "$Key = $value")
            } else {
                Write-Warning "Key value for $Key is not of known type $($value.GetType().FullName)"
            }

            if ($Flatten) {
                [void] $stringBuilder.Append('; ')
            }
        }

        if ($RecursiveIndenting.Length -ne 0) {
            $thisRecursiveIndenting = $RecursiveIndenting.Substring(0, $RecursiveIndenting.Length - 4)
        } else {
            $thisRecursiveIndenting = $RecursiveIndenting
        }
        [void] $stringBuilder.Append($thisRecursiveIndenting + "}")

        $stringBuilder.ToString().Replace('; }', '}')
    }

    end {
    }
}
