return {
  "renerocksai/telekasten.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = "Telekasten",
  keys = {
    { "<leader>;p", "<cmd>Telekasten panel<cr>", desc = "Open panel" },
    { "<leader>;f", "<cmd>Telekasten find_notes<cr>", desc = "Find notes" },
    { "<leader>;d", "<cmd>Telekasten goto_today<cr>", desc = "Today's note" },
    { "<leader>;n", "<cmd>Telekasten new_note<cr>", desc = "New note" },
    { "<leader>;s", "<cmd>Telekasten search_notes<cr>", desc = "Search notes" },
    { "<leader>;T", "<cmd>Telekasten goto_thisweek<cr>", desc = "This week's note" },
    { "gd", "<cmd>Telekasten follow_link<cr>", desc = "Follow link", ft = "markdown" },
    { "<C-Space>", "<cmd>Telekasten toggle_todo<cr>", desc = "Toggle todo", ft = "markdown", mode = { "n", "i" } },
    {
      "<leader>;t",
      function()
        local ticket_id = vim.fn.input "Ticket ID (e.g., PROJ-123): "
        if ticket_id ~= "" then
          local tickets_dir = vim.fn.expand "~/notes/tickets"
          vim.fn.mkdir(tickets_dir, "p")

          local filepath = tickets_dir .. "/" .. ticket_id .. ".md"
          vim.cmd("edit " .. filepath)

          -- If file is new/empty, insert template
          if vim.fn.getfsize(filepath) <= 0 then
            local template_path = vim.fn.expand "~/notes/templates/ticket.md"
            if vim.fn.filereadable(template_path) == 1 then
              vim.cmd("0r " .. template_path)
              -- Replace placeholder with actual ticket ID
              vim.cmd("%s/{{ticket_id}}/" .. ticket_id .. "/g")
              vim.cmd "normal! gg"
            end
          end
        end
      end,
      desc = "New ticket note",
    },
    {
      "<leader>;m",
      function()
        local tomorrow = os.time() + (24 * 60 * 60)
        local date_string = os.date("%Y-%m-%d", tomorrow)

        local dailies_dir = vim.fn.expand "~/notes/daily"
        vim.fn.mkdir(dailies_dir, "p")
        local filepath = dailies_dir .. "/" .. date_string .. ".md"
        vim.cmd("edit " .. filepath)

        -- If file is new/empty, insert template
        if vim.fn.getfsize(filepath) <= 0 then
          local template_path = vim.fn.expand "~/notes/templates/daily.md"
          if vim.fn.filereadable(template_path) == 1 then
            vim.cmd("0r " .. template_path)
            vim.cmd("%s/{{title}}/" .. date_string .. "/g")
            vim.cmd "normal! gg"
          end
        end
      end,
      desc = "Tomorrow's note",
    },
  },
  opts = {
    home = vim.fn.expand "~/notes",
    dailies = vim.fn.expand "~/notes/daily",
    weeklies = vim.fn.expand "~/notes/weekly",
    templates = vim.fn.expand "~/notes/templates",

    template_new_daily = vim.fn.expand "~/notes/templates/daily.md",
    template_new_weekly = vim.fn.expand "~/notes/templates/weekly.md",

    follow_creates_nonexisting = true,
    dailies_create_nonexisting = true,
    weeklies_create_nonexisting = true,
  },
}
