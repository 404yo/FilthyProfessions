local Startup = {}


local FilthyProfessions = _G.FilthyProfessions
local DB = FilthyProfessions.DB
local GUI = FilthyProfessions.GUI
FilthyProfessions.Startup = Startup

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "GUILD_ROSTER_UPDATE" and not FilthyProfessions.INIT  then
        Startup:start()
    end
end)

local function IsPlayerInGuild()
    return IsInGuild() and GetGuildInfo("player")
end

function Startup:start() 
    if not IsPlayerInGuild() then return end
    FilthyProfessions:init()
    Startup:initDB()
    Startup:InitItems()
    Startup:InitGUI()
    FilthyProfessions.INIT_GUI = true
    FilthyProfessions.INIT = true
end


function Startup:initDB() 
    local playerName = UnitName("player")
    local guildName, _, _, _ = GetGuildInfo(playerName);

    local realmName = GetNormalizedRealmName()
    
    FilthyProfessions.guildName = guildName
    FilthyProfessions.player = playerName
    FilthyProfessions.realmName = realmName
    FilthyProfessions.Profile = realmName.."-"..playerName

    FilthyProfessionsPlayersDB = FilthyProfessionsPlayersDB or {}
    FilthyProfessionsPlayersDB.professions = FilthyProfessionsPlayersDB.professions or {}


    FilthyProfessionsPlayersDB[FilthyProfessions.Profile] = FilthyProfessionsPlayersDB[FilthyProfessions.Profile] or {}
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"] = FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"] or {}
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["pinned"] = FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["pinned"]  or {}
    
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["First Aid"] =   FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["First Aid"]  or {} 
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Leather Working"] =   FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Leather Working"] or {}
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Black Smithing"] =   FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Black Smithing"] or {}
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Engineering"] =    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Engineering"] or {}
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Cooking"] =  FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Cooking"] or {}
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Enchanting"] =   FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Enchanting"] or {}
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Tailoring"] =   FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Tailoring"] or {}
    FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Alchemy"] =   FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"]["Alchemy"] or {}

    FilthyProfessions.gDB = FilthyProfessionsProfessionData or {}
    FilthyProfessions.gItemsDB  = FilthyProfessions.gItemsDB or {}
    FilthyProfessions.gItemsDB["First Aid"] = FilthyProfessions.gItemsDB["First Aid"] or {} 
    FilthyProfessions.gItemsDB["Leather Working"] = FilthyProfessions.gItemsDB["Leather Working"] or {}
    FilthyProfessions.gItemsDB["Black Smithing"] = FilthyProfessions.gItemsDB["Black Smithing"]or {}
    FilthyProfessions.gItemsDB["Engineering"] =  FilthyProfessions.gItemsDB["Engineering"] or {}
    FilthyProfessions.gItemsDB["Cooking"] = FilthyProfessions.gItemsDB["Cooking"] or {}
    FilthyProfessions.gItemsDB["Enchanting"] = FilthyProfessions.gItemsDB["Enchanting"] or {}
    FilthyProfessions.gItemsDB["Tailoring"] = FilthyProfessions.gItemsDB["Tailoring"] or {}
    FilthyProfessions.gItemsDB["Alchemy"] = FilthyProfessions.gItemsDB["Alchemy"] or {}

    FilthyProfessionsPlayerProfile = FilthyProfessionsPlayerProfile or {}
    FilthyProfessionsPlayerProfile[FilthyProfessions.Profile] = FilthyProfessionsPlayerProfile[FilthyProfessions.Profile] or {}
    FilthyProfessionsPlayerProfile[FilthyProfessions.Profile]["pinned"] = FilthyProfessionsPlayerProfile[FilthyProfessions.Profile]["pinned"] or {}
    FilthyProfessions.gPlayersDB = FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["Players"] or {}
    FilthyProfessions.gPinnedItems = FilthyProfessionsPlayersDB[FilthyProfessions.Profile]["pinned"] or {}
end

function Startup:InitItems()
    DB:init(function() 
    end)
end

function Startup:InitGUI()
    GUI:LoadStyling()
    GUI:init()
    GUI:SortItemList()
end