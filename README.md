# ML187-KIDNAP

A Simple script that allows players to restrain, carry, and place other players in vehicle trunks.

## HUGH SHOUT OUT TO Shawns Developments for help with bug fixes IF YOU WANNA SEE MORE OF HIS WORK GO HIT HIS DISCORD https://discord.gg/4EA4NUx8

## Features

- **Player Restraining**: Use zipties to restrain other players
- **Player Carrying**: Carry restrained players on your shoulder
- **Vehicle Trunk Interaction**: Place restrained players in vehicle trunks
- **Command-Based Interaction**: Simple commands for all actions
- **Fully Configurable**: Customize item names, commands, and more
- **Realistic Animations**: Proper animations for all actions
- **Immersive Experience**: Progress bars and notifications for all interactions

## Installation

1. Download the resource
2. Place the folder in your server's resources directory
3. Add `ensure qb-carry` to your server.cfg
4. Add the required items to your `qb-core/shared/items.lua` file (see below)
5. Restart your server

### Required Items

Add these items to your `qb-core/shared/items.lua` file if they don't already exist:

```lua
["ziptie"] = {
    ["name"] = "ziptie",
    ["label"] = "Zip Tie",
    ["weight"] = 50,
    ["type"] = "item",
    ["image"] = "ziptie.png",
    ["unique"] = false,
    ["useable"] = true,
    ["shouldClose"] = true,
    ["combinable"] = nil,
    ["description"] = "Can be used to restrain someone."
},
```
