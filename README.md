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
{
  "harlamenko/ng-generate.nvim",
  dependencies = {
    "nvim-neo-tree/neo-tree.nvim",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("ng-generate").setup()
  end
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

## ⚙️ Configuration

By default, `ng-generate.nvim` maps `n` in Neo-tree’s window to open the popup.

You can remap it by calling `setup()` with options:

```lua
require("ng-generate").setup({
  keymap = "g", -- change keybinding from "n" to "g"
})
```

---

## 🛠 Manual setup without auto-mapping

If you don’t want the plugin to overwrite your `n` mapping in Neo-tree,
you can skip `setup()` and bind the command yourself:

```lua
-- In your Neo-tree config:
window = {
  mappings = {
    ["<leader>ng"] = require("ng-generate").run,
  },
}
```

