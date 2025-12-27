InputDeviceManager = require "lib.cuddle.input.inputdevicemanager"
require "lib.cuddle.utils.callbacks"
require "lib.cuddle.input.inputactions"

PlayerInputManager = {}

setmetatable(PlayerInputManager, PlayerInputManager)
PlayerInputManager.__index = PlayerInputManager

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

	self.actionTriggeredCallbacks = {}
	self.actionStoppedCallbacks = {}
	self.activeInputDevice = {}

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
		self.activeInputDevice = inputDevice
	elseif inputDevice == "touch" then
		self.activeInputDevice = inputDevice
	elseif InputDeviceManager.isInputDeviceAGamepad(inputDevice) then
		self.activeInputDevice = inputDevice
	else
		error(string.format("failed to find registration behavior for input device %s"), inputDevice)
	end
end

function PlayerInputManager:unregisterInputDevice(inputDevice)
	if inputDevice == "mouseAndKeyboard" then
		self.activeInputDevice = nil
	elseif inputDevice == "touch" then
		self.activeInputDevice = nil
	elseif InputDeviceManager.isInputDeviceAGamepad(inputDevice) then
		self.activeInputDevice = nil
	else
		error(string.format("failed to find unregistration behavior for input device %s"), inputDevice)
	end
end

function PlayerInputManager:isInputDeviceUsedByPlayer(inputDevice)
	return self.activeInputDevice == inputDevice
end

return PlayerInputManager
