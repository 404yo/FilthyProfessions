
local GUI = {}
local GUI_INIT = false
local GuildProfessions = {}
local DB  = {}

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
    GUI:reloadDB()
    GUI:refresh()
    GUI:Create()


end

function UIMenuButton_OnLoad()
    -- this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    -- this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
    -- this:RegisterEvent("PARTY_MEMBER_ENABLE");
    -- this:RegisterEvent("PARTY_MEMBER_DISABLE");
end

function GUI:reloadDB()
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

function GUI:refresh()
end

function GUI:CreateMainFrame(frameName)
    -- "BasicFrameTemplateWithInset"
    local frame = CreateFrame("Frame", frameName, UIParent)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetWidth(800)
    frame:SetHeight(600)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton", "RightButton")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    -- frame.TitleText:SetText("GuildProfessions")
    frame:Show()
    return frame
end

function Item_Onclick(self)
    print("clicking on " .. tostring(self.detail))

    if self.detail:IsShown() then
        print("Set hidden")
        self.detail:Hide()
    else
        print("Set shows")
        if GUI.frame.activeDetail ~= nil and GUI.frame.activeDetail:GetName() ~= self.detail:GetName() then
            print("Set hide this")
            GUI.frame.activeDetail.detail:Hide()
        end
        self.detail:Show()
    end

    GUI.frame.activeDetail = self

end

function GUI:CreateItemButtonFrame(frameName, parent, itemData)
  
    local item, regeants, players = unpack(itemData)

    local itemLink = item[1]
    local itemTexure = item[3]
    local itemLevel = item[2]
    local players = itemData[3]
    local reagents = itemData[2]


    local rowFrame = CreateFrame("Button", frameName, parent)

    rowFrame:SetWidth((parent:GetWidth() - 4))
    rowFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    rowFrame:SetHeight((parent:GetHeight() - 4) / 22)
    rowFrame:SetPoint("TOP", parent, "TOP", 0, 0)

    -- row icon

    rowFrame.icon = rowFrame:CreateTexture("rowIcon" .. itemTexure .. "_icon")
    rowFrame.icon:SetPoint("LEFT", rowFrame, "LEFT", 1, -1)
    rowFrame.icon:SetHeight(18)
    rowFrame.icon:SetWidth(18)
    rowFrame.icon:SetTexture(itemTexure)

    rowFrame.text = rowFrame:CreateFontString(rowFrame, "OVERLAY", "GAMETOOLTIPTEXT")
    rowFrame.text:SetPoint("LEFT", 20, 0)
    rowFrame.text:SetText(itemLink)

    rowFrame:RegisterForClicks("AnyDown")
    rowFrame:SetScript("OnClick", Item_Onclick)
    rowFrame:Show()

    ---detail window
    rowFrame.detail = CreateFrame("Frame", "ItemDetailFrame" .. itemLink, GUI.frame, "BasicFrameTemplateWithInset")
    rowFrame.detail:SetWidth(GUI.frame:GetWidth() - GUI.parentItemFrame:GetWidth())
    rowFrame.detail:SetHeight(GUI.parentItemFrame:GetHeight())
    rowFrame.detail:SetPoint("LEFT", GUI.parentItemFrame, "RIGHT", 0, 0)
    rowFrame.detail:Hide()

    -- item info
    rowFrame.detail.info = CreateFrame("Frame", "ItemInfoRow" .. itemLink, rowFrame.detail,
                               "BasicFrameTemplateWithInset")
    rowFrame.detail.info:SetWidth(rowFrame.detail:GetWidth() - 10)
    rowFrame.detail.info:SetHeight(rowFrame.detail:GetHeight() / 5 - 10)
    rowFrame.detail.info:SetPoint("TOP", rowFrame.detail, "TOP", 0, -25)
    -- icon
    rowFrame.detail.info.icon = rowFrame.detail.info:CreateTexture("ItemInfoRow" ..itemLink .. "_icon")
    rowFrame.detail.info.icon:SetPoint("LEFT", rowFrame.detail.info, "LEFT", 10, -10)
    rowFrame.detail.info.icon:SetHeight(40)
    rowFrame.detail.info.icon:SetWidth(40)
    rowFrame.detail.info.icon:SetTexture(itemData[3])

    -- reagents window
    rowFrame.detail.reagents = CreateFrame("Frame", "regeantRow" ..itemLink, rowFrame.detail,
                                   "BasicFrameTemplateWithInset")
    rowFrame.detail.reagents:SetWidth(rowFrame.detail:GetWidth() / 2 - 5)
    rowFrame.detail.reagents:SetHeight(rowFrame.detail:GetHeight() - rowFrame.detail.info:GetHeight() - 25)
    rowFrame.detail.reagents:SetPoint("TOPLEFT", rowFrame.detail.info, "BOTTOMLEFT", 0, 0)


    -- {reagent:GetItemLink(),reagent:GetItemIcon(),count}
    local first = true
    local reagentTable = {}
    tprint(reagents)
    for k, v in pairs(reagents) do
        local itemLink, itemIcon, count =  unpack(v)
        local reagent = CreateFrame("Button", "player" .. itemLink, rowFrame.detail.reagents)
        reagent:SetWidth((rowFrame.detail.reagents:GetWidth() - 4))
        reagent:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        reagent:SetHeight((rowFrame.detail.reagents:GetHeight() - 4) / 22)

        if first then 
            reagent:SetPoint("TOP", rowFrame.detail.reagents, "TOP", 0, -50)
            first = false
        else 
            reagent:SetPoint("TOP", reagentTable[#reagentTable] , "BOTTOM", 0, -5)
        end

        reagent.text = reagent:CreateFontString(rowFrame, "OVERLAY","GAMETOOLTIPTEXT")
        reagent.text:SetPoint("LEFT",reagent, "LEFT",50, 0)
        reagent.text:SetText(itemLink .." x"..count)

        reagent.icon = reagent:CreateTexture("ItemInfoRow" ..itemLink .. "_icon")
        reagent.icon:SetPoint("LEFT", reagent, "LEFT", 20, 0)
        reagent.icon:SetHeight(20)
        reagent.icon:SetWidth(20)
        reagent.icon:SetTexture(itemIcon)

        reagentTable[k] = reagent

    end









    -- players window
    rowFrame.detail.players = CreateFrame("Frame", "playersRow" .. itemLink, rowFrame.detail,
                                  "BasicFrameTemplateWithInset")
    rowFrame.detail.players:SetWidth(rowFrame.detail:GetWidth() / 2 - 5)
    rowFrame.detail.players:SetHeight((rowFrame.detail:GetHeight() - rowFrame.detail.info:GetHeight() - 25) / 2)
    rowFrame.detail.players:SetPoint("TOPRIGHT", rowFrame.detail.info, "BOTTOMRIGHt", 0, 0)

    for k, v in pairs(players) do
        -- rowFrame.detail.players.player = CreateFrame("Button", "player" .. k, rowFrame.detail.players)
        -- rowFrame.detail.players.player:SetWidth((rowFrame.detail.players:GetWidth() - 4))
        -- rowFrame.detail.players.player:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        -- rowFrame.detail.players.player:SetHeight((rowFrame.detail.players:GetHeight() - 4) / 22)
        -- rowFrame.detail.players.player:SetPoint("TOP", rowFrame.detail.players, "TOP", 0, -50)

        -- rowFrame.detail.players.player.text = rowFrame.detail.players.player:CreateFontString(rowFrame, "OVERLAY","GAMETOOLTIPTEXT")
        -- rowFrame.detail.players.player.text:SetPoint("LEFT", 20, 0)
        -- rowFrame.detail.players.player.text:SetText(v)
    end




    -- total cost row (Should get info form auctioneer house)

    -- tab row pin an item, your think about to make (should be able to display in another tab with all other pinned)

    -- rowFrame.detail.bg = rowFrame.detail:CreateTexture(nil, "BACKGROUND")
    -- rowFrame.detail.bg:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
    -- rowFrame.detail.bg:SetWidth(200)
    -- rowFrame.detail.bg:SetHeight(200)
    -- rowFrame.detail.bg:SetPoint("CENTER", rowFrame.detail, "CENTER")
    -- rowFrame.detail.bg:Show()

    rowFrame.detail.text = rowFrame.detail:CreateFontString(rowFrame.detail.bg, "OVERLAY", "GAMETOOLTIPTEXT")
    rowFrame.detail.text:SetPoint("CENTER", 20, 0)
    rowFrame.detail.text:SetText(itemData[0])



    return rowFrame
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
    menu:SetWidth(menu:GetWidth() + 5)
    menu:SetHeight(menu:GetHeight() + 5)
    menu.text:SetText(checkBoxText)
    menu.text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE, MONOCHROME")
    menu:SetChecked(checked)
    menu:Show()
    return menu
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
    for k, v in pairs(CookingDB) do
        GUI.items[k] = GUI:CreateItemButtonFrame("firstItemRow", GUI.content, v)
        if firstItem == false then
            GUI.items[k]:SetPoint("TOP", GUI.items[k - 1], "BOTTOM")
        end
        firstItem = false

    end

    ----------------PROFESSION CHECKBOXES--------------------
    -- local alchyMyName = "ALCHEMY_BOX"
    -- GUI.alchemyBox = GUI:CreateCheckBox(alchyMyName, GUI.menu, "Alchemy", true)
    -- GUI.alchemyBox:SetPoint("CENTER", GUI.menu, "TOPLEFT", 25, -60)

    -- local blacksmithingName = "BLACKSMITHING_BOX"
    -- GUI.blacksmithingBox = GUI:CreateCheckBox(blacksmithingName, GUI.menu, "Blacksmithing", true)
    -- GUI.blacksmithingBox:SetPoint("TOP", GUI.alchemyBox, "BOTTOM", 0, -5)

    -- local enchantingName = "ENCHANTING_BOX"
    -- GUI.enchantingBox = GUI:CreateCheckBox(enchantingName, GUI.menu, "Enchanting", true)
    -- GUI.enchantingBox:SetPoint("TOP", GUI.blacksmithingBox, "BOTTOM", 0, -5)

    -- local engineeringName = "ENGINEERING_BOX"
    -- GUI.engineeringBox = GUI:CreateCheckBox(enchantingName, GUI.menu, "Enchanting", true)
    -- GUI.engineeringBox:SetPoint("TOP", GUI.enchantingBox, "BOTTOM", 0, -5)

    -- local cookingName = "COOKING_BOX"
    -- GUI.cookingBox = GUI:CreateCheckBox(cookingName, GUI.menu, "Cooking", true)
    -- GUI.cookingBox:SetPoint("TOP", GUI.engineeringBox, "BOTTOM", 0, -90)

    -- local firstAidName = "FIRSTAID_BOX"
    -- GUI.firstAidBox = GUI:CreateCheckBox(firstAidName, GUI.menu, "First Aid", true)
    -- GUI.firstAidBox:SetPoint("TOP", GUI.cookingBox, "BOTTOM", 0, -5)
    ---------------------------------------------------------------------------
end

function tprint (tbl, indent)
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
 