local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Roster_Details", function(self, parent)
    local Roster = NastrandirRaidTools:GetModule("Roster")
    local width = parent:GetWidth() or 600
    local height = parent:GetHeight() or 400

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local title = StdUi:Label(widget, "Details", 18, "GameFontNormal", widget:GetWidth() - 20, 24)
    widget.title = title
    StdUi:GlueTop(title, widget, 10, -20, "LEFT")

    local base = StdUi:PanelWithTitle(widget, widget:GetWidth() - 215, 200, "Base data")
    widget.base = base
    StdUi:GlueBelow(base, title, 0, -30, "LEFT")

    local name = StdUi:SimpleEditBox(base, base:GetWidth() - 20, 24, "")
    base.name = name
    StdUi:AddLabel(base, name, "Name", "TOP")
    StdUi:GlueTop(name, base, 10, -60, "LEFT")

    local role = StdUi:Dropdown(base, 0.48 * name:GetWidth(), 24, {
        {
            text = "Tank",
            value = "TANK"
        },
        {
            text = "Heal",
            value = "HEAL"
        },
        {
            text = "Ranged",
            value = "RANGED"
        },
        {
            text = "Melee",
            value = "MELEE"
        }
    })
    base.role = role
    StdUi:AddLabel(base, role, "Role", "TOP")
    StdUi:GlueBelow(role, name, 0, -30, "LEFT")

    local class = StdUi:Dropdown(base, 0.48 * name:GetWidth(), 24, {})
    base.class = class
    StdUi:AddLabel(base, class, "Class", "TOP")
    StdUi:GlueRight(class, role, 0.04 * name:GetWidth(), 0)

    local raidmember = StdUi:Checkbox(base, "Is raid member", 0.75 * name:GetWidth(), 24)
    base.raidmember = raidmember
    raidmember:SetChecked(false)
    StdUi:GlueBelow(raidmember, role, 0, -20, "LEFT")

    local save = StdUi:Button(base, 0.2 * name:GetWidth(), 24, "Save")
    base.save = save
    StdUi:GlueBelow(save, class, 0, -20, "RIGHT")

    local actions = StdUi:PanelWithTitle(widget, widget:GetWidth() - 215, 100, "Actions")
    widget.actions = actions
    StdUi:GlueBelow(actions, base, 0, -20, "LEFT")

    local mains = StdUi:Dropdown(actions, 0.48 * actions:GetWidth(), 24, {})
    actions.mains = mains
    local characters = Roster:GetMainCharacters()
    local options = {}
    for mainUID, mainName in pairs(characters) do
        table.insert(options, {
            text = mainName,
            value = mainUID
        })
    end
    table.sort(options, function(a, b)
        return a.text < b.text
    end)
    mains:SetOptions(options)
    StdUi:AddLabel(actions, mains, "Make alt of", "TOP")
    StdUi:GlueTop(mains, actions, 10, -60, "LEFT")

    local delete  = StdUi:Button(actions, 0.24 * actions:GetWidth(), 24, "Delete")
    actions.delete = delete
    StdUi:GlueRight(delete, mains, 0.01 * actions:GetWidth(), 0)

    local makemain = StdUi:Button(actions, 0.24 * actions:GetWidth(), 24, "Make main")
    actions.makemain = makemain
    StdUi:GlueRight(makemain, delete, 0.01 * actions:GetWidth(), 0)

    local buttonMain = StdUi:NastrandirRaidTools_Roster_ClassButton(widget, "fake-uid", "Main Character", "MONK")
    widget.buttonMain = buttonMain
    buttonMain:SetWidth(180)
    StdUi:GlueBelow(buttonMain, title, 0, -30, "RIGHT")

    local alts = StdUi:NastrandirRaidTools_Roster_ColumnFrame(widget, 180, 380)
    widget.alts = alts
    alts:SetName("Alts")
    alts:HideAddButton()
    StdUi:GlueBelow(alts, buttonMain, 0, -20, "RIGHT")

    function widget:GetOptionsForRole(role)
        local classes = NastrandirRaidTools:GetAllowedClasses(role)
        local allowedClasses = {}
        for classID, className in pairs(classes) do
            table.insert(allowedClasses, {
                text = className,
                value = classID
            })
        end
        table.sort(allowedClasses, function(a, b)
            return a.text < b.text
        end)

        return allowedClasses
    end

    function widget:LoadData(uid)
        local Roster = NastrandirRaidTools:GetModule("Roster")
        local member = Roster:GetCharacter(uid)

        -- Load base informations
        widget.uid = uid
        widget.base.name:SetText(member.name)
        widget.base.role:SetValue(member.role)
        widget.base.class:SetOptions(widget:GetOptionsForRole(member.role))
        widget.base.class:SetValue(member.class)
        widget.base.raidmember:SetChecked(member.raidmember)

        -- Setup main character button
        local main = member
        if member.main then
            main = Roster:GetCharacter(member.main)
        end

        widget.buttonMain:SetName(main.name)
        widget.buttonMain:SetClass(main.class)
        widget.buttonMain:SetUID(member.main or uid)

        -- Load Alts
        widget.alts:ReleaseMember()
        for alt_uid, alt in pairs(Roster:GetAlts(member.main or uid)) do
            widget.alts:AddMember({
                uid = alt_uid,
                name = alt.name,
                class = alt.class
            })
        end

        widget.alts:Sort()
    end

    function widget:Save()
        local Roster = NastrandirRaidTools:GetModule("Roster")

        local character = Roster:GetCharacter(widget.uid)

        character.name = widget.base.name:GetText()
        character.role = widget.base.role:GetValue()
        character.class = widget.base.class:GetValue()
        character.raidmember = widget.base.raidmember:GetChecked()

        Roster:ShowDetails(widget.uid)
    end

    function widget:MakeAltOf(mainUID)
        local Roster = NastrandirRaidTools:GetModule("Roster")
        local character = Roster:GetCharacter(widget.uid)
        local main = Roster:GetCharacter(mainUID)

        if not main.alts then
            main.alts = {}
        end

        if character.alts then
            for index, alt_uid in pairs(character.alts) do
                if alt_uid ~= mainUID then
                    local alt = Roster:GetCharacter(alt_uid)
                    alt.alts = nil
                    alt.main = mainUID

                    table.insert(main.alts, alt_uid)
                end
            end
        end

        character.alts = nil
        character.main = mainUID
        table.insert(main.alts, widget.uid)
        main.main = nil

        Roster:ShowDetails(widget.uid)
    end

    function widget:MakeMain()
        local Roster = NastrandirRaidTools:GetModule("Roster")
        local character = Roster:GetCharacter(widget.uid)

        if character.main then
            local main = Roster:GetCharacter(character.main)
            local pos = NastrandirRaidTools:FindInTable(main.alts, widget.uid)
            if pos then
                table.remove(main.alts, pos)
            end

            character.main = nil
            character.alts = {}
        end

        Roster:ShowDetails(widget.uid)
    end

    function widget:Delete()
        local Roster = NastrandirRaidTools:GetModule("Roster")

        local character = Roster:GetCharacter(widget.uid)
        if character.alts then
            for alt_uid, alt in pairs(character.alts) do
                Roster:DeleteCharacter(alt_uid)
            end
        end

        Roster:DeleteCharacter(widget.uid)

        if character.main then
            Roster:ShowDetails(character.main)
        else
            Roster:ShowCurrentRoster()
        end
    end

    role.OnValueChanged = function(self, value)
        local options = widget:GetOptionsForRole(value)
        widget.base.class:SetOptions(options)
        widget.base.class:SetValue(options[1].value, options[1].text)
    end

    save:SetScript("OnClick", function()
        widget:Save()
    end)

    mains.OnValueChanged = function(self, value)
        widget:MakeAltOf(value)
    end

    delete:SetScript("OnClick", function()
        NastrandirRaidTools:GetUserPermission(widget, {
            callbackYes = function()
                widget:Delete()
            end
        })

    end)

    makemain:SetScript("OnClick", function()
        widget:MakeMain()
    end)

    return widget
end)