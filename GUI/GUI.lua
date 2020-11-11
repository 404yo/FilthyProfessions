local GUI = {}

local FilthyProfessions = {}
local DB = {}
local GUI_INIT = false
local font


-- https://www.townlong-yak.com/framexml/8.1.5/ObjectAPI/Item.lua#33
---------------------------CHECKBOXES--------------------------------------
local blacksmithingBOX = "Black Smithing"
local enchantingBOX = "Enchanting"
local engineeringBOX = "Engineering"
local leatherWorkingBOX = "Leather Working"
local tailoringBOX = "Tailoring"
local cookingBOX = "Cooking"
local firstAidBOX = "First Aid"
local alchemyBOX = "Alchemy"

local gFilterSettings = {
    [blacksmithingBOX] = true,
    [enchantingBOX] = true,
    [engineeringBOX] = true,
    [leatherWorkingBOX] = true,
    [tailoringBOX] = true,
    [cookingBOX] = true,
    [firstAidBOX] = true,
    [alchemyBOX] = true
}
_G["GUI"] = GUI
------------FILTERDBS DATABASES---------------------------------------
local tonumber = tonumber
local tostring = tostring
local next = next
local match = string.match
local unpack = unpack
local floor = math.floor
local t_sort = table.sort
--------------------------PINNED ITEMS----------------------------------------

local sort_types = {"itemLevel", "name", "profession"}
local selected_sort_type = "itemLevel"
----------------------------GLOBALS----------------------------------------

local gPinnedItems = {}
local gFilteredDBs = {["First Aid"]={}, ["Alchemy"]={}, ["Engineering"]={},["Tailoring"]={}, ["Enchanting"]={}, ["Black Smithing"]={},["Leather Working"]={}, ["Cooking"] = {}}
local gSearchItems = {["First Aid"]={}, ["Alchemy"]={}, ["Engineering"]={},["Tailoring"]={}, ["Enchanting"]={}, ["Black Smithing"]={},["Leather Working"]={}, ["Cooking"] = {}}

local gItemsDB = {}
---------------------------------------------------------------------------

---TODO: move out all the GUI functions that doesn't handle creating gui elements to a util file

function GUI:init()
    DB = _G.DB
    FilthyProfessions = _G.FilthyProfessions
    GUI:LoadStyling()
    GUI:ReloadDB()
    GUI:Create()
    GUI:RefreshItems()
end

function GUI:LoadStyling()
    font = "Fonts\\FRIZQT__.ttf"
end

function GUI:ReloadDB()
    gItemsDB = DB:GetItemsDB()
    gPinnedItems = DB:GetPinnedItems()
end

function GUI:Refresh()
    local visible = GUI.UI.frame:IsVisible()
    GUI.UI.frame:Hide()
    GUI.UI = nil
    gItemsDB = {}
    GUI_INIT = false
    DB:Reset(function()
        GUI:ReloadDB()
        GUI:Create()
        if visible then
            GUI.UI.frame:Show()
        end
    end)
end

function GUI:SearchItems(str)
    local filteredb = GUI:GetFilterDB()
    if str == nil or str == "" then
        GUI:RefreshItems(filteredb)
        return
    end

    for profession, items in next, filteredb do
        local i = 0
        for itemID, item in next, items do
            if match(item[1]:lower(), str:lower()) then
                gSearchItems[profession][itemID] = item
            else
                gSearchItems[profession][itemID] = nil
            end
        end
    end
    GUI:RefreshItems(gSearchItems)
end

local fillPinnedItems = {}
local function LoadPinnedItems()
    for k,v in next, fillPinnedItems do fillPinnedItems[k] = nil end
    for itemID, profession in next, gPinnedItems do
        fillPinnedItems[itemID] = GUI:FindItemByProfessionAndID(profession, itemID)
    end
    return fillPinnedItems
end

function  GUI:DisplayPinnedItems()
    local items = LoadPinnedItems()
    GUI:RefreshItems(items)
end

function GUI:FindItemByProfessionAndID(profession, itemID)
    local professionDB = GUI:GetFilterDB(profession)
    local item = professionDB[itemID] or {}
    return item
end

-- function GUI:RefreshFilteredItems()
--     GUI.UI.parentItemFrame.items = GUI.UI.parentItemFrame.items or {}
--     for k, v in next, GUI.UI.parentItemFrame.items do
--         GUI.UI.parentItemFrame.items[k]:Hide()
--         GUI.UI.parentItemFrame.items[k] = nil
--     end
--     GUI.UI.parentItemFrame.items = CreateItems(GUI:GetFilterDB())
-- end

function GUI:RefreshItems(db)
    if GUI.UI.parentItemFrame.items ~= nil then 
        for k, v in next, GUI.UI.parentItemFrame.items do
            GUI.UI.parentItemFrame.items[k]:Hide()
            GUI.UI.parentItemFrame.items[k] = nil
        end
    end
    if GUI:isTableEmpty(db) then
        local _db = GUI:GetFilterDB()
        GUI.UI.parentItemFrame.items = GUI:CreateItems(_db)
    else
        GUI.UI.parentItemFrame.items = GUI:CreateItems(db)
    end

end

local function On_Search(self)
    GUI:SearchItems(self:GetText())
end

function GUI:CreateSearchBox(parent)
    local editbox = CreateFrame("EditBox", "SearchBox", parent, "InputBoxTemplate")
    editbox:SetSize(160, 22)
    editbox:EnableMouse(true)
    editbox:SetAltArrowKeyMode(false)
    editbox:SetAutoFocus(false)
    editbox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -5,5)
    editbox:SetTextInsets(6, 6, 2, 0)
    editbox:SetScript("OnTextChanged", On_Search)
    editbox:Show()
    return editbox;
end



function GUI:CreateMainFrame(frameName)
    local frame = CreateFrame("Frame", frameName, UIParent)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetWidth(400)
    frame:SetHeight(500)
    frame:SetToplevel(false)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton", "RightButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(false)
    frame:Show()
    return frame
end

local function Item_Onclick(parent, button, down)
    if button == "RightButton" then
        GUI:pinItem(parent, parent.itemID, parent.profession)
    elseif button == "LeftButton" then
        GUI:displayDetailwindow(parent)
    end
end

local d = {}
function GUI:displayDetailwindow(parent)

    if GUI.UI.detail == nil then
        GUI.UI.detail = GUI:CreateRowDetailWindow(parent)
        GUI.UI.detail.frame:Show()
    elseif GUI.UI.detail.itemLink ~= parent.itemLink then
        GUI.UI.detail.frame:Hide()
         GUI.UI.detail = GUI:CreateRowDetailWindow(parent)
         GUI.UI.detail.frame:Show()
    elseif GUI.UI.detail.frame:IsVisible() then
        GUI.UI.detail.frame:Hide()
    else
        GUI.UI.detail.frame:Show()
    end
end

local function  OnItemLeave(self)
    GameTooltip:Hide()
end

local function  OnItemEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    if self.profession == "Enchanting" then
        GameTooltip:SetHyperlink("spell:" .. self.itemID)
    else
        GameTooltip:SetHyperlink(self.itemLink)
    end
    GameTooltip:Show()
end



function GUI:CreateReagentItemRow(reagent,ableToCraftCount,index,parent)
    local reagentRowFrame = {}
    local itemLink, itemIcon, reagentID, count, itemCount = unpack(reagent)
    reagentRowFrame.frame = nil
    reagentRowFrame.frame = CreateFrame("Button", "REAGENT_"..index, parent.frame)

    reagentRowFrame.frame:SetWidth(parent.frame:GetWidth() - 4)
    reagentRowFrame.frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    reagentRowFrame.frame:SetHeight(10)

    reagentRowFrame.icon = reagentRowFrame.frame:CreateTexture("ItemInfoRow" .. itemLink .. "_icon")
    reagentRowFrame.icon:SetPoint("LEFT", reagentRowFrame.frame, "LEFT", 0, 0)
    reagentRowFrame.icon:SetHeight(20)
    reagentRowFrame.icon:SetWidth(20)
    reagentRowFrame.icon:SetTexture(itemIcon)

    reagentRowFrame.text = reagentRowFrame.frame:CreateFontString(font, "OVERLAY", "GAMETOOLTIPTEXT")
    reagentRowFrame.text:SetFont(font, 12, "OUTLINE");
    reagentRowFrame.text:SetPoint("LEFT", reagentRowFrame.icon, "RIGHT", 2, 0)
    reagentRowFrame.text:SetText(itemLink)

    local itemCountString

    if tonumber(count) <= tonumber(itemCount) then
        itemCountString = "|cFF00FF00" .. itemCount .. "|r"
    else
        itemCountString = "|cFFFF0000" .. itemCount .. "|r"
    end

    reagentRowFrame.countText = reagentRowFrame.frame:CreateFontString(font, "OVERLAY", "GAMETOOLTIPTEXT")
    reagentRowFrame.countText:SetFont(font, 12, "OUTLINE");
    reagentRowFrame.countText:SetPoint("RIGHT", reagentRowFrame.frame , "RIGHT", -20, 0)
    reagentRowFrame.countText:SetText("["..count.."/"..itemCountString.."]")

    reagentRowFrame.frame.itemLink = itemLink
    reagentRowFrame.frame:SetScript("OnEnter", OnItemEnter)
    reagentRowFrame.frame:SetScript("OnLeave", OnItemLeave)

    if itemCount/count < ableToCraftCount then
        ableToCraftCount = itemCount/count
    end
    return ableToCraftCount, reagentRowFrame
end



local reagentsFrame = {}
function GUI:CreateReagentFrame(parent,reagents)
    reagentsFrame.frame = CreateFrame("Frame", "REAGENT_FRAME", parent.frame)
    reagentsFrame.frame:SetWidth(parent.frame:GetWidth())
    reagentsFrame.frame:SetHeight(parent.frame:GetHeight()/2 - parent.info:GetHeight())
    reagentsFrame.frame:SetPoint("TOP", parent.info, "BOTTOM", 0, 0)
    reagentsFrame.reagentsTitle = reagentsFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    reagentsFrame.reagentsTitle:SetPoint("TOPLEFT", reagentsFrame.frame, "TOPLEFT", 10, -4);
    reagentsFrame.reagentsTitle:SetText("|cFFE658EDReagents|r");
    reagentsFrame.reagentsTitle:SetFont(font, 15, "OUTLINE");
    
    local ableToCraftCount = 999
    for x = 1, 20 do reagentsFrame[x] = nil end

    for k, v in next, reagents do
        print("k",k)
        ableToCraftCount, reagentsFrame[k] = GUI:CreateReagentItemRow(v,ableToCraftCount,k,reagentsFrame)
        reagentsFrame[k].frame:ClearAllPoints();
        if k == 1 then
            reagentsFrame[k].frame:SetPoint("TOP", reagentsFrame.frame, "TOP", 10, -35)
        else
            reagentsFrame[k].frame:SetPoint("TOP", reagentsFrame[k-1].frame, "BOTTOM", 0, -5)
        end
    end

    reagentsFrame.reagentsSummary = reagentsFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    reagentsFrame.reagentsSummary:SetPoint("TOPLEFT", reagentsFrame.frame, "BOTTOMLEFT", 10, -4);
    reagentsFrame.reagentsSummary:SetText("Resources for: |cFFFFC0CB"..floor(ableToCraftCount).."|r");
    reagentsFrame.reagentsSummary:SetFont(font, 12);
    return reagentsFrame
end
local _players = {}
local players = {}
function GUI:CreatePlayersFrame(parent,reagents,playersList)
    players.frame = CreateFrame("Frame", "PLAYER_FRAME", parent.frame)
    players.frame:SetWidth( reagents.frame:GetWidth())
    players.frame:SetHeight(reagents.frame:GetHeight()+30)
    players.frame:SetPoint("BOTTOM",  parent.frame, "BOTTOM", 0, 0)

    players.playersTitles = players.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    players.playersTitles:SetPoint("TOPLEFT", players.frame, "TOPLEFT", 9, 0);
    players.playersTitles:SetText("|cFF37FDFCPlayers|r");
    players.playersTitles:SetFont(font, 15, "OUTLINE");


    for x = 1, 20 do players[x] = nil end
    local first = true
    local i = 0
    for k, v in next, playersList do
        i = i+1
        _players.frame = CreateFrame("Button", "player_" .. i, players.frame)
        _players.frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        _players.frame:SetWidth(players.frame:GetWidth())
        _players.frame:SetHeight(12)
        _players.frameText = _players.frame:CreateFontString(_players.frame, "OVERLAY", "GAMETOOLTIPTEXT")
        _players.frameText:SetText(k)
        _players.frameText:SetFont(font, 12, "OUTLINE")
        if first then 
            _players.frame:SetPoint("TOPLEFT",players.frame,"BOTTOMLEFT",0, -10)
            first = false
        else
            _players.frameText:SetPoint("TOPLEFT",players[i-1].frame,"BOTTOMLEFT",0, -10)
        end
        players[i] = _players
    end


    return players

end


local detail = {}
function GUI:CreateRowDetailWindow(parent)

    local itemLink = parent.itemLink
    local itemID = parent.itemID
    local profession = parent.profession
    local reagents = parent.reagents
    local players = parent.players

    ---detail window

    detail.frame = CreateFrame("Frame", "ItemDetailFrame" .. itemLink, GUI.UI.frame, "BasicFrameTemplateWithInset")
    detail.frame:SetWidth(260)
    detail.frame:SetHeight(GUI.UI.parentItemFrame:GetHeight())
    detail.frame:SetPoint("LEFT", GUI.UI.parentItemFrame, "RIGHT", 0, 0)
    detail.frame:Hide()
    detail.frame:SetToplevel(true)
    detail.frame:EnableMouse(true)
    detail.frame:SetClampedToScreen(false)

    detail.itemLink = itemLink
    
    detail.title = detail.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.title:SetPoint("TOP", detail.frame, "TOP", 0, -5);
    detail.title:SetText("Recipe Detail");
    detail.title:SetFont(font, 12, "OUTLINE");

    -- item info
   
    detail.info = CreateFrame("Frame", "ItemInfoRow" .. itemLink, detail.frame)
    detail.info:SetWidth(detail.frame:GetWidth() - 10)
    detail.info:SetHeight(detail.frame:GetHeight() / 5 - 10)
    detail.info:SetPoint("TOP", detail.frame, "TOP", 0, -25)
    -- icon
  
    detail.infoIcon = detail.info:CreateTexture("ItemInfoRow" .. itemLink .. "_icon")
    detail.infoIcon:SetPoint("LEFT", detail.info, "LEFT", 10, -10)
    detail.infoIcon:SetHeight(40)
    detail.infoIcon:SetWidth(40)
    detail.infoIcon:SetTexture(parent.itemTexture)

    detail.ItemNameText = detail.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.ItemNameText:SetPoint("BOTTOMLEFT", detail.infoIcon, "TOPLEFT", 0, 10);
    detail.ItemNameText:SetText(itemLink);
    detail.ItemNameText:SetFont(font, 15, "OUTLINE");

    detail.professionText = detail.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.professionText:SetPoint("LEFT", detail.infoIcon, "RIGHT", 20, 0);
    detail.professionText:SetText(profession);
    detail.professionText:SetFont(font, 14, "OUTLINE");

    detail.reagents = GUI:CreateReagentFrame(detail,reagents)
    detail.players = GUI:CreatePlayersFrame(detail,detail.reagents,players)

    return detail
end


local rowFrame = {}
function GUI:CreateItemButtonFrame(frameName, profession, parent, item)
    -- GUI:tprint(item)

    local itemLink = item[1]
    local itemTexture = item[3]
    local itemID = item[4]
    local itemLevel = item[2]
    local players = item[6]
    local reagents = item[5]

    rowFrame = CreateFrame("Button", frameName, parent)

    rowFrame:SetWidth((parent:GetWidth() - 4))
    rowFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    rowFrame:SetHeight((parent:GetHeight() - 4) / 22)
    rowFrame:SetPoint("TOP", parent, "TOP", 15, -2)
    rowFrame.profession = profession
    rowFrame.itemLink = itemLink
    rowFrame.itemID = itemID
    rowFrame.itemTexture = itemTexture
    rowFrame.reagents = reagents
    rowFrame.players = players
    rowFrame.itemLevel = itemLevel
    if profession ~= "Enchanting" then
        rowFrame.itemName = match(itemLink, "%[(.+)%]")
    else
        rowFrame.itemName = itemLink
    end

    -- row icon

    rowFrame.icon = rowFrame:CreateTexture("rowIcon" .. tostring(itemTexture) .. "_icon")
    rowFrame.icon:SetPoint("LEFT", rowFrame, "LEFT", 10, 0)
    rowFrame.icon:SetHeight(20)
    rowFrame.icon:SetWidth(20)
    rowFrame.icon:SetTexture(itemTexture)

    rowFrame.pinn = nil
    if GUI:isPinned(itemID) then
        rowFrame.pinn = rowFrame:CreateTexture("pinnItem" .. itemID)
        rowFrame.pinn:SetPoint("RIGHT", rowFrame.icon, "LEFT", -5, 0)
        rowFrame.pinn:SetHeight(20)
        rowFrame.pinn:SetWidth(20)
        rowFrame.pinn:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        rowFrame.pinn:Show()
    end

    rowFrame.text = rowFrame:CreateFontString(rowFrame, "OVERLAY", "GAMETOOLTIPTEXT")
    rowFrame.text:SetPoint("LEFT", rowFrame.icon, "RIGHT",10, 0)
    rowFrame.text:SetText(itemLink)

    rowFrame.lvltext = rowFrame:CreateFontString(rowFrame, "OVERLAY", "GAMETOOLTIPTEXT")
    rowFrame.lvltext:SetPoint("RIGHT", -20, 0)
    if profession == "enchanting" then 
        rowFrame.lvltext:SetText(" ¯\\\_('_')_/¯")
    else
        rowFrame.lvltext:SetText(itemLevel)
    end
    

    rowFrame:RegisterForClicks("AnyDown")
    rowFrame:SetScript("OnClick", Item_Onclick)
    rowFrame:SetScript("OnEnter", OnItemEnter)
    rowFrame:SetScript("OnLeave", OnItemLeave)

    rowFrame:Show()

    return rowFrame
end

local function SortByItemLevel(a, b)
    -- print(a)
    return tonumber(a.itemLevel) > tonumber(b.itemLevel)
end


 function GUI:CreateItems(db)
    local _db = db or {}
    local firstItem = true
    local itemRowFrames = {}
    for k,v in next, itemRowFrames do itemRowFrames[k] = nil end
    GUI:tprint(_db)
    local i = 0
        for profession, items in next, _db do
            for itemID, itemContent in next, items do
                i = i + 1
                itemRowFrames[i] = GUI:CreateItemButtonFrame(
                "ItemRow_"..itemID, 
                profession, 
                GUI.UI.content,
                itemContent 
                )
            end
        end

    -- itemRowFrames = sortItems(itemRowFrames, selected_sort_type)
    -- print("tableSize ",getTableSize(itemRowFrames))
    t_sort(itemRowFrames, SortByItemLevel)
    
    for k, v in next, itemRowFrames do
        if firstItem == false then   
            itemRowFrames[k]:SetPoint("TOP", itemRowFrames[k - 1], "BOTTOM")
        else
            itemRowFrames[k]:SetPoint("TOP", GUI.UI.content, "TOP", 15, -2)
        end
        firstItem = false

    end
    return itemRowFrames
end


local function SortByProfession(a,b)
    return a.profession > b.profession
end

local function SortByName(a,b)
    return a.itemName > b.itemName
end

local function getTableSize(table)
    local count = 0
    local tbl = table
    for k, v in next, tbl do
        count = count + 1
    end
    return count
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


function  GUI:CreateScrollFrame(frameName, parent, child)
    -- https://youtu.be/1CQHKo1Pt2Q?list=PL3wt7cLYn4N-3D3PTTUZBM2t1exFmoA2G&t=2014
    local  scrollFrame = CreateFrame("ScrollFrame", frameName, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetWidth(child:GetWidth())
    scrollFrame:SetHeight(child:GetHeight() - 80)
    scrollFrame:SetPoint("BOTTOM", parent, "BOTTOM", -12, 5)
    scrollFrame:SetScrollChild(child)
    return scrollFrame
end

function GUI:CreateContentFrame(frameName, parent)
    local contentFrame = CreateFrame("Frame", frameName, parent)
    contentFrame:SetWidth(parent:GetWidth() - 40)
    contentFrame:SetHeight(parent:GetHeight() - 100)
    contentFrame:SetPoint("BOTTOM", parent, "BOTTOM", -12, 5)
    return contentFrame
end

function GUI:CreateMenuFrame(frameName, parent)
    local  menuFrame = CreateFrame("Frame", frameName, parent, "InsetFrameTemplate2")
    menuFrame:SetWidth(parent:GetWidth() / 5 - 20)
    menuFrame:SetHeight(parent:GetHeight() - 30)
    menuFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 6, 6)
    return menuFrame
end

local function CheckBox_OnClick(self)
    local name = self:GetName()
    gFilterSettings[name] = self:GetChecked()
    GUI:RefreshItems()
end


function GUI:CreateCheckBox(frameName, parent, checkBoxText, checked)
    local menu = CreateFrame("Checkbutton", frameName, parent, "UICheckButtonTemplate")
    menu:SetWidth(25)
    menu:SetHeight(25)
    menu.text:SetText(checkBoxText)
    menu.text:SetFont(font, 12, "OUTLINE, MONOCHROME")
    menu:SetChecked(checked)
    menu:Show()
    menu:SetScript("OnClick", CheckBox_OnClick)
    return menu
end


function GUI:TOGGLE()
    local g = GUI.UI.frame:IsVisible()
    if g then
        GUI.UI.frame:Hide()
    else
        GUI.UI.frame:Show()
    end
end

local function ItemFrame_close(self)
    GUI.UI.frame:Hide()
end

function GUI:CreateParentItemFrame()
    local parentItemFrame = CreateFrame("Frame", "MAIN_ITEM_FRAME", GUI.UI.frame, "BasicFrameTemplateWithInset")
    parentItemFrame:SetWidth(370)
    parentItemFrame:SetHeight(GUI.UI.frame:GetHeight())
    parentItemFrame:SetPoint("LEFT", GUI.UI.frame, "LEFT")
    parentItemFrame:SetToplevel(true)
    parentItemFrame.CloseButton:SetScript("OnClick", ItemFrame_close)
    return parentItemFrame
end

function GUI:Create()

    if GUI_INIT then
        return
    end
    GUI_INIT = true
    GUI.UI = {}
    local frameName = "MAIN_FRAME"
  
    GUI.UI.frame = GUI:CreateMainFrame(frameName)

    GUI.UI.parentItemFrame = GUI:CreateParentItemFrame()

    GUI.UI.title = GUI.UI.parentItemFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    GUI.UI.title:SetPoint("TOP", GUI.UI.parentItemFrame, "TOP", 0, -5);
    GUI.UI.title:SetText("|cFFF24444F|r|cFF58ED76|cFFF2F244i|r|cFF44F2E9l|r|cFF445bf2t|r|cffc144f2h|r|cfff244c6y|r Professions");
    GUI.UI.title:SetFont(font, 15, "OUTLINE");

    GUI.UI.itemFilterMenu = CreateFrame("Frame", "ITEM_FILTER_MENU", GUI.UI.parentItemFrame, "InsetFrameTemplate2")
    GUI.UI.itemFilterMenu:SetHeight(GUI.UI.parentItemFrame:GetHeight() / 6)
    GUI.UI.itemFilterMenu:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 10)
    GUI.UI.itemFilterMenu:SetPoint("TOP", GUI.UI.parentItemFrame, "TOP", 0, -20)

    GUI.UI.itemCol = CreateFrame("Frame", "ITEM_COLS", GUI.UI.parentItemFrame)
    GUI.UI.itemCol:SetHeight(GUI.UI.itemFilterMenu:GetHeight()/4-10)
    GUI.UI.itemCol:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 10)
    GUI.UI.itemCol:SetPoint("TOP", GUI.UI.itemFilterMenu, "BOTTOM", 0, 0)

    GUI.UI.itemCol.PinnedText = GUI.UI.itemCol:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    GUI.UI.itemCol.PinnedText :SetPoint("LEFT", GUI.UI.itemCol, "BOTTOMLEFT", 4, 6);
    GUI.UI.itemCol.PinnedText :SetText("pin");
    GUI.UI.itemCol.PinnedText :SetFont(font, 12, "OUTLINE");

    GUI.UI.itemCol.NameText = GUI.UI.itemCol:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    GUI.UI.itemCol.NameText :SetPoint("LEFT", GUI.UI.itemCol.PinnedText, "RIGHT", 40, 0);
    GUI.UI.itemCol.NameText :SetText("name");
    GUI.UI.itemCol.NameText :SetFont(font, 12, "OUTLINE");

    GUI.UI.itemCol.ItemLevelText = GUI.UI.itemCol:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    GUI.UI.itemCol.ItemLevelText :SetPoint("RIGHT", GUI.UI.itemCol, "BOTTOMRIGHT", -32, 6);
    GUI.UI.itemCol.ItemLevelText :SetText("lvl");
    GUI.UI.itemCol.ItemLevelText :SetFont(font, 12, "OUTLINE");

    local contenFrameName = "CONTENT_FRAME"
    GUI.UI.content = GUI:CreateContentFrame(contenFrameName, GUI.UI.parentItemFrame)
    GUI.UI.content:SetHeight(GUI.UI.parentItemFrame:GetHeight() - (GUI.UI.itemFilterMenu:GetHeight() + GUI.UI.itemCol:GetHeight()))
    GUI.UI.content:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 40)
    GUI.UI.content:SetPoint("TOP", GUI.UI.itemCol, "BOTTOM", -15, -5)

    GUI.UI.SearchFrame = GUI:CreateSearchBox(GUI.UI.itemFilterMenu)

    local scrollFrameName = "ITEM_SCROLL_FRAME"
    GUI.UI.scrollFrame = GUI:CreateScrollFrame(scrollFrameName, GUI.UI.parentItemFrame, GUI.UI.content)
    GUI.UI.scrollFrame:SetHeight(GUI.UI.parentItemFrame:GetHeight() - (GUI.UI.itemFilterMenu:GetHeight() + GUI.UI.itemCol:GetHeight()+100))
    GUI.UI.scrollFrame:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 40)
    GUI.UI.scrollFrame:SetPoint("TOP", GUI.UI.itemCol, "BOTTOM", -15, -5)

    ----------------PROFESSION CHECKBOXES--------------------
    GUI.UI.alchemyBox = GUI:CreateCheckBox(alchemyBOX, GUI.UI.itemFilterMenu, "Alchemy", gFilterSettings[alchemyBOX])

    GUI.UI.blacksmithingBox = GUI:CreateCheckBox(blacksmithingBOX, GUI.UI.itemFilterMenu, "Black Smithing",
    gFilterSettings[blacksmithingBOX])

    GUI.UI.enchantingBox = GUI:CreateCheckBox(enchantingBOX, GUI.UI.itemFilterMenu, "Enchanting",
    gFilterSettings[enchantingBOX])

    GUI.UI.engineeringBox = GUI:CreateCheckBox(engineeringBOX, GUI.UI.itemFilterMenu, "Engineering",
    gFilterSettings[engineeringBOX])

    GUI.UI.leatherWorking = GUI:CreateCheckBox(leatherWorkingBOX, GUI.UI.itemFilterMenu, "Leather Working",
    gFilterSettings[leatherWorkingBOX])

    GUI.UI.tailoring =
        GUI:CreateCheckBox(tailoringBOX, GUI.UI.itemFilterMenu, "Tailoring", gFilterSettings[tailoringBOX])

    GUI.UI.cookingBox = GUI:CreateCheckBox(cookingBOX, GUI.UI.itemFilterMenu, "Cooking", gFilterSettings[cookingBOX])

    GUI.UI.firstAidBox =
        GUI:CreateCheckBox(firstAidBOX, GUI.UI.itemFilterMenu, "First Aid", gFilterSettings[firstAidBOX])

    GUI.UI.enchantingBox:SetPoint("LEFT", GUI.UI.blacksmithingBox.text, "RIGHT", 10, 0)
    GUI.UI.alchemyBox:SetPoint("LEFT", GUI.UI.itemFilterMenu, "TOPLEFT", 5, -18)
    GUI.UI.leatherWorking:SetPoint("LEFT", GUI.UI.engineeringBox.text, "RIGHT", 0, 0)
    GUI.UI.engineeringBox:SetPoint("TOP", GUI.UI.alchemyBox, "BOTTOM", 0, 0)
    GUI.UI.cookingBox:SetPoint("TOP", GUI.UI.engineeringBox, "BOTTOM", 0, 0)
    GUI.UI.firstAidBox:SetPoint("TOP", GUI.UI.leatherWorking, "BOTTOM", 0, 0)
    GUI.UI.blacksmithingBox:SetPoint("BOTTOM", GUI.UI.leatherWorking, "TOP", 0, 0)
    GUI.UI.tailoring:SetPoint("TOP", GUI.UI.enchantingBox, "BOTTOM", 0, 0)

    GUI.UI.parentItemFrame.items = nil
    GUI.UI.parentItemFrame.items = GUI:CreateItems(GUI:GetFilterDB())
    GUI.UI.frame:Hide()
end


function GUI:GetFilterDB(profession)
    print("itemsDB")
    GUI:tprint(gItemsDB[profession])
    if profession ~= nil and profession ~= "" then
        return gItemsDB[profession] or {}
    end
    for k, v in next, gFilterSettings do
        if  v then
            gFilteredDBs[k] = gItemsDB[k] or {}
        else
            gFilteredDBs[k] = nil
        end
    end
    return gFilteredDBs
end


function GUI:tprint(tbl, indent)
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
            GUI:tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

function GUI:isPinned(itemID)
    return gPinnedItems[itemID] ~= nil
end

function GUI:pinItem(self, itemID, profession)
    local itemID = itemID
    local profession = profession
    local pinnedItems = gPinnedItems
    if not GUI:isPinned(itemID) then
        gPinnedItems[itemID] = profession
    else
        gPinnedItems[itemID] = nil
    end
    GUI:RefreshItems()
end

function GUI:isTableEmpty(table)
    if table == nil  or next(table) == nil then
        return true
    end
    return false

end

-------------------------------------------------------------
