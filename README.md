# cd-spec-delphi-compiler-versions
![Status](https://img.shields.io/badge/status-incubator-orange)
![Schema](https://img.shields.io/badge/schema-1.0.0-blue)
![Data](https://img.shields.io/badge/data-0.1.0-blue)
![Platform](https://img.shields.io/badge/platform-windows-lightgrey)

Canonical Delphi compiler version mapping based on official `VER###` symbols.

This repository defines the authoritative data model used by Continuous Delphi tooling to
resolve, normalize, and compare Delphi compiler versions. The canonical identifier is the
`VER###` symbol (for example: `VER180`, `VER230`, `VER360`, `VER370`).

## Scope

- Includes Delphi versions starting at `VER90` (Delphi 2).
- Excludes C++Builder-only entries.
- Excludes .NET-only Delphi compiler versions.
- Includes registry metadata required for deterministic toolchain discovery.

This repository is **data-first**. The JSON file under `data/` is the single source of truth.
Generated code and downstream tooling must derive from that dataset. Hardcoding version tables
across multiple tools is not acceptable -- all tooling must depend on this canonical dataset.

## Repository Structure

```
schemas/
  1.0.0/
    delphi-compiler-versions.schema.json    # immutable versioned schema
  delphi-compiler-versions.schema.json      # latest convenience copy
data/
  delphi-compiler-versions.json             # current dataset
```

- The schema is versioned and immutable once published. The `$id` inside each schema file
  matches its versioned canonical path.
- The dataset is versioned independently via `dataVersion`.
- Schema and data evolve separately under the Continuous Delphi versioning policy.

Canonical schema `$id`:

```
https://continuous-delphi.github.io/cd-spec-delphi-compiler-versions/schemas/1.0.0/delphi-compiler-versions.schema.json
```

## Versioning Model

### Schema

Breaking changes require a new MAJOR schema version (for example: `2.0.0`). The versioned
schema file at `schemas/1.0.0/` is immutable. A new version produces a new versioned folder.

### Dataset

The dataset file contains two independent version fields:

- `schemaVersion` -- identifies the schema contract the dataset conforms to.
- `dataVersion` -- tracks the dataset contents under semantic versioning.

Dataset version bump rules:

- PATCH -- metadata corrections, alias additions, non-semantic clarifications.
- MINOR -- new Delphi releases added.
- MAJOR -- breaking structural or semantic changes to existing entries.

Initial dataset release: `0.1.0`.

## Data Model

Primary file:

```
data/delphi-compiler-versions.json
```

Each entry includes:

- `ver` -- canonical `VER###` symbol (primary identifier, listed first in `aliases` by convention)
- `compilerVersion` -- string preserving the exact `CompilerVersion` notation (e.g., `"37.0"`)
- `product_name` -- official product name
- `package_version` -- package version identifier
- `bds_reg_version` -- BDS registry version string (if applicable)
- `registry_key_relpath` -- relative registry key path for toolchain discovery
- `aliases` -- all identifiers that resolve to this entry
- `notes` -- clarifications or historical remarks

Install paths are intentionally excluded from the specification. Tooling must resolve
installation directories via the registry `RootDir` value.

Schema changes follow the versioning policy defined in `docs/versioning-policy.md`. Changes
to existing fields or keys are breaking changes and require a MAJOR schema version increment.

## Purpose

This specification exists to ensure that:

- `cd-ci-toolchain` can normalize installed Delphi versions.
- CI build actions can select toolchains deterministically.
- Modernization tooling can reason about compiler capabilities.
- Alias resolution (`Delphi 13`, `BDS 37.0`, `VER370`, etc.) is consistent across all tools.
- Registry-based discovery logic is centralized and reproducible.

## Maturity

This repository is currently `incubator`. It will graduate to `stable` once:

- The schema is considered frozen at `1.x`.
- CI validation is in place.
- At least one downstream tool consumes the dataset.
- No breaking schema changes are anticipated.

Until graduation, breaking changes may occur. No migration guarantees are provided.

## Part of Continuous Delphi

This repository follows the Continuous Delphi organization taxonomy. See
[cd-meta-org](https://github.com/continuous-delphi/cd-meta-org) for navigation and governance.

- `docs/org-taxonomy.md` -- naming and tagging conventions
- `docs/versioning-policy.md` -- release and versioning rules
- `docs/repo-lifecycle.md` -- lifecycle states and graduation criteria
