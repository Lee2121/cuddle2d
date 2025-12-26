require "lib.cuddle.input.inputdevicemanager"
require "lib.cuddle.players.playermanager"

local PS4_BTN_ID_X = 1
local PS4_BTN_ID_CIRCLE = 2
local PS4_BTN_ID_SQUARE = 3
local PS4_BTN_ID_Triangle = 4

local JOYSTICK_DEADZONE = .1

local InputContext_Test  = {
	move = InputAction("vector2d", { 	xaxis = { Input_KeyboardKey('a'), Input_KeyboardKey("left"), Input_GamepadAxis("leftx") },
										yaxis = { Input_KeyboardKey('d'), Input_KeyboardKey("right"), Input_GamepadAxis("lefty") },
										xyaxis = { Input_TouchJoystick() } } ),

	spaceBar = InputAction("bool", { Input_KeyboardKey("spacebar"), Input_GamepadButton(PS4_BTN_ID_Triangle) } ),
}

local demoLogic = {}

function demoLogic:onPlayerConnected(newPlayerInstance)
	newPlayerInstance.inputManager:pushInputContext(InputContext_Test)
end

function love.load()
	PlayerManager:init()
	BindToCallback(PlayerManager.onPlayerConnectedCallbacks, demoLogic, demoLogic.onPlayerConnected)
end

function love.update()
	
end

function love.draw()
end
