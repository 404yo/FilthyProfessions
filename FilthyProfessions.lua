local FilthyProfessions = {}
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")
LibStub("AceComm-3.0"):Embed(FilthyProfessions)
local playerName = UnitName("player")
local gPrefix = "FilthyPrefix"
local gRealm
local gGuildName
local gItems = {}
local hasInit = false
local initLock = false
local defaults = {}
local t_insert = table.insert


-------------------------------------
_G["FilthyProfessions"] = FilthyProfessions
GUI = _G["GUI"]
DB = _G.DB
GDB = _G.GDB

-------------------------------------

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
EventFrame:RegisterEvent("CRAFT_UPDATE")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    if not hasInit then
        FilthyProfessions:init(function(boolean)
            hasInit = boolean
        end)
    end
    if (event == "TRADE_SKILL_UPDATE") then
        FilthyProfessions:SendSyncMessage("trade")
    end
    if (event == "CRAFT_UPDATE") then
        FilthyProfessions:SendSyncMessage("craft")
    end
    if event == "CHAT_MSG_ADDON" then
        -- MessageRecieveHandler(...)
    end
    if event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...
        if isInitialLogin or isReloadingUi then
        end
    end

end)

local function decodeMessage(message)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message)
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    local success, data = LibSerialize:Deserialize(decompressed)
    if success then
        return data
    else  
    return nil
    end
end

local function encodeMessage(message)
    local serialized = LibSerialize:Serialize(message)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    return encoded
end


function FilthyProfessions:MessageRecieveHandler(prefix, message, sourceChannel, context)

    if message == nil  and prefix == gPrefix then
        return
    end
    if sourceChannel == "GUILD" then
        local data = decodeMessage(message)
        message = nil
        FilthyProfessions:persistPlayerProfessions(data)
    end

    if sourceChannel == "WHISPER" then
        if message == 'sync-me' then
            local message =  DB:GetDB() or {}
            local payload = encodeMessage(message)
            FilthyProfessions:SendCommMessage(gPrefix, payload, "WHISPER", context)
        else
            local data = decodeMessage(message)
            DB:InsertAlienDB(data)
            GUI:RefreshItems()
        end
    end
    -- collectgarbage("collect")
end

local function parseMessage(data)
    local sourcePlayer = data["player"]
    local profession = data["profession"]
    local items = data["items"]
    return sourcePlayer, profession, items
end

function FilthyProfessions:persistPlayerProfessions(data)
    local sourcePlayer, profession, items = parseMessage(data)
    DB:InsertToDB(profession, items, sourcePlayer, function(boolean)
        GUI:RefreshItems()
    end)
end


local function IsPlayerInGuild()
    return IsInGuild() and GetGuildInfo("player")
end

function FilthyProfessions:init(callback)
       -- guild name doesn't exist on start, stupid right
    if not IsPlayerInGuild() or hasInit then
        return callback(false)
    end
    if initLock then return end
    initLock = true
    
    FilthyProfessions:RegisterComm(gPrefix,"MessageRecieveHandler")
    local guildName, _, _, realmName = GetGuildInfo(playerName);
    realmName = GetNormalizedRealmName()
    gRealm = realmName
    gGuildName = guildName

    DB:init(gGuildName,gRealm ,playerName, function(boolean)
        if boolean then
            GUI:init()
            initLock = false
            callback(true)
        end
    end)
end

local function GetRecipeInfo(prof_type, index)
    local name, type

    if (prof_type == "trade") then
        name, type, _, _, _, _ = GetTradeSkillInfo(index)
    elseif (prof_type == "craft") then
        name, _, type, _, _, _, _ = GetCraftInfo(index)
    end

    return name, type

end

local function GetNumberOfReagents(prof_type, index)
    local numberOfReagents
    if (prof_type == "craft") then
        numberOfReagents = GetCraftNumReagents(index)
    elseif (prof_type == "trade") then
        numberOfReagents = GetTradeSkillNumReagents(index)
    end
    return numberOfReagents
end

local function GetReagentItemid(prof_type, index, n)
    local itemLink
    if (prof_type == "craft") then
        itemLink = GetCraftReagentItemLink(index, n)
    elseif (prof_type == "trade") then
        itemLink = GetTradeSkillReagentItemLink(index, n)
    end

    if (not itemLink) then
        return
    end
    local itemID = itemLink:match("item:(%d+)")

    return itemID

end

local function GetReagentCount(prof_type, index, n)
    local reagantCount
    if (prof_type == "craft") then
        _, _, reagantCount, _ = GetCraftReagentInfo(index, n);
    elseif (prof_type == "trade") then
        _, _, reagantCount, _ = GetTradeSkillReagentInfo(index, n)
    end
    return tostring(reagantCount)
end

local function GetItemId(prof_type, index)
    local itemLink, itemID
    if (prof_type == "trade") then
        itemLink = GetTradeSkillItemLink(index)
    elseif (prof_type == "craft") then
        itemLink = GetCraftItemLink(index)
    end
    if (not itemLink) then
        return
    end

    itemID = itemLink:match("item:(%d+)")
    if itemID == nil then
        itemID = itemLink:match("enchant:(%d+)")
    end

    return itemID

end



local function GetProfInfo(prof_type)
    local skillLineDisplayName
    if (prof_type == "trade") then
        skillLineDisplayName, _, _ = GetTradeSkillLine()
        return skillLineDisplayName
    elseif (prof_type == "craft") then
        skillLineDisplayName, _, _ = GetCraftDisplaySkillLine()
        return skillLineDisplayName
    end
end

local function GetRecipeCount(prof_type)
    if (prof_type == "trade") then
        return GetNumTradeSkills()
    elseif (prof_type == "craft") then
        return GetNumCrafts()
    end

    return 0

end
local itemsToSend = {}
local function GetRecipes(prof_type)
    itemsToSend["items"] = {}
    for i = 1, GetRecipeCount(prof_type) do
        GetRecipeInfo(prof_type, i)
        local itemId = GetItemId(prof_type, i)  
        if (itemId ~= nil) then
            itemsToSend["items"][itemId] = {}
            for j = 1, GetNumberOfReagents(prof_type, i) do
                local reagentItemId = GetReagentItemid(prof_type, i, j)
                local count = GetReagentCount(prof_type, i, j)
                itemsToSend["items"][itemId][reagentItemId] =  count
            end
        end
    end
end


function FilthyProfessions:SendSyncMessage(prof_type)
        local proff = GetProfInfo(prof_type)
        if (proff ~= nil) then
            GetRecipes(prof_type)
            itemsToSend["player"] = playerName
            itemsToSend["profession"] = proff
            local encoded = encodeMessage(itemsToSend)
            FilthyProfessions:SendCommMessage(gPrefix, encoded, "GUILD")
     end
end




-- function broadCastMessage(items, proff)
--     if items == nil then return end
--     local payload = prepareMessage(items, proff)
--     FilthyProfessions:SendCommMessage(gPrefix, payload, "GUILD")
-- end

-- local message = {}
-- function prepareMessage(items, proff)
--     message["player"] = playerName
--     message["profession"] = proff
--     message["items"] = items
--     return encodeMessage(message)
-- end

-- function encodeMessage(message)
--     local serialized = LibSerialize:Serialize(message)
--     local compressed = LibDeflate:CompressDeflate(serialized)
--     local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
--     return encoded
-- end



local function tprint(tbl, indent)
    if tbl == nil then
        return
    end
    if not indent then
        indent = 0
    end

    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. tostring(v))
        end
    end
end

local function commands(msg, editbox)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
    if cmd == 'reset' then
        GUI:Refresh()
    elseif cmd == 'sync' and args ~= "" then
        print("Syncing professions from player " .. args)
        FilthyProfessions:SendCommMessage(gPrefix, "sync-me", "WHISPER", args)
    elseif cmd == 'help' then
        print("\n[/fp] To toggle fp UI\n" 
        .. "[/fp reset] To refresh UI\n" 
        .. "[/fp sync <player-name>] To Sync db from another player")
    else

        if not hasInit then
            FilthyProfessions:init(function(boolean)
                if boolean then 
                    GUI:TOGGLE()
                end
            end)
        else
            GUI:TOGGLE()
        end
   

    end
end

SLASH_FILTHYPROFESSIONS1, SLASH_FILTHYPROFESSIONS2 = '/fp', '/filthyprofessions'

SlashCmdList["FILTHYPROFESSIONS"] = commands
