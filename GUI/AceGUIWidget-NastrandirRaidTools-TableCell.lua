local Type, Version = "NastrandirRaidToolsRosterTableCell", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 120
local height = 20


local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
        self:Enable()
    end,
    ["SetHeight"] = function(self, height)
        self.frame:SetHeight(height)
    end,
    ["SetWidth"] = function(self, width)
        self.frame:SetWidth(width)
    end,
    ["SetText"] = function(self, title)
        self.text = title
        self.title:SetText(title)
    end,
    ["GetText"] = function(self)
        return self.text
    end,
    ["SetData"] = function(self, data)
        self.data = data
    end,
    ["GetData"] = function(self)
        return self.data
    end,
    ["SetClickCallback"] = function(self, func)
        self.frame:SetScript("OnClick", func)
    end,
    ["Disable"] = function(self)
        self.frame:Disable()
    end,
    ["Enable"] = function(self)
        self.frame:Enable()
    end,
    ["Hide"] = function(self)
        self.frame:Hide()
        self.title:Hide()
        self.background:Hide()
    end,
    ["Show"] = function(self)
        self.frame:Show()
        self.title:Show()
        self.background:Show()
    end
}


local function Constructor()
    local name = Type .. AceGUI:GetNextWidgetNum(Type)
    local button = CreateFrame("BUTTON", name, UIParent, "OptionsListButtonTemplate")
    button:SetHeight(height)
    button:SetWidth(width)
    button.dgroup = nil
    button.data = {}

    local background = button:CreateTexture(nil, "BACKGROUND")
    button.background = background
    background:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp")
    background:SetBlendMode("ADD")
    background:SetVertexColor(0.5, 0.5, 0.5, 0.25)
    background:SetPoint("TOP", button, "TOP")
    background:SetPoint("BOTTOM", button, "BOTTOM")
    background:SetPoint("LEFT", button, "LEFT")
    background:SetPoint("RIGHT", button, "RIGHT")

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.title = label
    label:SetHeight(height)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("CENTER")
    label:SetPoint("TOP", button, "TOP")
    label:SetPoint("LEFT", button, "LEFT")
    label:SetPoint("RIGHT", button, "RIGHT")
    label:SetPoint("BOTTOM", button, "BOTTOM")

    local widget = {
        frame = button,
        title = label,
        background = background,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)