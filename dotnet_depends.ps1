Get-ChildItem -Path "D:\" -Recurse -Include *.ps1,*.cmd,*.bat,*.yml,*.xml -ErrorAction SilentlyContinue |
Select-String -Pattern "NuGet-5.11.0\\nuget\.exe"
