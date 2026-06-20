-- codecompanion.nvim (lze spec). plenary + treesitter are eager, so the default
-- loader (packadd of the spec name) is all that's needed.
return {
  "codecompanion.nvim",
  cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionChat" },
  keys = {
    { "<Leader>a", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion actions" },
    { "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion chat toggle" },
    { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "CodeCompanion chat add" },
  },
  after = function()
    require("codecompanion").setup{
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              name = "Gemini 2.5",
              scheme = {
                model = {
                  default = "gemini-2.5-pro-exp-03-25",
                }
              },
              env = {
                api_key = "cmd:cat ~/gemini.apikey"
              },
            })
          end,
        }
      },
      strategies = {
        chat = {
          adapter = "gemini",
        },
        inline = {
          adapter = "gemini",
        },
        cmd = {
          adapter = "gemini",
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
          prompt = "Prompt ", -- Prompt used for interactive LLM calls
          provider = "telescope", -- default|telescope|mini_pick
          opts = {
            show_default_actions = true, -- Show the default actions in the action palette?
            show_default_prompt_library = true, -- Show the default prompt library in the action palette?
          },
        },
      },
    }

    vim.cmd([[cab cc CodeCompanion]])
  end,
}
