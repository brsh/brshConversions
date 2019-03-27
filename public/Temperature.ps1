Function ConvertTo-Fahrenheit([decimal]$celsius) {
	<#
    .SYNOPSIS
        Degrees C to F
    .DESCRIPTION
        Simple math to convert temperature
    .EXAMPLE
        ConvertTo-Fahrenheit 100
	#>
	$((1.8 * $celsius) + 32 )
}

Function ConvertTo-Celsius($fahrenheit) {
	<#
    .SYNOPSIS
        Degrees F to C
    .DESCRIPTION
        Simple math to convert temperature
    .EXAMPLE
        ConvertTo-Celsius 32
	#>
	$( (($fahrenheit - 32) / 9) * 5 )
}

New-Alias -name "ToF" -Value ConvertTo-Fahrenheit -Description "Convert degrees C to F" -Force
New-Alias -name "ToC" -Value ConvertTo-Celsius -Description "Convert degrees F to C" -Force
