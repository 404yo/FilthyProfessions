local db = _G.gDB
local GUI = {}
local GUI_INIT = false




function GUI:init()

    GUI:Create()

end

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
    tinsert(UISpecialFrames, frameName)


    frame.CloseButton = CreateFrame("Button", frameName.."_CLOSE", frame, "UIPanelCloseButton")
    frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)


    frame.menuFrame = CreateFrame("Frame", frameName.."_MENU", frame)
    frame.menuFrame:ClearAllPoints()
    frame.menuFrame:setParent(frame)
    frame.menuFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5,-5)
    frame.menuFrame:SetWidth(frame:GetWidth()/4)
    frame.menuFrame:setHeight(frame:GetHeight()-10)

    frame.menuFrame.titleFrame = CreateFrame()



    frame.contentFrame = CreateFrame("Frame", frameName .."-main-content",frame)
    frame.contentFrame:ClearAllPoints()
	frame.contentFrame:SetParent(frame)
	frame.contentFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -70)
	frame.contentFrame:SetWidth(560)		-- Frame = 560, Abstand = 20, Button = 270
	frame.contentFrame:SetHeight(510)		-- Frame = 460, Abstand = 10, Button = 30
	frame.contentFrame.shownFrame = nil
    
    
end