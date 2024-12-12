# statemanager.tl

A stack-based game state manager for Lua and typed with Teal. It was designed
to work with LÖVE 2D, but it can probably work with other Lua game frameworks.

## What does this do?

Suppose your game has a main game loop, and when you hit the pause button, you
enter the pause state. When you hit the pause button again, the pause state
exits and you reenter the main loop state of the game. That's what this
library can take care of: pausing states, entering states, and exiting states
using a stack.

## Usage

First, require the module:

```lua
local StateManager = require("statemanager")
```

### Creating a StateManager

A `StateManager` is used to push and pop game states.

```lua
local stateManager = StateManager.new()
```

### Creating a State

States are used to implement the game logic, draw the game, and call specific
lifecycle methods when states are pushed and popped.

```lua
-- Define a state.
local record PlayState is StateManager.State
    -- Put any state-specific properties here.
    playerData: table
end

-- Implement the state methods you need.
function PlayState:update(stateManager: StateManager, dt: number)
    if love.keyboard.isDown("enter") then
        -- push the pause state if the enter button is pressed.
        stateManager:push(PauseState.new())
    end
    if love.keyboard.isDown("escape") then
        -- exit the game if the escape button is pressed.
        stateManager:pop()
    end
end

-- Instead of manually implementing each method, you can inherit the
-- default method implementations using `StateManager.implementState`.
StateManager.implementState(PlayState)

--- You can make constructor methods for your state to setup metatables.
function PlayState.new(): PlayState
    return setmetatable({playerData = {}}, { __index = PlayState })
end

-- You can make any number of states, and each can have their own properties
-- and methods.
local record PauseState is StateManager.State end

function PauseState:update(stateManager: StateManager, dt: number)
    if love.keyboard.isDown("enter") then
        -- If the pause button is hit again, then exit the pause state.
        stateManager:pop()
    end
end

StateManager.implementState(PauseState)

function PauseState.new(pauseButton: string): PauseState
    return setmetatable({}, { __index = PauseState })
end
```

### Pushing and popping states

```lua
-- Just to demonstrate how to use the state manager in a loop.
stateManager:push(PlayState.new())
while not stateManager:isEmpty() do
    stateManager:update(dt)
    stateManager:draw()
end
```

### State lifecycle methods

* `pushed(self: State)`: Called when the state is pushed onto the stack.
* `popped(self: State)`: Called when the state is popped off the stack.
* `update(self: State, stateManager: StateManager, dt: number)`: Called
  periodically to update the state.
* `draw(self: State)`: Called to draw the state.
* `resumed(self: State)`: Called when the state is resumed. This happens when
  a state was popped, so the state below it in the stack is now at the top of
  the stack. This method is called after the previous state was popped. This
  method can be used to do things like resume music, reapply a graphical effect,
  etc.
* `suspended(self: State)`: Called when the state is suspended. This happens
  when a state is currently active, but another state has been pushed on top of
  it. This method is called just before the other state is pushed. It can be
  used to do things like remove graphical effects, pause music, etc.

### Creating states dynamically

The `StateManager.implementState` method can be used to implement States
dynamically. Any methods passed to the function are used with the created
state, and any methods that are not passed are implemented using the default
state methods that do nothing.

```lua
local dynamicState = StateManager.implementState({
    update = function(self: State, stateManager: StateManager, dt: number)
        print("Dynamic state update: " .. dt)
    end,
})
```

## Installation

**Copy and paste**:

Copy and paste `src/statemanager.tl` and/or `src/statemanager.lua` into your
project.

**Or use LuaRocks**:

```sh
luarocks install statemanager.tl
```

## Contributing

The source code is written in Teal and compiled to Lua. The updated and
compiled Lua must be part of every code change to the Teal source code.
You can compile Teal to Lua and run tests using:

```sh
make
```

## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See LICENSE for details.
