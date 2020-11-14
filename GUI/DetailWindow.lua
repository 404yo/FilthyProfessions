local DetailWindow = {}
local FilthyProfessions = _G.FilthyProfessions 
FilthyProfessions.DetailWindow = DetailWindow
local font = FilthyProfessions.font
local Players = FilthyProfessions.Players
local Reagents = {}
local MainWindow = {}
local Players = {}

local function Update(parent)
    
    DetailWindow.frame:Hide()
    local itemLink = parent.itemLink
    local itemID = parent.itemID
    local profession = parent.profession
    local reagents = parent.reagents
    local players = parent.players

    print("This has an itemLink",itemLink)
    DetailWindow.infoIcon:SetTexture(parent.itemTexture)
    DetailWindow.ItemNameText:SetText(itemLink);
    DetailWindow.professionText:SetText(profession);

    DetailWindow.reagents.update(reagents)
    DetailWindow.players.update(itemID,players)

    DetailWindow.frame:Show()

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
        
            DetailWindow.frame = CreateFrame("Frame", "ItemDetailWindowFrame",MainWindow.frame, "BasicFrameTemplateWithInset")

            DetailWindow.info = CreateFrame("Frame", "DetailWindowInfo" , DetailWindow.frame)

    end
    
    DetailWindow.frame:SetWidth(260)
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
    DetailWindow.title:SetFont(font, 12, "OUTLINE");

    DetailWindow.info:SetWidth(DetailWindow.frame:GetWidth() - 10)
    DetailWindow.info:SetHeight(DetailWindow.frame:GetHeight() /5 - 10)
    DetailWindow.info:SetPoint("TOP", DetailWindow.frame, "TOP", 0, -25)

    DetailWindow.infoIcon = DetailWindow.frame:CreateTexture(nil)
    DetailWindow.infoIcon:ClearAllPoints()
    DetailWindow.infoIcon:SetPoint("TOPLEFT", DetailWindow.frame, "TOPLEFT", 10, -60)
    DetailWindow.infoIcon:SetHeight(40)
    DetailWindow.infoIcon:SetWidth(40)

    DetailWindow.ItemNameText = DetailWindow.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    DetailWindow.ItemNameText:ClearAllPoints()
    DetailWindow.ItemNameText:SetPoint("BOTTOMLEFT", DetailWindow.infoIcon, "TOPLEFT", 0, 10);
    DetailWindow.ItemNameText:SetFont(font, 15, "OUTLINE");

    DetailWindow.professionText = DetailWindow.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    DetailWindow.professionText:ClearAllPoints()
    DetailWindow.professionText:SetPoint("LEFT", DetailWindow.infoIcon, "RIGHT", 20, 0);
    DetailWindow.professionText:SetFont(font, 14, "OUTLINE");

    DetailWindow.reagents = Reagents:Create(DetailWindow,reagents)
    DetailWindow.players = Players:Create(DetailWindow,itemID,DetailWindow.reagents,players)
    
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