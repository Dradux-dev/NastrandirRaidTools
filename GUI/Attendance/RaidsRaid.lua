local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidsRaid", function(self, parent, uid)
    local width = (parent:GetWidth() or 800) - 20
    local height = 40

    local widget = StdUi:Panel(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    widget.uid = uid

    local title = StdUi:FontString(widget, "Raid")
    widget.title = title
    StdUi:GlueLeft(title, widget, 10, 0, true)

    local record = StdUi:Button(widget, 80, 24, "Record")
    widget.record = record
    StdUi:GlueRight(record, widget, -20, 0, true)

    local show_log = StdUi:Button(widget, 80, 24, "Log")
    widget.show_log = show_log
    StdUi:GlueLeft(show_log, record, -10, 0)

    local edit = StdUi:Button(widget, 80, 24, "Edit")
    widget.edit = edit
    StdUi:GlueLeft(edit, show_log, -10, 0)

    function widget:SetUID(uid)
        widget.uid = uid
    end

    function widget:GetUID()
        return widget.uid
    end

    function widget:SetTitle(title)
        widget.title:SetText(title)
    end

    function widget:GetTitle()
        return widget.title:GetText()
    end

    function widget:ShowRaid()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaid(widget.uid)
    end

    function widget:ShowLog()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidLog(widget.uid)
    end

    function widget:ShowRecording()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidRecording(widget.uid)
    end


    edit:SetScript("OnClick", function()
        widget:ShowRaid()
    end)

    show_log:SetScript("OnClick", function()
        widget:ShowLog()
    end)

    record:SetScript("OnClick", function()
        widget:ShowRecording()
    end)

    return widget
end)