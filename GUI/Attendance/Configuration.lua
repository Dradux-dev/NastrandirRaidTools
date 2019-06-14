local StdUi = LibStub("StdUi")

local KEY = {
    GENERAL = "GENERAL",
    STATES = "STATES",
    ANALYTICS = "ANALYTICS"
}

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_Configuration", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)
    widget.tabs = {}

    local dropdown = StdUi:Dropdown(widget, 300, 24, {
        {
            text = "General",
            value = KEY.GENERAL
        },
        {
            text = "States",
            value = KEY.STATES
        },
        {
            text = "Analytics",
            value = KEY.ANALYTICS
        }
    })
    widget.dropdown = dropdown
    StdUi:GlueTop(dropdown, widget, -10, -10, "RIGHT")

    function widget:HideTabs()
        for _, tab in ipairs(widget.tabs) do
            tab:Hide()
        end
    end

    function widget:ShowTab(tab)
        widget:HideTabs()

        if tab then
            StdUi:GlueTop(tab, widget, 0, -40, "LEFT")
            tab:Show()
        end
    end

    function widget:ShowGeneral()
        print("ShowGeneral()")
        if not widget.general then
            local general = StdUi:NastrandirRaidTools_Attendance_ConfigurationGeneral(widget)
            widget.general = general
            general:Hide()
            table.insert(widget.tabs, general)
        end

        widget:ShowTab(widget.general)
    end

    function widget:ShowStates()
        print("ShowStates()")
        if not widget.states then
            local states = StdUi:NastrandirRaidTools_Attendance_ConfigurationStates(widget)
            widget.states = states
            states:SetWidth(widget:GetWidth())
            states:Hide()
            table.insert(widget.tabs, states)
        end

        widget:ShowTab(widget.states)
    end

    function widget:ShowAnalytics()
        print("ShowAnalytics()")
        if not widget.analytics then
            local analytics = StdUi:NastrandirRaidTools_Attendance_ConfigurationAnalytics(widget)
            widget.analytics = analytics
            analytics:Hide()
            table.insert(widget.tabs, analytics)
        end

        widget:ShowTab(widget.analytics)
    end

    widget.dropdown.OnValueChanged = function(dropdown, key)
        if key == KEY.GENERAL then
            widget:ShowGeneral()
            return
        end

        if key == KEY.STATES then
            widget:ShowStates()
            return
        end

        if key == KEY.ANALYTICS then
            widget:ShowAnalytics()
            return
        end
    end

    widget.dropdown:SetValue(KEY.GENERAL)
    return widget
end)