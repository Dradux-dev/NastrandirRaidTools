local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500
    local rowHeight = 20

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local title = StdUi:Label(widget, "Attendance", 18, "GameFontNormal", widget:GetWidth() - 20, 24)
    widget.title = title
    StdUi:GlueTop(title, widget, 10, -20, "LEFT")

    local start_raid = StdUi:Dropdown(widget, 300, 24, {})
    widget.start_raid = start_raid
    StdUi:AddLabel(widget, start_raid, "Start", "TOP")
    StdUi:GlueBelow(start_raid, title, 0, -30, "LEFT")

    local end_raid = StdUi:Dropdown(widget, 300, 24, {})
    widget.end_raid = end_raid
    StdUi:AddLabel(widget, end_raid, "End", "TOP")
    StdUi:GlueRight(end_raid, start_raid, 10, 0)

    local analyse = StdUi:Button(widget, 80, 24, "Analyse")
    widget.analyse = analyse
    StdUi:GlueRight(analyse, end_raid, 10, 0)

    local export = StdUi:Button(widget, 80, 24, "Export")
    widget.export = export
    StdUi:GlueRight(export, analyse, 10, 0)

    local configuration = StdUi:Button(widget, 80, 24, "Configuration")
    widget.configuration = configuration
    StdUi:GlueBelow(configuration, title, 0, -30, "RIGHT")

    local raids = StdUi:Button(widget, 80, 24, "Raids")
    widget.raids = raids
    StdUi:GlueLeft(raids, configuration, -10, 0)

    local data = StdUi:Table(widget, title:GetWidth(), 400, rowHeight, {}, {})
    widget.data = data
    StdUi:GlueBelow(data, start_raid, 0, -30, "LEFT")

    function widget:GetRaidList()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local list = Attendance:GetRaidList()
        local options = {}
        for _, uid in ipairs(list.order) do
            table.insert(options, {
                text = list.list[uid],
                value = uid
            })
        end

        return options
    end

    function widget:FilterRaidList(start_date)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local list = Attendance:GetRaidList(start_date)
        local options = {}
        for _, uid in ipairs(list.order) do
            table.insert(options, {
                text = list.list[uid],
                value = uid
            })
        end

        return options
    end

    function widget:Analyse()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local Roster = NastrandirRaidTools:GetModule("Roster")

        local start_raid = widget.start_raid:GetValue()
        local end_raid = widget.end_raid:GetValue()
        local start_date = Attendance:GetRaid(start_raid).date
        local end_date = Attendance:GetRaid(end_raid).date

        local attendance_data = {}
        local raid_list = Attendance:GetRaidList(start_date, end_date).order

        -- Parse participation
        for _, raid_uid in ipairs(raid_list) do
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
                    local duration = NastrandirRaidTools:GetDuration(player.timestamp, entry.time)
                    player.duration = player.duration + duration
                    player.states[player.state] = (player.states[player.state] or 0) + duration
                    player.state = entry.state
                    player.timestamp = entry.time
                end
            end

            -- Add duration of last state til raid end
            for main_uid, player in pairs(attendance_data) do
                if player.state then
                    local duration = NastrandirRaidTools:GetDuration(player.timestamp, raid.end_time)
                    player.duration = player.duration + duration
                    player.states[player.state] = (player.states[player.state] or 0) + duration
                    player.state = nil
                    player.timestamp = nil
                end
            end
        end

        -- Build table
        widget.states = Attendance:GetStates()
        widget.roster = Roster:GetRaidmember()
        table.sort(widget.roster, function(a, b)
            local name_a = Roster:GetCharacterName(a)
            local name_b = Roster:GetCharacterName(b)

            return name_a < name_b
        end)

        table.sort(widget.states, function(a, b)
            local order_a = Attendance:GetState(a).Order
            local order_b = Attendance:GetState(b).Order

            return order_a < order_b
        end)

        local columns = {
            {
                header = "Raid member",
                index = "name",
                align = "LEFT",
                width = widget.data:GetWidth() / (table.getn(widget.states) + 1)
            }
        }
        for _, state_uid in ipairs(widget.states) do
            local state = Attendance:GetState(state_uid)
            table.insert(columns, {
                header = state.Name,
                index = state_uid,
                align = "CENTER",
                width = widget.data:GetWidth() / (table.getn(widget.states) + 1)
            })
        end

        -- Fill table
        local data = {}
        for _, player_uid in ipairs(widget.roster) do
            local row = {
                name = Roster:GetCharacterName(player_uid)
            }

            for _, state_uid in ipairs(widget.states) do
                local str = "0%"
                if attendance_data[player_uid] then
                    local total = attendance_data[player_uid].duration
                    local time = 0
                    if attendance_data[player_uid].states[state_uid] then
                        time = attendance_data[player_uid].states[state_uid]
                    else
                        --print("State not found", self.data:GetText(1, s+1), ":", self.data:GetData(1, s+1))
                    end

                    str = string.format("%d%%", ((time / total) * 100) + 0.5)
                end

                row[state_uid] = str
            end

            table.insert(data, row)
        end

        widget.data:SetHeight((#data + 1) * rowHeight)
        widget.data:SetColumns(columns)
        widget.data:SetData(data)
        widget.data:DrawTable()
    end

    function widget:Export()
        local line = ""

        for c=1, table.getn(widget.data.columns) do
             line = line .. widget.data.columns[c].header .. ";"
        end
        print(line)

        for r=1, table.getn(widget.data.rows) do
            line = ""
            for c=1, table.getn(widget.data.columns) do
                local cell = widget.data.rows[r][c]
                if c == 1 then
                    line = line .. cell.text:GetText() .. ";"
                else
                    local fixed = string.sub(cell.text:GetText(), 1, string.len(cell.text:GetText()) - 1)
                    line = string.format("%s%d;", line, tonumber(fixed))
                end
            end
            print(line)
        end
    end

    -- Initialize
    local raids = widget:GetRaidList()
    if table.getn(raids) >= 1 then
        widget.start_raid:SetOptions(raids)
        local raid = raids[math.min(12, table.getn(raids))]
        widget.start_raid:SetValue(raid.value, raid.text)

        widget.end_raid:SetOptions(raids)
        widget.end_raid:SetValue(raids[1].value, raids[1].text)

        widget:Analyse()
    end


    widget.start_raid.OnValueChanged = function(self, value)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local date = Attendance:GetRaid(value).date
        local raids = widget:FilterRaidList(date)
        widget.end_raid:SetOptions(raids)
        widget.end_raid:SetValue(raids[1].value, raids[1].text)
    end

    widget.analyse:SetScript("OnClick", function()
        widget:Analyse()
    end)

    widget.export:SetScript("OnClick", function()
        widget:Export()
    end)

    widget.raids:SetScript("OnClick", function()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidList()
    end)

    widget.configuration:SetScript("OnClick", function()
        local Attendance  = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowConfiguration()
    end)

    return widget
end)