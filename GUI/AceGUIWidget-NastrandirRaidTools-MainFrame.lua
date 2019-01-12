local Type, Version = "NastrandirRaidToolsMainFrame", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 1000
local height = 600

local SPACER = 10
local SIDE_PANEL_WIDTH = 220

local methods = {
    ["OnAcquire"] = function(self)
        self.status = {}
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["OnHeightSet"] = function(self, height)
        self.spacer:SetHeight(self.side_panel.frame:GetHeight())
        self.content_group:SetHeight(self.side_panel.frame:GetHeight())
    end,
    ["OnWidthSet"] = function(self, width)
        self.content_group:SetWidth(self.widget.content:GetWidth() - SIDE_PANEL_WIDTH - SPACER)
    end
}


local function Constructor()
    local widget = AceGUI:Create("Frame")
    widget:SetLayout("Flow")
    widget:SetTitle("Nastrandir Raid Tools")
    widget:SetStatusText("v 0.1")
    widget:SetHeight(height)
    widget:SetWidth(width)

    local side_panel = AceGUI:Create("SimpleGroup")
    widget.side_panel = side_panel
    side_panel:SetWidth(SIDE_PANEL_WIDTH)
    side_panel:SetHeight(widget.content:GetHeight() - SPACER)
    side_panel:SetFullHeight(true)
    side_panel:SetLayout("Fill")
    widget:AddChild(side_panel)

    local scroll_frame = AceGUI:Create("ScrollFrame")
    side_panel.scroll_frame = scroll_frame
    scroll_frame:SetLayout("Flow")
    side_panel:AddChild(scroll_frame)

    local spacer = AceGUI:Create("NastrandirRaidToolsSpacer")
    widget.spacer = spacer
    spacer:SetHeight(side_panel.frame:GetHeight())
    spacer:SetWidth(SPACER)
    spacer:SetBackdropColor(1, 0, 0, 1)
    widget:AddChild(spacer)

    local content_group = AceGUI:Create("SimpleGroup")
    widget.content_panel = content_group
    content_group:SetWidth(widget.content:GetWidth() - SIDE_PANEL_WIDTH - SPACER)
    content_group:SetHeight(side_panel.frame:GetHeight())
    content_group:SetLayout("Fill")
    widget:AddChild(content_group)

    local widget = {
        frame = widget.frame,
        widget = widget,
        side_panel = side_panel,
        scroll_frame = scroll_frame,
        spacer = spacer,
        content_group = content_group,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)