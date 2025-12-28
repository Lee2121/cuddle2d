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
	actionPlayerInstance.startedInputs = {} -- list of linked inputs that have "started" but not ended

	for _, inputDefinition in ipairs(self.inputDefinitions) do
  		local inputInstance = inputDefinition:activate_internal(playerInputManager)
		BindToCallback(inputInstance.inputStartedCallbacks, actionPlayerInstance, actionPlayerInstance.linkedInputStarted)
		BindToCallback(inputInstance.inputEndedCallbacks, actionPlayerInstance, actionPlayerInstance.linkedInputEnded)
		table.insert(actionPlayerInstance.inputInstances, inputInstance)
	end

	actionPlayerInstance.onActionStartedCallbacks = {}
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
	
	self.value = value
	
	if #self.startedInputs == 0 then
		print("started")
		BroadcastCallback(self.onActionStartedCallbacks, value)
	end

	table.insert(self.startedInputs, inputDef)
end

function InputAction_Base:linkedInputEnded(inputDef, value)
	self.value = value

	self.startedInputs[inputDef] = nil

	for i = #self.startedInputs, 1, -1 do
		if self.startedInputs[i] == inputDef then
			table.remove(self.startedInputs, i)
		end
	end

	if #self.startedInputs == 0 then
		print("released")
		BroadcastCallback(self.onActionEndedCallbacks, value)
	end
end
