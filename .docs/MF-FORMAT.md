# .mf Container Format Specification v0.1

> The `.mf` (Manifesto) container is the encrypted distribution
> format for PleXcode applications. Every `.mf` ships with two
> companion files (`.att` and `.TAG`) forming a three-file assembly.
> This document is the source of truth for the binary layout of all
> three files. The runtime architecture is in `ARCHITECTURE.md`.

## 1. The Three-File Assembly

Every PleXcode application ships as exactly three files:

| File      | Purpose                                                   |
|-----------|-----------------------------------------------------------|
| `.mf`     | Encrypted manifesto container. Holds the compiled bytecode. |
| `.att`    | Signed asset/argument address book.                       |
| `.TAG`    | Signed metadata.                                          |

The three files share:

- A **clock-sync window** `[valid_from, valid_until]`
- A **pulse stream** (byte-identical across all three)
- **Cross-hashes** (each file references SHA-256 of the other two)
- A **developer signature** (Ed25519, applied per-file)

The player refuses to load any `.mf` whose assembly is broken,
expired, or has mismatched cross-hashes.

## 2. Bytecode Format

The transpiler compiles `.plx` to PleXcode bytecode — a stack-based
instruction set with named lane slots. This bytecode is what gets
encrypted into the `.mf`.

### 2.1 Lane slot model

The bytecode operates on a wide stack with four named-slot groups:

| Group    | Slots        | Indexed 0..N |
|----------|--------------|--------------|
| CPU      | `@cpu[0..255]`   | 256 slots |
| Memory   | `@mem[0..1023]`  | 1024 slots |
| I/O      | `@io[0..63]`     | 64 slots  |
| Network  | `@net[0..31]`    | 32 slots  |

`Argu~!!` claims a slot. The slot is held until the script ends or
the slot is explicitly released. Released slots are reset to the
empty value `[""]`.

### 2.2 Instruction set (v0.1)

Each instruction is a single byte opcode followed by zero or more
operand bytes. Operands are unsigned unless noted.

| Opcode | Mnemonic    | Operands         | Meaning                          |
|--------|-------------|------------------|----------------------------------|
| 0x00   | `NOP`       | —                | No operation.                    |
| 0x01   | `HALT`      | —                | End execution.                   |
| 0x10   | `POSSESS`   | slot(2), type(1) | Claim a lane slot. `type` is 0=CPU, 1=mem, 2=io, 3=net. |
| 0x11   | `RELEASE`   | slot(2)          | Release a lane slot.             |
| 0x20   | `PUSH_STR`  | len(2), bytes(N) | Push string literal onto stack.  |
| 0x21   | `PUSH_INT`  | value(8)         | Push 64-bit signed int.          |
| 0x22   | `PUSH_FLOAT`| value(8)         | Push 64-bit IEEE float.          |
| 0x23   | `PUSH_EMPTY`| —                | Push `[""]` (empty placeholder). |
| 0x30   | `POP`       | —                | Discard top of stack.            |
| 0x31   | `DUP`       | —                | Duplicate top of stack.          |
| 0x40   | `STORE`     | slot(2)          | Bind top of stack to slot.       |
| 0x41   | `LOAD`      | slot(2)          | Push slot's value onto stack.    |
| 0x50   | `ADD`       | —                | Pop two, push sum.               |
| 0x51   | `SUB`       | —                | Pop two, push difference.        |
| 0x52   | `MUL`       | —                | Pop two, push product.           |
| 0x53   | `DIV`       | —                | Pop two, push quotient.          |
| 0x54   | `MOD`       | —                | Pop two, push remainder.         |
| 0x60   | `EQ`        | —                | Pop two, push 1 if equal else 0. |
| 0x61   | `LT`        | —                | Pop two, push 1 if less else 0.  |
| 0x62   | `GT`        | —                | Pop two, push 1 if greater else 0.|
| 0x70   | `JMP`       | offset(4)        | Unconditional jump.              |
| 0x71   | `JMP_IF`    | offset(4)        | Jump if top of stack is truthy.  |
| 0x72   | `JMP_IFN`   | offset(4)        | Jump if top of stack is falsy.   |
| 0x80   | `CALL`      | name_idx(2)      | Call a built-in function by name. |
| 0x81   | `RET`       | —                | Return from current frame.       |
| 0x90   | `SCRIPT`    | lang_idx(2)      | Open a foreign-language block. Next on stack: source. Below: optional filename. |
| 0x91   | `SCRIPT_END`| —                | Close a foreign-language block.  |
| 0xA0   | `PULSE`     | channel(2), len(2), bytes(N) | Direct CPU packet.  |
| 0xA1   | `SHELL`     | cmd_idx(2)       | Toolchain passthrough. Top of stack: command string. |
| 0xB0   | `SHOW`      | —                | Pop top of stack, emit to output. |
| 0xB1   | `OUTPUT`    | —                | Pop top of stack, emit to caller (for `Hail` responses). |
| 0xC0   | `LINK`      | target_idx(2)    | Resolve an `@`-reference at runtime. |
| 0xC1   | `ATT`       | key_idx(2)       | Read from `.att` asset table.    |
| 0xC2   | `TAG`       | key_idx(2)       | Read from `.TAG` metadata.       |
| 0xFF   | `EXT`       | ext_id(2), len(2), bytes(N) | Extension opcode. Reserved. |

### 2.3 String table

Bytecode contains a string table at the end of the bytecode section.
References to strings in instructions are 16-bit indices into this
table. Strings are length-prefixed (2 bytes little-endian) followed
by UTF-8 bytes.

### 2.4 Bytecode section layout

```
+----------------+
| magic: "PLX1"  |  4 bytes
+----------------+
| header size    |  2 bytes (little-endian)
+----------------+
| flags          |  2 bytes
+----------------+
| stack size     |  2 bytes (max stack depth, default 256)
+----------------+
| code size      |  4 bytes
+----------------+
| string tbl sz  |  4 bytes
+----------------+
| code bytes     |  N bytes
+----------------+
| string table   |  M bytes
+----------------+
```

`flags` is a bitfield:
- bit 0: requires authentication
- bit 1: requires Python runtime
- bit 2: requires Node runtime
- bit 3: requires gcc
- bit 4: requires Java runtime
- bit 5: requires Swift runtime
- bit 6: requires WebView
- bit 7-15: reserved

## 3. The .mf File Layout

The `.mf` file is a binary container with this layout:

```
+-----------------------------------+
| MF Header (see 3.1)               |
+-----------------------------------+
| Pulse Stream (see 5)              |
+-----------------------------------+
| Cross-Hash Table (see 6)          |
+-----------------------------------+
| Clock-Sync Window (see 7)         |
+-----------------------------------+
| Developer Public Key (Ed25519)    |  32 bytes
+-----------------------------------+
| AES-256-GCM Nonce                 |  12 bytes
+-----------------------------------+
| AES-256-GCM Ciphertext            |  N bytes
|   (encrypted bytecode section)    |
+-----------------------------------+
| AES-256-GCM Auth Tag              |  16 bytes
+-----------------------------------+
| Ed25519 Signature                 |  64 bytes
+-----------------------------------+
```

### 3.1 MF Header

```
+----------------+
| magic: "MFC1"  |  4 bytes  (Manifesto Container v1)
+----------------+
| version        |  2 bytes  (= 0x0001)
+----------------+
| flags          |  4 bytes
+----------------+
| header size    |  2 bytes
+----------------+
```

`flags`:
- bit 0: assembly has expired window
- bit 1: requires network for foreign runtime
- bit 2-31: reserved

## 4. The .att File Layout

The `.att` (attributes) file is the asset/argument address book.

```
+-----------------------------------+
| ATT Header                        |
|   magic: "ATT1"                   |  4 bytes
|   version: 0x0001                 |  2 bytes
|   entry count                     |  4 bytes
+-----------------------------------+
| Entries (see 4.1)                 |
+-----------------------------------+
| Ed25519 Signature                 |  64 bytes
+-----------------------------------+
```

### 4.1 Entry format

```
+----------------+
| key length     |  2 bytes
+----------------+
| key (UTF-8)    |  N bytes
+----------------+
| value type     |  1 byte  (0=string, 1=int, 2=file, 3=auth)
+----------------+
| value length   |  4 bytes
+----------------+
| value bytes    |  M bytes
+----------------+
```

Auth entries (`type=3`) have the format:
```
<signer_id>: Auth - |~|!!| <signer_id>.!!
```

## 5. Pulse Stream

The pulse stream is the raw-preview engine. It is byte-identical
across `.mf`, `.att`, and `.TAG` in the same assembly.

### 5.1 Pulse stream layout

```
+-----------------------------------+
| Pulse Header                      |
|   magic: "PLS1"                   |  4 bytes
|   pulse count                     |  4 bytes
|   period (seconds)                |  4 bytes
+-----------------------------------+
| Pulse entries (see 5.2)           |
+-----------------------------------+
```

### 5.2 Pulse entry format

```
+----------------+
| timestamp      |  8 bytes  (Unix seconds, LE)
+----------------+
| rate length    |  2 bytes  (always 32 in v0.1)
+----------------+
| rate bytes     |  32 bytes
+----------------+
```

The `rate bytes` is a 256-bit value generated by a CSPRNG seeded
with `(file_sha256, pulse_timestamp, developer_public_key)`. The
player can reproduce the rate deterministically; nothing else can
without the developer's key.

### 5.3 Pulse stream invariants

- All three files in an assembly MUST have byte-identical pulse
  streams. The player verifies this on load.
- The pulse stream is append-only over the assembly's lifetime.
- The `period` field is the suggested interval between pulse
  entries (typically 1-5 seconds for active assemblies).

## 6. Cross-Hash Table

Each of the three files contains a cross-hash table referencing the
other two. The table is at a fixed location in each file's layout
(see Section 3 and Section 4 for `.att`; the `.TAG` layout is in
Section 8).

```
+----------------+
| peer count     |  1 byte  (always 2)
+----------------+
| peer[0] type   |  1 byte  (0=.mf, 1=.att, 2=.TAG)
+----------------+
| peer[0] hash   |  32 bytes (SHA-256 of peer file)
+----------------+
| peer[1] type   |  1 byte
+----------------+
| peer[1] hash   |  32 bytes
+----------------+
```

The cross-hash is computed over the entire peer file (header +
content + signature), including the peer's own pulse stream.

## 7. Clock-Sync Window

```
+----------------+
| valid_from     |  8 bytes  (Unix seconds, LE; 0 = open-start)
+----------------+
| valid_until    |  8 bytes  (Unix seconds, LE; 0xFFFFFFFFFFFFFFFF = open-end)
+----------------+
```

The window is embedded in all three files at the same location
(between the cross-hash table and the per-file data section).

The player rejects the assembly if:
- The system clock is outside `[valid_from, valid_until]` for any
  of the three files (and the windows disagree).
- The system clock is wildly wrong (e.g. before 2020, after 2100).
- Any of the three files' windows disagree with the others.

## 8. The .TAG File Layout

```
+-----------------------------------+
| TAG Header                        |
|   magic: "TAG1"                   |  4 bytes
|   version: 0x0001                 |  2 bytes
|   metadata count                  |  4 bytes
+-----------------------------------+
| Pulse Stream (identical to .mf)   |
+-----------------------------------+
| Cross-Hash Table                  |
+-----------------------------------+
| Clock-Sync Window                 |
+-----------------------------------+
| Metadata entries (see 8.1)        |
+-----------------------------------+
| Ed25519 Signature                 |  64 bytes
+-----------------------------------+
```

### 8.1 Metadata entry

```
+----------------+
| key length     |  2 bytes
+----------------+
| key (UTF-8)    |  N bytes
+----------------+
| value type     |  1 byte  (0=string, 1=int, 2=json)
+----------------+
| value length   |  4 bytes
+----------------+
| value bytes    |  M bytes
+----------------+
```

Standard metadata keys (reserved, all optional except `developer`):
- `developer`: developer display name
- `app_name`: application display name
- `version`: semver string
- `signed`: timestamp of signing
- `signer_id`: developer's Ed25519 public key (hex)

## 9. Signature Scheme

Each file is signed with Ed25519 over the canonical byte range from
the start of the file through the byte just before the signature
itself. The developer's Ed25519 keypair is generated at signing
time; the private key never leaves the developer's machine.

The player validates:
1. Ed25519 signature on each of the three files
2. SHA-256 cross-hashes match
3. Pulse streams are byte-identical
4. Clock-sync windows agree
5. System clock is within the agreed window

If any of these fail, the assembly is rejected with one of:
- `error.signature.invalid`
- `error.assembly.peer_missing`
- `error.assembly.cross_hash_mismatch`
- `error.pulse.desync`
- `error.clock.expired`
- `error.clock.unreasonable`

## 10. Raw Preview Rendering

When an unauthorized tool (text editor, hex viewer, `cat`, file
preview) opens any of the three files, the visible bytes should
be rendered as:

```
display_bytes[i] = file_bytes[i] XOR rate_mask[i % 32]
```

where `rate_mask` is the rate bytes of the most recent pulse entry
whose timestamp is `<= now`.

The bytes on disk are unchanged. The XOR mask is computed on the
fly for display. The pulse seed (which would let an attacker
reproduce the mask) is NEVER stored on disk and exists only in
transient memory during a single render.

This produces output that:
- Looks like random garbage to unauthorized viewers
- Changes on every render (because the rate is time-derived)
- Is non-reversible without the developer's key
- Does not affect the bytes on disk

The player bypasses this preview layer entirely; it operates on
the raw bytes using the developer's key to decrypt.

## 11. Versioning

This is `MF-FORMAT.md` version `0.1.0`. The container's `version`
field MUST match. Players reject containers whose `version` is
higher than the player supports.
