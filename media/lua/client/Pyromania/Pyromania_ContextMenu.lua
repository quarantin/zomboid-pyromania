
Pyromania = {}

Pyromania.igniterPredicate = function(item, player)
	if getCore():getGameVersion():getMajor() < 42 then
		return item:getType() == 'Lighter' or item:getType() == 'Matches'
	else
		local scriptItem = item:getScriptItem()
		local displayCategory = scriptItem:getDisplayCategory()
		return displayCategory == "FireSource"
	end
end

Pyromania.getIgniters = function(inventory)

	local igniters = {}

	local igniterItems = inventory:getAllEvalRecurse(Pyromania.igniterPredicate, ArrayList.new())
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

			local setFireOption = context:addOption(getText('ContextMenu_SetFire'), worldobjects)
			local igniterMenu = context:getNew(context)
			context:addSubMenu(setFireOption, igniterMenu)

			for igniterName, igniterValues in  pairs(igniters) do

				local igniterLabel = igniterName .. " (" .. tostring(#igniterValues) .. ")"
				local igniterOption = igniterMenu:addOption(igniterLabel, worldobjects)
				local flammableMenu = context:getNew(context)
				context:addSubMenu(igniterOption, flammableMenu)

				for flammableName, flammableValues in pairs(flammables) do
					local flammableLabel = flammableName .. " (" .. tostring(#flammableValues) .. ")"
					flammableMenu:addOption(
						flammableLabel,
						worldobjects,
						Pyromania.onSetFire,
						player,
						square,
						igniterValues[1],
						flammableValues[1]
					)
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
