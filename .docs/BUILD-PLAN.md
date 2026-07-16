# PleXcode Build Plan v0.1

> The build order, milestones, and definition-of-done for the
> PleXcode v0.1 release. After this is complete, the system is
> shippable: a developer can write a `.plx` file, compile it to
> an encrypted `.mf + .att + .TAG` assembly, and a user can
> install the player and run the assembly.

## 0. Prerequisites

Before any code is written, the following specs are complete and
authoritative:

- `ARCHITECTURE.md` — system shape, security model, file-assembly rules
- `PLEXCODE-SPEC.md` — language surface, glyphs, autocorrect, Script blocks
- `MF-FORMAT.md` — container format, bytecode ISA, encryption, pulse stream
- `PLAYER-SPEC.md` — player behavior, foreign-language bridge, native skin

## 1. Repository Layout

```
NCOM-Systems/plexcode-sdk/
├── ARCHITECTURE.md
├── PLEXCODE-SPEC.md
├── MF-FORMAT.md
├── PLAYER-SPEC.md
├── BUILD-PLAN.md
├── README.md
│
├── tools/                          # Developer-side tooling
│   ├── plexc/                      # The transpiler (.plx → .mf assembly)
│   │   ├── src/
│   │   │   ├── main.c              # CLI entry point
│   │   │   ├── lexer.c             # Tokenizer
│   │   │   ├── parser.c            # Parses .plx → AST
│   │   │   ├── ast.c               # AST nodes
│   │   │   ├── codegen.c           # AST → bytecode
│   │   │   ├── autocorrect.c       # Surface-form normalization
│   │   │   ├── crypto.c            # AES-256-GCM + Ed25519 wrappers
│   │   │   ├── pulse.c             # Pulse stream generation
│   │   │   ├── packager.c          # Bytecode → .mf + .att + .TAG
│   │   │   └── util.c
│   │   ├── include/
│   │   │   └── *.h
│   │   ├── tests/                  # Unit tests
│   │   │   ├── test_lexer.c
│   │   │   ├── test_parser.c
│   │   │   ├── test_codegen.c
│   │   │   ├── test_crypto.c
│   │   │   └── test_packager.c
│   │   ├── Makefile
│   │   └── README.md
│   │
│   └── README.md
│
├── player/                         # The runtime (per-platform)
│   ├── core/                       # Platform-agnostic C core
│   │   ├── src/
│   │   │   ├── main.c              # CLI entry point
│   │   │   ├── verify.c            # Assembly verification pipeline
│   │   │   ├── decrypt.c           # AES-256-GCM decryption
│   │   │   ├── interp.c            # Bytecode interpreter
│   │   │   ├── slots.c             # Lane slot management
│   │   │   ├── stack.c             # Evaluation stack
│   │   │   ├── foreign.c           # Foreign-language bridge
│   │   │   ├── shim_py.c           # Python shim (string template)
│   │   │   ├── shim_js.c           # JavaScript shim (string template)
│   │   │   ├── shim_c.c            # C shim (string template)
│   │   │   ├── probe.c             # Foreign runtime discovery
│   │   │   ├── hail.c              # Inbound Hail handshake
│   │   │   ├── errors.c            # Error reporting
│   │   │   └── util.c
│   │   ├── include/
│   │   │   └── *.h
│   │   ├── tests/                  # Unit tests for core
│   │   │   ├── test_verify.c
│   │   │   ├── test_decrypt.c
│   │   │   ├── test_interp.c
│   │   │   └── test_foreign.c
│   │   └── Makefile
│   │
│   ├── macos/                      # Swift skin for macOS
│   │   ├── Package.swift
│   │   ├── Sources/
│   │   │   ├── MFPlayerApp/        # SwiftUI app entry
│   │   │   ├── MFPlayerCore/       # C bridges to core/
│   │   │   └── MFPlayerSkin/       # Cocoa/AppKit integration
│   │   ├── Resources/
│   │   └── README.md
│   │
│   ├── linux/                      # Rust skin for Linux
│   │   ├── Cargo.toml
│   │   ├── src/
│   │   │   ├── main.rs             # CLI entry, skin metadata
│   │   │   ├── core_bridge.rs      # FFI to core/
│   │   │   └── skin.rs             # X11/Wayland integration
│   │   └── README.md
│   │
│   └── windows/                    # C/C++ skin for Windows
│       ├── CMakeLists.txt
│       ├── src/
│       │   ├── main.cpp            # Win32 entry, skin metadata
│       │   ├── core_bridge.cpp     # FFI to core/
│       │   └── skin.cpp            # Win32 integration
│       └── README.md
│
├── examples/                       # Sample .plx files
│   ├── hello.plx
│   ├── arithmetic.plx
│   ├── python_bridge.plx
│   ├── javascript_bridge.plx
│   ├── signed_secret.plx
│   └── swarm_orchestration.plx
│
├── tests/                          # End-to-end integration tests
│   ├── test_hello.sh               # hello.plx → assembly → run
│   ├── test_python_bridge.sh       # Python block executes
│   ├── test_signed.sh              # Signed assembly produces .att + .TAG
│   ├── test_tamper.sh              # Tampered file is rejected
│   └── test_expired.sh             # Expired assembly is rejected
│
└── docs/
    ├── getting-started.md
    ├── tutorial-hello-world.md
    ├── tutorial-bridge-python.md
    └── tutorial-signed-assembly.md
```

## 2. Milestones

### Milestone 1: Specs (COMPLETE)

Deliverables: `ARCHITECTURE.md`, `PLEXCODE-SPEC.md`, `MF-FORMAT.md`,
`PLAYER-SPEC.md`, `BUILD-PLAN.md`.

Definition of done: each spec is internally consistent, all four
cross-reference correctly, and the build order is unambiguous.

### Milestone 2: Transpiler Core

Build the `plexc` tool. This is the developer-side CLI that turns
`.plx` into an encrypted `.mf + .att + .TAG` assembly.

Sub-milestones:

- **2a. Lexer + parser.** Tokenize `.plx`, build AST. Handles all
  glyphs, commands, autocorrect, and `Script` blocks.
- **2b. AST → bytecode.** Compile the AST to PleXcode bytecode per
  `MF-FORMAT.md` Section 2.
- **2c. Crypto + packaging.** AES-256-GCM encryption, Ed25519
  signing, pulse stream generation, three-file assembly output.
- **2d. CLI.** `plexc input.plx` produces `input.mf`, `input.att`,
  `input.TAG`. Plus `--inspect`, `--sign`, `--keygen` flags.

Definition of done: `plexc examples/hello.plx` produces a valid
three-file assembly. The assembly's cross-hashes are correct, the
pulse streams are byte-identical, and the bytecode is well-formed.

### Milestone 3: Player Core (C, platform-agnostic)

Build the `core/` directory of the player. This is the verification
pipeline, the bytecode interpreter, and the foreign-language
bridge. Pure C, no GUI, no platform-specific code. Has a CLI mode
for testing.

Sub-milestones:

- **3a. Verification pipeline.** Implements `PLAYER-SPEC.md`
  Section 2 steps 1-11. Cross-hash, signature, pulse sync, clock
  window, all enforced.
- **3b. Decryption.** AES-256-GCM with key wrapping.
- **3c. Interpreter.** Full opcode set from `MF-FORMAT.md` Section
  2.2, including all flow control, slot management, and stack ops.
- **3d. Foreign-language bridge.** `popen` to `python3`, `node`,
  `gcc`. JSON contract. Python and JavaScript fully supported;
  C limited to compiled binaries in v0.1.
- **3e. Toolchain passthrough.** `\\\` lines route to the right
  toolchain.
- **3f. CLI.** `mf-player file.mf`, `--version`, `--probe`,
  `--inspect`, `--help`.

Definition of done: `./mf-player tests/fixtures/hello.mf` runs the
assembly and produces the expected output. Tampered assemblies
are rejected with the correct error code. Foreign-language blocks
execute and return JSON.

### Milestone 4: First End-to-End Test

A complete pipeline: write a `.plx` file, compile it, run the
resulting assembly.

```bash
# 1. Write a .plx file
cat > /tmp/hello.plx <<'EOF'
Hail | HelloWorld
╰──➤ Show | "Hello from PleXcode"
EOF

# 2. Compile to assembly
plexc /tmp/hello.plx
# produces /tmp/hello.mf, /tmp/hello.att, /tmp/hello.TAG

# 3. Run the assembly
mf-player /tmp/hello.mf
# expected output: "Hello from PleXcode"
```

Definition of done: the above sequence works on the build host.
The output is "Hello from PleXcode". All three assembly files are
created with valid cross-references, signatures, and pulse
streams.

### Milestone 5: Foreign-Language Bridge Test

```bash
cat > /tmp/python_bridge.plx <<'EOF'
Hail | PythonBridge
╰──➤ Script | python
   "import random; random.randint(1, 100)"
╰──➤ Show | @result
EOF

plexc /tmp/python_bridge.plx
mf-player /tmp/python_bridge.mf
# expected output: a random integer between 1 and 100
```

Definition of done: the assembly runs, Python is invoked via
`popen`, the JSON result is deserialized, and the value is shown.

### Milestone 6: Tamper Detection Test

```bash
# 1. Compile a normal assembly
plexc /tmp/hello.plx

# 2. Flip a byte in the .mf
printf '\x00' | dd of=/tmp/hello.mf bs=1 seek=42 count=1 conv=notrunc

# 3. Try to run it
mf-player /tmp/hello.mf
# expected: error.assembly.cross_hash_mismatch or error.signature.invalid
```

Definition of done: the player refuses to run the tampered
assembly. The error code is one of the codes from
`PLAYER-SPEC.md` Section 7.

### Milestone 7: Platform Skins

- **7a. macOS skin (Swift).** SwiftUI app, Cocoa integration,
  WKWebView. `make` in `player/macos/` produces `MFPlayer.app`.
- **7b. Linux skin (Rust).** Cargo project, FFI to `core/`, X11/
  Wayland integration. `cargo build` produces `mf-player`.
- **7c. Windows skin (C/C++).** CMake project, FFI to `core/`,
  Win32 + WebView2 integration. `cmake --build` produces
  `mf-player.exe`.

Definition of done: the same `.mf` assembly runs on macOS, Linux,
and Windows, producing identical output. Each skin has a CLI mode
that works the same as the core's CLI.

### Milestone 8: First Shippable Release

A complete v0.1 release:

- Transpiler (`plexc`) builds and runs on macOS, Linux, Windows.
- Player (`mf-player` or `MFPlayer.app`) builds and runs on
  macOS, Linux, Windows.
- NCOM-signing of the player binary on each platform (Gatekeeper
  on macOS, code signing on Windows, package signing on Linux).
- Six example `.plx` files covering the core feature set.
- Four end-to-end test scripts in `tests/`.
- Documentation: getting-started, two tutorials.
- Tagged release: `v0.1.0`.

Definition of done: a developer with the SDK installed can write
a `.plx` file, compile it, and ship the assembly. A user with the
player installed can download the assembly, run it, and see the
expected output. Tampered or expired assemblies are rejected.

## 3. What v0.1 Does NOT Include

These are deferred to v0.2 or later:

- Full C script execution (v0.1 supports only compiled binaries).
- Java, Swift, HTML handler bridge (deferred to v0.2).
- The mimic layer (player surface is clearly PleXcode-branded).
- Time-limited assemblies with `valid_until != ∞`.
- Auto-renewal of expired assemblies from a developer server.
- NCOM custom hardware support (TIER 1 of the architecture).
- Native PleXcode ISA on custom silicon (TIER 3).
- Localization of error messages.
- Self-modifying or auto-generating PleXcode scripts at runtime.
- A graphical IDE for `.plx` authoring.
- A package manager / `.k!t` builder.

## 4. Build Order (recommended)

1. **Milestone 1** — write the specs (done in this session).
2. **Milestone 3a-3c** — player core: verification, decryption,
   interpreter. This is the foundation. Build it first because
   it's the smallest working unit.
3. **Milestone 2a-2c** — transpiler: lexer, parser, codegen.
   The transpiler needs the player to verify its output, so
   build the player first.
4. **Milestone 4** — end-to-end hello world. Validates that the
   transpiler and player work together.
5. **Milestone 3d-3e** — foreign-language bridge and toolchain
   passthrough. This is the "PleXcode is a bridge" feature.
6. **Milestone 5** — Python bridge test. Validates the bridge.
7. **Milestone 6** — tamper detection. Validates the security
   model.
8. **Milestone 7a** — macOS skin first (since the macOS install
   path is the most mature in the project).
9. **Milestone 7b-7c** — Linux and Windows skins.
10. **Milestone 8** — packaging, signing, release.

## 5. Risk Register

- **Crypto correctness.** The encryption, signing, and pulse
  stream are the security foundation. Use a vetted library
  (libsodium or OpenSSL) — do not roll your own primitives.
- **Cross-platform C core.** C is portable but subtle differences
  (endianness, struct packing, locale) bite. Add CI on all three
  platforms early.
- **Foreign-runtime variability.** Python 3.10 vs 3.12, Node 18
  vs 20, etc., may behave differently. The JSON contract helps,
  but document the supported versions clearly.
- **Build toolchain availability.** The Linux and Windows build
  hosts may not have all dependencies (libsodium, gtk4,
  webview2). Document prerequisites.
- **mimic layer complexity.** The v0.2 mimic layer is a long
  rabbit hole. Keep v0.1 honest: the player is clearly
  PleXcode-branded. Don't slip mimic work into v0.1.

## 6. Versioning & Release

- v0.1.0 is the first shippable release.
- v0.2.0 adds the mimic layer, full C bridge, Java/Swift/HTML.
- v0.3.0 explores NCOM hardware prototypes.
- v1.0.0 is reserved for the first NCOM hardware release.
