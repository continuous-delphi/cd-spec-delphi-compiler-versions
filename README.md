# cd-spec-delphi-compiler-versions

Canonical Delphi compiler version mapping based on official `VER###` symbols.

This repository defines the authoritative data model used by Continuous Delphi tooling to
resolve, normalize, and compare Delphi compiler versions. The canonical identifier is the `VER###`
symbol (for example: `VER180`, `VER230`, `VER360`, `VER370`).

## Scope

- Includes Delphi versions starting at `VER90` (Delphi 2).
- Excludes C++Builder-only entries.
- Excludes .NET-only Delphi compiler versions.

This repository is **data-first**. The JSON file under `data/` is the single source of truth.
Generated Delphi units and documentation must derive from that JSON. Hardcoding version tables
across multiple tools is not acceptable - all tooling must depend on this canonical dataset.

## Purpose

This specification exists to ensure that:

- `cd-ci-toolchain` can normalize installed Delphi versions.
- Build actions can select toolchains deterministically.
- Modernization tooling can reason about compiler capabilities.
- Alias resolution (`Delphi 13`, `BDS 37.0`, `VER370`, etc.) is consistent across all tools.

## Data Model

Primary file:

```
data/delphi-compiler-versions.json
```

Each entry includes:

- `ver` -- canonical `VER###` symbol (primary identifier)
- `compilerVersion` -- numeric `CompilerVersion` constant value
- `marketingName` -- official product marketing name
- `bdsVersion` -- BDS registry version number (if applicable)
- `packageVersion` -- package version identifier
- `aliases` -- alternate identifiers that resolve to this entry

Planned extensions (not yet part of the schema):

- Default installation path patterns
- Toolchain kind classification (dcc vs msbuild)

Schema changes follow the versioning policy defined in `docs/versioning-policy.md`. Changes
to existing fields or keys are breaking changes and require a MAJOR version increment.

## Generated Code

The `src/delphi/` folder contains generated units derived from the JSON data. The JSON file
remains the single source of truth. Generated artifacts must not be manually edited.

## Maturity

This repository is currently labeled with the incubator maturity topic.
The data model is under active definition. It will graduate to `stable` 
once the schema is complete, CI is in place, and it is consumed by at
least one tooling repository. Breaking schema changes may occur prior to graduation.
No migration guarantees are provided until the repository is marked stable.

## Part of Continuous Delphi

This repository follows the Continuous Delphi organization taxonomy. See
[cd-meta-org](https://github.com/continuous-delphi/cd-meta-org) for navigation and governance.

- `docs/org-taxonomy.md` -- naming and tagging conventions
- `docs/versioning-policy.md` -- release and versioning rules
- `docs/repo-lifecycle.md` -- lifecycle states and graduation criteria
