local InputDef_Base = {}

InputDef_Base.__index = InputDef_Base

function InputDef_Base:createDef()
	local def = {}
	def.__index = def
	setmetatable(def, self)
	return def
end

function InputDef_Base:new(initData)
end

function InputDef_Base:__call(initData, ...)
	local inputDefInstance = setmetatable({}, self)
	inputDefInstance.__index = inputDefInstance
	inputDefInstance:new(initData)
	inputDefInstance.modifiers = { ... } or {} -- how to handle this if ... is already a self contained table (multiple modifiers)
	return inputDefInstance
end

function InputDef_Base:activate(owningActionInstance)
end

function InputDef_Base:__tostring()
	return "InputDef_Base"
end

function InputDef_Base:activate_internal(owningActionInstance)
	local playerInputDefInstance = {}

	setmetatable(playerInputDefInstance, self)
	playerInputDefInstance.__index = playerInputDefInstance

	playerInputDefInstance.originalDefinition = self
	
	playerInputDefInstance.onInputTriggeredCallbacks = {}
	playerInputDefInstance.onInputEndedCallbacks = {}

	BindToCallback(playerInputDefInstance.onInputTriggeredCallbacks, owningActionInstance, owningActionInstance.linkedInputTriggered)
	BindToCallback(playerInputDefInstance.onInputEndedCallbacks, owningActionInstance, owningActionInstance.linkedInputEnded)

	playerInputDefInstance.inputManager = owningActionInstance.linkedInputManager

	playerInputDefInstance:activate(owningActionInstance)

	return playerInputDefInstance
end

local function GetModifiedInputValue(inputDef, rawValue)
	local modifiedValue = rawValue
	for _, modifier in pairs(inputDef.modifiers) do
		modifiedValue = modifier:applyMod(modifiedValue)
	end
	return modifiedValue
end

local function BroadcastInputTriggered(inputDef, rawValue)
	local modifiedValue = GetModifiedInputValue(inputDef, rawValue)
	BroadcastCallback(inputDef.onInputTriggeredCallbacks, inputDef, modifiedValue)
end

local function BroadcastInputEnded(inputDef, rawValue)
	local modifiedValue = GetModifiedInputValue(inputDef, rawValue)
	BroadcastCallback(inputDef.onInputEndedCallbacks, inputDef, modifiedValue)
end

InputDef_KeyboardKey = InputDef_Base:createDef()
function InputDef_KeyboardKey:new(initData)
	self.assignedKey = initData
end

function InputDef_KeyboardKey:__tostring()
	return "InputDef_KeyboardKey"
end

function InputDef_KeyboardKey:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onKeyPressedCallbacks, self, self.onKeyPressed)
	BindToCallback(InputDeviceManager.onKeyReleasedCallbacks, self, self.onKeyReleased)
end

function InputDef_KeyboardKey:onKeyPressed(key, scancode, isRepeat)
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end

	if key == self.assignedKey then
		BroadcastInputTriggered(self, 1)
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

function InputDef_GamepadAxis:__tostring()
	return "InputDef_GamepadAxis"
end

function InputDef_GamepadAxis:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onGamepadAxisCallbacks, self, self.onGamepadAxis)
end

function InputDef_GamepadAxis:onGamepadAxis(joystick, axis, value)
	if not self.inputManager:isInputDeviceUsedByPlayer(joystick) then return end

	if axis == self.axisName then
		BroadcastInputTriggered(self, value)
	end
end

InputDef_GamepadButton = InputDef_Base:createDef()
function InputDef_GamepadButton:new(buttonID)
	self.buttonID = buttonID
end

function InputDef_GamepadButton:__tostring()
	return "InputDef_GamepadButton"
end

function InputDef_GamepadButton:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onGamepadPressedCallbacks, self, self.onGamepadButtonPressed)
	BindToCallback(InputDeviceManager.onGamepadReleasedCallbacks, self, self.onGamepadButtonReleased)
end

function InputDef_GamepadButton:onGamepadButtonPressed(joystick, button)
	if not self.inputManager:isInputDeviceUsedByPlayer(joystick) then return end
	
	if button == self.buttonID then
		BroadcastInputTriggered(self, 1)
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

function InputDef_GamepadHat:__tostring()
	return "InputDef_GamepadHat"
end

InputDef_MouseClicked = InputDef_Base:createDef()
function InputDef_MouseClicked:new(buttonID)
	self.buttonID = buttonID
end

function InputDef_MouseClicked:__tostring()
	return "InputDef_MouseClicked"
end

function InputDef_MouseClicked:activate(playerInputManager)
	BindToCallback(InputDeviceManager.onMousePressedCallbacks, self, self.onMousePressed)
	BindToCallback(InputDeviceManager.onMouseReleasedCallbacks, self, self.onMouseReleased)
end

function InputDef_MouseClicked:onMousePressed(x, y, button, isTouch, presses)
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end

	if button == self.buttonID then
		BroadcastInputTriggered(self, 1)
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
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end
	BindToCallback(InputDeviceManager.onMouseMovedCallbacks, self, self.onMouseMoved)
end

function InputDef_MousePosition:__tostring()
	return "InputDef_MousePosition"
end

function InputDef_MousePosition:onMouseMoved(x, y, dy, dy, isTouch)
	if not self.inputManager:isInputDeviceUsedByPlayer("mouseAndKeyboard") then return end
	BroadcastInputTriggered(self, {x, y})
end

InputDef_Touch = InputDef_Base:createDef()
function InputDef_Touch:new(screenSide)
	self.screenSide = screenSide
end

function InputDef_Touch:__tostring()
	return "InputDef_Touch"
end

function InputDef_Touch:activate(playerInputManager)
	if not self.inputManager:isInputDeviceUsedByPlayer("touch") then return end
	BindToCallback(InputDeviceManager.onTouchPressedCallbacks, self, self.onTouchPressed)
	BindToCallback(InputDeviceManager.onTouchMovedCallbacks, self, self.onTouchMoved)
	BindToCallback(InputDeviceManager.onTouchReleasedCallbacks, self, self.onTouchReleased)
end

function InputDef_Touch:onTouchPressed(id, x, y, dx, dy, pressure)

	-- determine if this is the correct side of the screen
	if self.screenSide == "left" then
		if x > love.graphics.getWidth() / 2 then
			return
		end
	elseif self.screenSide == "right" then
		if x < love.graphics.getWidth() / 2 then
			return
		end
	elseif self.screenSide ~= nil then
		error("unknown screenSide command " .. self.screenSide)
		return
	end

	self.id = id

	BroadcastInputTriggered(self, { x, y })
end

function InputDef_Touch:onTouchMoved(id, x, y, dx, dy, pressure)
	if self.id ~= id then return end
	BroadcastInputTriggered(self, { x, y })
end

function InputDef_Touch:onTouchReleased(id, x, y, dx, dy, pressure)
	if self.id ~= id then return end
	BroadcastInputEnded(self, { x, y })
end
