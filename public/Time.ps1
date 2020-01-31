function Convert-TimeAcrossTimeZone {
	<#
	.SYNOPSIS
	Converts time across 2 timezones

	.DESCRIPTION
	Sometimes you need to know what time it is (or is gonna be) in a different timezone.
	I know I need UTC a lot. And sure, it's simple enough to add 8 or subtract 8
	or whatever your modifier is ... but what's the point of this cool scripting language
	if we don't actually script things. I mean - who wants to think and math is hard and
	stuff.

	So, by default, this function will convert the current time to UTC. BUT, you can enter
	any time (or datetime) and convert that to UTC ... or go even further and specify the
	ID of a specific timezone and poof - converted time.

	And you can get a quick list of IDs (plus current times) via the Get-TimeZoneList
	function - not gonna leave that out, now am I.

	.PARAMETER time
	The time to convert - can be a simple string or a datetime. Defaults to "now"

	.PARAMETER fromTimeZone
	The ID of the TimeZone to convert from. Defaults ot the current timezone

	.PARAMETER toTimeZone
	The ID of the TimeZone to convert to. Defaults to UTC

	.EXAMPLE
	Convert-TimeAcrossTimeZone

	Outputs the current time in UTC

	.EXAMPLE
	Convert-TimeAcrossTimeZone -Time '8:00am'

	Converts 8am in the current TZ to UTC

	.EXAMPLE
	Convert-TimeAcrossTimeZone -Time '8:00 am' -toTimeZone 'Tonga Standard Time'

	Converts 8am in the current TZ to Tonga Standard

	.LINK
	https://docs.microsoft.com/en-us/archive/blogs/rslaten/converting-times-from-one-time-zone-to-another-time-zone-in-powershell
	#>

	param(
		[Parameter(Mandatory = $false)]
		[datetime] $Time = (get-date),
		[Parameter(Mandatory = $false)]
		[ArgumentCompleter( {
				param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
				if ($WordToComplete) {
					(Get-TimeZoneList -QuoteID | Sort-Object ID | Where-Object { $_.ID -match "^`"$WordToComplete" }).ID
				} else {
					(Get-TimeZoneList -QuoteID | Sort-Object ID).ID
				}
			})]
		[ValidateScript( {
				if ($null -eq (Get-TimeZoneList -QuoteID | where-object ID -eq "`"$_`"")) {
					Throw "Could not find TimeZone specified, `"$_`""
				} else {
					$true
				}
			})]
		[string] $FromTimeZone = (Get-TimeZone).ID,
		[Parameter(Mandatory = $false)]
		[ArgumentCompleter( {
				param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
				if ($WordToComplete) {
					(Get-TimeZoneList -QuoteID | Sort-Object ID | Where-Object { $_.ID -match "^`"$WordToComplete" }).ID
				} else {
					(Get-TimeZoneList -QuoteID | Sort-Object ID).ID
				}
			})]
		[ValidateScript( {
				if ($null -eq (Get-TimeZoneList -QuoteID | where-object ID -eq "`"$_`"")) {
					Throw "Could not find TimeZone specified, `"$_`""
				} else {
					$true
				}
			})]
		[string] $ToTimeZone = 'UTC'
	)

	if ($ToTimeZone -eq $FromTimeZone) {
		Write-Host 'Um... both From and To TZs are the same...' -ForegroundColor White
		Write-Host ''
	} else {
		$toNewTimeZone = ConvertTime -time $time -fromTimeZone $fromTimeZone -toTimeZone $toTimeZone
		$InfoStack = New-Object -TypeName PSCustomObject -Property ([ordered] @{
				PSTypeName          = 'brshConversions.ConvertedTime'
				$fromTimeZone       = $time
				$toTimeZone         = $toNewTimeZone
				SourceTimeZone      = $fromTimeZone
				SourceTime          = $time
				DestinationTimeZone = $toTimeZone
				DestinationTime     = $toNewTimeZone
			})

		#Sets the "default properties" when outputting the variable... but really for setting the order
		#I'm doing it this "old" way cuz I don't think I can do the "dynamic" field names in a PS1XML format file :(
		$defaultProperties = @($fromTimeZone, $toTimeZone)
		$defaultDisplayPropertySet = New-Object	System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]] $defaultProperties)
		$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
		$InfoStack | Add-Member MemberSet PSStandardMembers $PSStandardMembers

		$InfoStack
	}
}


function Get-TimeZoneList {
	<#
	.SYNOPSIS
	Lists all known TimeZones - incl offset and "current" time

	.DESCRIPTION
	A handy list of timezones in case you need it (and you need it if you want to convert time across timezones).
	This function also lists the current time in those timezones and whether daylight savings is in effect (although
	I have not fully tested that feature, and I can't guarantee the info is correct. We'll see once we hit DST
	somewhere... and I'll fix/remove if necessary).

	.PARAMETER QuoteID
	Surrounds the ID in quotes (handy when used as a parameter in another function)

	.EXAMPLE
	Get-TimeZoneList

	Returns all the TZs known to the system

	.EXAMPLE
	Get-TimeZoneList | Where ID -eq 'UTC'

	Returns only UTC
	#>
	param (
		[switch] $QuoteID = $false
	)

	$time = [DateTime]::SpecifyKind((Get-Date), [DateTimeKind]::Unspecified)
	$fromTimeZone = (([System.TimeZoneInfo]::Local).Id).ToString()
	foreach ($timeZone in ([system.timezoneinfo]::GetSystemTimeZones() | Sort-Object BaseUtcOffSet, ID)) {
		$tzTime = (ConvertTime -time $time -fromTimeZone $fromTimeZone -toTimeZone $timeZone.id)
		New-Object psobject -Property @{
			'PSTypeName'  = 'brshConversions.TimeZoneList'
			'Name'        = $timeZone.DisplayName
			'ID'          = if ($QuoteID) { "`"$($timeZone.id)`"" } else { $timeZone.id }
			'CurrentTime' = $tzTime
			'IsDST'       = $tzTime.IsDaylightSavingTime()
			'SupportsDST' = $timeZone.SupportsDaylightSavingTime
			'Offset'      = $timeZone.BaseUtcOffSet
		}
	}
}
