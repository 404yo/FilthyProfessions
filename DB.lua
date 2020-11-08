--[[



Init the ItemDB, itemlinks and what not
-- update itemsDB
-- filter components and handle transactions
-- sort professions table
-- should be able to trigger refresh GUI



]] --

local DB = {}
local FilthyProfessions = {}
--------------GLOBALS--------------------------
local gProfileDB = {}
local gDB = {}
local gItemsDB = {}
local gRealmName
local gGuildName
local gPlayerName
local gProfile
local initProfile = false
_G["ItemsDB"] = gItemsDB
_G["GDB"] = gDB
_G["DB"] = DB
_G["GProfileDB"] = gProfileDB
FilthyProfessionsssions = _G.FilthyProfessions
-----------------------------------------------
local next = next
local t_insert = table.insert
function DB:init(guildName, realmName, playerName, callback)
    gGuildName = guildName
    gRealmName = realmName
    gPlayerName = playerName
    gProfile = realmName .. "-" .. playerName
    DB:initProfile()
    DB:Reset(callback)

end

function DB:StoreProfile(gProfile)
    if gProfileDB == nil then
        return
    end
    FilthyProfessionsPlayerProfile[gProfile] = gProfileDB
    _G["GProfileDB"] = gProfileDB
end

function DB:StorePinnedItems(pinnedItems)
    gProfileDB = DB:GetProfile()
    gProfileDB["pinned"] = pinnedItems
    FilthyProfessionsPlayerProfile[gProfile] = gProfileDB or {}
    _G.GrpofileDB = gProfileDB
end

function DB:GetPinnedItems()
    local profile = DB:GetProfile() or {}
    return profile["pinned"] or {}
end

function DB:initProfile()
    FilthyProfessionsPlayerProfile = FilthyProfessionsPlayerProfile or {}
    FilthyProfessionsPlayerProfile[gProfile] = FilthyProfessionsPlayerProfile[gProfile] or {}
    FilthyProfessionsPlayerProfile[gProfile]["pinned"] = FilthyProfessionsPlayerProfile[gProfile]["pinned"] or {}
    gProfileDB = FilthyProfessionsPlayerProfile[gProfile]
end

function DB:GetProfile()
    if not initProfile then
     DB:initProfile()
     initProfile = true
    end
    gProfileDB = FilthyProfessionsPlayerProfile[gProfile] or {}
    return gProfileDB
end

function DB:Reset(callback)
    FilthyProfessionsPlayersDB = FilthyProfessionsPlayersDB or {}
    gDB = nil
    gDB = FilthyProfessionsPlayersDB or {}
    gDB.professions = FilthyProfessionsPlayersDB.professions or {}

    _G.GDB = gDB
    InitItems(function(boolean)
        callback(boolean)
    end)
end

function DB:GetRealmDB()
    gDB = DB:GetDB()
    return gDB or {}
end

function DB:GetDB()
    FilthyProfessionsPlayersDB = FilthyProfessionsPlayersDB or {}
    FilthyProfessionsPlayersDB.professions = FilthyProfessionsPlayersDB.professions or {}
    local db = FilthyProfessionsPlayersDB
    return db
end

function DB:StoreDB()
    FilthyProfessionsPlayersDB = gDB or {}
end

function DB:Commit(db)
    if db ~= nil then
    end
    FilthyProfessionsPlayersDB = db
    gDB = db
    _G.GDB = gDB
end

function DB:CommitProfessions(professions)
    local db = DB:GetDB()
    db.professions = professions
    DB:Commit(db)
end

function DB:GetProfessionsDB()
    local db = DB:GetDB()
    return db.professions or {}
end

function isTableEmpty(table)

    if next(table) == nil then
        return true
    end
    return false

end

function DB:InsertAlienDB(alienDB)
    -- db is not of this realm, spooky i know :(
    if alienDB == nil then
        return
    end
    -- empty db, sad face :(
    if alienDB.professions == nil then
        return
    end

    local currentDB = DB:GetRealmDB().professions or {}
    -- no need to parse db, just store it, the player table db is empty

    if isTableEmpty(currentDB) then
        DB:Commit(alienDB)
        return
    end

    local professions = alienDB.professions

    local alienProfessions = {
        ["First Aid"] = professions["First Aid"] or {},
        ["Alchemy"] = professions["Alchemy"] or {},
        ["Engineering"] = professions["Engineering"] or {},
        ["Tailoring"] = professions["Tailoring"] or {},
        ["Enchanting"] = professions["Enchanting"] or {},
        ["Black Smithing"] = professions["Black Smithing"] or {},
        ["Leather Working"] = professions["Leather Working"] or {},
        ["Cooking"] = professions["Cooking"] or {}
    }

    local currentProfessions = {
        ["First Aid"] = currentDB["First Aid"] or {},
        ["Alchemy"] = currentDB["Alchemy"] or {},
        ["Engineering"] = currentDB["Engineering"] or {},
        ["Tailoring"] = currentDB["Tailoring"] or {},
        ["Enchanting"] = currentDB["Enchanting"] or {},
        ["Black Smithing"] = currentDB["Black Smithing"] or {},
        ["Leather Working"] = currentDB["Leather Working"] or {},
        ["Cooking"] = currentDB["Cooking"] or {}
    }

    local unholyDB = {}

    for profession, items in next ,currentProfessions do
        gDB.professions[profession] = MergeProfessions(alienProfessions[profession], items)
    end

end

function MergeProfessions(source, destination)
    for itemID, item in next, source do
        local d = destination[itemID]
        if d == nil then
            destination[itemID] = item
        else
            destination[itemID][gRealmName] = MergePlayers(source[itemID][gRealmName], destination[itemID][gRealmName])
        end
    end

    return destination
end

function MergePlayers(source, destination)
    for player, v in next, source do
        local d = destination[player]
        if d == nil then
            destination[player] = v
        end
    end
    return destination
end

function GetItemData(itemID, proffesion, callback)
    local itemLink
    local itemLevel
    local icon
    if proffesion == "Enchanting" then
        icon = GetSpellTexture(itemID)
        local item2 = Spell:CreateFromSpellID(tonumber(itemID))
        item2:ContinueOnSpellLoad(function()
            --- get reagents
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

function DB:InsertToDB(profession, items, sourcePlayer, callback)
    
    -- local db = DB:GetDB()
    -- local _p = gDB.professions[profession]

    gDB.professions[profession] = gDB.professions[profession] or {}
    for itemId, reagents in next, items do
        if not gDB.professions[profession][itemId] then
            gDB.professions[profession][itemId] = {["reagents"] = reagents,[gRealmName] = {}}
            -- gDB.professions[profession][itemId]["reagents"] = reagents
            -- gDB.professions[profession][itemId][gRealmName] = {}
        end 

        if not gDB.professions[profession][itemId][gRealmName][sourcePlayer] then
            gDB.professions[profession][itemId][gRealmName][sourcePlayer] = true
        end
    end
   
    gDB.professions[profession] = gDB.professions[profession] 
    -- DB:Commit(db)

    DB:parseDBItems(profession, function(items)
        gItemsDB[profession] = items
        callback(true)
    end)

end

function getTableSize(table)
    local count = 0
 
    local tbl = table
    for k, v in next, tbl do
        count = count + 1
    end
    return count
end

function DB:parseDBItems(profession, callback)
    local parsedItems = {}
    local items = DB:GetProfessionsDB()[profession] or {}
    local size = getTableSize(items)
    if items == nil or size == 0 then
        callback(parsedItems)
        return parsedItems
    end
    
    local count = 0
   
    for itemID, v in next, items do
        local players = v[gRealmName]
        ParseItemData(itemID,profession,v.reagents,players, function(item)
            count = count + 1
            if item ~= nil then 
                t_insert(parsedItems,item)
            end
            if count == size then
                callback(parsedItems)
            end
        end)
    end
end


-- function parseSingleItem(callback)
--     ParseItemData(itemID,profession,v.reagents,players, function(item)
--         count = count + 1
--         if item ~= nil then 
--             t_insert(parsedItems,item)
--         end
--         if count == size then
--             callback(parsedItems)
--         end
--     end)
-- end

local gItem = {}
local _item = {}
local _reagents = {}

function ParseItemData(itemID, profession, reagents, players, callback)

    if players == nil then callback(nil) return end
    local count = 0
    GetItemData(itemID, profession, function(itemLink, icon, itemLevel, result)
        _item = {itemLink, itemLevel, icon, itemID}
        GetReagentData(reagents, function(r,r2)
            _reagents = r
            gItem ={_item,_reagents,players}
            callback(gItem)
        end)
    end)
end

-- function ParseReagentData(reagents,callback)
--     local count = 0
--     local size = getTableSize(reagents)
--     GetReagentData(reagents, function(reagents, result2)
--         count = count + 1
--         if result2 then
--             table.insert(parsedItems, {item, reagents, players})
--         end
--         if count == size then
--             callback(parsedItems)
--         end
--     end)
-- end
local t_insert = table.insert
function GetReagentData(reagentData, callback)
    local reagentsData = {}

    local size = getTableSize(reagentData)
    local i = 0
    local next = next
    for reagentKey, count in next, reagentData do
        local reagent = Item:CreateFromItemID(tonumber(reagentKey))
        reagent:ContinueOnItemLoad(function()
            i = i + 1
            local itemCount = GetItemCount(reagentKey)
            t_insert(reagentsData, {reagent:GetItemLink(), reagent:GetItemIcon(), reagentKey, count, itemCount})
            if i == size then
                callback(reagentsData, true)
            end
        end)
    end
end

function DB:GetItemsDB(profession)
    if profession ~= nil then
        return gItemsDB[profession] or {}
    end
    return gItemsDB or {}
end

function InitItems(callback)
    local professions = {"First Aid", "Alchemy", "Engineering", "Tailoring", "Enchanting", "Black Smithing",
                         "Leather Working", "Cooking"}
    local i = 0
    local next = next
    for k, v in next ,professions do
        LoadItems(v, function()
            i = i + 1
            if i == 8 then
                callback(true)
            end
        end)
    end

end

function LoadItems(profession, callback)
    gItemsDB[profession] = {}
    DB:parseDBItems(profession, function(parsedItems)
        gItemsDB[profession] = parsedItems
        callback(true)
    end)

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
            print(formatting .. v)
        end
    end
end
