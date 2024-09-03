Function Invoke-GeminiRequest
{
	[CmdletBinding(DefaultParameterSetName='ToScreen')]
	[OutputType([PSCustomObject], ParameterSetName='ToScreen')]
	[OutputType([Void], ParameterSetName='OutFile')]
	[Alias('igemr', 'Invoke-GemRequest')]
	Param(
		[Parameter(Mandatory, Position=0)]
		[Alias('Url')]
		[ValidateNotNullOrEmpty()]
		[Uri] $Uri,

		[Security.Cryptography.X509Certificates.X509Certificate] $Certificate,

		[Switch] $FavIcon,

		[Parameter(ValueFromPipeline)]
		[Alias('Input')]
		[AllowNull()]
		[String] $InputObject,

		[Parameter(ParameterSetName='OutFile')]
		[ValidateNotNullOrEmpty()]
		[String] $OutFile,

		[Switch] $SkipCertificateCheck
	)

	# Version 3.0 was the latest version available at this time.
	Set-StrictMode -Version 3.0

	# PowerShell doesn't recognize the gemini:// scheme.  Thus, we need to
	# re-define our URI object with the port explicitly mentioned -- if
	# and only if the user does not specify a non-standard port.
	If ($Uri.Port -eq -1)
	{
		$newURI = "gemini://" + $Uri.Host + ":1965" + $Uri.AbsolutePath + ($Uri.Query ? "?$($Uri.Query)" : '')
		$Uri = $Uri::new($newURI)
	}

	#region Establish TCP connection.
	Write-Verbose "Connecting to $($Uri.Host):$($Uri.Port)"
	Try
	{
		$TcpSocket = [Net.Sockets.TcpClient]::new($Uri.Host, $Uri.Port)
		$TcpStream = $TcpSocket.GetStream()
		$TcpStream.ReadTimeout = 2000 #milliseconds
		Write-Debug 'TCP socket open'

		# Bring up our secure stream.
		# The third parameter disables .NET Core's built-in certificate validation.
		# Trust-on-first-use logic happens a little later on.
		$secureStream = [Net.Security.SslStream]::new($TcpStream, $false, {$true}, $null)

		If ($null -ne $Certificate)
		{
			Write-Verbose "Using a client certificate."
			Write-Debug $Certificate
		}
		Else
		{
			Write-Debug "Not using a client certificate."
		}
		$secureStream.AuthenticateAsClient(
			$Uri.Host,
			$Certificate,
			[Net.SecurityProtocolType]::Tls13 -bor [Net.SecurityProtocolType]::Tls12,
			($null -ne $Certificate)
		)
		$TcpStream = $secureStream
		Write-Verbose "Connected to $($Uri.Host):$($Uri.Port) with $($TcpStream.SslProtocol)."
		Write-Debug "Using $($TcpStream.SslProtocol) with ciphersuite $($TcpStream.NegotiatedCipherSuite)."
	}
	Catch
	{
		# Throw a non-terminating error so that $? is set properly and the
		# pipeline can continue.  This will allow chaining operators to work as
		# intended.  Should a future version of this module support pipeline
		# input, that will let this cmdlet keep running with other input URIs.
		$er = [Management.Automation.ErrorRecord]::new(
			[Net.WebException]::new("Could not connect to $($Uri.Host):$($Uri.Port).  Aborting."),
			'TlsConnectionFailed',
			[Management.Automation.ErrorCategory]::ConnectionError,
			$Uri
		)
		$er.CategoryInfo.Activity = 'NegotiateTlsConnection'
		$PSCmdlet.WriteError($er)
		Return $null
	}
	#endregion (Establish TCP connection)

	#region Certificate TOFU validation
	If ($SkipCertificateCheck)
	{
		Write-Warning 'Skipping certificate validation.  This is not secure!'
	}
	Else
	{
		$cert = $TcpStream.RemoteCertificate
		Write-Debug "This certificate:    Fingerprint=$($cert.GetPublicKeyString()) Expires=$(Get-Date $cert.GetExpirationDateString())"
		$trustedCert = Get-PSGeminiKnownCertificate -HostName $Uri.Host -Port $Uri.Port
	
		If ($null -ne $trustedCert)
		{
			Write-Debug "Trusted certificate: Fingerprint=$($trustedCert.Fingerprint) Expires=$($trustedCert.ExpirationDate)"
	
			# We've connected to this server before, and this is the same certificate.
			If ($cert.GetPublicKeyString() -eq $trustedCert.Fingerprint)
			{
				Write-Verbose "Certificate validation succeeded."
			}
	
			# We've connected to this server before, but the old certificate expired.
			ElseIf ($trustedCert.ExpirationDate -lt (Get-Date))
			{
				Remove-PSGeminiKnownCertificate -HostName $Uri.Host -Confirm:$false
				Write-Warning "Subsequent visit. Memorizing new certificate for $($Uri.Host):$($Uri.Port)."
				Add-PSGeminiKnownCertificate -HostName $Uri.Host -Port $Uri.Port -Fingerprint $cert.GetPublicKeyString() -ExpirationDate (Get-Date $cert.GetExpirationDateString())
			}
	
			# We've connected to the server before, but the old certificate should
			# still be valid.
			Else
			{
				Write-Error "$($Uri.Host) presented a new certificate, and the memorized one is still valid.  Failing the connection for your own safety."
				Write-Debug "This: $($trustedCert.Fingerprint))"
				Write-Debug "That: $($cert.GetPublicKeyString())"
				Return $null
			}
		}
		Else
		{
			Write-Warning "First visit. Memorizing new certificate for $($Uri.Host):$($Uri.Port)."
			Add-PSGeminiKnownCertificate -HostName $Uri.Host -Port $Uri.Port -Fingerprint $cert.GetPublicKeyString() -ExpirationDate (Get-Date $cert.GetExpirationDateString())
		}	
	}
	#endregion SSL validation

	#region Send data
	# The Gemini specification (Section 2) requires the GET request to be
	# limited to 1024 bytes, so that's what we're doing here.
	$ToSend = $Uri.AbsoluteUri.Substring(0, [Math]::Min(1024, $Uri.AbsoluteUri.Length)) + "`r`n"

	Write-Verbose "Sending $($ToSend.Length) bytes to server."
	Write-Debug   "Sending $($ToSend.Length) bytes to server:  $($ToSend -Replace "`r",'\r' -Replace "`n",'\n' -Replace "`t",'\t')"
	
	$writer = [IO.StreamWriter]::new($TcpStream)
	$writer.WriteLine($ToSend)
	$writer.Flush()
	#endregion (send data)

	#region Get response header
	$response = ''
	$Encoder = [Text.UTF8Encoding]::new()
	$buffer = New-Object Byte[] 1029	# <STATUS><SPACE><META><CR><LF>

	While (($response -NotLike "*`r`n") -and (0 -ne ($bytesRead = $TcpStream.Read($buffer, 0, 1))))
	{
		Write-Debug "`tReading a byte from the server."
		$response += $Encoder.GetString($buffer, 0, $bytesRead)
	}
	Write-Verbose "Received $($Encoder.GetByteCount($response)) bytes from server."

	# Extract only the first line.
	$Status, $Meta = ($response -Split "`r`n")[0] -Split ' ',2
	$Meta = $Meta.Trim()
	Write-Debug "Response: $response"
	Write-Verbose "Recieved a status $Status with meta: $Meta"

	# This Switch statement will handle the Gemini server's response.  In all
	# error cases, we will throw a non-terminating error so that $? is set
	# properly and the pipeline can continue. This will allow chaining operators
	# to work as intended.  Should a future version of this module support
	# pipeline input, that will let this cmdlet keep running with other input
	# URIs.
	Switch ($Status)
	{ 
		10	# input
		{
			$InputObject ??= Read-Host -Prompt ($Meta ?? 'The server is requesting input: ')
			Return (Invoke-GeminiRequest "$Uri?$InputObject" -OutFile $OutFile)
		}

		11	# sensitive input
		{
			$InputObject ??= Read-Host -Prompt ($Meta ?? 'The server is requesting input: ') -MaskInput
			Return (Invoke-GeminiRequest "$Uri?$InputObject" -OutFile $OutFile)
		}

		20	# success
		{
			# If the server didn't send a MIME type, assume it to be this.
			# See section 3.3 of the Gemini specification.
			$Meta ??= 'text/gemini; charset=utf-8'
			Break
		}

		30	# temporary redirect
		{
			Write-Warning "Temporary redirect encountered.  Redirecting to $Meta"
			Return (Invoke-GeminiRequest $Meta -OutFile:$OutFile)
		}

		31	# permanent redirect
		{
			Write-Warning "Permanent redirect encountered.  Redirecting to $Meta"
			Return (Invoke-GeminiRequest $Meta -OutFile:$OutFile)
		}

		40	# temporary failure
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("A temporary failure occurred.  The server said: $Meta"),
				'TemporaryFailure',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'An unspecified condition exists on the server that is preventing the content from being served.  You may try again.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.40'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		41	# server not available
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("The server is not available.  The server said: $Meta"),
				'ServerUnavailable',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'The server is unavailable due to overload or maintenance.  You should try again later.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.41'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		42	# CGI error
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("A CGI error occurred.  The server said: $Meta"),
				'CGIError',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'A CGI process on the server died unexpectedly or timed out.  You may try again.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.42'
			$PSCmdlet.WriteError($er)
			
			Return $null
		}

		43	# proxy error
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("A proxy error occurred.  The server said: $Meta"),
				'ProxyError',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'A proxy request failed because the server was unable to successfully complete a transaction with the remote host.  You may try again.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.43'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		44	# rate-limiting
		{
			Write-Warning "Slow down.  The server provided this error: $Meta"
			For ($i = $Meta; $i -lt 0; $i++) {
				Write-Progress -Activity 'Waiting to retry this request.' -SecondsRemaining $i
				Start-Sleep 1
			}
			Invoke-GeminiRequest -InputObject:$InputObject -OutFile:$OutFile -SslVersion:$SslVersion -Uri:$Uri
		}

		50	# request failed
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("The request failed.  The server said: $Meta"),
				'PermanentFailure',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'Sorry, something went wrong (on the server side).  Please try again later.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.50'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		51	# resource not found
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("The resource was not found.  The server said: $Meta"),
				'ResourceNotFound',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'The requested resource could not be found.  Check the link you followed, and try again later.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.51'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		52	# resource gone
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("The resource is permanently gone.  The server said: $Meta"),
				'ResourceGone',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'The requested resource is gone forever.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.52'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		53	# proxy request refused
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("The proxy request was refused.  The server said: $Meta"),
				'ProxyRequestRefused',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'The request was for a resource at a domain not served by the server and the server does not accept proxy requests.  Please do not use this server as a proxy.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.53'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		59	# bad request
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("The request was invalid.  The server said: $Meta"),
				'BadRequest',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'The server was unable to parse your request, presumably due to a malformed request, or the request violated the contraints listed in the Request section.  Please change your request and try again.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.59'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		60	# client certificate required
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("A client certificate is required.  The server said: $Meta"),
				'ClientCertificateRequired',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'The content requires a client certificate.  You must provide a certificate in order to access the content, and should not repeat the request without one.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.60'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		61	# client certificate rejected
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("The client certificate is not authorized.  The server said: $Meta"),
				'ClientCertificateUnauthorized',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'The supplied client certificate is not authorized for accessing this particular requested resource. The problem is not with the certificate itself, which may be authorized for other resources.  Select another certificate and try again.'
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.61'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		62	# client certificate invalid
		{
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("The client certificate is not valid.  The server said: $Meta"),
				'ClientCertificateInvalid',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = "The supplied client certificate was not accepted because it is not valid. This indicates a problem with the certificate in and of itself, with no consideration of the particular requested resource. The most likely cause is that the certificate's validity start date is in the future or its expiry date has passed, but this code may also indicate an invalid signature, or a violation of X.509 standard requirements."
			$er.FullyQualifiedErrorId = 'PSGemini.GeminiProtocol.62'
			$PSCmdlet.WriteError($er)
			Return $null
		}

		default {
			$er = [Management.Automation.ErrorRecord]::new(
				[Net.ProtocolViolationException]::new("An invalid status code was received: $Response"),
				'InvalidGeminiStatusCode',
				[Management.Automation.ErrorCategory]::ConnectionError,
				$Uri
			)
			$er.CategoryInfo.Activity = 'ParseResponseHeader'
			$er.ErrorDetails = 'The server sent an undefined status code.  Please check its response for more information.'
			$PSCmdlet.WriteError($er)
			Return $null
		}
	}

	# If we made it this far, then we've encountered status code 20 (success).
	# Check the <META> to see our MIME type.  If we have a text type, or if we
	# have an application that's text-based (e.g., JSON, XML), let's process
	# this as text instead.  This mainly affects the output, but not the content
	# of the saved and/or displayed resource.
	$BINARY_TRANSFER = -Not (
		$Meta -Like 'text/*' -or
		$Meta -eq 'application/json' -or $Meta -Like '*/*+json' -or
		$Meta -eq 'application/xml' -or $Meta -Like '*/*+xml'
	)
	
	# Do we have MIME parameters (e.g., "text/gemini; charset=UTF-8")?
	# We will include these in a Headers object.
	$Headers = @()
	$Parameters = $Meta -Split ";\s*"
	If ($Parameters.Length -gt 1)
	{
		$Parameter, $Value = $Parameters[1].Trim() -Split '='
		Write-Debug "Found `"$Parameter`" with value `"$Value`""
		$Headers += [PSCustomObject]@{$Parameter.Trim() = $Value.Trim()}
	}

	# Start reading the response body.  Save the response header first.
	$RawContent = $response
	$response   = ''

	If (-Not $BINARY_TRANSFER)
	{
		$BufferSize = 2048
		$Buffer     = New-Object Byte[] $BufferSize

		Write-Debug 'Beginning to read textual data.'
		While (0 -ne ($bytesRead = $TcpStream.Read($buffer, 0, $BufferSize)))
		{
			Write-Debug "`tReading ≤$BufferSize bytes from the server."
			$response += $Encoder.GetString($buffer, 0, $bytesRead)
		}
		Write-Verbose "Received $($Encoder.GetByteCount($response)) bytes from server."
	}
	Else # it is a binary transfer #
	{
		$BufferSize = 51200
		$Buffer     = New-Object Byte[] $BufferSize
		$Response   = [IO.MemoryStream]::new()

		Write-Debug 'Beginning to read binary data.'
		While (0 -ne ($bytesRead = $TcpStream.Read($buffer, 0, $BufferSize)))
		{
			Write-Debug "`tReading ≤$BufferSize bytes from the server."
			$response.Write($buffer, 0, $bytesRead)
		}
		$response.Flush()
		Write-Verbose "Received $($response.Length) bytes from server."
	}
	$writer.Close()
	$TCPSocket.Close()
	#endregion (Receive data)

	#region Parse response
	$Content  = ''
	$Headings = @()
	$Links    = @()

	If ($BINARY_TRANSFER)
	{
		$Content = $response.ToArray()
	}
	Else
	{
		$response -Split "([`r`n]+)" | ForEach-Object {
			#Write-Debug "OUTPUT: $($_ -Replace "`r",'' -Replace "`n",'')"

			# Build content variable
			If ($_.Length -gt 0)
			{
				$Content += $_
			}

			# Look for links and headings.
			If (-Not $OutFile -and $Meta -CLike 'text/gemini*')
			{
				If ($_.Length -gt 1  -and  $_[0] -eq '#')
				{
					$Line = $_ -Split "\s+",2
					$Headings += [PSCustomObject]@{
						'Level'   = $Line[0].Trim().Length
						'Content' = $Line[1].Trim()
					}
				}

				# Links
				ElseIf ($_.Length -gt 2  -and  $_.Substring(0,2) -eq '=>')
				{
					Write-Debug "Found a link: $_"

					# Split the link line into the URL and the title.
					# Note that spacing after the "=>" is _optional_, per
					# the Gemini Protocol specification version 0.24.1.
					$href, $title = $_.Substring(2).Trim() -Split '\s+',2

					# Because PowerShell doesn't recognize the gemini:// scheme,
					# we need to go through the painstaking process of building
					# our System.Uri object manually.
					$detectedURI = [Uri]::new($Uri, $href)
					<#Write-Verbose "URI: $detectedURI"
					$builtURI    = ''

					# Absolute URIs in Gemtext will be assumed to be of the
					# file:// scheme.  In that case, we can simply rename it.
					$builtURI += ($detectedURI.Scheme -eq 'file' ? 'gemini' : $detectedURI.Scheme) + '://'

					$builtURI += ($detectedURI.Host -eq '' ? $Uri.Host : $detectedURI.Host)

					# Add the port if need be.
					If ($detectedURI.IsDefaultPort -eq $false) {
						$builtURI += ':' + ($detectedURI.Port -eq -1 ? 1965 : $detectedURI.Port)
					}

					$builtURI += $detectedURI.AbsolutePath

					If ($Uri.Query) {
						$builtURI += '?' + $detectedURI.Query
					}
					$builtURI += ($Uri.Query)
					#>

					Write-Debug "=> Link=`"$href`", title=`"$title`", href=$detectedURI"
					$Links += [PSCustomObject]@{
						'href'  = $detectedURI -Replace ":$($Uri.Port)"
						'title' = $title
					}
				}
			}
		}
	}
	#endregion

	#region Deliver response
	If ($OutFile)
	{
		Write-Verbose "Writing $($response.Length) bytes to $OutFile"
		Set-Content -Path $OutFile -Value $Content -AsByteStream
	}
	Else	# not writing to a file
	{
		$retval = [PSCustomObject]@{
			'StatusCode' = $Status
			'StatusDescription' = $Meta
			'Content' = $Content
			'RawContent' = $RawContent + ($BINARY_TRANSFER ? $response.ToArray() : $response)
			'Headers' = $Headers
			'Headings' = $Headings
			'Links' = $Links
			'RawContentLength' = $RawContent.Length + $response.Length
		}

		#region Experimental favicon support.
		# In the spirit of Gemini, this is disabled by default.
		# PowerShell doesn't seem capable of combining emojis and modifiers, but
		# we'll give it the ol' college try and show *something* to the user.
		If ($FavIcon)
		{
			$faviconUri = "gemini://$($Uri.Host):$($Uri.Port)/favicon.txt"
			$icon       = $null

			Try
			{
				$icon = (Invoke-GeminiRequest -Uri $faviconUri -Certificate:$Certificate -SkipCertificateCheck:$SkipCertificateCheck).Content
			}
			Catch
			{
				Write-Verbose "Could not get a favicon from $faviconUri."
			}

			$retval | Add-Member -NotePropertyName 'FavIcon' -NotePropertyValue $icon
		}
		#endregion (favicon)

		Return $retval
	}
	#endregion
}

Function Get-PSGeminiKnownCertificate
{
	[CmdletBinding()]
	[Alias('Get-PSGeminiKnownCertificates')]
	[OutputType([PSCustomObject[]])]
	Param(
		[AllowNull()]
		[String] $HostName,

		[ValidateRange(1,65535)]
		[UInt16] $Port = 1965
	)

	Write-Debug "Looking for a certificate for ${HostName}:$Port."
	$env:PSGeminiTOFUPath ??= (Join-Path -Path $HOME -ChildPath '.PSGemini_known_hosts.csv')

	If (Test-Path -Path $env:PSGeminiTOFUPath -PathType Leaf)
	{
		Write-Debug "Found a certificate store at ${env:PSGeminiTOFUPath}."
		$AllCerts = @()
		Import-CSV -Path $env:PSGeminiTOFUPath | ForEach-Object {
			If (
				($null -eq $HostName  -or  $HostName -In @('', $_.HostName)) -and
				($Port -eq ${_}?.Port  -or  $null -eq ${_}?.Port -and $Port -eq 1965)
			)
			{
				$NotAfter = [DateTime]::FromFileTimeUTC($_.ExpirationDate)
				$Port = ${_}?.Port ?? 1965
				Write-Debug "In our store, we have a matching certificate for $($_.HostName):$Port, good until $NotAfter, fingerprint $($_.Fingerprint)."
				$AllCerts += [PSCustomObject]@{
					HostName = $_.HostName
					Port = $Port
					Fingerprint = $_.Fingerprint
					ExpirationDate = $NotAfter
				}
			}
		}
		Return $AllCerts
	}
	Else
	{
		Write-Verbose "The certificate store ${env:PSGeminiTOFUPath} does not exist."
		Return @()
	}
}

Function Add-PSGeminiKnownCertificate
{
	[CmdletBinding()]
	[OutputType([Void])]
	Param(
		[Parameter(Mandatory, Position=0)]
		[ValidateNotNullOrEmpty()]
		[String] $HostName,

		[ValidateRange(1,65535)]
		[UInt16] $Port = 1965,

		[Parameter(Mandatory, Position=1)]
		[ValidateNotNullOrEmpty()]
		[String] $Fingerprint,

		[Parameter(Mandatory, Position=2)]
		[ValidateNotNullOrEmpty()]
		[Alias('NotAfter', 'ExpiryDate')]
		[DateTime] $ExpirationDate
	)

	Write-Verbose "Memorizing certificate for ${HostName}:$Port with fingerprint $Fingerprint and expiration date $ExpirationDate."

	$env:PSGeminiTOFUPath ??= (Join-Path -Path $HOME -ChildPath '.PSGemini_known_hosts.csv')

	# Version 0.24.1 of the Gemini Protocol Specification requires clients like PSGemini to keep
	# track of the port number.  We only started memorizing port numbers in version 1.1.0,
	# so let's make sure our file is upgraded to support port numbers.
	Convert-PSGeminiKnownHostsFileFormat -MinimumVersion 1.1.0 -ErrorAction Stop

	Export-CSV -Path $env:PSGeminiTOFUPath -Append -Delimiter ',' -InputObject ([PSCustomObject]@{
		HostName = $HostName
		Port = $Port
		Fingerprint = $Fingerprint
		ExpirationDate = $ExpirationDate.ToFileTimeUTC()
	})
	#Add-Content -Path $env:PSGeminiTOFUPath -Value "${HostName}:$Port,$Fingerprint,$($ExpirationDate.ToFileTimeUTC())"
}

Function Remove-PSGeminiKnownCertificate
{
	[CmdletBinding(
		SupportsShouldProcess, ConfirmImpact='Low',
		DefaultParameterSetName='HostName'
	)]
	[OutputType([Void])]
	Param(
		[Parameter(Mandatory, ParameterSetName='HostName')]
		[ValidateNotNullOrEmpty()]
		[String] $HostName,

		[Parameter(ParameterSetName='HostName')]
		[ValidateRange(1,65535)]
		[UInt16] $Port = 1965,

		[Parameter(Mandatory, ParameterSetName='Fingerprint')]
		[ValidateNotNullOrEmpty()]
		[String] $Fingerprint
	)

	$env:PSGeminiTOFUPath ??= (Join-Path -Path $HOME -ChildPath '.PSGemini_known_hosts.csv')

	If (-Not (Test-Path -Path $env:PSGeminiTOFUPath -PathType Leaf))
	{
		Return $null
	}

	$AllCerts = Import-CSV -Path $env:PSGeminiTOFUPath
	
	If ($PSCmdlet.ParameterSetName -eq 'HostName')
	{
		$FoundCert = $AllCerts | Where-Object {$_.HostName -eq $HostName -and ($_.Port -eq $Port -or ($Port -eq 1965 -and $null -eq ${_}?.Port))} | Select-Object -First 1
		If ($null -eq $FoundCert)
		{
			Write-Warning "No certificate for ${HostName}:$Port was found."
		}
	}
	ElseIf ($PSCmdlet.ParameterSetName -eq 'Fingerprint')
	{
		$FoundCert = $AllCerts | Where-Object Fingerprint -eq $Fingerprint | Select-Object -First 1
		If ($null -eq $FoundCert)
		{
			Write-Warning "No certificate $Fingerprint was found."
		}
	}

	If ($null -ne $FoundCert)
	{
		Write-Debug "Removing certificate for $($FoundCert.HostName):$(${FoundCert}?.Port ?? 1965):  expires=$([DateTime]::FromFileTimeUtc($FoundCert.ExpirationDate)), fingerprint=$($FoundCert.Fingerprint)"
		If ($PSCmdlet.ShouldProcess($FoundCert.Fingerprint, 'Remove from TOFU store'))
		{
			$AllCerts | Where-Object {$_ -ne $FoundCert} | Export-CSV -Path $env:PSGeminiTOFUPath -Force
		}
	}
}

Function Convert-PSGeminiKnownHostsFileFormat
{
	[CmdletBinding(SupportsShouldProcess)]
	[Alias('Update-PSGeminiKnownHostsFileFormat')]
	[OutputType([Void])]
	Param(
		[Parameter(ParameterSetName='SpecificVersion', Position=0)]
		[Version] $ModuleVersion = '1.1.0',

		[Parameter(ParameterSetName='MinimumVersion', Mandatory, Position=0)]
		[Version] $MinimumVersion,

		[Switch] $Force
	)

	$env:PSGeminiTOFUPath ??= (Join-Path -Path $HOME -ChildPath '.PSGemini_known_hosts.csv')
	If (-Not (Test-Path -Path $env:PSGeminiTOFUPath -PathType Leaf)) {
		Write-Verbose "The file $env:PSGeminiTOFUPath cannot be converted because it does not exist."
		Return
	}

	$FileContents = Import-CSV -Path $env:PSGeminiTOFUPath -ErrorAction Stop
	If ($null -eq $FileContents) {
		Write-Verbose "The file $env:PSGeminiTOFUPath cannot be converted because it's empty."
		Return
	}

	# The file format used in version 1.1.0 added port information, in order to comply with
	# the Gemini Protocol Specification version 0.24.1.
	If (($PSCmdlet.ParameterSetName -eq 'SpecificVersion' -and $ModuleVersion -ge '1.1.0') -or
	    ($PSCmdlet.ParameterSetName -eq 'MinimumVersion' -and $MinimumVersion -ge '1.1.0'))
	{
		If ($FileContents[0].PSObject.Properties.Name -Contains 'Port')
		{
			Write-Verbose 'This known hosts file is already in version 1.1.0 format.'
		}
		Else
		{
			Write-Verbose 'This known hosts file is in the legacy version 1.0.0 format.  Upgrading it in-place to add port information.'
			$NewFileContents = [PSCustomObject[]]@()
			$FileContents | ForEach-Object {
				Write-Debug "Adding port information for the capsule $($_.HostName) with fingerprint $($_.Fingerprint)."
				$NewFileContents += [PSCustomObject]@{
					'HostName' = $_.HostName
					'Port' = $_.Port ?? 1965
					'Fingerprint' = $_.Fingerprint
					'ExpirationDate' = $_.ExpirationDate
				}
			}

			If ($Force -or $PSCmdlet.ShouldProcess($env:PSGeminiTOFUPath, 'Convert this TOFU cache to the version 1.1.0 format'))
			{
				$NewFileContents | Export-CSV -Path $env:PSGeminiTOFUPath -NoTypeInformation -ErrorAction Continue
			}
		}
	}

	# I don't know why you would want to downgrade, but you can.
	ElseIf (($PSCmdlet.ParameterSetName -eq 'SpecificVersion' -and $ModuleVersion -ge '1.0.0') -or
	        ($PSCmdlet.ParameterSetName -eq 'MinimumVersion' -and $MinimumVersion -ge '1.0.0'))
	{
		If ($FileContents[0].PSObject.Properties.Name -NotContains 'Port')
		{
			Write-Verbose 'This known hosts file is already in version 1.0.0 format.'
		}
		Else
		{
			Write-Verbose 'This known hosts file is in a newer format.  Downgrading it in-place.'
			$NewFileContents = [PSCustomObject[]]@()
			$FileContents | ForEach-Object {
				Write-Debug "Removing port information for the capsule $($_.HostName) with fingerprint $($_.Fingerprint)."
				If ($null -ne ${_}.Port  -and  $_.Port -ne 1965  -and -not $Force) {
					Throw "This file contains port information for $($_.Hostname):$($_.Port) that would be lost in a downgrade.  Please re-run this cmdlet with the -Force parameter."
				}

				$NewFileContents += [PSCustomObject]@{
					'HostName' = $_.HostName
					'Fingerprint' = $_.Fingerprint
					'ExpirationDate' = $_.ExpirationDate
				}
			}

			If ($Force -or $PSCmdlet.ShouldProcess($env:PSGeminiTOFUPath, 'Convert this TOFU cache to the version 1.1.0 format'))
			{
				$NewFileContents | Export-CSV -Path $env:PSGeminiTOFUPath -NoTypeInformation -ErrorAction Continue
			}
		}
	}

	Else {
		Write-Error "You have specified an invalid file format version ($($ModuleVersion ?? $MinimumVersion))."
	}

	Return
}