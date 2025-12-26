local InputDef_Base = {
	inputStartedCallbacks = {},
	inputEndedCallbacks = {}
}

InputDef_Base.__index = InputDef_Base

function InputDef_Base:createDef()
	local def = {}
	def.__index = def
	setmetatable(def, self)
	return def
end

function InputDef_Base:__call(...)
	local inputInstance = setmetatable({}, self)
	inputInstance:new()
	return inputInstance
end

InputDef_KeyboardKey = InputDef_Base:createDef()

function InputDef_KeyboardKey:new()
	print("new keyboard key")
	BindToCallback(InputDeviceManager.onKeyPressedCallbacks, self, self.onKeyPressed)
	BindToCallback(InputDeviceManager.onKeyReleasedCallbacks, self, self.onKeyReleased)
end

function InputDef_KeyboardKey:onKeyPressed()
	print("key pressed")
	BroadcastCallback(self.inputStartedCallbacks, self)
end

function InputDef_KeyboardKey:onKeyReleased()
	BroadcastCallback(self.inputEndedCallbacks, self)
end

InputDef_GamepadAxis = InputDef_Base:createDef()
function InputDef_GamepadAxis:new(axisName)
end

InputDef_GamepadButton = InputDef_Base:createDef()
function InputDef_GamepadButton:new(buttonID)
end

InputDef_MouseClicked = InputDef_Base:createDef()
function InputDef_MouseClicked:new(buttonID)
end

InputDef_MousePosition = InputDef_Base:createDef()
function InputDef_MousePosition:new()
end

InputDef_TouchDrag = InputDef_Base:createDef()
function InputDef_TouchDrag:new()
end

InputDef_TouchJoystick = InputDef_Base:createDef()
function InputDef_TouchJoystick:new()
end
