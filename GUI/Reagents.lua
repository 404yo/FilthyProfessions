local Reagents = {}
Reagents.reagentRows = {}
local FilthyProfessions = _G.FilthyProfessions
FilthyProfessions.Reagents = Reagents
local realm
local font
local DB ={}

local unpack,next, tonumber, floor = unpack,next,tonumber,floor

-- local AucAdvanced = AucAdvanced
local function  OnItemLeave(parent)
    GameTooltip:Hide()
end

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


local function updateReagent(reagent,ableToCraftCount,reagentRow)

    local itemLink, itemIcon, reagentID, count, itemCount = unpack(reagent)

    reagentRow.icon:SetTexture(itemIcon)
    reagentRow.text:SetText(itemLink)

    reagentRow.icon:ClearAllPoints()
    reagentRow.text:ClearAllPoints()
    reagentRow.countText:ClearAllPoints()

    reagentRow.text:SetFont(font, 12, "OUTLINE");
    reagentRow.text:SetPoint("LEFT", reagentRow.icon, "RIGHT", 2, 0)
    reagentRow.text:SetText(itemLink)

    reagentRow.icon:SetPoint("LEFT", reagentRow.frame, "LEFT", 0, 0)
    reagentRow.icon:SetHeight(20)
    reagentRow.icon:SetWidth(20)
    reagentRow.icon:SetTexture(itemIcon)


    local itemCountString
    if tonumber(count) <= tonumber(itemCount) then
        itemCountString = "|cFF00FF00" .. itemCount .. "|r"
    else
        itemCountString = "|cFFFF0000" .. itemCount .. "|r"
    end


    reagentRow.countText:SetPoint("RIGHT", reagentRow.frame , "RIGHT", -20, 0)
    reagentRow.countText:SetText("["..count.."/"..itemCountString.."]")
    reagentRow.frame.itemLink = itemLink
    

    reagentRow.countText:SetFont(font, 12, "OUTLINE");
    reagentRow.countText:SetPoint("RIGHT", reagentRow.frame , "RIGHT", -20, 0)
    reagentRow.countText:SetText("["..count.."/"..itemCountString.."]")


    reagentRow.frame:SetScript("OnEnter", OnItemEnter)
    reagentRow.frame:SetScript("OnLeave", OnItemLeave)

    if itemCount/count < ableToCraftCount then
        ableToCraftCount = itemCount/count
    end


    return ableToCraftCount,reagentRow

end

local function CreateRow(reagent,ableToCraftCount,index,parent)
    
    local reagentRow = {} 

    local itemLink, itemIcon, reagentID, count, itemCount = unpack(reagent)

    reagentRow.frame = CreateFrame("Button", "REAGENT_"..index, parent.frame)   
    reagentRow.countText = reagentRow.frame:CreateFontString(font, "OVERLAY", "GAMETOOLTIPTEXT")
    reagentRow.marketPrice = reagentRow.frame:CreateFontString(font, "OVERLAY")
    reagentRow.frame:SetWidth(parent.frame:GetWidth() - 4)
    reagentRow.frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    reagentRow.frame:SetHeight(10)
    reagentRow.icon = reagentRow.frame:CreateTexture("REAGENT_ROW_ICON_"..index)
    reagentRow.text = reagentRow.frame:CreateFontString(font, "OVERLAY", "GAMETOOLTIPTEXT")

    local itemCountString

    if tonumber(count) <= tonumber(itemCount) then
        itemCountString = "|cFF00FF00" .. itemCount .. "|r"
    else
        itemCountString = "|cFFFF0000" .. itemCount .. "|r"
    end
    reagentRow.frame.itemLink = itemLink
    reagentRow.frame:SetScript("OnEnter", OnItemEnter)
    reagentRow.frame:SetScript("OnLeave", OnItemLeave)
    reagentRow.update = function(_reagent,_ableToCraftCount) 
        return updateReagent(_reagent,_ableToCraftCount,reagentRow)
    end
    if itemCount/count < ableToCraftCount then
        ableToCraftCount = itemCount/count
    end
    return ableToCraftCount,reagentRow
end


local function UpdateReagents(reagents,callback)
    local ableToCraftCount = 999
    for k,v in next,Reagents.reagentRows do Reagents.reagentRows[k].frame:Hide() end

    for k, reagent in next, reagents do
        if  Reagents.reagentRows[k] == nil  then
            ableToCraftCount, Reagents.reagentRows[k] = CreateRow(reagent,ableToCraftCount,k,Reagents)
        else
            ableToCraftCount,Reagents.reagentRows[k] = Reagents.reagentRows[k].update(reagent,ableToCraftCount,reagent)
        end

        Reagents.reagentRows[k].frame:ClearAllPoints();
        
        if k == 1 then
            Reagents.reagentRows[k].frame:SetPoint("TOP", Reagents.frame, "TOP", 10, -35)
        else
            Reagents.reagentRows[k].frame:SetPoint("TOP", Reagents.reagentRows[k-1].frame, "BOTTOM", 0, -5)
        end
        Reagents.reagentRows[k].frame:Show()
    end
    Reagents.reagentsSummary:ClearAllPoints() 
    Reagents.reagentsSummary:SetPoint("TOPLEFT", Reagents.frame, "BOTTOMLEFT", 10, -4);
    Reagents.reagentsSummary:SetText("Resources for: |cFFFFC0CB"..floor(ableToCraftCount).."|r");
    Reagents.reagentsSummary:SetFont(font, 12);
    callback(true)

end

local function isTableEmpty(tbl)
    if next(tbl) == nil then
        return true
    end
    return false
end

Reagents.frame = CreateFrame("Frame")
Reagents.frame:SetScale(1)
Reagents.reagentsSummary = Reagents.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
Reagents.reagentsTitle = Reagents.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");

function Reagents:Create(parent,reagents)
    font = FilthyProfessions.font
    DB = FilthyProfessions.DB
    realm = FilthyProfessions.realmName
    Reagents.frame:SetParent(parent.frame)
    Reagents.frame:SetWidth(parent.frame:GetWidth())
    Reagents.frame:SetHeight(parent.frame:GetHeight()/2 - parent.info:GetHeight())
    Reagents.frame:SetPoint("TOP", parent.info, "BOTTOM", 0, 0)
    Reagents.reagentsTitle:SetPoint("TOPLEFT", Reagents.frame, "TOPLEFT", 10, -4);
    Reagents.reagentsTitle:SetText("|cFFE658EDReagents|r");
    Reagents.reagentsTitle:SetFont(font, 15, "OUTLINE");
    local line = Reagents.frame:CreateLine()
    line:SetColorTexture(0.9, 0.5, 0.93,0.7)
    line:SetThickness(2)
    line:SetStartPoint("TOPLEFT",10,-20)
    line:SetEndPoint("TOPRIGHT",-10,-20)

    Reagents.update = function(_reagents,callback) 
        UpdateReagents(_reagents,callback)
    end


    return Reagents
end