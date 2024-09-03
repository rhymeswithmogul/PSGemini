---
external help file: PSGemini-help.xml
Module Name: PSGemini
online version: https://github.com/rhymeswithmogul/PSGemini/blob/main/man/en-US/Invoke-GeminiRequest.md
schema: 2.0.0
---

# Invoke-GeminiRequest

## SYNOPSIS
Gets content from a Gemini server on the Internet.

## SYNTAX

### ToScreen (Default)
```
Invoke-GeminiRequest [-Uri] <Uri> [-Certificate <X509Certificate>] [-FavIcon] [-InputObject <String>]
 [-SkipCertificateCheck] [<CommonParameters>]
```

### OutFile
```
Invoke-GeminiRequest [-Uri] <Uri> [-Certificate <X509Certificate>] [-FavIcon] [-InputObject <String>]
 [-OutFile <String>] [-SkipCertificateCheck] [<CommonParameters>]
```

## DESCRIPTION
The `Invoke-GeminiRequest` cmdlet sends a Gemini request to a Gemini server.  It parses the response and returns collections of links, images, and other significant elements.

## EXAMPLES

### Example 1
```
PS C:\> Invoke-GeminiRequest gemini://geminiprotocol.net/

StatusCode        : 20
StatusDescription : text/gemini
Content           : # Project Gemini
                    
                    ## Overview
                    
                    Gemini is a new internet protocol which:
                    
                    * Is heavier than gopher
                    * Is lighter than the web
                    * Will not replace either
                    * Strives for maximum power to weight ratio
                    * Takes user privacy very seriously
[…]
```

Connects to the Gemini server at gemini.circumlunar.space and returns the result.

### Example 2: Downloads
```powershell
PS /Users/colin> Invoke-GeminiRequest -UseSSL gemini://colincogle.name/pgp/pgp.txt -OutFile pgp.txt
PS /Users/colin> Get-Item pgp.txt                            

    Directory: /Users/colin

UnixMode   User             Group                 LastWriteTime           Size Name
--------   ----             -----                 -------------           ---- ----
-rw-r--r-- colin            wheel                2/8/2022 08:05           5218 pgp.txt
```

You can use the `-OutFile` switch to download files from Gemspace.

## PARAMETERS

### -Certificate
You can use this parameter to provide a client certificate.  Specify it as an `[X509Certificate]` or `[X509Certificate2]` object.

```yaml
Type: X509Certificate
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FavIcon
Specify this switch and this cmdlet will also grab the site's favicon.  For more information, see [the draft RFC](https://portal.mozz.us/gemini/mozz.us/files/rfc_gemini_favicon.gmi).

When used with `-OutFile`, this has no effect.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
To provide input to the remote server, specify it here.  Input will not be provided unless the server specifically requests it.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Input

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OutFile
To save the content of the response, specify this parameter.

```yaml
Type: String
Parameter Sets: OutFile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipCertificateCheck
Gemini trusts remote servers based on their certificate by a trust-on-first-use (TOFU) model, as opposed to the PKI infrastructure and hostname checks done in most SSL/TLS connections (i.e., HTTPS).  To satisfy this condition, PSGemini keeps an internal store of all certificates that it finds.

If, for some reason, you'd like to bypass this check, specify this parameter.  Note that this is **NOT SECURE** and **NOT RECOMMENDED** and should be used for debugging purposes only.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
The fully-qualified URI of the resource you'd like to access.  Be sure to include the protocol (`gemini://`).  If no port is specified, the default port of TCP 1965 is assumed.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: Url

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
This cmdlet accepts pipeline input for the `-InputObject` parameter.

## OUTPUTS

### System.Management.Automation.PSObject
This cmdlet generates an object similar to that generated by `Invoke-WebRequest` and `Invoke-GopherRequest`.

### System.Void
When using the `-OutFile` parameter or parameter set, no output will be generated.  The content will be saved to a file (if successful).

## NOTES
Client certificate checking has not been fully tested yet.

## RELATED LINKS

[Get-PSGeminiKnownCertificate]()
[Invoke-WebRequest]()
[Invoke-GopherRequest]()
[about_PSGemini]()
