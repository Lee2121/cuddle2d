InputDeviceManager = require "lib.cuddle.input.inputdevicemanager"
PlayerManager = require "lib.cuddle.players.playermanager"

local PS4_BTN_ID_X = 1
local PS4_BTN_ID_CIRCLE = 2
local PS4_BTN_ID_SQUARE = 3
local PS4_BTN_ID_Triangle = 4

local JOYSTICK_DEADZONE = .1

local InputContext_Test  = {
	move = InputAction:new("vector2d", { 	xaxis = { Input_KeyboardKey:new('a'), Input_KeyboardKey:new("left"), Input_GamepadAxis:new("leftx") },
										yaxis = { Input_KeyboardKey:new('d'), Input_KeyboardKey:new("right"), Input_GamepadAxis:new("lefty") },
										xyaxis = { Input_TouchJoystick:new() } } ),

	spaceBar = InputAction:new("bool", { Input_KeyboardKey:new("spacebar"), Input_GamepadButton:new(PS4_BTN_ID_Triangle) } ),
}

function love.load()
	PlayerManager:init()
end

function love.update()
	
end

function love.draw()
end
