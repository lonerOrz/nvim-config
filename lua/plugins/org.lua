return {
    "xheisenbugx/org.nvim",
    ft = "org",
    opts = {
        ui = {
            indent_mode     = true,
            startup_folded  = "overview",
        },
        export = {
            open_after_export = true,
        },
    },
    keys = {
        -- <leader>om: export current org buffer to Markdown and open in browser
        {
            "<leader>om",
            function()
                local src = vim.api.nvim_buf_get_name(0)
                if src == "" then
                    vim.notify("No file saved", vim.log.levels.WARN)
                    return
                end
                local base = src:gsub("%.org$", "") .. ".md"
                require("org.export").export("md", { output = base, open = true })
            end,
            desc = "org: export to Markdown and open",
            silent = true,
        },
    },
}
