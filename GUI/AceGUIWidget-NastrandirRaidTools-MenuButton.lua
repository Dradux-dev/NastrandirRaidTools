local Type, Version = "NastrandirRaidToolsMenuButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 248
local height = 24


local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.callbacks = {}

        function self.callbacks.OnClickNormal(button, mouseButton)
            if self.userFunction then
                self.userFunction(button, mouseButton)
            end
        end

        self.frame:SetScript("OnClick", self.callbacks.OnClickNormal)
        self:Enable()
    end,
    ["SetTitle"] = function(self, title)
        self.titletext = title
        self.title:SetText(title)
    end,
    ["Disable"] = function(self)
        self.frame:Disable()
    end,
    ["Enable"] = function(self)
        self.frame:Enable()
    end,
    ["SetUserFunction"] = function(self, func)
        self.userFunction = func
    end,
    ["Hide"] = function(self)
        self.frame:Hide()
        self.background:Hide()
        self.title:Hide()
    end,
    ["Show"] = function(self)
        self.frame:Show()
        self.background:Show()
        self.title:Show()
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

    local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.title = title
    title:SetHeight(height)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("CENTER")
    title:SetPoint("TOP", button, "TOP")
    title:SetPoint("LEFT", button, "LEFT", 5, 0)
    title:SetPoint("BOTTOM", button, "BOTTOM")
    title:SetPoint("RIGHT", button, "RIGHT")

    local widget = {
        frame = button,
        title = title,
        background = background,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)