# ng-generate.nvim

Neovim plugin that adds a handy popup menu for running `ng generate` commands in Angular projects.

https://github.com/user-attachments/assets/e279fcba-ffdc-4c93-9724-aa0005e77075


---

## ✨ Features

- Seamless integration with [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
- Popup menu for all `ng generate` commands
- Automatically detects path relative to `src/app`
- Supports additional command-line options
- Works with `npx ng g ...` out of the box
- Automatically refreshes Neo-tree after generation

---

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- In your Neo-tree config (e.g. lua/plugins/neo-tree.lua)
{
  { "harlamenko/ng-generate.nvim", dependencies = { "MunifTanjim/nui.nvim" } }, -- add this line
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      local ng_generate = require("ng-generate")
      opts = ng_generate.extend_config(vim.tbl_deep_extend("force", opts, {
        -- your options here
      }))
      return opts
    end,
  },
}
```

---

## 🚀 Usage

1. Open Neo-tree (e.g., `<space>e` or your own mapping)
2. Navigate to the desired directory inside `src/app`
3. Press `n`
4. Press symbol the desired Angular entity or place cursor on it and press `Enter` to generate (component, service, module, etc.)
5. Enter a name and any additional options

---

## 🛠 Manual setup without auto-mapping

If you don’t want the plugin to overwrite your `n` mapping in Neo-tree,
you can bind the command yourself:

```lua
-- In your Neo-tree config:
{
  { "harlamenko/ng-generate.nvim", dependencies = { "MunifTanjim/nui.nvim" } }, 
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          -- ...
          ["<leader>ng"] = function(state) require("ng-generate").run(state) end,
        },
      }
    },
  },
}
```

