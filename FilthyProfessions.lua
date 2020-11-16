local FilthyProfessions = {}
LibStub("AceComm-3.0"):Embed(FilthyProfessions)
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")
local playerName = UnitName("player")
local gPrefix = "FilthyPrefix"
FilthyProfessions.INIT = false
_G["FilthyProfessions"] = FilthyProfessions
local DB = {}
local syncLocktrigger = 4
local syncs = 0
local syncLock = false
local recieveLock = false
local timer = C_Timer
local t_insert = table.insert

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
EventFrame:RegisterEvent("CRAFT_UPDATE")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    if syncs == syncLocktrigger and not syncLock then 
        syncLock = true
        timer.After(12, function()  syncs = 0 syncLock = false end)
        return
    end

    if (event == "TRADE_SKILL_UPDATE") and not syncLock and not InCombatLockdown() then
        syncs = syncs + 1 
        FilthyProfessions:SendSyncMessage("trade")
    end
    if (event == "CRAFT_UPDATE")  and not syncLock and not InCombatLockdown() then
        syncs = syncs + 1
        FilthyProfessions:SendSyncMessage("craft")
    end

end)


function FilthyProfessions:init()
    FilthyProfessions:RegisterComm(gPrefix,"MessageRecieveHandler")
    DB  = FilthyProfessions.DB
end

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

    if message == nil  or recieveLock or InCombatLockdown() then
        return
    end
    if sourceChannel == "GUILD" then
        recievedData = decodeMessage(message)
        message = nil
        FilthyProfessions:persistPlayerProfessions(recievedData)
    end

    -- if sourceChannel == "WHISPER" then
    --     if message == 'sync-me' then
    --         local message =  DB:GetDB() or {}
    --         local payload = encodeMessage(message)
    --         FilthyProfessions:SendCommMessage(gPrefix, payload, "WHISPER", context)
    --     else
    --         local data = decodeMessage(message)
    --         DB:InsertAlienDB(data)
    --         GUI:CreateItems()
    --     end
    -- end
end

local function parseMessage(data)
    local sourcePlayer = data["player"]
    local profession = data["profession"]
    local items = data["itemID"]
    return sourcePlayer, profession, items
end

function FilthyProfessions:persistPlayerProfessions(data)
    local sourcePlayer, profession, items = parseMessage(data)
    DB:InsertToDB(profession, items, sourcePlayer, function(boolean)
    end)
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
    itemsToSend["itemID"]  = {}
    for i = 1, GetRecipeCount(prof_type) do
        local itemId = GetItemId(prof_type, i)
        if (itemId ~= nil) then
            t_insert(itemsToSend["itemID"],itemId)
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
            itemsToSend["itemID"] = nil
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
        local formatting = string.rep("  ", indent) .. k .. ": "
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
local sfind = string.find
local function commands(msg, editbox)
    local _, _, cmd, args = sfind(msg, "%s?(%w+)%s?(.*)")
    if cmd == 'sync' and args ~= "" then
        print("Soon^tm")
        -- FilthyProfessions:SendCommMessage(gPrefix, "sync-me", "WHISPER", args)
        -- .. "|cFF91ce16/fp sync <player-name>|r or |cFF91ce16/filthyprofessions sync <player-name>|r To Sync db from another player\n"

    elseif cmd == 'soff' then 
        recieveLock = true
    elseif cmd == 'son' then
        recieveLock = false
    elseif cmd == 'help' then
        print("\n|cFF91ce16/fp|r or |cFF91ce16/filthyprofessions|r :To toggle window\n" 
        .. "|cFF91ce16/fp soff|r or |cFF91ce16/filthyprofessions soff|r :To turn off syncing from other players\n"
        .. "|cFF91ce16/fp son|r or |cFF91ce16/filthyprofessions son|r :To Turn on syncing from other players\n"
    )
    else
        FilthyProfessions.GUI:TOGGLE()
    end
end

SLASH_FILTHYPROFESSIONS1, SLASH_FILTHYPROFESSIONS2 = '/fp', '/filthyprofessions'

SlashCmdList["FILTHYPROFESSIONS"] = commands
