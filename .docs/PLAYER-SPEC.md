# Manifesto Player Specification v0.1

> The manifesto player is the only "naked" binary on a user's
> machine. It is the trust root. It is small, signed by NCOM, and
> is the only thing that can load and execute a `.mf` assembly.
> This document specifies its behavior. The language is in
> `PLEXCODE-SPEC.md`; the container is in `MF-FORMAT.md`.

## 1. Player Architecture

A single player source, three platform-specific skins:

| Platform | Skin language | Skin purpose                                  |
|----------|---------------|-----------------------------------------------|
| macOS    | Swift         | Cocoa app, native process, Mach-O metadata.   |
| Linux    | Rust          | ELF binary, systemd-friendly, no runtime dep. |
| Windows  | C/C++         | Win32 binary, PE metadata, no CLR dependency. |

The core is identical across all three. The skin handles:

- Process name and binary metadata mimicry
- OS-specific integration (window management, file dialogs, etc.)
- Native API calls (Cocoa on macOS, X11/Wayland on Linux, Win32 on Windows)

## 2. Player Startup Sequence

When the player is invoked (e.g. `mf-play hello.mf`, or
double-click on `hello.mf`):

1. **Locate the assembly.** The user provides a `.mf` path. The
   player derives the companion paths:
   - `<basename>.att`
   - `<basename>.TAG` (case-sensitive on Linux/macOS, case-insensitive
     on Windows)

2. **Read all three files.** If any is missing, abort with
   `error.assembly.peer_missing`.

3. **Verify file headers.** Each file must begin with its magic
   bytes (`MFC1`, `ATT1`, `TAG1`). Mismatch aborts with
   `error.format.magic`.

4. **Verify version compatibility.** Each file's version field
   must be `<= player_version`. Newer versions abort with
   `error.format.too_new`.

5. **Verify cross-hashes.** For each file, recompute SHA-256 of
   the other two and compare to the cross-hash table. Mismatch
   aborts with `error.assembly.cross_hash_mismatch`.

6. **Verify Ed25519 signatures.** Each file's signature must
   validate against the embedded developer public key. The
   developer's public key must be the same across all three
   files. Mismatch aborts with `error.signature.invalid`.

7. **Verify pulse streams.** The pulse stream section of each
   file must be byte-identical. Mismatch aborts with
   `error.pulse.desync`.

8. **Verify clock-sync window.** All three files' windows must
   agree. The system clock must be within the agreed window and
   must be reasonable (2020-2100). Outside the window, abort with
   `error.clock.expired`. Unreasonable clock, abort with
   `error.clock.unreasonable`.

9. **Decrypt the bytecode.** Using the developer public key, the
   player unwraps the AES-256-GCM key. The player decrypts the
   `.mf` ciphertext into a private in-memory buffer. The
   plaintext bytes are NEVER written to disk.

10. **Load `.att` and `.TAG` into memory.** The asset table and
    metadata are now accessible via the `ATT` and `TAG` bytecode
    opcodes.

11. **Probe foreign runtimes.** The player checks which language
    runtimes are available on the system (Python, Node, gcc, Java,
    Swift, WebView). The probe is a PATH check and a version
    invocation. Result is reported to the user (e.g. "Python 3.11
    available, Node 20 available, gcc not found").

12. **Begin execution.** The bytecode interpreter starts at offset 0
    and runs until `HALT` or an unrecoverable error.

## 3. The Bytecode Interpreter

The player includes a stack-based interpreter that executes the
bytecode from `MF-FORMAT.md` Section 2.2.

### 3.1 Stack and slots

The interpreter maintains:
- An evaluation stack (max depth 256 by default; the bytecode's
  `stack size` field overrides).
- Four slot groups: `@cpu[0..255]`, `@mem[0..1023]`, `@io[0..63]`,
  `@net[0..31]`.

Slot values are tagged: `INT`, `FLOAT`, `STR`, `EMPTY`, or
`OBJECT` (a reference to a runtime-managed structure like a
foreign-language result).

### 3.2 Foreign-language block execution

When the interpreter hits a `SCRIPT` opcode:

1. Read the language index from the operand (lookup in string
   table: "python", "javascript", "c", "java", "swift", "html").
2. Verify the corresponding runtime is available. If not, abort
   with `error.runtime.missing`.
3. Pop the source string from the stack.
4. If there's a filename reference on the stack below the source,
   resolve it from the working directory.
5. Spawn the system interpreter via `popen` (or platform equivalent):
   - `python3` for Python
   - `node` for JavaScript
   - `gcc -o <tmp> -x c -` for C (compile, run)
   - `java -jar <tmp.jar>` for Java
   - `swift` for Swift
   - Platform WebView for HTML
6. Write the source + thin JSON shim to the interpreter's stdin.
7. Read stdout. Parse as JSON. Push the result onto the stack as
   an `OBJECT`.
8. If the interpreter exits non-zero or stdout is not valid JSON,
   push an error OBJECT.

### 3.3 Toolchain passthrough

When the interpreter hits a `SHELL` opcode:

1. Pop the command string from the stack.
2. Identify the leading command (`pip`, `npm`, `gcc`, `swiftc`, etc.)
   and select the appropriate toolchain context.
3. Spawn the toolchain with the command via `popen`.
4. Capture stdout/stderr. Push the result as an `OBJECT`.

### 3.4 The `Hail` handshake (inbound)

When a foreign runtime calls back into PleXcode (e.g. via
`\\\ pip install GoGo` followed by `Hail | GoGo`), the player:

1. Receives the inbound command via the foreign runtime's stdout
   pipe.
2. Identifies the calling language from the pipe context.
3. Pushes a `HAIL` frame onto the call stack.
4. Begins executing the matching `Hail | <name>` block in the
   current bytecode context.
5. `╰──|` (the `OUTPUT` opcode) writes back to the foreign
   runtime's stdin, completing the round-trip.

## 4. The Foreign-Language Shim

For each supported language, the player injects a thin shim that
wraps the user's source. The shim is the same on every platform
and is identical to what `MF-FORMAT.md` Section 5.4 specifies.

### 4.1 Python shim

```python
import sys, json
_user_source = sys.stdin.read()
try:
    _namespace = {"__name__": "__plex_block__"}
    exec(_user_source, _namespace)
    _last = _namespace.get("_plex_result")
    if _last is None:
        for _v in reversed(list(_namespace.values())):
            if not _v.__class__.__name__.startswith("_"):
                _last = _v
                break
    sys.stdout.write(json.dumps({"value": _last}))
except Exception as e:
    sys.stdout.write(json.dumps({"error": str(e)}))
```

### 4.2 JavaScript shim

```javascript
const _userSource = require('fs').readFileSync(0, 'utf8');
try {
  let _last;
  eval(_userSource);
  process.stdout.write(JSON.stringify({value: _last}));
} catch (e) {
  process.stdout.write(JSON.stringify({error: e.message}));
}
```

### 4.3 C shim

```c
// The player's C handler compiles the user's source with this shim
// appended. The shim provides a `_plex_result` global and a main()
// that reads source from stdin, evals it via a tiny interpreter
// (out of scope for v0.1 — the C handler only supports C source
// that defines a `_plex_main()` function returning int).
```

For v0.1, the C handler is limited: the user's source must define
`_plex_main() -> int`, and the return value is captured. Full C
script execution is v0.2.

### 4.4 Other languages

Java, Swift, and HTML handlers are v0.2. v0.1 supports Python and
JavaScript fully, C partially (compiled binaries only), and
reports unavailable for the rest.

## 5. The Native Skin (per-OS)

The skin is the part of the player that interfaces with the host
operating system. The skin handles:

- **Process metadata:** binary name, version string, process icon.
- **Window management:** opening windows for UI blocks.
- **File dialogs:** when a `.plx` file references an unknown file.
- **Clipboard:** for `Show` opcodes with text output.
- **Notification UI:** for runtime errors and assembly rejection.

### 5.1 macOS skin (Swift)

- App bundle: `MFPlayer.app/Contents/MacOS/MFPlayer`
- Mach-O metadata lists Swift symbols in the LC_SYMTAB.
- Window management via Cocoa/AppKit.
- WebView via WKWebView.
- File dialogs via NSOpenPanel.
- Process name: `MFPlayer`.

### 5.2 Linux skin (Rust)

- ELF binary, no dynamic linking beyond libc and libm.
- Window management via X11 or Wayland (auto-detect).
- WebView via webkit2gtk-4.1 (linked dynamically).
- File dialogs via GTK4 or zenity fallback.
- Process name: `mf-player`.

### 5.3 Windows skin (C/C++)

- PE32+ binary, no CLR.
- Window management via Win32 directly (no MFC, no ATL).
- WebView via WebView2 (linked dynamically).
- File dialogs via IFileDialog.
- Process name: `mf-player.exe`.
- The PE header's "language" field is set to `0x0409` (English) to
  mimic a native MSVC compile.

## 6. The Mimic Layer (deferred to v0.2)

In v0.1, the player is clearly PleXcode-branded. The process name,
binary metadata, and window title all say "MFPlayer" or similar.

In v0.2, a deeper mimic layer is added:

- The binary metadata is rewritten to look like a host-OS-native
  compile (Swift symbols on macOS, Rust symbols on Linux, MSVC
  metadata on Windows).
- The process name is randomized from a list of common native
  apps (e.g. on macOS, the process can be named "WindowServer",
  "loginwindow", "Finder", etc.).
- The window's title and behavior match a typical native app.

This mimic layer is cosmetic — it does not change the player's
behavior, only its surface. The player is still verifiable as
PleXcode via its NCOM signature, but casual inspection cannot
distinguish it from a normal native app.

## 7. Error Reporting

The player reports errors to the user in a clear, non-cryptic form.
Error codes are stable; messages may be localized in v0.2.

| Code                              | Meaning                                         |
|-----------------------------------|-------------------------------------------------|
| `error.assembly.peer_missing`     | `.att` or `.TAG` not found alongside `.mf`.     |
| `error.format.magic`              | File header magic bytes don't match.            |
| `error.format.too_new`            | Container version is newer than player supports.|
| `error.assembly.cross_hash_mismatch` | Cross-hash references don't match.            |
| `error.signature.invalid`         | Ed25519 signature verification failed.          |
| `error.pulse.desync`              | Pulse streams are not byte-identical.           |
| `error.clock.expired`             | Outside the agreed clock-sync window.           |
| `error.clock.unreasonable`        | System clock is wildly wrong.                   |
| `error.runtime.missing`           | Required foreign runtime not on PATH.           |
| `error.runtime.failed`            | Foreign runtime exited non-zero.               |
| `error.bytecode.invalid`          | Bytecode failed to parse.                       |
| `error.bytecode.stack_overflow`   | Stack exceeded max depth.                       |
| `error.slot.invalid`              | Reference to a slot outside the lane group.     |
| `error.internal`                  | Unrecoverable internal player error.            |

## 8. Security Invariants

The player MUST guarantee:

1. **The decrypted bytecode never touches disk.** All execution
   happens in private memory; the player does not `write()` or
   `mmap()` the plaintext to a backing file.
2. **Pulse seeds are non-persistent.** Pulse seeds are derived in
   transient memory from `(file_hash, timestamp, developer_key)`
   and are never logged or written.
3. **The player's binary is signed by NCOM.** The OS verifies the
   player's signature before launching (Gatekeeper on macOS, code
   signing on Windows, package signature on Linux).
4. **Cross-platform consistency.** The same `.mf` produces the
   same execution result on every platform (modulo foreign
   runtime version differences, which are reported, not hidden).
5. **Fail closed.** On any verification failure, the player
   refuses to run the assembly. There is no "ignore and proceed"
   path.

## 9. Player Versioning

The player has a version string (e.g. `0.1.0`) embedded at build
time. The player reports its version on `--version` and via the
`error.format.too_new` message when rejecting a newer container.

## 10. CLI Interface

The player is invokable from a shell:

```
mf-player <file.mf>          # run an assembly
mf-player --version          # print version
mf-player --probe            # list available foreign runtimes
mf-player --help             # usage information
mf-player --inspect <file.mf> # show assembly metadata (read-only)
```

`--inspect` is a debug-mode entry that loads the assembly,
performs full verification, and prints the contents of `.att` and
`.TAG` (with the bytecode's encrypted section length but not its
plaintext). It does NOT execute the bytecode.
