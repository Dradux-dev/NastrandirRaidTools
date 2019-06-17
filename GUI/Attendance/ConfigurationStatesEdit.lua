local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationStatesEdit", function(self, parent)
    local width = parent:GetWidth()-20 or 800
    local height = 305

    local widget = StdUi:Panel(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local button_down = StdUi:SquareButton(widget, 24, 24, "DOWN")
    widget.button_down = button_down
    StdUi:GlueTop(button_down, widget, -10, -10, "RIGHT")

    local button_up = StdUi:SquareButton(widget, 24, 24, "UP")
    widget.button_up = button_up
    StdUi:GlueLeft(button_up, button_down, -5, 0)

    local delete = StdUi:SquareButton(widget, 24, 24, "DELETE")
    widget.delete = delete
    StdUi:GlueLeft(delete, button_up, -5, 0)

    local name = StdUi:EditBox(widget, 0.77 * widget:GetWidth(), 24, "")
    widget.name = name
    StdUi:AddLabel(widget, name, "Name", "TOP")
    StdUi:GlueTop(name, widget, 10, -30, "LEFT")

    local track_alts = StdUi:Checkbox(widget, "Track Alts", 0.17 * widget:GetWidth(), 24)
    widget.track_alts = track_alts
    StdUi:GlueRight(track_alts, name, 10, 0)

    local messages = StdUi:Panel(widget, widget:GetWidth() - 20, 200)
    widget.messages = messages
    StdUi:GlueBelow(messages, name, 0, -10, "LEFT")

    local title = StdUi:Label(messages, "Messages")
    messages.title = title
    StdUi:GlueTop(title, messages, 10, -10, "LEFT")

    local enter = StdUi:EditBox(messages, messages:GetWidth() - 20, 24, "")
    messages.enter = enter
    StdUi:AddLabel(messages, enter, "Enter", "TOP")
    StdUi:GlueTop(enter, messages, 10, -50, "LEFT")

    local swap = StdUi:EditBox(messages, messages:GetWidth() - 20, 24, "")
    messages.swap = swap
    StdUi:AddLabel(messages, swap, "Character Swap", "TOP")
    StdUi:GlueBelow(swap, enter, 0, -30, "LEFT")

    local leave = StdUi:EditBox(messages, messages:GetWidth() - 20, 24, "")
    messages.leave = leave
    StdUi:AddLabel(messages, leave, "Leave", "TOP")
    StdUi:GlueBelow(leave, swap, 0, -30, "LEFT")

    local save = StdUi:Button(widget, 80, 24, "Save")
    widget.save = save
    StdUi:GlueBottom(save, widget, -10, 10, "RIGHT")

    function widget:ShowSave()
        if not widget.save:IsShown() then
            widget.save:Show()
            widget:SetHeight(widget:GetHeight() + 30)
        end
    end

    function widget:HideSave()
        if widget.save:IsShown() then
            widget.save:Hide()
            widget:SetHeight(widget:GetHeight() - 30)
        end
    end

    function widget:SetUID(uid)
        widget.uid = uid
    end

    function widget:Load()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        if not db.states[widget.uid] then
            db.states[widget.uid] = {
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

        local state = db.states[widget.uid]
        widget.name:SetText(state.Name)
        widget.track_alts:SetChecked(state.TrackAlts or false)
        widget.messages.enter:SetText(state.LogMessages.Enter)
        widget.messages.swap:SetText(state.LogMessages.Swap)
        widget.messages.leave:SetText(state.LogMessages.Leave)
        widget.order = state.Order

        widget:HideSave()
    end

    function widget:Save()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        db.states[widget.uid] = {
            Name = widget.name:GetText(),
            TrackAlts = widget.track_alts:GetChecked(),
            Order = widget.order,
            LogMessages = {
                Enter = widget.messages.enter:GetText(),
                Swap = widget.messages.swap:GetText(),
                Leave = widget.messages.leave:GetText()
            }
        }

        widget:HideSave()
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

    function widget:GetStateByOrder(order)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        for uid, state in pairs(db.states) do
            if state.Order == order then
                return uid
            end
        end
    end

    function widget:UpdateOrderButtons()
        local stateCount = widget:GetStatesCount()

        local function positionButton(t)
            local frames = {
                widget.button_down,
                widget.button_up,
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

        if widget.order == 1 and stateCount == 1 then
            positionButton({false, false, true})
        elseif widget.order == 1 then
            positionButton({true, false, true})
        elseif widget.order == stateCount then
            positionButton({false, true, true})
        else
            positionButton({true, true, true})
        end
    end

    widget.name:SetScript("OnEnterPressed", function()
        widget:ShowSave()
    end)

    widget.track_alts.OnValueChanged = function()
        widget:ShowSave()
    end

    widget.messages.enter:SetScript("OnEnterPressed", function()
        widget:ShowSave()
    end)

    widget.messages.swap:SetScript("OnEnterPressed", function()
        widget:ShowSave()
    end)

    widget.messages.leave:SetScript("OnEnterPressed", function()
        widget:ShowSave()
    end)

    widget.button_down:SetScript("OnClick", function()
        local other_uid = widget:GetStateByOrder(widget.order + 1)

        if other_uid then
            local db = NastrandirRaidTools:GetModuleDB("Attendance")
            db.states[other_uid].Order = widget.order

            widget.order = widget.order + 1
            widget:Save()

            widget:GetParent():DrawStates()
        end
    end)

    widget.button_up:SetScript("OnClick", function()
        local other_uid = widget:GetStateByOrder(widget.order - 1)

        if other_uid then
            local db = NastrandirRaidTools:GetModuleDB("Attendance")
            db.states[other_uid].Order = widget.order

            widget.order = widget.order - 1
            widget:Save()

            widget:GetParent():DrawStates()
        end
    end)

    widget.delete:SetScript("OnClick", function()
        NastrandirRaidTools:GetUserPermission(widget, {
            callbackYes = function()
                local db = NastrandirRaidTools:GetModuleDB("Attendance", "states")
                db[widget.uid] = nil
                widget:GetParent():DrawStates()
            end
        })
    end)

    widget.save:SetScript("OnClick", function()
        widget:Save()
    end)

    widget:SetScript("OnShow", function()
        widget:UpdateOrderButtons()
    end)

    return widget
end)