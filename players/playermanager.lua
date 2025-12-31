require "lib.cuddle2d.utils.callbacks"
require "lib.cuddle2d.input.inputdevicemanager"
require "lib.cuddle2d.players.playerinstance"

PlayerManager = {
	connectedPlayers = {},

	onPlayerConnectedCallbacks = {},
	onPlayerDisconnectedCallbacks = {},

	defaultPlayerConfig = {}
}

function PlayerManager:init(defaultPlayerConfig)
	BindToCallback(InputDeviceManager.onInputDeviceConnectedCallbacks, self, self.onInputDeviceConnected)
	BindToCallback(InputDeviceManager.onInputDeviceDisconnectedCallbacks, self, self.onInputDeviceDisconnected)

	self.defaultPlayerConfig = defaultPlayerConfig
end

function PlayerManager:onInputDeviceConnected(inputDevice)
	if not self:isAnyPlayerUsingDevice() then
		self:connectLocalPlayer(inputDevice, self.defaultPlayerConfig)
	end
end

function PlayerManager:onInputDeviceDisconnected(inputDevice)
	local associatedPlayer = self:getPlayerUsingDevice(inputDevice)
	if associatedPlayer ~= nil then
		self:disconnectLocalPlayer(associatedPlayer)
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

function PlayerManager:connectLocalPlayer(inputDevice, playerConfig)

	-- make sure this input device isn't already being used
	if self:isAnyPlayerUsingDevice(inputDevice) then
		error("Attempting to register a player with an input device that is already being used")
		return
	end

	local newPlayerInstance = PlayerInstance(inputDevice, "local", playerConfig)

	print("Connecting local player ", table.maxn(self.connectedPlayers) + 1, " with device ", inputDevice)
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

function PlayerManager:getPlayerIndex(player)
	for playerIndex, currPlayer in ipairs(self.connectedPlayers) do
		if currPlayer == player then
			return playerIndex
		end
	end
	return -1
end

function PlayerManager:connectRemotePlayer()
	error("implement ConnectRemotePlayer")
end

function PlayerManager:disconnecteRemotePlayer()
	error("implement DisconnecteRemotePlayer")
end

return PlayerManager
