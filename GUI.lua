local db = _G.gDB
local GUI = {}
local GUI_INIT = false

function GUI:Create() 
    if GUI_INIT then return end
    GUI_INIT = true

    local frameName = "MAIN_FRAME"

    local frame = CreateFrame("Frame",frameName)
    frame:ClearAllPoints()
    frame:SetParent(UIParent)
    frame:setPoint("TOP")
    frame:SetWidth(920)
	frame:SetHeight(600)
	frame:SetMovable(true)
	frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton", "RightButton")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetBackdropColor(0.45,0.45,0.45,1)
    frame:Hide()


    frame.CloseButton = CreateFrame("Button", frameName.."-CloseButton", frame, "UIPanelCloseButton")
    frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    
    
end