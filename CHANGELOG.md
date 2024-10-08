# PSGemini ChangeLog

## Version 1.1.0
This version includes various little changes in order to comply with the evolving specification, which is now up to version 0.24.1:

*  Per the section [*Clarification on error reporting*](https://geminiprotocol.net/news/2024_08_28.gmi#clarification-on-error-reporting), longer explanations of the error codes are now included in the returned error objects.
*  Previous versions of this module would not parse a link line correctly if there was no spacing after the leading `=>`.  This was allowed the whole time, but [*Permit use of tabs in link lines and text lines*](https://geminiprotocol.net/news/2024_08_28.gmi#permit-use-of-tabs-in-link-lines-and-text-lines) made this a requirement.
*  The built-in TOFU validation is now supposed to match a hostname and port, not just a hostname.  This introduces a new file format for the TOFU cache.  It will be upgraded automatically, but can also be changed via `Convert-PSGeminiKnownHostsFileFormat`, should you want to upgrade or downgrade the file manually for some reason.

There are also small improvements to the packaging structure and documentation.

## Version 1.0.6
Included the Project Gemini Speculative Speculation as some extra reading material (`Get-Help about_ProjectGemini`).  The original has British English spellings, so why not?  Now we have a localization/localisation.

## Version 1.0.5
Code cleanup.

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
