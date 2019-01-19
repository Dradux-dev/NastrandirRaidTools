local Attendance = NastrandirRaidTools:NewModule("Attendance")
local AceGUI = LibStub("AceGUI-3.0")

--[[
Attendance = {
    raids = {
        [20181219] = {
            name = "Uldir",
            date = 20181219,
            start_time = 1915,
            end_time = 2245
        }
    },
    states = {
        ["Shielddux-20181207-124507"] = {
            name = "Im Raid"
            TrackAlts = true,
            order = 1,
            LogMessages = {
                Enter = "<Main> tritt dem Raid bei.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> verlässt den Raid."
            }
        },
        ["Shielddux-20181207-124603"] = {
            name = "Ersatzbank",
            TrackAlts = true,
            order = 2,
            LogMessages = {
                Enter = "<Main> geht auf die Ersatzbank.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> verlässt die Ersatzbank."
            }
        },
        ["Shielddux-20181207-124643"] = {
            name = "Abgemeldet",
            TrackAlts = true,
            order = 3,
            LogMessages = {
                Enter = "<Main> ist jetzt abgemeldet.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> ist jetzt nicht mehr abgemeldet.",
            }
        },
        ["Shielddux-20181207-124720"] = {
            name = "Fehlt",
            TrackAlts = true,
            order = 4,
            LogMessages = {
                Enter = "<Main> fehlt.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> fehlt jetzt nicht mehr.
            }
        },
        ["Shielddux-20181207-124900"] = {
            name = "Frei",
            TrackAlts = true,
            order = 5,
            LogMessages = {
                Enter = "<Main> hat jetzt frei.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> hat jetzt nicht mehr frei.",
            }
        }
        ["Shielddux-20181207-125007"] = {
            name = "Urlaub",
            TrackAlts = true, -- Don't take care of this raid
            order = 6,
            LogMessages = {
                Enter = "<Main> ist jetzt im Urlaub.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> ist jetzt nicht mehr im Urlaub."
            }
        }
    },
    analytics = {
        ["Shielddux-20181207-134509"] = {
            name = "Teilgenommen",
            order = 1,
            states = {
                "Shielddux-20181207-124507", -- Im Raid,
                "Shielddux-20181207-124603", -- Ersatzbank
                "Shielddux-20181207-124900", -- Frei
            },
            colors = {
                {
                    value = 0,
                    color = {1, 0, 0}
                }
                {
                    value = 0.5,
                    color = {1, 1, 0}
                }
                {
                    value = 1,
                    color = {0, 1, 0}
                }
            }
        },
        ["Shielddux-20181207-134712"] = {
            name = "Im Raid",
            order = 2,
            states = {
                "Shielddux-20181207-124507", -- Im Raid
            }
        },
        ["Abgemeldet"] = {
            "Abgemeldet"
        },
        ["Fehlt"] = {
            "Fehlt"
        }
    },
    participation = {
        [20181219] = {
            {
                -- Entered raid
                member = "Shielddux-20181219-1223",
                time = 1915,
                state = "In Raid",
                order = 1
            },
            {
                -- Swapped to an alt
                member = "Shielddux-20181219-1227"
                time = 1930,
                state = "In Raid",
                order = 2
            }
        }
    }
}
]]

function Attendance:Initialize()
end

function Attendance:OnEnable()
    print("Adding Attendance menu entry")
    NastrandirRaidTools:AddMenu({
        {
            text = "Attendance",
            priority = 1,
            onClick = function(button, mouseButton)
                Attendance:ShowAttendance()
            end
        }
    })
end

function Attendance:ShowAttendance()
    NastrandirRaidTools:ReleaseContent()
    local content_panel = NastrandirRaidTools:GetContentPanel()
    local attendance_frame = AceGUI:Create("NastrandirRaidToolsAttendance")
    attendance_frame:Initialize()
    attendance_frame:SetWidth(content_panel.frame:GetWidth())
    content_panel:AddChild(attendance_frame)
end

function Attendance:ShowRaidList()
    NastrandirRaidTools:ReleaseContent()
    local content_panel = NastrandirRaidTools:GetContentPanel()
    local attendance_frame = AceGUI:Create("NastrandirRaidToolsAttendanceRaids")
    attendance_frame:Initialize()
    attendance_frame:SetWidth(content_panel.frame:GetWidth())
    content_panel:AddChild(attendance_frame)
end

function Attendance:ShowRaidLog(raid_id)

end

function Attendance:ShowConfiguration()
    NastrandirRaidTools:ReleaseContent()
    local content_panel = NastrandirRaidTools:GetContentPanel()
    local attendance_frame = AceGUI:Create("NastrandirRaidToolsAttendanceConfiguration")
    attendance_frame:Initialize()
    attendance_frame:SetWidth(content_panel.frame:GetWidth())
    content_panel:AddChild(attendance_frame)
end

function Attendance:ShowRaid(uid)
    NastrandirRaidTools:ReleaseContent()
    local content_panel = NastrandirRaidTools:GetContentPanel()
    local raid_frame = AceGUI:Create("NastrandirRaidToolsAttendanceRaidDetails")
    raid_frame:Initialize()
    raid_frame:SetUID(uid)
    raid_frame:Load()
    raid_frame:SetWidth(content_panel.frame:GetWidth())
    content_panel:AddChild(raid_frame)
end

function Attendance:ShowRaidLog(uid)
    print("Showing raid log", uid)
end

function Attendance:ShowRaidRecording(uid)
    NastrandirRaidTools:ReleaseContent()
    local content_panel = NastrandirRaidTools:GetContentPanel()
    local raid_frame = AceGUI:Create("NastrandirRaidToolsAttendanceRaidRecording")
    raid_frame:Initialize()
    raid_frame:SetUID(uid)
    raid_frame:Load()
    raid_frame:SetWidth(content_panel.frame:GetWidth())
    content_panel:AddChild(raid_frame)
end

function Attendance:GetRaidList(start_date)
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.raids then
        db.raids = {}
    end

    local raid_list = {
        list = {},
        order = {}
    }

    for raid_uid, info in pairs(db.raids) do
        if info.date >= (start_date or 19700101)then
            local date = NastrandirRaidTools:SplitDate(info.date)
            raid_list.list[raid_uid] = string.format("%s, %02d.%02d.%04d", info.name, date.day, date.month, date.year)
            table.insert(raid_list.order, raid_uid)
        end
    end

    table.sort(raid_list.order, function(a, b)
        local date_a = db.raids[a].date
        local date_b = db.raids[b].date

        return date_a > date_b
    end)

    return raid_list
end

function Attendance:GetRaid(raid_uid)
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.raids then
        db.raids = {}
    end

    return db.raids[raid_uid] or {
        name = "Unknown",
        date = 19700101,
        start_time = 1900,
        end_time = 2300
    }
end