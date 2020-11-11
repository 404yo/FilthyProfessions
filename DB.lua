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

local t_insert = table.insert


local gProfessions = {"First Aid", "Alchemy", "Engineering", "Tailoring", "Enchanting", "Black Smithing","Leather Working", "Cooking"}
-----------------------------------------------

local t_insert = table.insert
local next = next

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
    -- gProfileDB = DB:GetProfile()
    -- gProfileDB["pinned"] = pinnedItems
    -- FilthyProfessionsPlayerProfile[gProfile] = gProfileDB or {}
    -- _G.GrpofileDB = gProfileDB
end

function DB:GetPinnedItems()
    local profile = DB:GetProfile() or {}
    return profile["pinned"] or {}
end

function DB:initProfile()
    FilthyProfessionsPlayersDB = FilthyProfessionsPlayersDB or {}
    FilthyProfessionsPlayersDB.professions = FilthyProfessionsPlayersDB.professions or {}
    
    FilthyProfessionsPlayersDB.professions["First Aid"] =   FilthyProfessionsPlayersDB.professions["First Aid"]  or {} 
    FilthyProfessionsPlayersDB.professions["Leather Working"] =   FilthyProfessionsPlayersDB.professions["Leather Working"] or {}
    FilthyProfessionsPlayersDB.professions["Black Smithing"] =   FilthyProfessionsPlayersDB.professions["Black Smithing"] or {}
    FilthyProfessionsPlayersDB.professions["Engineering"] =    FilthyProfessionsPlayersDB.professions["Engineering"] or {}
    FilthyProfessionsPlayersDB.professions["Cooking"] =  FilthyProfessionsPlayersDB.professions["Cooking"] or {}
    FilthyProfessionsPlayersDB.professions["Enchanting"] =   FilthyProfessionsPlayersDB.professions["Enchanting"] or {}
    FilthyProfessionsPlayersDB.professions["Tailoring"] =   FilthyProfessionsPlayersDB.professions["Tailoring"] or {}
    FilthyProfessionsPlayersDB.professions["Alchemy"] =   FilthyProfessionsPlayersDB.professions["Alchemy"] or {}

    gDB = FilthyProfessionsPlayersDB

    gItemsDB["First Aid"] =   gItemsDB["First Aid"]  or {} 
    gItemsDB["Leather Working"] =   gItemsDB["Leather Working"] or {}
    gItemsDB["Black Smithing"] =   gItemsDB["Black Smithing"] or {}
    gItemsDB["Engineering"] =    gItemsDB["Engineering"] or {}
    gItemsDB["Cooking"] =  gItemsDB["Cooking"] or {}
    gItemsDB["Enchanting"] =   gItemsDB["Enchanting"] or {}
    gItemsDB["Tailoring"] =   gItemsDB["Tailoring"] or {}
    gItemsDB["Alchemy"] =   gItemsDB["Alchemy"] or {}

    _G.ItemsDB  = gItemsDB
    
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
    DB:InitItems(1,function(boolean)
        callback(boolean)
    end)
end

function DB:GetRealmDB()
    gDB = DB:GetDB()
    return gDB or {}
end

function DB:GetDB()
    return gDB
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

local function isTableEmpty(table)

    if next(table) == nil then
        return true
    end
    return false

end


local function MergePlayers(source, destination)
    for player, v in next, source do
        local d = destination[player]
        if d == nil then
            destination[player] = v
        end
    end
    return destination
end 
local function MergeProfessions(source, destination)
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

    local currentProfessions = {
        ["First Aid"] = currentDB["First Aid"],
        ["Alchemy"] = currentDB["Alchemy"],
        ["Engineering"] = currentDB["Engineering"],
        ["Tailoring"] = currentDB["Tailoring"] or {},
        ["Enchanting"] = currentDB["Enchanting"],
        ["Black Smithing"] = currentDB["Black Smithing"],
        ["Leather Working"] = currentDB["Leather Working"],
        ["Cooking"] = currentDB["Cooking"]
    }
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

    for profession, items in next ,currentProfessions do
        gDB.professions[profession] = MergeProfessions(alienProfessions[profession], items)
    end

end





local function GetItemData(itemID, proffesion, callback)
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



local function getTableSize(table)
    local count = 0
    if table == nil then return count end

    for k, v in next, table do
        count = count + 1
    end
    return count
end


local reagentsData = {}
local function GetReagentData(reagentData, callback)
  
    local size = getTableSize(reagentData)
    local i = 0
    for reagentKey, count in next, reagentData do
        local reagent = Item:CreateFromItemID(tonumber(reagentKey))
        reagent:ContinueOnItemLoad(function()
            i = i + 1
            local itemCount = GetItemCount(reagentKey)
            reagentsData[i]={reagent:GetItemLink(), reagent:GetItemIcon(), reagentKey, count, itemCount}
            if i == size then
                callback(reagentsData, true)
            end
        end)
    end
end


local parsedItems = {true,true,true,true,true}
local function ParseItemData(itemID, profession, reagents, players,callback)
    if players == nil then return end
    print(itemID)
    GetItemData(itemID, profession, function(itemLink, icon, itemLevel)
        GetReagentData(reagents, function(r,r2)
            print("itemLink",itemLink,"icon",icon,"itemLevel",itemLevel)
            parsedItems = {itemLink, itemLevel, icon, itemID,r,players}
            callback(parsedItems)
        end)
    end)
end


function DB:parseDBItems(profession,callback)
    local items = gDB.professions[profession]  
    local size = getTableSize(items)
    if items == nil or size == 0 then
        callback(true)
        return
    end

    local count = 0
    for itemID, v in next, items do
        ParseItemData(itemID, profession, v.reagents, v[gRealmName],function(item)
            count = count + 1
            print("got callback")
            if item ~= nil then 
                gItemsDB[profession] = gItemsDB[profession] or {}
                gItemsDB[profession][itemID] = item
            end
            if count == size then
                callback(true)
            end
        end)
    end
end


function DB:InsertToDB(profession, items, sourcePlayer, callback)
    
    gDB.professions[profession] = gDB.professions[profession] or {}
    for itemId, reagents in next, items do
        if not gDB.professions[profession][itemId] then
            gDB.professions[profession][itemId] = {["reagents"] = reagents,[gRealmName] = {}}
        end 

        if not gDB.professions[profession][itemId][gRealmName][sourcePlayer] then
            gDB.professions[profession][itemId][gRealmName][sourcePlayer] = true
        end
    end
   
    gDB.professions[profession] = gDB.professions[profession] 

    DB:parseDBItems(profession, function(bool) 
        callback(bool)
    end)

end



function DB:GetItemsDB(profession)
    if profession ~= nil then
        return gItemsDB[profession]
    end
    return gItemsDB
end

local function LoadItems(profession, callback)
    gItemsDB[profession] = nil
    DB:parseDBItems(profession, function(bool) callback(bool) end)
end

function DB:InitItems(profession,callback)
    print("hej")
    if profession < 7 then
            LoadItems(gProfessions[profession], function()
                DB:InitItems(profession+1, callback)
            end)
  
        return
    end

    LoadItems(gProfessions[profession+1], function()
        callback(true)
        collectgarbage("collect")
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
        formatting = string.rep("  ", indent) .. k .. ": "
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
