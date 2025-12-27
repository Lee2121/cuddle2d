InputAction = {}

setmetatable(InputAction, InputAction)
InputAction.__index = InputAction

function InputAction:__call(valueType, inputs)
	local definitionInstance = setmetatable({}, InputAction)
	definitionInstance:new(valueType, inputs)
	return definitionInstance
end

function InputAction:new(valueType, inputs)
	self.valueType = valueType

	if valueType == "vector2d" then
		self.xAxisInputs = inputs["xaxis"]
		self.yAxisInputs = inputs["yaxis"]
		self.xyAxisInputs = inputs["xyaxis"]
	else
		self.inputDefinitions = inputs
	end
end

function InputAction:activateForPlayer(playerInputManager)
	local actionPlayerInstance = setmetatable({}, self)
	actionPlayerInstance.linkedInputManager = playerInputManager
	self.inputInstances = {}
	for _, inputDefinition in ipairs(self.inputDefinitions) do
  		local inputInstance = inputDefinition:activate_internal(playerInputManager)
		BindToCallback(inputInstance.inputStartedCallbacks, self, self.linkedInputStarted)
		BindToCallback(inputInstance.inputHeldCallbacks, self, self.linkedInputHeld)
		BindToCallback(inputInstance.inputEndedCallbacks, self, self.linkedInputEnded)
		table.insert(self.inputInstances, inputInstance)
	end
	return actionPlayerInstance
end

function InputAction:linkedInputStarted(inputDef, value)
	print("started")
end

function InputAction:linkedInputHeld(inputDef, value)
	print("held")
end

function InputAction:linkedInputEnded(inputDef, value)
	print("released")
end
