---
name: delta-review-lens
description: Project lens for the Primal SDK — a Dart implementation of the Primal programming language, with a reader → lexical → syntactic → semantic → lowering → runtime pipeline shipping to CLI and web. Supplies the project-specific briefs — architecture, domain, security, resource parity and style — that the delta-review skill turns into reviewer agents. Not a standalone review skill; it defines no change-set collection, orchestration, severities, or fixes of its own.
---

This file is a **lens**, not a review. The `delta-review` skill reads it, takes each `##` section below as one reviewer brief, and owns everything else — collecting the change set, spawning agents, refuting findings, assigning severity, reporting, and fixing. Nothing here overrides that.

**The project.** A programming language implementation, not an application. The compiler pipeline lives in `lib/compiler/` as `reader` → `lexical` → `syntactic` → `semantic` → `lowering` → `runtime`, with `models`, `errors` and `warnings` shared across it. The standard library is roughly thirty capability groups under `lib/compiler/library/` (arithmetic, string, list, map, set, file, directory, path, json, timestamp, duration, hash, uuid, and so on), all registered in `standard_library.dart`. Platform access is abstracted in `lib/compiler/platform/` across six capability groups. Two entry points: `lib/main/main_cli.dart` and `lib/main/main_web.dart`. Version `0.5.4`; dependencies are only `path`, `crypto` and `characters`.

**Note on the agent files.** `CLAUDE.md` and `GEMINI.md` are **symlinks to `AGENTS.md`** — one file under three names. Never report drift between them, and never "sync" them.

**What to read first.** `AGENTS.md` for every review. `README.md` for the language overview, `docs/lang/**` for user-facing semantics, `docs/dev/**` for implementation rationale, and `docs/schema.md` for the knowledge-base conventions — the last matters because docs are part of the change here, not commentary on it.

## Architecture

Phase boundaries, registration points, the platform seam, and the cost of getting the hot path wrong.

- **Phases only import forward.** `reader` may not import `lexical`, `lexical` may not import `syntactic`, and so on down the pipeline. `test/compiler/phase_separation_test.dart` enforces this, so a violation is a failing test rather than a subtle bug — catch it in review anyway, because the fix is usually a design question (which phase owns this?) rather than an import edit.
- **Phases share the `Analyzer<I, O>` / `State<I, O>` contract.** A new phase step, or a change to an existing one, must keep that shape: input type in, output type out, state threaded explicitly.
- **A standard-library function is invisible until it is registered.** It must follow the `NativeFunctionTerm` / `NativeFunctionTermWithArguments` pattern **and** appear in `StandardLibrary.get()`. That list feeds `getSignatures()`, which semantic analysis validates every call against — a function defined but never registered compiles fine and is unreachable from any program.
- **The platform seam is six triples, and both sides must move together.** Each capability group under `lib/compiler/platform/` — base, console, directory, environment, file, path — has a `*_base`, a `*_cli` and a `*_web` file, wired by conditional import. A method added to a base needs a real implementation in **both** concrete files; `dart:io` may be reached only through the CLI side. A `dart:io` import anywhere in `lib/compiler/library/**` or another shared file breaks the web build outright, and a runtime check (`if (dart.library.html)`) is the wrong tool — the seam is a conditional import.
- **The shared model vocabulary is small and load-bearing:** `Term`, `Type`, `Expression`, `Token`, `Lexeme`, `Location`, `Located`, `Parameter`, `FunctionSignature`, `Bindings`. A new subtype of any of them must be handled by every `is`-chain, `switch` and dispatch table that consumes the parent — those are spread across phases, so the caller sweep matters more here than in an application.
- **Errors and warnings are a hierarchy, not strings.** A phase must raise the error type its consumers expect; replacing a specific error subtype with a more general one silently changes what callers — and tests, and users — can distinguish.
- **The hot paths are `reduce()` and the lexical and syntactic loops.** Work added there runs once per term per evaluation. Watch for: the same term reduced more than once instead of reduced and stored; string building with `+` in a loop rather than `StringBuffer`; `List` or `Map` allocated per recursive call; and recursion with no depth guard.

**Report shape:** the phase, library group or platform file affected, the boundary or contract broken, and the regression or scaling path that follows.

## Domain

The product **is** the semantics. In an application, a domain defect shows a wrong number; here it changes what every program written in this language means. Every observable behaviour of a shipped language is a contract with programs that already exist.

- **The language surface is versioned by use, not by declaration.** A core function renamed or removed from `StandardLibrary.get()` breaks every program that calls it. Arity changed, or parameter order changed, silently rebinds arguments. A parameter type narrowed (`Parameter.any` → `Parameter.number`, or a stricter `Type.accepts`) rejects calls that used to work; widened, it shifts `type_of` and dispatch.
- **`Parameter` declarations must match what `reduce()` actually does.** A function declaring `Parameter.string()` and then treating the value as a number type-checks at the boundary and fails at runtime, or worse, coerces silently.
- **A changed return subtype is a semantic change.** `reduce()` returning a decimal where it used to return an integer alters downstream type checks, `type_of`, comparisons, and `to_string` output for every caller.
- **Error messages, error categories and error classes are part of the surface.** Users match on them, tests assert on them, and `docs/lang/**` documents them.
- **Output formatting is behaviour:** number rendering, `to_string`, duration and time formatting, console output shape. A cosmetic-looking format change breaks every sample and every user script that parses output.
- **Syntax changes reach further than they look:** a lexeme or operator added, a precedence or associativity change in the expression parser, a new reserved word — each makes previously valid sources fail to parse.
- **`Location` must stay accurate through every phase.** Row and column drift produces error messages pointing at the wrong part of the user's source, which is a real defect even though nothing throws.
- **Numeric and text semantics are the classic trap:** integer versus double division (`~/` versus `/`), precision loss, `NaN` and infinity propagation, and `int` behaviour differing between the native and JavaScript runtimes — a program that works on the CLI and overflows differently on web is a correctness bug, not a platform quirk. Lexing must respect grapheme clusters (the `characters` dependency exists for this), not raw code units.
- **`timestamp` and `duration` carry time-zone, DST, leap-year and boundary behaviour** that no test will surface unless someone thinks of it.
- **Copy-paste is the normal authoring mode for library functions**, since the files are near-identical. The characteristic defect is a copied file that kept the source function's name, parameter list, arity, or error message — check every new library file against the one it was clearly copied from.
- **`test/resources/samples/*.prm` and `samples_test.dart` are the end-to-end record of language behaviour.** A changed expected result there means a program that used to produce X now produces Y; that is a language change and must be reported as one, whatever the diff says it is.

**Report shape:** a concrete Primal program or REPL input, the semantic rule or invariant it violates, and the observable difference in what that program does.

## Security

This is an interpreter that executes source it did not write, plus a standard library that reaches the filesystem and the environment. Two distinct framings apply, and a finding should say which: **untrusted program** (a `.prm` file or REPL input that should not be able to harm the host) and **malformed input** (a program that should fail cleanly rather than take the process down).

- **Unbounded recursion and allocation reachable from source are the primary risk.** `reduce()` recursing without a depth guard, or a list, string, map or vector builder with no size sanity, turns a short program into a crash or a hang. Any new recursive evaluation path or collection constructor needs to be considered adversarially.
- **The capability surface is `file`, `directory`, `path` and `environment`.** These are where a program touches the host: path traversal out of an intended root, symlink following, overwriting an existing file, recursive deletion, and reading environment values a program should not see. A change that widens what those groups can reach deserves an explicit justification.
- **`json` and `base64` parse untrusted input** — depth, size and malformed-input behaviour matter.
- **`hash` and `uuid` make cryptographic-looking promises.** Weak or predictable randomness where strength is implied, or a non-cryptographic hash presented as a secure one, is a real finding.
- **Error messages and debug output must not leak the host into the program's world** — absolute paths, environment values, or internal state disclosed through an error a program can catch and print.
- **The web build runs inside a browser sandbox.** A `dart:io` reach that escapes the platform seam is both a build break and an assumption that the sandbox does not hold.
- **Everything in the repository ships.** The compiled binaries in `bin/` are published artifacts, and there are no secrets to add here — if a change introduces one, that is the finding.

**Report shape:** the attacker capability (a crafted `.prm` program, hostile REPL input, a malicious path or JSON payload), the path from that input to the effect, the host asset affected, and the smallest fix.

## Resource parity

Documentation is a first-class artifact in this repository, and several other sets must move together.

- **81 documentation pages carry `sources:` frontmatter naming the `lib/` files they describe** (`docs/schema.md` defines the format). A source file moved, renamed or deleted leaves a dangling reference; a behaviour change leaves the page confidently wrong. `docs/dev/**` documents implementation rationale for contributors, `docs/lang/**` documents semantics for users — a single change can owe both, and `AGENTS.md`'s two-outputs rule means a significant explanation updates the wiki as well as the chat.
- **A new or changed core function owes four places at once:** its implementation, its `StandardLibrary.get()` registration, its `docs/lang/**` reference page, and its tests.
- **The platform triple must stay symmetric** — a `*_base` method needs `*_cli` and `*_web` implementations whose behaviour actually agrees, not merely two files that compile.
- **`bin/` holds three checked-in compiled binaries** — `primal-linux-x86-64`, `primal-macos-arm64` and `primal-windows-x86-64` — and the `binary`-tagged tests smoke-test them. Any change to the CLI or the runtime leaves those artifacts stale until `scripts/build_desktop.sh` runs. Say so; do not assume someone will notice.
- **`dart_test.yaml` defines six tags** — compiler, runtime, io, unit, cli, binary — with a 120s timeout. A test that loses its tag or gains a different one silently stops running in the suite that was meant to cover it, which looks identical to a passing build.
- **`README.md`, `CHANGELOG.md` and the `pubspec.yaml` version** track language-visible changes.
- **`test/helpers/` is shared infrastructure**, not per-test scaffolding — `assertion_helpers`, `pipeline_helpers`, `resource_helpers`, `token_factories`, the console fakes and runners. A change there reaches dozens of tests at once.

**Report shape:** the two sides that drifted, and the consequence — for a user, a contributor, or a build.

## Style

Everything here is a **Nit**; if it has a behavioural consequence it belongs to Architecture or Domain. **Do not report anything `analysis_options.yaml` already enforces** — it is strict, erroring on dead code, unused locals and unused fields, and linting single quotes, declared return types, final locals, directive ordering, control-body placement and much more. Formatting belongs to `scripts/format.sh`. Assume both ran.

- **Explicit type annotations, always.** `final String name`, never `final name` — an `AGENTS.md` rule the analyzer does not enforce, and the most common style finding in this repository.
- **No abbreviations.** Full words for every identifier: `function`, `argument`, `expression`, `index` — never `fn`, `arg`, `expr`, `idx`.
- **Match the file you copied from.** Library functions are near-identical by design, so a new one should mirror its siblings in structure, naming and ordering; a file that diverges gratuitously is harder to scan against the thirty next to it.
- **Reuse `test/helpers/`** rather than re-implementing an assertion, a fake, or a token factory locally.
- **Documentation pages follow `docs/schema.md`** — frontmatter fields, wikilinks, and the TLDR convention.
- **Dead code introduced by the change**, including an unused library entry, helper, or documentation page with no remaining source.

**Report shape:** `file:line`, the rule as written above, and the conforming form.
