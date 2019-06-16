local CurrentGroupRoster = NastrandirRaidTools:NewModule("CurrentGroupRoster", "AceEvent-3.0")


function CurrentGroupRoster:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function CurrentGroupRoster:Init(force)
    if not self.listener then
        self.listener = {}
    end

    if not self.groupRoster or force then
        self.groupRoster = {
            uid = {},
            main_uid = {},
            name = {},
            unknown = {}
        }
    end
end

function CurrentGroupRoster:Scan()
    local Roster = NastrandirRaidTools:GetModule("Roster")

    CurrentGroupRoster:Init(true)

    -- Iterate Group Roster
    for unit in NastrandirRaidTools:IterateGroupMembers() do
        local name = UnitName(unit)
        local uid = Roster:GetCharacterByName(name)
        if uid then
            local subgroup
            if IsInRaid() then
                local index = tonumber(string.sub(unit, 5))
                _, _, subgroup = GetRaidRosterInfo(index)
            end

            self.groupRoster.uid[uid] = {
                name = name,
                class = Roster:GetCharacterClass(uid),
                role = Roster:GetCharacterRole(uid),
                subgroup = subgroup or 1
            }

            self.groupRoster.main_uid[Roster:GetMainUID(uid)] = uid
            self.groupRoster.name[name] = uid
        else
            table.insert(self.groupRoster.unknown, name)
        end
    end

   -- Notify Listener
    for entry in CurrentGroupRoster:IterateListener() do
        entry.callback(entry.listener)
    end
end

function CurrentGroupRoster:GetByUID(uid)
    CurrentGroupRoster:Init()

    return self.groupRoster.uid[uid]
end

function CurrentGroupRoster:GetByName(name)
    CurrentGroupRoster:Init()
    local uid = self.groupRoster.name[name]
    if uid then
        return CurrentGroupRoster:GetByUID(uid)
    end
end

function CurrentGroupRoster:GetAlt(uid)
    local Roster = NastrandirRaidTools:GetModule("Roster")
    CurrentGroupRoster:Init()

    local main_uid = Roster:GetMainUID(uid)

    local uid = self.groupRoster.main_uid[main_uid]
    if uid then
        return CurrentGroupRoster:GetByUID(uid)
    end
end

function CurrentGroupRoster:IsUnknown(name)
    CurrentGroupRoster:Init()
    local pos = NastrandirRaidTools:FindInTable(self.groupRoster.unknown, name)
    return (pos and true) or false
end

function CurrentGroupRoster:IterateUnknown()
    CurrentGroupRoster:Init()
    local i = 1
    local count = #self.groupRoster.unknown
    return function()
        local ret
        if i <= count then
            ret = self.groupRoster.unknown[i]
        end

        i = i + 1
        return ret
    end
end

function CurrentGroupRoster:RegisterListener(listener, callback)
    CurrentGroupRoster:Init()
    local pos = NastrandirRaidTools:FindInTableIf(self.listener, function(entry)
        return entry.listener == listener
    end)

    if pos then
        self.listener[pos].callback = callback
    else
        table.insert(self.listener, {
            listener = listener,
            callback = callback
        })
    end
end

function CurrentGroupRoster:UnRegisterListener(listener)
    CurrentGroupRoster:Init()
    local pos = NastrandirRaidTools:FindInTableIf(self.listener, function(entry)
        return entry.listener == listener
    end)

    if pos then
        table.remove(self.listener, pos)
    end
end

function CurrentGroupRoster:IterateListener()
    CurrentGroupRoster:Init()
    local i = 1
    local count = #self.listener

    return function()
        local ret
        repeat
            ret = nil

            if i <= count and type(self.listener[i].callback) == "function" then
                ret = self.listener[i]
            end

            i = i + 1
        until ret or i > count

        return ret
    end
end

function CurrentGroupRoster:GROUP_ROSTER_UPDATE()
    CurrentGroupRoster:Scan()
end

function CurrentGroupRoster:PLAYER_ENTERING_WORLD()
    CurrentGroupRoster:Scan()
end