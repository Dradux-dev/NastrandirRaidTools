local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidRecordingPlayer", function(self, parent, uid, name, class)
    local width = 300
    local height = 20

    local button = StdUi:NastrandirRaidTools_Roster_ClassButton(parent, uid, name, class)
    self:InitWidget(button)
    self:SetObjSize(button, width, height)

    function button:GetName()
        if button.uid then
            local Roster = NastrandirRaidTools:GetModule("Roster")
            return Roster:GetCharacterName(button.uid)
        else
            return button.title:GetText()
        end
    end

    function button:SetColumnContainer(container)
        button.column_container = container
    end

    function button:SetRoster(roster)
        button.roster = roster
    end

    function button:SetColumn(column)
        button.column = column
    end

    function button:Drag()
        local uiscale, scale = UIParent:GetScale(), button:GetEffectiveScale()
        local x, w = button:GetLeft(), button:GetWidth()
        local _, y = GetCursorPosition()

        if button.column then
            for index, child in ipairs(button.column.members) do
                if child.button then
                    child.button:ClearAllPoints()
                end
            end
        end

        button:SetMovable(true);
        button:StartMoving()
        button:ClearAllPoints()
        button.temp = {
            parent = button:GetParent(),
            strata = button:GetFrameStrata(),
            level = button:GetFrameLevel()
        }
        button:SetParent(UIParent)
        button:SetFrameStrata("TOOLTIP")
        button:SetFrameLevel(120)
        button:SetPoint("Center", UIParent, "BOTTOMLEFT", (x + w / 2) * scale / uiscale, y / uiscale)

        button:SetScript("OnUpdate", function()
            local child = button:GetDropTarget()

            if child and child ~= button.roster then
                for index, wrong_child in ipairs(button.column_container) do
                    if child ~= wrong_child then
                        wrong_child:SetDropTarget(false)
                    end
                end

                child:SetDropTarget(true)
            end
        end)
    end

    function button:Drop()
        button:StopMovingOrSizing()
        button:SetScript("OnUpdate", nil)

        for index, column in ipairs(button.column_container) do
            column:SetDropTarget(false)
        end

        local child = button:GetDropTarget()
        if child and child ~= button.roster then
            child:AddPlayer(button.uid)
            button.column:RemovePlayer(button.uid)
        else
            button.column:CreatePlayerButtons()
        end

        button:SetParent(button.temp.parent)
        button:SetFrameStrata(button.temp.strata)
        button:SetFrameLevel(button.temp.level)
    end

    function button:GetDropTarget()
        if button.column_container and button.roster then
            for index, child in ipairs(button.column_container) do
                if child ~= button.roster and child:IsMouseOver() then
                    return child
                end
            end
        end
    end

    function button:CreateMenu()
        local options = {}

        local function newOnEnter(itemFrame)
            button.context:CloseSubMenus();

            if itemFrame.childContext then
                itemFrame.childContext:ClearAllPoints();
                itemFrame.childContext:SetPoint('TOPLEFT', itemFrame, 'TOPRIGHT', 0, 0);
                itemFrame.childContext:Show();
            end

            itemFrame.text:SetTextColor(1, 0.431, 0.101, 1)
        end

        local function newOnLeave(itemFrame)
            itemFrame.text:SetTextColor(1, 1, 1, 1)
        end

        -- Edit
        table.insert(options, {
            title = "Edit",
            callback = function()
                button.context:CloseMenu()
                button:EditCharacter()
            end,
            events = {
                OnEnter = newOnEnter,
                OnLeave = newOnLeave
            }
        })

        local characters = button:GetCharacterList()
        button:RemoveCharacter(characters, button.uid)
        if table.getn(characters) >= 1 then
            table.sort(characters, function(a, b)
                return a.name < b.name
            end)

            table.insert(options, {
                isSeparator = true
            })

            for index, info in ipairs(characters) do
                table.insert(options, {
                    title = info.name,
                    callback = function()
                        button.context:CloseMenu()
                        button.column:lockButtons()
                        button.column:AddPlayer(info.uid)
                        button.column:RemovePlayer(button.uid)
                        button.column:unlockButtons()
                    end,
                    events = {
                        OnEnter = newOnEnter,
                        OnLeave = newOnLeave
                    }
                })
            end
        end

        table.insert(options, {
            isSeparator = true
        })

        table.insert(options, {
            title = "Close",
            callback = function()
                button.context:CloseMenu()
            end,
            events = {
                OnEnter = newOnEnter,
                OnLeave = newOnLeave
            }
        })

        return options
    end

    function button:EditCharacter()
        local Roster = NastrandirRaidTools:GetModule("Roster")
        Roster:ShowDetails(button.uid)
    end

    function button:GetCharacterList()
        local Roster = NastrandirRaidTools:GetModule("Roster")
        local characters = {}

        local main_uid = Roster:GetMainUID(button.uid)
        local main = Roster:GetCharacter(main_uid)
        table.insert(characters, {
            uid = main_uid,
            name = main.name
        })

        for index, character_uid in ipairs(main.alts) do
            local character = Roster:GetCharacter(character_uid)
            table.insert(characters, {
                uid = character_uid,
                name = character.name
            })
        end

        return characters
    end

    function button:RemoveCharacter(characters, uid)
        local pos = button:FindCharacter(characters, uid)

        if pos then
            table.remove(characters, pos)
        end
    end

    function button:FindCharacter(characters, uid)
        for index, info in ipairs(characters) do
            if info.uid == uid then
                return index
            end
        end
    end

    function button:CreateInfoText()
        if not button.uid then
            -- There is no information stored who this is
            return
        end

        local Roster = NastrandirRaidTools:GetModule("Roster")
        local name = Roster:GetCharacterName(button.uid)

        if UnitExists(name) then
            button:SetName(name .. " (*)")
        else
            button:SetName(name)
        end
    end

    button:SetScript("OnClick", function(frame, mouseButton)
        if mouseButton == "RightButton" then
            if not button.context then
                button.context = StdUi:ContextMenu(button, button:CreateMenu())
            else
                button.context:DrawOptions(button:CreateMenu())
            end

            StdUi:GlueBelow(button.context, button, 10, button:GetHeight() / 2, "LEFT")
            button.context:SetFrameStrata("TOOLTIP")
            button.context:Show()
        end
    end)

    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function()
        button:Drag()
    end)

    button:SetScript("OnDragStop", function()
        button:Drop()
    end)

    button:RegisterEvent("GROUP_ROSTER_UPDATE")
    button:SetScript("OnEvent", function(event)
        if event == "GROUP_ROSTER_UPDATE" then
            button:CreateInfoText()
        end
    end)

    button:SetUID(uid)
    button:SetName(name)
    button:SetClass(class)

    return button
end)