Config = {}

-- Admin permissions (ACE based)
Config.AdminGroups = {
    superadmin = 4,
    admin = 3,
    moderator = 2,
    helper = 1
}

-- Key to open admin menu
Config.OpenKey = 'F6'

-- Admin HQ coordinates (default LSPD)
Config.AdminHQ = {
    x = 425.1,
    y = -979.5,
    z = 30.7
}

-- Ban system
Config.UseBanSystem = true
Config.BanTable = 'user_bans'

-- Spectate settings
Config.SpectateKey = 'E' -- Key to stop spectating
Config.SpectateCoords = {
    x = 0.0,
    y = 0.0,
    z = 1000.0
}

-- Jobs available for setting
Config.Jobs = {
    'unemployed',
    'police',
    'ambulance',
    'mechanic',
    'taxi',
    'cardealer',
    'banker',
    'lawyer'
}

-- Items available for giving
Config.Items = {
    'bread',
    'water',
    'phone',
    'bandage',
    'lockpick',
    'clothe',
    'medikit'
}