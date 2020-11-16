--------------GLOBALS--------------------------
local DB = {}
local GUI = {}
local FilthyProfessions = _G.FilthyProfessions
FilthyProfessions.DB = DB
local gItemsDB
local gRealmName
local type, next, t_insert  = type, next, table.insert


local gDB = {}
local gPlayersDB = {}
local gProfessions = {"First Aid", "Alchemy", "Engineering", "Tailoring", "Enchanting", "Black Smithing", "Leather Working", "Cooking"}

function DB:init(callback)
    gDB = FilthyProfessions.gDB
    gPlayersDB = FilthyProfessions.gPlayersDB
    gItemsDB = FilthyProfessions.gItemsDB
    gRealmName = FilthyProfessions.realmName
    GUI = FilthyProfessions.GUI
    DB:InitItems(1, function()
        callback(true)
    end)
end


-- local function MergePlayers(source, destination)
--     for player, v in next, source do
--         local d = destination[player]
--         if d == nil then
--             destination[player] = v
--         end
--     end
--     return destination
-- end
-- local function MergeProfessions(source, destination)
--     for itemID, item in next, source do
--         local d = destination[itemID]
--         if d == nil then
--             destination[itemID] = item
--         else
--             destination[itemID][gRealmName] = MergePlayers(source[itemID][gRealmName], destination[itemID][gRealmName])
--         end
--     end
    
--     return destination
-- end

-- function DB:InsertAlienDB(alienDB)
--     if alienDB == nil then
--         return
--     end
    
--     if alienDB.professions == nil then
--         return
--     end
    
--     for profession, items in next, gDB.professions do
--         gDB.professions[profession] = MergeProfessions(alienDB.professions[profession], items)
--     end

-- end
local _Spell = Spell
local function GetItemData(itemID, proffesion, callback)
    local itemLink
    local itemLevel
    local icon
    if proffesion == "Enchanting" then
        icon = GetSpellTexture(itemID)
        local item2 = _Spell:CreateFromSpellID(tonumber(itemID))
        item2:ContinueOnSpellLoad(function()
                itemLink = item2:GetSpellName()
                callback(itemLink, icon, itemID, true)
        
        end)
    else
        local item2 = Item:CreateFromItemID(tonumber(itemID))
        item2:ContinueOnItemLoad(function()
            itemLink = item2:GetItemLink()
            itemLevel = item2:GetCurrentItemLevel()
            icon = item2:GetItemIcon()
            callback(itemLink, icon, itemLevel, true)
        end)
    end

end



local function getTableSize(table)
    local count = 0
    if table == nil then return count end
    
    for k, v in next, table do
        count = count + 1
    end
    return count
end
local _Item = Item
local function GetReagentData(reagentData, callback)
    local size = getTableSize(reagentData)
    local reagentsData = {}
    
    
    local i = 0
    for reagentKey, count in next, reagentData do
        local reagent = _Item:CreateFromItemID(tonumber(reagentKey))
        reagent:ContinueOnItemLoad(function()
            i = i + 1
            reagentsData[i] = {reagent:GetItemLink(), reagent:GetItemIcon(), reagentKey, count}
            if i == size then
                callback(reagentsData, true)
                for k, v in next, reagentsData do reagentsData[k] = nil end
            end
        end)
    end
end


local function ParseItemData(itemID, profession, reagents, callback)
    GetItemData(itemID, profession, function(itemLink, icon, itemLevel)
        GetReagentData(reagents, function(reagent, bool)
            callback(itemLink, itemLevel, icon, reagent)
        end)
    end)
end

local function table_copy(src, dest)
    for index, value in next, src do
        if type(value) == "table" then
            dest[index] = {}
            table_copy(value, dest[index])
        else
            dest[index] = value
        end
    end
end

function DB:parseDBItems(profession, callback)
    local items = gDB.professions[profession]
    local size = getTableSize(items)
    if items == nil or size == 0 then
        callback(true)
        return
    end
    
    local count = 0
    for itemID, v in next, items do

        ParseItemData(itemID, profession, v.reagents, function(itemLink, itemLevel, icon, reagents)
            if itemLink ~= nil then
                count = count + 1
                gItemsDB[profession][itemID] = gItemsDB[profession][itemID] or {}
                gItemsDB[profession][itemID][1] = itemLink
                if profession == "Enchanting" then
                    itemLevel = math.floor((itemID / 7000) ^ 2 * 5 + 1)
                end
                gItemsDB[profession][itemID][2] = itemLevel
                gItemsDB[profession][itemID][3] = icon
                gItemsDB[profession][itemID][4] = itemID
                gItemsDB[profession][itemID][5] = {}
                table_copy(reagents, gItemsDB[profession][itemID][5])
                reagents = nil
                v = nil
            end
            if count == size then
                callback(true)
            end
        end)
    end
end


function DB:InsertToDB(profession, items, sourcePlayer, callback)
    local insert = true
    DB:tprint(items)
    for k,itemID in next, items do
        local id = tonumber(itemID)
        gPlayersDB[profession][id] = gPlayersDB[profession][id] or {}

        for k,name in next, gPlayersDB[profession][id] do 
             if name == sourcePlayer then insert = false end
        end
        if insert then
            t_insert(gPlayersDB[profession][id],sourcePlayer)
        end
    end
    callback(true)

end

local function LoadItems(profession, callback)
    DB:parseDBItems(profession, function(bool)callback(bool) end)
end

function DB:InitItems(profession, callback)
    if profession < 8 then
        LoadItems(gProfessions[profession], function(bool)
            DB:InitItems(profession + 1, callback)
        end)
        return
    end
    LoadItems(gProfessions[8], function()
        callback(true)
    end)
end

function DB:tprint(tbl, indent)
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
            DB:tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end
