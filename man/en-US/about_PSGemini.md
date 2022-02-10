# PSGemini
## about_PSGemini

# SHORT DESCRIPTION
Get resources by using [the Gemini protocol](https://gemini.circumlunar.space/).

# LONG DESCRIPTION
PSGemini is a PowerShell module designed to access, view, download, and interact with resources available over the Gemini protocol.  Designed to be "somewhere between Gopher and HTTP", Gemini is growing in popularity.  It's time it had a PowerShell module.

This module has a few cmdlets, but the important one is `Invoke-GeminiRequest`.  Modeled after `Invoke-WebRequest`, it can be used similarly.  The syntax and output are similar.

## Certificate Trust
While [the Gemini protocol specification](https://gemini.circumlunar.space/docs/specification.gmi) requires TLS 1.2 or newer, it also eschews the traditional SSL/TLS <abbr title="Certificate Authority">CA</abbr>-based certificate validation with a simple TOFU (trust on first use) model.  To keep track of this, PSGemini saves found certificates to a file.  That file is saved at $env:PSGeminiTOFUPath.  If that is not defined, it defaults to `${env:HOME}/.PSGemini_known_hosts.csv`.

While strongly discouraged, if you've managed to find my conceptual help, you might be the type who wants to mess with the trust store.  You can do so by using one of these cmdlets:
* `Get-PSGeminiKnownCertificates`
* `Add-PSGeminiKnownCertificate`
* `Remove-PSGeminiKnownCertificate`

Even more strongly discouraged:  you may open the file in a text editor, Excel, LibreOffice Calc, or your favorite CSV editor.

## Aliases (or, Why Not `igr`?)
You can use the aliases `Invoke-GemRequest` or `igemr`.  (Why not `igr`?  That's already used by my other module, [PSGopher](https://github.com/rhymeswithmogul/PSGemini).)

## Client Certificates
Client certificates are supported.  Use the `-Certificate` parameter to specify one.

## FavIcons
Why not have a little fun?  Someone made [a draft RFC](https://portal.mozz.us/gemini/mozz.us/files/rfc_gemini_favicon.gmi) to bring something like favicons to Gemini.  In the spirit of the protocol, we're not making any additional requests, so this is disabled by default.  To request a resource's favicon, use the `-FavIcon` parameter for `Invoke-GeminiRequest`.

## TLS 1.3 Support
This cmdlet supports TLS 1.3.  However, there may be issues using it with PowerShell 7 on some platforms.  The `Invoke-GeminiRequest` cmdlet will make a best effort to use TLS 1.3 before falling back to TLS 1.2.  Per the specification, no older protocols may or will be tried.

# EXAMPLES
### Example 1: Access Resources
```
PS C:\> Invoke-GeminiRequest gemini://gemini.circumlunar.space

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

### Example 2: Download Resources
```powershell
PS /Users/colin> Invoke-GeminiRequest -UseSSL gemini://colincogle.name/pgp/pgp.txt -OutFile pgp.txt
PS /Users/colin> Get-Item pgp.txt                            

    Directory: /Users/colin

UnixMode   User             Group                 LastWriteTime           Size Name
--------   ----             -----                 -------------           ---- ----
-rw-r--r-- colin            wheel                2/8/2022 08:05           5218 pgp.txt
```

You can use the `-OutFile` switch to download files from Gemspace.

# NOTE
[The Gemini protocol specification](https://gemini.circumlunar.space/docs/specification.gmi) eschews the traditional SSL/TLS CA-based certificate validation with a simple TOFU (trust on first use) model.  To keep track of this, PSGemini saves found certificates to a file.  That file is saved at $env:PSGeminiTOFUPath.  If that is not defined, it defaults to `${env:HOME}/.PSGemini_known_hosts.csv`.

# TROUBLESHOOTING NOTE
Client certificates have not been fully tested.  If you encounter any issues, come complain on GitHub.  The link follows.

# SEE ALSO
Issues?  Rants?  Raves?  [Find this module on GitHub](https://github.com/rhymeswithmogul/PSGemini).

If you'd like to know more about Gemini, check out its unofficial official site at [gemini.circumlunar.space](https://gemini.circumlunar.space/).  (Obviously, it's also [available over Gemini](gemini://gemini.circumlunar.space/).)

If you like Web/<abbr title="World Wide Web">WWW</abbr>/<abbr title="Hypertext Transfer Protocol">HTTP</abbr> alternatives, why not check out my other module:  [PSGopher](https://github.com/rhymeswithmogul/PSGopher) for interacting with Gopherspace?

# KEYWORDS
Gemini, Gemlog, Gemblog, Geminispace, Gemtext, SSL, TLS, PowerShell Core