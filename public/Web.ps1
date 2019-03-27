Function ConvertTo-URLEncode([string]$Text = "You did not enter any text!") {
	<#
    .SYNOPSIS
        URL EN-code a string
    .DESCRIPTION
        Replaces "special characters" with their URL-clean codes
    .EXAMPLE
        ConvertTo-URLEncode "This is a string;+^"
	#>
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.web")
	[System.Web.HttpUtility]::UrlEncode($Text)
}

Function ConvertFrom-URLEncode([string]$Text = "You+did+not+enter+any+text!") {
	<#
    .SYNOPSIS
        URL DE-code a string
    .DESCRIPTION
        Replaces URL-clean codes with the ASCII "special characters"
    .EXAMPLE
        ConvertFrom-URLEncode "This%20is%20a%20string%3b%2b%5e"
	#>
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.web")
	[System.Web.HttpUtility]::UrlDecode($Text)
}

New-Alias -name "URLEncode" -Value ConvertTo-URLEncode -Description "URL encode a string" -Force
New-Alias -name "URLDecode" -Value ConvertFrom-URLEncode -Description "URL decode a string" -Force

Function ConvertTo-Base64([string]$Text = "You+did+not+enter+any+text!") {
	<#
    .SYNOPSIS
        Convert a string to Base64 encoding
    .DESCRIPTION
        Replaces a text string into Base64
    .EXAMPLE
        ConvertTo-Base64 "This is a string."
	#>
	try {
		[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
	} catch {
		Write-Host "Could not convert string to Base64:"
		Write-Host "    $($_.Exception.Message)"
	}
}

Function ConvertFrom-Base64([string]$Text = "You+did+not+enter+any+text!") {
	<#
    .SYNOPSIS
        Convert a string from Base64 encoding to UTF-8
    .DESCRIPTION
        Replaces a text string from Base64
    .EXAMPLE
        ConvertFrom-Base64 "This is a string."
	#>
	try {
		[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Text))
	} catch {
		Write-Host "Could not convert string from Base64:" -ForegroundColor Yellow
		Write-Host "    $($_.Exception.Message)" -ForegroundColor Red
	}
}

Function ConvertFrom-HTML {
	<#
	.SYNOPSIS
	Strips common HTML codes from stings

	.DESCRIPTION
	A 'quick' function to remove html codes and replace them with the appropriate text

	.EXAMPLE
	ConvertFrom-HTML (new-object net.webclient).DownloadString("https://github.com/brsh/")
	.LINK
	winstonfassett.com/blog/2010/09/21/html-to-text-conversion-in-powershell/

	#>
	param (
		[string] $Text
	)
	# remove line breaks, replace with spaces
	$html = $Text -replace "(`r|`n|`t)", " "
	# write-verbose "removed line breaks: `n`n$html`n"

	# remove invisible content
	@('head', 'style', 'script', 'object', 'embed', 'applet', 'noframes', 'noscript', 'noembed') | ForEach-Object {
		$html = $html -replace "<$_[^>]*?>.*?</$_>", ""
	}
	# write-verbose "removed invisible blocks: `n`n$html`n"

	# Condense extra whitespace
	$html = $html -replace "( )+", " "
	# write-verbose "condensed whitespace: `n`n$html`n"

	# Add line breaks
	@('div', 'p', 'blockquote', 'h[1-9]') | ForEach-Object { $html = $html -replace "</?$_[^>]*?>.*?</$_>", ("`n" + '$0' )}
	# Add line breaks for self-closing tags
	@('div', 'p', 'blockquote', 'h[1-9]', 'br') | ForEach-Object { $html = $html -replace "<$_[^>]*?/>", ('$0' + "`n")}
	# write-verbose "added line breaks: `n`n$html`n"

	#strip tags
	$html = $html -replace "<[^>]*?>", ""
	# write-verbose "removed tags: `n`n$html`n"

	# replace common entities
	@(
		@("&amp;bull;", " * "),
		@("&amp;lsaquo;", "<"),
		@("&amp;rsaquo;", ">"),
		@("&amp;(rsquo|lsquo);", "'"),
		@("&amp;(quot|ldquo|rdquo);", '"'),
		@("&amp;trade;", "(tm)"),
		@("&amp;frasl;", "/"),
		@("&amp;(quot|#34|#034|#x22);", '"'),
		@('&amp;(amp|#38|#038|#x26);', "&amp;"),
		@("&amp;(lt|#60|#060|#x3c);", "<"),
		@("&amp;(gt|#62|#062|#x3e);", ">"),
		@('&amp;(copy|#169);', "(c)"),
		@("&amp;(reg|#174);", "(r)"),
		@("&amp;nbsp;", " "),
		@("&amp;(.{2,6});", "")
	) | ForEach-Object { $html = $html -replace $_[0], $_[1] }
	# write-verbose "replaced entities: `n`n$html`n"

	$html


}
