PlayerInputManager = require "lib.cuddle.input.playerinputmanager"

PlayerInstance = {}

function PlayerInstance:new(inputDevice, connectionType)
	self.inputDevice = inputDevice
	self.connectionType = connectionType
	
	self.playerInputManager = PlayerInputManager(inputDevice)
end

return PlayerInstance
