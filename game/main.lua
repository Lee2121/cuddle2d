require "lib.cuddle.input.inputdevicemanager"
require "lib.cuddle.input.inputdefs"
require "lib.cuddle.input.inputmods"
require "lib.cuddle.players.playermanager"

local PS4_BTN_ID_X = 1
local PS4_BTN_ID_CIRCLE = 2
local PS4_BTN_ID_SQUARE = 3
local PS4_BTN_ID_Triangle = 4

local JOYSTICK_DEADZONE = .1

local InputContext_Test  = {
	move = InputAction("vector2d", { xaxis = { InputDef_KeyboardKey('a'), InputDef_KeyboardKey("left"), InputDef_KeyboardKey('d', InputMod_Invert()), InputDef_KeyboardKey("right", InputMod_Invert()), InputDef_GamepadAxis("leftx", InputMod_Deadzone(JOYSTICK_DEADZONE) ) },
									 yaxis = { InputDef_KeyboardKey('w'), InputDef_KeyboardKey("up"), InputDef_KeyboardKey('s', InputMod_Invert()), InputDef_KeyboardKey("down", InputMod_Invert()), InputDef_GamepadAxis("lefty", InputMod_Deadzone(JOYSTICK_DEADZONE) ) },
									 xyaxis = { InputDef_TouchJoystick() } } ),

	spaceBar = InputAction("bool", { InputDef_KeyboardKey("spacebar"), InputDef_GamepadButton(PS4_BTN_ID_Triangle) } ),

	mouseMoved = InputAction("vector2d", { xyaxis = { InputDef_MousePosition() } } ),

	mouseClicked = InputAction("bool", { InputDef_MouseClicked(1) } )
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
