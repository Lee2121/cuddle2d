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

	onGamepadPressedCallbacks = {},
	onGamepadReleasedCallbacks = {},
	onGamepadAxisCallbacks = {},
	onGamepadHatCallbacks = {},

	onTouchPressedCallbacks = {},
	onTouchReleasedCallbacks = {},
	onTouchMovedCallbacks = {},
	-- End Input Device Callbacks
}

function love.joystickpressed(joystick, button)
	if not InputDeviceManager:isInputDeviceConnected(joystick) then
		InputDeviceManager:connectDevice(joystick)
	end
	BroadcastCallback(InputDeviceManager.onGamepadPressedCallbacks, joystick, button)
end

function love.joystickreleased(joystick, button)
	BroadcastCallback(InputDeviceManager.onGamepadReleasedCallbacks, joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
	BroadcastCallback(InputDeviceManager.onGamepadAxisCallbacks, joystick, axis, value)
end

function love.joystickhat(joystick, hat, direction)
	BroadcastCallback(InputDeviceManager.onGamepadHatCallbacks, joystick, hat, direction)
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
	if not InputDeviceManager:isInputDeviceConnected("mouseAndKeyboard") then
		InputDeviceManager:connectDevice("mouseAndKeyboard")
	end
	BroadcastCallback(InputDeviceManager.onMousePressedCallbacks, x, y, button, isTouch, presses)
end

function love.mousereleased(x, y, button, isTouch, presses)
	BroadcastCallback(InputDeviceManager.onMouseReleasedCallbacks, x, y, button, isTouch, presses)
end

function love.keypressed(key, scancode, isRepeat)
	if not InputDeviceManager:isInputDeviceConnected("mouseAndKeyboard") then
		InputDeviceManager:connectDevice("mouseAndKeyboard")
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
		if connectedDevice == inputDevice then
			return true
		end
	end
	return false
end

function InputDeviceManager.isInputDeviceAGamepad(inputDevice)
	for _, joystick in ipairs(love.joystick.getJoysticks()) do
		if joystick == inputDevice then
			return true
		end
	end
	return false
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
