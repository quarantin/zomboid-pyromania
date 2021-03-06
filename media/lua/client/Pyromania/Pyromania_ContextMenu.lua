
Pyromania = {}

Pyromania.getIgniters = function(inventory)

	local igniters = {}

	local igniterItems = inventory:getAllEvalRecurse(function(item, player)
		return item:getType() == 'Lighter' or item:getType() == 'Matches'
	end, ArrayList.new())

	if igniterItems:size() == 0 then
		return nil
	end

	for i = 0, igniterItems:size() - 1 do

		local igniter = igniterItems:get(i)
		local name = igniter:getName()
		if not igniters[name] then
			igniters[name] = {}
		end

		table.insert(igniters[name], igniter)
	end

	return igniters
end

Pyromania.getFlammables = function(inventory)

	local flammables = {}

	local flammableItems = inventory:getAllEvalRecurse(function(item, player)
		return item:getCategory() == 'Literature'
	end, ArrayList.new())

	if flammableItems:size() == 0 then
		return nil
	end

	for i = 0, flammableItems:size() - 1 do

		local flammable = flammableItems:get(i)
		local name = flammable:getName()
		if not flammables[name] then
			flammables[name] = {}
		end

		table.insert(flammables[name], flammable)
	end

	return flammables
end

Pyromania.onFillWorldObjectContextMenu = function(playerId, context, worldobjects, test)

	local player = getSpecificPlayer(playerId)
	local inventory = player:getInventory()

	local igniters = Pyromania.getIgniters(inventory)
	if not igniters then
		return
	end

	local flammables = Pyromania.getFlammables(inventory)
	if not flammables then
		return
	end

	for _, object in ipairs(worldobjects) do
		local square = object:getSquare()
		if square then

			for igniterName, igniterValues in  pairs(igniters) do

				local rootMenu = context:addOption(getText('ContextMenu_SetFire') .. " [" .. igniterName .. " (" .. tostring(#igniterValues) .. ")]", worldobjects, nil)
				local subMenu = context:getNew(context)
				context:addSubMenu(rootMenu, subMenu)
				for flammableName, flammableValues in pairs(flammables) do
					subMenu:addOption(flammableName .. " (" .. tostring(#flammableValues) .. ")", worldobjects, Pyromania.onSetFire, player, square, igniterValues[1], flammableValues[1])
				end
			end
			return
		end
	end
end

Pyromania.onSetFire = function(worldobjects, player, square, igniter, flammable)
	if luautils.walkAdj(player, square, false) then
		ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), igniter, true, false)
		ISWorldObjectContextMenu.equip(player, player:getSecondaryHandItem(), flammable, false, false)
		ISTimedActionQueue.add(SetFireAction:new(player, square, igniter, flammable, 100))
	end
end

Events.OnFillWorldObjectContextMenu.Add(Pyromania.onFillWorldObjectContextMenu)
