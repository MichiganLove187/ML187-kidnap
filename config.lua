Config = {}

-- Item names (can be changed to match your server's items)
Config.ZiptieItem = "handcuffs"        -- Item used to restrain players
Config.KnifeItem = "weapon_knife"   -- Item used to cut zipties

-- Commands
Config.Commands = {
    carry = "carry",           -- Command to carry a player
    putInTrunk = "putintrunk", -- Command to put player in trunk
    getOutTrunk = "getouttrunk", -- Command to get out of trunk
    cutZiptie = "cutziptie"    -- Command to cut zipties
}

-- Animation Settings
Config.ZiptieTime = 3000       -- Time in ms to apply zipties
Config.CutZiptieTime = 5000    -- Time in ms to cut zipties

-- Notifications
Config.Notifications = {
    noPlayerNearby = "No player nearby!",
    cancelled = "Cancelled...",
    ziptied = "You have been zip-tied!",
    vehicleLocked = "Vehicle is locked!",
    notCloseToVehicle = "Not close enough to a vehicle trunk!",
    noVehicleNearby = "No vehicle nearby!",
    notCarryingAnyone = "You're not carrying anyone!",
    cantGetOut = "You can't get out while zip-tied!",
    needKnife = "You need a knife to cut zip-ties!",
    ziptiesCut = "Your zip-ties have been cut!"
}
