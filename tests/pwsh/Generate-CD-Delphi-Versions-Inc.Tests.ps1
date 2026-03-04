# tests/pwsh/Generate-CD-Delphi-Versions-Inc.Tests.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'CD_DELPHI_VERSIONS.inc generator' {

  BeforeAll {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

    $genPath  = Join-Path $repoRoot 'tools\generate-cd-delphi-versions-inc.ps1'
    $dataPath = Join-Path $repoRoot 'tests\pwsh\fixtures\delphi-compiler-versions.min.json'

    if (-not (Test-Path -LiteralPath $genPath))  { throw "Generator not found: $genPath" }
    if (-not (Test-Path -LiteralPath $dataPath)) { throw "Test data not found: $dataPath" }

    $script:TmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('cd-delphi-versions-tests-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TmpRoot | Out-Null
    $outPath = Join-Path $script:TmpRoot 'CD_DELPHI_VERSIONS.inc'

    & $genPath -DataPath $dataPath -OutPath $outPath -Force | Out-Null

    $script:OutPath = $outPath
    $script:OutText = Get-Content -LiteralPath $outPath -Raw -Encoding UTF8
  }

  It 'writes the output file' {
    Test-Path -LiteralPath $script:OutPath | Should -BeTrue
  }

  It 'emits metadata defines' {
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_SCHEMA_1_0_0\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_DATA_1_0_0\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_GENERATED_2026_03_01\}'
  }

  It 'defines VERSION_UNKNOWN and undefines it inside known VER blocks' {
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_VERSION_UNKNOWN\}'
    $script:OutText | Should -Match '\{\$IFDEF VER90\}\s*\r?\n\s*\{\$UNDEF CD_DELPHI_VERSION_UNKNOWN\}'
  }

  It 'emits expected Delphi 2 tokens' {
    $script:OutText | Should -Match '\{\$IFDEF VER90\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_VER90\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_2\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_2_OR_LATER\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_COMPILER_VERSION_9\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_PACKAGE_VERSION_20\}'
  }

  It 'emits modern marketing tokens' {
    $script:OutText | Should -Match '\{\$IFDEF VER350\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_11\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_ALEXANDRIA\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_11_OR_LATER\}'
    $script:OutText | Should -Match '\{\$DEFINE CD_DELPHI_ALEXANDRIA_OR_LATER\}'
  }

  It 'emits MSBuild as open-ended optimistic support' {
    # Assert the block exists
    $script:OutText | Should -Match '\{\$IFDEF CD_DELPHI_10_2_OR_LATER\}\s*\r?\n\s*\{\$DEFINE CD_DELPHI_SUPPORTS_MSBUILD\}'

    # Extract the specific MSBuild capability block and ensure it has no VERSION_UNKNOWN guard
    $m = [regex]::Match(
        $script:OutText,
        '\{\$IFDEF CD_DELPHI_10_2_OR_LATER\}[\s\S]*?\{\$DEFINE CD_DELPHI_SUPPORTS_MSBUILD\}[\s\S]*?\{\$ENDIF\}',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $m.Success | Should -BeTrue
    $m.Value | Should -Not -Match 'CD_DELPHI_VERSION_UNKNOWN'
  }

  It 'emits macOS32 platform support as a bounded range' {
    $script:OutText | Should -Match '\{\$IFDEF CD_DELPHI_10_2_OR_LATER\}[\s\S]*\{\$IFNDEF CD_DELPHI_11_OR_LATER\}[\s\S]*\{\$DEFINE CD_DELPHI_SUPPORTS_PLATFORM_MACOS32\}'
  }

  It 'writes CRLF line endings for the .inc file' {
    $rawBytes = [System.IO.File]::ReadAllBytes($script:OutPath)
    $text = [System.Text.Encoding]::UTF8.GetString($rawBytes)

    # Should contain CRLF
    $text | Should -Match "`r`n"

    # Should NOT contain lone LF
    $text -replace "`r`n", "" | Should -Not -Match "`n"

    # Should NOT contain lone CR
    $text -replace "`r`n", "" | Should -Not -Match "`r"
  }

  It 'does not write a UTF-8 BOM' {
    $rawBytes = [System.IO.File]::ReadAllBytes($script:OutPath)
    # UTF-8 BOM: EF BB BF
    if ($rawBytes.Length -ge 3) {
        ($rawBytes[0] -eq 0xEF -and $rawBytes[1] -eq 0xBB -and $rawBytes[2] -eq 0xBF) | Should -BeFalse
    } else {
        $true | Should -BeTrue
    }
  }

AfterAll {
  if ($script:TmpRoot -and (Test-Path -LiteralPath $script:TmpRoot)) {
    Remove-Item -LiteralPath $script:TmpRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}
}


