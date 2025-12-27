local InputDef_Base = {}

InputDef_Base.__index = InputDef_Base

function InputDef_Base:createDef()
	local def = {}
	def.__index = def
	setmetatable(def, self)
	return def
end

function InputDef_Base:activate(playerInputManager)
end

function InputDef_Base:activate_internal(playerInputManager)
	local playerInputDefInstance = {}
	
	playerInputDefInstance.inputStartedCallbacks = {}
	playerInputDefInstance.inputHeldCallbacks = {}
	playerInputDefInstance.inputEndedCallbacks = {}

	playerInputDefInstance.__index = self
	setmetatable(playerInputDefInstance, playerInputDefInstance)
	playerInputDefInstance.inputManager = playerInputManager
	playerInputDefInstance:activate(playerInputManager)

	return playerInputDefInstance
end

function InputDef_Base:__call(initData, ...)
	local inputDefInstance = setmetatable({}, self)
	inputDefInstance:new(initData)
	inputDefInstance.modifiers = { ... } or {} -- how to handle this if ... is already a self contained table (multiple modifiers)
	return inputDefInstance
end

function InputDef_Base:new(initData)
end

local function GetModifiedInputValue(inputDef, rawValue)
	local modifiedValue = rawValue
	for _, modifier in pairs(inputDef.modifiers) do
		modifiedValue = modifier:applyMod(modifiedValue)
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
end

function InputDef_KeyboardKey:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onKeyPressedCallbacks, self, self.onKeyPressed)
	BindToCallback(InputDeviceManager.onKeyReleasedCallbacks, self, self.onKeyReleased)
end

function InputDef_KeyboardKey:onKeyPressed(key, scancode, isRepeat)
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end

	if key == self.assignedKey then
		if not isRepeat then
			BroadcastInputStarted(self, 1)
		else
			BroadcastInputHeld(self, 1)
		end
	end
end

function InputDef_KeyboardKey:onKeyReleased(key)
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end

	if key == self.assignedKey then
		BroadcastInputEnded(self, 0)
	end
end

InputDef_GamepadAxis = InputDef_Base:createDef()
function InputDef_GamepadAxis:new(axisName)
	self.axisName = axisName
end

function InputDef_GamepadAxis:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onGamepadAxisCallbacks, self, self.onGamepadAxis)
end

function InputDef_GamepadAxis:onGamepadAxis(joystick, axis, value)
	if not self.inputManager:isInputDeviceUsedByPlayer(joystick) then return end

	if axis == self.axisName then
		BroadcastInputStarted(self, value)
	end
end

InputDef_GamepadButton = InputDef_Base:createDef()
function InputDef_GamepadButton:new(buttonID)
	self.buttonID = buttonID
end

function InputDef_GamepadButton:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onGamepadPressedCallbacks, self, self.onGamepadButtonPressed)
	BindToCallback(InputDeviceManager.onGamepadReleasedCallbacks, self, self.onGamepadButtonReleased)
end

function InputDef_GamepadButton:onGamepadButtonPressed(joystick, button)
	if not self.inputManager:isInputDeviceUsedByPlayer(joystick) then return end
	
	if button == self.buttonID then
		BroadcastInputStarted(self, 1)
	end
end

function InputDef_GamepadButton:onGamepadButtonReleased(joystick, button)
	if not self.inputManager:isInputDeviceUsedByPlayer(joystick) then return end
	
	if button == self.buttonID then
		BroadcastInputEnded(self, 0)
	end
end

InputDef_GamepadHat = InputDef_Base:createDef()
function InputDef_GamepadHat:new(buttonID)
end

InputDef_MouseClicked = InputDef_Base:createDef()
function InputDef_MouseClicked:new(buttonID)
	self.buttonID = buttonID
end

function InputDef_MouseClicked:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onMousePressedCallbacks, self, self.onMousePressed)
	BindToCallback(InputDeviceManager.onMouseReleasedCallbacks, self, self.onMouseReleased)
end

function InputDef_MouseClicked:onMousePressed(x, y, button, isTouch, presses)
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end

	if button == self.buttonID then
		BroadcastInputStarted(self, 1)
	end
end

function InputDef_MouseClicked:onMouseReleased(x, y, button, isTouch, presses)
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end

	if button == self.buttonID then
		BroadcastInputEnded(self, 0)
	end
end

InputDef_MousePosition = InputDef_Base:createDef()
function InputDef_MousePosition:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onMouseMovedCallbacks, self, self.onMouseMoved)
end

function InputDef_MousePosition:onMouseMoved(x, y, dy, dy, isTouch)
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end
	BroadcastInputStarted(self, {x, y})
end

InputDef_TouchDrag = InputDef_Base:createDef()
function InputDef_TouchDrag:new()
end

InputDef_TouchJoystick = InputDef_Base:createDef()
function InputDef_TouchJoystick:new()
end
