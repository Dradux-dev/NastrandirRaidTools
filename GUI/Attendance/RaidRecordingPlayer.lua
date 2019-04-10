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
        local uiscale, scale = UIParent:GetScale(), button.frame:GetEffectiveScale()
        local x, w = button.frame:GetLeft(), button.frame:GetWidth()
        local _, y = GetCursorPosition()

        if button.column then
            for index, child in ipairs(button.column.scroll_frame.children) do
                child.frame:ClearAllPoints()
            end
        end

        button.frame:SetMovable(true);
        button.frame:StartMoving()
        button.frame:ClearAllPoints()
        button.frame.temp = {
            parent = button.frame:GetParent(),
            strata = button.frame:GetFrameStrata(),
            level = button.frame:GetFrameLevel()
        }
        button.frame:SetParent(UIParent)
        button.frame:SetFrameStrata("TOOLTIP")
        button.frame:SetFrameLevel(120)
        button.frame:SetPoint("Center", UIParent, "BOTTOMLEFT", (x + w / 2) * scale / uiscale, y / uiscale)

        button.frame:SetScript("OnUpdate", function()
            local child = button:GetDropTarget()

            if child and child ~= button.roster then
                for index, wrong_child in ipairs(button.column_container.children) do
                    if child ~= wrong_child then
                        wrong_child:SetDropTarget(false)
                    end
                end

                child:SetDropTarget(true)
            end
        end)
    end

    function button:Drop()
        button.frame:StopMovingOrSizing()
        button.frame:SetScript("OnUpdate", nil)

        for index, column in ipairs(button.column_container.children) do
            column:SetDropTarget(false)
        end

        local child = button:GetDropTarget()
        if child and child ~= button.roster then
            child:AddPlayer(button.uid)
            button.column:RemovePlayer(button.uid)
        else
            button.column:CreatePlayerButtons()
        end
    end

    function button:GetDropTarget()
        if button.column_container and button.roster then
            for index, child in ipairs(button.column_container.children) do
                if child ~= button.roster and child.frame:IsMouseOver() then
                    return child
                end
            end
        end
    end

    function button:CreateMenu()
        button.menu = {}

        table.insert(button.menu, {
            text = "Edit",
            notCheckable = 1,
            func = function()
                button:EditCharacter()
            end
        })

        local characters = button:GetCharacterList()
        button:RemoveCharacter(characters, button.uid)
        if table.getn(characters) >= 1 then
            table.sort(characters, function(a, b)
                return a.name < b.name
            end)

            table.insert(button.menu, {
                text = " ",
                notCheckable = 1,
                notClickable = 1,
                func = nil
            })

            for index, info in ipairs(characters) do
                table.insert(button.menu, {
                    text = info.name,
                    notCheckable = 1,
                    func = function()
                        button.column:lockButtons()
                        button.column:AddPlayer(info.uid)
                        button.column:RemovePlayer(button.uid)
                        button.column:unlockButtons()
                    end
                })
            end

            table.insert(button.menu, {
                text = " ",
                notCheckable = 1,
                notClickable = 1,
                func = nil
            })
        end

        table.insert(button.menu, {
            text = "Close",
            notCheckable = 1,
            func = function()
                button.column:GetDropDown():Hide()
            end
        })
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


    button:SetScript("OnClick", function(button, mouseButton)
        if mouseButton == "RightButton" then
            L_EasyMenu(button.menu, NastrandirRaidTools:GetOptionsDropDown(), "cursor", 0, -15, "MENU")
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