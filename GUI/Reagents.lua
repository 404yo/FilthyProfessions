local Reagents = {}
Reagents.reagentRows = {}
local FilthyProfessions = _G.FilthyProfessions
FilthyProfessions.Reagents = Reagents
local realm
local font

local unpack,next, tonumber, floor = unpack,next,tonumber,floor

local AucAdvancedAPI
local initAuc = false
if  not initAuc and  AucAdvanced and AucAdvanced.API then
    initAuc = true
    AucAdvancedAPI = AucAdvanced.API
end
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

local function GetReagentPrice(itemLink,count,itemCount)

    local marketprice
    if AucAdvancedAPI then
       marketprice = AucAdvancedAPI.GetMarketValue(itemLink,realm)
    else
        return 0,0
    end
    if marketprice ~= nil then
        if tonumber(itemCount) > tonumber(count) then return marketprice*count,0 end
        return marketprice * count , marketprice * (tonumber(count)-tonumber(itemCount))
    end
    return 0,0
end



local GetItemCount = GetItemCount
local function updateReagent(reagent,ableToCraftCount,reagentRow)
    local itemLink, itemIcon, reagentID, count = unpack(reagent)
    local itemCount = GetItemCount(itemLink,true)
    local marketPrice, priceWithMats = GetReagentPrice(itemLink,count,itemCount)

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

    reagentRow.frame:Show()
    return ableToCraftCount,reagentRow, marketPrice,priceWithMats
end

local function CreateRow(reagent,ableToCraftCount,index,parent)
    local reagentRow = {} 


    local itemLink, _, _, _ = unpack(reagent)

    reagentRow.frame = CreateFrame("Button", "REAGENT_"..index, parent.frame)   
    reagentRow.countText = reagentRow.frame:CreateFontString(font, "OVERLAY", "GAMETOOLTIPTEXT")
    reagentRow.marketPrice = reagentRow.frame:CreateFontString(font, "OVERLAY")
    reagentRow.frame:SetWidth(parent.frame:GetWidth() - 4)
    reagentRow.frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    reagentRow.frame:SetHeight(10)
    reagentRow.icon = reagentRow.frame:CreateTexture("REAGENT_ROW_ICON_"..index)
    reagentRow.text = reagentRow.frame:CreateFontString(font, "OVERLAY", "GAMETOOLTIPTEXT")


    reagentRow.frame.itemLink = itemLink
    reagentRow.frame:SetScript("OnEnter", OnItemEnter)
    reagentRow.frame:SetScript("OnLeave", OnItemLeave)
    

    reagentRow.update = function(_reagent,_ableToCraftCount) 
        return updateReagent(_reagent,_ableToCraftCount,reagentRow)
    end

    return updateReagent(reagent,ableToCraftCount,reagentRow)

end

local GetCoinTextureString = GetCoinTextureString
local function UpdateReagents(reagents,callback)
    local ableToCraftCount = 999
    for k,v in next,Reagents.reagentRows do Reagents.reagentRows[k].frame:Hide() end
    local totalMarketPrice = 0
    local totalMarketPriceWithMats = 0 
    for k, reagent in next, reagents do
        local marketPrice, priceWithMats = 0,0
        if  Reagents.reagentRows[k] == nil  then
            ableToCraftCount, Reagents.reagentRows[k], marketPrice, priceWithMats = CreateRow(reagent,ableToCraftCount,k,Reagents)
        else
            ableToCraftCount,Reagents.reagentRows[k], marketPrice, priceWithMats = Reagents.reagentRows[k].update(reagent,ableToCraftCount,reagent)
        end

        Reagents.reagentRows[k].frame:ClearAllPoints();
        
        if k == 1 then
            Reagents.reagentRows[k].frame:SetPoint("TOP", Reagents.frame, "TOP", 10, -35)
        else
            Reagents.reagentRows[k].frame:SetPoint("TOP", Reagents.reagentRows[k-1].frame, "BOTTOM", 0, -10)
        end
        Reagents.reagentRows[k].frame:Show()
        totalMarketPrice = totalMarketPrice + marketPrice 
        totalMarketPriceWithMats = totalMarketPriceWithMats + priceWithMats
    end
    Reagents.reagentsSummary:SetText("Resources For: |cFFFFC0CB"..floor(ableToCraftCount).."|r");
    
    Reagents.reagentsSummaryCostWithMats:SetText("Cost W Mats: "..GetCoinTextureString(totalMarketPriceWithMats));
    Reagents.reagentsSummaryCost:SetText("Cost W\\O Mats: "..GetCoinTextureString(totalMarketPrice));

    Reagents.reagentsSummaryCostWithMats:SetFont(font, 12);
    Reagents.reagentsSummaryCost:SetFont(font, 12);
    Reagents.reagentsSummary:SetFont(font, 12);
    
    
    Reagents.reagentsSummaryCost:Show()
    Reagents.reagentsSummary:Show()

    callback(true)

end


Reagents.frame = CreateFrame("Frame",nil,nil)
Reagents.reagentsSummary = Reagents.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
Reagents.reagentsSummaryCost = Reagents.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
Reagents.reagentsSummaryCostWithMats = Reagents.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");


Reagents.reagentsTitle = Reagents.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");

function Reagents:Create(parent,reagents)

    font = FilthyProfessions.font
    DB = FilthyProfessions.DB
    realm = FilthyProfessions.realmName
    Reagents.frame:SetScale(1)

    Reagents.frame:SetParent(parent.frame)
    Reagents.frame:SetWidth(parent.frame:GetWidth())
    Reagents.frame:SetHeight(parent.frame:GetHeight()-200-parent.info:GetHeight())
    Reagents.frame:SetPoint("TOP", parent.info, "BOTTOM", 0, 0)
    Reagents.reagentsTitle:SetPoint("TOPLEFT", Reagents.frame, "TOPLEFT", 10, -4);
    Reagents.reagentsTitle:SetText("|cFFE658EDReagents|r");
    Reagents.reagentsTitle:SetFont(font, 15, "OUTLINE");
    local line = Reagents.frame:CreateLine()
    line:SetColorTexture(0.9, 0.5, 0.93,0.7)
    line:SetThickness(2)
    line:SetStartPoint("TOPLEFT",10,-20)
    line:SetEndPoint("TOPRIGHT",-10,-20)
        Reagents.reagentsSummaryCost:SetScale(1)
    Reagents.reagentsSummaryCostWithMats:SetScale(1)
    Reagents.reagentsSummary:SetScale(1)
    Reagents.reagentsSummaryCost:SetPoint("BOTTOMLEFT",  Reagents.frame, "BOTTOMLEFT",10,2)

Reagents.reagentsSummary:SetPoint("BOTTOMLEFT", Reagents.reagentsSummaryCostWithMats, "TOPLEFT", 0, 0)
Reagents.reagentsSummaryCostWithMats:SetPoint("BOTTOMLEFT", Reagents.reagentsSummaryCost, "TOPLEFT",0,0)



    Reagents.update = function(_reagents,callback) 
        UpdateReagents(_reagents,function() 
            Reagents.frame:Show()
            callback(true)
        end)
    end
    return Reagents
end