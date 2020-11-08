local GUI = {}
local GUI_INIT = false
local FilthyProfessions = {}
local DB = {}
local font
local gItemsDB = {}
local filterSettings = {}

-- https://www.townlong-yak.com/framexml/8.1.5/ObjectAPI/Item.lua#33
---------------------------CHECKBOXES--------------------------------------
local blacksmithingBOX = "BLACKSMITHING_BOX"
local enchantingBOX = "ENCHANTING_BOX"
local engineeringBOX = "ENGINEERING_BOX"
local leatherWorkingBOX = "LEATHERWORKING_BOX"
local tailoringBOX = "TAILORING_BOX"
local cookingBOX = "COOKING_BOX"
local firstAidBOX = "FIRSTAID_BOX"
local alchemyBOX = "ALCHEMY_BOX"

------------FILTERDBS DATABASES-----------------------------------------

-- local AlchemyDB = {}
-- local EnchantingDB = {}
-- local BlackSmithingDB = {}
-- local EngineeringDB = {}
-- local TailoringDB = {}
-- local LeatherWorkingDB = {}
-- local FirstAidDB = {}
-- local CookingDB = {}
local PinnedItemsDB = {}
local tonumber = tonumber
local tostring = tostring
local next = next
local match = string.match
--------------------------PINNED ITEMS----------------------------------------
local gPinnedItems = {}
local sort_types = {"itemLevel", "name", "profession"}
local selected_sort_type = "itemLevel"
----------------------------GLOBALS----------------------------------------
_G["GUI"] = GUI

---------------------------------------------------------------------------

---TODO: move out all the GUI functions that doesn't handle creating gui elements to a util file

function GUI:init()
    filterSettings = {
        [blacksmithingBOX] = true,
        [enchantingBOX] = true,
        [engineeringBOX] = true,
        [leatherWorkingBOX] = true,
        [tailoringBOX] = true,
        [cookingBOX] = true,
        [firstAidBOX] = true,
        [alchemyBOX] = true
    }
    FilthyProfessions = _G.FilthyProfessions
    LoadStyling()
    ReloadDB()
    Create()
    GUI:RefreshItems()
end

function LoadStyling()
    font = "Fonts\\FRIZQT__.ttf"
end

function ReloadDB()
    DB = _G.DB
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
        ReloadDB()
        Create()
        if visible then
            GUI.UI.frame:Show()
        end
    end)
end

function SearchItems(str)
    if str == nil then
        return
    end

    local filteredb = GUI:GetFilterDB()
    if str == nil or str == "" then
        GUI:RefreshItems(filteredb)
    end
    local searchFilteredDB = {}

    for k, v in next, filteredb do
        searchFilteredDB[k] = {}
        local i = 0
        for _k, _v in next, v do
            if match(_v[1][1]:lower(), str:lower()) then
                local i = i + 1
                searchFilteredDB[k][_k] = _v
            end
        end
    end
    GUI:RefreshItems(searchFilteredDB)
end

function LoadPinnedItems()
    local pinnedItems = gPinnedItems
    local items = {}
    local next = next
    for itemID, profession in next, pinnedItems do
        items[itemID] = GUI:FindItemByProfessionAndID(profession, itemID)
    end
    return items
end

function DisplayPinnedItems()
    local items = LoadPinnedItems()
    GUI:RefreshItems(items)
end

function GUI:FindItemByProfessionAndID(profession, itemID)
    local professionDB = GUI:GetFilterDB(profession)
    local item = professionDB[itemID] or {}
    return item
end

function GUI:RefreshFilteredItems()
    GUI.UI.parentItemFrame.items = GUI.UI.parentItemFrame.items or {}
    for k, v in next, GUI.UI.parentItemFrame.items do
        GUI.UI.parentItemFrame.items[k]:Hide()
        GUI.UI.parentItemFrame.items[k] = nil
    end
    GUI.UI.parentItemFrame.items = CreateItems(GUI:GetFilterDB())
end

function GUI:RefreshItems(db)
    local _db = {}
    if db == nil then
        local _db = GUI:GetFilterDB()
    else
        _db = db
    end

    DB:Reset(function()
        ReloadDB()
        for k, v in next, GUI.UI.parentItemFrame.items do
            GUI.UI.parentItemFrame.items[k]:Hide()
            GUI.UI.parentItemFrame.items[k] = nil
        end
        GUI.UI.parentItemFrame.items = CreateItems(_db)
    end)
end

function CreateSearchBox(parent)
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

function On_Search(self)
    SearchItems(self:GetText())
end

function CreateMainFrame(frameName)
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

function Item_Onclick(self, button, down)
    if button == "RightButton" then
        pinItem(self, self.itemID, self.profession)
    elseif button == "LeftButton" then
        displayDetailwindow(self)
    end
end

function displayDetailwindow(self)

    if GUI.UI.detail == nil then
        GUI.UI.detail = GUI:CreateRowDetailWindow(self)
        GUI.UI.detail:Show()
    elseif GUI.UI.detail.itemLink ~= self.itemLink then
        GUI.UI.detail:Hide()
        GUI.UI.detail = nil
        GUI.UI.detail = GUI:CreateRowDetailWindow(self)
        GUI.UI.detail:Show()
    else
        GUI.UI.detail:Hide()
        GUI.UI.detail = nil
    end
end
function GUI:CreateRowDetailWindow(parent)

    local itemLink = parent.itemLink
    local itemID = parent.itemID
    local profession = parent.profession
    local reagents = parent.reagents
    local players = parent.players

    ---detail window
    local detail = CreateFrame("Frame", "ItemDetailFrame" .. itemLink, GUI.UI.frame, "BasicFrameTemplateWithInset")
    detail:SetWidth(260)
    detail:SetHeight(GUI.UI.parentItemFrame:GetHeight())
    detail:SetPoint("LEFT", GUI.UI.parentItemFrame, "RIGHT", 0, 0)
    detail:Hide()
    -- detail:RegisterForDrag("LeftButton", "RightButton")
    -- detail:SetScript("OnDragStart", GUI.UI.frame.StartMoving)
    -- detail:SetScript("OnDragStop", GUI.UI.frame.StopMovingOrSizing)
    detail:SetToplevel(true)
    detail:EnableMouse(true)
    -- detail:SetMovable(true)
    detail:SetClampedToScreen(false)
    detail.itemLink = itemLink

    detail.title = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.title:SetPoint("TOP", detail, "TOP", 0, -5);
    detail.title:SetText("Recipe Detail");
    detail.title:SetFont(font, 12, "OUTLINE");

    -- item info
    detail.info = CreateFrame("Frame", "ItemInfoRow" .. itemLink, detail)
    detail.info:SetWidth(detail:GetWidth() - 10)
    detail.info:SetHeight(detail:GetHeight() / 5 - 10)
    detail.info:SetPoint("TOP", detail, "TOP", 0, -25)
    -- icon
    detail.info.icon = detail.info:CreateTexture("ItemInfoRow" .. itemLink .. "_icon")
    detail.info.icon:SetPoint("LEFT", detail.info, "LEFT", 10, -10)
    detail.info.icon:SetHeight(40)
    detail.info.icon:SetWidth(40)
    detail.info.icon:SetTexture(parent.itemTexture)


    detail.ItemNameText = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.ItemNameText:SetPoint("BOTTOMLEFT", detail.info.icon, "TOPLEFT", 0, 10);
    detail.ItemNameText:SetText(itemLink);
    detail.ItemNameText:SetFont(font, 15, "OUTLINE");

    detail.professionText = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.professionText:SetPoint("LEFT", detail.info.icon, "RIGHT", 20, 0);
    detail.professionText:SetText(profession);
    detail.professionText:SetFont(font, 14, "OUTLINE");


    -- reagents window
    detail.reagents = CreateFrame("Frame", "regeantRow" .. itemLink, detail)
    detail.reagents:SetWidth(detail:GetWidth())
    detail.reagents:SetHeight(detail:GetHeight()/2 - detail.info:GetHeight())
    detail.reagents:SetPoint("TOP", detail.info, "BOTTOM", 0, 0)

    detail.reagents.title = detail.reagents:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.reagents.title:SetPoint("TOPLEFT", detail.reagents, "TOPLEFT", 10, -4);
    detail.reagents.title:SetText("|cFFE658EDReagents|r");
    detail.reagents.title:SetFont(font, 15, "OUTLINE");

    local first = true
    local reagentTable = {}
    local ableToCraftCount = 999
    local floor = math.floor
    for k, v in next, reagents do
        local itemLink, itemIcon, reagentID, count, itemCount = unpack(v)
        local reagent = CreateFrame("Button", "player" .. itemLink, detail.reagents)

        reagent:SetWidth((detail.reagents:GetWidth() - 4))
        reagent:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        reagent:SetHeight(10)

        if first then
            reagent:SetPoint("TOP", detail.reagents, "TOP", 10, -35)
            first = false
        else
            reagent:SetPoint("TOP", reagentTable[#reagentTable], "BOTTOM", 0, -5)
        end

        reagent.icon = reagent:CreateTexture("ItemInfoRow" .. itemLink .. "_icon")
        reagent.icon:SetPoint("LEFT", reagent, "LEFT", 0, 0)
        reagent.icon:SetHeight(20)
        reagent.icon:SetWidth(20)
        reagent.icon:SetTexture(itemIcon)

        reagent.text = reagent:CreateFontString(font, "OVERLAY", "GAMETOOLTIPTEXT")
        reagent.text:SetFont(font, 12, "OUTLINE");
        reagent.text:SetPoint("LEFT", reagent.icon, "RIGHT", 2, 0)
        reagent.text:SetText(itemLink)

        local itemCountString
        if itemCount/count < ableToCraftCount then
            ableToCraftCount = itemCount/count
        end

        if tonumber(count) <= tonumber(itemCount) then
            itemCountString = "|cFF00FF00" .. itemCount .. "|r"
        else
            itemCountString = "|cFFFF0000" .. itemCount .. "|r"
        end
        reagent.countText = reagent:CreateFontString(font, "OVERLAY", "GAMETOOLTIPTEXT")
        reagent.countText:SetFont(font, 12, "OUTLINE");
        reagent.countText:SetPoint("RIGHT", reagent , "RIGHT", -20, 0)
        reagent.countText:SetText("["..count.."/"..itemCountString.."]")
      
        reagent.itemLink = itemLink
        reagent:SetScript("OnEnter", OnItemEnter)
        reagent:SetScript("OnLeave", OnItemLeave)

        reagentTable[k] = reagent

    end
    detail.reagents.summary = detail.reagents:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.reagents.summary:SetPoint("TOPLEFT", detail.reagents, "BOTTOMLEFT", 10, -4);
    detail.reagents.summary:SetText("Resources for: |cFFFFC0CB"..floor(ableToCraftCount).."|r");
    detail.reagents.summary:SetFont(font, 12);


    detail.reagentsList = reagentTable;
    -- |TInterface\\Icons\\INV_Misc_Coin_01:16|t Coins
    -- players window
    detail.players = CreateFrame("Frame", "playersRow" .. itemLink, detail)
    detail.players:SetWidth( detail.reagents:GetWidth())
    detail.players:SetHeight( detail.reagents:GetHeight()+30)
    detail.players:SetPoint("BOTTOM", detail, "BOTTOM", 0, 0)

    detail.players.title = detail.players:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    detail.players.title:SetPoint("TOPLEFT", detail.players, "TOPLEFT", 9, 0);
    detail.players.title:SetText("|cFF37FDFCPlayers|r");
    detail.players.title:SetFont(font, 15, "OUTLINE");

    -- detail.player.scrollFrame = GUI:CreateScrollFrame("d", detail.players, detail.players)
    -- detail.player.scrollFrame:SetHeight(detail.players:GetHeight()-100)
    -- detail.player.scrollFrame:SetWidth(detail.players:GetWidth())
    -- detail.player.scrollFrame:SetPoint("TOP", detail.players.title, "BOTTOM", -15, -5)


    local playersList = {}
    local first = true
    for k, v in next, players do
        local player = CreateFrame("Button", "player" .. k, detail.players)
        player:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        player:SetWidth(detail.players:GetWidth())
        player:SetHeight(12)
        player.text = player:CreateFontString(parent, "OVERLAY", "GAMETOOLTIPTEXT")
        
        player.text:SetText(k)
        player.text:SetFont(font, 12, "OUTLINE")
        if first then 
            player:SetPoint("TOPLEFT",detail.players.title,"BOTTOMLEFT",0, -10)
            player.text:SetPoint("TOPLEFT",detail.players.title,"BOTTOMLEFT",0, -10)
            first = false
        end
        playersList[k] = player
      

    end
    detail.players = playersList;

    return detail
end


function CreateItemButtonFrame(frameName, profession, parent, itemData)

    local item, regeants, players = unpack(itemData)
    local itemLink = item[1]
    local itemTexture = item[3]
    local itemID = item[4]
    local itemLevel = item[2]
    local players = itemData[3]
    local reagents = itemData[2]

    local rowFrame = CreateFrame("Button", frameName, parent)

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

    -- rowFrame.pinn = GUI:CreateButtonPinn(itemID,profession,rowFrame,rowFrame.icon)

    if isPinned(itemID) then
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

function CreateItems(db)
    local _db = db or {}
    local firstItem = true
    local itemRowFrames = {}
    local i = 0
    
        for profession, items in next, _db do
            for k, itemContent in next, items do
                i = i + 1
                itemRowFrames[i] = CreateItemButtonFrame("firstItemRow_" .. profession .. k..i, profession, GUI.UI.content,itemContent)
            end
        end


    itemRowFrames = sortItems(itemRowFrames, selected_sort_type)
    table.sort(itemRowFrames, SortByItemLevel)
    
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

function SortByItemLevel(a, b)
    -- print(a)
    -- print(a[1][2],b[1][2])
    return tonumber(a.itemLevel) > tonumber(b.itemLevel)
end

function SortByProfession(a,b)
    return a.profession > b.profession
end

function SortByName(a,b)
    return a.itemName > b.itemName
end


function getTableSize(table)
    local count = 0

    local tbl = table
    for k, v in next, tbl do
        count = count + 1
    end
    return count
end


local t_sort = table.sort
function sortItems(rowFrames, sort_type)
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

function OnItemLeave(self)
    GameTooltip:Hide()
end

function OnItemEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    if self.profession == "Enchanting" then
        GameTooltip:SetHyperlink("spell:" .. self.itemID)
    else
        GameTooltip:SetHyperlink(self.itemLink)
    end
    GameTooltip:Show()
end

function CreateScrollFrame(frameName, parent, child)
    -- https://youtu.be/1CQHKo1Pt2Q?list=PL3wt7cLYn4N-3D3PTTUZBM2t1exFmoA2G&t=2014
    local scrollFrame = CreateFrame("ScrollFrame", frameName, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetWidth(child:GetWidth())
    scrollFrame:SetHeight(child:GetHeight() - 80)
    scrollFrame:SetPoint("BOTTOM", parent, "BOTTOM", -12, 5)
    scrollFrame:SetScrollChild(child)
    return scrollFrame

end

function CreateContentFrame(frameName, parent)
    local contentFrame = CreateFrame("Frame", frameName, parent)
    contentFrame:SetWidth(parent:GetWidth() - 40)
    contentFrame:SetHeight(parent:GetHeight() - 100)
    contentFrame:SetPoint("BOTTOM", parent, "BOTTOM", -12, 5)
    return contentFrame
end

function GUI:CreateMenuFrame(frameName, parent)
    local menuFrame = CreateFrame("Frame", frameName, parent, "InsetFrameTemplate2")
    menuFrame:SetWidth(parent:GetWidth() / 5 - 20)
    menuFrame:SetHeight(parent:GetHeight() - 30)
    menuFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 6, 6)
    return menuFrame
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

function ItemFrame_close(self)
    GUI.UI.frame:Hide()
end

function GUI:TOGGLE()
    local g = GUI.UI.frame:IsVisible()
    if g then
        GUI.UI.frame:Hide()
    else
        GUI.UI.frame:Show()
    end
end

function CreateParentItemFrame()
    local parentItemFrame = CreateFrame("Frame", "MAIN_ITEM_FRAME", GUI.UI.frame, "BasicFrameTemplateWithInset")
    parentItemFrame:SetWidth(370)
    parentItemFrame:SetHeight(GUI.UI.frame:GetHeight())
    parentItemFrame:SetPoint("LEFT", GUI.UI.frame, "LEFT")
    parentItemFrame:SetToplevel(true)
    parentItemFrame.CloseButton:SetScript("OnClick", ItemFrame_close)
    return parentItemFrame
end

function Create()
    if GUI_INIT then
        return
    end
    GUI_INIT = true
    local frameName = "MAIN_FRAME"
    GUI.UI = {}
    GUI.UI.frame = CreateMainFrame(frameName)

    GUI.UI.parentItemFrame = CreateParentItemFrame()

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
    GUI.UI.content = CreateContentFrame(contenFrameName, GUI.UI.parentItemFrame)
    GUI.UI.content:SetHeight(GUI.UI.parentItemFrame:GetHeight() - (GUI.UI.itemFilterMenu:GetHeight() + GUI.UI.itemCol:GetHeight()))
    GUI.UI.content:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 40)
    GUI.UI.content:SetPoint("TOP", GUI.UI.itemCol, "BOTTOM", -15, -5)

    GUI.UI.SearchFrame = CreateSearchBox(GUI.UI.itemFilterMenu)

    local scrollFrameName = "ITEM_SCROLL_FRAME"
    GUI.UI.scrollFrame = CreateScrollFrame(scrollFrameName, GUI.UI.parentItemFrame, GUI.UI.content)
    GUI.UI.scrollFrame:SetHeight(GUI.UI.parentItemFrame:GetHeight() - (GUI.UI.itemFilterMenu:GetHeight() + GUI.UI.itemCol:GetHeight()+100))
    GUI.UI.scrollFrame:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 40)
    GUI.UI.scrollFrame:SetPoint("TOP", GUI.UI.itemCol, "BOTTOM", -15, -5)

    ----------------PROFESSION CHECKBOXES--------------------
    GUI.UI.alchemyBox = GUI:CreateCheckBox(alchemyBOX, GUI.UI.itemFilterMenu, "Alchemy", filterSettings[alchemyBOX])

    GUI.UI.blacksmithingBox = GUI:CreateCheckBox(blacksmithingBOX, GUI.UI.itemFilterMenu, "Black Smithing",
                                  filterSettings[blacksmithingBOX])

    GUI.UI.enchantingBox = GUI:CreateCheckBox(enchantingBOX, GUI.UI.itemFilterMenu, "Enchanting",
                               filterSettings[enchantingBOX])

    GUI.UI.engineeringBox = GUI:CreateCheckBox(engineeringBOX, GUI.UI.itemFilterMenu, "Engineering",
                                filterSettings[engineeringBOX])

    GUI.UI.leatherWorking = GUI:CreateCheckBox(leatherWorkingBOX, GUI.UI.itemFilterMenu, "Leather Working",
                                filterSettings[leatherWorkingBOX])

    GUI.UI.tailoring =
        GUI:CreateCheckBox(tailoringBOX, GUI.UI.itemFilterMenu, "Tailoring", filterSettings[tailoringBOX])

    GUI.UI.cookingBox = GUI:CreateCheckBox(cookingBOX, GUI.UI.itemFilterMenu, "Cooking", filterSettings[cookingBOX])

    GUI.UI.firstAidBox =
        GUI:CreateCheckBox(firstAidBOX, GUI.UI.itemFilterMenu, "First Aid", filterSettings[firstAidBOX])

    GUI.UI.enchantingBox:SetPoint("LEFT", GUI.UI.blacksmithingBox.text, "RIGHT", 10, 0)
    GUI.UI.alchemyBox:SetPoint("LEFT", GUI.UI.itemFilterMenu, "TOPLEFT", 5, -18)
    GUI.UI.leatherWorking:SetPoint("LEFT", GUI.UI.engineeringBox.text, "RIGHT", 0, 0)
    GUI.UI.engineeringBox:SetPoint("TOP", GUI.UI.alchemyBox, "BOTTOM", 0, 0)
    GUI.UI.cookingBox:SetPoint("TOP", GUI.UI.engineeringBox, "BOTTOM", 0, 0)
    GUI.UI.firstAidBox:SetPoint("TOP", GUI.UI.leatherWorking, "BOTTOM", 0, 0)
    GUI.UI.blacksmithingBox:SetPoint("BOTTOM", GUI.UI.leatherWorking, "TOP", 0, 0)
    GUI.UI.tailoring:SetPoint("TOP", GUI.UI.enchantingBox, "BOTTOM", 0, 0)

    GUI.UI.parentItemFrame.items = {}
    GUI.UI.parentItemFrame.items = CreateItems(GUI:GetFilterDB())
    GUI.UI.frame:Hide()
end

function SetTabs(frame, numTabs, ...)
    frame.numTabs = numTabs

end


function GUI:GetFilterDB(profession)
    ReloadDB()
    local FilteredDBs = {}

    if profession ~= nil and profession ~= "" then
        return gItemsDB[profession] or {}
    end

    for k, v in next, filterSettings do
        if k == alchemyBOX and v then
            FilteredDBs["Alchemy"] = gItemsDB["Alchemy"] or {}
        end

        if k == enchantingBOX and v then
            FilteredDBs["Enchanting"] = gItemsDB["Enchanting"] or {}
        end

        if k == engineeringBOX and v then
            FilteredDBs["Engineering"] = gItemsDB["Engineering"] or {}
        end

        if k == leatherWorkingBOX and v then
            FilteredDBs["Leather Working"] = gItemsDB["LeatherWorking"] or {}
        end

        if k == blacksmithingBOX and v then
            FilteredDBs["Black Smithing"] =  gItemsDB["Black Smithing"]
        end

        if k == tailoringBOX and v then
            FilteredDBs["Tailoring"] = gItemsDB["Tailoring"] or {}
        end

        if k == firstAidBOX and v then
            FilteredDBs["First Aid"] = gItemsDB["First Aid"] or {}
        end

        if k == cookingBOX and v then
            FilteredDBs["Cooking"] = gItemsDB["Cooking"] or {}
        end
    end
    return FilteredDBs
end

function CheckBox_OnClick(self)
    filterSettings[self:GetName()] = self:GetChecked()
    GUI:RefreshFilteredItems()
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

function isPinned(itemID)
    local pinnedItems = gPinnedItems
    return pinnedItems[itemID] ~= nil
end

function pinItem(self, itemID, profession)
    local itemID = itemID
    local profession = profession
    local pinnedItems = gPinnedItems
    if not isPinned(itemID) then
        pinnedItems[itemID] = profession
    else
        pinnedItems[itemID] = nil
    end
    GUI:RefreshFilteredItems()
    gPinnedItems = pinnedItems
    DB:StorePinnedItems(pinnedItems)
end

-------------------------------------------------------------
