







local StateManager = {}


























































local STATEMANAGER_MT = {
   __index = StateManager,
}

local STATE_MT = {
   __index = {
      draw = function(_self) end,
      pushed = function(_self) end,
      popped = function(_self) end,
      suspended = function(_self) end,
      resumed = function(_self) end,
      update = function(_self, _stateManager, _dt) end,
   },
}

function StateManager.implementState(state)
   return setmetatable(state, STATE_MT)
end

function StateManager.new()
   return setmetatable({ _stack = {} }, STATEMANAGER_MT)
end

function StateManager:isEmpty()
   return #self._stack == 0
end

function StateManager:push(state)
   if #self._stack > 0 then
      self._stack[#self._stack]:suspended()
   end
   self._stack[#self._stack + 1] = state
   state:pushed()
end

function StateManager:pop()
   assert(#self._stack > 0, "State stack is empty")
   local current = self._stack[#self._stack]
   self._stack[#self._stack] = nil
   current:popped()
   if #self._stack > 0 then
      self._stack[#self._stack]:resumed()
   end
   return current
end

function StateManager:update(dt)
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
