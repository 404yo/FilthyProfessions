local Players = {}

local FilthyProfessions = _G.FilthyProfessions
FilthyProfessions.Players = Players
local font 
local  s_sub, next = string.sub, next

Players.players = {}
Players.frame = CreateFrame("Frame", "PLAYER_FRAME",nil)
Players.frame:SetScale(1)
Players.playersTitles = Players.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");

local function Update(players)
  
    local first = true
    local multiplier = 0

    for k,v in next, Players.players do Players.players[k]:Hide() end
    local _players = {}
    local i = 1
    for k, v in next, players do
        local name = s_sub(k,1,10)

        if Players.players[i] == nil then
            Players.players[i] = CreateFrame("Button", nil, Players.frame)
        end 
        if Players.players[i].frameText == nil then
            Players.players[i].frameText = Players.players[i]:CreateFontString(Players.players[i], "OVERLAY", "GAMETOOLTIPTEXT")
        end

        Players.players[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        Players.players[i]:SetWidth(85)
        Players.players[i]:SetHeight(10)
        Players.players[i].frameText:SetText(name)
        Players.players[i].frameText:SetFont(font, 12, "OUTLINE")
        Players.players[i].frameText:ClearAllPoints()
        Players.players[i]:ClearAllPoints()

        if first then 
            Players.players[i]:SetPoint("TOPLEFT",Players.frame,"TOPLEFT",10 + multiplier, -13)
            Players.players[i].frameText:SetPoint("TOPLEFT",Players.frame,"TOPLEFT",10 + multiplier, -13)
            first = false
        else
            Players.players[i]:SetPoint("TOPLEFT",Players.players[i-1],"BOTTOMLEFT",0, -3)
            Players.players[i].frameText:SetPoint("TOPLEFT",Players.players[i-1],"BOTTOMLEFT",0, -3)
        end
        if i % 13 == 0 then 
            multiplier = multiplier + 85
            first = true
        end
        Players.players[i]:Show()

        i = i + 1
    end
end

function Players:Create(parent,itemID,reagents,playersList)
    font = FilthyProfessions.font
    Players.frame:SetParent(parent.frame)
    Players.frame:SetWidth( reagents.frame:GetWidth())
    Players.frame:SetHeight(reagents.frame:GetHeight()+30)
    Players.frame:ClearAllPoints()
    Players.frame:SetPoint("BOTTOM",  parent.frame, "BOTTOM", 0, 0)

    Players.playersTitles:ClearAllPoints()
    Players.playersTitles:SetPoint("LEFT", Players.frame, "TOPLEFT", 9, 0);
    Players.playersTitles:SetText("|cFF37FDFCPlayers|r");
    Players.playersTitles:SetFont(font, 15, "OUTLINE");
 
    local line = Players.frame:CreateLine()
    line:SetColorTexture(0.23, 0.5, 0.69,0.7)
    line:SetThickness(2)
    line:SetStartPoint("TOPLEFT",10,-10)
    line:SetEndPoint("TOPRIGHT",-10,-10)

    Players.update = function() 
        Update(playersList)
    end

    Update(playersList)
    return Players

end


