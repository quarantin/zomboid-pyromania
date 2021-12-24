local Pyromania = {}

Pyromania.pyromaniacPlayers = {}

Pyromania.pyromaniacStressIncrease = 0.005

Pyromania.flammableToEnergy = function(flammable)
	return 50
end

Pyromania.setFire = function(square, flammable)

	local anywhere = false
	local energy = Pyromania.flammableToEnergy(flammable)

	local fire = IsoFire.new(getCell(), square, anywhere, energy)
	square:AddTileObject(fire)
end

Pyromania.decreasePyromaniacStress = function(player)
	if player:HasTrait('Pyromaniac') then
		player:getStats():setStress(0)
	end
end

Pyromania.OnGameBoot = function()
	TraitFactory.addTrait("Pyromaniac", getText("UI_trait_pyromaniac"), -2, getText("UI_trait_pyromaniacdesc"), false)
	TraitFactory.setMutualExclusive("Pyromaniac", "Pacifist")
end

Pyromania.OnCreatePlayer = function(playerId, player)
	if player:HasTrait('Pyromaniac') then
		Pyromania.pyromaniacPlayers[playerId] = player
	end
end

Pyromania.EveryOneMinute = function()
	print('DEBUG: EveryOneMinute')
	for playerId, player in pairs(Pyromania.pyromaniacPlayers) do
		local stats = player:getStats()
		print("DEBUG", player:getFullName(), stats:getStress())
		stats:setStress(stats:getStress() + Pyromania.pyromaniacStressIncrease)
	end
end

return Pyromania
