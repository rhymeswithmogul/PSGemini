---
external help file: PSGemini-help.xml
Module Name: PSGemini
online version: https://github.com/rhymeswithmogul/PSGemini/blob/main/man/en-US/Get-PSGeminiKnownCertificate.md
schema: 2.0.0
---

# Get-PSGeminiKnownCertificate

## SYNOPSIS
Fetches one or more certificates from the PSGemini internal store.

## SYNTAX

```
Get-PSGeminiKnownCertificate [[-HostName] <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will search PSGemini's certificate store (see Notes) and return any and all certificates matching the given host name.  If no host name is provided, all certificates will be returned.

Certificates are kept in the store until they are expired, at which point, they will be removed by subsequent calls to `Invoke-GeminiRequest`.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-PSGeminiKnownCertificate gemini.circumlunar.space | Format-List

HostName       : gemini.circumlunar.space                                                           
Fingerprint    : 04A89008021E8F7AD7C73498D9147CC1D1122858FDB02DE0D50F82491F8CAF7CD525A2B410A20871A6AC7DB75AF7A1CE04C2F6628378108F8D6AB38EB8748D79BD
ExpirationDate : 10/03/2025 09:50:37
```

Fetches the trusted certificate for the named domain.  (Piped to `Format-List` for readability.)

## PARAMETERS

### -HostName
{{ Fill HostName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### System.Management.Automation.PSObject[]
A `PSCustomObject` showing the saved certificate information: the host name (the subject), the fingerprint, and the expiration date.

## NOTES
The PSGemini certificate store is saved in ~/.PSGemini_known_hosts.csv.  You may override this by setting the `$env:PSGeminiTOFUPath` variable.

## RELATED LINKS

[Add-PSGeminiKnownCertificate]()
[Remove-PSGeminiKnownCertificate]()
[Invoke-GeminiRequest]()
[about_ProjectGemini]()