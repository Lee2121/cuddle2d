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
	definitionInstance.__index = definitionInstance
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

function InputAction_Base:linkedInputStarted(inputDefInstance, value)
	
	self.rawValue = value 
	self.value = self:calcValueForInput(inputDefInstance, value)
	
	if #self.startedInputs == 0 then
		BroadcastCallback(self.onActionStartedCallbacks, value)
	end

	local function hasInputBeenStarted(inputDefInstance)
		for _, inputDef in ipairs(self.startedInputs) do
			if inputDef == inputDefInstance then
				return true
			end
		end
		return false
	end

	if not hasInputBeenStarted(inputDefInstance) then
		table.insert(self.startedInputs, inputDefInstance)
	end
end

function InputAction_Base:linkedInputEnded(inputDefInstance, value)

	for i = #self.startedInputs, 1, -1 do
		if self.startedInputs[i] == inputDefInstance then
			table.remove(self.startedInputs, i)
		end
	end

	if #self.startedInputs == 0 then
		self.rawValue = value
		self.value = self:calcValueForInput(inputDefInstance, value)
		BroadcastCallback(self.onActionEndedCallbacks, value)
	end
end

InputAction_Bool = InputAction_Base:define()
function InputAction_Bool:__tostring()
	return "InputAction_Bool"
end

function InputAction_Bool:getDefaultValue()
	return false
end

function InputAction_Bool:calcValueForInput(inputDefInstance, value)
	return value > 0 and true or false
end

InputAction_Float = InputAction_Base:define()
function InputAction_Float:__tostring()
	return "InputAction_Float"
end

function InputAction_Float:getDefaultValue()
	return 0
end

function InputAction_Float:calcValueForInput(inputDefInstance, value)
	return value
end

InputAction_Vector2 = InputAction_Base:define()
function InputAction_Vector2:__tostring()
	return "InputAction_Vector2"
end

function InputAction_Vector2:new(inputs)
	self.xAxisInputs = inputs.xaxis or {}
	self.yAxisInputs = inputs.yaxis or {}
	self.xyAxisInputs = inputs.xyaxis or {}

	self.inputDefinitions = {}

	local function appendToInputDefinitions(inputs)
		if inputs == nil then return end
		for _, input in ipairs(inputs) do
			table.insert(self.inputDefinitions, input)
		end
	end

	appendToInputDefinitions(inputs.xaxis)
	appendToInputDefinitions(inputs.yaxis)
	appendToInputDefinitions(inputs.xyaxis)
end

function InputAction_Vector2:getDefaultValue()
	return { 0, 0 }
end

function InputAction_Vector2:calcValueForInput(inputDefInstance, value)

	local function doesInputControlAxis(inputDefInstance, axisInputs)
		for _, currInputDef in ipairs(axisInputs) do
			if currInputDef == inputDefInstance.originalDefinition then
				return true
			end
		end
		return false
	end

	if doesInputControlAxis(inputDefInstance, self.xAxisInputs) then
		return { value, self.value[2] }
	elseif doesInputControlAxis(inputDefInstance, self.yAxisInputs) then
		return { self.value[1], value }
	elseif doesInputControlAxis(inputDefInstance, self.xyAxisInputs) then
		return value
	end
end
