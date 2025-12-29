InputDeviceManager = require "lib.cuddle2d.input.inputdevicemanager"
require "lib.cuddle2d.utils.callbacks"
require "lib.cuddle2d.input.inputactions"

PlayerInputManager = {}

setmetatable(PlayerInputManager, PlayerInputManager)
PlayerInputManager.__index = PlayerInputManager

function PlayerInputManager:__call(inputDevice)
	local newInstance = setmetatable({}, self)
	newInstance:new(inputDevice)
	return newInstance
end

function PlayerInputManager:__tostring()
	return "PlayerInputManager"
end

function PlayerInputManager:new(inputDevice)
	if inputDevice == nil then
		error("invalid input device!")
	end

	self.inputContextStack = {}

	self.activeActionInstances = {}
	
	self.actionTriggeredCallbacks = {}
	self.actionStoppedCallbacks = {}

	self.activeInputDevice = inputDevice
end

function PlayerInputManager:isInputDeviceUsedByPlayer(inputDevice)
	return self.activeInputDevice == inputDevice
end

function PlayerInputManager:pushInputContext(inputContext)
	print("Pushing Input Context ", inputContext)
	table.insert(self.inputContextStack, inputContext)
	for _, actionDefinition in pairs(inputContext) do
		local actionInstance = actionDefinition:activateForPlayer(self)
		actionInstance.associatedContext = inputContext
		table.insert(self.activeActionInstances, actionInstance)
	end
end

function PlayerInputManager:popInputContext(inputContext)
	print("Removing Input Context ", inputContext)
	for contextName, context in pairs(self.inputContextStack) do
		if context == inputContext then

			for i = #self.activeActionInstances, 1, -1 do
				local currInstance = self.activeActionInstances[i]
				if currInstance.associatedContext == inputContext then
					table.remove(self.activeActionInstances, i)
				end
			end

			table.remove(self.inputContextStack, contextName)
			break
		end
	end
end

function PlayerInputManager:findActionInstance(action)
	for _, actionInstance in ipairs(self.activeActionInstances) do
		if actionInstance.originalDefinition == action then
			return actionInstance
		end
	end
	return nil
end

function PlayerInputManager:bindActionCallbacks(listener, action, triggeredCallback, endedCallback)
	local actionInstance = self:findActionInstance(action)
	if actionInstance == nil then
		error("failed to find a matching action")
		return
	end

	if triggeredCallback ~= nil then
		BindToCallback(actionInstance.onActionTriggeredCallbacks, listener, triggeredCallback)
	end
	if endedCallback ~= nil then
		BindToCallback(actionInstance.onActionEndedCallbacks, listener, endedCallback)
	end
end

function PlayerInputManager:unbindActionCallbacks(listener, action)
	local actionInstance = self:findActionInstance(action)
	if actionInstance == nil then
		error("failed to find a matching action")
		return
	end

	UnregisterAllCallbacks(actionInstance.onActionTriggeredCallbacks, listener)
	UnregisterAllCallbacks(actionInstance.onActionEndedCallbacks, listener)
end

function PlayerInputManager:getActionValue(action)
	local actionInstance = self:findActionInstance(action)
	if actionInstance ~= nil then
		return actionInstance.value
	end
	return nil
end

return PlayerInputManager
