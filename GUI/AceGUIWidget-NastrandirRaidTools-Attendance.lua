local Type, Version = "NastrandirRaidToolsAttendance", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 400

local WIDTH = {
    DROPDOWN = 150,
    BUTTON = 100
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        local raids = self:GetRaidList()
        self.start_raid:SetList(raids.list)
        self.end_raid:SetList(raids.list, raids.order)
        self.start_raid:SetCallback("OnValueChanged", function(dropdown, event, value)
            local raids = self:FilterRaidList(value)
            self.end_raid:SetList(raids.list, raids.order)
        end)
        self.analyse:SetCallback("OnClick", function(button, mouseButton)
            print("Analyse clicked")
        end)
        self.raids:SetCallback("OnClick", function(button, mouseButton)
            local Attendance = NastrandirRaidTools:GetModule("Attendance")
            Attendance:ShowRaidList()
        end)
        self.configuration:SetCallback("OnClick", function(button, mouseButton)
            local Attendance  = NastrandirRaidTools:GetModule("Attendance")
            Attendance:ShowConfiguration()
        end)
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnHeightSet"] = function(self, height)
        self.top_bar:SetHeight(40)
        self.view:SetHeight(self.widget.frame:GetHeight() - self.top_bar.frame:GetHeight())
    end,
    ["OnWidthSet"] = function(self, width)
        self.widget:SetWidth(width)
        self.top_bar:SetWidth(width)
        self.top_bar.spacer:SetWidth(width - 2 * WIDTH.DROPDOWN - 3 * WIDTH.BUTTON - 7)
    end,
    ["GetRaidList"] = function(self)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        return Attendance:GetRaidList()
    end,
    ["FilterRaidList"] = function(self, start_date)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        return Attendance:GetRaidList(start_date)
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetLayout("Flow")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local top_bar = AceGUI:Create("SimpleGroup")
    widget.top_bar = top_bar
    top_bar:SetLayout("Flow")
    top_bar:SetWidth(widget.frame:GetWidth())
    top_bar.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(top_bar)

    local start_raid = AceGUI:Create("Dropdown")
    top_bar.start_raid = start_raid
    start_raid:SetWidth(WIDTH.DROPDOWN)
    start_raid:SetLabel("Start")
    top_bar:AddChild(start_raid)

    local end_raid = AceGUI:Create("Dropdown")
    top_bar.end_raid = end_raid
    end_raid:SetWidth(WIDTH.DROPDOWN)
    end_raid:SetLabel("End")
    top_bar:AddChild(end_raid)

    local analyse = AceGUI:Create("Button")
    top_bar.analyse = analyse
    analyse:SetText("Analyse")
    analyse:SetWidth(WIDTH.BUTTON)
    top_bar:AddChild(analyse)

    local spacer = AceGUI:Create("NastrandirRaidToolsSpacer")
    top_bar.spacer = spacer
    spacer:SetHeight(20)
    spacer:SetWidth(1)
    spacer:SetBackdropColor(0, 0, 0, 0)
    top_bar:AddChild(spacer)

    local raids = AceGUI:Create("Button")
    top_bar.analyse = raids
    raids:SetText("Raids")
    raids:SetWidth(WIDTH.BUTTON)
    top_bar:AddChild(raids)

    local configuration = AceGUI:Create("Button")
    top_bar.analyse = configuration
    configuration:SetText("Configuration")
    configuration:SetWidth(WIDTH.BUTTON)
    top_bar:AddChild(configuration)

    local view = AceGUI:Create("SimpleGroup")
    widget.view = view
    view:SetLayout("Fill")
    view:SetWidth(widget.frame:GetWidth())
    view.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(view)

    local data = AceGUI:Create("NastrandirRaidToolsTable")
    view.data = data
    data:SetRows(25)
    data:SetColumns(5)
    view:AddChild(data)

    local widget = {
        frame = widget.frame,
        widget = widget,
        top_bar = top_bar,
        start_raid = start_raid,
        end_raid = end_raid,
        analyse = analyse,
        raids = raids,
        configuration = configuration,
        view = view,
        data = data,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)