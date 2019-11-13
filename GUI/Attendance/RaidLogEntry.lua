local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidLogEntry", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 20

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    widget.strings = {}

    local function FindFirst(message, needles)
        local first, last

        for needle, _ in pairs(needles) do
            local actualFirst, actualLast = string.find(message, needle)

            if not first or (actualFirst and actualFirst < first) then
                first, last = actualFirst, actualLast
            end
        end

        return first, last
    end

    local function SplitMessage(message, replacer)
        local splitted = {}
        local len = string.len(message)
        local oldLen = -1

        while len > 0 and len ~= oldLen do
            oldLen = len

            local first, last = FindFirst(message, replacer)
            if first then
                table.insert(splitted, string.sub(message, 1, first-1))
                table.insert(splitted, string.sub(message, first, last))
                message = string.sub(message, last+1)
                len = string.len(message)
            end
        end

        -- Add the remaining string to the list
        table.insert(splitted, message)

        return splitted
    end

    local function SetString(i, data)
        local fs = widget.strings[i]
        if not fs then
            fs = StdUi:FontString(widget, data.text)
            widget.strings[i] = fs
        end

        if data.click then
            fs:SetText("|cFF4487F2[" .. data.text .. "]|r")
            fs.click = data.click
        else
            fs:SetText("|cFFFFFFFF" .. data.text .. "|r")
            fs.click = nil
        end

        fs:ClearAllPoints()
        if i == 1 then
            StdUi:GlueTop(fs, widget, 0, 0, "LEFT")
        else
            StdUi:GlueRight(fs, widget.strings[i-1], 0, 0)
        end

        fs:Show()
    end

    function widget:SetData(entry)

        -- Build Replacer List
        local replacer = {}
        if entry.replacer then
            for key, _ in pairs(entry.replacer) do
                replacer["<" .. key .. ">"] = key
            end
        end

        -- Split the message
        local splitted = SplitMessage(entry.message, replacer)

        -- Hide all strings
        for _, string in ipairs(widget.strings) do
            string:Hide()
        end

        -- Setup
        widget.member = entry.member
        SetString(1, { text = string.sub(entry.time, 1, 2) .. ":" .. string.sub(entry.time, 3, 4) .. " " })
        for index, sub in ipairs(splitted) do
            if replacer[sub] then
                local data = entry.replacer[replacer[sub]]
                SetString(index+1, data)
            else
                SetString(index+1, { text = sub })
            end
        end
    end

    widget:EnableMouse(true)
    widget:SetScript("OnMouseUp", function()
        for index, fs in ipairs(widget.strings) do
            if fs:IsShown() and fs:IsMouseOver() and fs.click then
                fs.click()
            end
        end
    end)

    return widget
end)