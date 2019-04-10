local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidRecordingRoster", function(self, parent, width, height)
    local widget = StdUi:NastrandirRaidTools_Roster_ColumnFrame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)
    widget:HideAddButton()

    function widget:AddPlayer(player)
        if not widget:FindPlayer(player) then
            table.insert(widget.members, player)
            widget:CreatePlayerButtons()
        end
    end

    function widget:lockButtons()
        widget.buttons_locked = true
    end

    function widget:unlockButtons()
        if widget.buttons_locked then
            widget.buttons_locked = false
            widget:CreatePlayerButtons()
        end
    end

    function widget:CreatePlayerButtons()
        if widget.buttons_locked then
            return
        end

        widget.scroll_frame:ReleaseChildren()

        if widget.sortCallback then
            table.sort(widget.members, widget.sortCallback)
        end

        local Roster = NastrandirRaidTools:GetModule("Roster")
        for index, uid in ipairs(widget.members) do
            local button = AceGUI:Create("NastrandirRaidToolsAttendanceRaidRecordingPlayer")
            button:Initialize()
            button:SetName(Roster:GetCharacterName(uid))
            button:SetClass(Roster:GetCharacterClass(uid))
            button:SetKey(uid)
            button:SetColumnContainer(widget.column_container)
            button:SetRoster(widget.roster)
            button:SetColumn(widget)
            widget.scroll_frame:AddChild(button)
        end

        widget.title:SetText(string.format("%s (%d)", "Roster", table.getn(widget.members)))
    end

    function widget:SetSortCallback(func)
        widget.sortCallback = func
    end

    function widget:SetDropTarget(state)
        -- Ignore
    end

    function widget(uid)
        local pos = widget:FindPlayer(uid)

        if pos then
            table.remove(widget.members, pos)
            widget:CreatePlayerButtons()
        end
    end

    function widget:FindPlayer(uid)
        for index, comp_uid in ipairs(widget.members) do
            if uid == comp_uid then
                return index
            end
        end
    end

    function widget:SetColumnContainer(container)
        widget.column_container = container
    end

    function widget:SetRoster(roster)
        widget.roster = roster
    end

    function widget:RemovePlayerByMain(player_uid)
        local pos = widget:FindPlayerByMain(widget:GetMainUID(player_uid))

        if pos then
            table.remove(widget.members, pos)
            widget:CreatePlayerButtons()
        end
    end

    function widget:GetMainUID(player_uid)
        local Roster = NastrandirRaidTools:GetModule("Roster")
        return Roster:GetMainUID(player_uid)
    end

    function widget:FindPlayerByMain(main_uid)
        for index, uid in ipairs(widget.members) do
            local compare = widget:GetMainUID(uid)
            if main_uid == compare then
                return index
            end
        end
    end

    return widget
end)