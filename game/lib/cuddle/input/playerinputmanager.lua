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

	for _, actionDefinition in pairs(inputContext) do
		actionDefinition:activateForPlayer(self)
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
end

function PlayerInputManager:mousePressed(x, y, button, isTouch, presses)
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

return PlayerInputManager
