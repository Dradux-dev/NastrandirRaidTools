local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidRecording", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 300

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)
    widget.content_group = {}

    -- Top Bar
    local hours = StdUi:NastrandirRaidTools_SpinBox(widget)
    widget.hours = hours
    hours:SetMin(0)
    hours:SetMax(23)
    StdUi:GlueTop(hours, widget, -25, 5)

    local minutes = StdUi:NastrandirRaidTools_SpinBox(widget)
    widget.minutes = minutes
    minutes:SetMin(0)
    minutes:SetMax(59)
    StdUi:GlueTop(minutes, widget, -25, 5)

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
        local Roster = NastrandirRaidTools:GetModule("Roster")

        local role_values = {
            ["TANK"] = 1,
            ["HEAL"] = 2,
            ["MELEE"] = 3,
            ["RANGED"] = 4
        }

        -- First off sort by role
        local role_a = role_values[Roster:GetCharacterRole(a)]
        local role_b = role_values[Roster:GetCharacterRole(b)]
        if role_a < role_b then
            return true
        elseif role_a > role_b then
            return false
        end

        local class_a = Roster:GetCharacterClass(a)
        local class_b = Roster:GetCharacterClass(b)
        if class_a < class_b then
            return true
        elseif class_a > class_b then
            return false
        end

        local name_a = Roster:GetCharacterName(a)
        local name_b = Roster:GetCharacterName(b)
        return name_a < name_b
    end

    function widget:GetColumn()
        -- find unused column
        for index, column in ipairs(widget.content_group) do
            if not column:IsShown() then
                return column
            end
        end

        -- create new column: no unused column available
        local column = StdUi:NastrandirRaidTools_Attendance_RaidRecordingStateColumn(widget, 200, 500)
        table.insert(widget.content_group, column)
        return column
    end

    function widget:GetTime()
        local time = {
            hours = widget.hours:GetValue(),
            minutes = widget.minutes:GetValue()
        }

        return NastrandirRaidTools:PackTime(time)
    end

    function widget:GetRaidStartTime()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        if not db.raids[widget.uid] then
            return 1900
        end

        return db.raids[widget.uid].start_time
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
        local time = NastrandirRaidTools:SplitTime(time)
        widget.hours:SetValue(time.hours)
        widget.minutes:SetValue(time.minutes)
    end

    function widget:GetStateColumn(state_uid)
        for index, child in ipairs(widget.content_group.children) do
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
        local states = widget:GetStates()
        local column_count = table.getn(states) + 1

        -- Create states
        local column_width = (WIDTH.COLUMN / column_count) * widget:GetWidth()
        for index, uid in ipairs(states) do
            local state = widget:GetStateColumn(uid)
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
            end)
            widget.content_group:AddChild(state)
        end

        -- Create roster
        local roster = StdUi:NastrandirRaidTools_Attendance_RaidRecordingRoster(widget, column_width, 500)
        widget.roster = roster
        roster:Initialize()
        roster:SetWidth(column_width)
        roster:SetSortCallback(function(a, b)
            return widget:SortCompare(a, b)
        end)
        widget.content_group:AddChild(roster)

        -- Set Data to all columns
        for index, child in ipairs(widget.content_group.children) do
            child:SetColumnContainer(widget.content_group)
            child:SetRoster(roster)
        end

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
        for index, child in ipairs(widget.content_group.children) do
            child:RemovePlayerByMain(player_uid)
        end
    end

    return widget
end)