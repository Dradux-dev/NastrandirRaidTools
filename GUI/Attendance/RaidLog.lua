local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidLog", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local filter = StdUi:Dropdown(widget, 180, 24)
    widget.filter = filter
    filter:SetPlaceholder("--- Select ---")
    StdUi:GlueTop(filter, widget, -5, -5, "RIGHT")

    local clearFilter = StdUi:SquareButton(widget, 24, 24, "DELETE")
    widget.clearFilter = clearFilter
    clearFilter:Hide()
    StdUi:GlueTop(clearFilter, widget, -5, -5, "RIGHT")

    local back = StdUi:Button(widget, 80, 24, "Back")
    widget.back = back
    StdUi:GlueTop(back, widget, 5, -5, "LEFT")

    widget.entries = {}

    function widget:SetFilterOptions(entries)
        local Roster = NastrandirRaidTools:GetModule("Roster")
        local cache = {}
        local options = {}

        for _, entry in ipairs(entries) do
            if entry.member and not cache[entry.member] then
                cache[entry.member] = true
                local character = Roster:GetCharacter(entry.member)
                table.insert(options, {
                    text = character.name,
                    value = entry.member
                })
            end
        end

        table.sort(options, function(a, b)
            return a.text < b.text
        end)

        filter:SetOptions(options)
    end

    function widget:ShowEntries(entries)
        StdUi:ObjectList(
                widget,
                widget.entries,
                function(parent, value, i, key)
                    -- Create
                    local itemFrame = StdUi:NastrandirRaidTools_Attendance_RaidLogEntry(parent)
                    itemFrame:SetData(value)
                    return itemFrame
                end,
                function(parent, itemFrame, value, i, key)
                    itemFrame:SetData(value)
                end,
                entries,
                2,
                5,
                -40
        )
    end

    function widget:SetRaid(uid)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        widget.log = Attendance:GetRaidLog(uid)

        widget:SetFilterOptions(widget.log)
        widget:ClearFilter()
        widget:ShowEntries(widget.log)
    end

    function widget:FilterEntries(member_uid)
        local filtered = {}

        for _, entry in ipairs(widget.log) do
            if entry.member and entry.member == member_uid then
                -- Insert if it's about the member
                table.insert(filtered, entry)
            elseif not entry.member then
                -- Insert if it's a global event (like sections)
                table.insert(filtered, entry)
            end
        end

        widget:ShowEntries(filtered)
    end

    function widget:ClearFilter()
        widget.filter:SetValue(nil)
        widget.filter:ClearAllPoints()
        StdUi:GlueTop(widget.filter, widget, -5, -5, "RIGHT")
        widget.clearFilter:Hide()
        widget:ShowEntries(widget.log)
    end

    widget.filter.OnValueChanged = function(dropdown, value)
        print("Value Changed", value)
        if value then
            widget.filter:ClearAllPoints()
            StdUi:GlueLeft(widget.filter, widget.clearFilter, -5, 0)
            widget.clearFilter:Show()
            widget:FilterEntries(value)
        end
    end

    widget.clearFilter:SetScript("OnClick", function()
        widget:ClearFilter()
    end)

    widget.back:SetScript("OnClick", function()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidList()
    end)

    return widget
end)