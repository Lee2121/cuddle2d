local InputMod_Base = {}

InputMod_Base.__index = InputMod_Base

function InputMod_Base:createMod()
	local mod = {}
	mod.__index = mod
	setmetatable(mod, self)
	return mod
end

function InputMod_Base:new()
end

function InputMod_Base:__call(...)
	local inputInstance = setmetatable({}, self)
	inputInstance:new()
	return inputInstance
end

InputMod_Invert = InputMod_Base:createMod()
function InputMod_Invert.applyMod(rawValue)
	return rawValue * -1
end

InputMod_Deadzone = InputMod_Base:createMod()
function InputMod_Deadzone:new(deadzoneValue)
	self.deadzoneValue = deadzoneValue
end

function InputMod_Deadzone:ApplyMod(rawValue)
	local inputX, inputY = unpack(rawValue)

	local function mapToDeadzone(rawValue, deadzoneValue)
		if rawValue < deadzoneValue then
			return 0
		end
		return ((rawValue) * (1 - deadzoneValue)) + deadzoneValue
	end

	inputX = mapToDeadzone(inputX, self.deadzoneValue)
	inputY = mapToDeadzone(inputY, self.deadzoneValue)

	return inputX, inputY
end
