---
name: prepare-release
description: Prepares the next SDK release by updating version, syncing documentation, generating changelog, and building the web binary.
---

1. **Version Update**: Prompt the user for the new version number.
   a. Validate that the input follows semver format (`X.Y.Z` where X, Y, Z are non-negative integers)
   b. If invalid, explain the expected format and prompt again
   c. Update the `version` field in `pubspec.yaml`
   d. Run the command `dart pub get` to update dependencies and lockfile

2. **Documentation Audit**: Perform a comprehensive audit to ensure `docs/` is in sync with `lib/`.
   a. For each standard library module in `lib/`, verify a corresponding reference page exists in `docs/reference/`
   b. For each function documented in `docs/reference/`, verify it exists and matches the implementation
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
   a. Run `scripts/build-web.sh`
   b. Verify the build succeeded with no errors
   c. Confirm that `output/primal.js` was created
   d. If the build fails, report the error and stop

5. **Manual Steps Reminder**: Inform the user of the remaining manual steps:
   - **Website updates**:
     - Update version number on the website
     - Deploy the new `output/primal.js` binary
     - Update documentation pages if needed
   - **Desktop binaries**: Generate binaries for all desktop platforms (macOS, Windows, Linux)
   - **Git workflow**: Merge the release branch into `main`
   - **GitHub release**: Create a new GitHub release tagged with the version number, attaching all binaries
