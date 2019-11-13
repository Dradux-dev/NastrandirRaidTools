local StdUi = LibStub("StdUi")

local KEY = {
    GENERAL = "GENERAL",
    AUTORECORD = "AUTORECORD",
    STATES = "STATES",
    ANALYTICS = "ANALYTICS",
    SECTIONS = "SECTIONS"
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
            value = KEY.GENERAL,
            show = function()
                widget:ShowGeneral()
            end
        },
        {
            text = "Auto Record",
            value = KEY.AUTORECORD,
            show = function()
                widget:ShowAutoRecord()
            end
        },
        {
            text = "States",
            value = KEY.STATES,
            show = function()
                widget:ShowStates()
            end
        },
        {
            text = "Analytics",
            value = KEY.ANALYTICS,
            show = function()
                widget:ShowAnalytics()
            end
        },
        {
            text = "Sections",
            value = KEY.SECTIONS,
            show = function()
                widget:ShowSections()
            end
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

    function widget:SelectGeneral()
        widget.dropdown:SetValue(KEY.GENERAL, widget.dropdown:FindValueText(KEY.GENERAL))
    end

    function widget:SelectAutoRecord()
        widget.dropdown:SetValue(KEY.AUTORECORD, widget.dropdown:FindValueText(KEY.AUTORECORD))
    end

    function widget:SelectStates()
        widget.dropdown:SetValue(KEY.STATES, widget.dropdown:FindValueText(KEY.STATES))
    end

    function widget:SelectAnalytics()
        widget.dropdown:SetValue(KEY.ANALYTICS, widget.dropdown:FindValueText(KEY.ANALYTICS))
    end

    function widget:SelectSections()
        widget.dropdown:SetValue(KEY.SECTIONS, widget.dropdown:FindValueText(KEY.SECTIONS))
    end

    function widget:ShowGeneral()
        if not widget.general then
            local general = StdUi:NastrandirRaidTools_Attendance_ConfigurationGeneral(widget)
            widget.general = general
            general:Hide()
            table.insert(widget.tabs, general)
        end


        widget:ShowTab(widget.general)
    end

    function widget:ShowAutoRecord()
        if not widget.autorecord then
            local autorecord = StdUi:NastrandirRaidTools_Attendance_ConfigurationAutoRecord(widget)
            widget.autorecord = autorecord
            autorecord:Hide()
            table.insert(widget.tabs, autorecord)
        end


        widget:ShowTab(widget.autorecord)
    end

    function widget:ShowStates()
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
        if not widget.analytics then
            local analytics = StdUi:NastrandirRaidTools_Attendance_ConfigurationAnalytics(widget)
            widget.analytics = analytics
            analytics:Hide()
            table.insert(widget.tabs, analytics)
        end

        widget:ShowTab(widget.analytics)
    end

    function widget:ShowSections()
        if not widget.sections then
            local sections = StdUi:NastrandirRaidTools_Attendance_ConfigurationSections(widget)
            widget.sections = sections
            sections:Hide()
            table.insert(widget.tabs, sections)
        end

        widget:ShowTab(widget.sections)
    end

    widget.dropdown.OnValueChanged = function(dropdown, key)
        for _, entry in ipairs(widget.dropdown.options) do
            if entry.value == key and entry.show then
                entry.show()
                return
            end
        end
        --[[if key == KEY.GENERAL then
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

        if key == KEY.SECTIONS then
            widget:ShowSections()
            return
        end]]
    end

    widget.dropdown:SetValue(KEY.GENERAL)
    return widget
end)