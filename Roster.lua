local Roster = NastrandirRaidTools:NewModule("Roster")
local StdUi = LibStub("StdUi")

--[[
roster = {
    characters = {
        ["Shielddux-141118-005945"] = {
            name = "Cothar",
            raidmember = true,
            class = "MONK",
            role = "TANK"
            alts = {
                Shielddux-141118-010237,
                Shielddux-141118-010411
            }
        },
        ["Shielddux-141118-010237"] = {
            name = "Rovur",
            class = "DEATHKNIGHT",
            role = "TANK",
            main = "Shielddux-1141118-0005945"
        },
        ["Shielddux-141118-010411"] = {
            name = "Firghor",
            class = "DEMONHUNTER",
            role = "TANK",
            main = "Shielddux-1141118-0005945"
        },
    },
    recruitment = {
        {
            {
                class = "DRUID",
                role = "MELEE",
            }
        }
    }
}
]]

function Roster:OnInitialize()
end

function Roster:OnEnable()
    NastrandirRaidTools:AddMenu({
        {
            text = "Roster",
            priority = 1,
            onClick = function(button, mouseButton)
                Roster:ShowCurrentRoster()
            end,
            contextMenu = {
                {
                    title = "Add Tank",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()
                        
                        Roster:AddMember(
                                NastrandirRaidTools:GetFirstKey(NastrandirRaidTools:GetTankClasses(), true),
                                NastrandirRaidTools.role_types.tank
                        )
                    end
                },
                {
                    title = "Add Melee",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        Roster:AddMember(
                                NastrandirRaidTools:GetFirstKey(NastrandirRaidTools:GetMeleeClasses(), true),
                                NastrandirRaidTools.role_types.melee
                        )
                    end
                },
                {
                    title = "Add Ranged",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        Roster:AddMember(
                                NastrandirRaidTools:GetFirstKey(NastrandirRaidTools:GetRangedClasses(), true),
                                NastrandirRaidTools.role_types.ranged
                        )
                    end
                },
                {
                    title = "Add Healer",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        Roster:AddMember(
                                NastrandirRaidTools:GetFirstKey(NastrandirRaidTools:GetHealClasses(), true),
                                NastrandirRaidTools.role_types.heal
                        )
                    end
                },
                {
                  isSeparator = true
                },
                {
                    title = "Close",
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()
                    end
                },
            }
        }
    })
end

function Roster:ShowCurrentRoster()
    local content = NastrandirRaidTools:GetContent()

    if not self.frame then
        self.frame = StdUi:NastrandirRaidTools_Roster(content.child)
        table.insert(content.children, self.frame)
        self.frame:Hide()
    end

    NastrandirRaidTools:ReleaseContent()
    StdUi:GlueTop(self.frame, content.child, 0, 0, "LEFT")
    self.frame:LoadRoster()
    self.frame:Show()
end

function Roster:ShowDetails(uid)
    local content = NastrandirRaidTools:GetContent()

    if not self.details then
        self.details = StdUi:NastrandirRaidTools_Roster_Details(content.child)
        table.insert(content.children, self.details)
        self.details:Hide()
    end

    NastrandirRaidTools:ReleaseContent()
    StdUi:GlueTop(self.details, content.child, 0, 0, "LEFT")
    self.details:LoadData(uid)
    self.details:Show()
end

function Roster:CreateUID()
    return NastrandirRaidTools:CreateUID("Roster-Character")
end

function Roster:GetCharacter(uid)
    local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")

    if not RosterDB.characters then
        RosterDB.characters = {}
    end

    if RosterDB.characters[uid] then
        return RosterDB.characters[uid]
    end

    return {
        name = "Unknown",
        role = "TANK",
        class = "MONK",
        raidmember = false,
        alts = {},
    }
end

function Roster:GetAlts(uid)
    local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")

    if not RosterDB.characters then
        RosterDB.characters = {}
    end

    local t = {}
    for alt_uid, alt in pairs(RosterDB.characters) do
        if alt.main and alt.main == uid then
            t[alt_uid] = alt
        end
    end

    return t
end

function Roster:GetMainCharacters()
    local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")

    if not RosterDB.characters then
        RosterDB.characters = {}
    end

    local t = {}
    for uid, data in pairs(RosterDB.characters) do
        if not data.main then
            t[uid] = data.name
        end
    end

    return t
end

function Roster:GetRaidmember()
    local db = NastrandirRaidTools:GetModuleDB("Roster")

    if not db.characters then
        db.characters = {}
    end

    local t = {}
    for uid, data in pairs(db.characters) do
        if not data.main and data.raidmember then
            table.insert(t, uid)
        end
    end

    return t
end

function Roster:GetMainCharacter(uid)
    local character = Roster:GetCharacter(uid)

    if character.main then
        character = Roster:GetCharacter(character.main)
    end

    return character
end

function Roster:DeleteCharacter(uid)
    local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")

    if not RosterDB.characters then
        RosterDB.characters = {}
    end

    RosterDB.characters[uid] = nil
end

function Roster:GetCharacterName(uid)
    local db = NastrandirRaidTools:GetModuleDB("Roster")

    if not db.characters then
        db.characters = {}
    end

    if not db.characters[uid] then
        return "Unknown"
    end

    return db.characters[uid].name
end

function Roster:GetCharacterClass(uid)
    local db = NastrandirRaidTools:GetModuleDB("Roster")

    if not db.characters then
        db.characters = {}
    end

    if not db.characters[uid] then
        return "MONK"
    end

    return db.characters[uid].class
end

function Roster:GetCharacterRole(uid)
    local db = NastrandirRaidTools:GetModuleDB("Roster")

    if not db.characters then
        db.characters = {}
    end

    if not db.characters[uid] then
        return "TANK"
    end

    return db.characters[uid].role
end

function Roster:GetMainUID(uid)
    local character = Roster:GetCharacter(uid)

    if character.main then
        return character.main
    end

    return uid
end

function Roster:AddMember(class, role, name, main, skipDetails)
    local db = NastrandirRaidTools:GetModuleDB("Roster")

    if not db.characters then
        db.characters = {}
    end

    local uid = Roster:CreateUID()

    db.characters[uid] = {
        name = name or "New Player",
        raidmember = true,
        class = class,
        role = role,
        alts = {}
    }

    if main then
        db.characters[uid].alts = nil
        db.characters[uid].main = main
    end

    if not skipDetails then
        Roster:ShowDetails(uid)
    end
end

function Roster:GetCharacterByName(name)
    return NastrandirRaidTools:FindInTableIf(
            NastrandirRaidTools:GetModuleDB("Roster", "characters"),
            function(character)
                return character.name == name
            end,
            true
    )
end