local Type, Version = "NastrandirRaidToolsAttendanceConfiguration", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 450

local KEY = {
    GENERAL = "GENERAL",
    STATES = "STATES",
    ANALYTICS = "ANALYTICS"
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self:ShowGeneral()

        self.dropdown:SetCallback("OnValueChanged", function(dropdown, event, key)
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
        end)
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnHeightSet"] = function(self, height)

    end,
    ["OnWidthSet"] = function(self, width)
        for index, child in ipairs(self.widget.children) do
            child:SetWidth(width)
        end
    end,
    ["BuildTabs"] = function(self)
        -- It is called by the TabGroup, don't know what to implement here
    end,
    ["ShowGeneral"] = function(self)
        print("ShowGeneral")
        self.config_container:ReleaseChildren()
    end,
    ["ShowStates"] = function(self)
        print("ShowStates()")
        self.config_container:ReleaseChildren()

        local states = AceGUI:Create("NastrandirRaidToolsAttendanceConfigurationStates")
        states:Initialize()
        states:SetWidth(self.widget.frame:GetWidth())
        self.config_container:AddChild(states)
    end,
    ["ShowAnalytics"] = function(self)
        print("ShowAnalytics()")
        self.config_container:ReleaseChildren()
    end

}


local function Constructor()
    -- TopBar with dropdown: General, States, Analytics
    -- Content = SimpleGroup

    local widget = AceGUI:Create("SimpleGroup")
    widget:SetWidth(width)
    widget:SetHeight(height)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local top_bar = AceGUI:Create("SimpleGroup")
    widget.top_bar = top_bar
    top_bar:SetWidth(widget.frame:GetWidth())
    top_bar:SetHeight(30)
    top_bar:SetLayout("Flow")
    top_bar.frame:SetBackdropColor(0, 0,0 ,0)
    widget:AddChild(top_bar)

    local spacer = AceGUI:Create("NastrandirRaidToolsSpacer")
    top_bar.spacer = spacer
    spacer:SetWidth(0.64 * top_bar.frame:GetWidth())
    spacer:SetHeight(30)
    spacer:SetBackdropColor(0, 0, 0, 0)
    top_bar:AddChild(spacer)

    local dropdown = AceGUI:Create("Dropdown")
    top_bar.dropdown = dropdown
    dropdown:SetWidth(0.25 * top_bar.frame:GetWidth())
    dropdown:SetList(
        {
            [KEY.GENERAL] = "General",
            [KEY.STATES] = "States",
            [KEY.ANALYTICS] = "Analytics"
        },
        {
            KEY.GENERAL,
            KEY.STATES,
            KEY.ANALYTICS
        }
    )
    dropdown:SetValue(KEY.GENERAL)
    top_bar:AddChild(dropdown)

    local config_container = AceGUI:Create("SimpleGroup")
    widget.config_container = config_container
    config_container:SetWidth(widget.frame:GetWidth())
    config_container:SetHeight(height - 30)
    config_container.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(config_container)

    local widget = {
        frame = widget.frame,
        widget = widget,
        top_bar = top_bar,
        dropdown = dropdown,
        config_container = config_container,
        type = Type
    }

    --[[local widget = AceGUI:Create("TabGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget:SetTabs({
        {
            value = KEY.GENERAL,
            text = "General"
        },
        {
            value = KEY.STATES,
            text = "States"
        },
        {
            value = KEY.ANALYTICS,
            text = "Analytics"
        }
    })
    widget:SelectTab(KEY.STATES)

    local widget = {
        frame = widget.frame,
        widget = widget,
        type = Type
    }]]

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)