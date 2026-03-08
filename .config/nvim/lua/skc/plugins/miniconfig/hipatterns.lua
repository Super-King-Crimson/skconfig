local hipatterns = require("mini.hipatterns")
local hi_words = require("mini.extra").gen_highlighter.words
hipatterns.setup({
  highlighters = {
    -- Highlight a fixed set of common words. Will be highlighted in any place,
    -- not like "only in comments".
    fixme = hi_words({ "FIXME" }, "MiniHipatternsFixme"),
    hack = hi_words({ "HACK" }, "MiniHipatternsHack"),
    todo = hi_words({ "TODO" }, "MiniHipatternsTodo"),
    note = hi_words({ "NOTE" }, "MiniHipatternsNote"),

    -- Highlight hex color string (#aabbcc) with that color as a background
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
