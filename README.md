Steps to use:
1. Navigate to your game's `/lib` directory.
2. Right-click, and open git bash.
3. Paste in `git submodule add https://github.com/Lee2121/cuddle2d.git` and hit enter.
4. Make sure you do not have any of the core love input handling callbacks in your project (`love.keyboardpresssed`, `love.mousepressed`, `love.joystickaxis`, etc). These will all be handled by cuddle2d.
5. In your main.lua file, add `require "lib.cuddle2d.init`
6. In `function love.load()`, call `PlayerManager:init()`
7. Define Input Mapping Contexts. Create a new table. Inside the table, the keys are the name of the input actions. Each input action key should point to a child of `InputAction_Base`. Eg:

```
local InputContext_Test = {
	move = InputAction_Vector2({ xaxis = { InputDef_KeyboardKey('a'), InputDef_KeyboardKey("left"), InputDef_KeyboardKey('d', InputMod_Invert()), InputDef_KeyboardKey("right", InputMod_Invert()), InputDef_GamepadAxis("leftx", InputMod_Deadzone(JOYSTICK_DEADZONE) ) },
								 yaxis = { InputDef_KeyboardKey('w', InputMod_Invert()), InputDef_KeyboardKey("up", InputMod_Invert()), InputDef_KeyboardKey('s'), InputDef_KeyboardKey("down"), InputDef_GamepadAxis("lefty", InputMod_Deadzone(JOYSTICK_DEADZONE) ) },
								 xyaxis = { InputDef_Touch() } } ),

	jump = InputAction_Bool( { InputDef_KeyboardKey("space"), InputDef_GamepadButton(PS4_BTN_ID_SQUARE) } ),

	mouseMoved = InputAction_Vector2( { xyaxis = { InputDef_MousePosition() } } ),

	leftMouseClick = InputAction_Bool( { InputDef_MouseClicked(1), InputDef_KeyboardKey("return") } ),

	leftScreenTouch = InputAction_Vector2( { InputDef_Touch("left") } )
}
```

8. The PlayerManager has `onPlayerConnectedCallbacks` that you can listen to for new players.
9. That callback provides a `playerInstance`. You can use that `playerInstance` to push or pop input contexts, using `playerInstance.inputManager:pushInputContext(inputContextName)` and `playerInstance.inputManager:popInputContext(inputContextName)`

See https://github.com/Lee2121/cuddle2dtest as an example.
