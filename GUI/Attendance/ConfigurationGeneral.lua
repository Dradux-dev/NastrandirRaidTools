local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationGeneral", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local name = StdUi:SimpleEditBox(widget, width - 20, 24, "")
    widget.name = name
    StdUi:AddLabel(widget, name, "Default Name", "TOP")
    StdUi:GlueTop(name, widget, 10, -30, "LEFT")

    local startTime = StdUi:NumericBox(widget, (width - 30) / 2, 24, "")
    widget.startTime = startTime
    StdUi:AddLabel(widget, startTime, "Start Time", "TOP")
    StdUi:GlueBelow(startTime, name, 0, -30, "LEFT")

    local endTime = StdUi:NumericBox(widget, (width - 30) / 2, 24, "")
    widget.endTime = endTime
    StdUi:AddLabel(widget, endTime, "End Time", "TOP")
    StdUi:GlueRight(endTime, startTime, 10, 0)

    local save = StdUi:Button(widget, 80, 24, "Save")
    widget.save = save
    StdUi:GlueBelow(save, endTime, 0, -15, "RIGHT")

    function widget:ShowSave()
        widget.save:Show()
    end

    function widget:HideSave()
        widget.save:Hide()
    end

    function widget:Load()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.defaults then
            db.defaults = {}
        end

        widget.name:SetText(db.defaults.name or "")
        widget.startTime:SetText(db.defaults.startTime or 1900)
        widget.endTime:SetText(db.defaults.endTime or 2300)
        widget:HideSave()
    end

    function widget:Save()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.defaults then
            db.defaults = {}
        end

        db.defaults.name = widget.name:GetText()
        db.defaults.startTime = tonumber(widget.startTime:GetText())
        db.defaults.endTime = tonumber(widget.endTime:GetText())
        widget:HideSave()
    end

    widget.name:SetScript("OnEnterPressed", function()
        widget:ShowSave()
    end)

    widget.startTime:SetScript("OnEnterPressed", function()
        widget.startTime:Validate()
        if widget.startTime.isValid then
            widget:ShowSave()
        end
    end)

    widget.startTime.button:SetScript("OnClick", widget.startTime:GetScript("OnEnterPressed"))

    widget.endTime:SetScript("OnEnterPressed", function()
        widget.endTime:Validate()
        if widget.endTime.isValid then
            widget:ShowSave()
        end
    end)

    widget.endTime.button:SetScript("OnClick", widget.endTime:GetScript("OnEnterPressed"))

    widget.save:SetScript("OnClick", function()
        widget:Save()
    end)

    widget:SetScript("OnShow", function()
        widget:Load()
    end)

    return widget
end)