PlayerInputManager = require "lib.cuddle2d.input.playerinputmanager"

PlayerInstance = {}

setmetatable(PlayerInstance, PlayerInstance)
PlayerInstance.__index = PlayerInstance

function PlayerInstance:__call(inputDevice, connectionType, config)
	local newInstance = setmetatable({}, self)
	newInstance:new(inputDevice, connectionType, config)
	return newInstance
end

function PlayerInstance:new(inputDevice, connectionType, config)
	self.inputDevice = inputDevice
	self.connectionType = connectionType
	self.inputManager = PlayerInputManager(inputDevice, config)
end

return PlayerInstance
