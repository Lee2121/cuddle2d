InputDeviceManager = {
	connectedDevices = {},
	onInputDeviceConnectedCallbacks = {},
	onInputDeviceDisconnectedCallbacks = {},

	-- Start Input Device Callbacks
	onKeyPressedCallbacks = {},
	onKeyReleasedCallbacks = {},

	onMousePressedCallbacks = {},
	onMouseReleasedCallbacks = {},
	onMouseMovedCallbacks = {},

	onGamepadPresseCallbacks = {},
	onGamepadReleasedCallbacks = {},
	onGamepadAxisCallbacks = {},

	onTouchPressedCallbacks = {},
	onTouchReleasedCallbacks = {},
	onTouchMovedCallbacks = {},
	-- End Input Device Callbacks
}

function InputDeviceManager:bindToKeyboardCallbacks(requestingObject, onKeyPressed, onKeyReleased)
	BindToCallback(self.onKeyPressedCallbacks, requestingObject, onKeyPressed)
	BindToCallback(self.onKeyReleasedCallbacks, requestingObject, onKeyReleased)
end

function InputDeviceManager:unregisterFromKeyboardCallbacks(requestingObject)
	UnregisterAllCallbacks(self.onKeyPressedCallbacks, requestingObject)
	UnregisterAllCallbacks(self.onKeyReleasedCallbacks, requestingObject)
end

function InputDeviceManager:bindToMouseCallbacks(requestingObject, onMousePressed, onMouseReleased, onMouseMoved)
	BindToCallback(self.onMousePressedCallbacks, requestingObject, onMousePressed)
	BindToCallback(self.onMouseReleasedCallbacks, requestingObject, onMouseReleased)
	BindToCallback(self.onMouseMovedCallbacks, requestingObject, onMouseMoved)
end

function InputDeviceManager:unregisterFromMouseCallbacks(requestingObject)
	UnregisterAllCallbacks(self.onMousePressedCallbacks, requestingObject)
	UnregisterAllCallbacks(self.onMouseReleasedCallbacks, requestingObject)
	UnregisterAllCallbacks(self.onMouseMovedCallbacks, requestingObject)
end

function InputDeviceManager:bindToGamepadCallbacks(requestingObject, onGamepadPressed, onGamepadReleased, onGamepadAxis)
	BindToCallback(self.onGamepadPressedCallbacks, requestingObject, onGamepadPressed)
	BindToCallback(self.onGamepadReleasedCallbacks, requestingObject, onGamepadReleased)
	BindToCallback(self.onGamepadAxisCallbacks, requestingObject, onGamepadAxis)
end

function InputDeviceManager:unregisterFromGamepadCallbacks(requestingObject)
	UnregisterAllCallbacks(self.onGamepadPressedCallbacks, requestingObject)
	UnregisterAllCallbacks(self.onGamepadReleasedCallbacks, requestingObject)
	UnregisterAllCallbacks(self.onGamepadAxisCallbacks, requestingObject)
end

function InputDeviceManager:bindToTouchCallbacks(requestingObject, onTouchPressed, onTouchReleased, onTouchMoved)
	BindToCallback(self.onTouchPressedCallbacks, requestingObject, onTouchPressed)
	BindToCallback(self.onTouchReleasedCallbacks, requestingObject, onTouchReleased)
	BindToCallback(self.onTouchMovedCallbacks, requestingObject, onTouchMoved)
end

function InputDeviceManager:unregisterFromTouchCallbacks(requestingObject)
	UnregisterAllCallbacks(self.onTouchPressedCallbacks, requestingObject)
	UnregisterAllCallbacks(self.onTouchReleasedCallbacks, requestingObject)
	UnregisterAllCallbacks(self.onTouchMovedCallbacks, requestingObject)
end

function love.gamepadpressed(joystick, button)
	if not InputDeviceManager:isInputDeviceConnected(joystick) then
		InputDeviceManager:connectDevice(joystick)
	end
	BroadcastCallback(InputDeviceManager.onGamepadPressedCallbacks, joystick, button)
end

function love.gamepadreleased(joystick, button)
	BroadcastCallback(InputDeviceManager.onGamepadReleasedCallbacks, joystick, button)
end

function love.joystickremoved(joystick)
	if InputDeviceManager:isInputDeviceConnected(joystick) then
		InputDeviceManager:disconnectDevice(joystick)
	end
end

function love.mousemoved(x, y, dx, dy, isTouch)
	BroadcastCallback(InputDeviceManager.onMouseMovedCallbacks, x, y, dy, dy, isTouch)
end

function love.mousepressed(x, y, button, isTouch, presses)
	if not InputDeviceManager:isInputDeviceConnected("keyboard") then
		InputDeviceManager:connectDevice("keyboard")
	end
	BroadcastCallback(InputDeviceManager.onMousePressedCallbacks, x, y, button, isTouch, presses)
end

function love.mousereleased(x, y, button, isTouch, presses)
	BroadcastCallback(InputDeviceManager.onmouseReleasedCallbacks, x, y, button, isTouch, presses)
end

function love.keypressed(key, scancode, isRepeat)
	if not InputDeviceManager:isInputDeviceConnected("keyboard") then
		InputDeviceManager:connectLocalPlayer("keyboard")
	end
	BroadcastCallback(InputDeviceManager.onKeyPressedCallbacks, key, scancode, isRepeat)
end

function love.keyreleased(key)
	BroadcastCallback(InputDeviceManager.onKeyReleasedCallbacks, key)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
	if InputDeviceManager:isInputDeviceConnected("touch") then
		InputDeviceManager:connectDevice("touch")
	end
	BroadcastCallback(InputDeviceManager.onTouchPressedCallbacks, id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	BroadcastCallback(InputDeviceManager.onTouchMovedCallbacks, id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	BroadcastCallback(InputDeviceManager.onTouchReleasedCallbacks, id, x, y, dx, dy, pressure)
end

function InputDeviceManager:isInputDeviceConnected(inputDevice)
	for i, connectedDevice in ipairs(self.connectedDevices) do
		if connectedDevice.inputDevice == inputDevice then
			return false
		end
	end
	return true
end

function InputDeviceManager:connectDevice(inputDevice)
	print("Connecting input device", inputDevice)
	table.insert(self.connectedDevices, inputDevice)
	BroadcastCallback(self.onInputDeviceConnectedCallbacks, inputDevice)
end

function InputDeviceManager:disconnectDevice(inputDevice)
	print("Disconnecting input device", inputDevice)
	table.remove(self.connectedDevices, inputDevice)
	BroadcastCallback(self.onInputDeviceDisconnectedCallbacks, inputDevice)
end

return InputDeviceManager
