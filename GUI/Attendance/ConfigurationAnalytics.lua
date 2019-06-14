local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationAnalytics", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 44

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local add = StdUi:Button(widget, 80, 24, "Add Analytic")
    widget.add = add
    StdUi:GlueTop(add, widget, 10, -10, "LEFT")

    function widget:DrawAnalytics()
        if not widget.itemFrames then
            widget.itemFrames = {}
        end

        local _, totalHeight = StdUi:ObjectList(
                widget,
                widget.itemFrames ,
                function(parent, data, i)
                    local itemFrame = StdUi:NastrandirRaidTools_Attendance_ConfigurationAnalyticsEdit(parent)
                    itemFrame:SetUID(data)
                    itemFrame:Load()
                    itemFrame:UpdateOrderButtons()
                    return itemFrame
                end,
                function(parent, itemFrame, data, i)
                    itemFrame:SetUID(data)
                    itemFrame:Load()
                    itemFrame:UpdateOrderButtons()
                end,
                widget.analytics,
                5,
                10,
                -40
        )

        widget:SetHeight(height + totalHeight)
    end

    function widget:Load()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.analytics then
            db.analytics = {}
        end

        widget.analytics = NastrandirRaidTools:GetSortedKeySet(db.analytics, function(a, b)
            local analyticA = db.analytics[a]
            local analyticB = db.analytics[b]

            return analyticA.order < analyticB.order
        end)

        widget:DrawAnalytics()
    end

    function widget:GetAnalyticsCount()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.analytics then
            db.analytics = {}
        end

        local count = 0
        for _, _ in pairs(db.analytics) do
            count = count + 1
        end

        return count
    end

    function widget:NewAnalytic()
        -- Get UID
        local uid = NastrandirRaidTools:CreateUID("Attendance-Analytic")

        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.analytics then
            db.analytics = {}
        end

        if not db.analytics[uid] then
            db.analytics[uid] = {
                name = "New Analytic",
                order = widget:GetAnalyticsCount() + 1,
                states = {}
            }
        end

        widget:Load()
    end

    widget.add:SetScript("OnClick", function()
        widget:NewAnalytic()
    end)

    widget:SetScript("OnShow", function()
        widget:Load()
    end)

    return widget
end)