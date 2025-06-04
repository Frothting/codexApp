# Repo Guidelines

- When you implement a feature listed in `todo.md`, update the checklist by changing `[ ]` to `[x]` for that item.
- After making changes, scan all code for variables that use reserved keywords from the language in question (Lua for `.p8` files and Bash for `.sh` scripts). Rename any such variables before committing.
- Run the provided helper scripts before committing:
  - `./scripts/lint.sh` to check for trailing whitespace in `.p8` files.
  - `./scripts/token_count.sh` to report token counts.
