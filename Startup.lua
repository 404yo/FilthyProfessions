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
    
    -- if realmName == nil or guildName or guildName == nil then 
    --     return 
    -- end

    FilthyProfessions.guildName = guildName
    FilthyProfessions.player = playerName
    FilthyProfessions.realmName = realmName
    FilthyProfessions.Profile = realmName.."-"..playerName

    FilthyProfessionsPlayersDB = FilthyProfessionsPlayersDB or {}
    FilthyProfessionsPlayersDB.professions = FilthyProfessionsPlayersDB.professions or {}
    
    FilthyProfessionsPlayersDB.professions["First Aid"] =   FilthyProfessionsPlayersDB.professions["First Aid"]  or {} 
    FilthyProfessionsPlayersDB.professions["Leather Working"] =   FilthyProfessionsPlayersDB.professions["Leather Working"] or {}
    FilthyProfessionsPlayersDB.professions["Black Smithing"] =   FilthyProfessionsPlayersDB.professions["Black Smithing"] or {}
    FilthyProfessionsPlayersDB.professions["Engineering"] =    FilthyProfessionsPlayersDB.professions["Engineering"] or {}
    FilthyProfessionsPlayersDB.professions["Cooking"] =  FilthyProfessionsPlayersDB.professions["Cooking"] or {}
    FilthyProfessionsPlayersDB.professions["Enchanting"] =   FilthyProfessionsPlayersDB.professions["Enchanting"] or {}
    FilthyProfessionsPlayersDB.professions["Tailoring"] =   FilthyProfessionsPlayersDB.professions["Tailoring"] or {}
    FilthyProfessionsPlayersDB.professions["Alchemy"] =   FilthyProfessionsPlayersDB.professions["Alchemy"] or {}

    FilthyProfessions.gDB = FilthyProfessionsPlayersDB
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
    FilthyProfessions.gProfileDB = FilthyProfessionsPlayerProfile[FilthyProfessions.Profile] or {}
    FilthyProfessions.gPinnedItems = FilthyProfessionsPlayerProfile[FilthyProfessions.Profile]["pinned"] or {}
end

function Startup:InitItems()
    DB:init(function() 
        return
    end)
end

function Startup:InitGUI()
    GUI:LoadStyling()
    GUI:init()
end