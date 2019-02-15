local Type, Version = "NastrandirRaidToolsAttendanceRaidRecording", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 400

local WIDTH = {
    TOP_SPACER = 0.28,
    COLUMN = 0.98
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.content_group:ReleaseChildren()
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnWidthSet"] = function(self, width)
        self.widget.top_bar:SetWidth(width)
        self.content_group:SetWidth(width)
        self.top_spacer_left:SetWidth(WIDTH.TOP_SPACER * self.widget.top_bar.frame:GetWidth())
        self.top_spacer_right:SetWidth(WIDTH.TOP_SPACER * self.widget.top_bar.frame:GetWidth())

        local states = self:GetStates()
        local column_count = table.getn(states) + 1
        local column_width = (WIDTH.COLUMN / column_count) * self.content_group.frame:GetWidth()
        for index, child in ipairs(self.content_group.children) do
            child:SetWidth(column_width)
        end
    end,
    ["SetUID"] = function(self, uid)
        self.uid = uid
    end,
    ["GetUID"] = function(self)
        return self.uid
    end,
    ["Load"] = function(self)
        local states = self:GetStates()
        local column_count = table.getn(states) + 1

        -- Create states
        local column_width = (WIDTH.COLUMN / column_count) * self.content_group.frame:GetWidth()
        for index, uid in ipairs(states) do
            local state = AceGUI:Create("NastrandirRaidToolsAttendanceRaidRecordingStateColumn")
            state:Initialize()
            state:SetUID(uid)
            state:SetTitle(self:GetStateName(uid))
            state:SetWidth(column_width)
            state:SetSortCallback(function(a, b)
                return self:SortCompare(a, b)
            end)
            state:SetPlayerAddedCallback(function(state_uid, player_uid)
                local db = NastrandirRaidTools:GetModuleDB("Attendance")

                if not db.participation then
                    db.participation = {}
                end

                if not db.participation[self.uid] then
                    db.participation[self.uid] = {}
                end

                table.insert(db.participation[self.uid], {
                    member = player_uid,
                    time = self:GetTime(),
                    state = state_uid,
                    order = table.getn(db.participation[self.uid]) + 1
                })

                table.sort(db.participation[self.uid], function(a, b)
                    if a.time < b.time then
                        return true
                    elseif a.time > b.time then
                        return false
                    end

                    return a.order < b.order
                end)
            end)
            self.content_group:AddChild(state)
        end

        -- Create roster
        local roster = AceGUI:Create("NastrandirRaidToolsAttendanceRaidRecordingRoster")
        self.roster = roster
        roster:Initialize()
        roster:SetWidth(column_width)
        roster:SetSortCallback(function(a, b)
            return self:SortCompare(a, b)
        end)
        self.content_group:AddChild(roster)

        -- Set Data to all columns
        for index, child in ipairs(self.content_group.children) do
            child:SetColumnContainer(self.content_group)
            child:SetRoster(roster)
        end

        -- Fill Roster
        local players = self:GetRoster()
        for index, uid in ipairs(players) do
            roster:AddPlayer(uid)
        end

        -- Set time to start time
        self:SetTime(self:GetRaidStartTime())

        -- Parse already done log
        self:ParseLog()
    end,
    ["GetStates"] = function(self)
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
    end,
    ["GetStateName"] = function(self, uid)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        return db.states[uid].Name
    end,
    ["GetRoster"] = function(self)
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
    end,
    ["SortCompare"] = function(self, a, b)
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
    end,
    ["GetRaidStartTime"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        if not db.raids[self.uid] then
            return 1900
        end

        return db.raids[self.uid].start_time
    end,
    ["GetTime"] = function(self)
        local time = {
            hours = self.hours:GetValue(),
            minutes = self.minutes:GetValue()
        }

        return NastrandirRaidTools:PackTime(time)
    end,
    ["SetTime"] = function(self, time)
        local time = NastrandirRaidTools:SplitTime(time)
        self.hours:SetValue(time.hours)
        self.minutes:SetValue(time.minutes)
    end,
    ["ParseLog"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.participation then
            db.participation = {}
        end

        if not db.participation[self.uid] then
            db.participation[self.uid] = {}
        end

        local participation = db.participation[self.uid]

        for index, entry in ipairs(participation) do
            self:SetTime(entry.time)
            self:RemovePlayerByMain(entry.member)

            local column = self:GetStateColumn(entry.state)
            if column then
                column:AddPlayerSilently(entry.member)
            else
                if self.roster then
                    local Roster = NastrandirRaidTools:GetModule("Roster")
                    self.roster:AddPlayer(Roster:GetMainUID(entry.member))
                end
            end
        end
    end,
    ["RemovePlayerByMain"] = function(self, player_uid)
        for index, child in ipairs(self.content_group.children) do
            child:RemovePlayerByMain(player_uid)
        end
    end,
    ["GetStateColumn"] = function(self, state_uid)
        for index, child in ipairs(self.content_group.children) do
            local column_uid = child:GetUID()
            if column_uid == state_uid then
                return child
            end
        end
    end
}

local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local top_bar = AceGUI:Create("SimpleGroup")
    widget.top_bar = top_bar
    top_bar:SetWidth(width)
    top_bar:SetLayout("Flow")
    widget:AddChild(top_bar)

    local spacer_left = AceGUI:Create("NastrandirRaidToolsSpacer")
    top_bar.spacer_left = spacer_left
    spacer_left:SetWidth(WIDTH.TOP_SPACER * top_bar.frame:GetWidth())
    spacer_left:SetBackdropColor(0, 0, 0, 0)
    top_bar:AddChild(spacer_left)

    local hours = AceGUI:Create("NastrandirRaidToolsSpinBox")
    top_bar.hours = hours
    hours:SetMin(0)
    hours:SetMax(23)
    top_bar:AddChild(hours)

    local minutes = AceGUI:Create("NastrandirRaidToolsSpinBox")
    top_bar.minutes = minutes
    minutes:SetMin(0)
    minutes:SetMax(59)
    top_bar:AddChild(minutes)

    local spacer_right = AceGUI:Create("NastrandirRaidToolsSpacer")
    top_bar.spacer_right = spacer_right
    spacer_right:SetWidth(WIDTH.TOP_SPACER * top_bar.frame:GetWidth())
    spacer_right:SetBackdropColor(0, 0, 0, 0)
    top_bar:AddChild(spacer_right)

    local content_group = AceGUI:Create("SimpleGroup")
    widget.content_group = content_group
    content_group:SetWidth(width)
    content_group:SetLayout("Flow")
    content_group.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(content_group)

    local widget = {
        frame = widget.frame,
        widget = widget,
        top_spacer_left = spacer_left,
        hours = hours,
        minutes = minutes,
        top_spacer_right = spacer_right,
        content_group = content_group,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)