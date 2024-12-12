-- statemanager.tl
--
-- Copyright (c) 2024, Michael Dowling
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.

--- Manages a stack of game states.
local record StateManager
    --- A state manager state.
    interface State
        --- Called each frame of the game loop to update the current state.
        --- @param dt Time since the last update.
        --- @param StateManager The state manager. The state can use this to push and pop states, including itself.
        update: function(self: State, stateManager: StateManager, dt: number)

        --- Draws the current state.
        draw: function(self: State)

        --- Called when the state is pushed onto the top of the stack, but before update is called.
        pushed: function(self: State)

        --- Called when the state is popped and being left, but before the next state is resumed.
        --- This can be used to clean up state resources, stop sounds, etc.
        popped: function(self: State)

        --- Called when a state is suspended because another state was pushed on top of it.
        --- This is called before the next state is pushed. It can be used to pause sounds, remove effects, etc.
        suspended: function(self: State)

        --- Called when a state is now the top of the stack because another state was popped.
        --- For example, this can be used to reapply graphical effects, play sounds, etc.
        resumed: function(self: State)
    end

    --- Create a new StateManager.
    --- @return the StateManager.
    new: function(): StateManager

    --- Check if the state manager is empty.
    --- @return true if the state manager is empty.
    isEmpty: function(self: StateManager): boolean

    --- Updates the state manager.
    --- @param dt Time since the last update.
    update: function(self: StateManager, dt: number)

    --- Draw the current state.
    draw: function(self: StateManager)

    --- Push a state to the top of the stack and give it focus.
    --- @param state State to push.
    push: function(self: StateManager, State)

    --- Pop a state from the stack and return it.
    --- @return the popped state.
    pop: function(self: StateManager): State

    --- Update the given State implementation to inherit the default interface methods of State.
    --- @param state State to implement.
    implementState: function<S is State>(state: S): S

    _stack: {State}
end

local type State = StateManager.State

local STATEMANAGER_MT <const>: metatable<StateManager> = {
    __index = StateManager
}

local STATE_MT <const>: metatable<State> = {
    __index = {
        draw = function(_self: State) end,
        pushed = function(_self: State) end,
        popped = function(_self: State) end,
        suspended = function(_self: State) end,
        resumed = function(_self: State) end,
        update = function(_self: State, _stateManager: StateManager, _dt: number) end
    }
}

function StateManager.implementState<S is State>(state: S): S
    return setmetatable(state, STATE_MT as metatable<S>)
end

function StateManager.new(): StateManager
    return setmetatable({_stack = {}}, STATEMANAGER_MT)
end

function StateManager:isEmpty(): boolean
    return #self._stack == 0
end

function StateManager:push(state: State)
    if #self._stack > 0 then
        self._stack[#self._stack]:suspended()
    end
    self._stack[#self._stack + 1] = state
    state:pushed()
end

function StateManager:pop(): State
    assert(#self._stack > 0, "State stack is empty")
    local current = self._stack[#self._stack]
    self._stack[#self._stack] = nil
    current:popped()
    if #self._stack > 0 then
        self._stack[#self._stack]:resumed()
    end
    return current
end

function StateManager:update(dt: number)
    if #self._stack > 0 then
        self._stack[#self._stack]:update(self, dt)
    end
end

function StateManager:draw()
    if #self._stack > 0 then
        self._stack[#self._stack]:draw()
    end
end

return StateManager

