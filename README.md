# nvim-obsidian-tasks.nvim

A tiny Neovim plugin that mirrors Obsidian Tasks completion formatting. It converts open tasks to completed form with a date stamp, but only inside directories that contain a `.obsidian` folder. Markdown buffers only; normal and visual mode support.

## Features
- Convert `- [ ] task` to `- [x] YYYY-MM-DD task` with a completion marker.
- Respects existing text (tags, emoji, punctuation) after the checkbox.
- Normal and visual mode keymaps on `<leader>x`.
- Guardrails: no edits outside an Obsidian vault or in non-Markdown buffers; already completed tasks are skipped.
- Single undo step for each invocation (including multi-line visual changes).

## Requirements
- Neovim 0.9+
- A workspace that has `.obsidian/` in the current directory or a parent directory.

## Installation (Lazy.nvim)
```lua
return {
  {
    "AniP-gt/nvim-obsidian-tasks.nvim",
    lazy = false, -- enable immediately; change to an event if you prefer lazy loading
    keys = {
      { "<leader>x", mode = "n", desc = "Complete task (current line)" },
      { "<leader>x", mode = "v", desc = "Complete tasks in selection" },
    },
    config = function()
      require("nvim-tasks").setup()
    end,
  },
}
```

## Usage
- Open a Markdown file inside a directory that has `.obsidian` somewhere above it.
- Normal mode: place the cursor on an open task line `- [ ] ...` and press `<leader>x`.
- Visual mode: select lines (can include non-task lines) and press `<leader>x`.
- Outside a vault or in non-Markdown buffers, the command is ignored with a notice.
- If no open tasks are found, nothing is changed and a notice is shown.

## Behavior Details
- Regex for open tasks: `^%s*%- %[ %] .+`
- Completion format: `- [x] YYYY-MM-DD <original text>`; indentation is preserved.
- Already completed lines (`- [x] ...`) are left untouched.
- All changes in one call can be undone with a single undo.

## Limitations
- Markdown only; other filetypes are ignored.
- No recurring task handling or Dataview integration.
- Date uses local system time.

## Development
- Core files: `lua/nvim-tasks/complete.lua`, `vault.lua`, `keymaps.lua`, `init.lua`; entrypoint: `plugin/nvim-tasks.lua`.
- Tests are not provided; manual checks follow the user stories in `specs/001-task-complete-date/spec.md`.
