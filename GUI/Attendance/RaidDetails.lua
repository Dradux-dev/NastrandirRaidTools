local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidDetails", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local title = StdUi:Label(widget, "Details", 18, "GameFontNormal", widget:GetWidth() - 20, 24)
    widget.title = title
    StdUi:GlueTop(title, widget, 10, -20, "LEFT")

    local name = StdUi:SimpleEditBox(widget, widget:GetWidth() - 20, 24, "")
    widget.name = name
    StdUi:AddLabel(widget, name, "Name", "TOP")
    StdUi:GlueBelow(name, title, 0, -30, "LEFT")

    local date = StdUi:SimpleEditBox(widget, widget:GetWidth() - 20, 24, "")
    widget.date = date
    StdUi:AddLabel(widget, date, "Date (YYYYMMDD)", "TOP")
    StdUi:GlueBelow(date, name, 0, -30, "LEFT")

    local startTime = StdUi:SimpleEditBox(widget, (widget:GetWidth() - 30) / 2, 24, "")
    widget.startTime = startTime
    StdUi:AddLabel(widget, startTime, "Start Time (HHMM)", "TOP")
    StdUi:GlueBelow(startTime, date, 0, -30, "LEFT")

    local endTime = StdUi:SimpleEditBox(widget, (widget:GetWidth() - 30) / 2, 24, "")
    widget.endTime = endTime
    StdUi:AddLabel(widget, endTime, "End Time (HHMM)", "TOP")
    StdUi:GlueBelow(endTime, date, 0, -30, "RIGHT")

    local save = StdUi:Button(widget, 80, 24, "Save")
    widget.save = save
    StdUi:GlueBelow(save, endTime, 0, -20, "RIGHT")

    local delete  = StdUi:Button(widget, 80, 24, "Delete")
    widget.delete = delete
    StdUi:GlueLeft(delete, save, -10, 0)

    function widget:SetUID(uid)
        widget.uid = uid
    end

    function widget:GetUID()
        return widget.uid
    end

    function widget:Delete()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        db.raids[widget.uid] = nil
        db.participation[widget.uid] = nil

        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidList()
    end

    function widget:Save()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        db.raids[widget.uid] = {
            name = widget.name:GetText(),
            date = tonumber(widget.date:GetText()),
            start_time = tonumber(widget.startTime:GetText()),
            end_time = tonumber(widget.endTime:GetText())
        }

        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidList()
    end

    function widget:Load()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        local raid = db.raids[widget.uid]
        widget.name:SetText(raid.name)
        widget.date:SetText(raid.date)
        widget.startTime:SetText(raid.start_time)
        widget.endTime:SetText(raid.end_time)
    end

    widget.delete:SetScript("OnClick", function()
        NastrandirRaidTools:GetUserPermission(widget, {
            callbackYes = function()
                widget:Delete()
            end
        })
    end)

    widget.save:SetScript("OnClick", function()
        widget:Save()
    end)

    return widget
end)