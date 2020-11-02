local GUI = {}
local GUI_INIT = false
local GuildProfessions = {}
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

------------PROFFESSIONS DATABASES-----------------------------------------

local AlchemyDB = {}
local EnchantingDB = {}
local BlackSmithingDB = {}
local EngineeringDB = {}
local TailoringDB = {}
local LeatherWorkingDB = {}
local FirstAidDB = {}
local CookingDB = {}
---------------------------------------------------------------------------
----------------------------GLOBALS----------------------------------------
_G["GUI"] = GUI

---------------------------------------------------------------------------

function GUI:init()
    print("WTF")
    filterSettings = {
        [blacksmithingBOX] = true, 
        [enchantingBOX] = true, 
        [engineeringBOX] = true,
        [leatherWorkingBOX] = true,
        [tailoringBOX] = true,
        [cookingBOX] = true,
        [firstAidBOX] = true,
        [alchemyBOX] = true,
    }
    GuildProfessions = _G.GuildProfessions
    GUI:LoadStyling()
    GUI:ReloadDB()
    GUI:Create()

end

function GUI:LoadStyling()
    font = "Fonts\\FRIZQT__.ttf"
end


function UIMenuButton_OnLoad()
    -- this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    -- this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
    -- this:RegisterEvent("PARTY_MEMBER_ENABLE");
    -- this:RegisterEvent("PARTY_MEMBER_DISABLE");
end

function GUI:ReloadDB()
    DB = _G.DB
    gItemsDB = _G.ItemsDB
    AlchemyDB = gItemsDB["Alchemy"] or {}
    EnchantingDB = gItemsDB["Enchanting"] or {}
    BlackSmithingDB = gItemsDB["Black Smithing"] or {}
    EngineeringDB = gItemsDB["Engineering"] or {}
    TailoringDB = gItemsDB["Tailoring"] or {}
    LeatherWorkingDB = gItemsDB["LeatherWorking"] or {}
    FirstAidDB = gItemsDB["First Aid"] or {}
    CookingDB = gItemsDB["Cooking"] or {}
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
        if visible then GUI.UI.frame:Show() end

    end)
end

function GUI:CreateMainFrame(frameName)
    local frame = CreateFrame("Frame", frameName, UIParent)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetWidth(800)
    frame:SetHeight(500) 
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton", "RightButton")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:Show()
    return frame
end


function Item_Onclick(self)
    if self.detail:IsShown() then
        self.detail:Hide()
    else
        if GUI.UI.frame.activeDetail ~= nil and GUI.UI.frame.activeDetail:GetName() ~= self.detail:GetName() then
            GUI.UI.frame.activeDetail.detail:Hide()
        end
        self.detail:Show()
    end

    GUI.UI.frame.activeDetail = self

end

function GUI:CreateItemButtonFrame(frameName,profession, parent, itemData)

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
    rowFrame:SetPoint("TOP", parent, "TOP", 0, 0)
    rowFrame.itemLink = itemLink
    rowFrame.itemID = itemID
    rowFrame.profession = profession

    -- row icon

    rowFrame.icon = rowFrame:CreateTexture("rowIcon" .. tostring(itemTexture) .. "_icon")
    rowFrame.icon:SetPoint("LEFT", rowFrame, "LEFT", 10, 0)
    rowFrame.icon:SetHeight(20)
    rowFrame.icon:SetWidth(20)
    rowFrame.icon:SetTexture(itemTexture)

    rowFrame.text = rowFrame:CreateFontString(rowFrame, "OVERLAY", "GAMETOOLTIPTEXT")
    rowFrame.text:SetPoint("LEFT", 35, 0)
    rowFrame.text:SetText(itemLink)

    rowFrame:RegisterForClicks("AnyDown")
    rowFrame:SetScript("OnClick", Item_Onclick)

    ---detail window
    rowFrame.detail = CreateFrame("Frame", "ItemDetailFrame" .. itemLink, GUI.UI.frame, "BasicFrameTemplateWithInset")
    rowFrame.detail:SetWidth(GUI.UI.frame:GetWidth() - GUI.UI.parentItemFrame:GetWidth())
    rowFrame.detail:SetHeight(GUI.UI.parentItemFrame:GetHeight())
    rowFrame.detail:SetPoint("LEFT", GUI.UI.parentItemFrame, "RIGHT", 0, 0)
    rowFrame.detail:Hide()

    rowFrame.detail.title = rowFrame.detail:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    rowFrame.detail.title:SetPoint("TOP", rowFrame.detail, "TOP", 0, -5);
    rowFrame.detail.title:SetText(itemLink);
    rowFrame.detail.title:SetFont(font, 12, "OUTLINE");


    -- item info
    rowFrame.detail.info = CreateFrame("Frame", "ItemInfoRow" .. itemLink, rowFrame.detail)
    rowFrame.detail.info:SetWidth(rowFrame.detail:GetWidth() - 10)
    rowFrame.detail.info:SetHeight(rowFrame.detail:GetHeight() / 5 - 10)
    rowFrame.detail.info:SetPoint("TOP", rowFrame.detail, "TOP", 0, -25)
    -- icon
    rowFrame.detail.info.icon = rowFrame.detail.info:CreateTexture("ItemInfoRow" .. itemLink .. "_icon")
    rowFrame.detail.info.icon:SetPoint("LEFT", rowFrame.detail.info, "LEFT", 10, -10)
    rowFrame.detail.info.icon:SetHeight(40)
    rowFrame.detail.info.icon:SetWidth(40)
    rowFrame.detail.info.icon:SetTexture(itemTexture)

    -- reagents window
    rowFrame.detail.reagents = CreateFrame("Frame", "regeantRow" .. itemLink, rowFrame.detail)
    rowFrame.detail.reagents:SetWidth(rowFrame.detail:GetWidth() / 2 - 5)
    rowFrame.detail.reagents:SetHeight(rowFrame.detail:GetHeight() - rowFrame.detail.info:GetHeight() - 25)
    rowFrame.detail.reagents:SetPoint("TOPLEFT", rowFrame.detail.info, "BOTTOMLEFT", 0, 0)


    rowFrame.detail.reagents.title = rowFrame.detail.reagents:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    rowFrame.detail.reagents.title:SetPoint("TOPLEFT", rowFrame.detail.reagents, "TOPLEFT", 8, -10);
    rowFrame.detail.reagents.title:SetText("Reagents");
    rowFrame.detail.reagents.title:SetFont(font, 25, "OUTLINE");



    local first = true
    local reagentTable = {}
    for k, v in pairs(reagents) do
        local itemLink, itemIcon,reagentID, count, itemCount = unpack(v)
        local reagent = CreateFrame("Button", "player" .. itemLink, rowFrame.detail.reagents)
        
        reagent:SetWidth((rowFrame.detail.reagents:GetWidth() - 4))
        reagent:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        reagent:SetHeight((rowFrame.detail.reagents:GetHeight() - 4) / 22)

        if first then
            reagent:SetPoint("TOP", rowFrame.detail.reagents, "TOP", 0, -50)
            first = false
        else
            reagent:SetPoint("TOP", reagentTable[#reagentTable], "BOTTOM", 0, -5)
        end

        
        reagent.icon = reagent:CreateTexture("ItemInfoRow" .. itemLink .. "_icon")
        reagent.icon:SetPoint("LEFT", reagent, "LEFT", 8, 0)
        reagent.icon:SetHeight(20)
        reagent.icon:SetWidth(20)
        reagent.icon:SetTexture(itemIcon)


        reagent.text = reagent:CreateFontString(rowFrame, "OVERLAY", "GAMETOOLTIPTEXT")
        reagent.text:SetPoint("LEFT", reagent.icon, "RIGHT", 2, 0)

        local itemCountString
        if tonumber(count) <=  tonumber(itemCount) then
            itemCountString = "|cFF00FF00" ..itemCount.."|r"
        else
            itemCountString = "|cFFFF0000" ..itemCount.."|r"
        end
        reagent.text:SetText(itemLink .. " x " .. count .."[" ..itemCountString.."]")


        reagent.itemLink = itemLink
        reagent:SetScript("OnEnter",OnItemEnter)
        reagent:SetScript("OnLeave",OnItemLeave)

        reagentTable[k] = reagent

    end
    rowFrame.reagentsList = reagentTable;

    -- players window
    rowFrame.detail.players = CreateFrame("Frame", "playersRow" .. itemLink, rowFrame.detail)
    rowFrame.detail.players:SetWidth(rowFrame.detail:GetWidth() / 2 - 5)
    rowFrame.detail.players:SetHeight((rowFrame.detail:GetHeight() - rowFrame.detail.info:GetHeight() - 25) / 2)
    rowFrame.detail.players:SetPoint("TOPRIGHT", rowFrame.detail.info, "BOTTOMRIGHt", 0, 0)
   
    rowFrame.detail.players.title = rowFrame.detail.players:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    rowFrame.detail.players.title:SetPoint("TOP", rowFrame.detail.players, "TOP", -43, -5);
    rowFrame.detail.players.title:SetText("Players");
    rowFrame.detail.players.title:SetFont(font, 25, "OUTLINE");

    local playersList =  {}
    for k, v in pairs(players) do
        local player = CreateFrame("Button", "player" .. k, rowFrame.detail.players)
        player:SetWidth((rowFrame.detail.players:GetWidth() - 4))
        player:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        player:SetHeight((rowFrame.detail.players:GetHeight() - 4) / 18)
        player:SetPoint("TOP", rowFrame.detail.players, "TOP", 0, -50)

        player = player:CreateFontString(rowFrame, "OVERLAY","GAMETOOLTIPTEXT")
        player:SetPoint("LEFT", 20, 0)
        player:SetFont(font,12,"OUTLINE")
        player:SetText(k)
        playersList[k] =  player
    end

    rowFrame.players = playersList;

    -- total cost row (Should get info form auctioneer house)

    -- tab row pin an item, your think about to make (should be able to display in another tab with all other pinned)
    
    rowFrame.detail.text = rowFrame.detail:CreateFontString(rowFrame.detail.bg, "OVERLAY", "GAMETOOLTIPTEXT")
    rowFrame.detail.text:SetPoint("CENTER", 20, 0)
    rowFrame.detail.text:SetText(itemData[0])

    rowFrame:SetScript("OnEnter",OnItemEnter)
    rowFrame:SetScript("OnLeave",OnItemLeave)

    rowFrame:Show()

    return rowFrame
end

function GUI:CreateItems()
    local filteredDBs = GUI:GetFilterDB()
    local firstItem = true
    local items = {}
    local i = 0
    for db_k, db_v in pairs(filteredDBs) do 
        for k, v in pairs(db_v) do
            i = i+1
            items[i] = GUI:CreateItemButtonFrame("firstItemRow","Enchanting", GUI.UI.content, v)
            if firstItem == false then
                items[i]:SetPoint("TOP", items[i-1], "BOTTOM")
            end
            firstItem = false
        end
     
    end 
    return items
end


function OnItemLeave(self)
    GameTooltip:Hide()
end

function OnItemEnter(self) 
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); 
    GameTooltip:ClearLines();
    if self.profession == "Enchanting" then 
        GameTooltip:SetHyperlink("spell:"..self.itemID)
    else
        GameTooltip:SetHyperlink(self.itemLink)
    end
    GameTooltip:Show()
end

function GUI:CreateScrollFrame(frameName, parent, child)
    local scrollFrame = CreateFrame("ScrollFrame", frameName, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetWidth(child:GetWidth())
    scrollFrame:SetHeight(child:GetHeight())
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
    menu:SetScript("OnClick",CheckBox_OnClick)
    return menu
end

function ItemFrame_close(self) 
    GUI.UI.frame:Hide()
end

function GUI:TOGGLE() 
    if GUI.UI.frame:IsVisible() then
        GUI.UI.frame:Hide()
    else
        GUI.UI.frame:Show()
    end
end

function GUI:Create()
    if GUI_INIT then
        return
    end
    GUI_INIT = true
    local frameName = "MAIN_FRAME"
    GUI.UI = {}
    GUI.UI.frame = GUI:CreateMainFrame(frameName)
    -- local menuName = "LEFT_MENU"
    -- GGUI.UI.menu = GUI:CreateMenuFrame(menuName, GGUI.UI.frame)

    GUI.UI.parentItemFrame = CreateFrame("Frame", "MAIN_ITEM_FRAME", GUI.UI.frame, "BasicFrameTemplateWithInset")
    GUI.UI.parentItemFrame:SetWidth(GUI.UI.frame:GetWidth() / 3 + 80)
    GUI.UI.parentItemFrame:SetHeight(GUI.UI.frame:GetHeight())
    GUI.UI.parentItemFrame:SetPoint("LEFT", GUI.UI.frame, "LEFT")
    GUI.UI.parentItemFrame.CloseButton:SetScript("OnClick", ItemFrame_close)

    GUI.UI.title = GUI.UI.parentItemFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    GUI.UI.title:SetPoint("TOP", GUI.UI.parentItemFrame, "TOP", 0, -5);
    GUI.UI.title:SetText("Filthy Professions");
    GUI.UI.title:SetFont(font, 15, "OUTLINE");

    -- GGUI.UI.parentItemFrame = GGUI.UI.parentItemFrame:CreateFontString(nil, "OVERLAY");
    -- GGUI.UI.parentItemFrame.title:SetFontObject("GameFontHighlight");
    -- GGUI.UI.parentItemFrame.title:SetPoint("TOP",  GGUI.UI.parentItemFrame, "TOP", 5, 0);
    -- GGUI.UI.parentItemFrame.title:SetText("CrenUI Buff Options");

    GUI.UI.itemFilterMenu = CreateFrame("Frame", "ITEM_FILTER_MENU", GUI.UI.parentItemFrame, "InsetFrameTemplate2")
    GUI.UI.itemFilterMenu:SetHeight(GUI.UI.parentItemFrame:GetHeight() / 6)
    GUI.UI.itemFilterMenu:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 10)
    GUI.UI.itemFilterMenu:SetPoint("TOP", GUI.UI.parentItemFrame, "TOP", 0, -20)

    local contenFrameName = "CONTENT_FRAME"
    GUI.UI.content = GUI:CreateContentFrame(contenFrameName, GUI.UI.parentItemFrame)
    GUI.UI.content:SetHeight(GUI.UI.parentItemFrame:GetHeight() - GUI.UI.itemFilterMenu:GetHeight())
    GUI.UI.content:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 40)
    GUI.UI.content:SetPoint("TOP", GUI.UI.itemFilterMenu, "BOTTOM", -15, 0)


    local scrollFrameName = "ITEM_SCROLL_FRAME"
    GUI.UI.scrollFrame = GUI:CreateScrollFrame(scrollFrameName, GUI.UI.parentItemFrame, GUI.UI.content)
    GUI.UI.scrollFrame:SetHeight(GUI.UI.parentItemFrame:GetHeight() - GUI.UI.itemFilterMenu:GetHeight())
    GUI.UI.scrollFrame:SetWidth(GUI.UI.parentItemFrame:GetWidth() - 40)
    GUI.UI.scrollFrame:SetPoint("TOP", GUI.UI.itemFilterMenu, "BOTTOM", -15, 0)

    ----------------PROFESSION CHECKBOXES--------------------
    -- local alchyMyName = "ALCHEMY_BOX"firstAidBOX
    GUI.UI.alchemyBox = GUI:CreateCheckBox(alchemyBOX, GUI.UI.itemFilterMenu, "Alchemy", filterSettings[alchemyBOX])
    
    GUI.UI.blacksmithingBox = GUI:CreateCheckBox(blacksmithingBOX, GUI.UI.itemFilterMenu, "Black Smithing", filterSettings[blacksmithingBOX])

    GUI.UI.enchantingBox = GUI:CreateCheckBox(enchantingBOX, GUI.UI.itemFilterMenu, "Enchanting", filterSettings[enchantingBOX])

    GUI.UI.engineeringBox = GUI:CreateCheckBox(engineeringBOX,GUI.UI.itemFilterMenu, "Engineering", filterSettings[engineeringBOX])

    GUI.UI.leatherWorking = GUI:CreateCheckBox(leatherWorkingBOX,GUI.UI.itemFilterMenu, "Leather Working", filterSettings[leatherWorkingBOX])

    GUI.UI.tailoring = GUI:CreateCheckBox(tailoringBOX,GUI.UI.itemFilterMenu, "Tailoring", filterSettings[tailoringBOX])

    GUI.UI.cookingBox = GUI:CreateCheckBox(cookingBOX, GUI.UI.itemFilterMenu, "Cooking", filterSettings[cookingBOX])

    GUI.UI.firstAidBox = GUI:CreateCheckBox(firstAidBOX,GUI.UI.itemFilterMenu, "First Aid", filterSettings[firstAidBOX])
    

    GUI.UI.enchantingBox:SetPoint("LEFT", GUI.UI.blacksmithingBox.text, "RIGHT", 10, 0)
    GUI.UI.alchemyBox:SetPoint("LEFT", GUI.UI.itemFilterMenu, "TOPLEFT", 5, -18)
    GUI.UI.leatherWorking:SetPoint("LEFT", GUI.UI.engineeringBox.text, "RIGHT", 0, 0)
    GUI.UI.engineeringBox:SetPoint("TOP", GUI.UI.alchemyBox, "BOTTOM", 0, 0)
    GUI.UI.cookingBox:SetPoint("TOP", GUI.UI.engineeringBox, "BOTTOM", 0, 0)
    GUI.UI.firstAidBox:SetPoint("TOP", GUI.UI.leatherWorking, "BOTTOM", 0, 0)
    GUI.UI.blacksmithingBox:SetPoint("BOTTOM",   GUI.UI.leatherWorking, "TOP", 0, 0)
    GUI.UI.tailoring:SetPoint("TOP",   GUI.UI.enchantingBox, "BOTTOM", 0, 0)



    ---------------------------------------------------------------------------

    GUI.UI.items = GUI:CreateItems()
    GUI.UI.frame:Hide()
end



function GUI:GetFilterDB()
    local FilteredDBs = {}

    for k,v in pairs(filterSettings) do
        if k == alchemyBOX and v then
            FilteredDBs["Alchemy"] = AlchemyDB
        end

        if k == enchantingBOX and v then
            FilteredDBs["Enchanting"] = EnchantingDB
        end

        if k == engineeringBOX and v then
            FilteredDBs["Engineering"] = EngineeringDB
        end

        if k == leatherWorkingBOX and v then
            FilteredDBs["Leather Working"] = LeatherWorkingDB
        end

        if k == blacksmithingBOX and v then
            FilteredDBs["Black Smithing"] = BlackSmithingDB
        end

        if k == tailoringBOX and v then
            FilteredDBs["Tailoring"] = TailoringDB
        end

        if k == firstAidBOX and v then
            FilteredDBs["First Aid"] = FirstAidDB
        end

        if k == cookingBOX and v then
            FilteredDBs["Cooking"] = CookingDB
        end
    end
    return FilteredDBs
end


function CheckBox_OnClick(self)
    filterSettings[self:GetName()] = self:GetChecked()
    GUI:Refresh()
end

function tprint(tbl, indent)
    if tbl == nil then return end
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
