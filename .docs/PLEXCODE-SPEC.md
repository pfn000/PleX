# PleXcode Language Specification v0.1

> Authoritative language spec. This document is the source of truth for
> `.plx` syntax. Where this document conflicts with README.md or
> example files, this document wins.

## 1. Overview

PleXcode is a meta-language and bridge runtime. A `.plx` file is
orchestration logic — it describes intent (what should happen), how
foreign languages are called into the flow, and how state is held
across those calls. The transpiler compiles `.plx` to encrypted
PleXcode bytecode, which is then packaged into a three-file assembly
(`.mf` + `.att` + `.TAG`) for distribution.

The language is built on three pillars:

- **Intent** — declarative commands that say what should happen.
- **Possession** — explicit lane claims via `Argu~!!`, not implicit
  variable declarations.
- **Force** — `~!!` bolts that turn intent into execution.

The hardware model underneath has four lane groups:

| Group     | Lane count | Purpose                              |
|-----------|------------|--------------------------------------|
| CPU       | 256        | Active computation                   |
| Memory    | 1024       | Stored values, asset references      |
| I/O       | 64         | Files, devices, sensors              |
| Network   | 32         | Sockets, peer nodes, foreign runtimes|

A `.plx` script operates on these lanes directly. There is no
"variable scope" — a lane is either possessed (`Argu~!!`) or it is
not. Lanes are released when the script signs off (`Sign~!!`) or when
the assembly's runtime ends.

## 2. The Kinetic Glyphs

These are the syntactic primitives. Every `.plx` file is built from
combinations of these.

### 2.1 Force and control

| Glyph      | Meaning                                              |
|------------|------------------------------------------------------|
| `~!!`      | Force execute. Override / sudo equivalent. A standalone `~!!` before any identifier turns it into a top-level imperative ("HEY GO DO THIS"). Used for top-level directives like `~!! Scope`, `~!! Key~!!`, `~!! Sync`, `~!! Authority~!!`, `~!! Hail`. |
| `~`        | Soft execute. Suggests, does not force.              |
| `\\\`      | Direct toolchain passthrough to system shell. For developer-tool commands like `pip install`. |
| `\\\\`     | Shell or SSH passthrough. Stronger than `\\\`; routes to system shell or remote SSH. Used for deferred shell commands, SSH triggers, and remote sync. |
| `\\`       | **Reserved/INVALID** in v0.1. Was a typo for `\\\\`. |
| `/!!`      | Comment marker. Line is documentation, not code.     |
| `\\\\~$`   | Shell passthrough with end-marker. The `$` terminates the shell-continued line. |

### 2.2 Flow and structure

| Glyph      | Meaning                                              |
|------------|------------------------------------------------------|
| `╰──➤`     | Flow operator. Means WHEN/IF/THEN/FI/OR/ELSE/BUT/FOR/GET. Always paired with a header. Never appears alone. |
| `╰──\|`     | Output operator. Emits a value or result.            |
| `\|~\|`    | Link operator. Connects logic to an attribute or data reference. |
| `\|!!\|`   | Hard guard. Prevents invalid calls, aborts the lane on conflict. |
| `@`        | Reference operator. Names a file or attribute (e.g. `@attributes`, `@.TAG`, `@model.name`). |
| `[ ]`      | Bracketed value. String, number, or named slot.      |
| `( )`      | Tuple. Multiple values bound together.               |
| `\|`       | Pipe. Separates command from its argument list.      |
| `:`        | Key-value separator inside a block.                  |
| `→`        | Direction arrow. "X goes to Y".                     |

### 2.3 Quoting and grouping

| Glyph      | Meaning                                              |
|------------|------------------------------------------------------|
| `"..."`    | String literal. May span multiple lines.             |
| `[""]`     | Empty value placeholder.                             |
| `{ }`      | Block delimiter for nested logic.                    |

## 3. Core Commands

These are the verbs the language understands. Each command takes a
pipe-separated argument list and a `╰──➤`-indented body.

### 3.1 Lifecycle

- **`Hail | <Name>`** — Handshake. The first command in any `.plx` file
  that opens a flow. Announces the script to the runtime. Tells the
  runtime which resources to prepare.
- **`Sign~!!`** — Optional. ONLY present in scripts that authenticate
  or store secrets. Auto-corrects to `Sign | [""]`. When used, writes
  signed state to `.TAG` and `.att` (see Section 8).

### 3.2 Loading and building

- **`Build | <target>`** — Prepare a target for use. Imports,
  fetches, or checks for updates before execution.
- **`Build~!! | <target>`** — Absolute build. Force the build
  immediately, no update check.
- **`Load | <source>`** — Pull a resource into the runtime. Source
  can be a `.plx` file, a `.attributes` reference, a `.TAG` reference,
  or an `@`-prefixed file path.
- **`Call | <target>`** — State check. Verify a file, resource, or
  system state.
- **`Script | <language>`** — Open a foreign-language block. The body
  is source code in `<language>`, passed to the system interpreter
  at runtime. See Section 6.

### 3.3 Possession and state

- **`Argu~!! | <lane> | <value>`** — Possess a lane. Bind a value to
  a specific CPU/memory/I/O/network lane. Once possessed, the lane
  is held until released.
- **`Math | <lane>`** — Declare a math logic block. Body is
  arithmetic on possessed lanes.
- **`Logic | <lane>`** — Declare a logic block. Body is conditions
  and branches on possessed lanes.
- **`Store | <lane> | <value>`** — Persist a lane's value to the
  assembly's `.att` file.

### 3.4 Inspection and output

- **`Sniff | <target>`** — Search or scan. Detect physical devices,
  query sensors, find files.
- **`Show | <target>`** — Display. Output a value to the user/console.
- **`Mark | <target>`** — Bundle pulse. Communicates with hardware
  layers; auto-corrects to `|~|~!!`.
- **`Pulse | <target>`** — Direct CPU signal. The ONLY command that
  allows the `n~` form (e.g. `n~ |~| @0xFAF1_NF-0`). Sends a raw
  packet via a channel line.

### 3.5 UI and panels

- **`UI | <target>`** — Declare a graphical interface block. Body
  contains `Panel~!!` and `UI` sub-commands.
- **`Panel | <name>`** — A UI component inside a `UI` block.
- **`Panel~!! | <name>`** — A UI component that must be force-built.

### 3.6 Bundling and metadata

- **`Bundle | <target>`** — Group multiple commands into a structured
  execution bundle.
- **`TAG | <name>`** — Create a `.TAG` file for metadata or signature
  storage.
- **`Link | <target>`** — Link command; auto-corrects to `|~|` (or
  `|~|~!!` as a safeguard variant).
- **`Check | <target>`** — Validation. Confirm system state,
  arguments, or logic correctness.

### 3.7 Execution control

- **`Script | [start-end] RUN`** — Run a specified range of lines
  from code. Example: `Script | [1-16] RUN`.

## 4. Autocorrect Table

The transpiler applies these normalizations before compilation.
These are not optional — the surface syntax accepts both forms, but
the canonical compiled form is the auto-corrected version.

| Surface form    | Canonical form        | Notes                                |
|-----------------|----------------------|--------------------------------------|
| `Hail~!!`       | `Hail \|`            | Handshake opens a flow, doesn't force its body. |
| `Build~!!`      | `Build \|`           | Build is preparation, not execution. |
| `Show~!!`       | `Show \|`            | Show is a request to display.        |
| `Send~!!`       | `Send \|`            | Send is a request, not a force.      |
| `Bundle~!!`     | `Bundle \|`          | Bundle is grouping, not force.       |
| `Link~!!`       | `\|~\|` (or `\|~\|~!!` as safeguard) | Link is a connector, optionally force-guarded. |
| `Pulse~!!`      | **NO autocorrect**   | Pulse is a direct CPU packet. May use `n~` form. |

## 5. The Script Block (Foreign-Language Bridge)

`Script` is how `.plx` files reach into other languages. The block
opens with `Script | <language>`, optionally declares a filename
reference, and contains the embedded source.

### 5.1 Inline source

```plex
Script | python
"print('hello from python')"
```

The runtime pushes the embedded string to the system Python
interpreter via `popen`, reads the JSON-serialized result, and
pushes it onto the PleXcode stack.

### 5.2 External file reference

```plex
Script | python
╰──➤ "filename" | .py
   ╰──➤ script [ line: 920 ] - [to]
Script | "filename" | .py
```

The runtime reads the referenced file (or line range) and treats
the contents as the embedded source for the foreign block.

### 5.3 Multi-language mix

A `.plx` file may contain multiple `Script` blocks in different
languages. Each block runs in its own interpreter process.

### 5.4 JSON contract

The foreign interpreter receives the embedded source plus a thin
shim that wraps the entrypoint:

```python
# shim injected by the player
import sys, json
user_source = sys.stdin.read()
# ... user source executes, last expression's value is captured ...
result = {"value": last_value}
sys.stdout.write(json.dumps(result))
```

The player expects JSON on stdout. Errors are reported as
`{"error": "message"}`.

### 5.5 Required tools

`Script | python` requires `python3` on PATH. `Script | javascript`
requires `node`. `Script | c` requires `gcc`. `Script | java`
requires `java`. `Script | swift` requires `swift`. `Script | html`
requires a system WebView (macOS `WKWebView`, Linux `webkit2gtk`,
Windows WebView2). The player probes for these at startup and
reports which runtimes are available.

## 6. The `\`-Operator (Toolchain Passthrough)

Any line beginning with `\\\` is passed verbatim to the system shell
after the appropriate toolchain router. Examples:

```plex
\\\ pip install requests
\\\ npm install lodash
\\\ gcc -o hello hello.c
```

The player uses the leading command (`pip`, `npm`, `gcc`, etc.) to
select the right toolchain context, then passes the rest to that
toolchain's shell.

## 7. The Hail Handshake (Inbound)

Other languages call INTO PleXcode via `\\\` passthrough into a
`.plx`-exposed `Hail` block. The pattern is:

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

When the inbound toolchain command lands, the player registers a
`Hail` handshake identifying the calling language. The body of the
`Hail` block runs in the player's normal interpreter context,
dispatching via `╰──|` to send output back to the caller.

## 8. The Sign~!! Rule (CORRECTED)

`Sign~!!` is **NOT** present in every `.plx` file. It is reserved
for scripts that:

- Need authentication
- Store secrets
- Produce a signed assembly
- Call `~!! Hail | USER@SSH` or any remote/trust-bearing block

**Correction from earlier draft:** `Sign~!!` does NOT auto-correct
to `Sign | [""]`. The runtime stores authentication data into the
`.TAG` and `.att` containers, but the source-level form remains
`Sign~!!` — the bare `[""]` was a v0.0 draft that has been removed.

When used:

- Writes to `.TAG` (metadata) and `.att` (signed asset table)
- `.att` entry format: `<name>: Auth - |~|!!| <signer_id>.!!`
- `.TAG` body format (the canonical template):

  ```
  Auth |~| <signer_id>
  ╰──➤ \\\ UserName [ <username> ] |!!|
  ╰──➤ \\\ Pass [ <password_hash> ] |!!|
  ```

- A `.plx` file without `Sign~!!` produces an unsigned assembly.
  The `.att` and `.TAG` are still generated for asset/metadata
  storage, but they do not carry a developer signature.

## 9. Lane Possession Patterns

### 9.1 Basic possession

```plex
Hail | MyScript
╰──➤ Argu~!! | @cpu[1] | "hello"
╰──➤ Show | @cpu[1]
```

`Argu~!! | @cpu[1] | "hello"` claims CPU lane 1 and binds the string
`"hello"` to it. The lane is held until the script ends.

### 9.2 Math on possessed lanes

```plex
Hail | Math | Logic
╰──➤ Argu~!!
   ╰──➤ X | 2
   ╰──➤ Y | 4
╰──➤ Math
   ╰──➤ X + Y | 8
   ╰──➤ 8 | X + Y
   ╰──➤ 8 | combined value
```

Lanes `X` and `Y` are possessed, then the `Math` block computes
their sum and binds the result to a derived lane.

### 9.3 Foreign-language data handoff

```plex
Hail | Pipeline
╰──➤ Script | python
   "import random; random.randint(1, 100)"
╰──➤ Argu~!! | @mem[1] | @result
╰──➤ Show | @mem[1]
```

The Python block runs, returns a JSON object. The player binds the
returned value to memory lane 1, then `Show` emits it.

## 10. The Flow Operator (`╰──➤`)

The flow operator connects a header to its sub-arguments. It is the
ONLY way to nest commands. The flow operator:

- Means WHEN/IF/THEN/FI/OR/ELSE/BUT/FOR/GET depending on context
- Is ALWAYS paired with a header command
- NEVER appears alone (no orphan `╰──➤` lines)
- May be nested arbitrarily deep

Example:

```plex
Hail | UI
╰──➤ Nav Bar
   ╰──➤ pill-shaped ( corners rounded = 24 )
   ╰──➤ background | @assets.theme.dark
```

## 11. File Layout

A `.plx` file is a sequence of:

1. An optional `Hail` handshake (required if the file is invoked as
   an entry point).
2. Zero or more command blocks, each consisting of a header line
   and a `╰──➤`-indented body.
3. An optional `Sign~!!` (only if authentication is required).

A `.plx` file does not need to start with `Hail` if it is a library
or partial — only entry-point files do.

## 12. New Construct Surface (from v0.1.1 code review)

The following constructs appear in canonical `.plx` samples but
were under-specified in the v0.1 draft. They are now normative.

### 12.1 `Call | local(USER)[states]`

State-check operator. Pulls the current user's stored attribute
state (from `.att`) and reports it on the flow. Used to verify
that a user, role, or trust level is bound before a privileged
operation runs. The `local(...)` qualifier scopes the call to
the runtime's local trust domain; `remote(...)` is reserved for
future use.

```plex
Call | local(USER)[states]
╰──| store | user.data @attributes
```

### 12.2 `Fetch | <id> | .retard | .bundle`

Fetch a pure-mathematics file by ID. `.retard` and `.bundle` are
NCOM's equation stores — they contain nothing but mathematical
expressions and constant values. The runtime treats the computer
as "stupid" when reading these files, meaning no inference, no
shortcuts, no type coercion. The literal byte sequence is loaded
and bound to the named ID. This is the safety layer: math is
executed in a sandbox where the runtime cannot reinterpret it.

```plex
Fetch | 0xFAF1_NF-0 | .retard | .bundle
```

The runtime:
1. Resolves the ID against the local `.retard`/`.bundle` index.
2. Loads the equation store at that ID.
3. Binds the result to the requesting lane with no transformation.

If the ID is missing, the call aborts. There is no fallback.

### 12.3 `Type | <name> | >%< | <float>`

Declare a typed value that occupies a fractional percentage slot
in a parent. The `>%<` glyph is the "fractional containment"
operator. The float is the slot's share of the parent container
(0.0 – 1.0, or 0 – 100 if a `%` suffix is present).

```plex
Type | Action|>%<| 0.5
```

Means: `Action` is a type that takes 50% of its parent container's
slot space. Used in UI blocks where elements need proportional
sizing without absolute pixel math.

### 12.4 `bounds | min | [Value]% | && max | [Value]% | |!!| <float>`

Declare a clamped range for a previously declared `Type`. The
`|!!|` operator is a hard guard — values outside the bounds are
rejected at runtime, not clamped. The trailing `<float>` is the
default value used if no input is supplied.

```plex
bounds | min | 0% | && max | 100% | |!!| 0.5
```

Means: the value is constrained to [0%, 100%], the default is 0.5,
and any attempt to assign outside the range aborts the lane.

### 12.5 `Time | 0!!`

Initialize the execution clock to zero. The trailing `!!` is the
"absolute start" form — the clock begins at the device's epoch
pulse, not at file-load time. Used when a script needs its timing
synchronized with the device's pulse-clock network (see
`MF-FORMAT.md` Section 4 on pulse keys).

### 12.6 The `n~` prefix (Pulse only)

`Pulse` is the ONLY command that allows the `n~` form on its
arguments. The `n~` prefix means "send this as a raw channel
packet", bypassing all autocorrect and type-checking.

```plex
Pulse | n~ |~| @0xFAF1_NF-0
```

The `|~|` after `n~` is the channel-link operator. `@0xFAF1_NF-0`
is the destination address. This is the lowest-level construct
in the language; misuse can corrupt the runtime state.

### 12.7 Group markers (`Group N yes` / `yes`)

A `Group` block is a user-declared control-flow region. The
lines `Group 1 yes`, `Group 2 yes`, ... `Group N yes`, followed
by a bare `yes` closer, define an explicit grouping that the
runtime treats as a single unit for branching, parallel
dispatch, or transaction boundaries.

```plex
Group 1 yes
Group 2 yes
Group 3 yes
yes
```

The trailing bare `yes` closes the group. The numeric labels
are stable identifiers, not ordering hints — the runtime may
execute groups in any order unless an explicit `Logic` block
orders them.

### 12.8 The `Load | "name" \\\~$` end-marker form

A `Load` line may end with the `\\~\$` end-marker when the load
is sourcing from a shell/SSH session and the result needs to be
streamed back into the `.plx` flow. The `$` terminates the
shell-continued line. This is distinct from `\\~$` (the plain
shell passthrough end-marker) in that `Load` here is performing
a SHELL-aware fetch, not a bare passthrough.

```plex
Load | "Saidie" \\\~$
```

The runtime opens an SSH session to the named host, fetches the
resource, and continues the flow on the next line. Used when
`Sign~!!` is present and the load requires authenticated access.

### 12.9 Output operator clarification (`╰──|`)

The `╰──|` glyph is the OUTPUT operator. It is distinct from
`╰──➤` (flow). `╰──|` EMITS a value or result to the runtime's
output lane. `╰──➤` ROUTES a value to the next command in the
flow. Confusing them is a common authoring error; the transpiler
warns (does not error) on `╰──|` appearing where `╰──➤` was
likely intended.

The `||` (bare double-pipe) form is a SYSTEM STATEMENT — it
signals that what follows is a response from the underlying
shell or system call, not user-authored content. The runtime
routes it to the shell-response lane, not the user-output lane.

## 13. Reserved Forms

These are reserved for future use and MUST NOT be used by user
code in v0.1:

- Direct binary literals
- Pointer arithmetic
- Untyped memory access
- Self-modifying constructs

## 14. Versioning

This is `PLEXCODE-SPEC.md` version `0.1.1`. The transpiler
emits a `plex_version` field in every `.mf` container matching
the spec version it was built against. Players reject `.mf`
files whose `plex_version` is newer than the player supports,
and warn (but accept) older versions.
