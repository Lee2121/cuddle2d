InputDeviceManager = require "lib.cuddle.input.inputdevicemanager"
require "lib.cuddle.utils.callbacks"
require "lib.cuddle.input.inputactions"

PlayerInputManager = {
	actionTriggeredCallbacks = {},
	actionStoppedCallbacks = {}
}

setmetatable(PlayerInputManager, PlayerInputManager)
PlayerInputManager.__index = PlayerInputManager

local registeredInputDevices = {
	mouseAndKeyboard = {},
	touch = {},
	gamepad = {}
}

local inputContextStack = {}

function PlayerInputManager:__call(inputDevice)
	local newInstance = setmetatable({}, self)
	newInstance:new(inputDevice)
	return newInstance
end

function PlayerInputManager:new(inputDevice)

	if inputDevice == nil then
		error("invalid input device!")
	end
	
	self:registerInputDevice(inputDevice)
end

function PlayerInputManager:pushInputContext(inputContext)
	print("Pushing Input Context ", inputContext)
	table.insert(inputContextStack, inputContext)

	for inputAction, actionDefinition in pairs(inputContext) do
		
	end
end

function PlayerInputManager:popInputContext(inputContext)
	print("Removing Input Context ", inputContext)
	for i, context in ipairs(inputContext) do
		if context == inputContext then
			table.remove(inputContextStack, i)
			break
		end
	end
end

function PlayerInputManager:registerInputDevice(inputDevice)
	if inputDevice == "mouseAndKeyboard" then
		-- InputDeviceManager:bindToKeyboardCallbacks(self, self.keyPressed, self.keyReleased)
		registeredInputDevices.mouseAndKeyboard = inputDevice
	elseif inputDevice == "touch" then
		-- InputDeviceManager:bindToTouchCallbacks(self, self.touchPressed, self.touchReleased, self.touchMoved)
		registeredInputDevices.touch = inputDevice
	elseif InputDeviceManager.isInputDeviceAGamepad(inputDevice) then
		-- InputDeviceManager:bindToGamepadCallbacks(self, self.gamepadPressed, self.gamepadReleased, self.gamepadAxis)
		registeredInputDevices.gamepad = inputDevice
	else
		error(string.format("failed to find registration behavior for input device %s"), inputDevice)
	end
end

function PlayerInputManager:unregisterInputDevice(inputDevice)
	if inputDevice == "mouseAndKeyboard" then
		-- InputDeviceManager:unregisterFromMouseAndKeyboardCallbacks(self)
		registeredInputDevices.mouseKeyboard = nil
	elseif inputDevice == "touch" then
		-- InputDeviceManager:unregisterFromTouchCallbacks(self)
		registeredInputDevices.touch = nil
	elseif InputDeviceManager.isInputDeviceAGamepad(inputDevice) then
		-- InputDeviceManager:unregisterFromGamepadCallbacks(self)
		registeredInputDevices.gamepad = nil
	else
		error(string.format("failed to find unregistration behavior for input device %s"), inputDevice)
	end
end

local function GetInputNameFromDevice(inputDevice)
	if inputDevice == "mouseAndKeyboard" then
		return "mouseAndKeyboard"
	elseif inputDevice == "touch" then
		return "touch"
	elseif InputDeviceManager.isInputDeviceAGamepad(inputDevice) then
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

	local function getMouseAndKeyboardActionValue(actionInputs)
		return love.mouse.isDown(actionInputs)
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
				
				if inputType == "mouseAndKeyboard" then
					result = getMouseAndKeyboardActionValue(actionInputs)
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
