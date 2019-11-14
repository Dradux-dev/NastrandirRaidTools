local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidRecordingTimeline", function(self, parent, width)
    width = width or parent:GetWidth() or 800
    local height = 48

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local slider = StdUi:Slider(widget, width, 16)
    widget.slider = slider
    slider:SetPrecision(0)
    slider.thumb:SetFrameLevel(15)
    StdUi:GlueTop(slider, widget, 0, -16, "LEFT")

    local text = StdUi:FontString(widget, "20:15")
    widget.text = text
    StdUi:GlueBelow(text, slider, 0, -5)

    local nowicon = StdUi:NastrandirRaidTools_Attendance_RaidRecordingTimelineNow(widget)
    widget.nowicon = nowicon
    nowicon:SetFrameLevel(14)
    nowicon:Hide()

    function widget:IsInRange(value, min, max)
        return min <= value and max >= value
    end

    function widget:GetTimeOffset(time)
        local totalDuration = NastrandirRaidTools:GetDuration(widget.start_time, widget.end_time)
        local currentDuration = NastrandirRaidTools:GetDuration(widget.start_time, time)
        local percent = currentDuration / totalDuration
        return percent * widget:GetWidth()
    end

    function widget:SetMinMaxValues(min, max)
        widget.oldValue = min or 0
        widget.slider:SetMinMaxValues(min or 0, max or 100)
    end

    function widget:SetRaidTimes(start_time, end_time)
        widget.slider:SetValue(0)

        widget.start_time = start_time or 1915
        widget.end_time = end_time or 2245

        widget:SetMinMaxValues(0, NastrandirRaidTools:GetDuration(start_time, end_time))
        if widget.slider:GetValue() ~= 0 then
            widget.slider:SetValue(0)
        else
            widget:UpdateTimeDisplay()
        end
    end

    function widget:UpdateTimeDisplay()
        local time = widget:GetTime()
        local splitted = NastrandirRaidTools:SplitTime(time)
        widget.text:SetText(string.format("%02d:%02d", splitted.hours, splitted.minutes))
    end

    function widget:IsInRaidTime(time)
        return widget:IsInRange(time, widget.start_time, widget.end_time)
    end

    function widget:ShallNowButtonBeenShown(now)
        if widget:IsInRaidTime(now) then
            local nowDuration = NastrandirRaidTools:GetDuration(widget.start_time, now)
            local sliderDuration = widget.slider:GetValue()
            if math.abs(nowDuration - sliderDuration) >= 1 then
                return true
            end
        end

        return false
    end

    function widget:UpdateNowIcon()
        local now = tonumber(date("%H%M"))
        if widget:ShallNowButtonBeenShown(now) then
            widget.nowicon:SetTime(now)

            local posx = widget:GetTimeOffset(now) - (widget.nowicon:GetWidth()) + 2
            widget.nowicon:ClearAllPoints()
            StdUi:GlueLeft(widget.nowicon, widget.slider, posx, 0, true)
            widget.nowicon:Show()
        else
            widget.nowicon:Hide()
        end
    end

    function widget:SetTime(time, fix)
        if not widget:IsInRaidTime(time) and fix then
            if time < widget.start_time then
                time = widget.start_time
            elseif time > widget.end_time then
                time = widget.end_time
            end
        end

        if widget:IsInRaidTime(time) then
            local duration = NastrandirRaidTools:GetDuration(widget.start_time, time)
            widget.slider:SetValue(duration)
        end
    end

    function widget:GetTime()
        return NastrandirRaidTools:AddDuration(widget.start_time, widget.slider:GetValue())
    end

    function widget:GetTimeEventPosition(index, offset, text_width, marker_width)
        if index % 2 == 1 then
            return "TOP"
        else
            local mid = widget:GetWidth() / 2
            local min = mid - (text_width / 2) - marker_width
            local max = mid + (text_width / 2)
            if widget:IsInRange(offset, min, max) then
                return "TOP"
            end

            return "BOTTOM"
        end
    end

    function widget:CreateTimeEvents(time_events)
        if not widget.time_event_markers then
            widget.time_event_markers = {}
        end

        for index, event in ipairs(time_events) do
            local marker = widget.time_event_markers[index] or StdUi:NastrandirRaidTools_Attendance_RaidRecordingTimelineEventMarker(widget, "TOP")
            local offset = widget:GetTimeOffset(event.time)

            marker:SetTime(event.time)

            local displayType = widget:GetTimeEventPosition(index, offset, 30, marker:GetWidth())
            marker:SetDisplayType(displayType)
            marker:SetData(event.data)

            if displayType == "TOP" then
                StdUi:GlueAbove(marker, slider, offset, 0, "LEFT")
            else
                StdUi:GlueBelow(marker, slider, offset, 0, "LEFT")
            end

            if not widget.time_event_markers[index] then
                table.insert(widget.time_event_markers, marker)
            end
        end

        for i=#time_events+1, #widget.time_event_markers do
            widget.time_event_markers[i]:Hide()
        end
    end

    slider.OnValueChanged = function(slider, newValue)
        -- ParseLog again!
        if newValue ~= widget.oldValue then
            widget.oldValue = newValue
            widget:UpdateTimeDisplay()
            widget:UpdateNowIcon()

            if widget.OnValueChanged then
                widget.OnValueChanged(widget, widget:GetTime())
            end
        end
    end

    widget:SetScript("OnShow", function()
        widget:UpdateNowIcon()
        widget.timer = C_Timer.NewTicker(20, function()
            widget:UpdateNowIcon()
        end)
    end)

    widget:SetScript("OnHide", function()
        if widget.timer then
            widget.timer:Cancel()
            widget.timer = nil
        end
    end)

    return widget
end)
