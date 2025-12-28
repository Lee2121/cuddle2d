local InputAction_Base = {}

InputAction_Base.__index = InputAction_Base

function InputAction_Base:define()
	local newActionDef = {}
	newActionDef.__index = newActionDef
	setmetatable(newActionDef, self)
	return newActionDef
end

function InputAction_Base:new(inputs)
	self.inputDefinitions = inputs
end

function InputAction_Base:__call(inputs)
	local definitionInstance = setmetatable({}, self)
	definitionInstance.__index = self
	definitionInstance:new(inputs)
	return definitionInstance
end

function InputAction_Base:__tostring()
	return "InputAction_Base"
end

function InputAction_Base:activateForPlayer(playerInputManager)
	local actionPlayerInstance = {}
	
	setmetatable(actionPlayerInstance, self)
	actionPlayerInstance.__index = actionPlayerInstance

	actionPlayerInstance.linkedInputManager = playerInputManager
	actionPlayerInstance.inputInstances = {}
	actionPlayerInstance.originalDefinition = self

	actionPlayerInstance.rawValue = 0
	actionPlayerInstance.value = actionPlayerInstance:getDefaultValue()

	actionPlayerInstance.startedInputs = {} -- list of linked inputs that have "started" but not ended

	for _, inputDefinition in ipairs(self.inputDefinitions) do
  		local inputInstance = inputDefinition:activate_internal(actionPlayerInstance)
		table.insert(actionPlayerInstance.inputInstances, inputInstance)
	end

	actionPlayerInstance.onActionStartedCallbacks = {}
	actionPlayerInstance.onActionEndedCallbacks = {}

	return actionPlayerInstance
end

function InputAction_Base:linkedInputStarted(inputDef, value)
	
	self.rawValue = value 
	self.value = self:calcValueForInput(inputDef, value)
	
	if #self.startedInputs == 0 then
		print("started")
		BroadcastCallback(self.onActionStartedCallbacks, value)
	end

	table.insert(self.startedInputs, inputDef)
end

function InputAction_Base:linkedInputEnded(inputDef, value)

	for i = #self.startedInputs, 1, -1 do
		if self.startedInputs[i] == inputDef then
			table.remove(self.startedInputs, i)
		end
	end

	if #self.startedInputs == 0 then
		print("released")
		self.rawValue = value
		self.value = self:calcValueForInput(inputDef, value)
		BroadcastCallback(self.onActionEndedCallbacks, value)
	end
end

InputAction_Vector2 = InputAction_Base:define()
function InputAction_Vector2:new(inputs)
	
end

function InputAction_Vector2:__tostring()
	return "InputAction_Vector2"
end

InputAction_Bool = InputAction_Base:define()
function InputAction_Bool:__tostring()
	return "InputAction_Bool"
end

function InputAction_Bool:getDefaultValue()
	return false
end

function InputAction_Bool:calcValueForInput(inputDef, value)
	return value > 0 and true or false
end

