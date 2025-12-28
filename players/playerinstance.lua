PlayerInputManager = require "lib.cuddle.input.playerinputmanager"

PlayerInstance = {}

setmetatable(PlayerInstance, PlayerInstance)
PlayerInstance.__index = PlayerInstance

function PlayerInstance:__call(inputDevice, connectionType)
	local newInstance = setmetatable({}, self)
	newInstance:new(inputDevice, connectionType)
	return newInstance
end

function PlayerInstance:new(inputDevice, connectionType)
	self.inputDevice = inputDevice
	self.connectionType = connectionType
	self.inputManager = PlayerInputManager(inputDevice)
end

return PlayerInstance
