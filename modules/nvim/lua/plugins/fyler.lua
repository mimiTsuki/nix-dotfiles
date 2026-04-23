return {
  "A7Lavinraj/fyler.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  keys = {
    { "<leader>e", function() require('fyler').open({ kind = "split_left_most" }) end, desc = "Open fyler View" }
  },
  branch = "stable",  -- Use stable branch for production
  lazy = false, -- Necessary for `default_explorer` to work properly
  opts = {}
}
