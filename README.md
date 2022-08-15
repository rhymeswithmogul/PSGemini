[![PowerShell Gallery Version (including pre-releases)](https://img.shields.io/powershellgallery/v/PSGemini?include_prereleases)](https://powershellgallery.com/packages/PSGemini/) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSGemini)](https://powershellgallery.com/packages/v/PSGemini)

# PSGemini
A [Gemini](https://gemini.circumlunar.space/) client written for PowerShell 7 and newer.

## Installation
Grab it from PowerShell Gallery with: `Install-Module PSGemini`

## Usage
In this example, we'll connect to a Gemini server and return the content.

```
PS C:\> Invoke-GeminiRequest gemini://gemini.circumlunar.space
WARNING: First visit. Memorizing new certificate for gemini.circumlunar.space

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

The syntax and output of this cmdlet is modeled after [`Invoke-WebRequest`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest) and [`Invoke-GopherRequest`](https://github.com/rhymeswithmogul/PSGopher), going as far as to emulate some of its properties:

```
PS /home/colin> igemr gemini://gemini.circumlunar.space

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
                    
RawContent        : 20 text/gemini
                    # Project Gemini
                    
                    ## Overview
                    
                    Gemini is a new internet protocol which:
                    
                    * Is heavier than gopher
                    * Is lighter than the web
                    * Will not replace either
                    * Strives for maximum power to weight ratio
                    * Takes user privacy very seriously
[…]

Headers           : {}
Headings          : {@{Level=1; Content=Project Gemini}, @{Level=2; Content=Overview}, @{Level=2; Content=Resources}, @{Level=2; Content=Web proxies}…}
Links             : {@{href=gemini://gemini.circumlunar.space/news/; title=Official Project Gemini news}, @{href=gemini://gemini.circumlunar.space/docs/; title=Gemini documentation}, @{href=gemini://gemini.circumlunar.space/software/; title=Gemini software}, @{href=gemini://gemini.circumlunar.space/servers/; title=Known Gemini servers}…}
RawContentLength  : 1281
```

### Downloading Files
You can also use PSGemini's `-OutFile` parameter to download files:

```powershell
PS /Users/colin> Invoke-GeminiRequest -UseSSL gemini://colincogle.name/pgp/pgp.txt -OutFile pgp.txt
PS /Users/colin> Get-Item pgp.txt                            

    Directory: /Users/colin

UnixMode   User             Group                 LastWriteTime           Size Name
--------   ----             -----                 -------------           ---- ----
-rw-r--r-- colin            wheel                2/8/2022 08:05           5218 pgp.txt
```

### Other Neat Features
* Full support for all platforms that support PowerShell 7.1 or newer -- that's Windows, macOS, and Linux!
* Since Gemini certificates can be self-signed, PSGemini maintains its own <abbr title="Trust on First Use">TOFU</abbr> certificate store.
* Client certificates can be provided (`-Certificate [<X509Certificate>]`).
* Full support for [experimental favicons](https://portal.mozz.us/gemini/mozz.us/files/rfc_gemini_favicon.gmi) (`-FavIcon`), disabled by default in the spirit of Gemini.
