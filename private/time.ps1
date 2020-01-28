function ConvertTime {
	param(
		$time,
		$fromTimeZone,
		$toTimeZone
	)

	$oFromTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($fromTimeZone)
	$oToTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($toTimeZone)
	$utc = [System.TimeZoneInfo]::ConvertTimeToUtc($time, $oFromTimeZone)
	$newTime = [System.TimeZoneInfo]::ConvertTime($utc, $oToTimeZone)

	[datetime] $newTime
}
