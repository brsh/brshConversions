function ConvertFrom-RomanNumeral {
	<#
    .SYNOPSIS
        Convert a Roman numeral to a number
    .DESCRIPTION
        Converts a Roman numeral - in the range of I..MMMCMXCIX - to a number. Found at https://stackoverflow.com/questions/267399/how-do-you-match-only-valid-roman-numerals-with-a-regular-expression
    .EXAMPLE
        ConvertFrom-RomanNumeral -Numeral MMXIV
    .EXAMPLE
        "MMXIV" | ConvertFrom-RomanNumeral
	#>
	[CmdletBinding()]
	[OutputType([int])]
	Param (
		[Parameter(Mandatory = $true,
			HelpMessage = "Enter a roman numeral in the range I..MMMCMXCIX",
			ValueFromPipeline = $true,
			Position = 0)]
		[ValidatePattern("^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$")]
		[string] $Numeral
	)
	Begin {
		$RomanToDecimal = [ordered]@{
			M  = 1000
			CM = 900
			D  = 500
			CD = 400
			C  = 100
			XC = 90
			L  = 50
			X  = 10
			IX = 9
			V  = 5
			IV = 4
			I  = 1
		}
	}
	Process {
		$roman = $Numeral + " "
		$value = 0

		do {
			foreach ($key in $RomanToDecimal.Keys) {
				if ($key.Length -eq 1) {
					if ($key -match $roman.Substring(0, 1)) {
						$value += $RomanToDecimal.$key
						$roman = $roman.Substring(1)
						break
					}
				} else {
					if ($key -match $roman.Substring(0, 2)) {
						$value += $RomanToDecimal.$key
						$roman = $roman.Substring(2)
						break
					}
				}
			}
		} until ($roman -eq " ")
		$value
	}
	End {
	}
}

New-Alias -name "FromRoman" -value ConvertFrom-RomanNumeral -Description "Convert from a roman numeral" -Force

function ConvertTo-RomanNumeral {
	<#
    .SYNOPSIS
        Convert a number to a Roman numeral
    .DESCRIPTION
        Converts a number - in the range of 1 to 3,999 - to a Roman numeral. Found at https://stackoverflow.com/questions/267399/how-do-you-match-only-valid-roman-numerals-with-a-regular-expression
    .EXAMPLE
        ConvertTo-RomanNumeral -Number (Get-Date).Year
    .EXAMPLE
        (Get-Date).Year | ConvertTo-RomanNumeral
	#>
	[CmdletBinding()]
	[OutputType([string])]
	Param (
		[Parameter(Mandatory = $true,
			HelpMessage = "Enter an integer in the range 1 to 3,999",
			ValueFromPipeline = $true,
			Position = 0)]
		[ValidateRange(1, 4999)] [int] $Number
	)
	Begin {
		$DecimalToRoman = @{
			Ones      = "", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX";
			Tens      = "", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC";
			Hundreds  = "", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM";
			Thousands = "", "M", "MM", "MMM", "MMMM"
		}
		$column = @{Thousands = 0; Hundreds = 1; Tens = 2; Ones = 3}
	}
	Process {
		[int[]]$digits = $Number.ToString().PadLeft(4, "0").ToCharArray() | ForEach-Object { [Char]::GetNumericValue($_) }
		$RomanNumeral = ""
		$RomanNumeral += $DecimalToRoman.Thousands[$digits[$column.Thousands]]
		$RomanNumeral += $DecimalToRoman.Hundreds[$digits[$column.Hundreds]]
		$RomanNumeral += $DecimalToRoman.Tens[$digits[$column.Tens]]
		$RomanNumeral += $DecimalToRoman.Ones[$digits[$column.Ones]]

		$RomanNumeral
	}
	End {
	}
}

New-Alias -name "ToRoman" -value ConvertTo-RomanNumeral -Description "Convert to a roman numeral" -Force

Function ConvertTo-Ordinal {
	<#
    .SYNOPSIS
        Add a suffix to numeral
    .DESCRIPTION
        Adds the ordinal (??) suffix to a number. Handy for denoting the 1st, 2nd, or 3rd... etc. ... of something. Defaults to the current day.
    .EXAMPLE
        ConvertTo-Ordinal -Number (Get-Date).Day
    .EXAMPLE
        PS > "The $(ConvertTo-Ordinal (Get-Date).Day) day of the $(ConvertTo-Ordinal (Get-Date).ToString("%M")) month of the $(ConvertTo-Ordinal (Get-Date).Year) year"

        The 25th day of the 3rd month of the 2016th year
	#>
	[CmdletBinding()]
	[OutputType([string])]
	Param (
		[Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
		[int]$Number = (Get-Date).Day
	)
	Switch ($Number % 100) {
		11 { $suffix = "th" }
		12 { $suffix = "th" }
		13 { $suffix = "th" }
		default {
			Switch ($Number % 10) {
				1 { $suffix = "st" }
				2 { $suffix = "nd" }
				3 { $suffix = "rd" }
				default { $suffix = "th"}
			}
		}
	}
	"$Number$suffix"
}
