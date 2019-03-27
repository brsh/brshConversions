Function Convert-BytesToSize {
	<#
.SYNOPSIS
Converts any integer size given to a user friendly size.

.DESCRIPTION
Converts any integer size given to a user friendly size.

.PARAMETER size
Used to convert into a more readable format.
Required Parameter

.EXAMPLE
ConvertSize -size 134217728
Converts size to show 128MB

.LINK
https://learn-powershell.net/2010/08/29/convert-bytes-to-highest-available-unit/
#>
	#Requires -version 2.0

	[CmdletBinding()]
	Param
	(
		[parameter(Mandatory = $true, Position = 0)]
		[int64] $Size
	)

	#Decide what is the type of size
	Switch ($Size) {
		{$Size -gt 1PB} {
			Write-Verbose "Convert to PB"
			$NewSize = "$([math]::Round(($Size / 1PB),2))PB"
			Break
		}
		{$Size -gt 1TB} {
			Write-Verbose "Convert to TB"
			$NewSize = "$([math]::Round(($Size / 1TB),2))TB"
			Break
		}
		{$Size -gt 1GB} {
			Write-Verbose "Convert to GB"
			$NewSize = "$([math]::Round(($Size / 1GB),2))GB"
			Break
		}
		{$Size -gt 1MB} {
			Write-Verbose "Convert to MB"
			$NewSize = "$([math]::Round(($Size / 1MB),2))MB"
			Break
		}
		{$Size -gt 1KB} {
			Write-Verbose "Convert to KB"
			$NewSize = "$([math]::Round(($Size / 1KB),2))KB"
			Break
		}
		Default {
			Write-Verbose "Convert to Bytes"
			$NewSize = "$([math]::Round($Size,2))Bytes"
			Break
		}
	}
	Return $NewSize
}
