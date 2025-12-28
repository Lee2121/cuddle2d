InputAction_Base = {}

setmetatable(InputAction_Base, InputAction_Base)
InputAction_Base.__index = InputAction_Base

function InputAction_Base:__call(inputs)
	local definitionInstance = setmetatable({}, InputAction_Base)
	definitionInstance:new(inputs)
	return definitionInstance
end

function InputAction_Base:new(inputs)
	self.inputDefinitions = inputs
end

function InputAction_Base:__tostring()
	return "inputaction_base"
end

function InputAction_Base:define()
	local newActionDef = {}
	setmetatable(newActionDef, self)
	return newActionDef
end

function InputAction_Base:activateForPlayer(playerInputManager)
	local actionPlayerInstance = setmetatable({}, InputAction_Base)
	actionPlayerInstance.__index = InputAction_Base

	actionPlayerInstance.linkedInputManager = playerInputManager
	actionPlayerInstance.inputInstances = {}
	actionPlayerInstance.originalDefinition = self

	actionPlayerInstance.value = 0

	for _, inputDefinition in ipairs(self.inputDefinitions) do
  		local inputInstance = inputDefinition:activate_internal(playerInputManager)
		BindToCallback(inputInstance.inputStartedCallbacks, actionPlayerInstance, actionPlayerInstance.linkedInputStarted)
		BindToCallback(inputInstance.inputHeldCallbacks, actionPlayerInstance, actionPlayerInstance.linkedInputHeld)
		BindToCallback(inputInstance.inputEndedCallbacks, actionPlayerInstance, actionPlayerInstance.linkedInputEnded)
		table.insert(actionPlayerInstance.inputInstances, inputInstance)
	end

	actionPlayerInstance.onActionStartedCallbacks = {}
	actionPlayerInstance.onActionHeldCallbacks = {}
	actionPlayerInstance.onActionEndedCallbacks = {}

	return actionPlayerInstance
end

InputAction_Vector2 = InputAction_Base:define()
function InputAction_Vector2:new(inputs)
	
end

function InputAction_Vector2:__tostring()
	return "inputaction_vector2"
end

InputAction_Bool = InputAction_Base:define()

function InputAction_Bool:__tostring()
	return "inputaction_bool"
end

function InputAction_Base:linkedInputStarted(inputDef, value)
	print("started")
	self.value = value
	BroadcastCallback(self.onActionStartedCallbacks, 1)
end

function InputAction_Base:linkedInputHeld(inputDef, value)
	print("held")
	self.value = value
	BroadcastCallback(self.onActionHeldCallbacks, 1)
end

function InputAction_Base:linkedInputEnded(inputDef, value)
	print("released")
	self.value = value
	BroadcastCallback(self.onActionEndedCallbacks, 0)
end
