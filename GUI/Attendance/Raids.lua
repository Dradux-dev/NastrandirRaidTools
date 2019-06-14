local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_Raids", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    widget.children = {}

    local title = StdUi:Label(widget, "Raids", 18, "GameFontNormal", widget:GetWidth() - 20, 24)
    widget.title = title
    StdUi:GlueTop(title, widget, 10, -20, "LEFT")

    local add_raid = StdUi:Button(widget, 80, 24, "Add raid")
    widget.add_raid = add_raid
    StdUi:GlueBottom(add_raid, title, 0, 0, "RIGHT")


    add_raid:SetScript("OnClick", function()
        widget:NewRaid()
    end)

    function widget:NewRaid()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:NewRaid()
    end

    function widget:Sort()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")
        if not db.raids then
            db.raids = {}
        end

        table.sort(widget.children, function(a, b)
            return db.raids[a:GetUID()].date > db.raids[b:GetUID()].date
        end)

        for index, child in ipairs(widget.children) do
            child:ClearAllPoints()
            if index == 1 then
                StdUi:GlueBelow(child, title, 0, -20, "LEFT")
            else
                local lastChild = widget.children[index - 1]
                StdUi:GlueBelow(child, lastChild, 0, -2)
            end

            child:Show()
        end
    end

    function widget:AddRaid(uid, title)
        local raid
        local pos = NastrandirRaidTools:FindInTableIf(widget.unused, function(child)
            return (child:GetUID() == uid)
        end)

        if pos then
            -- Reuse widget, that had already this UID
            raid = widget.unused[pos]
            table.remove(widget.unused, pos)
            table.insert(widget.children, raid)
            raid:Hide()
        else
            -- Reuse widget, that is no longer required by any other raid
            local db = NastrandirRaidTools:GetModuleDB("Attendance")

            if not db.raids then
                db.raids = {}
            end

            pos = NastrandirRaidTools:FindInTableIf(widget.unused, function(child)
                return not db.raids[child:GetUID()]
            end)

            if pos then
                raid = widget.unused[pos]
                table.remove(widget.unused, pos)
                raid:SetUID(uid)
            else
                -- Create new widget
                raid = StdUi:NastrandirRaidTools_Attendance_RaidsRaid(widget, uid)
            end
            raid:Hide()
            table.insert(widget.children, raid)
        end

        raid:SetTitle(title)
    end

    function widget:LoadRaids()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        if not widget.unused then
            widget.unused = {}
        end

        -- Move all raids widgets to unused. Reuse them if required.
        table.foreach(widget.children, function(index, child)
            table.insert(widget.unused, child)
            child:Hide()
        end)
        widget.children = {}

        local raid_list = {}
        for uid, raid in pairs(db.raids) do
            table.insert(raid_list, {
                uid = uid,
                raid = raid
            })
        end

        for index, entry in ipairs(raid_list) do
            local raid_date = NastrandirRaidTools:SplitDate(entry.raid.date)
            widget:AddRaid(entry.uid, string.format("%s, %02d.%02d.%04d", entry.raid.name, raid_date.day, raid_date.month, raid_date.year))
        end

        widget:Sort()
    end

    widget:SetScript("OnShow", function()
        widget:LoadRaids()
    end)

    widget:LoadRaids()
    return widget
end)