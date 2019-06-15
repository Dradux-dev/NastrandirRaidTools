local CurrentGroupRoster = NastrandirRaidTools:NewModule("CurrentGroupRoster", "AceEvent-3.0")


function CurrentGroupRoster:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function CurrentGroupRoster:Init(force)
    if not self.groupRoster or force then
        self.groupRoster = {
            uid = {},
            main_uid = {},
            name = {},
            unknown = {}
        }
    end
end

function CurrentGroupRoster:GROUP_ROSTER_UPDATE()
    local Roster = NastrandirRaidTools:GetModule("Roster")

    CurrentGroupRoster:Init(true)

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
end

function CurrentGroupRoster:GetByUID(uid)
    CurrentGroupRoster:Init()

    return self.groupRoster.uid[uid]
end

function CurrentGroupRoster:GetByName(name)
    CurrentGroupRoster:Init()
    local uid = self.groupRoster.name[name]
    if uid then
        return CurrentGroupRoster:GetCurrentGroupRosterByUID(uid)
    end
end

function CurrentGroupRoster:GetAlt(uid)
    local Roster = NastrandirRaidTools:GetModule("Roster")
    CurrentGroupRoster:Init()
    local main_uid = Roster:GetMainUID(uid)
    local uid = self.groupRoster.main_uid[main_uid]
    if uid then
        return CurrentGroupRoster:GetCurrentGroupRosterByUID(uid)
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
        if i <= count then
            return self.groupRoster.unknown[i]
        end
    end
end

