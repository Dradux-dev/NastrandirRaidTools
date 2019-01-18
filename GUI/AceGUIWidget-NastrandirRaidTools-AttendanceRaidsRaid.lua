local Type, Version = "NastrandirRaidToolsAttendanceRaidsRaid", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 28

local WIDTH = {
    TITLE = 0.64,
    BUTTON = 0.17
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.title:SetCallback("OnClick", function()
            self:ShowRaid()
        end)

        self.show_log:SetCallback("OnClick", function()
            self:ShowLog()
        end)

        self.record:SetCallback("OnClick", function()
            self:ShowRecording()
        end)
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnWidthSet"] = function(self, width)
        self.title:SetWidth(WIDTH.TITLE * self.widget.frame:GetWidth())
        self.show_log:SetWidth(WIDTH.BUTTON * self.widget.frame:GetWidth())
        self.record:SetWidth(WIDTH.BUTTON * self.widget.frame:GetWidth())
    end,
    ["SetUID"] = function(self, uid)
        self.uid = uid
    end,
    ["GetUID"] = function(self)
        return self.uid
    end,
    ["SetTitle"] = function(self, title)
        self.title:SetText(title)
    end,
    ["GetTitle"] = function(self)
        return self.title:GetText()
    end,
    ["ShowRaid"] = function(self)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaid(self.uid)
    end,
    ["ShowLog"] = function(self)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidLog(self.uid)
    end,
    ["ShowRecording"] = function(self)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidRecording(self.uid)
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local background = widget.frame:CreateTexture(nil, "BACKGROUND")
    widget.background = background
    background:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp")
    background:SetBlendMode("ADD")
    background:SetVertexColor(0.5, 0.5, 0.5, 0.25)
    background:SetPoint("TOP", widget.frame, "TOP")
    background:SetPoint("BOTTOM", widget.frame, "BOTTOM")
    background:SetPoint("LEFT", widget.frame, "LEFT")
    background:SetPoint("RIGHT", widget.frame, "RIGHT")

    local title = AceGUI:Create("InteractiveLabel")
    widget.title= title
    title:SetWidth(WIDTH.TITLE * widget.frame:GetWidth())
    title:SetHeight(height)
    widget:AddChild(title)

    local show_log = AceGUI:Create("Button")
    widget.show_log = show_log
    show_log:SetWidth(WIDTH.BUTTON * widget.frame:GetWidth())
    show_log:SetText("Log")
    widget:AddChild(show_log)

    local record = AceGUI:Create("Button")
    widget.record = record
    record:SetWidth(WIDTH.BUTTON * widget.frame:GetWidth())
    record:SetText("Record")
    widget:AddChild(record)

    local widget = {
        frame = widget.frame,
        widget = widget,
        title = title,
        show_log = show_log,
        record = record,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)