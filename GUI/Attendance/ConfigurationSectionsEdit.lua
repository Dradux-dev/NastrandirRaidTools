local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationSectionEdit", function(self, parent)
    local width = parent:GetWidth()-20 or 800
    local height = 360

    local widget = StdUi:Panel(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local delete = StdUi:SquareButton(widget, 24, 24, "DELETE")
    widget.delete = delete
    StdUi:GlueTop(delete, widget, -10, -10, "RIGHT")

    local name = StdUi:SimpleEditBox(widget, 0.77 * widget:GetWidth(), 24, "")
    widget.name = name
    StdUi:AddLabel(widget, name, "Name", "TOP")
    StdUi:GlueTop(name, widget, 10, -40, "LEFT")

    local usable = StdUi:Checkbox(widget, "Usable", 0.17 * widget:GetWidth(), 24)
    widget.usable = usable
    StdUi:GlueRight(usable, name, 10, 0)

    local values = StdUi:Panel(widget, widget:GetWidth() - 20, 70)
    widget.values = values
    StdUi:GlueBelow(values, widget.name, 0, -15, "LEFT")

    local title = StdUi:Label(values, "Values")
    values.title = title
    StdUi:GlueTop(title, values, 10, -10, "LEFT")

    local value = StdUi:SimpleEditBox(values, values:GetWidth() - 80, 24, "")
    values.value = value
    StdUi:GlueBelow(value, title, 0, -5, "LEFT")

    local add = StdUi:Button(values, 50, 24, "Add")
    values.add = add
    StdUi:GlueRight(add, value, 10, 0)

    values.frames = {}

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

    function widget:SetSection(section)
        widget.section = section
    end

    function widget:DrawValues()
        if not widget.values.frames then
            widget.values.frames = {}
        end

        local _, totalHeight = StdUi:ObjectList(
                widget.values,
                widget.values.frames ,
                function(parent, data, i)
                    local itemFrame = StdUi:NastrandirRaidTools_Attendance_ConfigurationSectionEditValue(parent)
                    itemFrame:SetValue(data)
                    return itemFrame
                end,
                function(parent, itemFrame, data, i)
                    itemFrame:SetValue(data)
                end,
                widget.valueList or {},
                5,
                10,
                -60
        )

        widget.values:SetHeight(math.max(70, totalHeight + 10))
        local saveShown = widget.save:IsShown() and 30 or 0
        widget:SetHeight(90 + saveShown + widget.values:GetHeight())
    end

    function widget:Load()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.sections then
            db.sections = {}
        end

        if not db.sections[widget.uid] then
            db.sections[widget.uid] = {
                name = "New Section",
                usable = true,
                values = {}
            }
        end

        local section = db.sections[widget.uid]
        widget.name:SetText(section.name)
        widget.usable:SetChecked(section.usable or false)
        widget.valueList = section.values

        widget:DrawValues()
        widget:HideSave()
    end

    function widget:Save()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.sections then
            db.sections = {}
        end

        db.sections[widget.uid] = {
            name = widget.name:GetText(),
            usable = widget.usable:GetChecked(),
            values = widget.valueList
        }

        widget:HideSave()
    end

    function widget:RemoveValue(value)
        local pos = NastrandirRaidTools:FindInTable(widget.valueList, value)
        if not pos then
            return
        end

        table.remove(widget.valueList, pos)
        widget:DrawValues()
        widget:ShowSave()
    end

    function widget:AddValue(value)
        widget.valueList = widget.valueList or {}

        if value == "" then
            -- Don't add empty values
            return
        end

        local pos = NastrandirRaidTools:FindInTable(widget.valueList, value)
        if pos then
            -- Don't add same value twice
            return
        end

        table.insert(widget.valueList, value)
        widget:DrawValues()
        widget:ShowSave()
    end

    widget.name:SetScript("OnEnterPressed", function()
        widget:ShowSave()
    end)

    widget.usable.OnValueChanged = function()
        widget:ShowSave()
    end

    widget.delete:SetScript("OnClick", function()
        NastrandirRaidTools:GetUserPermission(widget, {
            callbackYes = function()
                local db = NastrandirRaidTools:GetModuleDB("Attendance", "sections")
                db[widget.uid] = nil
                widget:GetParent():DrawSections()
            end
        })
    end)

    widget.values.value:SetScript("OnEnterPressed", function()
        widget:AddValue(widget.values.value:GetText())
        widget.values.value:SetText("")
    end)

    widget.values.add:SetScript("OnClick", function()
        widget:AddValue(widget.values.value:GetText())
        widget.values.value:SetText("")
    end)

    widget.save:SetScript("OnClick", function()
        widget:Save()
    end)

    widget:SetScript("OnShow", function()
        widget:Load()
    end)

    return widget
end)