# PSGemini ChangeLog

## Version 1.0.4
*  The `-Fingerprint` parameter to `Remove-PSGeminiKnownCertificate` did not work.  This has been corrected.
*  `Remove-PSGeminiKnownCertificate` now supports `ShouldProcess` (`-Confirm` and `-WhatIf`).
*  Code cleanup.

## Version 1.0.3
The `-HostName` parameter to `Remove-PSGeminiKnownCertificate` is now implied (i.e., the default parameter set).

## Version 1.0.2 and 1.0.1
If `$env:PSGeminiTOFUPath` was not defined, certificates could not be reliably added or removed.  This has been corrected by checking for null or undefined values.

## Version 1.0.0
First release.