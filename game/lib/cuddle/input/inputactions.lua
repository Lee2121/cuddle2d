InputAction = {}
function InputAction:new(valueType, inputs)
	self.valueType = valueType
	self.inputs = inputs

	for i, input in ipairs(inputs) do
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

Input_KeyboardKey = {
	keyboardPressedCallbacks = InputDeviceManager.onKeyPressedCallbacks,
	keyboardReleasedCallbacks = InputDeviceManager.onKeyReleasedCallbacks
}

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
function Input_GamepadAxis:new(axisName)

end

Input_GamepadButton = {}
function Input_GamepadButton:new(buttonID)

end

Input_MouseClicked = {}
function Input_MouseClicked:new(buttonID)

end

Input_MousePosition = {}
function Input_MousePosition:new()

end

Input_TouchDrag = {}
function Input_TouchDrag:new()

end

Input_TouchJoystick = {}
function Input_TouchJoystick:new()

end
