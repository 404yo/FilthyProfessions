
local GuildProfessions = {}
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

local playerName = UnitName("player")
local prefix = "BIGMAMBASA"
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

function MessageRecieveHandler(prefix, message, sourceChannel, sourcePlayer)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message)
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    local success, data = LibSerialize:Deserialize(decompressed)

    persistPlayerProfessions(data)
end

function persistPlayerProfessions(data)
    local sourcePlayer, profession, items = parseMessage(data)
    DB:InsertToDB(profession, items, sourcePlayer)
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
    local guildName, _, _, realmName = GetGuildInfo(playerName);
    realmName = GetNormalizedRealmName()

    gProfile = guildName .. " - " ..realmName
    print(gProfile)
    DB:init(gProfile)


    C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    GUI:init()
    hasInit = true



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

function GuildProfessions:DeepPrint(e)

    -- items = {
    --     [itemId] = {
    --         [reagentId] = 1,
    --     }
    -- }
    if( type(e) == "table") then
        for k, v in pairs(e) do
            if type(v) == "table" then
                print("Key [" .. k .. "]")
                GuildProfessions:DeepPrint(v)
            else
                print("Value [".. tostring(k).."] [ "..tostring(v) .. "]")
                print("*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*")
            end
        end
    else
        print("Value ["..tostring(v) .. "]")
        print("*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*")
    end
end
