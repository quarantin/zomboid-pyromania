function onFillWorldObjectContextMenu(playerId, context, worldobjects, test)

	local player = getSpecificPlayer(playerId)
	local inventory = player:getInventory()
	
	local igniters = inventory:getAllEvalRecurse(function(item, player)
		return item:getType() == 'Lighter' or item:getType() == 'Matches'
	end, ArrayList.new())

	if igniters:size() <= 0 then
		return
	end

	local flammables = inventory:getAllEvalRecurse(function(item, player)
		return item:getCategory() == 'Literature'
	end, ArrayList.new())

	if flammables:size() <= 0 then
		return
	end

	for _, object in ipairs(worldobjects) do
		local square = object:getSquare()
		if square then

			for i = 0, igniters:size() - 1 do

				local igniter = igniters:get(i)
				local rootMenu = context:addOption(getText('ContextMenu_SetFire') .. " (" .. igniter:getName() .. ")", worldobjects, nil)
				local subMenu = context:getNew(context)
				context:addSubMenu(rootMenu, subMenu)
				for j = 0, flammables:size() - 1 do
					local flammable = flammables:get(j)
					subMenu:addOption(flammable:getName(), worldobjects, onSetFire, player, square, igniter, flammable)
				end
				return
			end
		end
	end
end

function onSetFire(worldobjects, player, square, igniter, flammable)
	if luautils.walkAdj(player, square, false) then
		ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), igniter, true, false)
		ISWorldObjectContextMenu.equip(player, player:getSecondaryHandItem(), flammable, false, false)
		ISTimedActionQueue.add(SetFireAction:new(player, square, igniter, flammable, 100))
	end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
