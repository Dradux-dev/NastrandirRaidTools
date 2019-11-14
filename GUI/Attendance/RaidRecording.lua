local StdUi = LibStub("StdUi")

local role_values = {
    ["TANK"] = 1,
    ["HEAL"] = 2,
    ["MELEE"] = 3,
    ["RANGED"] = 4
}

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidRecording", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 300
    local column_height = 400

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)
    widget.content_group = {}

    local timeline = StdUi:NastrandirRaidTools_Attendance_RaidRecordingTimeline(widget, width - 10)
    widget.timeline = timeline
    StdUi:GlueTop(timeline, widget, 5, -40, "LEFT")

    local section = StdUi:Button(widget, 80, 24, "Section")
    widget.section = section
    StdUi:GlueTop(section, widget, 5, -5, "LEFT")

    local auto = StdUi:Button(widget, 24, 24, "")
    widget.auto = auto
    local icon = auto:CreateTexture(nil, "OVERLAY")
    auto.icon = icon
    icon:SetBlendMode("BLEND")
    icon:SetWidth(auto:GetWidth())
    icon:SetHeight(auto:GetHeight())
    icon:SetPoint("LEFT", auto, "LEFT", 0, 0)
    icon:SetTexture("Interface\\AddOns\\NastrandirRaidTools\\media\\icons\\gear")
    local tooltip = StdUi:FrameTooltip(auto, "Auto Record", "AutoRecord_Tooltip", "BOTTOMLEFT", false)
    auto.tooltip = tooltip
    tooltip:Hide()
    StdUi:GlueTop(auto, widget, -5, -5, "RIGHT")

    function widget:HideChildren()
        for index, child in ipairs(widget.content_group) do
            child:Hide()
        end
    end

    function widget:SetUID(uid)
        widget.uid = uid
    end

    function widget:GetUID()
        return widget.uid
    end

    function widget:GetStates()
        local states = {}
        local db = NastrandirRaidTools:GetModuleDB("Attendance")


        if not db.states then
            db.states = {}
        end

        for uid, state in pairs(db.states) do
            table.insert(states, uid)
        end

        table.sort(states, function(a, b)
            local state_a = db.states[a]
            local state_b = db.states[b]

            return state_a.Order < state_b.Order
        end)

        return states
    end

    function widget:GetStateName(uid)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        return db.states[uid].Name
    end

    function widget:SortCompare(a, b)
        -- First off sort by role
        if role_values[a.role] < role_values[b.role] then
            return true
        elseif role_values[a.role] > role_values[b.role] then
            return false
        end

        -- Sort by class
        if a.class < b.class then
            return true
        elseif a.class > b.class then
            return false
        end

        -- Sort by name
        return a.name < b.name
    end

    function widget:GetColumn()
        -- find unused column
        for index, column in ipairs(widget.content_group) do
            if not column:IsShown() then
                return column
            end
        end

        -- create new column: no unused column available
        local column = StdUi:NastrandirRaidTools_Attendance_RaidRecordingStateColumn(widget, 200, column_height)
        table.insert(widget.content_group, column)
        return column
    end

    function widget:GetTime()
        --[[local time = {
            hours = widget.hours:GetValue(),
            minutes = widget.minutes:GetValue()
        }

        if widget.timeline then
            print("Timeline", widget.timeline:GetTime())
        end

        return NastrandirRaidTools:PackTime(time)]]
        return widget.timeline:GetTime()
    end

    function widget:GetRaidTimes()
        local raid = NastrandirRaidTools:GetModuleDB("Attendance", "raids", widget.uid)
        return raid.start_time, raid.end_time
    end

    function widget:GetRaidStartTime()
        local time = widget:GetRaidTimes()
        return time
    end

    function widget:GetRaidEndTime()
        local _, time = widget:GetRaidTimes()
        return time
    end

    function widget:GetRaidTimeEvents()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        widget.time_events = Attendance:GetRaidTimeEvents(widget:GetUID())
        widget.timeline:CreateTimeEvents(widget.time_events)
    end

    function widget:GetRoster()
        local db = NastrandirRaidTools:GetModuleDB("Roster")

        if not db.characters then
            db.characters = {}
        end

        local players = {}
        for uid, player in pairs(db.characters) do
            if player.raidmember and not player.main then
                table.insert(players, uid)
            end
        end

        return players
    end

    function widget:SetTime(time)
        --[[local time = NastrandirRaidTools:SplitTime(time)
        widget.hours:SetValue(time.hours)
        widget.minutes:SetValue(time.minutes)]]
        widget.timeline:SetTime(time)
    end

    function widget:GetStateColumn(state_uid)
        for index, child in ipairs(widget.content_group) do
            local column_uid = child:GetUID()
            if column_uid == state_uid then
                return child
            end
        end
    end

    function widget:ParseLog(end_time)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.participation then
            db.participation = {}
        end

        if not db.participation[widget.uid] then
            db.participation[widget.uid] = {}
        end

        local participation = db.participation[widget.uid]

        if not end_time then
            end_time = participation[#participation].time
            widget:SetTime(end_time)
        end

        widget.autoParseLog = false
        for index, entry in ipairs(participation) do
            if entry.time > end_time then
                -- do not parse over the end of the
                -- log or a specified end
                break
            end

            widget:RemovePlayerByMain(entry.member)

            local column = widget:GetStateColumn(entry.state)
            if column then
                column:AddPlayerSilently(entry.member)
            else
                if widget.roster then
                    local Roster = NastrandirRaidTools:GetModule("Roster")
                    widget.roster:AddPlayer(Roster:GetMainUID(entry.member))
                end
            end
        end
        widget.autoParseLog = true
    end

    function widget:Load()
        -- Hide all columns, to avoid creating new ones
        for _, column in ipairs(widget.content_group) do
            column:Hide()
        end

        local states = widget:GetStates()
        local column_count = table.getn(states) + 1

        -- Create states
        local lastColumn
        local column_width = math.floor((widget:GetWidth() - 10) / column_count)
        for index, uid in ipairs(states) do
            local state = widget:GetColumn()
            state:ReleaseButtons()
            state:SetUID(uid)
            state:SetName(widget:GetStateName(uid))
            state:SetWidth(column_width)
            state:ReleaseAllMember()
            state:SetSortCallback(function(a, b)
                return widget:SortCompare(a, b)
            end)
            state:SetPlayerAddedCallback(function(state_uid, player_uid)
                local db = NastrandirRaidTools:GetModuleDB("Attendance")

                if not db.participation then
                    db.participation = {}
                end

                if not db.participation[widget.uid] then
                    db.participation[widget.uid] = {}
                end

                table.insert(db.participation[widget.uid], {
                    member = player_uid,
                    time = widget:GetTime(),
                    state = state_uid,
                    order = table.getn(db.participation[widget.uid]) + 1
                })

                table.sort(db.participation[widget.uid], function(a, b)
                    if a.time < b.time then
                        return true
                    elseif a.time > b.time then
                        return false
                    end

                    return a.order < b.order
                end)

                widget:GetRaidTimeEvents()
            end)

            state:ClearAllPoints()
            state:Show()
            if lastColumn then
                StdUi:GlueRight(state, lastColumn, 0, 0)
            else
                StdUi:GlueBelow(state, widget.timeline, 0, -10, "LEFT")

                widget.timeline:SetRaidTimes(widget:GetRaidTimes())
                widget:GetRaidTimeEvents()
            end

            lastColumn = state
        end

        -- Create roster
        local roster
        if not widget.roster then
            roster = StdUi:NastrandirRaidTools_Attendance_RaidRecordingRoster(widget, column_width, column_height)
            widget.roster = roster
        else
            roster = widget.roster
        end
        roster:SetWidth(column_width)
        roster:SetSortCallback(function(a, b)
            return widget:SortCompare(a, b)
        end)

        if lastColumn then
            StdUi:GlueRight(roster, lastColumn, 0, 0)
        else
            StdUi:GlueTop(roster, roster:GetParent(), 5, -70, "LEFT")
        end

        -- Set Data to all columns
        for index, child in ipairs(widget.content_group) do
            child:SetColumnContainer(widget.content_group)
            child:SetRoster(roster)
        end
        roster:SetColumnContainer(widget.content_group)
        roster:SetRoster(roster)

        -- Fill Roster
        local players = widget:GetRoster()
        for index, uid in ipairs(players) do
            roster:AddPlayer(uid)
        end

        -- Set time to start time
        widget.autoParseLog = false
        widget:SetTime(widget:GetRaidStartTime())

        -- Parse already done log
        widget:ParseLog()
    end


    function widget:RemovePlayerByMain(player_uid)
        for index, child in ipairs(widget.content_group) do
            child:RemovePlayerByMain(player_uid)
        end

        widget.roster:RemovePlayerByMain(player_uid)
    end

    function widget:SectionChanged(uid, value)
        local raid = NastrandirRaidTools:GetModuleDB("Attendance", "raids", widget.uid)
        raid.sections = raid.sections or {}
        table.insert(raid.sections, {
            time = widget.timeline:GetTime(),
            section = uid,
            value = value,
            order = #raid.sections + 1
        })

        widget:GetRaidTimeEvents()
    end

    function widget:GetSectionMenu()
        local db = NastrandirRaidTools:GetModuleDB("Attendance", "sections")
        local sections = {}
        for uid, section in pairs(db) do
            if section.usable then
                table.insert(sections, uid)
            end
        end

        table.sort(sections, function(a, b)
            return db[a].name < db[b].name
        end)

        local menu = {}
        for _, uid in ipairs(sections) do
            local section = db[uid]
            local children = {}

            for _, value in ipairs(section.values) do
                table.insert(children, {
                    radio = value,
                    radioGroup = uid,
                    checked = false,
                    callback = function()
                        widget:SectionChanged(uid, value)
                    end
                })
            end

            table.insert(menu, {
                title = section.name,
                children = children
            })
        end

        table.insert(menu, {
            isSeparator = true
        })
        table.insert(menu, {
            title = "Close",
            callback = function()
                widget.section_menu:CloseMenu()
            end
        })

        return menu
    end

    function widget:IsMemberInGroup(uid)
        local CurrentGroupRoster = NastrandirRaidTools:GetModule("CurrentGroupRoster")
        local info = CurrentGroupRoster:GetAlt(uid)
        if info then
            return true, info.uid, info.subgroup
        end

        return false
    end

    function widget:AutoRecord(columns)
        -- Copy actual member list
        local member = {}
        for index, column in ipairs(columns) do
            if column then
                for _, entry in ipairs(column.members) do
                    table.insert(member, entry.uid)
                end
            end
        end

        local autorecord = NastrandirRaidTools:GetModuleDB("Attendance", "autorecord")
        local group_state = widget:GetStateColumn(autorecord.in_group)
        local missing_state = widget:GetStateColumn(autorecord.missing)
        for _, member_uid in ipairs(member) do
            local state, actual_uid, subgroup = widget:IsMemberInGroup(member_uid)
            if state then
                -- Move players of group 5-8 to missing, if you are in a mythic raid
                local _, type, difficulty = GetInstanceInfo()
                if state and type and type == "raid"  and difficulty and difficulty == 16 and subgroup >= 5 then
                    state = false
                end

                -- Is in current group
                if group_state and not group_state:FindPlayer(actual_uid) then
                    widget:RemovePlayerByMain(actual_uid)
                    group_state:AddPlayer(actual_uid)
                end
            else
                -- Is not in current group
                if missing_state and not missing_state:FindPlayer(member_uid) then
                    widget:RemovePlayerByMain(member_uid)
                    missing_state:AddPlayer(member_uid)
                end
            end
        end
    end

    widget:SetScript("OnShow", function()
        local autorecord = NastrandirRaidTools:GetModuleDB("Attendance", "autorecord")
        if not autorecord.in_group or not autorecord.missing then
            widget.auto:Hide()
        else
            widget.auto:Show()
        end
    end)

    widget.section:SetScript("OnClick", function()
        if not widget.section_menu then
            widget.section_menu = StdUi:DynamicContextMenu(parent, widget:GetSectionMenu())
            widget.section_menu:SetHighlightTextColor(1, 0.431, 0.101, 1)
        else
            widget.section_menu:DrawOptions(widget:GetSectionMenu())
        end

        local menu = widget.section_menu
        menu:SetFrameStrata("TOOLTIP")

        menu:ClearAllPoints()
        StdUi:GlueBelow(widget.section_menu, widget.section, 0, 0, "LEFT")

        menu:Show()
    end)

    widget.auto:SetScript("OnClick", function()
        local now = tonumber(date("%H%M"))
        widget.timeline:SetTime(now, true)

        local autorecord = NastrandirRaidTools:GetModuleDB("Attendance", "autorecord")
        widget:AutoRecord({
            widget:GetStateColumn(autorecord.in_group),
            widget:GetStateColumn(autorecord.missing),
            widget.roster
        })
    end)

    widget.auto:SetScript("OnEnter", function()
        widget.auto.tooltip:Show()
    end)

    widget.auto:SetScript("OnLeave", function()
        widget.auto.tooltip:Hide()
    end)

    widget.timeline.OnValueChanged = function(timeline, newTime)
        if widget.autoParseLog then
            widget:ParseLog(newTime)
        end
    end

    return widget
end)