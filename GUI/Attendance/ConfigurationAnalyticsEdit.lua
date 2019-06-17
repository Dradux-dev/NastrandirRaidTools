local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationAnalyticsEdit", function(self, parent)
    local width = (parent:GetWidth() or 800) - 20
    local height = 100
    local statesHeight = 10

    local widget = StdUi:Panel(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)
    widget.stateList = {}

    local down = StdUi:SquareButton(widget, 24, 24, "DOWN")
    widget.down = down
    StdUi:GlueTop(down, widget, -10, -10, "RIGHT")

    local up = StdUi:SquareButton(widget, 24, 24, "UP")
    widget.up = up
    StdUi:GlueLeft(up, down, -5, 0)

    local delete = StdUi:SquareButton(widget, 24, 24, "DELETE")
    widget.delete = delete
    StdUi:GlueLeft(delete, up, -5, 0)

    local name = StdUi:SimpleEditBox(widget, width - 20, 24, "")
    widget.name = name
    StdUi:AddLabel(widget, name, "Default Name", "TOP")
    StdUi:GlueTop(name, widget, 10, -40, "LEFT")

    local states = StdUi:Panel(widget, width - 20, statesHeight)
    widget.states = states
    StdUi:GlueBelow(states, name, 0, -15, "LEFT")

    local title = StdUi:Label(states, "States")
    states.title = title
    StdUi:GlueTop(title, states, 10, -10, "LEFT")

    local search = StdUi:Dropdown(states, width - 40, 24, {})
    states.search = search
    StdUi:GlueBelow(search, title, 0, -15, "LEFT")

    local save = StdUi:Button(widget, 80, 24, "Save")
    widget.save = save
    StdUi:GlueBelow(save, states, 0, -10, "RIGHT")

    function widget:SetUID(uid)
        widget.uid = uid
    end

    function widget:ShowSave()
        if not widget.save:IsShown() then
            widget:SetHeight(widget:GetHeight() + 34)
            widget.save:Show()
        end
    end

    function widget:HideSave()
        if widget.save:IsShown() then
            widget:SetHeight(widget:GetHeight() - 34)
            widget.save:Hide()
        end
    end

    function widget:DrawStates()
        if not states.itemFrames then
            states.itemFrames = {}
        end

        local _, totalHeight = StdUi:ObjectList(
                states,
                states.itemFrames ,
                function(parent, data, i)
                    local stateFrame = StdUi:NastrandirRaidTools_Attendance_ConfigurationAnalyticsEditState(parent)
                    stateFrame:SetAnalyticUID(widget.uid)
                    stateFrame:SetUID(data)
                    stateFrame:Load()
                    return stateFrame
                end,
                function(parent, stateFrame, data, i)
                    stateFrame:SetAnalyticUID(widget.uid)
                    stateFrame:SetUID(data)
                    stateFrame:Load()
                end,
                widget.stateList,
                2,
                10,
                -70
        )

        local realHeight = height
        if widget.save:IsShown() then
            realHeight = height + 34
        end

        states:SetHeight(statesHeight + totalHeight)
        widget:SetHeight(realHeight + totalHeight)
    end

    function widget:GetAnalyticsCount()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.analytics then
            db.analytics = {}
        end

        local count = 0
        for uid, analytic in pairs(db.analytics) do
            count = count + 1
        end

        return count
    end

    function widget:CompareStates(a, b)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        local stateA = db.states[a]
        local stateB = db.states[b]

        return stateA.Order < stateB.Order
    end

    function widget:Load()
        if not widget.uid then
            -- Don't know what to load
            return
        end

        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.analytics then
            db.analytics = {}
        end

        if not db.analytics[widget.uid] then
            db.analytics[widget.uid] = {
                name = "New Analytic",
                order = widget:GetAnalyticsCount(),
                states = {}
            }
        end

        local analytic = db.analytics[widget.uid]
        widget.name:SetText(analytic.name)
        widget.order = analytic.order

        widget.stateList = NastrandirRaidTools:GetSortedKeySet(analytic.states, function (a, b)
            return widget:CompareStates(a, b)
        end)

        widget:DrawStates()
        widget:HideSave()
    end

    function widget:Save()
        if not widget.uid then
            return
        end

        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.analytics then
            db.analytics = {}
        end

        local analytic = {
            name = widget.name:GetText(),
            order = widget.order,
            states = {}
        }

        for _, itemFrame in ipairs(widget.states.itemFrames) do
            if itemFrame:IsShown() then
                local uid = itemFrame.state_uid
                analytic.states[uid] = {
                    tolerance = itemFrame.tolerance:GetValue()
                }
            end
        end

        db.analytics[widget.uid] = analytic
        widget:HideSave()
    end

    function widget:RemoveState(uid)
        local pos = NastrandirRaidTools:FindInTable(widget.stateList, uid)

        if not pos then
            return
        end

        table.remove(widget.stateList, pos)
        widget:DrawStates()
        widget:ShowSave()
    end

    function widget:UpdateStateDropdown()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        local options = {}
        for uid, state in pairs(db.states) do
            table.insert(options, {
                text = state.Name,
                value = uid,
                order = state.Order
            })
        end

        table.sort(options, function(a, b)
            return a.order < b.order
        end)

        widget.states.search:SetOptions(options)
        widget.states.search:SetPlaceholder("-- Select --")
        widget.states.search:SetText(widget.states.search.placeholder)
    end

    function widget:UpdateOrderButtons()
        local count = widget:GetAnalyticsCount()

        local function positionButton(t)
            local frames = {
                widget.down,
                widget.up,
                widget.delete
            }

            local last
            for index, state in ipairs(t) do
                local frame = frames[index]
                if state then
                    frame:Show()
                    frame:ClearAllPoints()
                    if not last then
                        StdUi:GlueTop(frame, widget, -10, -10, "RIGHT")
                    else
                        StdUi:GlueLeft(frame, last, -5, 0)
                    end

                    last = frame
                else
                    frame:Hide()
                end
            end
        end

        if widget.order == 1 and count == 1 then
            positionButton({false, false, true})
        elseif widget.order == 1 then
            positionButton({true, false, true})
        elseif widget.order == count then
            positionButton({false, true, true})
        else
            positionButton({true, true, true})
        end
    end

    widget:SetScript("OnShow", function()
        widget:UpdateStateDropdown()
    end)

    widget.name:SetScript("OnEnterPressed", function()
        widget:ShowSave()
    end)

    widget.save:SetScript("OnClick", function()
        widget:Save()
    end)

    widget.states.search.OnValueChanged = function(self, value)
        if value == "-- Select --" then
            return
        end

        local pos = NastrandirRaidTools:FindInTable(widget.stateList, value)
        if pos then
            return
        end

        table.insert(widget.stateList, value)
        table.sort(widget.stateList, function(a, b)
            return widget:CompareStates(a, b)
        end)

        widget:DrawStates()
        widget:ShowSave()
    end

    widget.delete:SetScript("OnClick", function()
        NastrandirRaidTools:GetUserPermission(widget, {
            callbackYes = function()
                local db = NastrandirRaidTools:GetModuleDB("Attendance")

                if not db.analytics then
                    db.analytics = {}
                end

                db.analytics[widget.uid] = nil
                widget:GetParent():Load()
            end
        })
    end)

    widget.down:SetScript("OnClick", function()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local below = Attendance:GetAnalyticByOrder(widget.order + 1)
        if below then
            below.order = widget.order
        end

        widget.order = widget.order + 1
        widget:Save()
        widget:GetParent():Load()
    end)

    widget.up:SetScript("OnClick", function()
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local above = Attendance:GetAnalyticByOrder(widget.order - 1)
        if above then
            above.order = widget.order
        end

        widget.order = widget.order - 1
        widget:Save()
        widget:GetParent():Load()
    end)

    widget:DrawStates()
    widget:UpdateStateDropdown()
    return widget
end)