local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationAnalyticsEditState", function(self, parent)
    local width = (parent:GetWidth() or 800) - 20
    local height = 34

    local widget = StdUi:Panel(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local name = StdUi:Label(widget, "Name")
    widget.name = name
    StdUi:GlueLeft(name, widget, 10, 0, true)

    local delete = StdUi:SquareButton(widget, 24, 24, "DELETE")
    widget.delete = delete
    StdUi:GlueRight(delete, widget, -10, 0, true)

    local toleranceOptions = {
        {text = "Total time", value = "TOTAL"},
        {text = "Without Tolerance", value = "EXCLUDE_TOLERANCE"},
        {text = "Only Tolerance", value = "TOLERANCE"}
    }
    local tolerance = StdUi:Dropdown(widget, 180, 24, toleranceOptions, toleranceOptions[1].value)
    widget.tolerance = tolerance
    StdUi:GlueLeft(tolerance, delete, -5, 0)

    function widget:SetAnalyticUID(uid)
        widget.analytic_uid = uid
    end

    function widget:SetUID(uid)
        widget.state_uid = uid
    end

    function widget:Load()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local state = Attendance:GetState(widget.state_uid)
        widget.name:SetText(state.Name)
        local toleranceTime = state.tolerance or 0
        if toleranceTime == 0 then
            widget.tolerance:Hide()
        else
            local analytic = Attendance:GetAnalytic(widget.analytic_uid)
            if type(analytic.states[widget.state_uid]) == "table" and analytic.states[widget.state_uid].tolerance then
                tolerance:SetValue(analytic.states[widget.state_uid].tolerance, tolerance:FindValueText(analytic.states[widget.state_uid].tolerance))
            else
                tolerance:SetValue(toleranceOptions[1].value, tolerance:FindValueText(toleranceOptions[1].value))
            end
            widget.tolerance:Show()
        end
    end

    widget.delete:SetScript("OnClick", function()
        widget:GetParent():GetParent():RemoveState(widget.state_uid)
    end)

    widget.tolerance.OnValueChanged = function(newValue)
        widget:GetParent():GetParent():ShowSave()
    end

    return widget
end)