Config = {}

Config.DebugMode = true -- no needed

Config.Base = "sandbox" -- mythic/sandbox this is the Base type

Config.BaseName = "skdev-base" -- here the base name

Config.WatchCoords = vector3(464.618, -962.563, 28.103) -- Where they can start watch?

-- If you wanna use Targeting make this true
Config.Targeting = {
    Enable = true,
    Text = "Show CCTV's",
    Icon = "camera"
}

-- if you wanna use Native instead of Targeting you will need setup this as you want
-- like this https://prnt.sc/KhykDVv6BZuD
Config.Native = {
    KEY = 38, -- Default is E, If you wanna change it get the key Index from here: https://docs.fivem.net/docs/game-references/controls/
    Text = "[E] Open Dispatch CCTVs",
    ZoneSize = 5, -- From X far he can see it, Default is 5, maximum = 15, minimum = 2
}

-- if you wanna use it With F1 you will need disable Config.Item THEN
-- DO NOT REPLACE IT, ONLY ADD IT AS ITS NEED
-- https://gist.github.com/ISKinGeR/7f2704d979dd835b609f17827a863346

-- SEE THESE IMAGES TO KNOW HOW TO DO IT
-- BEFORE: https://prnt.sc/xYUMEltpmeMd
-- AFTER: https://prnt.sc/ZxUMd0cIEQ0I
Config.Items = { -- If you want to use items instead of normal F1 -> police -> ToggleBodyCam
    Enable = false,
    items = { -- Add these to ur inventory system mythic/sandbox
        {
            name = "bodycam",
            label = "Bodycam",
            price = 0,
            isUsable = true,
            isRemoved = false,
            isStackable = false,
            isDestroyed = true,
            type = 1,
            rarity = 4,
            closeUi = true,
            metalic = true,
            weight = 2.0,
            durability = (60 * 60 * 24 * 21),
            description = "Bodycam for police officers!",
        }
    }
}

Config.MenuTexts = {
    -- first menu
    MainMenuText = "Dispatch CCTVs",
    DashCamsLabel = "Bodycam List",
    DashCamsText = "Click to see the police officers with active bodycam",
    cctvsLabel = "Places List",
    cctvsText = "Click to see the Places CCTV",

    -- second menu
    DashCamLabel = "Bodycam List",
    DashCamText = "Watch the camera of cop: ",
    cctvLabel = "CCTV - Places",
    cctvText = "Watch group: "
}

Config.Notifications = {
    NoCameraFound = "No active cameras found",
    BodycamON = "Bodycam turned on",
    BodycamOFF = "Bodycam turned off",
    NoNameFound = "Something went wrong.",
    CameraInUse = "This bodycam is currently being watched by another officer",
    AlreadyWatching = "You are already watching another camera",
    SubjectIsWatching = "This officer is currently monitoring another camera",
    SubjectStartedWatching = "Camera disconnected because subject started watching another feed",
    SubjectDisabledCamera = "Camera feed lost: Subject disabled their bodycam",
    SubjectDisconnected = "Camera disconnected because subject went offline",
    CameraDisabled = "Camera unavailable (user is watching another feed)"
}

Config.Places = {
    Enable = true, -- If you dont want it just disable it
    Cameras = {
        {label = "24/7 - Davis", x = -57.146, y = -1752.099, z = 31.661, r = { x = -11.275, y = 0.000, z = -109.257 }, canRotate = false, isOnline = true, quality = "low", group = "store1"},
        
        {label = "24/7 - North Rockford Dr", x = -1827.255, y = 784.642, z = 140.551, r = { x = -11.472, y = -0.000, z = -23.939 }, canRotate = false, isOnline = true, quality = "low", group = "store2"},
        
        {label = "24/7 - Little Seoul", x = -717.920, y = -915.900, z = 21.451, r = { x = -12.061, y = 0.000, z = -67.729 }, canRotate = false, isOnline = true, quality = "low", group = "store3"},
        
        {label = "24/7 - Grapeseed", x = 1702.986, y = 4933.736, z = 44.283, r = { x = -11.690, y = 0.000, z = 170.551 }, canRotate = false, isOnline = true, quality = "low", group = "store4"},
        
        {label = "24/7 - Grand Senora", x = 2679.095, y = 3290.074, z = 57.490, r = { x = -15.259, y = 0.000, z = 173.866 }, canRotate = false, isOnline = true, quality = "low", group = "store5"},
        
        {label = "24/7 - Mt Chiliad", x = 1738.581, y = 6414.694, z = 37.296, r = { x = -18.586, y = -0.000, z = 85.439 }, canRotate = false, isOnline = true, quality = "low", group = "store6"},
        
        {label = "24/7 - Harmony", x = 539.920, y = 2665.774, z = 44.409, r = { x = -30.505, y = -0.000, z = -58.851 }, canRotate = false, isOnline = true, quality = "low", group = "store7"},
        
        {label = "24/7 - Sandy Shores", x = 1966.472, y = 3748.642, z = 34.598, r = { x = -26.781, y = 0.000, z = 148.139 }, canRotate = false, isOnline = true, quality = "low", group = "store8"},
        
        {label = "24/7 - West Strawberry", x = 34.389, y = -1342.936, z = 31.723, r = { x = -27.383, y = -0.000, z = 115.196 }, canRotate = false, isOnline = true, quality = "low", group = "store9"},
        
        {label = "24/7 - Downtown Vinewood", x = 383.229, y = 328.228, z = 105.806, r = { x = -28.735, y = 0.000, z = 105.179 }, canRotate = false, isOnline = true, quality = "low", group = "store10"},
        
        {label = "24/7 - Banham Canyon", x = -3046.180, y = 592.659, z = 10.153, r = { x = -29.067, y = -0.000, z = -134.047 }, canRotate = false, isOnline = true, quality = "low", group = "store11"},
        
        {label = "24/7 - Chumash", x = -3245.739, y = 1010.180, z = 15.082, r = { x = -25.955, y = -0.000, z = -158.470 }, canRotate = false, isOnline = true, quality = "low", group = "store12"},
        
        {label = "24/7 - Tataviam Mountains", x = 2553.326, y = 390.828, z = 110.860, r = { x = -31.758, y = -0.000, z = -154.588 }, canRotate = false, isOnline = true, quality = "low", group = "store13"},
        
        {label = "24/7 - Mirror Park", x = 1153.504, y = -327.009, z = 71.436, r = { x = -19.413, y = -0.000, z = -51.031 }, canRotate = false, isOnline = true, quality = "low", group = "store14"},
        
        {label = "24/7 - East Strawberry", x = 290.650, y = -1260.870, z = 31.752, r = { x = -22.286, y = -0.000, z = -157.896 }, canRotate = false, isOnline = true, quality = "low", group = "store15"},
        
        {label = "24/7 - Paleto", x = 170.661, y = 6637.689, z = 33.953, r = { x = -23.117, y = -0.000, z = 76.900 }, canRotate = false, isOnline = true, quality = "low", group = "store16"},
    
        {label = "Vangelico Jewellery", x = -627.438, y = -239.845, z = 40.374, r = { x = -13.827, y = -0.000, z = -18.146 }, canRotate = true, isOnline = true, quality = "brown", group = "vangelico"},
    
        {label = "Fleeca - Hawick Ave East (Lobby)", x = 316.969, y = -280.250, z = 56.199, r = { x = -28.152, y = 0.000, z = 36.842 }, canRotate = true, isOnline = true, quality = "medium", group = "fleeca_hawick_east" },
    
        {label = "Fleeca - Hawick Ave West (Lobby)", x = -348.147, y = -51.061, z = 51.060, r = { x = -24.457, y = -0.000, z = 36.695 }, canRotate = true, isOnline = true, quality = "medium", group = "fleeca_hawick_west" },
    
        {label = "Fleeca - Blvd Del Perro (Lobby)", x = -1209.770, y = -329.542, z = 39.814, r = { x = -19.418, y = 0.000, z = 87.837 }, canRotate = true, isOnline = true, quality = "medium", group = "fleeca_delperro" },
    
        {label = "Fleeca - Great Ocean Hwy (Lobby)", x = -2962.311, y = 485.884, z = 17.733, r = { x = -23.118, y = -0.000, z = 142.995 }, canRotate = true, isOnline = true, quality = "medium", group = "fleeca_great_ocean" },
    
        {label = "Fleeca - Route 68 (Lobby)", x = 1172.177, y = 2706.841, z = 40.050, r = { x = -22.646, y = -0.000, z = -118.028 }, canRotate = true, isOnline = true, quality = "medium", group = "fleeca_route68" },
    
        {label = "Fleeca - Vespucci Blvd (Lobby)", x = 152.609, y = -1041.868, z = 31.420, r = { x = -22.292, y = -0.000, z = 41.696 }, canRotate = true, isOnline = true, quality = "medium", group = "fleeca_vespucci" },
        
        {label = "Bay City Maze Bank", x = -1315.266, y = -822.446, z = 20.813, r = { x = -25.387, y = -0.000, z = -86.372 }, canRotate = true, isOnline = true, quality = "blurred", group = "mazebank" },
        
        {label = "Lombank", x = 6.566, y = -920.700, z = 36.403, r = { x = -24.496, y = -0.000, z = -145.391 }, canRotate = true, isOnline = true, quality = "blurred", group = "lombank" },
    
        {label = "Paleto", x = -103.558, y = 6451.413, z = 34.660, r = { x = -19.993, y = -0.000, z = 64.690 }, canRotate = true, isOnline = true, quality = "blurred", group = "paleto" },
    
        {label = "Pacific Bank", x = 237.908, y = 234.100, z = 109.965, r = { x = -14.890, y = -0.000, z = -165.588 }, canRotate = true, isOnline = true, quality = "blurred", group = "pacific_bank"},
        
        {label = "Diamond Casino", x = 913.811, y = 35.502, z = 84.674, r = { x = -12.874, y = 0.000, z = 123.120 }, canRotate = true, isOnline = true, quality = "blurred", group = "diamond_casino"},
    
        {label = "Art Gallery", x = 18.399, y = 150.852, z = 96.096, r = { x = -22.979, y = -0.000, z = 122.631 }, canRotate = true, isOnline = true, quality = "blurred", group = "art_gallery"},
    }
}
