Get-Content -Path lib/app/keys.dart -Raw | % { [Text.Encoding]::UTF8.GetString([Text.Encoding]::UTF8.GetBytes()) }
