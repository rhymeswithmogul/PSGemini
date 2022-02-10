---
external help file: PSGemini-help.xml
Module Name: PSGemini
online version:
schema: 2.0.0
---

# Invoke-GeminiRequest

## SYNOPSIS
{{ Fill in the Synopsis }}

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
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Certificate
{{ Fill Certificate Description }}

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
{{ Fill FavIcon Description }}

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
{{ Fill InputObject Description }}

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
{{ Fill OutFile Description }}

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
{{ Fill SkipCertificateCheck Description }}

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
{{ Fill Uri Description }}

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
## OUTPUTS

### System.Management.Automation.PSObject
### System.Void
## NOTES

## RELATED LINKS
