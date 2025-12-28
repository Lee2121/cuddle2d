require "lib.cuddle2d.utils.callbacks"
require "lib.cuddle2d.input.inputdevicemanager"
require "lib.cuddle2d.players.playerinstance"

PlayerManager = {
	connectedPlayers = {},

	onPlayerConnectedCallbacks = {},
	onPlayerDisconnectedCallbacks = {},
}

function PlayerManager:init()
	BindToCallback(InputDeviceManager.onInputDeviceConnectedCallbacks, self, self.onInputDeviceConnected)
	BindToCallback(InputDeviceManager.onInputDeviceDisconnectedCallbacks, self, self.onInputDeviceDisconnected)
end

function PlayerManager:onInputDeviceConnected(inputDevice)
	if not self:isAnyPlayerUsingDevice() then
		self:connectLocalPlayer(inputDevice)
	end
end

function PlayerManager:onInputDeviceDisconnected(inputDevice)
	local associatedPlayer = self:getPlayerUsingDevice(inputDevice)
	if associatedPlayer ~= nil then
		self:disconnectLocalPlayer()
	end
end

function PlayerManager:getPlayerUsingDevice(inputDevice)
	for i, player in ipairs(self.connectedPlayers) do
		if player.inputDevice == inputDevice then
			return player
		end
	end
	return nil
end

function PlayerManager:isAnyPlayerUsingDevice(inputDevice)
	return (PlayerManager:getPlayerUsingDevice(inputDevice) ~= nil)
end

function PlayerManager:connectLocalPlayer(inputDevice)

	-- make sure this input device isn't already being used
	if self:isAnyPlayerUsingDevice(inputDevice) then
		error("Attempting to register a player with an input device that is already being used")
		return
	end

	local newPlayerInstance = PlayerInstance(inputDevice, "local")

	print("Connecting local player ", table.maxn(self.connectedPlayers), " with device ", inputDevice)
	table.insert(self.connectedPlayers, newPlayerInstance)
	BroadcastCallback(self.onPlayerConnectedCallbacks, newPlayerInstance)
end

function PlayerManager:disconnectLocalPlayer(player)
	for i, connectedPlayer in ipairs(self.connectedPlayers) do
		if connectedPlayer == player then
			print("Disconnecting player ", player)
			table.remove(self.connectedPlayers, i)
			BroadcastCallback(self.onPlayerDisconnectedCallbacks, connectedPlayer)
			break
		end
	end
end

function PlayerManager:connectRemotePlayer()
	error("implement ConnectRemotePlayer")
end

function PlayerManager:disconnecteRemotePlayer()
	error("implement DisconnecteRemotePlayer")
end

return PlayerManager
