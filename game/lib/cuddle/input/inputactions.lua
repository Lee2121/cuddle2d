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

function InputAction:ActivateForPlayer(playerInstance)
	local actionPlayerInstance = setmetatable({}, self)
	for i, input in ipairs(self.inputs) do
		BindToCallback(input.inputStarted, self, self.linkedInputStarted)
		BindToCallback(input.inputEnded, self, self.linkedInputEnded)
	end
end

function InputAction:linkedInputStarted(input)
	print("started", input)
end

function InputAction:linkedInputEnded(input)
	print("ended", input)
end


local Input_Base = {
	inputStartedCallbacks = {},
	inputEndedCallbacks = {}
}
Input_Base.__index = Input_Base

function Input_Base:__call(...)
	local inputInstance = setmetatable({}, Input_Base)
	inputInstance:new(...)
	return inputInstance
end

function Input_Base:new(...)
end

Input_KeyboardKey = {
	keyboardPressedCallbacks = InputDeviceManager.onKeyPressedCallbacks,
	keyboardReleasedCallbacks = InputDeviceManager.onKeyReleasedCallbacks
}
setmetatable(Input_KeyboardKey, Input_Base)

function Input_KeyboardKey:new(key)
	setmetatable(self, Input_Base)
	BindToCallback(self.keyboardPressedCallbacks, self, self.onKeyPressed)
	BindToCallback(self.keyboardReleasedCallbacks, self, self.onKeyReleased)
end

function Input_KeyboardKey:onKeyPressed()
	BroadcastCallback(self.inputStartedCallbacks, self)
end

function Input_KeyboardKey:onKeyReleased()
	BroadcastCallback(self.inputEndedCallbacks, self)
end

Input_GamepadAxis = {}
setmetatable(Input_GamepadAxis, Input_Base)
function Input_GamepadAxis:new(axisName)
end

Input_GamepadButton = {}
setmetatable(Input_GamepadButton, Input_Base)
function Input_GamepadButton:new(buttonID)
end

Input_MouseClicked = {}
setmetatable(Input_MouseClicked, Input_Base)
function Input_MouseClicked:new(buttonID)

end

Input_MousePosition = {}
setmetatable(Input_MousePosition, Input_Base)
function Input_MousePosition:new()

end

Input_TouchDrag = {}
setmetatable(Input_TouchDrag, Input_Base)
function Input_TouchDrag:new()

end

Input_TouchJoystick = {}
setmetatable(Input_TouchJoystick, Input_Base)
function Input_TouchJoystick:new()

end
