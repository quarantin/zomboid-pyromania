local Pyromania = require('Pyromania/Pyromania_Trait')

SetFireAction = ISBaseTimedAction:derive('SetFireAction')

function SetFireAction:isValid()
	return true
end

function SetFireAction:waitToStart()
	self.character:faceThisObject(self.window)
	return self.character:shouldBeTurning()
end

function SetFireAction:update()
	self.character:faceThisObject(self.window)
end

function SetFireAction:start()
	self:setActionAnim('Loot')
	self.character:SetVariable('LootPosition', 'Mid')
end

function SetFireAction:stop()
	ISBaseTimedAction.stop(self);
end

function SetFireAction:perform()
	ISBaseTimedAction.perform(self)
	self.character:setSecondaryHandItem(nil)
	self.character:getInventory():Remove(self.flammable)
	local fire = IsoFire.new(getCell(), self.square)
	fire:AttachAnim("Fire", "01", 4, IsoFireManager.FireAnimDelay, -16, -78, true, 0, false, 0.7, IsoFireManager.FireTintMod)
	self.square:AddTileObject(fire)
	self.character:setPrimaryHandItem(nil)
	Pyromania.decreasePyromaniacStress(self.character)
end

function SetFireAction:new(character, square, igniter, flammable, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.square = square
	o.igniter = igniter
	o.flammable = flammable
	o.maxTime = time
	if o.character:isTimedActionInstant() then o.maxTime = 1 end
	return o
end
