local Roster = NastrandirRaidTools:NewModule("Roster")

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
            end
        }
    })
end

function Roster:ShowCurrentRoster()
    NastrandirRaidTools:ReleaseContent()
    NastrandirRaidTools.RosterFrame:Init()
end

function Roster:ShowDetails(uid)
    NastrandirRaidTools:ReleaseContent()
    NastrandirRaidTools.RosterFrame_Details:Init(uid)
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