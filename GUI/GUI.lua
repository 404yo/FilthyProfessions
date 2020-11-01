local GUI = {}
local GUI_INIT = false
local GuildProfessions = {}
local DB = {}
local font
local gItemsDB = {}

-- https://www.townlong-yak.com/framexml/8.1.5/ObjectAPI/Item.lua#33

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
    GUI.frame:Hide()
    GUI = nil
    gItemsDB = {}
    DB:InitItems(function() 
    GUI:ReloadDB()
    GUI:Create()   
    end)
    GUI.frame:Show()
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
        if GUI.frame.activeDetail ~= nil and GUI.frame.activeDetail:GetName() ~= self.detail:GetName() then
            GUI.frame.activeDetail.detail:Hide()
        end
        self.detail:Show()
    end

    GUI.frame.activeDetail = self

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
    rowFrame.detail = CreateFrame("Frame", "ItemDetailFrame" .. itemLink, GUI.frame, "BasicFrameTemplateWithInset")
    rowFrame.detail:SetWidth(GUI.frame:GetWidth() - GUI.parentItemFrame:GetWidth())
    rowFrame.detail:SetHeight(GUI.parentItemFrame:GetHeight())
    rowFrame.detail:SetPoint("LEFT", GUI.parentItemFrame, "RIGHT", 0, 0)
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
        player:SetFont(font,18,"OUTLINE")
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
    return menu
end

function ItemFrame_close(self) 
    GUI.frame:Hide()
end

function GUI:Create()
    if GUI_INIT then
        return
    end
    GUI_INIT = true
    local frameName = "MAIN_FRAME"
    GUI.frame = GUI:CreateMainFrame(frameName)
    -- local menuName = "LEFT_MENU"
    -- GUI.menu = GUI:CreateMenuFrame(menuName, GUI.frame)

    GUI.parentItemFrame = CreateFrame("Frame", "MAIN_ITEM_FRAME", GUI.frame, "BasicFrameTemplateWithInset")
    GUI.parentItemFrame:SetWidth(GUI.frame:GetWidth() / 3 + 80)
    GUI.parentItemFrame:SetHeight(GUI.frame:GetHeight())
    GUI.parentItemFrame:SetPoint("LEFT", GUI.frame, "LEFT")
    GUI.parentItemFrame.CloseButton:SetScript("OnClick", ItemFrame_close)

    GUI.title = GUI.parentItemFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    GUI.title:SetPoint("TOP", GUI.parentItemFrame, "TOP", 0, -5);
    GUI.title:SetText("Filthy Professions");
    GUI.title:SetFont(font, 15, "OUTLINE");

    -- GUI.parentItemFrame = GUI.parentItemFrame:CreateFontString(nil, "OVERLAY");
    -- GUI.parentItemFrame.title:SetFontObject("GameFontHighlight");
    -- GUI.parentItemFrame.title:SetPoint("TOP",  GUI.parentItemFrame, "TOP", 5, 0);
    -- GUI.parentItemFrame.title:SetText("CrenUI Buff Options");

    GUI.itemFilterMenu = CreateFrame("Frame", "ITEM_FILTER_MENU", GUI.parentItemFrame, "InsetFrameTemplate2")
    GUI.itemFilterMenu:SetHeight(GUI.parentItemFrame:GetHeight() / 6)
    GUI.itemFilterMenu:SetWidth(GUI.parentItemFrame:GetWidth() - 10)
    GUI.itemFilterMenu:SetPoint("TOP", GUI.parentItemFrame, "TOP", 0, -20)

    local contenFrameName = "CONTENT_FRAME"
    GUI.content = GUI:CreateContentFrame(contenFrameName, GUI.parentItemFrame)
    GUI.content:SetHeight(GUI.parentItemFrame:GetHeight() - GUI.itemFilterMenu:GetHeight())
    GUI.content:SetWidth(GUI.parentItemFrame:GetWidth() - 40)
    GUI.content:SetPoint("TOP", GUI.itemFilterMenu, "BOTTOM", -15, 0)


    local scrollFrameName = "ITEM_SCROLL_FRAME"
    GUI.scrollFrame = GUI:CreateScrollFrame(scrollFrameName, GUI.parentItemFrame, GUI.content)
    GUI.scrollFrame:SetHeight(GUI.parentItemFrame:GetHeight() - GUI.itemFilterMenu:GetHeight())
    GUI.scrollFrame:SetWidth(GUI.parentItemFrame:GetWidth() - 40)
    GUI.scrollFrame:SetPoint("TOP", GUI.itemFilterMenu, "BOTTOM", -15, 0)



    GUI.items = {}
    local firstItem = true
    local i = 1
    for k, v in pairs(EnchantingDB) do
        i = i+1
        GUI.items[i] = GUI:CreateItemButtonFrame("firstItemRow","Enchanting", GUI.content, v)
        if firstItem == false then
            GUI.items[i]:SetPoint("TOP", GUI.items[i-1], "BOTTOM")
        end
        firstItem = false

    end

    for k, v in pairs(CookingDB) do
        i = i+1
        GUI.items[i] = GUI:CreateItemButtonFrame("firstItemRow","Cooking" ,GUI.content, v)
        if firstItem == false then
            GUI.items[i]:SetPoint("TOP", GUI.items[i-1], "BOTTOM")
        end
        firstItem = false

    end

    for k, v in pairs(FirstAidDB) do
        i = i+1
        GUI.items[i] = GUI:CreateItemButtonFrame("firstItemRow", "First Aid",GUI.content, v)
        if firstItem == false then
            GUI.items[i]:SetPoint("TOP", GUI.items[i-1], "BOTTOM")
        end
        firstItem = false

    end


    for k, v in pairs(TailoringDB) do
        i = i+1
        GUI.items[i] = GUI:CreateItemButtonFrame("firstItemRow", "Tailoring",GUI.content, v)
        if firstItem == false then
            GUI.items[i]:SetPoint("TOP", GUI.items[i-1], "BOTTOM")
        end
        firstItem = false

    end

    ----------------PROFESSION CHECKBOXES--------------------
    -- local alchyMyName = "ALCHEMY_BOX"
    GUI.alchemyBox = GUI:CreateCheckBox("asd", GUI.itemFilterMenu, "Alchemy", true)
    GUI.alchemyBox:SetPoint("LEFT", GUI.itemFilterMenu, "TOPLEFT", 5, -18)

    local blacksmithingName = "BLACKSMITHING_BOX"
    GUI.blacksmithingBox = GUI:CreateCheckBox(blacksmithingName, GUI.itemFilterMenu, "Black Smithing", true)

    local enchantingName = "ENCHANTING_BOX"
    GUI.enchantingBox = GUI:CreateCheckBox(enchantingName, GUI.itemFilterMenu, "Enchanting", true)
    GUI.enchantingBox:SetPoint("LEFT", GUI.blacksmithingBox.text, "RIGHT", 10, 0)

    local engineeringName = "ENGINEERING_BOX"
    GUI.engineeringBox = GUI:CreateCheckBox(enchantingName,GUI.itemFilterMenu, "Engineering", true)
    GUI.engineeringBox:SetPoint("TOP", GUI.alchemyBox, "BOTTOM", 0, 0)


    local leatherWorking = "LEATHERWORKING_BOX"
    GUI.leatherWorking = GUI:CreateCheckBox(leatherWorking,GUI.itemFilterMenu, "Leather Working", true)
    GUI.leatherWorking:SetPoint("LEFT", GUI.engineeringBox.text, "RIGHT", 0, 0)



    local tailoring = "TAILORING_BOX"
    GUI.tailoring = GUI:CreateCheckBox(tailoring,GUI.itemFilterMenu, "Tailoring", true)


    local cookingName = "COOKING_BOX"
    GUI.cookingBox = GUI:CreateCheckBox(cookingName, GUI.itemFilterMenu, "Cooking", true)
    GUI.cookingBox:SetPoint("TOP", GUI.engineeringBox, "BOTTOM", 0, 0)

    local firstAidName = "FIRSTAID_BOX"
    GUI.firstAidBox = GUI:CreateCheckBox(firstAidName,GUI.itemFilterMenu, "First Aid", true)

    GUI.firstAidBox:SetPoint("TOP", GUI.leatherWorking, "BOTTOM", 0, 0)
    GUI.blacksmithingBox:SetPoint("BOTTOM", GUI.leatherWorking, "TOP", 0, 0)
    GUI.tailoring:SetPoint("TOP", GUI.enchantingBox, "BOTTOM", 0, 0)


    ---------------------------------------------------------------------------

    GUI.frame:Show()
    
end

function tprint(tbl, indent)
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
