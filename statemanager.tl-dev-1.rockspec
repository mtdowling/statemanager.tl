rockspec_format = "3.0"
package = "statemanager.tl"
version = "dev-1"
source = {
  url = "git+https://github.com/mtdowling/statemanager.tl.git",
  branch = "main",
}
description = {
  summary = "A stack-based game state manager for Lua and typed with Teal",
  detailed = [[
    A stack-based game state manager for Lua and typed with Teal. It was designed
    to work with LÖVE 2D, but it can probably work with other Lua game frameworks.

    Suppose your game has a main game loop, and when you hit the pause button, you
    enter the pause state. When you hit the pause button again, the pause state
    exits and you reenter the main loop state of the game. That's what this
    library can take care of: pausing states, entering states, and exiting states
    using a stack.]],
  homepage = "https://github.com/mtdowling/statemanager.tl",
  license = "MIT <http://opensource.org/licenses/MIT>",
}
dependencies = {
  "lua >= 5.1",
}
test_dependencies = {
  "busted",
  --"busted-tl",
}
build_dependencies = {
  "tl >= 0.24.1",
  "cyan >= 0.4.0",
  "luacheck >= 0.2.0",
}
test = {
  type = "busted",
  flags = {
    "--loaders=teal",
  },
}
build = {
  type = "builtin",
  modules = {
    statemanager = "src/statemanager.lua",
  },
  install = {
    lua = {
      statemanager = "src/statemanager.tl",
    },
  },
}
