Function Convert-SubnetMask {
	<#
    .SYNOPSIS
        Converts to and from CIDR/SubnetMask
    .DESCRIPTION
		Sometimes you need the CIDR, sometimes you need the Subnet Mask. Sometimes you need to know how many
		ip addresses are contained in a specific CIDR/SubnetMask. Well, here ya go.

		'Course, we all know that valid CIDR values are 8-30, with 32 being a specific host.

		Based on work found on reddit:
			https://www.reddit.com/r/PowerShell/comments/82mxds/inspired_by_latest_shortest_script_challenge_ipv4/
			https://www.reddit.com/r/PowerShell/comments/81x324/shortest_script_challenge_cidr_to_subnet_mask/

		And
			http://www.ryandrane.com/2016/05/getting-ip-network-information-powershell/

    .EXAMPLE
		Convert-SubnetMask -CIDR 24

CIDR             : 24
NumberOfHosts    : 254
BroadcastAddress : 10.0.0.255
NetworkAddress   : 10.0.0.0
Mask             : 255.255.255.0
Class			 : C

    .EXAMPLE
		Convert-SubnetMask -Mask '255.255.0.0'

CIDR             : 16
NumberOfHosts    : 65534
BroadcastAddress : 10.0.255.255
NetworkAddress   : 10.0.0.0
Mask             : 255.255.0.0
Class            : B

	.EXAMPLE
		Convert-SubnetMask -Mask '255.255.0.0' -IPAddress '10.10.0.0'

CIDR             : 16
NumberOfHosts    : 65534
BroadcastAddress : 10.10.255.255
NetworkAddress   : 10.10.0.0
Mask             : 255.255.0.0
Class            : B

#>
	[CmdletBinding(DefaultParameterSetName = "CIDR")]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'CIDR', Position = 0)]
		[ValidateScript( { (($_ -le 30) -and ($_ -ge 8)) -or ($_ -eq 32) } )]
		[int] $CIDR,
		[Parameter(Mandatory = $true, ParameterSetName = 'MASK', Position = 0)]
		[ValidateScript( { $_ -match [ipaddress] $_ })]
		[Alias('Subnet', 'SubnetMask')]
		[string] $Mask,
		[Parameter(Mandatory = $false, ParameterSetName = 'CIDR', Position = 1)]
		[Parameter(Mandatory = $false, ParameterSetName = 'MASK', Position = 1)]
		[ValidateScript( { $_ -match [ipaddress] $_ })]
		[Alias('Address', 'IP')]
		[ipaddress] $IPAddress = '10.0.0.1'
	)

	[string] $MASKFinal = ''
	[int] $CIDRFinal = ''

	#these 1-liners were found on reddit
	if ($PSCmdlet.ParameterSetName -eq 'CIDR') {
		$CIDRFinal = $CIDR
		try {
			$MASKFinal = ([ipaddress]([uint32]::MaxValue - [math]::Pow(2, 32 - $CIDR) + 1)).IPAddressToString
		} catch {
			$MASKFinal = 'Invalid CIDR Value'
		}
	} elseif ($PSCmdlet.ParameterSetName -eq "MASK") {
		$MASKFinal = $Mask
		try {
			$CIDRFinal = (($Mask.Split('.') | ForEach-Object { [convert]::ToString($_, 2) }) -join '' -replace (0)).Length
		} catch {
			$CIDRFinal = 'Invalid Mask Value'
		}
	} else {
		throw "Invalid parameters!"
	}

	try {
		#https://blogs.technet.microsoft.com/heyscriptingguy/2011/11/11/use-powershell-to-easily-convert-decimal-to-binary-and-back/
		$BinMask = $i = $null
		$MASKFinal.Split('.') | ForEach-Object {
			$i++
			[string]$BinMask += [convert]::ToString([int32]$_, 2).PadLeft(8, '0')
			if ($i -le 3) { [string]$BinMask += "." }
		}
	} catch {
		$BinMask = "Could not convert Mask"
	}

	#this part was found http://www.ryandrane.com/2016/05/getting-ip-network-information-powershell/
	# Get Arrays of [Byte] objects, one for each octet in our IP and Mask
	$IPAddressBytes = ([ipaddress]::Parse($IPAddress)).GetAddressBytes()
	$SubnetMaskBytes = ([ipaddress]::Parse($MASKFinal)).GetAddressBytes()

	# Declare empty arrays to hold output
	$NetworkAddressBytes = @()
	$BroadcastAddressBytes = @()
	$WildcardMaskBytes = @()

	# Determine Broadcast / Network Addresses, as well as Wildcard Mask
	for ($i = 0; $i -lt 4; $i++) {
		# Compare each Octet in the host IP to the Mask using bitwise
		# to obtain our Network Address
		$NetworkAddressBytes += $IPAddressBytes[$i] -band $SubnetMaskBytes[$i]

		# Compare each Octet in the subnet mask to 255 to get our wildcard mask
		$WildcardMaskBytes += $SubnetMaskBytes[$i] -bxor 255

		# Compare each octet in network address to wildcard mask to get broadcast.
		$BroadcastAddressBytes += $NetworkAddressBytes[$i] -bxor $WildcardMaskBytes[$i]
	}

	# Create variables to hold our NetworkAddress, WildcardMask, BroadcastAddress
	$NetworkAddress = $NetworkAddressBytes -join '.'
	$BroadcastAddress = $BroadcastAddressBytes -join '.'

	# Now that we have our Network, Widcard, and broadcast information,
	# We need to reverse the byte order in our Network and Broadcast addresses
	[array]::Reverse($NetworkAddressBytes)
	[array]::Reverse($BroadcastAddressBytes)

	# We also need to reverse the array of our IP address in order to get its
	# integer representation
	[array]::Reverse($IPAddressBytes)

	# Next we convert them both to 32-bit integers
	$NetworkAddressInt = [System.BitConverter]::ToUInt32($NetworkAddressBytes, 0)
	$BroadcastAddressInt = [System.BitConverter]::ToUInt32($BroadcastAddressBytes, 0)

	# Calculate the number of hosts in our subnet, subtracting one to account for network address.
	[int] $NumberOfHosts = ($BroadcastAddressInt - $NetworkAddressInt) - 1

	# And class
	[string] $Class = Switch ($CIDRFinal) {
		{ $_ -lt 16 } { 'A'; break }
		{ $_ -lt 24 } { 'B'; break }
		{ $_ -lt 32 } { 'C'; break }
		{ $_ -eq 32 } { 'Host'; break }
	}

	New-Object -TypeName psobject -Property ([ordered] @{
			Class            = $Class
			NumberOfHosts    = $NumberOfHosts
			Mask             = $MASKFinal
			CIDR             = $CIDRFinal
			BinaryMask       = $BinMask
			NetworkAddress   = $NetworkAddress
			BroadcastAddress = $BroadcastAddress
		})
}

Function Convert-AddressToName($addr) {
	<#
    .SYNOPSIS
        DNS ip to name lookup
    .DESCRIPTION
        Uses DNS to get the name(s) for a specific ip address
    .EXAMPLE
        Convert-AddressToName 127.0.0.1
	#>
	[system.net.dns]::GetHostByAddress($addr)
}

Function Convert-NameToAddress($addr) {
	<#
    .SYNOPSIS
        DNS name to ip lookup
    .DESCRIPTION
        Uses DNS to get the ip address(es) for a specific computername
    .EXAMPLE
        Convert-NameToAddress myVM
	#>
	[system.net.dns]::GetHostByName($addr)
}

New-Alias -name "n2a" -value Convert-NameToAddress -Description "Get IP Address from DNS by Host Name" -Force
New-Alias -name "a2n" -value Convert-AddressToName -Description "Get Host Name from DNS by IP Address" -Force
