local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidsRaid", function(self, parent, uid)
    local width = parent:GetWidth() or 800
    local height = 75

    local widget = StdUi:PanelWithLabel(parent, width, height, nil, "Raid")
    widget.uid = uid
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local title = StdUi:Label(widget, "Profiles", 18, "GameFontNormal", widget:GetWidth() - 20, 24)
    widget.title = title
    StdUi:GlueTop(title, widget, 10, -20, "LEFT")

    local contentPanel, contentFrame, contentChild, contentBar = StdUi:ScrollFrame(widget, widget:GetWidth() - 20, height - 75)
    widget.content = {
        panel = contentPanel,
        frame = contentFrame,
        child = contentChild,
        bar = contentBar,
        children = {}
    }
    StdUi:GlueTop(contentPanel, widget, 10, -40, "LEFT")

    local add_raid = StdUi:Button(widget, "Add raid")
    widget.add_raid = add_raid
    StdUi:GlueAbove(add_raid, contentPanel, 0, 20, "RIGHT")


    add_raid:SetScript("OnClick", function()
        widget:NewRaid()
    end)

    function widget:NewRaid()
        -- Get UID
        local uid = NastrandirRaidTools:CreateUID("Attendance-Raid")

        -- Do the DB stuff
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        db.raids[uid] = {
            name = "New Raid",
            date = NastrandirRaidTools:Today(),
            start_time = 2000,
            end_time = 2300
        }

        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaid(uid)
    end

    function widget:Sort()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")
        table.sort(widget.content.children, function(a, b)
            return db[a:GetUID()].date < db[b:GetUID()].date
        end)

        for index, child in ipairs(widget.content.children) do
            child:ClearAllPoints()
            if index == 1 then
                StdUi:GlueTop(child, widget.content.child, 0, 0, "LEFT")
            else
                local lastChild = widget.content.children[index - 1]
                StdUi:GlueBelow(child, lastChild, 0, -2)
            end
        end
    end

    function widget:AddRaid(uid, title)
        local raid
        local pos = NastrandirRaidTools:FindInTableIf(widget.content.children, function(child)
            return (child:GetUID() == uid)
        end)

        if pos then
            raid = widget.content.children[pos]
            raid:Hide()
        else
            raid = StdUi:NastrandirRaidTools_Attendance_RaidsRaid(widget.content.child, uid)
            raid:Hide()
            table.insert(widget.content.children, raid)
        end

        raid:SetTitle(title)
    end

    function widget:LoadRaids()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
        db.raids = {}
        end

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

    return widget
end)