# PleXcode Bridge Architecture (as of 2026-07-10)

> Source of truth: conversation with Saidie Quinn Newara (creator).
> Corrections to earlier assumptions: SOUL.md / SKILL.md do not exist in this project —
> they were cross-contamination from another project and must be ignored.

## What PleXcode Actually Is

PleXcode is **not** a replacement for other languages. It is a **meta-language
and encrypted bridge runtime** that orchestrates between other languages.

- `.plx` files are orchestration logic, not standalone executables.
- PleXcode embeds handlers for Python, JavaScript, Swift, C, Java, HTML natively.
- The `Hail` operator is the universal handshake: one language announces itself
  to PleXcode (or PleXcode announces itself to another language), and the bridge
  dispatches to the right runtime.
- Communication is bidirectional: PleXcode → other languages, AND
  other languages → PleXcode via `\\\` shell-passthrough into a `Hail` block.

## Inline Foreign-Language Invocation

PleXcode can pull a specific line or whole file from another language:

```
Script | python
╰──➤ "filename" | .py
   ╰──➤ script [ line: 920 ] - [to]
Script | "filename" | .py
```

```
"python script content"
```

This embeds Python source directly in a `.plx` file, scoped to the `python`
handler. The runtime hands the embedded block to the Python interpreter,
returning the result back into the PleXcode flow.

## Direct Toolchain Passthrough

Any toolchain command works as-is via `\\\`:

```
\\\ pip install GoGo
```

The runtime identifies the target toolchain (pip → Python) and dispatches
without leaving PleXcode's orchestration context.

## Inbound Calls (Other Languages → PleXcode)

A Python or shell script can call into PleXcode using `\\\` passthrough:

```
\\\ pip install GoGo
Hail | GoGo
╰──| GoGo not found: I'll install "GoGo"
╰──| Installing GoGo
╰──| GoGo is written in .py , .js , .swift let me build this
╰──| \\\ Build | GoGo.k!t
   ╰──| .k!t | GoGo
   ╰──| .k!t | Build | .mf && .att
```

When another language calls in, PleXcode:
1. Receives the call as a `Hail` handshake (the language announces itself).
2. Responds with output via `╰──|` (the output operator).
3. Can decide to build, install, or orchestrate further — including deciding
   that the foreign tool should be wrapped into a `.k!t` (NCOM's official
   app file extension) and packaged as `.mf` + `.att`.

## File-Type Vocabulary (NCOM-native)

- `.plx` — PleXcode source (the orchestration layer)
- `.attributes` / `.att` — signed asset/argument address book
- `.TAG` — signed metadata for authenticated scripts
- `.mf` — encrypted manifesto container (AES-256-GCM)
- `.k!t` — NCOM's official app file extension
- `.bun` / `.Retard` — compressed raw logic bundles
- Foreign: `.py`, `.js`, `.swift`, `.c`, `.java`, `.html` — bridged, not replaced

## The `Sign~!!` Rule (corrected)

`Sign~!!` is **NOT** used in every `.plx` file. It is reserved for scripts that
need authentication / secret storage. When used:

- Auto-corrects to `Sign | [""]`
- Writes to `.TAG` (metadata) and `.attributes` (signed asset table)
- `.attributes` entry format: `name: Auth - |~|!!| Saidie.!!`
- `.TAG` body format:
  ```
  Auth |~| Saidie
  ╰──➤ \\\ UserName [ Saidie.Newara ] |!!|
  ╰──➤ \\\ Pass [ An@NK00! ] |!!|
  ```

## What This Means for the Runtime

The transpiler question is now: **how do we build a runtime that embeds
Python, JS, Swift, C, Java, HTML interpreters, accepts `\\\` passthrough
to any of their toolchains, and exposes all of this through the PleXcode
flow operators?**

The runtime is not a transpiler-to-native-binary. It is an **orchestration
host** that:

1. Parses `.plx` into a flow graph (Hail / Build / Load / Logic / Sign).
2. For each `Script | <lang>` block, hands the embedded source to the
   corresponding language handler (embedded Python/JS/etc. interpreter).
3. For each `\\\` line, routes to the matching toolchain passthrough.
4. For each `Hail` from an external caller, registers a handshake and
   dispatches the response via `╰──|`.
5. Persists signed state to `.TAG` / `.attributes` when `Sign~!!` is used.
6. Packages built apps as `.k!t` + `.mf` + `.att` on completion.
