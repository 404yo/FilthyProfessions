local Item = {}
Item.items = {}
local FilthyProfessions = _G.FilthyProfessions
local GUI = FilthyProfessions.GUI
FilthyProfessions.Item = Item
local font

local tonumber, match = tonumber, string.match
local gPinnedItems = {}

local function pinItem(parent, itemID, profession)
    local itemID = itemID
    local profession = profession
    if not gPinnedItems[itemID] then
        Item.items[itemID].pinn:Show()
        gPinnedItems[itemID] = profession
    else
        Item.items[itemID].pinn:Hide()
        gPinnedItems[itemID] = nil
    end
end

local function Item_Onclick(parent, button, down)
    if button == "RightButton" then
        pinItem(parent, parent.itemID, parent.profession)
    elseif button == "LeftButton" then
        if not FilthyProfessions.DetailWindow.frame then
            FilthyProfessions.DetailWindow:Create(parent)
        end
        FilthyProfessions.DetailWindow.update(parent)
    end
end

local function OnItemLeave(parent)
    GameTooltip:Hide()
end

local function OnItemEnter(parent)
    GameTooltip:SetOwner(parent, "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    if parent.profession == "Enchanting" then
        GameTooltip:SetHyperlink("spell:" .. parent.itemID)
    else
        GameTooltip:SetHyperlink(parent.itemLink)
    end
    GameTooltip:Show()
end

local function SetPoint(current, relativePoint, first)
    
    current.frame:Hide()
    current.icon:Hide()
    current.pinn:Hide()
    current.text:Hide()
    current.lvltext:Hide()
    current.professionText:Hide()
    
    if first then
        current.frame:SetPoint("TOP", GUI.UI.content, "TOP", 15, -2)
    else
        current.frame:SetPoint("TOP", relativePoint.frame, "BOTTOM", 0, 0)
    end
    
    current.icon:ClearAllPoints()
    current.pinn:ClearAllPoints()
    current.text:ClearAllPoints()
    current.lvltext:ClearAllPoints()
    current.professionText:ClearAllPoints()
    
    current.icon:SetPoint("LEFT", current.frame, "LEFT", 5, 0)
    current.pinn:SetPoint("RIGHT", current.icon, "LEFT", -1, 0)
    current.text:SetPoint("LEFT", current.icon, "RIGHT", 4, 0)
    current.lvltext:SetPoint("CENTER", current.frame, "RIGHT", -25, 0)
    current.professionText:SetPoint("CENTER", current.frame, "RIGHT", -80, 0)
    
    
    if gPinnedItems[current.frame.itemID] ~= nil then
        current.pinn:Show()
    else
        current.pinn:Hide()
    end
    
    current.frame:Show()
    current.icon:Show()
    current.text:Show()
    current.lvltext:Show()
    current.professionText:Show()
end


function Item:Create(frameName, profession, parent, item)
    gPinnedItems = FilthyProfessions.gPinnedItems
    font = FilthyProfessions.font
    local itemLink = item[1]
    local itemTexture = item[3]
    local itemID = item[4]
    local itemLevel = item[2]
    local players = item[6]
    local reagents = item[5]
    
    
    Item.items[itemID] = Item.items[itemID] or {}
    Item.items[itemID].frame = CreateFrame("Button", frameName, parent)
    Item.items[itemID].frame:SetScale(1)
    Item.items[itemID].frame:SetWidth((parent:GetWidth() - 4))
    Item.items[itemID].frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    Item.items[itemID].frame:SetHeight((parent:GetHeight() - 4) / 22)
    Item.items[itemID].frame:SetPoint("TOP", parent, "TOP", 15, -2)
    Item.items[itemID].frame.profession = profession
    Item.items[itemID].frame.itemLink = itemLink
    Item.items[itemID].frame.itemID = itemID
    Item.items[itemID].frame.itemTexture = itemTexture
    Item.items[itemID].frame.reagents = reagents
    Item.items[itemID].frame.players = players
    Item.items[itemID].frame.itemLevel = itemLevel
    if profession ~= "Enchanting" then
        Item.items[itemID].itemName = match(itemLink, "%[(.+)%]")
    else
        Item.items[itemID].itemName = itemLink
    end

    Item.items[itemID].icon = Item.items[itemID].frame:CreateTexture(nil)
    Item.items[itemID].icon:SetPoint("LEFT", Item.items[itemID].frame, "LEFT", 10, 0)
    Item.items[itemID].icon:SetHeight(20)
    Item.items[itemID].icon:SetWidth(20)
    Item.items[itemID].icon:SetTexture(itemTexture)

    Item.items[itemID].pinn = Item.items[itemID].frame:CreateTexture("pinnItem" .. itemID)
    Item.items[itemID].pinn:SetPoint("RIGHT", Item.items[itemID].icon, "LEFT", -5, 0)
    Item.items[itemID].pinn:SetHeight(20)
    Item.items[itemID].pinn:SetWidth(20)
    Item.items[itemID].pinn:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")

    Item.items[itemID].text = Item.items[itemID].frame:CreateFontString(Item.items[itemID].frame, "OVERLAY", "GAMETOOLTIPTEXT")
    Item.items[itemID].text:SetPoint("LEFT", Item.items[itemID].icon, "RIGHT", 10, 0)
    Item.items[itemID].text:SetText(string.gsub(itemLink, "Enchant ", ""))
    Item.items[itemID].text:SetFont(font, 12, "OUTLINE")
    
    Item.items[itemID].lvltext = Item.items[itemID].frame:CreateFontString(Item.items[itemID].frame, "OVERLAY", "GAMETOOLTIPTEXT")
    Item.items[itemID].lvltext:SetPoint("CENTER", Item.items[itemID].frame, "RIGHT", -25, 0)
    
    Item.items[itemID].lvltext:SetText(itemLevel)
    Item.items[itemID].lvltext:SetFont(font, 10, "OUTLINE")
    
    
    local professionText
    if profession == "Black Smithing" then
        professionText = "|cFF2B3A67BS|r"
    end
    if profession == "Tailoring" then
        professionText = "|cFFF2BEFC" .. profession .. "|r"
    end
    
    if profession == "Engineering" then
        professionText = "|cFFFF9B71" .. profession .. "|r"
    end
    
    if profession == "First Aid" then
        professionText = "|cFFE84855" .. profession .. "|r"
    end
    
    if profession == "Enchanting" then
        professionText = "|cFFFFFD82" .. profession .. "|r"
    end
    
    if profession == "Cooking" then
        professionText = "|cFFffb92d" .. profession .. "|r"
    end
    
    if profession == "Alchemy" then
        professionText = "|cFF54c45b" .. profession .. "|r"
    end
    
    if profession == "Leather Working" then
        professionText = "|cFFB56B45LW|r"
    end
    
    Item.items[itemID].professionText = Item.items[itemID].frame:CreateFontString(Item.items[itemID].frame, "OVERLAY", "GAMETOOLTIPTEXT")
    Item.items[itemID].professionText:SetText(professionText)
    Item.items[itemID].professionText:SetFont(font, 12, "OUTLINE")
    Item.items[itemID].frame:RegisterForClicks("AnyDown")
    Item.items[itemID].frame:SetScript("OnClick", Item_Onclick)
    Item.items[itemID].frame:SetScript("OnEnter", OnItemEnter)
    Item.items[itemID].frame:SetScript("OnLeave", OnItemLeave)
    
    
    Item.items[itemID].setPoint = function(_self, relativePoint, first)
        SetPoint(_self, relativePoint, first)
    end
    Item.items[itemID].frame:Show()
end
