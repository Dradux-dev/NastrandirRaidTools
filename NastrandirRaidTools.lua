

local Dialog = LibStub("LibDialog-1.0")
local AceGUI = LibStub("AceGUI-3.0")


SLASH_NASTRANDIRRAIDTOOLS1 = "/nrt"

function SlashCmdList.NASTRANDIRRAIDTOOLS(cmd, editbox)
    NastrandirRaidTools:ToggleInterface()
end

local defaultSavedVars = {
    profile = {
        window = {
            x = 0,
            y = 150,
            width = 1000,
            height = 600,
            anchromFrom = "TOP",
            anchorTo = "TOP",
            background_color = {0.059, 0.059, 0.059, 0.9},
            spacer = 10,
            side_panel_width = 220,
            margin = 2,
        },
        modules = {
        }
    }
}

-- Init
function NastrandirRaidTools:OnInitialize()
    self:RegisterEvent("ADDON_LOADED")
end

function NastrandirRaidTools:ADDON_LOADED(event, addonName)
    if event == "ADDON_LOADED" and addonName == "NastrandirRaidTools" then
        self.db = LibStub("AceDB-3.0"):New("NastrandirRaidToolsDB", defaultSavedVars)

        for moduleName, module in pairs(self.modules) do
            module:Enable()
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end

function NastrandirRaidTools:InitFrames()
    NastrandirRaidTools.MainFrame:Init()

    NastrandirRaidTools:AddMenu({
        {
            text = "Configuration",
            priority = 100,
            onClick = function(button, mouseButton)
                local frame = AceGUI:Create("NastrandirRaidToolsMainFrame")
                print("Frame", frame)
            end
        }
    })

    NastrandirRaidTools:HideInterface()
end

function NastrandirRaidTools:ToggleInterface()
    if not NastrandirRaidTools.main_frame then
        NastrandirRaidTools.InitFrames()
    end

    if NastrandirRaidTools.main_frame:IsShown() then
        NastrandirRaidTools:HideInterface()
    else
        NastrandirRaidTools:ShowInterface()
    end
end

function NastrandirRaidTools:ShowInterface()
    if not NastrandirRaidTools.main_frame then
        NastrandirRaidTools.InitFrames()
    end

    self:CreateMenu()
    NastrandirRaidTools.main_frame:Show()
end

function NastrandirRaidTools:HideInterface()
    NastrandirRaidTools.main_frame:Hide()
end

function NastrandirRaidTools:AddMenu(entries)
    if not self.menu then
        self.menu = {}
    end

    for index, value in pairs(entries) do
        table.insert(self.menu, value)
    end
end

function NastrandirRaidTools:GetMenu()
    if not self.menu then
        self.menu = {}
    end

    return self.menu
end

function NastrandirRaidTools:GetModuleDB(moduleName)
    if not NastrandirRaidTools.db then
        NastrandirRaidTools.db = LibStub("AceDB-3.0"):New("NastrandirRaidToolsDB", defaultSavedVars)
    end

    local modules = NastrandirRaidTools.db.profile.modules
    if not modules[moduleName] then
        modules[moduleName] = {}
    end

    return modules[moduleName]
end

function NastrandirRaidTools:CreateMenu()
    if not self.main_frame then
        return
    end

    if not self.menu then
        self.menu = {}
    end

    table.sort(self.menu, function(a, b)
        return a.priority < b.priority
    end)

    local scroll_frame = self.main_frame.side_panel.scroll_frame
    scroll_frame:ReleaseChildren()
    self.main_frame.menuButtons = {}
    for index, entry in ipairs(self.menu) do
        local button = AceGUI:Create("NastrandirRaidToolsMenuButton")
        self.main_frame.menuButtons[index] = button
        button:Initialize()
        button:Enable()
        button:SetTitle(entry.text)
        button:SetUserFunction(entry.onClick)
        scroll_frame:AddChild(button)
    end
end

function NastrandirRaidTools:ReleaseContent()
    local content_panel = self.main_frame.content_panel.scroll_frame
    content_panel:ReleaseChildren()
end

function NastrandirRaidTools:GetContentPanel()
    if not self.main_frame then
        return
    end

    return self.main_frame.content_panel.scroll_frame
end

function NastrandirRaidTools:GetTankClasses()
    return {
        DEATHKNIGHT = "Death Knight",
        DEMONHUNTER = "Demon Hunter",
        DRUID = "Druid",
        MONK = "Monk",
        PALADIN = "Paladin",
        WARRIOR = "Warrior"
    }
end

function NastrandirRaidTools:GetHealClasses()
    return {
        DRUID = "Druid",
        MONK = "Monk",
        PALADIN = "Paladin",
        PRIEST = "Priest",
        SHAMAN = "Shaman"
    }
end

function NastrandirRaidTools:GetMeleeClasses()
    return {
        DEATHKNIGHT = "Death Knight",
        DEMONHUNTER = "Demon Hunter",
        DRUID = "Druid",
        HUNTER = "Hunter",
        MONK = "Monk",
        PALADIN = "Paladin",
        ROGUE = "Rogue",
        SHAMAN = "Shaman",
        WARRIOR = "Warrior"
    }
end

function NastrandirRaidTools:GetRangedClasses()
    return {
        DRUID = "Druid",
        HUNTER = "Hunter",
        MAGE = "Mage",
        PRIEST = "Priest",
        SHAMAN = "Shaman",
        WARLOCK = "Warlock"
    }
end

function NastrandirRaidTools:GetAllowedClasses(role)
    if role == "TANK" then
        return NastrandirRaidTools:GetTankClasses()
    elseif role == "HEAL" then
        return NastrandirRaidTools:GetHealClasses()
    elseif role == "MELEE" then
        return NastrandirRaidTools:GetMeleeClasses()
    elseif role == "RANGED" then
        return NastrandirRaidTools:GetRangedClasses()
    end

    return {}
end

function NastrandirRaidTools:GetSortedKeySet(t, func)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, k)
    end

    table.sort(keys, func)

    return keys
end