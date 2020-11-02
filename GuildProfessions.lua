local GuildProfessions = {}
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

local playerName = UnitName("player")
local gPrefix = "BIGMAMBASA"
local gRealm
local gGuildName
local gItems = {}
local hasInit = false
local defaults = {}
local gProfile

-------------------------------------
-- _G["DB"] = {}
_G["GuildProfessions"] = GuildProfessions
_G["profile"] = gProfile
GUI = _G["GUI"]
DB = _G.DB
GDB = _G.GDB
-- _G["professionsDB"] = gDB

-------------------------------------

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
EventFrame:RegisterEvent("CRAFT_UPDATE")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    if not hasInit then
        GuildProfessions:init()
    end
    if (event == "TRADE_SKILL_UPDATE") then
        SendSyncMessage("trade")
    end
    if (event == "CRAFT_UPDATE") then
        SendSyncMessage("craft")
    end
    if event == "CHAT_MSG_ADDON" then
        MessageRecieveHandler(...)
    end
    if event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...
        if isInitialLogin or isReloadingUi then
        end
    end

end)

function MessageRecieveHandler(prefix, message, sourceChannel, context)

    if message == nil  and prefix == gPrefix then
        return
    end
    if sourceChannel == "GUILD" then
        local data = decodeMessage(message)
        persistPlayerProfessions(data)
    end

    if sourceChannel == "WHISPER" then
        if message == 'sync-me' then
            print("got sync me")
            local message = {}
            message["profile"] = gProfile
            message["db"] = _G.GDB
            tprint(message)
            local payload = encodeMessage(message)
            print(tostring(payload))
            C_ChatInfo.SendAddonMessage(gPrefix, payload, "WHISPER", context)
            print("sent data")
        else
            local data = decodeMessage(message)
            print("Thanks for the sync".. data.profile)
            GuildProfessionPlayersDB = getGuildProfessionPlayersDB or {}
            GuildProfessionPlayersDB[data.profile] = data.db or {}
            GUI:Refresh()
        end
    end

end

function persistPlayerProfessions(data)
    local sourcePlayer, profession, items = parseMessage(data)
    print(data)
    DB:InsertToDB(profession, items, sourcePlayer, function(boolean)
        GUI:Refresh()
    end)
end

function GuildProfessions:GetItemLink(itemId)
    local _, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = GetItemInfo(itemId)
    return itemLink, itemIcon
end

function parseMessage(data)
    local sourcePlayer = data["player"]
    local profession = data["profession"]
    local items = data["items"]
    return sourcePlayer, profession, items
end

function GuildProfessions:IsPlayerInGuild()
    return IsInGuild() and GetGuildInfo("player")
end

function GuildProfessions:init()

    -- guild name doesn't exist on start, stupid right
    if not GuildProfessions:IsPlayerInGuild() then
        return
    end

    C_ChatInfo.RegisterAddonMessagePrefix(gPrefix)

    local guildName, _, _, realmName = GetGuildInfo(playerName);
    realmName = GetNormalizedRealmName()
    gRealm = realmName
    gGuildName = guildName
    DB:init(gGuildName,gRealm, function(boolean)
        if boolean then
            GUI:init()
            hasInit = true
        end
    end)

end

function GetProfInfo(prof_type)
    local skillLineDisplayName
    if (prof_type == "trade") then
        skillLineDisplayName, _, _ = GetTradeSkillLine()
        return skillLineDisplayName
    elseif (prof_type == "craft") then
        skillLineDisplayName, _, _ = GetCraftDisplaySkillLine()
        return skillLineDisplayName
    end
end

function GetRecipeCount(prof_type)
    if (prof_type == "trade") then
        return GetNumTradeSkills()
    elseif (prof_type == "craft") then
        return GetNumCrafts()
    end

    return 0

end

function GetRecipeInfo(prof_type, index)
    local name, type

    if (prof_type == "trade") then
        name, type, _, _, _, _ = GetTradeSkillInfo(index)
    elseif (prof_type == "craft") then
        name, _, type, _, _, _, _ = GetCraftInfo(index)
    end

    return name, type

end

function GetNumberOfReagents(prof_type, index)
    local numberOfReagents
    if (prof_type == "craft") then
        numberOfReagents = GetCraftNumReagents(index)
    elseif (prof_type == "trade") then
        numberOfReagents = GetTradeSkillNumReagents(index)
    end
    return numberOfReagents
end

function GetReagentItemid(prof_type, index, n)
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

function GetReagentCount(prof_type, index, n)
    local reagantCount
    if (prof_type == "craft") then
        _, _, reagantCount, _ = GetCraftReagentInfo(index, n);
    elseif (prof_type == "trade") then
        _, _, reagantCount, _ = GetTradeSkillReagentInfo(index, n)
    end
    return tostring(reagantCount)
end

function GetItemId(prof_type, index)
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
function SendSyncMessage(prof_type)
    if (prof_type == "craft" or "trade") then
        local proff = GetProfInfo(prof_type)
        local items = {}
        if (proff ~= nil) then
            items = GetRecipes(prof_type)
            broadCastMessage(items, proff)
        end
    end
end

function GetRecipes(prof_type)
    local items = {}
    for i = 1, GetRecipeCount(prof_type) do
        local itemId = GetItemId(prof_type, i)
        local reagent = {}

        if (itemId ~= nil) then

            for j = 1, GetNumberOfReagents(prof_type, i) do
                local reagentItemId = GetReagentItemid(prof_type, i, j)
                reagent[reagentItemId] = GetReagentCount(prof_type, i, j);
            end
            items[itemId] = reagent
        end
    end
    return items
end

function broadCastMessage(items, proff)
    if items == nil then return end
    local payload = prepareMessage(items, proff)
    C_ChatInfo.SendAddonMessage(gPrefix, payload, "GUILD")
end

function prepareMessage(items, proff)
    local message = {}
    message["player"] = playerName
    message["profession"] = proff
    message["items"] = items
    return encodeMessage(message)
end

function encodeMessage(message)
    local serialized = LibSerialize:Serialize(message)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    return encoded
end

function decodeMessage(message)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message)
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    local success, data = LibSerialize:Deserialize(decompressed)
    if success then
        return data
    else
            
    print("failed to decode payload")
    return nil
    end

end
function tprint(tbl, indent)
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
        C_ChatInfo.SendAddonMessage(gPrefix, "sync-me", "WHISPER", args)
    elseif cmd == 'help' then
        print("\n[/fp] To toggle fp UI\n" 
        .. "[/fp reset] To refresh UI\n" 
        .. "[/fp sync <player-name>] To Sync db from another player")
    else
        GuildProfessions:init()
        GUI:TOGGLE()
    end
end

SLASH_FILTHYPROFESSIONS1, SLASH_FILTHYPROFESSIONS2 = '/fp', '/filthyprofessions'

SlashCmdList["FILTHYPROFESSIONS"] = commands
