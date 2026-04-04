---
name: prepare-release
description: TODO
---

1. update pubspec version: ask the user for the new version number (e.g. 1.2.3), then update `pubspec.yaml`
2. check if all the content in @docs is up-to-date with the codebase in @lib, and update if needed
3. do the same with @README.md and update it if needed
4. generate changelog by running the skill `changelog` amd updating the file @CHANGELOG.md
5. run the script in `scripts/build-web.sh` to generate the web binary
6. Inform the user to manually:

- update website
  - update version number
  - update JavaScript binary
  - update documentation if needed
- generate the binaries for all desktop platforms
- merge branch into `main`
- generate a GitHub release with the new version number
