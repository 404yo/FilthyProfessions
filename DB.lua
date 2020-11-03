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

local gDB = {}
local gItemsDB = {}
local gRealmName
local gGuildName
_G["ItemsDB"] = gItemsDB
_G["GDB"] = gDB
_G["DB"] = DB
FilthyProfessionsssions = _G.FilthyProfessions
-----------------------------------------------


function DB:init(guildName, realmName, callback)
    gGuildName = guildName
    gRealmName = realmName
    DB:Reset(callback)
end

function DB:Reset(callback)
    FilthyProfessionsPlayersDB = FilthyProfessionsPlayersDB or {}
    gDB = FilthyProfessionsPlayersDB or {}
    gDB[gRealmName] = FilthyProfessionsPlayersDB[gRealmName] or {}
    gDB[gRealmName].professions = FilthyProfessionsPlayersDB[gRealmName].professions or {}
    _G.GDB = gDB
    DB:InitItems(function(boolean)
        callback(boolean)
    end)
end

function DB:GetRealmDB()
        gDB[gRealmName] = DB:GetDB()[gRealmName]
    return gDB[gRealmName] or {}
end

function DB:GetDB()
    FilthyProfessionsPlayersDB = FilthyProfessionsPlayersDB or {}
    FilthyProfessionsPlayersDB[gRealmName] = FilthyProfessionsPlayersDB[gRealmName] or {}
    FilthyProfessionsPlayersDB[gRealmName].professions = FilthyProfessionsPlayersDB[gRealmName].professions or {}
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
end

function DB:CommitProfessions(professions)
    local db = DB:GetDB()
    db[gRealmName].professions = professions
    DB:Commit(db)
end

function DB:GetProfessionsDB()
    local db = DB:GetDB()
    return db[gRealmName].professions or  {}
end

function isTableEmpty(table)

    local next = next
    if next(table) == nil then
        return true
    end
    return false

end

function DB:InsertAlienDB(alienDB)
    -- db is not of this realm, spooky i know :(
    if alienDB[gRealmName] == nil then
        return
    end
    -- empty db, sad face :(
    if alienDB[gRealmName].professions == nil then
        return
    end

    local currentDB = DB:GetRealmDB().professions or {}
    -- no need to parse db, just store it, the player table db is empty

    if isTableEmpty(currentDB) then
        DB:Commit(alienDB)
        return
    end

    local proffesions = alienDB[gRealmName].professions

    local alienProfessions = {
        ["First Aid"] = proffesions["First Aid"] or {},
        ["Alchemy"] = proffesions["Alchemy"] or {},
        ["Engineering"] = proffesions["Engineering"] or {},
        ["Tailoring"] = proffesions["Tailoring"] or {},
        ["Enchanting"] = proffesions["Enchanting"] or {},
        ["Black Smithing"] = proffesions["Black Smithing"] or {},
        ["Leather Working"] = proffesions["Leather Working"] or {},
        ["Cooking"] = proffesions["Cooking"] or {}
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

    for k, v in pairs(currentProfessions) do
        unholyDB[k] = DB:MergeProfessions(alienProfessions[k], v)
    end

end


function DB:MergeProfessions(source, destination)

    for k, v in pairs(source) do
        local d = destination[k]
        if d == nil then
            destination[k] = v
        else
            destination[k].players = MergePlayers(source[k].players, destination[k].players)
        end
    end

    return destination
end

function MergePlayers(source, destination)

    for k, v in pairs(source) do
        local d = destination[k]
        if d == nil then
            destination[k] = v
        else
        end
        return destination

    end
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
            icon = GetSpellTexture(itemID)
            callback(itemLink, icon, nil, true)

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

function getTableSize(table)
    local count = 0
    for k, v in pairs(table) do
        count = count + 1
    end
    return count
end

function GetReagentData(reagentData, callback)
    local reagents = {}
    local size = getTableSize(reagentData)
    local i = 0
    for reagentKey, count in pairs(reagentData) do
        local reagent = Item:CreateFromItemID(tonumber(reagentKey))
        reagent:ContinueOnItemLoad(function()
            i = i + 1

            local itemCount = GetItemCount(reagentKey)
            table.insert(reagents, {reagent:GetItemLink(), reagent:GetItemIcon(), reagentKey, count, itemCount})
            if i == size then
                callback(reagents, true)
            end
        end)
    end
end

function DB:InsertToDB(profession, items, sourcePlayer, callback)
    local _db = {}
    for itemId, reagents in pairs(items) do
        _db[itemId] = _db[itemId] or {}

        _db[itemId]["reagents"] = reagents

        _db[itemId]["players"] = _db[itemId]["players"] or {}
        local exists = _db[itemId]["players"][gGuildName .. "-" .. sourcePlayer] or false
        if not exists then
            _db[itemId]["players"][gGuildName .. "-" .. sourcePlayer] = true
        end
    end
    gDB[gRealmName].professions[profession] = _db
    DB:Commit(gDB)
    callback(true)
end

function DB:parseDBItems(profession, callback)
    local items = DB:GetProfessionsDB()[profession] or {}
    local parsedItems = {}

    if items == nil or getTableSize(items) == 0 then
        callback(parsedItems)
        return parsedItems
    end
    local size = getTableSize(items)
    local count = 0
    for itemID, v in pairs(items) do
        local players = v.players
        -- callback hell, i know, i'll use an event trigger if it gets bigger, or will i...
        GetItemData(itemID, profession, function(itemLink, icon, itemLevel, result)
            local item = {itemLink, itemLevel, icon, itemID}
            GetReagentData(v.reagents, function(reagents, result2)
                count = count + 1
                if result2 then
                    table.insert(parsedItems, {item, reagents, players})
                end
                if count == size then
                    callback(parsedItems)
                end
            end)
        end)
    end
end

function DB:GetItemsDB(profession)
    if profession ~= nil then
        return gItemsDB[profession] or {}
    end
    return gItemsDB or {}
end

function DB:PrintItems()
    for k, v in pairs(gItemsDB) do
        print(k)
    end
end

function DB:InitItems(callback)
    local professions = {
        "First Aid","Alchemy","Engineering","Tailoring","Enchanting","Black Smithing","Leather Working","Cooking"
    }
    local i = 0
    for k,v in pairs(professions) do
        DB:LoadItems(v, function()
            i = i + 1
            if i == 8 then
                callback(true)
            end
        end)
    end

end

function DB:LoadItems(profession, callback)
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
