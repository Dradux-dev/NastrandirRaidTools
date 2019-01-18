local Type, Version = "NastrandirRaidToolsSpinBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local WIDTH = {
    BUTTON = 40,
    EDIT = 50
}

local HEIGHT = 30

local width = WIDTH.BUTTON + WIDTH.EDIT + WIDTH.BUTTON + 20
local height = HEIGHT


local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)

        self.minus:SetCallback("OnClick", function()
            self:SetValue(self:GetValue() - self:GetStep())
        end)

        self.plus:SetCallback("OnClick", function()
            self:SetValue(self:GetValue() + self:GetStep())
        end)

        self.value:SetCallback("OnEnterPressed", function()
            self:SetValue(self:GetValue())
        end)
    end,
    ["SetMin"] = function(self, min)
        self.min = min
    end,
    ["SetMax"] = function(self, max)
        self.max = max
    end,
    ["SetValue"] = function(self, value)
        self.value:SetText(string.format("%d", math.min(self.max or 100, math.max(self.min or 1, value))))
    end,
    ["SetStep"] = function(self, step)
        self.step = step
    end,
    ["GetMin"] = function(self)
        return self.min or 1
    end,
    ["GetMax"] = function(self)
        return self.max or 100
    end,
    ["GetValue"] = function(self)
        return tonumber(self.value:GetText())
    end,
    ["GetStep"] = function(self)
        return self.step or 1
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local minus = AceGUI:Create("Button")
    widget.minus = minus
    minus:SetWidth(WIDTH.BUTTON)
    minus:SetHeight(HEIGHT)
    minus:SetText("-")
    widget:AddChild(minus)

    local value = AceGUI:Create("EditBox")
    widget.value = value
    value:SetWidth(WIDTH.EDIT)
    value:SetHeight(HEIGHT)
    value:SetText("0")
    widget:AddChild(value)

    local plus = AceGUI:Create("Button")
    widget.plus = plus
    plus:SetWidth(WIDTH.BUTTON)
    plus:SetHeight(HEIGHT)
    plus:SetText("+")
    widget:AddChild(plus)

    local widget = {
        frame = widget.frame,
        widget = widget,
        minus = minus,
        value = value,
        plus = plus,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)