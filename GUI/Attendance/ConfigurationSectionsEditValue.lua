local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationSectionEditValue", function(self, parent)
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

    function widget:SetValue(value)
        widget.name:SetText(value)
    end

    widget.delete:SetScript("OnClick", function()
        widget:GetParent():GetParent():RemoveValue(widget.name:GetText())
    end)

    return widget
end)