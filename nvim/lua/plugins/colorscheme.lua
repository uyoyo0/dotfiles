return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night",
    transparent = false,
    terminal_colors = true,
    styles = {
      sidebars = "dark",
      floats = "dark",
    },
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd.colorscheme("tokyonight-night")

    -- Toggle between dark (night) and light (day)
    vim.api.nvim_create_user_command("ToggleTheme", function()
      if vim.g.colors_name == "tokyonight-day" then
        vim.cmd.colorscheme("tokyonight-night")
      else
        vim.cmd.colorscheme("tokyonight-day")
      end
    end, { desc = "Toggle light/dark theme" })
    vim.keymap.set("n", "<leader>ut", "<cmd>ToggleTheme<cr>", { desc = "Toggle light/dark theme" })
  end,
}
