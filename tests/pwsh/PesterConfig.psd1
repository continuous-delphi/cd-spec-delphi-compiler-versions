# PesterConfiguration for delphi-compiler-versionsolchain generation  PowerShell tests.
# Run from the repository root with:
#   Invoke-Pester -Configuration (New-PesterConfiguration -Hashtable (Import-PowerShellDataFile ./tests/pwsh/PesterConfig.psd1))
# Or via the runner script (location-independent):
#   ./tests/run-tests.ps1
#
# Requires: Pester 5.7+

@{
  Run = @{
    #Pester discovers all *.Tests.ps1 files automatically in this path
    Path = './tests/pwsh'
  }
  Output = @{
    Verbosity = 'Detailed'
  }
  TestResult = @{
    Enabled      = $true
    OutputPath   = './tests/pwsh/results/pester-results.xml'
    OutputFormat = 'NUnitXml'
  }
  CodeCoverage = @{
    Enabled    = $false
  }
}