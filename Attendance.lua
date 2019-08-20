local Attendance = NastrandirRaidTools:NewModule("Attendance")
local StdUi = LibStub("StdUi")

--[[
Attendance = {
    defaults = {
        name = "New Raid",
        startTime = 1915,
        endTime = 2245
    },
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
                ["Shielddux-20181207-124507"] = true, -- Im Raid,
                ["Shielddux-20181207-124603"] = true, -- Ersatzbank
                ["Shielddux-20181207-124900"] = true, -- Frei
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
                ["Shielddux-20181207-124507"] = true, -- Im Raid
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
    NastrandirRaidTools:AddMenu({
        {
            text = "Attendance",
            priority = 1,
            onClick = function(button, mouseButton)
                Attendance:ShowAttendance()
            end,
            contextMenu = {
                {
                    title = "Add Raid",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        Attendance:NewRaid()
                    end
                },
                {
                    title = "Edit Raid",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        local uid = Attendance:GetLastRaid()
                        if uid then
                            Attendance:ShowRaid(uid)
                        end
                    end
                },
                {
                    title = "Record",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        local uid = Attendance:GetLastRaid()
                        if uid then
                            Attendance:ShowRaidRecording(uid)
                        end
                    end
                },
                {
                    isSeparator = true
                },
                {
                    title = "Config",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        Attendance:ShowConfiguration()
                        self.configuration:SelectGeneral()
                    end
                },
                {
                    title = "Config: States",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        Attendance:ShowConfiguration()
                        self.configuration:SelectStates()
                    end
                },
                {
                    title = "Config: Analytics",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        Attendance:ShowConfiguration()
                        self.configuration:SelectAnalytics()
                    end
                },
                {
                    title = "Config: Sections",
                    close = true,
                    callback = function(itemFrame)
                        local context = itemFrame.mainContext or itemFrame:GetParent()
                        context:CloseMenu()

                        Attendance:ShowConfiguration()
                        self.configuration:SelectSections()
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
                }
            }
        }
    })
end

function Attendance:ShowAttendance()
    local content =  NastrandirRaidTools:GetContent()


    if not self.frame then
        self.frame = StdUi:NastrandirRaidTools_Attendance(content.child)
        table.insert(content.children, self.frame)
        self.frame:Hide()
    end

    NastrandirRaidTools:ReleaseContent()
    StdUi:GlueTop(self.frame, content.child, 0, 0, "LEFT")
    self.frame:Show()
end

function Attendance:ShowRaidList()
    local content = NastrandirRaidTools:GetContent()

    if not self.raids then
        self.raids = StdUi:NastrandirRaidTools_Attendance_Raids(content.child)
        table.insert(content.children, self.raids)
        self.raids:Hide()
    end

    NastrandirRaidTools:ReleaseContent()
    StdUi:GlueTop(self.raids, content.child, 0, 0, "LEFT")
    self.raids:Show()
end

function Attendance:ShowRaid(uid)
    local content = NastrandirRaidTools:GetContent()

    if not self.details then
        self.details = StdUi:NastrandirRaidTools_Attendance_RaidDetails(content.child)
        table.insert(content.children, self.details)
        self.details:Hide()
    end

    NastrandirRaidTools:ReleaseContent()
    StdUi:GlueTop(self.details, content.child, 0, 0, "LEFT")
    self.details:SetUID(uid)
    self.details:Load()
    self.details:Show()
end

function Attendance:ShowRaidLog(raid_id)

end

function Attendance:ShowConfiguration()
    local content = NastrandirRaidTools:GetContent()

    if not self.configuration then
        self.configuration = StdUi:NastrandirRaidTools_Attendance_Configuration(content.child)
        table.insert(content.children, self.configuration)
        self.configuration:Hide()
    end

    NastrandirRaidTools:ReleaseContent()
    StdUi:GlueTop(self.configuration, content.child, 0, 0, "LEFT")
    self.configuration:Show()
end


function Attendance:ShowRaidLog(uid)
    print("Showing raid log", uid)
end

function Attendance:ShowRaidRecording(uid)
    local content = NastrandirRaidTools:GetContent()

    if not self.record then
        self.record = StdUi:NastrandirRaidTools_Attendance_RaidRecording(content.child)
        table.insert(content.children, self.record)
        self.record:Hide()
    end

    NastrandirRaidTools:ReleaseContent()
    StdUi:GlueTop(self.record, content.child, 0, 0, "LEFT")
    self.record:SetUID(uid)
    self.record:Load()
    self.record:Show()
end

function Attendance:GetRaidList(start_date, end_date)
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.raids then
        db.raids = {}
    end

    local raid_list = {
        list = {},
        order = {}
    }

    for raid_uid, info in pairs(db.raids) do
        if info.date >= (start_date or 19700101) and info.date <= (end_date or 20480101) then
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

function Attendance:GetStates()
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.states then
        db.states = {}
    end

    local t = {}
    for uid, data in pairs(db.states) do
        table.insert(t, uid)
    end

    return t
end

function Attendance:GetState(uid)
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.states then
        db.states = {}
    end

    return db.states[uid]
end

function Attendance:GetAnalytic(uid)
    return NastrandirRaidTools:GetModuleDB("Attendance", "analytics", uid)
end

function Attendance:GetRaidParticipation(raid_uid)
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.participation then
        db.participation = {}
    end

    return db.participation[raid_uid] or {}
end

function Attendance:NewRaid()
    -- Get UID
    local uid = NastrandirRaidTools:CreateUID("Attendance-Raid")

    -- Do the DB stuff
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.raids then
        db.raids = {}
    end

    if not db.defaults then
        db.defaults = {}
    end

    db.raids[uid] = {
        name = db.defaults.name or "New Raid",
        date = NastrandirRaidTools:Today(),
        start_time = db.defaults.startTime or 1900,
        end_time = db.defaults.endTime or 2300
    }

    local Attendance = NastrandirRaidTools:GetModule("Attendance")
    Attendance:ShowRaid(uid)
end

function Attendance:GetAnalyticByOrder(order)
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.analytics then
        db.analytics = {}
    end

    for uid, analytic in pairs(db.analytics) do
        if analytic.order == order then
            return analytic
        end
    end
end

function Attendance:GetLastRaid()
    local db = NastrandirRaidTools:GetModuleDB("Attendance")

    if not db.raids then
        db.raids = {}
    end

    local last
    for uid, raid in pairs(db.raids) do
        if not last then
            last = {
                uid = uid,
                raid = raid
            }
        elseif last.raid.date < raid.date then
            last = {
                uid = uid,
                raid = raid
            }
        elseif last.raid.date == raid.date and last.raid.start_time < raid.start_time then
            last = {
                uid = uid,
                raid = raid
            }
        end
    end

    return (last or {}).uid
end

function Attendance:IsStateTrackingAlts(uid)
    local state = Attendance:GetState(uid)
    if state then
        return state.TrackAlts
    end

    return false
end

function Attendance:Analyse(start_raid, end_raid)
    local Roster = NastrandirRaidTools:GetModule("Roster")

    local start_date = Attendance:GetRaid(start_raid).date
    local end_date = Attendance:GetRaid(end_raid).date

    local attendance_data = {}
    local raid_list = Attendance:GetRaidList(start_date, end_date).order

    -- Parse participation
    local raid_count = 0
    for _, raid_uid in ipairs(raid_list) do
        raid_count = raid_count + 1
        local raid = Attendance:GetRaid(raid_uid)

        for index, entry in ipairs(Attendance:GetRaidParticipation(raid_uid)) do
            local main_uid = Roster:GetMainUID(entry.member)

            if not attendance_data[main_uid] then
                attendance_data[main_uid] = {
                    state = nil,
                    timestamp = nil,
                    duration = 0,
                    states = {}
                }
            end

            local player = attendance_data[main_uid]
            if not player.state then
                -- First occurence in the actual raid
                player.state = entry.state
                player.timestamp = entry.time
            else
                local state = Attendance:GetState(player.state)
                local duration = NastrandirRaidTools:GetDuration(player.timestamp, entry.time)
                player.duration = player.duration + duration
                player.states[player.state] = {
                    total = ((player.states[player.state] or {}).total or 0) + duration,
                    tolerance = ((player.states[player.state] or {}).tolerance or 0) + math.min(duration, state.tolerance or 0)
                }
                player.state = entry.state
                player.timestamp = entry.time
            end
        end

        -- Add duration of last state til raid end
        for main_uid, player in pairs(attendance_data) do
            if player.state then
                local state = Attendance:GetState(player.state)
                local duration = NastrandirRaidTools:GetDuration(player.timestamp, raid.end_time)
                player.duration = player.duration + duration
                player.states[player.state] = {
                    total = ((player.states[player.state] or {}).total or 0) + duration,
                    tolerance = ((player.states[player.state] or {}).tolerance or 0) + math.min(duration, state.tolerance or 0)
                }
                player.state = nil
                player.timestamp = nil
            end
        end
    end

    print(string.format("Scanned %d raids", raid_count))

    return attendance_data
end

function Attendance:GetRaidTimeEvents(uid)
    local Roster = NastrandirRaidTools:GetModule("Roster")
    local raid = NastrandirRaidTools:GetModuleDB(Attendance:GetName(), "raids", uid)
    local participation = NastrandirRaidTools:GetModuleDB(Attendance:GetName(), "participation", uid)
    local events = {}
    local cache = {
        sections = {},
        state = {},
        character = {}
    }

    local function GetTimeEvent(time)
        for _, event in ipairs(events) do
            if time == event.time then
                return event
            end
        end
    end

    local function ModifyTimeEvent(time, modifier)
        local add = false
        local event = GetTimeEvent(time)

        if not event then
            event = {
                time = time,
                data = {}
            }

            add = true
        end

        if modifier then
            modifier(event)
        end

        if add then
            table.insert(events, event)
        end
    end

    local function CompareTimeOrder(a, b)
        if a.time < b.time then
            return true
        elseif a.time > b.time then
            return false
        end

        return a.order < b.order
    end

    if raid and raid["sections"] then
        table.sort(raid["sections"], CompareTimeOrder)
        for _, entry in ipairs(raid["sections"]) do
            ModifyTimeEvent(entry.time, function(event)
                table.insert(event.data, {
                    event = "section_changed",
                    section = entry.section,
                    old = cache.sections[entry.section],
                    new = entry.value,
                    order = table.getn(event.data) + 1
                })

                cache.sections[entry.section] = entry.value
            end)
        end
    end

    if participation then
        table.sort(participation, CompareTimeOrder)
        for _, entry in ipairs(participation) do
            ModifyTimeEvent(entry.time, function(event)
                local main_uid = Roster:GetMainUID(entry.member)
                local old_state = cache.state[main_uid]
                local old_character = cache.character[main_uid]

                if old_state ~= entry.state then
                    table.insert(event.data, {
                        event = "state_changed",
                        main = main_uid,
                        old = old_state,
                        new = entry.state,
                        order = table.getn(event.data) + 1
                    })
                end

                if old_character and old_character ~= entry.member then
                    table.insert(event.data, {
                        event = "character_changed",
                        main = main_uid,
                        old = old_character,
                        new = entry.member,
                        order = table.getn(event.data) + 1
                    })
                end

                cache.state[main_uid] = entry.state
                cache.character[main_uid] = entry.member
            end)
        end
    end

    -- Sort events by time
    table.sort(events, function(a, b)
        return a.time < b.time
    end)

    ViragDevTool_AddData(events, "Time Events")
    return events
end