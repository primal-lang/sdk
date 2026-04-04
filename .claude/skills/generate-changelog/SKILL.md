---
name: generate-changelog
description: Generates a changelog by comparing the current branch against main, analyzing code changes to categorize them as Added, Fixed, Changed, Deprecated, Removed, or Security.
---

1. **When invoked**: Use the Task tool to spawn a changelog subagent with the full instructions below. The subagent should:
   a. Run `git diff main...HEAD --stat` to get an overview of changed files
   b. Run `git diff main...HEAD` to get the full diff
   c. If there are no changes, report "No changes to document" and stop
   d. Proceed with the Analysis Phase

2. **Analysis Phase**: Analyze the code diff (ignore commit messages, they are not useful in this project). For each logical change, determine which category it belongs to:
   - **Added**: New features, new functions, new capabilities
   - **Fixed**: Bug fixes, error corrections
   - **Changed**: Modifications to existing functionality
   - **Deprecated**: Features marked for future removal
   - **Removed**: Deleted features or functionality
   - **Security**: Security-related fixes or improvements

3. **Grouping**: Group changes by area (e.g., Language, Standard library, Runtime, CLI, etc.) based on what makes sense for the changes. Within each area, list items under the appropriate category (Added, Fixed, Changed, etc.).

4. **Output Format**: Present the changelog following this format:
   ```
   ### [Area Name]

   #### Added
   * Description of new feature
       - Sub-item if needed

   #### Fixed
   * Description of fix

   [... other non-empty categories ...]
   ```

   Rules:
   - Omit categories that have no items
   - Omit areas that have no items
   - Group related changes into single bullet points
   - Use sub-items (indented with 4 spaces and `-`) for listing multiple related items
   - Be concise but descriptive
   - Focus on user-facing changes, not internal implementation details

5. **Summary**: End with a brief one-line summary of the overall changes (e.g., "Added X new features, fixed Y bugs across Z areas").
