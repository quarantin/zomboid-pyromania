local Pyromania = require('Pyromania/Pyromania_Trait')

Events.OnGameBoot.Add(Pyromania.OnGameBoot)
Events.OnCreatePlayer.Add(Pyromania.OnCreatePlayer)
Events.EveryOneMinute.Add(Pyromania.EveryOneMinute)
