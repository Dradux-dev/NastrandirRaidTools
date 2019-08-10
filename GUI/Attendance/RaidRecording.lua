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

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)
    widget.content_group = {}

    -- Top Bar
    --[[local hours = StdUi:NastrandirRaidTools_SpinBox(widget)
    widget.hours = hours
    hours:SetMin(0)
    hours:SetMax(23)
    StdUi:GlueTop(hours, widget, -57, -15)

    local minutes = StdUi:NastrandirRaidTools_SpinBox(widget)
    widget.minutes = minutes
    minutes:SetMin(0)
    minutes:SetMax(59)
    StdUi:GlueTop(minutes, widget, 57, -15)--]]

    local timeline = StdUi:NastrandirRaidTools_Attendance_RaidRecordingTimeline(widget, width - 10)
    widget.timeline = timeline
    StdUi:GlueTop(timeline, widget, 5, -15, "LEFT")

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
        local column = StdUi:NastrandirRaidTools_Attendance_RaidRecordingStateColumn(widget, 200, 450)
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

    function widget:ParseLog()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.participation then
            db.participation = {}
        end

        if not db.participation[widget.uid] then
            db.participation[widget.uid] = {}
        end

        local participation = db.participation[widget.uid]

        for index, entry in ipairs(participation) do
            widget:SetTime(entry.time)
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
                StdUi:GlueTop(state, state:GetParent(), 5, -70, "LEFT")
                
                widget.timeline:SetRaidTimes(widget:GetRaidTimes())
                widget:GetRaidTimeEvents()
            end

            lastColumn = state
        end

        -- Create roster
        local roster
        if not widget.roster then
            roster = StdUi:NastrandirRaidTools_Attendance_RaidRecordingRoster(widget, column_width, 450)
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

    return widget
end)