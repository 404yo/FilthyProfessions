local DetailWindow = {}
local FilthyProfessions = _G.FilthyProfessions 
FilthyProfessions.DetailWindow = DetailWindow
local font
local Players
local Reagents
local MainWindow
local Players


local sgsub = string.gsub
local AucAdvanced = AucAdvanced

local function  OnItemEnter(parent)
    GameTooltip:SetOwner(parent, "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    if parent.profession == "Enchanting" then
        GameTooltip:SetHyperlink("spell:" .. parent.itemID)
    else
        GameTooltip:SetHyperlink(parent.itemLink)
    end
    GameTooltip:Show()
end
local function  OnItemLeave(parent)
    GameTooltip:Hide()
end
local function Update(parent)

    if parent.itemID == DetailWindow.itemID and DetailWindow.frame:IsVisible() then 
        DetailWindow.frame:Hide() 
        return 
    end
    DetailWindow.frame:Hide()
    local itemLink = parent.itemLink
    local itemID = parent.itemID
    local profession = parent.profession
    local reagents = parent.reagents
    local players = parent.players


    local professionText  = profession
    if profession == "Black Smithing" then
        professionText = "|cFFff95f5BS|r"
    end
    if profession == "Tailoring" then
        professionText = "|cFF33f3ff"..profession.."|r"
    end
    
    if profession == "Engineering" then
        professionText = "|cFF918f8f"..profession.."|r"
    end
    
    if profession == "First Aid" then
        professionText = "|cFFb82522"..profession.."|r"
    end
    
    if profession == "Enchanting" then
        professionText = "|cFFfff46c"..profession.."|r"
    end
    
    if profession == "Cooking" then
        professionText = "|cFFffb92d"..profession.."|r"
    end
    
    if profession == "Alchemy" then
        professionText = "|cFFa656ff"..profession.."|r"
    end

    if profession == "Leather Working" then
        professionText = "|cFFc5a964LW|r"
    end

    DetailWindow.itemID = itemID
    DetailWindow.infoIconFrame.itemID = itemID
    DetailWindow.infoIconFrame.itemLink = itemLink
    DetailWindow.infoIconFrame.profession = profession
    DetailWindow.infoIcon:SetTexture(parent.itemTexture)
    DetailWindow.ItemNameText:SetText(sgsub(itemLink,"Enchant ",""));
    DetailWindow.professionText:SetText(professionText);

    DetailWindow.reagents.update(reagents,function() 
        DetailWindow.players.update(players, function() 
            DetailWindow.frame:Show()
        end)
    end)

end

function DetailWindow:Create(parent)

    MainWindow = FilthyProfessions.MainWindow
    Reagents = FilthyProfessions.Reagents
    Players = FilthyProfessions.Players
    font = FilthyProfessions.font

    local itemLink = parent.itemLink
    local itemID = parent.itemID
    local profession = parent.profession
    local reagents = parent.reagents
    local players = parent.players
    
    
    if DetailWindow.frame == nil then
        
            DetailWindow.frame = CreateFrame("Frame",nil,MainWindow.frame, "BasicFrameTemplateWithInset")
            DetailWindow.info = CreateFrame("Frame",nil , DetailWindow.frame)
            DetailWindow.infoIconFrame = CreateFrame("frame",nil,DetailWindow.frame)
    end
    
    DetailWindow.frame:SetWidth(260)
    DetailWindow.frame:SetScale(1)
    DetailWindow.frame:SetHeight(MainWindow.parentItemFrame:GetHeight())
    DetailWindow.frame:SetPoint("LEFT", MainWindow.parentItemFrame, "RIGHT", 0, 0)
    DetailWindow.frame:Hide()
    DetailWindow.frame:SetToplevel(true)
    DetailWindow.frame:EnableMouse(true)
    DetailWindow.frame:SetClampedToScreen(false)

    DetailWindow.itemLink = itemLink
    DetailWindow.title = DetailWindow.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    DetailWindow.title:ClearAllPoints()
    DetailWindow.title:SetPoint("TOP", DetailWindow.frame, "TOP", 0, -5);
    DetailWindow.title:SetText("Recipe Info");
    DetailWindow.title:SetFont(font, 13, "OUTLINE");

    DetailWindow.info:SetWidth(DetailWindow.frame:GetWidth() - 10)
    DetailWindow.info:SetHeight(DetailWindow.frame:GetHeight() /7 - 10)
    DetailWindow.info:SetPoint("TOP", DetailWindow.frame, "TOP", 0, -25)

    DetailWindow.infoIconFrame:SetHeight(35)
    DetailWindow.infoIconFrame:SetWidth(35)
    DetailWindow.infoIconFrame:SetPoint("TOPLEFT", DetailWindow.frame, "TOPLEFT", 10, -40)

    DetailWindow.infoIcon = DetailWindow.infoIconFrame:CreateTexture(nil)
   
    DetailWindow.infoIcon:ClearAllPoints()
    DetailWindow.infoIcon:SetPoint("TOPLEFT", DetailWindow.frame, "TOPLEFT", 10, -40)
    DetailWindow.infoIcon:SetHeight(DetailWindow.infoIconFrame:GetWidth())
    DetailWindow.infoIcon:SetWidth(DetailWindow.infoIconFrame:GetHeight())

       
    DetailWindow.infoIconFrame.profession = profession
    DetailWindow.infoIconFrame.itemID = itemID
    DetailWindow.infoIconFrame.itemLink = itemLink
    DetailWindow.infoIconFrame:SetScript("OnEnter", OnItemEnter)
    DetailWindow.infoIconFrame:SetScript("OnLeave", OnItemLeave)

    DetailWindow.ItemNameText = DetailWindow.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    DetailWindow.ItemNameText:ClearAllPoints()
    DetailWindow.ItemNameText:SetPoint("LEFT", DetailWindow.infoIcon, "RIGHT", 10, 8);
    DetailWindow.ItemNameText:SetFont(font, 13, "OUTLINE");

    DetailWindow.professionText = DetailWindow.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    DetailWindow.professionText:ClearAllPoints()
    DetailWindow.professionText:SetPoint("LEFT", DetailWindow.infoIcon, "RIGHT", 10, -10);
    DetailWindow.professionText:SetFont(font, 12, "OUTLINE");

    DetailWindow.reagents = Reagents:Create(DetailWindow,reagents)
    DetailWindow.players = Players:Create(DetailWindow,itemID,DetailWindow.reagents,DetailWindow.infoIcon,players)
    
    DetailWindow.toggle = function() 
        if DetailWindow.frame:IsVisible() then
            DetailWindow.frame:Hide()
        else
            DetailWindow.frame:Show()
        end
    end
    DetailWindow.update = function(item)
        Update(item)
    end

    return DetailWindow
end