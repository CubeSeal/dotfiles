return {
  "olimorris/codecompanion.nvim",
  config = true,
  keys={ '<Leader>', '<LocalLeader>' },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
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
        provider = "telescope", -- default|ttelescopeelescope|mini_pick
        opts = {
          show_default_actions = true, -- Show the default actions in the action palette?
          show_default_prompt_library = true, -- Show the default prompt library in the action palette?
        },
      },
    },
  } 

  vim.keymap.set({ "n", "v" }, "<Leader>a", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
  vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
  vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

  vim.cmd([[cab cc CodeCompanion]])
  end
}
