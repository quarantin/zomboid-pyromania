function onFillWorldObjectContextMenu(playerId, context, worldobjects, test)

	local player = getSpecificPlayer(playerId)
	local inventory = player:getInventory()
	
	local ignitions = inventory:getAllEvalRecurse(function(item, player)
		return item:getType() == 'Lighter' or item:getType() == 'Matches'
	end, ArrayList.new())

	if ignitions:size() <= 0 then
		return
	end

	local flamables = inventory:getAllEvalRecurse(function(item, player)
		return item:getCategory() == 'Literature'
	end, ArrayList.new())

	if flamables:size() <= 0 then
		return
	end

	for _, object in ipairs(worldobjects) do
		local square = object:getSquare()
		if square then

			for i = 0, ignitions:size() - 1 do

				local ignition = ignitions:get(i)
				print("Ignition", ignition:getName())
				local rootMenu = context:addOption(getText('ContextMenu_SetFire') .. " (" .. ignition:getName() .. ")", worldobjects, nil)
				local subMenu = context:getNew(context)
				context:addSubMenu(rootMenu, subMenu)
				for j = 0, flamables:size() - 1 do
					local flamable = flamables:get(j)
					print("Flamable", flamable:getName())
					subMenu:addOption(flamable:getName(), worldobjects, onSetFire, player, square, ignition, flamable)
				end
				return
			end
		end
	end
end

function onSetFire(worldobjects, player, square, ignition, flamable)
	if luautils.walkAdj(player, square, false) then
		ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), ignition, true, false)
		ISWorldObjectContextMenu.equip(player, player:getSecondaryHandItem(), flamable, false, false)
		ISTimedActionQueue.add(SetFireAction:new(player, square, ignition, flamable, 100))
	end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
