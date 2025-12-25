InputDeviceManager = require "lib.cuddle.input.inputdevicemanager"
require "lib.cuddle.utils.callbacks"

PlayerInputManager = {
	actionTriggeredCallbacks = {},
	actionStoppedCallbacks = {}
}

local PS4_BTN_ID_X = 1
local PS4_BTN_ID_CIRCLE = 2
local PS4_BTN_ID_SQUARE = 3
local PS4_BTN_ID_Triangle = 4

local JOYSTICK_DEADZONE = .1

local InputAction = {}
function InputAction:new(valueType, inputs)
	self.valueType = valueType
	self.inputs = inputs

	for i, input in ipairs(inputs) do
		BindToCallback(input.inputStarted, self, self.linkedInputStarted)
		BindToCallback(input.inputEnded, self, self.linkedInputEnded)
	end
end

function InputAction:linkedInputStarted(input)

end

function InputAction:linkedInputEnded(input)

end

local Input_KeyboardKey = {
	keyboardPressedCallbacks = InputDeviceManager.onKeyPressedCallbacks,
	keyboardReleasedCallbacks = InputDeviceManager.onKeyReleasedCallbacks
}

function Input_KeyboardKey:new(key)
	BindToCallback(self.keyboardPressedCallbacks, self, self.onKeyPressed)
	BindToCallback(self.keyboardReleasedCallbacks, self, self.onKeyReleased)
end

function Input_KeyboardKey:onKeyPressed()
	BroadcastCallback(self.inputStarted, self)
end

function Input_KeyboardKey:onKeyReleased()
	BroadcastCallback(self.inputEnded, self)
end

local Input_GamepadAxis = {}
function Input_GamepadAxis:new(axisName)

end

local Input_GamepadButton = {}
function Input_GamepadButton:new(buttonID)

end

local Input_MouseClicked = {}
function Input_MouseClicked:new(buttonID)

end

local Input_MousePosition = {}
function Input_MousePosition:new()

end

local Input_TouchDrag = {}
function Input_TouchDrag:new()

end

local Input_TouchJoystick = {}
function Input_TouchJoystick:new()

end

-- these should eventually be moved out to a game specific section of the code. maybe the player controller?
InputContext_Rally  = {
	move = InputAction:new("vector2d", { 	xaxis = { Input_KeyboardKey:new('a'), Input_KeyboardKey:new("left"), Input_GamepadAxis:new("leftx") },
										yaxis = { Input_KeyboardKey:new('d'), Input_KeyboardKey:new("right"), Input_GamepadAxis:new("lefty") },
										xyaxis = { Input_TouchJoystick:new() } } ),

	spaceBar = InputAction:new("bool", { Input_KeyboardKey:new("spacebar"), Input_GamepadButton:new(PS4_BTN_ID_Triangle) } ),
}

local registeredInputDevices = {
	keyboard = {},
	mouse = {},
	touch = {},
	gamepad = {}
}

local inputContextStack = {}

function PlayerInputManager:new(inputDevice)
	if inputDevice ~= nil then
		self:registerInputDevice(inputDevice)
	end
end

function PushInputContext(inputContext)
	print("Pushing Input Context ", inputContext)
	table.insert(inputContextStack, inputContext)

	for inputAction, actionDefinition in pairs(inputContext) do
		
	end
end

function PopInputContext(inputContext)
	print("Removing Input Context ", inputContext)
	for i, context in ipairs(inputContext) do
		if context == inputContext then
			table.remove(inputContextStack, i)
			break
		end
	end
end

local function isInputDeviceAGamepad(inputDevice)
	return (love.joystick.getJoysticks()[inputDevice] ~= nil)
end

function PlayerInputManager:registerInputDevice(inputDevice)
	if inputDevice == "keyboard" then
		InputDeviceManager:bindToKeyboardCallbacks(self, self.keyPressed, self.keyReleased)
		registeredInputDevices.keyboard = inputDevice
	elseif inputDevice == "mouse" then
		InputDeviceManager:bindToMouseCallbacks(self, self.mousePressed, self.mouseReleased, self.mouseMoved)
		registeredInputDevices.mouse = inputDevice
	elseif inputDevice == "touch" then
		InputDeviceManager:bindToTouchCallbacks(self, self.touchPressed, self.touchReleased, self.touchMoved)
		registeredInputDevices.touch = inputDevice
	elseif isInputDeviceAGamepad(inputDevice) then
		InputDeviceManager:bindToGamepadCallbacks(self, self.gamepadPressed, self.gamepadReleased, self.gamepadAxis)
		registeredInputDevices.gamepad = inputDevice
	end
end

function PlayerInputManager:unregisterInputDevice(inputDevice)
	if inputDevice == "keyboard" then
		InputDeviceManager:unregisterFromKeyboardCallbacks(self)
		registeredInputDevices.keyboard = nil
	elseif inputDevice == "mouse" then
		InputDeviceManager:unregisterFromMouseCallbacks(self)
		registeredInputDevices.mouse = nil
	elseif inputDevice == "touch" then
		InputDeviceManager:unregisterFromKeyboardCallbacks(self)
		registeredInputDevices.touch = nil
	else
		InputDeviceManager:unregisterFromKeyboardCallbacks(self)
		registeredInputDevices.gamepad = nil
	end
end

local function GetInputNameFromDevice(inputDevice)
	if inputDevice == "keyboard" then
		return "keyboard"
	elseif inputDevice == "mouse" then
		return "mouse"
	elseif inputDevice == "touch" then
		return "touch"
	elseif isInputDeviceAGamepad(inputDevice) then
		return "gamepad"
	end
	error(string.format("Failed to find an input name for device %s"), inputDevice)
	return nil
end

function PlayerInputManager:FindLinkedInputActionForDevice(input, inputDevice)

	local deviceName = GetInputNameFromDevice(inputDevice)
	if deviceName == nil then
		return nil
	end

	for contextIndex = #inputContextStack, 1, -1 do
		
		local context = inputContextStack[contextIndex]
		for action, inputTable in pairs(context) do
			
			local inputs = action[deviceName]
			if inputs ~= nil then
				for inputType, inputKeys in pairs(inputs) do
					
				end
			end

			for intputDevice, inputs in pairs(action) do
				
				if inputTable[input] ~= nil then
					return action
				end
			end
		end
	end
	return nil
end

function PlayerInputManager:getInputActionValue(action)

	local function getMouseActionValue(actionInputs)
		if actionInputs["buttons"] ~= nil then
			return love.mouse.isDown(actionInputs["buttons"])
		elseif actionInputs == "axis" then
			if actionInputs["axis"] == "xy" then
				return { love.mouse.getPosition() }
			elseif actionInputs["axis"] == 'x' then
				return love.mouse.getX()
			elseif actionInputs["axis"] == 'y' then
				return love.mouse.getY()
			else
				error(string.format("failed to find mouse axis behavior for %s"), actionInputs["axis"])
			end
		else
			error(string.format("failed to find touch behavior for action %s", actionInputs))
		end

		return nil
	end

	local function getKeyboardActionValue(actionInputs)
		return love.keyboard.isDown(actionInputs)
	end

	local function getTouchActionValue(actionInputs)

		if actionInputs == "drag" then
			error("implement me")
		elseif actionInputs == "joystick" then
			error("implement met")
		else
			error(string.format("failed to find touch behavior for action %s", actionInputs))
			return nil
		end
	end

	local function getGamepadActionValue(actionInputs)

		local connectedGamepad = love.joystick.getJoysticks()[self.registeredInputDevies["gamepad"]]
		if connectedGamepad == nil then
			return nil
		end

		for i, actionType in ipairs(actionInputs) do
			if actionType == "buttons" then
				return connectedGamepad.isGamepadDown(actionInputs)
			elseif actionType == "axis" then
				return connectedGamepad.getGamepadAxis(actionInputs)
			else
				error(string.format("No gamepad logic defined for action type %s", actionType))
			end
		end

		return nil
	end

	local result = nil
	for contextIndex = #inputContextStack, 1, -1 do
		
		local context = inputContextStack[contextIndex]
		local actionInputs = context[action]

		if actionInputs ~= nil then

			for j, inputType in ipairs(actionInputs) do
				
				if inputType == "mouse" then
					result = getMouseActionValue(actionInputs)
				elseif inputType == "keyboard" then
					result = getKeyboardActionValue(actionInputs)
				elseif inputType == "touch" then
					result = getTouchActionValue(actionInputs)
				elseif inputType == "gamepad" then
					result = getGamepadActionValue(actionInputs)
				else
						error("failed to find any input device for action ", action)
				end

				-- if a result is nil, consider it "unhandled"
				-- Eg. we're evaluating a gamepad action, but a gamepad is not connected so a button is not triggered nor released - it is nil
				-- This allows us to check input contexts that are lower in the stack to see if we should return an action value for them instead 
				if result ~= nil then
					return result
				end
			end
		end
	end

	return nil
end

function PlayerInputManager:gamepadPressed(joystick, button)
	if registeredInputDevices[joystick] ~= nil then
		local associatedAction = self:FindLinkedInputActionForDevice(joystick, button)
		if associatedAction ~= nil then
			BroadcastCallback(self.actionTriggeredCallbacks, associatedAction)
		end
	end
end

function PlayerInputManager:gamepadReleased(joystick, button)
	if registeredInputDevices[joystick] ~= nil then
		local associatedAction = self:FindLinkedInputActionForDevice(joystick, button)
		if associatedAction ~= nil then
			BroadcastCallback(self.actionStoppedCallbacks, associatedAction)
		end
	end
end

function PlayerInputManager:gamepadAxis(joystick, axis, value)
	if registeredInputDevices[joystick] ~= nil then
		local associatedAction = self:FindLinkedInputActionForDevice(joystick, axis)
		if associatedAction ~= nil then
			BroadcastCallback(self.actionTriggeredCallbacks, associatedAction)
		end
	end
end

function PlayerInputManager:mouseMoved(x, y, dx, dy, isTouch)
	local xAxisAction = self:FindLinkedInputActionForDevice("mouse", 'x')
	local yAxisAction = self:FindLinkedInputActionForDevice("mouse", 'y')
	local xyAxisAction = self:FindLinkedInputActionForDevice("mouse", "xy")
	if xAxisAction ~= nil then
		BroadcastCallback(self.actionTriggeredCallbacks, xAxisAction, x)
	end
	if yAxisAction ~= nil then
		BroadcastCallback(self.actionTriggeredCallbacks, yAxisAction, y)
	end
	if xyAxisAction ~= nil then
		BroadcastCallback(self.actionTriggeredCallbacks, xyAxisAction, x, y)
	end
end

function PlayerInputManager:mousePressed(x, y, button, isTouch, presses)
	local associatedAction = self:FindLinkedInputActionForDevice("mouse")
end

function PlayerInputManager:mouseReleased(x, y, button, isTouch, presses)
end

function PlayerInputManager:keyPressed(key, scancode, isRepeat)
end

function PlayerInputManager:keyReleased(key)
end

function PlayerInputManager:touchPressed(id, x, y, dx, dy, pressure)
end

function PlayerInputManager:touchMoved(id, x, y, dx, dy, pressure)
end

function PlayerInputManager:touchReleased(id, x, y, dx, dy, pressure)
end

function GetJoystickAxesWithDeadzone(joystick, deadzoneValue)
	local inputX, inputY = joystick:getAxes()

	if math.abs(inputX) <= deadzoneValue then inputX = 0 end
	if math.abs(inputY) <= deadzoneValue then inputY = 0 end
	
	return inputX, inputY
end

return PlayerInputManager
