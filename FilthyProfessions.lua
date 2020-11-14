local FilthyProfessions = {}
LibStub("AceComm-3.0"):Embed(FilthyProfessions)
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")
local playerName = UnitName("player")
local gPrefix = "FilthyPrefix"
local t_insert = table.insert
local hasInit = false
FilthyProfessions.INIT = false
_G["FilthyProfessions"] = FilthyProfessions
local DB = {}
local GUI = {}
local Startup = {}


local next =  next


local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
EventFrame:RegisterEvent("CRAFT_UPDATE")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    if (event == "TRADE_SKILL_UPDATE") then
        FilthyProfessions:SendSyncMessage("trade")
    end
    if (event == "CRAFT_UPDATE") then
        FilthyProfessions:SendSyncMessage("craft")
    end
    if event == "CHAT_MSG_ADDON" then
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

local recievedData = {}
function FilthyProfessions:MessageRecieveHandler(prefix, message, sourceChannel, context)

    if message == nil  and prefix == gPrefix then
        return
    end
    if sourceChannel == "GUILD" then
        recievedData = decodeMessage(message)
        message = nil
        FilthyProfessions:persistPlayerProfessions(recievedData)
    end

    if sourceChannel == "WHISPER" then
        if message == 'sync-me' then
            local message =  DB:GetDB() or {}
            local payload = encodeMessage(message)
            FilthyProfessions:SendCommMessage(gPrefix, payload, "WHISPER", context)
        else
            local data = decodeMessage(message)
            DB:InsertAlienDB(data)
            GUI:CreateItems()
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
    end)
end


local function IsPlayerInGuild()
    return IsInGuild() and GetGuildInfo("player")
end

function FilthyProfessions:init()
    FilthyProfessions:RegisterComm(gPrefix,"MessageRecieveHandler")
    DB  = FilthyProfessions.DB
    GUI = FilthyProfessions.GUI
    Startup = FilthyProfessions.Startup
    hasInit = true
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
local itemsToSend = {["items"] = {}}
local function GetRecipes(prof_type)
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
            for k,v in next, itemsToSend["items"] do itemsToSend["items"][k] = nil end
            itemsToSend["player"] = nil
            itemsToSend["profession"] = nil
     end
end

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
        FilthyProfessions.GUI:TOGGLE()
    end
end

SLASH_FILTHYPROFESSIONS1, SLASH_FILTHYPROFESSIONS2 = '/fp', '/filthyprofessions'

SlashCmdList["FILTHYPROFESSIONS"] = commands
