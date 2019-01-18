local Type, Version = "NastrandirRaidToolsSpacer", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 10
local height = 10



local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["SetWidth"] = function(self, w)
        self.frame:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.frame:SetHeight(h)
    end,
    ["SetBackdropColor"] = function(self, r, g, b, a)
        self.background:SetVertexColor(r, g, b, a)
    end
}


local function Constructor()
    local name = Type .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", name, UIParent)
    frame:SetHeight(height)
    frame:SetWidth(width)
    frame:SetBackdropColor(0, 0, 0, 0)

    local background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background = background
    background:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp")
    background:SetBlendMode("ADD")
    background:SetVertexColor(0.5, 0.5, 0.5, 0.25)
    background:SetPoint("TOP", frame, "TOP")
    background:SetPoint("BOTTOM", frame, "BOTTOM")
    background:SetPoint("LEFT", frame, "LEFT")
    background:SetPoint("RIGHT", frame, "RIGHT")
    background:SetVertexColor(0, 0, 0, 0)

    local widget = {
        frame = frame,
        background = background,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)