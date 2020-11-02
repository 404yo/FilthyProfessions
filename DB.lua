
--[[



Init the ItemDB, itemlinks and what not
-- update itemsDB
-- filter components and handle transactions
-- sort professions table
-- should be able to trigger refresh GUI



]]--
local DB = {}
local GuildProfessions = {}
--------------GLOBALS--------------------------

local gDB = {}
local gItemsDB = {}
local gRealmName
local gGuildName
_G["ItemsDB"] = gItemsDB
_G["GDB"] = gDB
_G["DB"] = DB
GuildProfessions = _G.GuildProfessions
-----------------------------------------------


------------PROFFESSIONS DATABASES-------------

-----------------------------------------------


function DB:init(guildName, realmName, callback)
    gGuildName = guildName
    gRealmName = realmName
    DB:Reset(callback)
end

function DB:Reset(callback)
    GuildProfessionPlayersDB = GuildProfessionPlayersDB or {}
    gDB = GuildProfessionPlayersDB or {}
    gDB[gRealmName] = GuildProfessionPlayersDB[gRealmName] or {}
    gDB[gRealmName].professions = GuildProfessionPlayersDB[gRealmName].professions or {}
    _G.GDB = gDB
    DB:InitItems(function(boolean)
        callback(boolean)
    end)
end


function DB:LoadProfessions()

end

function GetItemData(itemID,proffesion, callback) 
    local itemLink
    local itemLevel
    local icon

    if proffesion == "Enchanting" then  
        icon =  GetSpellTexture(itemID)
        local item2 = Spell:CreateFromSpellID(tonumber(itemID))
        item2:ContinueOnSpellLoad(function()
            --- get reagents
            itemLink = item2:GetSpellName()
            icon = GetSpellTexture(itemID)
            callback(itemLink,icon,nil,true)
          
        end)
    else 
        local item2 = Item:CreateFromItemID(tonumber(itemID))
        item2:ContinueOnItemLoad(function()
            itemLink = item2:GetItemLink()
            itemLevel = item2:GetCurrentItemLevel()
            icon = item2:GetItemIcon()
            callback(itemLink,icon,itemLevel,true)
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
            i = i+1

            local itemCount = GetItemCount(reagentKey)
            table.insert(reagents, {reagent:GetItemLink(),reagent:GetItemIcon(),reagentKey,count, itemCount})
            if i == size then 
             callback(reagents,true)
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
        local exists = _db[itemId]["players"][gGuildName .."-"..sourcePlayer] or false
        if not exists then
            _db[itemId]["players"][gGuildName .."-"..sourcePlayer] = true
        end
    end 
    gDB[gRealmName].professions[profession] = _db
    callback(true)
end

function DB:parseDBItems(profession, callback)
    local items = gDB[gRealmName].professions[profession]
    local parsedItems = {}
  
    if items == nil or  getTableSize(items) == 0 then 
        callback(parsedItems)
        return  parsedItems 
    end
    local size = getTableSize(items) 
    local count = 0
    for itemID, v in pairs(items) do
        local players = v.players
        -- callback hell, i know, i'll use an event trigger if it gets bigger, or will i...
        GetItemData(itemID,profession, function(itemLink,icon,itemLevel,result)
            local item =  {itemLink, itemLevel,icon,itemID}
            GetReagentData(v.reagents,function(reagents,result2)
                count = count + 1
                if result2 then
                    table.insert(parsedItems, {item,reagents,players})
                end
                if count == size then
                    callback(parsedItems)
                end
            end)
        end)
    end
end

function DB:PrintItems()
    for k,v in pairs(gItemsDB) do
        print(k)
    end
end

function DB:InitItems(callback)
    local i = 0
    DB:LoadItems("Cooking", function()
        i = i+1
        print("Cooking Loaded")
        if i == 8 then 
            callback(true)
        end
    end)

    DB:LoadItems("Alchemy", function()
        i = i+1
        print("Alchemy Loaded")
        if i == 8 then 
            callback(true)
        end
    end)


    DB:LoadItems("Enchanting", function()
        i = i+1
        print("Enchanting Loaded")
        if i == 8 then 
            callback(true)
        end
    end)

    DB:LoadItems("First Aid", function()
        i = i+1
        print("First Aid loaded")
        if i == 8 then 
            callback(true)
        end
    end)

    DB:LoadItems("Tailoring", function()
        print("Tailoring Loaded")
        i = i+1
        if i == 8 then 
            callback(true)
        end
    end)

    DB:LoadItems("Engineering", function()
        print("Engineering Loaded")
        i = i+1
        if i == 8 then 
            callback(true)
        end
    end)


    DB:LoadItems("Leather Working", function()
        print("Leather Working Loaded")
        i = i+1
        if i == 8 then 
            callback(true)
        end
    end)


    
    DB:LoadItems("Black Smithing", function()
        print("Black Smithing Loaded")
        i = i+1
        if i == 8 then 
            callback(true)
        end
    end)





    -- DB:LoadItems("First Aid", function()

    -- end)

    -- DB:LoadItems("First Aid", function()

    -- end)

    -- DB:LoadItems("First Aid", function()

    -- end)


end

function DB:LoadItems(profession,callback)
    gItemsDB[profession] = {}
    DB:parseDBItems(profession, function(parsedItems)
        gItemsDB[profession] = parsedItems
        callback(true)
    end)    

end

function tprint (tbl, indent)
    if tbl == nil then return end
    if not indent then indent = 0 end

    for k, v in pairs(tbl) do
      formatting = string.rep("  ", indent) .. k .. ": "
      if type(v) == "table" then
        print(formatting)
        tprint(v, indent+1)
      elseif type(v) == 'boolean' then
        print(formatting .. tostring(v))		
      else
        print(formatting .. v)
      end
    end
  end
 