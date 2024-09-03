---
external help file: PSGemini-help.xml
Module Name: PSGemini
online version:
schema: 2.0.0
---

# Convert-PSGeminiKnownHostsFileFormat

## SYNOPSIS
This cmdlet converts a PSGemini known hosts file between the new and old formats.

## SYNTAX

### SpecificVersion
```
Convert-PSGeminiKnownHostsFileFormat [[-ModuleVersion] <Version>] [-Force] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### MinimumVersion
```
Convert-PSGeminiKnownHostsFileFormat [-MinimumVersion] <Version> [-Force] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet converts the active PSGemini known hosts file (located at `$env:PSGeminiTOFUPath`) between the format used by PSGemini v1.1.0 and the format used by older versions.  This file is used to manage the trust-on-first-use certificate cache, and gets amended automatically as PSGemini's cmdlets are run.

There should be no need for anyone to use this cmdlet unless you need to use both the current version of PSGemini alongside an older one.

## EXAMPLES

### Example 1
```powershell
PS C:\> Convert-PSGeminiKnownHostsFileFormat
```

Upgrades the TOFU cache file to the latest version (which is v1.1.0).

### Example 2
```powershell
PS C:\> Convert-PSGeminiKnownHostsFileFormat -MinimumVersion v1.0.6
```

Converts the TOFU cache file to the newest file format needed to support PSGemini v1.0.6 (that is, file format v1.0.0).

## PARAMETERS

### -Force
If there is custom port information that would be lost in a version downgrade, the conversion fails to protect your data.  To bypass this warning, specify this parameter.

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

### -MinimumVersion
Specify a version of the PSGemini module, and the file format will be upgraded or downgraded to the newest format that that version of PSGemini requires.


```yaml
Type: Version
Parameter Sets: MinimumVersion
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleVersion
Specify a version of the PSGemini module, and the file format will be upgraded or downgraded to the oldest format that that version of PSGemini requires.


```yaml
Type: Version
Parameter Sets: SpecificVersion
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
This module does not accept pipeline input.

## OUTPUTS

### System.Void
This module does not generate output.  The file is converted without status messages.

## NOTES
There are two file formats, and the file format version matches the PSGemini module version.  File format v1.0.0 was the first version.  FIle format v1.1.0 added a Port parameter.

## RELATED LINKS
[Add-PSGeminiKnownCertificate]()
[Get-PSGeminiKnownCertificate]()
[Remove-PSGeminiKnownCertificate]()
