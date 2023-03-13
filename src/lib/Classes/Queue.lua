--[[
	Queue class
	Provides simple queue functionality in the form of an object
--]]

local Queue = {}

---------------------
-- Roblox Services --
---------------------
local HttpService = game:GetService("HttpService")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API Methods
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : new
-- @Description : Creates a new queue object
-- @Return : Queue object
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Queue.new()
	local NewQueue = {
		_Queue = {},
		_IsExecuting = false,
	}

	setmetatable(NewQueue, {
		__index = Queue
	})

	return NewQueue
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : AddAction
-- @Description : Adds an action to the queue
-- @Params : function "Action" - The action to add to the queue
--           OPTIONAL function "Callback" - The callback to call when the action is complete
-- @Return : string "ActionID" - The ID of the action
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Queue:AddAction(Action, Callback)
	local ActionID = HttpService:GenerateGUID(false)

	table.insert(self._Queue, {
		Action = Action,
		Callback = Callback,
		ActionID = ActionID
	})

	return ActionID
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Pop
-- @Description : Removes the first action from the queue
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Queue:Pop()
	if #self._Queue > 0 then
		table.remove(self._Queue, 1)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetSize
-- @Description : Returns the size of the queue
-- @Return : int "Size" - The size of the queue
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Queue:GetSize()
	return #self._Queue
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Execute
-- @Description : Executes all actions in the queue
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Queue:Execute()
	if not self:IsExecuting() then
		self._IsExecuting = true

		while true do
			if #self._Queue == 0 then
				break
			end

			local ActionInQueue = self._Queue[1]
			local Action = ActionInQueue.Action
			local Callback = ActionInQueue.Callback

			Action(ActionInQueue.ActionID)
			self:Pop()

			if Callback ~= nil then
				Callback(ActionInQueue.ActionID)
			end
		end

		self._IsExecuting = false
	else
		error("Queue is already executing!")
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : IsExecuting
-- @Description : Returns whether or not the queue is executing
-- @Return : bool "IsExecuting" - Whether or not the queue is executing
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Queue:IsExecuting()
	return self._IsExecuting
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Destroy
-- @Description : Destroys the queue
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Queue:Destroy()
	self._Queue = {}
end

return Queue