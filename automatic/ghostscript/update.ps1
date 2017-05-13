﻿Import-Module AU

$releases = 'http://downloads.ghostscript.com/public/old-gs-releases/'

function global:au_SearchReplace {
  [version]$version = $Latest.RemoteVersion
  $docsUrl = "http://www.ghostscript.com/doc/$($version)/Readme.htm"
  $releaseNotesUrl = "https://ghostscript.com/doc/$($version)/History$($version.Major).htm"
  @{
    ".\Ghostscript.nuspec" = @{
      "(\<dependency .+?`"$($Latest.PackageName).app`" version=)`"([^`"]+)`"" = "`$1`"[$($Latest.Version)]`""
      "(?i)(^\s*\<docsUrl\>).*(\<\/docsUrl\>)" = "`${1}$docsUrl`${2}"
      "(?i)(^\s*\<releaseNotes\>).*(\<\/releaseNotes\>)" ` = "`${1}$releaseNotesUrl`${2}"
    }
  }
}
function global:au_GetLatest {
  $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

  $re = 'gs916w32\.exe$'
  $url32 = $download_page.Links | ? href -match $re | select -first 1 -expand href | % { $releases + $_ }

  $re = 'gs916w64\.exe$'
  $url64 = $download_page.links | ? href -match $re | select -first 1 -expand href | % { $releases + $_ }

  <#$verRe = 'Ghostscript\s*([\d]+\.[\d\.]+) for Windows'
  $Matches = $null
  $download_page.Content -match $verRe | Out-Null
  if ($Matches) {
    $version = $Matches[1]
  }#>

  @{
    URL32 = $url32
    URL64 = $url64
    #Version = $version
    Version  = '9.16'
    RemoteVersion = '9.16'
    PackageName = 'Ghostscript'
  }
}

if ($MyInvocation.InvocationName -ne '.') { # run the update only if script is not sourced
    update -ChecksumFor none
}
