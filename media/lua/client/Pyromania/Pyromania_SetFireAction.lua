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
	self.character:SetVariable('LootPosition', 'Low')
end

function SetFireAction:stop()
	ISBaseTimedAction.stop(self);
end

function SetFireAction:perform()
	ISBaseTimedAction.perform(self)
	self.character:setSecondaryHandItem(nil)
	self.character:getInventory():Remove(self.flammable)
	Pyromania.setFire(self.square, self.flammable)
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
