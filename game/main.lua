require "lib.cuddle.input.inputdevicemanager"
require "lib.cuddle.input.inputdefs"
require "lib.cuddle.input.inputmods"
require "lib.cuddle.players.playermanager"

local PS4_BTN_ID_X = 1
local PS4_BTN_ID_CIRCLE = 2
local PS4_BTN_ID_SQUARE = 3
local PS4_BTN_ID_Triangle = 4

local JOYSTICK_DEADZONE = .1

local InputContext_Test = {
	-- move = InputAction_Vector2({ xaxis = { InputDef_KeyboardKey('a'), InputDef_KeyboardKey("left"), InputDef_KeyboardKey('d', InputMod_Invert()), InputDef_KeyboardKey("right", InputMod_Invert()), InputDef_GamepadAxis("leftx", InputMod_Deadzone(JOYSTICK_DEADZONE) ) },
	-- 							 yaxis = { InputDef_KeyboardKey('w'), InputDef_KeyboardKey("up"), InputDef_KeyboardKey('s', InputMod_Invert()), InputDef_KeyboardKey("down", InputMod_Invert()), InputDef_GamepadAxis("lefty", InputMod_Deadzone(JOYSTICK_DEADZONE) ) },
	-- 							 xyaxis = { InputDef_TouchJoystick() } } ),

	jump = InputAction_Bool( { InputDef_KeyboardKey("space"), InputDef_GamepadButton(PS4_BTN_ID_SQUARE) } ),

	mouseMoved = InputAction_Vector2( { xyaxis = { InputDef_MousePosition() } } ),

	leftMouseClick = InputAction_Bool( { InputDef_MouseClicked(1), InputDef_KeyboardKey("return") } )
}

local demoLogic = {}

function demoLogic:onPlayerConnected(newPlayerInstance)

	self.playerInstance = newPlayerInstance

	newPlayerInstance.inputManager:pushInputContext(InputContext_Test)

	newPlayerInstance.inputManager:bindActionCallbacks(self, InputContext_Test.jump, self.onJumpStarted)
end

function demoLogic:onJumpStarted(value)
	print("jump action detected", value)
end

function love.load()
	PlayerManager:init()
	BindToCallback(PlayerManager.onPlayerConnectedCallbacks, demoLogic, demoLogic.onPlayerConnected)
end

function love.update()
	if demoLogic.playerInstance ~= nil then
		local jumpvalue = demoLogic.playerInstance.inputManager:getActionValue(InputContext_Test.jump)
		print("jump val: ", jumpvalue)
		local mousevalue = demoLogic.playerInstance.inputManager:getActionValue(InputContext_Test.mouseMoved)
		print("mouse pos: ", mousevalue[1], mousevalue[2])
	end
end

function love.draw()
end
