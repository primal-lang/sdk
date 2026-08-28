---
name: prepare-release
description: Prepares the next SDK release by updating version, syncing documentation, generating changelog, and building the web binary.
---

0. **Pre-flight Checks**: Run validation checks before starting the release process.
   a. Run `git status` to check for uncommitted changes; warn the user if the working directory is not clean
   b. Run `dart format lib` to format library code
   c. Run `dart format test` to format test code
   d. Run `dart analyze` to perform static analysis
   e. Run `dart test` to run all tests
   f. If any command fails, stop immediately and report the error

1. **Version Update**: Prompt the user for the new version number.
   a. Validate that the input follows semver format (`X.Y.Z` where X, Y, Z are non-negative integers)
   b. If invalid, explain the expected format and prompt again
   c. Update the `version` field in `pubspec.yaml`
   d. Update the `version` constant in `lib/main/main_cli.dart` — it backs `--version`, the REPL `:version` command and the REPL banner
   e. Update the badge line in `README.md` — both the release-tag URL and the `Latest-X.Y.Z` badge label
   f. Run the command `dart pub get` to update dependencies and lockfile
   g. Verify that no stale version string remains:

   ```bash
   git grep -F "<old-version>" -- . ':(exclude)CHANGELOG.md' ':(exclude)pubspec.lock' ':(exclude)bin'
   ```

   Expect no matches. `CHANGELOG.md` and `pubspec.lock` legitimately retain older versions, and `bin/` holds the previous release's binaries, which the `Build Desktop` workflow replaces in step 5. Any other hit is a version location this step is missing — update it, then add it to this list.

2. **Documentation Audit**: Perform a comprehensive audit to ensure `docs/` is in sync with `lib/`.
   a. For each standard library module in `lib/`, verify a corresponding reference page exists in `docs/lang/reference/`
   b. For each function documented in `docs/lang/reference/`, verify it exists and matches the implementation
   c. Check that function signatures, parameters, and return types are accurately documented
   d. Update any outdated or missing documentation

3. **Changelog Generation**: Generate the changelog for this release.
   a. Invoke the `generate-changelog` skill to analyze changes since `main`
   b. Prepend a new version section to `CHANGELOG.md` with the format:

   ```
   ## X.Y.Z - [Codename]

   [Generated changelog content]
   ```

4. **Web Build**: Build the JavaScript binary for web deployment.
   a. Run `scripts/build_web.sh`
   b. Verify the build succeeded with no errors
   c. Confirm that `output/primal.js` was created
   d. If the build fails, report the error and stop

5. **Manual Steps Reminder**: Inform the user of the remaining manual steps:
   - **Run the apocalypse bug review**: Run the `apocalypse-bug-review` skill
   - **Website updates**: Run the skill `sync-sdk` in the website repository
   - **Deploy website**: Deploy the updated website
   - **Git workflow**: Merge the release branch into `main`
   - **Desktop binaries**: Trigger the `Build Desktop` workflow from the Actions tab, then download its three artifacts and commit them to `bin/`
   - **GitHub release**: Create a new GitHub release tagged with the version number
   - **Create new branch**: Create a new release branch for the next version (e.g., `release/next-version`) and push it to the remote repository
