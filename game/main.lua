require "lib.cuddle.input.inputdevicemanager"
require "lib.cuddle.input.inputdefs"
require "lib.cuddle.players.playermanager"

local PS4_BTN_ID_X = 1
local PS4_BTN_ID_CIRCLE = 2
local PS4_BTN_ID_SQUARE = 3
local PS4_BTN_ID_Triangle = 4

local JOYSTICK_DEADZONE = .1

local InputContext_Test  = {
	move = InputAction("vector2d", { 	xaxis = { InputDef_KeyboardKey('a'), InputDef_KeyboardKey("left"), InputDef_GamepadAxis("leftx") },
										yaxis = { InputDef_KeyboardKey('d'), InputDef_KeyboardKey("right"), InputDef_GamepadAxis("lefty") },
										xyaxis = { InputDef_TouchJoystick() } } ),

	spaceBar = InputAction("bool", { InputDef_KeyboardKey("spacebar"), InputDef_GamepadButton(PS4_BTN_ID_Triangle) } ),
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
