local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationStates", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local add_state = StdUi:Button(widget, 80, 24, "Add State")
    widget.add_state = add_state
    StdUi:GlueTop(add_state, widget, 10, -10, "LEFT")

    function widget:GetStates()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        local state_list = {}
        for uid, _ in pairs(db.states) do
            table.insert(state_list, uid)
        end

        table.sort(state_list, function(a, b)
            local stateA = db.states[a]
            local stateB = db.states[b]
            return stateA.Order < stateB.Order
        end)

        return state_list
    end

    function widget:DrawStates()
        if not widget.stateFrames then
            widget.stateFrames = {}
        end

        local _, totalHeight = StdUi:ObjectList(
                widget,
                widget.stateFrames,
                function(parent, data, i)
                    local stateFrame = StdUi:NastrandirRaidTools_Attendance_ConfigurationStatesEdit(parent)
                    stateFrame:SetUID(data)
                    stateFrame:Load()
                    return stateFrame
                end,
                function(parent, stateFrame, data, i)
                    stateFrame:SetUID(data)
                    stateFrame:Load()
                    stateFrame:UpdateOrderButtons()
                end,
                widget:GetStates(),
                5,
                10,
                -50
        )

        widget:SetHeight(totalHeight + 30)
    end

    function widget:GetStatesCount()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        local count = 0
        for uid, state in pairs(db.states) do
            count = count + 1
        end

        return count
    end

    function widget:NewState()
        -- Get UID
        local uid = NastrandirRaidTools:CreateUID("Attendance-State")

        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        if not db.states[uid] then
            db.states[uid] = {
                Name = "New State",
                TrackAlts = true,
                Order = widget:GetStatesCount() + 1,
                LogMessages = {
                    Enter = "",
                    Swap = "",
                    Leave = ""
                }
            }
        end

        -- Add to the GUI
        widget:DrawStates()
    end

    widget.add_state:SetScript("OnClick", function()
        widget:NewState()
    end)

    widget:SetScript("OnShow", function()
        widget:DrawStates()
    end)

    return widget
end)