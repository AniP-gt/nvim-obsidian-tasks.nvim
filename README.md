# nvim-obsidian-tasks.nvim

A tiny Neovim plugin that mirrors Obsidian Tasks completion formatting. It converts open tasks to completed form with a date stamp, but only inside directories that contain a `.obsidian` folder. Markdown buffers only; normal and visual mode support.

## Features
- Convert `- [ ] task` to `- [x] YYYY-MM-DD task` with a completion marker that reuses Obsidian Tasks’ emoji conventions.
- Respects existing text (tags, emoji, punctuation) after the checkbox.
- Provides commands to stamp date metadata (`:TasksSetDueDate`, `:TasksSetScheduledDate`, `:TasksSetStartDate`, `:TasksSetCreatedDate`, `:TasksSetDoneDate`, `:TasksSetCancelledDate`) or adjust priorities (`:TasksSetPriority [level]`).
- Toggle completion with `:TasksToggle`, which adds a `✅ <date>` when marking done and removes that stamp when reopening the task.
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
    config = function()
      require("nvim-tasks").setup()
      vim.keymap.set("n", "<leader>x", "<cmd>TasksComplete<CR>", { desc = "Complete task on current line" })
      vim.keymap.set("v", "<leader>x", "'<,'>TasksComplete<CR>", { desc = "Complete tasks in selection" })
    end,
  },
}
```

## Usage
- Open a Markdown file inside a directory that has `.obsidian` somewhere above it.
- Run `:TasksComplete` to convert open tasks on the current line or (when you provide a range like `:'<,'>` or `:10,20`) across many lines.
- Select lines visually and execute `:'<,'>TasksComplete` (or your preferred keymap) to batch-complete tasks, including non-task lines in the selection.
- Use the new commands to decorate tasks with metadata:
  - `:TasksSetDueDate [YYYY-MM-DD]`
  - `:TasksSetScheduledDate [YYYY-MM-DD]`
  - `:TasksSetStartDate [YYYY-MM-DD]`
  - `:TasksSetCreatedDate [YYYY-MM-DD]`
  - `:TasksSetDoneDate [YYYY-MM-DD]`
  - `:TasksSetCancelledDate [YYYY-MM-DD]`
  - `:TasksSetPriority [highest|high|medium|normal|low|lowest]`
  - Toggle completion with `:TasksToggle`, which flips a task between open and done while adding/removing the `✅ <date>` stamp.
- Outside a vault or in non-Markdown buffers, the command is ignored with a notice.


- If no open tasks are found, nothing is changed and a notice is shown.

## Configuration
Call `require("nvim-tasks").setup()` once during your plugin configuration to register `:TasksComplete`. At the moment there are no additional options, but the command registration is idempotent, so you can safely call `setup()` even when the plugin is reloaded.

## Keymaps
This plugin leaves keybindings to you. Here is how you can replicate the previous `<leader>x` behavior:

```lua
vim.keymap.set("n", "<leader>x", "<cmd>TasksComplete<CR>", { desc = "Complete task on current line" })
vim.keymap.set("v", "<leader>x", "'<,'>TasksComplete<CR>", { desc = "Complete tasks in selection" })
```

You can choose other keys or modes if you prefer.

## Behavior Details
- Regex for open tasks: `^%s*%- %[ %] .+`
- Completion format: `- [x] YYYY-MM-DD <original text>`; indentation is preserved.
- Toggle commands share the same task detection and keep the ✅ date stamp aligned with the `[x]` checkbox state.
- Already completed lines (`- [x] ...`) are left untouched unless you reopen them with `:TasksToggle`.
- All changes in one call can be undone with a single undo.

## Limitations
- Markdown only; other filetypes are ignored.
- No recurring task handling or Dataview integration.
- Date uses local system time.

## Development
- Core files: `lua/nvim-tasks/complete.lua`, `meta.lua`, `symbols.lua`, `vault.lua`. Command definitions live under `lua/nvim-tasks/commands/` and shared helpers under `lua/nvim-tasks/utils/`.
- Tests are not provided; manual checks follow the user stories in `specs/001-task-complete-date/spec.md`.
