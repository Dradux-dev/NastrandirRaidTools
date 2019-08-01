local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidRecordingPlayer", function(self, parent, uid, name, class)
    local width = 300
    local height = 20

    local button = StdUi:NastrandirRaidTools_Roster_ClassButton(parent, uid, name, class)
    self:InitWidget(button)
    self:SetObjSize(button, width, height)

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

    function button:CreateAddableAltsMenu()
        local options = {}

        local CurrentGroupRoster = NastrandirRaidTools:GetModule("CurrentGroupRoster")
        for name in CurrentGroupRoster:IterateUnknown() do
            local class = select(2, UnitClass(name))
            local role = UnitGroupRolesAssigned(name)
            local internal_role = NastrandirRaidTools.class_roles[class][role]
            local roles = NastrandirRaidTools.class_roles[class][NastrandirRaidTools.role_types.all]
            local role_options

            if #roles > 1 then
                role_options = {}

                local dict = {
                    [NastrandirRaidTools.role_types.tank] = "Tank",
                    [NastrandirRaidTools.role_types.melee] = "Melee",
                    [NastrandirRaidTools.role_types.ranged] = "Ranged",
                    [NastrandirRaidTools.role_types.heal] = "Heal"
                }

                for _, role in ipairs(roles) do
                    table.insert(role_options, {
                        title = dict[role],
                        callback = function()
                            local Roster = NastrandirRaidTools:GetModule("Roster")
                            Roster:AddMember(class, role, name, button.uid, true)
                            button.context:CloseMenu()
                        end
                    })
                end
            end

            table.insert(options, {
                title = name,
                callback = function(entry)
                    local skipDetails = #roles == 1
                    local Roster = NastrandirRaidTools:GetModule("Roster")
                    Roster:AddMember(class, internal_role, name, button.uid, skipDetails)
                    button.context:CloseMenu()
                end,
                children = role_options
            })
        end

        return options
    end

    function button:CreateMenu()
        local options = {}

        -- Edit
        table.insert(options, {
            title = "Edit",
            callback = function()
                button.context:CloseMenu()
                button:EditCharacter()
            end
        })

        local characters = button:GetCharacterList()
        button:RemoveCharacter(characters, button.uid)
        local alts_options = button:CreateAddableAltsMenu()

        if (table.getn(characters) >= 1 and button.column:AreAltsAllowed()) or #alts_options >= 1 then
            table.insert(options, {
                isSeparator = true
            })
        end

        if table.getn(characters) >= 1 and button.column:AreAltsAllowed() then
            table.sort(characters, function(a, b)
                return a.name < b.name
            end)

            for index, info in ipairs(characters) do
                table.insert(options, {
                    title = info.name,
                    callback = function(entry)
                        local Roster = NastrandirRaidTools:GetModule("Roster")
                        local uid = Roster:GetCharacterByName(entry.text:GetText())

                        button.context:CloseMenu()
                        button.column:lockButtons()
                        button.column:AddPlayer(uid)
                        button.column:RemovePlayer(button.uid)
                        button.column:unlockButtons()

                        print(info.name, info.uid)
                    end
                })
            end
        end

        if #alts_options >= 1 then
            table.insert(options, {
                title = "Add Alt",
                children = alts_options
            })
        end

        table.insert(options, {
            isSeparator = true
        })

        table.insert(options, {
            title = "Close",
            callback = function()
                button.context:CloseMenu()
            end
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
        local db = NastrandirRaidTools:GetModuleDB("Attendance")
        local name = Roster:GetCharacterName(button.uid)


        local CurrentGroupRoster = NastrandirRaidTools:GetModule("CurrentGroupRoster")
        local entry = CurrentGroupRoster:GetByUID(button.uid)
        if entry then
            if db.defaults.groupIndicator == "PREFIX" then
                button:SetName(string.format("[%d] %s", entry.subgroup, name))
            elseif db.defaults.groupIndicator == "SUFFIX" then
                button:SetName(string.format("%s [%d]", name, entry.subgroup))
            else
                button:SetName(name)
            end

        else
            entry = CurrentGroupRoster:GetAlt(button.uid)
            if entry then
                if db.defaults.groupIndicator == "PREFIX" then
                    button:SetName(string.format("[A,%d] %s", entry.subgroup, name))
                elseif db.defaults.groupIndicator == "SUFFIX" then
                    button:SetName(string.format("%s [A,%d]", name, entry.subgroup))
                else
                    button:SetName(name)
                end
            else
                button:SetName(name)
            end
        end
    end

    function button:CloseContextMenu()
        if button.context then
            button.context:CloseMenu()
        end
    end

    function button:CloseAllContextMenus()
        for _, column in ipairs(button.column_container) do
            column:CloseContextMenus()
        end

        self.roster:CloseContextMenus()
    end

    button:SetScript("OnShow", function()
        button:CreateInfoText()
    end)

    button:SetScript("OnClick", function(frame, mouseButton)
        ViragDevTool_AddData(button:IsShown(), "Is Shown")
        if button:IsShown() then
            if mouseButton == "RightButton" then
                if not button.context then
                    button.context = StdUi:DynamicContextMenu(button, button:CreateMenu())
                    button.context:SetHighlightTextColor(1, 0.431, 0.101, 1)
                else
                    button.context:DrawOptions(button:CreateMenu())
                end

                button:CloseAllContextMenus()

                button.context:ClearAllPoints()
                StdUi:GlueBelow(button.context, button, 10, button:GetHeight() / 2, "LEFT")
                button.context:SetFrameStrata("TOOLTIP")
                button.context:Show()
            end
        end
    end)

    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function()
        button:Drag()
    end)

    button:SetScript("OnDragStop", function()
        button:Drop()
    end)

    local CurrentGroupRoster = NastrandirRaidTools:GetModule("CurrentGroupRoster")
    CurrentGroupRoster:RegisterListener(button, function()
        button:CreateInfoText()
    end)

    button:SetUID(uid)
    button:SetName(name)
    button:SetClass(class)
    button:CreateInfoText()

    return button
end)