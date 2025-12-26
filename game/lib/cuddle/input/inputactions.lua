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
	self.inputs = inputs
end

function InputAction:activateForPlayer(playerInputManager)
	local actionPlayerInstance = setmetatable({}, self)
	actionPlayerInstance.linkedInputManager = playerInputManager
	for i, input in ipairs(self.inputs) do
		BindToCallback(input.inputStartedCallbacks, self, self.linkedInputStarted)
		BindToCallback(input.inputEndedCallbacks, self, self.linkedInputEnded)
	end
end

function InputAction:linkedInputStarted(input)
	print("started", input)
end

function InputAction:linkedInputEnded(input)
	print("ended", input)
end
