vim.api.nvim_create_user_command("QA", "qa!", { desc = "Because exclamation points are hard to hit." })

require("skc.commands.autosession")
require("skc.commands.write_output_to_register")

require("skc.commands.autocommands")
