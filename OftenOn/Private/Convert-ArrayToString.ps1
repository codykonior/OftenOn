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

function Convert-ArrayToString {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [array] $Array,
        [switch] $Flatten
    )

    begin {
        if ($Flatten) {
            $Mode = 'Append'
        } else {
            $Mode = 'AppendLine'
        }

        if ($Flatten -or $Array.Count -eq 0) {
            $RecursiveIndenting = ''
        } else {
            $RecursiveIndenting = '    ' * (Get-PSCallStack).Where( {$_.Command -match 'Convert-ArrayToString|Convert-HashtableToString' }).Count
        }
    }

    process {
        $stringBuilder = New-Object System.Text.StringBuilder

        if ($Array.Count -ge 1) {
            [void] $stringBuilder.$Mode('@(')
        } else {
            [void] $stringBuilder.Append('@(')
        }

        for ($i = 0; $i -lt $Array.Count; $i++) {
            $item = $Array[$i]

            if ($item -is [String]) {
                [void] $stringBuilder.Append($RecursiveIndenting + "'$item'")
            } elseif ($item -is [int] -or $value -is [double]) {
                [void] $stringBuilder.Append($RecursiveIndenting + "$($item.ToString())")
            } elseif ($item -is [bool]) {
                [void] $stringBuilder.Append($RecursiveIndenting + "`$$($item.ToString().ToLower())")
            } elseif ($item -is [array]) {
                $value = Convert-ArrayToString -Array $item -Flatten:$Flatten

                [void] $stringBuilder.Append($RecursiveIndenting + $value)
            } elseif ($item -is [hashtable]) {
                $value = Convert-HashtableToString -Hashtable $item -Flatten:$Flatten

                [void] $stringBuilder.Append($RecursiveIndenting + $value)
            } else {
                Write-Warning "Array element for $Key is not of known type $($value.GetType().FullName)"
            }

            if ($i -lt ($Array.Count - 1)) {
                if ($Mode -eq 'Append') {
                    [void] $stringBuilder.$Mode(', ')
                } else {
                    [void] $stringBuilder.$Mode(',')
                }
            } elseif (-not $Flatten) {
                [void] $stringBuilder.AppendLine('')
            }
        }

        if ($RecursiveIndenting.Length -ne 0) {
            $thisRecursiveIndenting = $RecursiveIndenting.Substring(0, $RecursiveIndenting.Length - 4)
        } else {
            $thisRecursiveIndenting = $RecursiveIndenting
        }
        [void] $stringBuilder.Append($thisRecursiveIndenting + ')')

        $stringBuilder.ToString()
    }

    end {
    }
}
