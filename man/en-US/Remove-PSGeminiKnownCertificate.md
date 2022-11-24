---
external help file: PSGemini-help.xml
Module Name: PSGemini
online version: https://github.com/rhymeswithmogul/PSGemini/blob/main/man/en-US/Remove-PSGeminiKnownCertificate.md
schema: 2.0.0
---

# Remove-PSGeminiKnownCertificate

## SYNOPSIS
Removes a certificate from PSGemini's internal store.

## SYNTAX

### HostName (Default)
```
Remove-PSGeminiKnownCertificate -HostName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Fingerprint
```
Remove-PSGeminiKnownCertificate -Fingerprint <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will remove a certificate, indicated by either the host name or the fingerprint, from PSGemini's internal store.

This cmdlet is meant to be used internally by Invoke-GeminiRequest, but regular users may (or may not) find a use for it.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-PSGeminiKnownCertificate gemini.circumlunar.space
```

Removes gemini.circumlunar.space's certificate from the store.  The next time `Invoke-GeminiRequest` is run, it will implicitly trust any certificate it is presented.

### Example 2
```powershell
PS C:\> Remove-PSGeminiKnownCertificate -Fingerprint '04A89008021E8F7AD7C73498D9147CC1D1122858FDB02DE0D50F82491F8CAF7CD525A2B410A20871A6AC7DB75AF7A1CE04C2F6628378108F8D6AB38EB8748D79BD'
```

Removes that specific certificate from the store.  The next time that the user runs `Invoke-GeminiRequest`, it will implicitly trust any certificate that the server presents.

## PARAMETERS

### -Fingerprint
The fingerprint of a certificate present in the store.  The exact format of the fingerprint is left to the PowerShell runtime.  You must match whichever format that it stores.

```yaml
Type: String
Parameter Sets: Fingerprint
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostName
The hostname of a certificate.  This will match only the legacy Subject (CN=...) field, ignoring the SAN (subjectAltName) values, as the Gemini specification, as written, only checks the fingerprint and the expiration date.


```yaml
Type: String
Parameter Sets: HostName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
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
This cmdlet does not generate output.

## NOTES
The PSGemini certificate store is saved in ~/.PSGemini_known_hosts.csv.  You may override this by setting the `$env:PSGeminiTOFUPath` variable.

## RELATED LINKS

[Add-PSGeminiKnownCertificate]()
[Get-PSGeminiKnownCertificate]()
[Invoke-GeminiRequest]()
[about_ProjectGemini]()