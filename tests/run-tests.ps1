# tests/run-tests.ps1
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
Import-Module Pester -MinimumVersion 5.7.0 -Force
Push-Location (Join-Path $PSScriptRoot '..')
try {
  Invoke-Pester -Configuration (New-PesterConfiguration -Hashtable (Import-PowerShellDataFile "$PSScriptRoot/pwsh/PesterConfig.psd1"))
} finally {
  Pop-Location
}