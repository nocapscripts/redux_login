Config = Config or {}


Config.Framework = 'rs_base' -- Framework name

Config.InsertUserData = true -- Default: false This option is related to my custom library script which unfortunately i cannot share or make it public :(

Config.OnPlayerLoaded = 'NPX:Client:OnPlayerLoaded' -- Player loaded event name

Config.OnPlayerUnload = 'NPX:Client:OnPlayerUnload' -- Player unloaded event name

Config.Notify = 'NPX:Notify' -- Notify event name

Config.starterpack = { 
    ['phone'] = { count = 1, item = 'phone' },
    ['id_card'] = { count = 1, item = 'id_card' },
    ['scratch_ticker'] = { count = 1, item = 'scratch_ticket' },
    ['burger'] = { count = 20, item = 'burger' },
    ['water'] = { count = 20, item = 'water' },
    ['lockpick'] = { count = 20, item = 'lockpick' }


}

Config.SkipSelection = false -- Skip the spawn selection and spawns the player at the last location
Config.DefaultNumberOfCharacters = 5 -- Define maximum amount of default characters (maximum 5 characters defined by default)
Config.PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 2 },
}