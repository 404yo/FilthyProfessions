local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

local playerName = UnitName("player")
local prefix = "BIGMAMBASA"
local PlayerTradeSkills = {}
local unpack = unpack;
local db = {}

local MessageQueue = {};  
local MessageThrottle = 0.1;

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
EventFrame:RegisterEvent("CRAFT_UPDATE")
EventFrame:RegisterEvent("ADDON_LOADED");
EventFrame:RegisterEvent("CHAT_MSG_ADDON")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

EventFrame:SetScript("OnEvent", function(self, event, ...)

    if event == "ADDON_LOADED" then
        init()
    end
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
        print(playerName)
        local isInitialLogin, isReloadingUi = ...
        if isInitialLogin or isReloadingUi then
            C_ChatInfo.RegisterAddonMessagePrefix(prefix)
        end
    end

end)

function MessageRecieveHandler(prefix, message, sourceChannel, sourcePlayer)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(message)
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    local success, data = LibSerialize:Deserialize(decompressed)
    DeepPrint(data)
    persistPlayerProfessions(data)
end


function persistPlayerProfessions(data)
    local sourcePlayer, profession, items = parseMessage(data)

end

function parseMessage(data)
    local sourcePlayer = data["player"]
    local profession = data["profession"]
    local items = data["items"]

    return sourcePlayer, profession, items
end


function init()
    db["guild_professions"] = GuildProfessionPlayersDB or {}
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

function GetReagentLink(prof_type, index, n)
    local itemString
    if (prof_type == "craft") then
        itemString = GetCraftReagentItemLink(index, n)
    elseif (prof_type == "trade") then
        itemString = GetTradeSkillReagentItemLink(index, n)
    end

    return itemString

end

function GetReagentCount(prof_type, index, n)
    local reagantCount
    print("checking count")
    if (prof_type == "craft") then
        _, _, reagantCount, _ = GetCraftReagentInfo(index, n);
        print(reagantCount)
    elseif (prof_type == "trade") then
        _, _, reagantCount, _ = GetTradeSkillReagentInfo(index, n)
        print(reagantCount)

    end
    return tostring(reagantCount)
end

function GetItemLink(prof_type, index)
    local itemLink, itemID

    if (prof_type == "trade") then
        itemLink = GetTradeSkillItemLink(index)
        if (not itemLink) then
            return
        end
        itemID = itemLink:match("item:(%d+)")
    elseif (prof_type == "craft") then
        itemLink = GetCraftItemLink(index)
        if (not itemLink) then
            return
        end
        itemID = itemLink:match("item:(%d+)")
    end

    return itemID

end
function guildProfessions:hej(prof_type)
    if (prof_type == "craft" or "trade") then
        local proff = GetProfInfo(prof_type)
        local items = {}
        if (proff ~= nil) then
            items = GetRecipes(prof_type)
            broadCastMessage(items,proff)
        end
    end
end

function GetRecipes(prof_type)
    local items = {}
    for i = 1, GetRecipeCount(prof_type) do
        local item = GetItemLink(prof_type, i)
        table.insert(items, item)
    end
    return items
end


function broadCastMessage(items,proff)
    local payload = prepareMessage(items,proff)
    C_ChatInfo.SendAddonMessage(prefix, payload, "WHISPER", playerName)
end

function prepareMessage(items,proff)
    local message = {}
    message["player"] = playerName
    message["profession"] = proff
    message["items"] = items
    local serialized = LibSerialize:Serialize(message)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    return encoded
end


function DeepPrint (e)
    if type(e) == "table" then
        for k,v in pairs(e) do 
            print("key " ..k)
            DeepPrint(v)
        end
    else 
        print("value" ..e)
    end
end
