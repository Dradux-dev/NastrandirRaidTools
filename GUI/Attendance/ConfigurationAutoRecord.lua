local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationAutoRecord", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local group_state = StdUi:Dropdown(widget, width - 20, 24, {})
    widget.group_state = group_state
    StdUi:AddLabel(widget, group_state, "In group", "TOP")
    StdUi:GlueTop(group_state, widget, 10, -30, "LEFT")

    local mythic = StdUi:Checkbox(widget, "|cFFFFFF00Mythic only:|r Consider group 5 - 8 as not in the current group", width - 20, 24)
    widget.mythic = mythic
    StdUi:GlueBelow(mythic, group_state, 0, -5, "LEFT")

    local missing_state = StdUi:Dropdown(widget, width - 20, 24, {})
    widget.missing_state = missing_state
    StdUi:AddLabel(widget, missing_state, "Not in group", "TOP")
    StdUi:GlueBelow(missing_state, mythic, 0, -30, "LEFT")

    local save = StdUi:Button(widget, 80, 24, "Save")
    widget.save = save
    StdUi:GlueBelow(save, missing_state, 0, -15, "RIGHT")

    function widget:Load()
        local db = NastrandirRaidTools:GetModuleDB("Attendance", "autorecord")

        if db.in_group then
            widget.group_state:SetValue(db.in_group)
        end

        if db.missing then
            widget.missing_state:SetValue(db.missing)
        end

        widget.mythic:SetChecked(db.mythic)

        widget.save:Hide()
    end

    function widget:Save()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        db["autorecord"] = {
            in_group = widget.group_state:GetValue(),
            missing = widget.missing_state:GetValue(),
            mythic = widget.mythic:GetChecked(),
        }

        widget.save:Hide()
    end

    widget:SetScript("OnShow", function()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local state_uids = Attendance:GetStates()

        local options = {}
        for _, state_uid in ipairs(state_uids) do
            local state = Attendance:GetState(state_uid)
            table.insert(options, {
                text = state.Name,
                value = state_uid,
                order = state.Order
            })
        end

        table.sort(options, function(a, b)
            return a.order < b.order
        end)

        widget.group_state:SetOptions(options)
        widget.missing_state:SetOptions(options)

        widget:Load()
    end)

    widget.group_state.OnValueChanged = function(dropdown, value)
        widget.save:Show()
    end

    widget.missing_state.OnValueChanged = function(dropdown, value)
        widget.save:Show()
    end

    widget.mythic.OnValueChanged = function(checkbox, state, value)
        widget.save:Show()
    end

    widget.save:SetScript("OnClick", function()
        widget:Save()
    end)

    return widget
end)