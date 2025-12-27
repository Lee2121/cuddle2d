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
	local inputContextInstance = inputContext
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
		registeredInputDevices.mouseAndKeyboard = inputDevice
	elseif inputDevice == "touch" then
		registeredInputDevices.touch = inputDevice
	elseif InputDeviceManager.isInputDeviceAGamepad(inputDevice) then
		registeredInputDevices.gamepad = inputDevice
	else
		error(string.format("failed to find registration behavior for input device %s"), inputDevice)
	end
end

function PlayerInputManager:unregisterInputDevice(inputDevice)
	if inputDevice == "mouseAndKeyboard" then
		registeredInputDevices.mouseAndKeyboard = nil
	elseif inputDevice == "touch" then
		registeredInputDevices.touch = nil
	elseif InputDeviceManager.isInputDeviceAGamepad(inputDevice) then
		registeredInputDevices.gamepad = nil
	else
		error(string.format("failed to find unregistration behavior for input device %s"), inputDevice)
	end
end

function PlayerInputManager:isInputDeviceUsedByPlayer(inputDevice)
	if inputDevice == "mouseAndKeyboard" then
		return registeredInputDevices.mouseAndKeyboard ~= nil
	elseif inputDevice == "touch" then
		return registeredInputDevices.touch ~= nil
	elseif InputDeviceManager.isInputDeviceAGamepad(inputDevice) then
		return registeredInputDevices.gamepad == inputDevice
	else
		error(string.format("failed to find input device %s"), inputDevice)
		return false
	end
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
