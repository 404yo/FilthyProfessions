local db = _G.gDB
local GUI = {}
local GUI_INIT = false

----------------------------GLOBALS----------------------------------------
_G["GUI"] = GUI
--------------------------------------------------------------------------

function GUI:init()
    GUI:Create()
end

function GUI:CreateMainFrame(frameName)

    local frame = CreateFrame("Frame",frameName, UIParent, "BasicFrameTemplateWithInset")
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UiParent,"CENTER")
    frame:SetWidth(920)
    frame:SetHeight(600)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton", "RightButton")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame.TitleText:SetText("GuildProfessions")
    frame:Show()

    return frame

end

function GUI:CreateMenuFrame(frameName,parent)
    local menuFrame = CreateFrame("Frame",frameName,parent,"InsetFrameTemplate2") 
    menuFrame:SetWidth(parent:GetWidth()/4)
    menuFrame:SetHeight(parent:GetHeight()-30)
    menuFrame:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT",6,6)
    return menuFrame
end

function GUI:CreateCheckBox(frameName,parent,checkBoxText, checked)
    local menu =  CreateFrame("Checkbutton",frameName,parent,"UICheckButtonTemplate")
    menu:SetWidth(menu:GetWidth()+5)
    menu:SetHeight(menu:GetHeight()+5)
    menu.text:SetText(checkBoxText)
    menu.text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE, MONOCHROME")
    menu:SetChecked(checked)
    menu:Show()
    return menu
end

function GUI:Create() 
    if GUI_INIT then return end
    GUI_INIT = true
    local frameName = "MAIN_FRAME"
    GUI.frame = GUI:CreateMainFrame(frameName)
    local menuName = "LEFT_MENU"
    GUI.menu = GUI:CreateMenuFrame(menuName,GUI.frame)

    ----------------PROFESSION CHECKBOXES--------------------
    local alchyMyName = "ALCHEMY_BOX"
    GUI.alchemyBox = GUI:CreateCheckBox(alchyMyName,GUI.menu,"Alchemy",true)
    GUI.alchemyBox:SetPoint("CENTER",GUI.menu,"TOPLEFT",25,-60)

    local blacksmithingName = "BLACKSMITHING_BOX"
    GUI.blacksmithingBox = GUI:CreateCheckBox(blacksmithingName,GUI.menu,"Blacksmithing",true)
    GUI.blacksmithingBox:SetPoint("TOP",GUI.alchemyBox,"BOTTOM",0,-5)

    local enchantingName = "ENCHANTING_BOX"
    GUI.enchantingBox = GUI:CreateCheckBox(enchantingName,GUI.menu,"Enchanting",true)
    GUI.enchantingBox:SetPoint("TOP",GUI.blacksmithingBox,"BOTTOM",0,-5)

    local engineeringName = "ENGINEERING_BOX"
    GUI.engineeringBox = GUI:CreateCheckBox(enchantingName,GUI.menu,"Enchanting",true)
    GUI.engineeringBox:SetPoint("TOP",GUI.enchantingBox,"BOTTOM",0,-5)





    
    local cookingName = "COOKING_BOX"
    GUI.cookingBox = GUI:CreateCheckBox(cookingName,GUI.menu,"Cooking",true)
    GUI.cookingBox:SetPoint("TOP",GUI.engineeringBox,"BOTTOM",0,-90)

    local firstAidName = "FIRSTAID_BOX"
    GUI.firstAidBox = GUI:CreateCheckBox(firstAidName,GUI.menu,"First Aid",true)
    GUI.firstAidBox:SetPoint("TOP",GUI.cookingBox,"BOTTOM",0,-5)
    ---------------------------------------------------------------------------
end