local gDB = {}
local GUI = {}
local GUI_INIT = false
local GuildProfessions = {}

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
    GUI:Create()
    GUI:reloadDB()

    GUI:refresh()
 
end

function UIMenuButton_OnLoad()
	-- this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	-- this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	-- this:RegisterEvent("PARTY_MEMBER_ENABLE");
	-- this:RegisterEvent("PARTY_MEMBER_DISABLE");
end


function GUI:reloadDB()
    gDB  = _G.DB
    AlchemyDB = gDB["Alchemy"] or {}
    EnchantingDB = gDB["Enchanting"] or {}
    BlacksmithingDB = gDB["Black Smithing"] or {}
    EngineeringDB = gDB["Engineering"] or {}
    TailoringDB = gDB["Tailoring"] or {}
    LeatherWorkingDB = gDB["Leather Working"] or {}
    FirstAidDB = gDB["First Aid"] or {}
    CookingDB = gDB["Cooking"] or {}
end

function GUI:refresh()
    GUI:FillContent()
end

function GUI:CreateMainFrame(frameName)
    -- "BasicFrameTemplateWithInset"
    local frame = CreateFrame("Frame", frameName, UIParent)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetWidth(900)
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

function GUI:CreateItemButtonFrame(frameName, parent,itemData)
    local rowFrame = CreateFrame("Button", frameName, parent, "InsetFrameTemplate2")
    rowFrame:SetWidth((parent:GetWidth()-4))
    rowFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    rowFrame:SetHeight((parent:GetHeight()-4) / 22)
    rowFrame:SetPoint("TOP", parent, "TOP",0,0)
    rowFrame.text = rowFrame:CreateFontString(rowFrame,"OVERLAY","GAMETOOLTIPTEXT")
    rowFrame.text:SetPoint("LEFT",20,0)
    rowFrame.text:SetText(itemData[0])





    -- local first = true
    -- local playerText = {}
    -- for k,v in pairs(itemData[1]) do
    --     playerText[k] = rowFrame:CreateFontString(rowFrame,"OVERLAY","GAMETOOLTIPTEXT")
    --     playerText[k]:SetText(v)

    --     if first then 
    --         playerText[k]:SetPoint("RIGHT",rowFrame,"CENTER",-40,0)
    --     else 
    --         playerText[k]:SetPoint("LEFT",playerText[k-1],"RIGHT",-40,0)
    --     end    
    --    first = false
    -- end

    -- first = true
    -- local reagentText = {}
    -- local reagentString
    -- local i = 0
    -- for k,v in pairs(itemData[2]) do
    --     print(tostring(k),tostring(v))
    --     reagentText[i] = rowFrame:CreateFontString(rowFrame,"OVERLAY","GAMETOOLTIPTEXT")
    --     reagentText[i]:SetText(tostring(k)  .. " x " ..v)
    --     if first then 
    --         reagentText[i]:SetPoint("LEFT",rowFrame,"CENTER",0,0)
    --     else 
    --         reagentText[i]:SetPoint("LEFT",reagentText[i-1],"RIGHT",10,0)
    --     end  
    --     i = i + 1
    --     first = false

    -- end

    
    return rowFrame
end

function GUI:CreateScrollFrame(frameName,parent,child) 
    local scrollFrame =  CreateFrame ("ScrollFrame", frameName, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetWidth(child:GetWidth())
    scrollFrame:SetHeight(child:GetHeight())
    scrollFrame:SetPoint("BOTTOM", parent, "BOTTOM",-12,5)
    scrollFrame:SetScrollChild(child)
    return scrollFrame

end

function GUI:CreateContentFrame(frameName, parent)
    local contentFrame = CreateFrame("Frame", frameName, parent, "InsetFrameTemplate2")
    contentFrame:SetWidth(parent:GetWidth()-40)
    contentFrame:SetHeight(parent:GetHeight()-100)
    contentFrame:SetPoint("BOTTOM", parent, "BOTTOM",-12,5)
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
    
    GUI.parentItemFrame = CreateFrame("Frame","MAIN_ITEM_FRAME",GUI.frame,"BasicFrameTemplateWithInset")
    GUI.parentItemFrame:SetWidth(GUI.frame:GetWidth()/3+80)
    GUI.parentItemFrame:SetHeight(GUI.frame:GetHeight())
    GUI.parentItemFrame:SetPoint("LEFT", GUI.frame, "LEFT")
    
    GUI.itemFilterMenu = CreateFrame("Frame","ITEM_FILTER_MENU", GUI.parentItemFrame,"InsetFrameTemplate2")
    GUI.itemFilterMenu:SetHeight(GUI.parentItemFrame:GetHeight()/6)
    GUI.itemFilterMenu:SetWidth(GUI.parentItemFrame:GetWidth()-10)
    GUI.itemFilterMenu:SetPoint("TOP",GUI.parentItemFrame,"TOP",0,-20)


    local contenFrameName = "CONTENT_FRAME"
    GUI.content = GUI:CreateContentFrame(contenFrameName,GUI.parentItemFrame)
    GUI.content:SetHeight(GUI.parentItemFrame:GetHeight()-GUI.itemFilterMenu:GetHeight())
    GUI.content:SetWidth(GUI.parentItemFrame:GetWidth()-40)
    GUI.content:SetPoint("TOP",GUI.itemFilterMenu,"BOTTOM",-15,0)

    
    local scrollFrameName = "ITEM_SCROLL_FRAME"
    GUI.scrollFrame = GUI:CreateScrollFrame(scrollFrameName, GUI.parentItemFrame,GUI.content)
    GUI.scrollFrame:SetHeight(GUI.parentItemFrame:GetHeight()-GUI.itemFilterMenu:GetHeight())
    GUI.scrollFrame:SetWidth(GUI.parentItemFrame:GetWidth()-40)
    GUI.scrollFrame:SetPoint("TOP",GUI.itemFilterMenu,"BOTTOM",-15,0)


    ----------------PROFESSION CHECKBOXES--------------------
    local alchyMyName = "ALCHEMY_BOX"
    GUI.alchemyBox = GUI:CreateCheckBox(alchyMyName, GUI.menu, "Alchemy", true)
    GUI.alchemyBox:SetPoint("CENTER", GUI.menu, "TOPLEFT", 25, -60)

    local blacksmithingName = "BLACKSMITHING_BOX"
    GUI.blacksmithingBox = GUI:CreateCheckBox(blacksmithingName, GUI.menu, "Blacksmithing", true)
    GUI.blacksmithingBox:SetPoint("TOP", GUI.alchemyBox, "BOTTOM", 0, -5)

    local enchantingName = "ENCHANTING_BOX"
    GUI.enchantingBox = GUI:CreateCheckBox(enchantingName, GUI.menu, "Enchanting", true)
    GUI.enchantingBox:SetPoint("TOP", GUI.blacksmithingBox, "BOTTOM", 0, -5)

    local engineeringName = "ENGINEERING_BOX"   
    GUI.engineeringBox = GUI:CreateCheckBox(enchantingName, GUI.menu, "Enchanting", true)
    GUI.engineeringBox:SetPoint("TOP", GUI.enchantingBox, "BOTTOM", 0, -5)

    local cookingName = "COOKING_BOX"
    GUI.cookingBox = GUI:CreateCheckBox(cookingName, GUI.menu, "Cooking", true)
    GUI.cookingBox:SetPoint("TOP", GUI.engineeringBox, "BOTTOM", 0, -90)

    local firstAidName = "FIRSTAID_BOX"
    GUI.firstAidBox = GUI:CreateCheckBox(firstAidName, GUI.menu, "First Aid", true)
    GUI.firstAidBox:SetPoint("TOP", GUI.cookingBox, "BOTTOM", 0, -5)
    ---------------------------------------------------------------------------
end

function GUI:ParseDBItem(itemID,item) 
    local parsedItem = {}
    local reagents = {}
    local players =  {}
    local itemLink = GuildProfessions:GetItemLink(itemID)
    for k,v in pairs(item) do
        if (k == "reagents") then 
            local reagentItem = {}
            for reagentKey,count in pairs(v) do
                local reagentItemLink = GuildProfessions:GetItemLink(reagentKey)
                reagentItem[tostring(reagentItemLink)] = count
            end

           reagents = reagentItem
        else
            table.insert(players,k)
        end
    end
    parsedItem = { [0] = itemLink, [1] =  players, [2] = reagents}
    return parsedItem
end

function GUI:FillContent()
    GUI:reloadDB()
    items = {}
    for k,v in pairs(TailoringDB) do
        table.insert(items,GUI:ParseDBItem(k,v))
    end

    for k,v in pairs(FirstAidDB) do
        table.insert(items,GUI:ParseDBItem(k,v))
    end

    for k,v in pairs(EnchantingDB) do
        table.insert(items,GUI:ParseDBItem(k,v))
    end

    for k,v in pairs(CookingDB) do
        table.insert(items,GUI:ParseDBItem(k,v))
    end
    
    GUI.items = {}

    local firstItem = true
    for k,v in pairs(items) do
        GUI.items[k] = GUI:CreateItemFrame("firstItemRow", GUI.content, v)
        if firstItem == false then 
            GUI.items[k]:SetPoint("TOP", GUI.items[k-1], "BOTTOM")
        end
        firstItem = false
    
    end

end
