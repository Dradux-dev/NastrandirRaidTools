local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Profiles", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 220

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local title = StdUi:Label(widget, "Profiles", 18, "GameFontNormal", widget:GetWidth() - 20, 24)
    widget.title = title
    StdUi:GlueTop(title, widget, 10, -20, "LEFT")

    local current = StdUi:Dropdown(widget, 350, 24)
    widget.current = current
    StdUi:GlueBelow(current, title, 0, -30, "LEFT")

    local currentLabel = StdUi:Label(widget, "Current")
    widget.currentLabel = currentLabel
    StdUi:GlueAbove(currentLabel, current, 0, 5, "LEFT")

    local copyFrom = StdUi:Dropdown(widget, 350, 24)
    widget.copyFrom = copyFrom
    StdUi:GlueRight(copyFrom, current, 10, 0)

    local copyFromLabel = StdUi:Label(widget, "Copy From")
    widget.copyFromLabel = copyFromLabel
    StdUi:GlueAbove(copyFromLabel, copyFrom, 0, 5, "LEFT")

    local delete = StdUi:Dropdown(widget, 710, 24)
    widget.delete = delete
    StdUi:GlueBelow(delete, current, 0, -30, "LEFT")

    local deleteLabel = StdUi:Label(widget, "Delete")
    widget.deleteLabel = deleteLabel
    StdUi:GlueAbove(deleteLabel, delete, 0, 5, "LEFT")

    local new = StdUi:SimpleEditBox(widget, 470, 24, "")
    widget.new = new
    StdUi:GlueBelow(new, delete, 0, -30, "LEFT")

    local newLabel = StdUi:Label(widget, "Create New Profile")
    widget.newLabel = newLabel
    StdUi:GlueAbove(newLabel, new, 0, 5, "LEFT")

    local create = StdUi:Button(widget, 230, 24, "Create")
    widget.create = create
    StdUi:GlueRight(create, new, 10, 0)

    function widget:GetCurrentProfile()
        local db = NastrandirRaidTools:GetDB()
        return db:GetCurrentProfile()
    end

    function widget:GetProfileList(includeCurrent)
        local db = NastrandirRaidTools:GetDB()

        local profiles = db:GetProfiles()

        local FindCurrentProfile = function()
            local currentProfile = db:GetCurrentProfile()
            for pos, profileName in ipairs(profiles) do
                if profileName == currentProfile then
                    return pos
                end
            end
        end

        local pos = FindCurrentProfile()
        if not includeCurrent and pos then
            table.remove(profiles, pos)
        end

        table.sort(profiles)

        local profile_list = {}
        for index, profileName in ipairs(profiles) do
            table.insert(profile_list, {
                text = profileName,
                value = profileName
            })
        end

        return profile_list
    end

    function widget:AskDelete(f)
        if not widget.ask then
            local ask = StdUi:Window(parent, "Are you sure?", 360, 140)
            widget.ask = ask

            local yes = StdUi:Button(ask, 80, 24, "Yes")
            ask.yes = yes
            yes:SetPoint("RIGHT", ask, "CENTER", -5, 0)
            yes:SetScript("OnClick", function()
                f.yes()
                widget.ask:Hide()
            end)

            local no = StdUi:Button(ask, 80, 24, "No")
            ask.no = no
            no:SetPoint("LEFT", ask, "CENTER", 5, 0)
            no:SetScript("OnClick", function()
                f.no()
                widget.ask:Hide()
            end)

            widget.ask:Hide()
        end

        widget.ask:SetPoint("CENTER")
        widget.ask:Show()
    end

    widget:SetScript("OnShow", function()
        current:SetOptions(widget:GetProfileList(true))
        current:SetValue(widget:GetCurrentProfile())

        copyFrom:SetOptions(widget:GetProfileList())
        copyFrom:SetPlaceholder("-- Select --")
        copyFrom:SetText(copyFrom.placeholder)


        delete:SetOptions(widget:GetProfileList())
        delete:SetPlaceholder("-- Select --")
        delete:SetText(delete.placeholder)

        new:SetText("")
    end)

    create:SetScript("OnClick", function()
        local name = widget.new:GetText()
        if name == "" then
            return
        end

        widget.new:SetText("")
        NastrandirRaidTools:GetDB():SetProfile(name)
        NastrandirRaidTools:ShowProfiles()
    end)

    current.OnValueChanged = function(self, value)
        NastrandirRaidTools:GetDB():SetProfile(value)
        NastrandirRaidTools:ShowProfiles()
    end

    copyFrom.OnValueChanged = function(self, value)
        NastrandirRaidTools:GetDB():CopyProfile(value)
            NastrandirRaidTools:ShowProfiles()
        local db = NastrandirRaidTools:GetDB()
        print(NastrandirRaidTools:GetName().. ": Copied profile " .. value .. " into " .. db:GetCurrentProfile())
    end

    delete.OnValueChanged = function(self, value)
        NastrandirRaidTools:GetUserPermission(parent, {
            callbackYes = function()
                NastrandirRaidTools:GetDB():DeleteProfile(value)
                NastrandirRaidTools:ShowProfiles()
            end,
            callbackNo = function()
                NastrandirRaidTools:ShowProfiles()
            end

        })
    end

    return widget
end)