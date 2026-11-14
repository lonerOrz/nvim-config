-- lua/plugins/git.lua
return {
	-- Neogit — 仓库级 Git 操作界面
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"folke/snacks.nvim",
			"ibhagwan/fzf-lua",
			-- "m00qek/baleia.nvim", -- log_pager 的 ANSI 颜色渲染，需要安装 delta
		},
		cmd = { "Neogit", "NeogitLog" },
		keys = {
			{ "<leader>gg", "<cmd>Neogit kind=split_below<cr>", desc = "Git Status (bottom)" },
			{ "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git Commit popup" },
			{ "<leader>gL", "<cmd>Neogit log<cr>", desc = "Git Log popup" },
			{ "<leader>gH", "<cmd>NeogitLog<cr>", desc = "Git history for current file" },
		},
		opts = {
			-- 界面
			kind = "split_below",
			-- disable_hint = true, -- 隐藏顶部提示行
			disable_context_highlighting = false, -- 保留光标所在区块高亮
			disable_signs = false, -- 保留 >/v 折叠符号
			disable_commit_confirmation = false, -- 保留内置提交确认

			-- Diff
			treesitter_diff_highlight = true,
			word_diff_highlight = true,

			-- Log / Graph
			graph_style = "unicode", -- 需要 Nerd Font
			-- log_pager = { "delta", "--width", "117" }, -- 需 baleia.nvim
			status = { show_head_commit_hash = true },
			log_view = { kind = "split_below" }, -- 部分版本可能回退到 tab

			-- 选择器集成
			-- 优先级：telescope > fzf_lua > snacks > mini_pick
			integrations = {
				fzf_lua = true,
				snacks = false,
				telescope = false,
				mini_pick = false,
			},

			-- 提交编辑器
			commit_editor = {
				kind = "split",
				show_staged_diff = true,
				staged_diff_split_kind = "split",
				spell_check = true,
			},

			-- 状态区块默认折叠
			sections = {
				untracked = { folded = false, hidden = false },
				unstaged = { folded = false, hidden = false },
				staged = { folded = false, hidden = false },
				stashes = { folded = true, hidden = false },
				recent = { folded = true, hidden = false },
			},

			use_default_keymaps = true,
		},
	},

	-- Gitsigns — 缓冲区级 hunk 操作与 blame
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			current_line_blame = true,
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "▎" },
				topdelete = { text = "▔" },
				changedelete = { text = "▎" },
				untracked = { text = "┆" },
			},
			on_attach = function(buffer)
				local gs = require("gitsigns")
				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

				-- Hunk 导航
				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gs.nav_hunk("next")
					end
				end, "Next Git Hunk")

				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gs.nav_hunk("prev")
					end
				end, "Prev Git Hunk")

				-- 常用操作
				map("n", "<leader>gh", gs.preview_hunk_inline, "Preview Hunk Inline")
				map("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, "Blame Line")
				map("n", "<leader>gw", gs.toggle_word_diff, "Toggle Inline Word Diff")
			end,
		},
	},
}
