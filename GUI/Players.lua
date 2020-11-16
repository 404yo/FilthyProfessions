local Players = {}

local FilthyProfessions = _G.FilthyProfessions
FilthyProfessions.Players = Players
local font 
local  s_sub, next = string.sub, next
local gPlayersDB = {}

Players.frame = CreateFrame("Frame", "PLAYER_FRAME",nil)
Players.frame:SetScale(1)
Players.playersTitles = Players.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");


Players.players = {}
local function Update(profession,itemID,callback)
    gPlayersDB = FilthyProfessions.gPlayersDB

    local professions = gPlayersDB[profession] or {}
    local players = professions[itemID] or {}
    local first = true
    local multiplier = 0

    for k,v in next, Players.players do Players.players[k]:Hide() end

    for id, name in next, players do
        local truncName = s_sub(name,1,10)

        if Players.players[id] == nil then
            Players.players[id] = CreateFrame("Button", nil, Players.frame)
        end 
        if Players.players[id].frameText == nil then
            Players.players[id].frameText = Players.players[id]:CreateFontString(Players.players[id], "OVERLAY", "GAMETOOLTIPTEXT")
        end

        Players.players[id]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        Players.players[id]:SetWidth(85)
        Players.players[id]:SetHeight(10)
        Players.players[id].frameText:SetText(truncName)
        Players.players[id].frameText:SetFont(font, 12, "OUTLINE")
        Players.players[id].frameText:ClearAllPoints()
        Players.players[id]:ClearAllPoints()
        
        if id % 13 == 0 then 
            multiplier = multiplier + 85
            first = true
        end
        if first then 
            Players.players[id]:SetPoint("TOPLEFT",Players.frame,"TOPLEFT",10 + multiplier, -13)
            Players.players[id].frameText:SetPoint("TOPLEFT",Players.frame,"TOPLEFT",10 + multiplier, -13)
            first = false
        else
            Players.players[id]:SetPoint("TOPLEFT",Players.players[id-1],"BOTTOMLEFT",0, -3)
            Players.players[id].frameText:SetPoint("TOPLEFT",Players.players[id-1],"BOTTOMLEFT",0, -3)
        end

        Players.players[id]:Show()

    end
    callback()

end

function Players:Create(parent,reagents,infoIconFrame)
    
    font = FilthyProfessions.font
    Players.frame:SetParent(parent.frame)
    Players.frame:SetWidth(reagents.frame:GetWidth())
    Players.frame:SetHeight(parent.frame:GetHeight() - reagents.frame:GetHeight() - infoIconFrame:GetHeight())
    Players.frame:ClearAllPoints()
    Players.frame:SetPoint("TOP",  reagents.frame, "BOTTOM", 0, -5)

    Players.playersTitles:ClearAllPoints()
    Players.playersTitles:SetPoint("LEFT", Players.frame, "TOPLEFT", 9, 0);
    Players.playersTitles:SetText("|cFF37FDFCPlayers|r");
    Players.playersTitles:SetFont(font, 15, "OUTLINE");
 
    local line = Players.frame:CreateLine()
    line:SetColorTexture(0.23, 0.5, 0.69,0.7)
    line:SetThickness(2)
    line:SetStartPoint("TOPLEFT",10,-10)
    line:SetEndPoint("TOPRIGHT",-10,-10)

    Players.update = function(profession,itemID,callback) 
        Update(profession,itemID,function() callback(true) end)
    end

    return Players

end


