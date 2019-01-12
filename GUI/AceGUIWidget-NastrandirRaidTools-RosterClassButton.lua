local Type, Version = "NastrandirRaidToolsRosterClassButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 248
local height = 20


local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.callbacks = {}

        function self.callbacks.OnClickNormal(button, mouseButton)
            local Roster = NastrandirRaidTools:GetModule("Roster")
            Roster:ShowDetails(self.key)
        end

        self.frame:SetScript("OnClick", self.callbacks.OnClickNormal)

        self.classColors = {
            ["DEATHKNIGHT"] = {
                background = {0.77, 0.12, 0.23, 1},
                foreground = {1, 1, 1, 1}
            },
            ["DEMONHUNTER"] = {
                background = {0.64, 0.19, 0.79, 1},
                foreground = {1, 1, 1, 1}
            },
            ["DRUID"] = {
                background = {1, 0.49, 0.04, 1},
                foreground = {1, 1, 1, 1}
            },
            ["HUNTER"] = {
                background = {0.67, 0.83, 0.45, 1},
                foreground = {1, 1, 1, 1}
            },
            ["MAGE"] = {
                background = {0.25, 0.78, 0.92, 1},
                foreground = {1, 1, 1, 1}
            },
            ["MONK"] = {
                background = {0, 1, 0.59, 1},
                foreground = {1, 1, 1, 1}
            },
            ["PALADIN"] = {
                background = {0.96, 0.55, 0.73, 1},
                foreground = {1, 1, 1, 1}
            },
            ["PRIEST"] = {
                background = {1, 1, 1, 1},
                foreground = {1, 1, 1, 1}
            },
            ["ROGUE"] = {
                background = {1, 0.96, 0.41, 1},
                foreground = {1, 1, 1, 1}
            },
            ["SHAMAN"] = {
                background = {0, 0.44, 0.87, 1},
                foreground = {1, 1, 1, 1}
            },
            ["WARLOCK"] = {
                background = {0.53, 0.53, 0.93, 1},
                foreground = {1, 1, 1, 1}
            },
            ["WARRIOR"] = {
                background = {0.78, 0.61, 0.43, 1},
                foreground = {1, 1, 1, 1}
            }
        }

        self:Enable()
    end,
    ["SetName"] = function(self, title)
        self.titletext = title
        self.title:SetText(title)
    end,
    ["GetName"] = function(self)
        return self.titletext
    end,
    ["SetClass"] = function(self, class)
        self.class = class
        self.title:SetTextColor(unpack(self.classColors[class].foreground))
        self.background:SetVertexColor(unpack(self.classColors[class].background))
        self.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
    end,
    ["GetClass"] = function(self)
        return self.class
    end,
    ["SetKey"] = function(self, key)
        self.key = key
    end,
    ["GetKey"] = function(self)
        return self.key
    end,
    ["Disable"] = function(self)
        self.frame:Disable()
    end,
    ["Enable"] = function(self)
        self.frame:Enable()
    end,
    ["Hide"] = function(self)
        self.frame:Hide()
        self.icon:Hide()
        self.title:Hide()
        self.background:Hide()

        self:Disable()

        self:SetHeight(0)
    end,
    ["Show"] = function(self)
        self.frame:Show()
        self.icon:Show()
        self.title:Show()
        self.background:Show()

        self:Enable()

        self:SetHeight(height)
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

    local icon_dimension = height - 4
    local icon = button:CreateTexture(nil, "OVERLAY")
    button.icon = icon
    icon:SetWidth(icon_dimension)
    icon:SetHeight(icon_dimension)
    icon:SetPoint("LEFT", button, "LEFT", 2, 0)
    icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")

    local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.title = title
    title:SetHeight(height)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("CENTER")
    title:SetPoint("TOP", button, "TOP")
    title:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    title:SetPoint("RIGHT", button, "RIGHT")
    title:SetPoint("BOTTOM", button, "BOTTOM")

    local widget = {
        frame = button,
        title = title,
        icon = icon,
        background = background,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)