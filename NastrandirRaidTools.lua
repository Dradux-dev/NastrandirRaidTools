local Dialog = LibStub("LibDialog-1.0")
local AceGUI = LibStub("AceGUI-3.0")
local StdUi = LibStub("StdUi")

SLASH_NASTRANDIRRAIDTOOLS1 = "/nrt"

function SlashCmdList.NASTRANDIRRAIDTOOLS(cmd, editbox)
    NastrandirRaidTools:ToggleInterface()
end

local defaultSavedVars = {
    profile = {
        window = {
            x = 0,
            y = 150,
            width = 1400,
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

function NastrandirRaidTools:ToggleInterface()
    if not self.window then
        self.window = StdUi:NastrandirRaidTools_MainFrame()

        self:AddMenu({
            {
                text = "Profile",
                priority = 100,
                onClick = function(button, mouseButton)
                    NastrandirRaidTools:ShowProfiles()
                end
            }
        })
    end

    ToggleFrame(self.window)
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

function NastrandirRaidTools:GetDB()
    if not NastrandirRaidTools.db then
        NastrandirRaidTools.db = LibStub("AceDB-3.0"):New("NastrandirRaidToolsDB", defaultSavedVars)
    end

    return NastrandirRaidTools.db
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
    if not self.window then
        return
    end

    if not self.menu then
        self.menu = {}
    end

    table.sort(self.menu, function(a, b)
        if a.priority == b.priority then
            return a.text < b.text
        end

        return a.priority < b.priority
    end)

    for index, entry in ipairs(self.menu) do
        if not entry.button then
            entry.button = StdUi:NastrandirRaidTools_MenuButton(self.window.menu.child, entry.text, entry.onClick)
        end

        entry.button:ClearAllPoints()
        if index == 1 then
            StdUi:GlueTop(entry.button, self.window.menu.child, 0, 0, "LEFT")
        else
            local lastButton = self.menu[index -1].button
            StdUi:GlueBelow(entry.button, lastButton, 0, -2)
        end

        if not entry.button:IsShown() then
            entry.button:Show()
        end
    end
end

function NastrandirRaidTools:ReleaseContent()
    for _, frame in ipairs(self.window.content.children) do
        frame:Hide()
    end
end

function NastrandirRaidTools:GetContent()
    if not self.window then
        return
    end

    return self.window.content
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
    if role == NastrandirRaidTools.role_types.tank then
        return NastrandirRaidTools:GetTankClasses()
    elseif role == NastrandirRaidTools.role_types.heal then
        return NastrandirRaidTools:GetHealClasses()
    elseif role == NastrandirRaidTools.role_types.melee then
        return NastrandirRaidTools:GetMeleeClasses()
    elseif role == NastrandirRaidTools.role_types.ranged then
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

function NastrandirRaidTools:SplitDate(date)
    return {
        day = date % 100,
        month = math.floor(date / 100) % 100,
        year = math.floor(date / 10000)
    }
end

function NastrandirRaidTools:PackDate(date)
    return (date.year * 10000) + (date.month * 100) + date.day
end

function NastrandirRaidTools:SplitTime(time)
    return {
        hours = math.floor(time / 100),
        minutes = time % 100
    }
end

function NastrandirRaidTools:PackTime(time)
    return (time.hours * 100) + time.minutes
end

function NastrandirRaidTools:GetDuration(start_time, end_time)
    local duration = 0

    if end_time < start_time then
        end_time = end_time + 2400
    end

    local s = NastrandirRaidTools:SplitTime(start_time)
    local e = NastrandirRaidTools:SplitTime(end_time)

    while(NastrandirRaidTools:PackTime(s) < NastrandirRaidTools:PackTime(e)) do
        if s.hours < e.hours then
            duration = duration + (60 - s.minutes)
            s.minutes = 0
            s.hours = s.hours + 1
        else
            duration = duration + (e.minutes - s.minutes)
            s.minutes = e.minutes
            s.hours = e.hours
        end
    end

    return duration
end

function NastrandirRaidTools:CreateUID(type)
    local name = UnitName("player")
    local today = date("%d%m%y")
    local now = date("%H%M%S")

    return string.format("%s-%s-%s-%s", (type or "Generic"), name, today, now)
end

function NastrandirRaidTools:Today()
    return tonumber(date("%Y%m%d"))
end

function NastrandirRaidTools:ShowProfiles()
    local content = NastrandirRaidTools:GetContent()

    if not self.profiles then
        self.profiles = StdUi:NastrandirRaidTools_Profiles(content.child)
        table.insert(content.children, self.profiles)
        self.profiles:Hide()
    end

    NastrandirRaidTools:ReleaseContent()

    self.profiles:ClearAllPoints()
    StdUi:GlueTop(self.profiles, content.child, 0, 0, "LEFT")
    self.profiles:Show()
end

function NastrandirRaidTools:GetUserPermission(parent, options)
    if not self.ask then
        local ask = StdUi:Window(parent, "", 360, 140)
        self.ask = ask
        ask:SetFrameLevel(100)

        local yes = StdUi:Button(ask, 80, 24, "")
        ask.yes = yes
        yes:SetPoint("RIGHT", ask, "CENTER", -5, 0)

        local no = StdUi:Button(ask, 80, 24, "")
        ask.no = no
        no:SetPoint("LEFT", ask, "CENTER", 5, 0)

        ask:Hide()
    end

    self.ask:SetParent(parent)
    self.ask:SetWindowTitle(options.title or "Are you sure?")
    self.ask.yes:SetText(options.yes or "Yes")
    self.ask.no:SetText(options.no or "No")

    self.ask.yes:SetScript("OnClick", function()
        if options.callbackYes then
            options.callbackYes()
        end
        self.ask:Hide()
    end)

    self.ask.no:SetScript("OnClick", function()
        if options.callbackNo then
            options.callbackNo()
        end
        self.ask:Hide()
    end)
    self.ask:SetPoint("CENTER")
    self.ask:Show()
end

function NastrandirRaidTools:FindInTable(t, needle, assosiative)
    local result = {}

    if not assosiative then
        for pos, value in pairs(t) do
            if value == needle then
                table.insert(result, pos)
            end
        end
    else
        for pos, value in ipairs(t) do
            if value == needle then
                table.insert(result, pos)
            end
        end
    end

    if #result == 0 then
        return
    elseif #result == 1 then
        return result[1]
    end

    return result
end

function NastrandirRaidTools:FindInTableIf(t, callback, assosiative)
    local result = {}

    if not assosiative then
        for pos, value in pairs(t) do
            if callback(value) then
                table.insert(result, pos)
            end
        end
    else
        for pos, value in ipairs(t) do
            if callback(value) then
                table.insert(result, pos)
            end
        end
    end

    if #result == 0 then
        return
    elseif #result == 1 then
        return result[1]
    end

    return result
end