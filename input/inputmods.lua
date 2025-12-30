local InputMod_Base = {}

InputMod_Base.__index = InputMod_Base

function InputMod_Base:createMod()
	local mod = {}
	mod.__index = mod
	setmetatable(mod, self)
	return mod
end

function InputMod_Base:new(...)
end

function InputMod_Base:__call(...)
	local modInstance = setmetatable({}, self)
	modInstance:new(...)
	return modInstance
end

InputMod_Invert = InputMod_Base:createMod()
function InputMod_Invert:applyMod(rawValue)
	return rawValue * -1
end
