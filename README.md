# git-mob.nvim

Neovim plugin for [git-mob](https://github.com/rkotze/git-mob) — manage co-authors in commit messages when pair or mob programming.

## Requirements

- Neovim >= 0.10
- [git-mob](https://github.com/rkotze/git-mob) CLI installed (`npm install -g git-mob`)

## Installation

**lazy.nvim**

```lua
{
  "rcasia/git-mob.nvim",
  keys = {
    { "<leader>gm", function() require("git-mob").ui.select_coauthors() end, desc = "Select co-authors" },
    { "<leader>gs", function() require("git-mob").api.go_solo() end,         desc = "Go solo" },
  },
}
```

## API

```lua
local git_mob = require("git-mob")

-- Current mob as { name, email }[]
git_mob.api.get_current_mob()

-- All co-authors as { initials, name, email, active }[]
git_mob.api.get_coauthors()

-- Set mob by initials (empty list goes solo)
git_mob.api.set_current_mobbers({ "aa", "bb" })

-- Toggle a single co-author on/off
git_mob.api.toggle_coauthor("aa")

-- Clear all co-authors
git_mob.api.go_solo()

-- Open the interactive selector
git_mob.ui.select_coauthors()
```

## Development

```bash
make test        # run tests once
make test-watch  # re-run on file changes
```
