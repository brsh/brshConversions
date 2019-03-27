function ConvertFrom-SID {
	<#
    .SYNOPSIS
        Security ID to Username
    .DESCRIPTION
        Gets the username for a specified system SID
    .EXAMPLE
        ConvertFrom-sid S-1-5-21-4079184686-3691728653-2528636808-500
	#>
	param([string]$SID = "S-1-0-0")
	$objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
	$objUser = $objSID.Translate([System.Security.Principal.NTAccount])
	$objUser.Value
}

function ConvertTo-SID {
	<#
    .SYNOPSIS
        Username to Security ID
    .DESCRIPTION
        Gets the system SID for a specified username
    .EXAMPLE
        ConvertTo-SID administrator
	#>
	param([string]$ID = "Null SID")
	$objID = New-Object System.Security.Principal.NTAccount($ID)
	$objSID = $objID.Translate([System.Security.Principal.SecurityIdentifier])
	Return $objSID.Value
}

new-alias -name FromSID -value ConvertFrom-SID -Description "Get UserName from SID" -Force
new-alias -name ToSID -value ConvertTo-SID -Description "Get SID from UserName" -Force
