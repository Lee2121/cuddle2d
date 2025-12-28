function BindToCallback(callbacksList, requestingObject, callbackFunction)
	-- create a callback binding with weak object references, which ensures these callback lists don't prevent garbage collection from cleaning these objects up
	local weakCallbackBinding = setmetatable( {obj = requestingObject }, { __mode = "vk"})
	table.insert(callbacksList, { weakCallbackBinding, callbackFunction })
end

function BroadcastCallback(callbacksList, ...)
	-- iterate backwards in case we need to remove an element
	for callbackIndex = #callbacksList, 1, -1 do
		local callback = callbacksList[callbackIndex]
		local callbackObj = callback[1].obj
		if callbackObj ~= nil then
			callback[2](callbackObj, ...)	
		else
			table.remove(callbacksList, callbackIndex)
		end
	end
end

function UnregisterCallback(callbacksList, requestingObject, callbackFunction)
	if callbacksList == nil then return end
	for i = #callbacksList, 1, -1 do
		if callbacksList[i][2] == callbackFunction and callbacksList[i][1].obj == requestingObject then
			table.remove(callbacksList, i)
		end
	end
end

function UnregisterAllCallbacks(callbacksList, requestingObject)
	if callbacksList == nil then return end
	for i = #callbacksList, 1, -1 do
		if callbacksList[i][1].obj == requestingObject then
			table.remove(callbacksList, i)
		end
	end
end
