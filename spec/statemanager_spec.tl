global describe: function(string, function)
global it: function(string, function)

local StateManager <const> = require("statemanager")

local dynamicCalls: {string} = {}

-- States can be created dynamically too.
local function createState(name: string): StateManager.State
    return StateManager.implementState({
        draw = function(_self: StateManager.State)
            dynamicCalls[#dynamicCalls + 1] = name .. ":draw"
        end,
        pushed = function(_self: StateManager.State)
            dynamicCalls[#dynamicCalls + 1] = name .. ":pushed"
        end,
        popped = function(_self: StateManager.State)
            dynamicCalls[#dynamicCalls + 1] = name .. ":popped"
        end,
        suspended = function(_self: StateManager.State)
            dynamicCalls[#dynamicCalls + 1] = name .. ":suspended"
        end,
        resumed = function(_self: StateManager.State)
            dynamicCalls[#dynamicCalls + 1] = name .. ":resumed"
        end,
        update = function(_self: StateManager.State, _stateManager: StateManager, _dt: number)
            dynamicCalls[#dynamicCalls + 1] = name .. ":update"
        end
    })
end

describe("StateManager", function()
    describe("new", function()
        it("works", function()
            StateManager.new()
        end)
    end)

    describe("push", function()
        it("can push and pop", function()
            local stateManager = StateManager.new()
            stateManager:push(createState("state1"))
            stateManager:draw()
            stateManager:update(1)
            stateManager:push(createState("state2"))
            stateManager:draw()
            stateManager:update(1)
            stateManager:pop()
            stateManager:draw()
            stateManager:update(1)
            stateManager:pop()

            assert(dynamicCalls[1] == "state1:pushed")
            assert(dynamicCalls[2] == "state1:draw")
            assert(dynamicCalls[3] == "state1:update")
            assert(dynamicCalls[4] == "state1:suspended")
            assert(dynamicCalls[5] == "state2:pushed")
            assert(dynamicCalls[6] == "state2:draw")
            assert(dynamicCalls[7] == "state2:update")
            assert(dynamicCalls[8] == "state2:popped")
            assert(dynamicCalls[9] == "state1:resumed")
            assert(dynamicCalls[10] == "state1:draw")
            assert(dynamicCalls[11] == "state1:update")
            assert(dynamicCalls[12] == "state1:popped")
            assert(#dynamicCalls == 12)
        end)

        it("errors when attempting to pop and stack is empty", function()
            local stateManager = StateManager.new()
            assert(pcall(function() stateManager:pop() end) == false)
        end)

        it("allows states to pop themselves", function()
            local stateManager = StateManager.new()
            stateManager:push(StateManager.implementState({
                update = function(_self: StateManager.State, sm: StateManager, _dt: number)
                    sm:pop()
                end
            }))

            assert(not stateManager:isEmpty())

            stateManager:update(1)

            assert(stateManager:isEmpty())
        end)
    end)
end)

