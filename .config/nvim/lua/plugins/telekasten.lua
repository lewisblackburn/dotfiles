return {
  "renerocksai/telekasten.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = "Telekasten",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<leader>;"] = { name = "Notes" },
          },
        },
      },
    },
  },
  keys = {
    { "<leader>;p", "<cmd>Telekasten panel<cr>", desc = "Open panel" },
    { "<leader>;f", "<cmd>Telekasten find_notes<cr>", desc = "Find notes" },
    { "<leader>;d", "<cmd>Telekasten goto_today<cr>", desc = "Today's note" },
    { "<leader>;n", "<cmd>Telekasten new_note<cr>", desc = "New note" },
    { "<leader>;s", "<cmd>Telekasten search_notes<cr>", desc = "Search notes" },
    { "<leader>;T", "<cmd>Telekasten goto_thisweek<cr>", desc = "This week's note" },
    { "gd", "<cmd>Telekasten follow_link<cr>", desc = "Follow link", ft = "markdown" },
    { "<C-Space>", "<cmd>Telekasten toggle_todo<cr>", desc = "Toggle todo", ft = "markdown", mode = { "n", "i" } },
    { "<leader>;i", "<cmd>Telekasten insert_img_link<cr>", desc = "Insert image link", ft = "markdown" },
    { "<leader>;I", "<cmd>Telekasten paste_img_and_link<cr>", desc = "Paste image", ft = "markdown" },
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
        local pickers = require "telescope.pickers"
        local finders = require "telescope.finders"
        local actions = require "telescope.actions"
        local action_state = require "telescope.actions.state"
        local conf = require("telescope.config").values

        local dates = {}
        local today = os.time()
        for i = 1, 7 do
          local t = today + (i * 86400)
          table.insert(dates, { display = os.date("%Y-%m-%d (%A)", t), value = os.date("%Y-%m-%d", t) })
        end

        pickers
          .new({}, {
            prompt_title = "Pick Date",
            finder = finders.new_table {
              results = dates,
              entry_maker = function(entry)
                return { value = entry.value, display = entry.display, ordinal = entry.display }
              end,
            },
            sorter = conf.generic_sorter {},
            attach_mappings = function(bufnr)
              actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(bufnr)
                local dailies_dir = vim.fn.expand "~/notes/daily"
                vim.fn.mkdir(dailies_dir, "p")
                local filepath = dailies_dir .. "/" .. selection.value .. ".md"
                vim.cmd("edit " .. filepath)
                if vim.fn.getfsize(filepath) <= 0 then
                  local template_path = vim.fn.expand "~/notes/templates/daily.md"
                  if vim.fn.filereadable(template_path) == 1 then
                    vim.cmd("0r " .. template_path)
                    vim.cmd("%s/{{title}}/" .. selection.value .. "/g")
                    vim.cmd "normal! gg"
                  end
                end
              end)
              return true
            end,
          })
          :find()
      end,
      desc = "Pick date note",
    },
    {
      "<leader>;w",
      function()
        require("telescope.builtin").live_grep {
          prompt_title = "All TODOs",
          search_dirs = { vim.fn.expand "~/notes" },
          default_text = "- \\[ \\] ",
        }
      end,
      desc = "Find all TODOs",
    },
    {
      "<leader>;q",
      function()
        local todo = vim.fn.input "TODO: "
        if todo == "" then return end

        local today = vim.fn.expand("~/notes/daily/" .. os.date "%Y-%m-%d" .. ".md")
        local file = io.open(today, "r")

        if not file then
          vim.notify("❌ Create today's note first", vim.log.levels.ERROR)
          return
        end

        local lines = {}
        local tasks_line = nil

        for line in file:lines() do
          table.insert(lines, line)
          if not tasks_line and line:match "^## Tasks" then tasks_line = #lines end
        end
        file:close()

        if not tasks_line then
          vim.notify("❌ No Tasks section found", vim.log.levels.ERROR)
          return
        end

        -- Insert blank line after header if not present, then TODO
        if lines[tasks_line + 1] ~= "" then table.insert(lines, tasks_line + 1, "") end
        table.insert(lines, tasks_line + 2, "- [ ] " .. todo)

        file = io.open(today, "w")
        for _, line in ipairs(lines) do
          file:write(line .. "\n")
        end
        file:close()

        vim.notify("✅ Added", vim.log.levels.INFO)
      end,
      desc = "Quick TODO",
    },
  },
  opts = {
    home = vim.fn.expand "~/notes",
    dailies = vim.fn.expand "~/notes/daily",
    weeklies = vim.fn.expand "~/notes/weekly",
    templates = vim.fn.expand "~/notes/templates",
    image_subdir = "images",

    template_new_daily = vim.fn.expand "~/notes/templates/daily.md",
    template_new_note = vim.fn.expand "~/notes/templates/note.md",
    template_new_weekly = vim.fn.expand "~/notes/templates/weekly.md",

    follow_creates_nonexisting = true,
    dailies_create_nonexisting = true,
    weeklies_create_nonexisting = true,
  },
}
