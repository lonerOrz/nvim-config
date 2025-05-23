return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    null_ls.setup({
      sources = {
        -- nix
        null_ls.builtins.formatting.alejandra,
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          -- 自动格式化
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })

          -- 手动快捷键
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ bufnr = bufnr })
          end, { buffer = bufnr, desc = "Format buffer with LSP" })
        end
      end,
    })
  end,
}
