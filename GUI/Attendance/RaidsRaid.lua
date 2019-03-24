local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidsRaid", function(self, parent, uid)
    local width = parent:GetWidth() or 800
    local height = 75

    local widget = StdUi:PanelWithLabel(parent, width, height, nil, "Raid")
    widget.uid = uid
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local record = StdUi:Button(widget, "Record")
    widget.record = record
    StdUi:GlueRight(record, widget, -20, 0, true)

    local show_log = StdUi:Button(widget, "Log")
    widget.show_log = show_log
    StdUi:GlueLeft(show_log, record, -10, 0)

    local edit = StdUi:Button(widget, "Edit")
    widget.edit = edit
    StdUi:GlueLeft(edit, show_log, -10, 0)

    function widget:SetUID(uid)
        widget.uid = uid
    end

    function widget:GetUID()
        return widget.uid
    end

    function widget:SetTitle(title)
        widget.label:SetText(title)
    end

    function widget:GetTitle()
        return widget.label:GetText()
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