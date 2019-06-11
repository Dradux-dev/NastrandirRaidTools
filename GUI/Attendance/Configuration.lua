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
            text = "ANALYTICS",
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
            tab:Show()
        end
    end

    function widget:ShowGeneral()
        print("ShowGeneral")
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
        widget:ShowTab(widget.analytics)
    end

    widget.dropdown.OnValueChanged = function(dropdown, key)
        if key == KEY.GENERAL then
            self:ShowGeneral()
            return
        end

        if key == KEY.STATES then
            self:ShowStates()
            return
        end

        if key == KEY.ANALYTICS then
            self:ShowAnalytics()
            return
        end
    end

    return widget
end)