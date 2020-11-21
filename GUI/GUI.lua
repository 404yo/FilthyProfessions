
local GUI = {}
local FilthyProfessions = _G.FilthyProfessions
FilthyProfessions.GUI = GUI
local gPinnedItems = {}
local gSearchItems = {}
local gItemsDB = {}


local font

local blacksmithingBOX = "FILTHY_Black Smithing"
local enchantingBOX = "FILTHY_Enchanting"
local engineeringBOX = "FILTHY_Engineering"
local leatherWorkingBOX = "FILTHY_Leather Working"
local tailoringBOX = "FILTHY_Tailoring"
local cookingBOX = "FILTHY_Cooking"
local firstAidBOX = "FILTHY_First Aid"
local alchemyBOX = "FILTHY_Alchemy"
local pinnedBOX  = "FILTHY_pinned"
local gFilterSettings = {
    [blacksmithingBOX] = true,
    [enchantingBOX] = true,
    [engineeringBOX] = true,
    [leatherWorkingBOX] = true,
    [tailoringBOX] = true,
    [cookingBOX] = true,
    [firstAidBOX] = true,
    [alchemyBOX] = true,
    [pinnedBOX] = false,
}

local tonumber = tonumber
local tostring = tostring
local next = next
local match = string.match
local t_sort = table.sort
local t_insert = table.insert


function GUI:init()
    GUI:LoadStyling()
    FilthyProfessions.GUI = GUI
    FilthyProfessions.gFilterSettings = gFilterSettings
    gItemsDB = FilthyProfessions.gItemsDB
    gPinnedItems = FilthyProfessions.gPinnedItems
    GUI.UI = FilthyProfessions.MainWindow
    GUI.Item = FilthyProfessions.Item
    GUI.UI:Create()
    GUI:CreateItems()
    GUI:SortItemList()
end

function GUI:LoadStyling()
    font = "Fonts\\FRIZQT__.ttf"
    FilthyProfessions.font = font
end


function GUI:SearchItems(str)

    for profession, items in next, gItemsDB do
        local i = 0
        for itemID, item in next, items do
            if match(item[1]:lower(), str:lower()) then
                gSearchItems[itemID] = true
            else
                gSearchItems[itemID] = false
            end
        end
    end

    if gFilterSettings[pinnedBOX] then
        for k,v in next, gSearchItems do
            if not gPinnedItems[k]  then
                gSearchItems[k] = false
            end
        end
    end

    for k,v in next, GUI.Item.items do
        if gSearchItems[k]  and gFilterSettings["FILTHY_"..v.frame.profession] then
            GUI.Item.items[k].frame:Show()
        else
            GUI.Item.items[k].frame:Hide()
        end
    end
    GUI:SortItemList()
end


function  GUI:DisplayPinnedItems()
    for k,v in next, GUI.UI.items do
        if gPinnedItems[k] then
            GUI.UI.items[k].frame:Show()
        else
            GUI.UI.items[k].frame:Hide()
        end
    end
    GUI:SortItemList()
end

function GUI:DisplayFilteredItems()
    if gFilterSettings[pinnedBOX] then
        for k,v in next, GUI.Item.items do
            if gPinnedItems[k] then
                GUI.Item.items[k].frame:Show()
            else
                GUI.Item.items[k].frame:Hide()
            end
        end
    else
        for k,v in next, GUI.Item.items do
            if gFilterSettings["FILTHY_"..v.frame.profession] then
                GUI.Item.items[k].frame:Show()
            else
                GUI.Item.items[k].frame:Hide()
            end
        end
    end
    GUI:SortItemList()
end


local function SortByItemLevel(a, b)
    return tonumber(a[2]) > tonumber(b[2])
end


function GUI:TOGGLE()
    if  GUI.UI.frame:IsVisible() then
        GUI.UI.frame:Hide()
    else
        GUI.UI.frame:Show()
    end
end

function GUI:CreateItems(db)

    for profession, items in next, gItemsDB do
        for itemID, itemContent in next, items do
            if not GUI.Item.items[itemID] then
                GUI.Item:Create(
                nil,
                profession,
                GUI.UI.content,
                itemContent
                )
            end
        end
    end
    GUI:SortItemList()
end


local sortedItemIds = {}
function GUI:SortItemList()
  

    for itemID,item in next, GUI.Item.items do
        -- if item.frame:IsVisible() then
        --    sortedItemIds[#sortedItemIds+1]["ilvl"] = item.frame.itemLevel
        --    sortedItemIds[#sortedItemIds+1]["id"] = itemID
                sortedItemIds[#sortedItemIds+1] = {itemID, item.frame.itemLevel}
        -- end
    end

    t_sort(sortedItemIds,SortByItemLevel)
    local firstItem = true
    local kbefore
    for k, v in next, sortedItemIds do
        if GUI.Item.items[v[1]].frame:IsVisible() then
            local itemID = v[1]
            if firstItem == false then
                GUI.Item.items[itemID].frame:SetPoint( "TOP",GUI.Item.items[kbefore].frame ,"BOTTOM",0,0)
            else
                GUI.Item.items[itemID].frame:SetPoint("TOP", GUI.UI.content, "TOP",15,-2)
            end
            kbefore = itemID
            firstItem = false
     
        end
    end
    for k,v in next,sortedItemIds do sortedItemIds[k] = nil end
end

local function SortByProfession(a,b)
    return a.profession > b.profession
end

local function SortByName(a,b)
    return a.itemName > b.itemName
end

function  GUI:sortItems(rowFrames, sort_type)
    if sort_type == "itemLevel" then
        t_sort(rowFrames, SortByItemLevel)
    end

    if sort_type == "professions" then
        t_sort(rowFrames, SortByProfession)
    end

    if sort_type == "name" then
        t_sort(rowFrames, SortByName)
    end

    return rowFrames
end
function GUI:tprint(tbl, indent)
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
            GUI:tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end
