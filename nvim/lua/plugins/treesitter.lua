return {
  "nvim-treesitter/nvim-treesitter",
  -- The v1.0 API (`require("nvim-treesitter").install`) only exists on `main`.
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "bash", "c", "cpp", "json", "lua", "markdown", "markdown_inline",
      "python", "regex", "toml", "vim", "vimdoc", "yaml",
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        pcall(vim.treesitter.start)

        local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
        if vim.treesitter.query.get(lang, "indents") then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
