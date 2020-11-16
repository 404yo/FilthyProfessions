local MainWindow = {}
local FilthyProfessions = _G.FilthyProfessions
local GUI = FilthyProfessions.GUI
local blacksmithingBOX = "Black Smithing"
local enchantingBOX = "Enchanting"
local engineeringBOX = "Engineering"
local leatherWorkingBOX = "Leather Working"
local tailoringBOX = "Tailoring"
local cookingBOX = "Cooking"
local firstAidBOX = "First Aid"
local alchemyBOX = "Alchemy"
local pinnedBOX  = "pinned"
FilthyProfessions.MainWindow = MainWindow

local gItemsDB

local font
local gFilterSettings

local function  CreateScrollFrame(frameName, parent, child)
    local  scrollFrame = CreateFrame("ScrollFrame", frameName, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetWidth(child:GetWidth())
    scrollFrame:SetHeight(child:GetHeight() - 80)
    scrollFrame:SetPoint("BOTTOM", parent, "BOTTOM", -12, 5)
    scrollFrame:SetScrollChild(child)
    return scrollFrame
end

local function CreateContentFrame(frameName, parent)
    local contentFrame = CreateFrame("Frame", frameName, parent)
    contentFrame:SetWidth(parent:GetWidth() - 40)
    contentFrame:SetHeight(parent:GetHeight() - 100)
    contentFrame:SetPoint("BOTTOM", parent, "BOTTOM", -12, 5)
    return contentFrame
end

-- local function CreateMenuFrame(frameName, parent)
--     local  menuFrame = CreateFrame("Frame", frameName, parent, "InsetFrameTemplate2")
--     menuFrame:SetWidth(parent:GetWidth() / 5 - 20)
--     menuFrame:SetHeight(parent:GetHeight() - 30)
--     menuFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 6, 6)
--     return menuFrame
-- end

local function CheckBox_OnClick(self)
    local name = self:GetName()
    print(name)
    GUI:tprint(gItemsDB[name])
    gFilterSettings[name] = self:GetChecked()
    GUI:DisplayFilteredItems()
end

local function On_Search(self)
    GUI:SearchItems(self:GetText())
end

local function CreateSearchBox(parent)
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



local function CreateCheckBox(frameName, parent, checkBoxText, checked)
    local menu = CreateFrame("Checkbutton", frameName, parent, "UICheckButtonTemplate")
    menu:SetWidth(25)
    menu:SetHeight(25)
    menu.text:SetText(checkBoxText)
    menu.text:SetFont(font, 12, "MONOCHROME")
    menu:SetChecked(checked)
    menu:Show()
    menu:SetScript("OnClick", CheckBox_OnClick)
    return menu
end


local function TOGGLE()
    if MainWindow.frame:IsVisible() then
        MainWindow.frame:Hide()
    else
        MainWindow.frame:Show()
    end
end

local function ItemFrame_close(self)
    MainWindow.frame:Hide()
end

local function CreateParentItemFrame()
    local parentItemFrame = CreateFrame("Frame", "MAIN_ITEM_FRAME", MainWindow.frame, "BasicFrameTemplateWithInset")
    parentItemFrame:SetWidth(370)
    parentItemFrame:SetHeight(MainWindow.frame:GetHeight())
    parentItemFrame:SetPoint("LEFT", MainWindow.frame, "LEFT")
    parentItemFrame:SetToplevel(true)
    parentItemFrame.CloseButton:SetScript("OnClick", ItemFrame_close)
    return parentItemFrame
end

local function CreateMainFrame(frameName)
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


function MainWindow:Create()
    font = FilthyProfessions.font
    gFilterSettings = FilthyProfessions.gFilterSettings
    Item = FilthyProfessions.Item
    if FilthyProfessions.GUI_INIT then
        return
    end
    gItemsDB = FilthyProfessions.gItemsDB
    FilthyProfessions.GUI_INIT = true
    local frameName = "MAIN_FRAME"
  
    MainWindow.frame = CreateMainFrame(frameName)
    MainWindow.frame:SetScale(1)

    MainWindow.parentItemFrame = CreateParentItemFrame()

    MainWindow.title = MainWindow.parentItemFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    MainWindow.title:SetPoint("TOP", MainWindow.parentItemFrame, "TOP", 0, -5);
    MainWindow.title:SetText("|cFFF24444F|r|cFF58ED76|cFFF2F244i|r|cFF44F2E9l|r|cFF445bf2t|r|cffc144f2h|r|cfff244c6y|r Professions");
    MainWindow.title:SetFont(font, 15, "OUTLINE");

    MainWindow.itemFilterMenu = CreateFrame("Frame", "ITEM_FILTER_MENU", MainWindow.parentItemFrame, "InsetFrameTemplate2")
    MainWindow.itemFilterMenu:SetHeight(MainWindow.parentItemFrame:GetHeight() / 6)
    MainWindow.itemFilterMenu:SetWidth(MainWindow.parentItemFrame:GetWidth() - 10)
    MainWindow.itemFilterMenu:SetPoint("TOP", MainWindow.parentItemFrame, "TOP", 0, -20)

    MainWindow.itemCol = CreateFrame("Frame", "ITEM_COLS", MainWindow.parentItemFrame)
    MainWindow.itemCol:SetHeight(MainWindow.itemFilterMenu:GetHeight()/4-10)
    MainWindow.itemCol:SetWidth(MainWindow.parentItemFrame:GetWidth() - 10)
    MainWindow.itemCol:SetPoint("TOP", MainWindow.itemFilterMenu, "BOTTOM", 0, 0)

    MainWindow.itemCol.PinnedText = MainWindow.itemCol:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    MainWindow.itemCol.PinnedText :SetPoint("LEFT", MainWindow.itemCol, "BOTTOMLEFT", 4, 6);
    MainWindow.itemCol.PinnedText :SetText("pin");
    MainWindow.itemCol.PinnedText :SetFont(font, 12, "OUTLINE");

    MainWindow.itemCol.NameText = MainWindow.itemCol:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    MainWindow.itemCol.NameText :SetPoint("LEFT", MainWindow.itemCol.PinnedText, "RIGHT", 40, 0);
    MainWindow.itemCol.NameText :SetText("name");
    MainWindow.itemCol.NameText :SetFont(font, 12, "OUTLINE");

    MainWindow.toggle = function() 
        TOGGLE()
    end

    MainWindow.itemCol.ItemLevelText = MainWindow.itemCol:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    MainWindow.itemCol.ItemLevelText :SetPoint("RIGHT", MainWindow.itemCol, "BOTTOMRIGHT", -32, 6);
    MainWindow.itemCol.ItemLevelText :SetText("lvl");
    MainWindow.itemCol.ItemLevelText :SetFont(font, 12, "OUTLINE");

    MainWindow.itemCol.professionText = MainWindow.itemCol:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    MainWindow.itemCol.professionText :SetPoint("RIGHT", MainWindow.itemCol.ItemLevelText, "LEFT", -30, 0);
    MainWindow.itemCol.professionText :SetText("prof");
    MainWindow.itemCol.professionText :SetFont(font, 12, "OUTLINE");


    local contenFrameName = "CONTENT_FRAME"
    MainWindow.content = CreateContentFrame(contenFrameName, MainWindow.parentItemFrame)
    MainWindow.content:SetHeight(MainWindow.parentItemFrame:GetHeight() - (MainWindow.itemFilterMenu:GetHeight() + MainWindow.itemCol:GetHeight()))
    MainWindow.content:SetWidth(MainWindow.parentItemFrame:GetWidth() - 40)
    MainWindow.content:SetPoint("TOP", MainWindow.itemCol, "BOTTOM", -15, -5)

    MainWindow.SearchFrame = CreateSearchBox(MainWindow.itemFilterMenu)

    local scrollFrameName = "ITEM_SCROLL_FRAME"
    MainWindow.scrollFrame = CreateScrollFrame(scrollFrameName, MainWindow.parentItemFrame, MainWindow.content)
    MainWindow.scrollFrame:SetHeight(MainWindow.parentItemFrame:GetHeight() - (MainWindow.itemFilterMenu:GetHeight() + MainWindow.itemCol:GetHeight()+100))
    MainWindow.scrollFrame:SetWidth(MainWindow.parentItemFrame:GetWidth() - 40)
    MainWindow.scrollFrame:SetPoint("TOP", MainWindow.itemCol, "BOTTOM", -15, -5)

    ----------------PROFESSION CHECKBOXES--------------------
    MainWindow.alchemyBox =CreateCheckBox(alchemyBOX, MainWindow.itemFilterMenu, "Alchemy", gFilterSettings[alchemyBOX])

    MainWindow.blacksmithingBox = CreateCheckBox(blacksmithingBOX, MainWindow.itemFilterMenu, "Black Smithing",
    gFilterSettings[blacksmithingBOX])

    MainWindow.enchantingBox = CreateCheckBox(enchantingBOX, MainWindow.itemFilterMenu, "Enchanting",
    gFilterSettings[enchantingBOX])

    MainWindow.engineeringBox = CreateCheckBox(engineeringBOX, MainWindow.itemFilterMenu, "Engineering",
    gFilterSettings[engineeringBOX])

    MainWindow.leatherWorking = CreateCheckBox(leatherWorkingBOX, MainWindow.itemFilterMenu, "Leather Working",
    gFilterSettings[leatherWorkingBOX])

    MainWindow.tailoring =
        CreateCheckBox(tailoringBOX, MainWindow.itemFilterMenu, "Tailoring", gFilterSettings[tailoringBOX])

    MainWindow.cookingBox = CreateCheckBox(cookingBOX, MainWindow.itemFilterMenu, "Cooking", gFilterSettings[cookingBOX])

    MainWindow.firstAidBox =
        CreateCheckBox(firstAidBOX, MainWindow.itemFilterMenu, "First Aid", gFilterSettings[firstAidBOX])

    MainWindow.PinnedBox = CreateCheckBox(pinnedBOX, MainWindow.itemFilterMenu, "Pin", gFilterSettings[pinnedBOX])

    MainWindow.enchantingBox:SetPoint("LEFT", MainWindow.blacksmithingBox.text, "RIGHT", 10, 0)
    MainWindow.alchemyBox:SetPoint("LEFT", MainWindow.itemFilterMenu, "TOPLEFT", 5, -18)
    MainWindow.leatherWorking:SetPoint("LEFT", MainWindow.engineeringBox.text, "RIGHT", 0, 0)
    MainWindow.engineeringBox:SetPoint("TOP", MainWindow.alchemyBox, "BOTTOM", 0, 0)
    MainWindow.cookingBox:SetPoint("TOP", MainWindow.engineeringBox, "BOTTOM", 0, 0)
    MainWindow.firstAidBox:SetPoint("TOP", MainWindow.leatherWorking, "BOTTOM", 0, 0)
    MainWindow.blacksmithingBox:SetPoint("BOTTOM", MainWindow.leatherWorking, "TOP", 0, 0)
    MainWindow.tailoring:SetPoint("TOP", MainWindow.enchantingBox, "BOTTOM", 0, 0)
    MainWindow.PinnedBox:SetPoint("LEFT", MainWindow.tailoring,"RIGHT",55,0)
    MainWindow.frame:Hide()
end