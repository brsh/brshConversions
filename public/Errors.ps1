function ConvertFrom-ErrorCode {
	<#
	.SYNOPSIS
	Converts an ErrorCode to a human understandable message

	.DESCRIPTION
	A function to translate Error Codes to "easily" understandable text
	messages. Might not be helpful, depending on the context, but
	something is better than nothing.

	Note - if you're piping 0x codes, it'll automatically be converted
	to an Int32 for the resulting output - sorry about that. Not worth
	it enough to figure any workaround. Meanwhile, using 0x with the
	"ErrorCode" parameter doesn't have that problem, and you can get
	around the piping issue by enclosing the 0x in quotes. See the 2nd
	example for ... an example.

	.PARAMETER ErrorCode
	The numeric error code

	.PARAMETER AsObject
	Returns an object rather than just echoing to screen

	.EXAMPLE
	ConvertFrom-ErrorCode 0x80070BC2
0x80070BC2: The requested operation is successful. Changes will not be effective until the system is rebooted

	.EXAMPLE
	3010, '0x80070BC2', 0x80070BC2 | ConvertFrom-ErrorCode -AsObject

ErrorCode   Message
---------   -------
3010        The requested operation is successful. Changes will not be effective until the system is rebooted
0x80070BC2  The requested operation is successful. Changes will not be effective until the system is rebooted
-2147021886 The requested operation is successful. Changes will not be effective until the system is rebooted

Note: the last 0x was converted to the negative integer form cuz it was sent "native"
	#>

	[Cmdletbinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string] $ErrorCode,
		[switch] $AsObject
	)
	PROCESS {
		try {
			$retval = [ComponentModel.Win32Exception] ([int32] $ErrorCode)

			if ($Null -eq $retval) {
				$retval = 'No error text found'
			}
			if ($AsObject) {
				[PSCustomObject] [ordered] @{
					ErrorCode = $ErrorCode
					Message   = $retval.Message
				}
			} else {
				Write-Status -Message "${ErrorCode}:", "$($retval.Message)" -Type Warning, Info -Level 0
				# Write-Host "${ErrorCode}: " -ForegroundColor Yellow -NoNewline
				# Write-Host "$($retval.Message)" -ForegroundColor White
			}
		} catch {
			'Error converting the code to text'
		}
	}
}
