local InputDef_Base = {
	inputStartedCallbacks = {},
	inputHeldCallbacks = {},
	inputEndedCallbacks = {}
}

InputDef_Base.__index = InputDef_Base

function InputDef_Base:createDef()
	local def = {}
	def.__index = def
	setmetatable(def, self)
	return def
end

function InputDef_Base:__call(initData, ...)
	local inputInstance = setmetatable({}, self)
	inputInstance:new(initData)
	inputInstance.modifiers = { ... } or {}
	return inputInstance
end

local function GetModifiedInputValue(inputDef, rawValue)
	local modifiedValue = rawValue
	for _, modifier in pairs(inputDef.modifiers) do
		modifiedValue = modifier.applyMod(modifiedValue)
	end
	return modifiedValue
end

local function BroadcastInputStarted(inputDef, rawValue)
	local modifiedValue = GetModifiedInputValue(inputDef, rawValue)
	BroadcastCallback(inputDef.inputStartedCallbacks, inputDef, modifiedValue)
end

local function BroadcastInputHeld(inputDef, rawValue)
	local modifiedValue = GetModifiedInputValue(inputDef, rawValue)
	BroadcastCallback(inputDef.inputHeldCallbacks, inputDef, modifiedValue)
end

local function BroadcastInputEnded(inputDef, rawValue)
	local modifiedValue = GetModifiedInputValue(inputDef, rawValue)
	BroadcastCallback(inputDef.inputEndedCallbacks, inputDef, modifiedValue)
end

InputDef_KeyboardKey = InputDef_Base:createDef()
function InputDef_KeyboardKey:new(initData)
	self.assignedKey = initData
	BindToCallback(InputDeviceManager.onKeyPressedCallbacks, self, self.onKeyPressed)
	BindToCallback(InputDeviceManager.onKeyReleasedCallbacks, self, self.onKeyReleased)
end


function InputDef_KeyboardKey:onKeyPressed(key, scancode, isRepeat)
	if key == self.assignedKey then
		if not isRepeat then
			BroadcastInputStarted(self, 1)
		else
			BroadcastInputHeld(self, 1)
		end
	end
end

function InputDef_KeyboardKey:onKeyReleased(key)
	if key == self.assignedKey then
		BroadcastInputEnded(self, 0)
	end
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
