---
external help file: PSGemini-help.xml
Module Name: PSGemini
online version: https://github.com/rhymeswithmogul/PSGemini/blob/main/man/en-US/Add-PSGeminiKnownCertificate.md
schema: 2.0.0
---

# Add-PSGeminiKnownCertificate

## SYNOPSIS
Adds an SSL certificate to the PSGemini certificate store.

## SYNTAX

```
Add-PSGeminiKnownCertificate [-HostName] <String> [-Fingerprint] <String> [-ExpirationDate] <DateTime>
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will manually add the given certificate to the PSGemini certificate store.

This cmdlet is meant to be used internally by the PSGemini module.  Still, there might be a reason why you want to run it (e.g., high security connections).

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-PSGeminiKnownCertificate -HostName gemini.circumlunar.space -Fingerprint 04A89008021E8F7AD7C73498D9147CC1D1122858FDB02DE0D50F82491F8CAF7CD525A2B410A20871A6AC7DB75AF7A1CE04C2F6628378108F8D6AB38EB8748D79BD -ExpirationDate (Get-Date 10/03/2025 09:50:37)
```

Manually adds a certificate to the store.

## PARAMETERS

### -ExpirationDate
The NotAfter date from the certificate.  Specify this as a `[DateTime]` object, or let PowerShell do the conversion for you.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: NotAfter, ExpiryDate

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fingerprint
The full fingerprint of the certificate.  The exact format of this parameter is left up to the PowerShell runtime to decide.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostName
The host name (i.e., Subject) field of the certificate, minus qualifiers such as "CN=".  The Gemini protocol does not check the SAN (subjectAltName) field.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
This cmdlet does not accept pipeline input.

## OUTPUTS

### System.Void
This cmdlet does not generate any output.

## NOTES
The PSGemini certificate store is saved in ~/.PSGemini_known_hosts.csv.  You may override this by setting the `$env:PSGeminiTOFUPath` variable.

This cmdlet is supposed to be run internally.  Calling this cmdlet manually is STRONGLY DISCOURAGED.

## RELATED LINKS

[Get-PSGeminiKnownCertificate]()
[Remove-PSGeminiKnownCertificate]()
[Invoke-GeminiRequest]()