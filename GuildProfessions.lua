local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

guildProfessions = {}
local playerName = UnitName("player")
local prefix = "BIGMAMBASA"
local gGuildName
local gDB = {}
local gItems = {}

local defaults = {}

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
EventFrame:RegisterEvent("CRAFT_UPDATE")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    if (event == "TRADE_SKILL_UPDATE") then
        guildProfessions:hej("trade")
    end
    if (event == "CRAFT_UPDATE") then
        guildProfessions:hej("craft")
    end
    if event == "CHAT_MSG_ADDON" then
        MessageRecieveHandler(...)
    end
    if event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...
        if isInitialLogin or isReloadingUi then
            init()
        end
    end

end)

function MessageRecieveHandler(prefix, message, sourceChannel, sourcePlayer)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message)
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    local success, data = LibSerialize:Deserialize(decompressed)

    persistPlayerProfessions(data)
end

function persistPlayerProfessions(data)
    local sourcePlayer, profession, items = parseMessage(data)
    insertToDb(profession, items, sourcePlayer)
end

function insertToDb(profession, items, sourcePlayer)
    DeepPrint(items)
    print("profession " .. profession)
    print("source " .. sourcePlayer)
    print("source " .. tostring(gGuildName))

    local db = gDB[gGuildName].professions[profession] or {}

    for itemId, reagents in pairs(items) do
        db[itemId] = db[itemId] or {}
        db[itemId]["reagents"] = reagents
        local exists = db[itemId][sourcePlayer] or false
        if not exists then
            db[itemId][sourcePlayer] = true
        end
    end

    gDB[gGuildName].professions[profession] = db
    DeepPrint(gDB)
end

function getItemLink(itemId)
    local _, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = GetItemInfo(itemId)
    return itemLink, itemIcon
end

function parseMessage(data)
    local sourcePlayer = data["player"]
    local profession = data["profession"]
    local items = data["items"]
    return sourcePlayer, profession, items
end

function init()
    
    local guildName, _, _, _ = GetGuildInfo("player");
    local realmName = GetNormalizedRealmName()
    gGuildName = guildName .." - " ..realmName

    GuildProfessionPlayersDB = GuildProfessionPlayersDB or {}
    gDB = GuildProfessionPlayersDB
    gDB[gGuildName] = GuildProfessionPlayersDB[gGuildName] or {}
    gDB[gGuildName]["professions"] = GuildProfessionPlayersDB[gGuildName]["professions"] or {}

    C_ChatInfo.RegisterAddonMessagePrefix(prefix)

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
        name, type, _, _, _, _ = GetTradeSkillInfo(index);
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
    itemID = itemLink:match("item:(%d+)")

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
    return itemID

end
function guildProfessions:hej(prof_type)
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
    local payload = prepareMessage(items, proff)
    C_ChatInfo.SendAddonMessage(prefix, payload, "WHISPER", playerName)
end

function prepareMessage(items, proff)
    local message = {}
    message["player"] = playerName
    message["profession"] = proff
    message["items"] = items
    local serialized = LibSerialize:Serialize(message)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    return encoded
end

function DeepPrint(e)

    -- items = {
    --     [itemId] = {
    --         [reagentId] = 1,
    --     }
    -- }

    if type(e) == "table" then
        for k, v in pairs(e) do
            print("------------------")
            if type(k) == "table" then
                DeepPrint(k)
            else
                print("key " .. k)
                DeepPrint(v)
            end
        end
    else
            print("value" .. tostring(e))
            print("------------------")
    end
end
