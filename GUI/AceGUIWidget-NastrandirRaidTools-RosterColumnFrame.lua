local Type, Version = "NastrandirRaidToolsRosterColumnFrame", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 180
local height = 300


local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
    end,
    ["SetName"] = function(self, title)
        self.titletext = title
        self.title:SetText((title or "") .. " (" .. (self.count or 0) .. ")")
    end,
    ["SetCount"] = function(self, count)
        self.count = count
        self.title:SetText((self.titletext or "") .. " (" .. (self.count or 0) .. ")")
    end,
    ["AddMember"] = function(self, member)
        if not self.members then
            self.members = {}
        end

        table.insert(self.members, {
            name = member:GetName(),
            class = member:GetClass(),
            uid = member:GetKey()
        })

        self.scroll_frame:AddChild(member)
        self.count = (self.count or 0) + 1
    end,
    ["ReleaseMember"] = function(self)
        self.members = {}
        self.scroll_frame:ReleaseChildren()
    end,
    ["ShowAddButton"] = function(self)
        self.button_add:Show()
    end,
    ["HideAddButton"] = function(self)
        self.button_add:Hide()
    end,
    ["SetAddFunction"] = function(self, func)
        self.button_add:SetUserFunction(func)
    end,
    ["SetWidth"] = function(self, width)
        self.widget:SetWidth(width)
        self.title:SetWidth(width)
        self.widget_group:SetWidth(width)
        self.button_add:SetWidth(width)
    end,
    ["SetHeight"] = function(self, height)
        self.widget:SetHeight(height)
        self.widget_group:SetHeight(self.widget.frame:GetHeight() - self.title.frame:GetHeight() - self.button_add.frame:GetHeight() - 20)
    end,
    ["Sort"] = function(self)
        local actual_shown = {}
        for index, child in ipairs(self.scroll_frame.children) do
            table.insert(actual_shown, {
                name = child:GetName(),
                class = child:GetClass(),
                uid = child:GetKey()
            })
        end

        table.sort(actual_shown, function(a, b)
            local new_player = "New Player"

            if a.name == new_player and b.name ~= new_player then
                return false
            elseif a.name ~= new_player and b.name == new_player then
                return true
            end

            if a.class < b.class then
                return true
            elseif a.class > b.class then
                return false
            end

            return a.name < b.name
        end)

        self.scroll_frame:ReleaseChildren()
        for index, entry in ipairs(actual_shown) do
            local button = AceGUI:Create("NastrandirRaidToolsRosterClassButton")
            button:Initialize()
            button:SetName(entry.name)
            button:SetClass(entry.class)
            button:SetKey(entry.uid)
            self.scroll_frame:AddChild(button)
        end
    end,
    ["Filter"] = function(self, name, only_raidmember, show_alts)
        self.scroll_frame:ReleaseChildren()
        local count = 0
        for index, entry in ipairs(self.members) do
            local add = true

            local Roster = NastrandirRaidTools:GetModule("Roster")
            local character = Roster:GetCharacter(entry.uid)

            -- Hide name mismatch
            if name ~= "" and not character.name:lower():match(name:lower()) then
                add = false
            end

            -- Hide non raidmembers
            if only_raidmember and not character.raidmember then
                add = false
            end

            -- Hide alts
            if not show_alts and character.main then
                add = false
            end

            if add then
                local button = AceGUI:Create("NastrandirRaidToolsRosterClassButton")
                button:Initialize()
                button:SetName(entry.name)
                button:SetClass(entry.class)
                button:SetKey(entry.uid)
                self.scroll_frame:AddChild(button)

                count = count + 1
            end

            self:SetCount(count)
        end
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local title = AceGUI:Create("Label")
    widget.title = title
    title:SetHeight(20)
    title:SetWidth(widget.frame:GetWidth())
    title:SetColor(1, 1, 0, 1)
    title:SetJustifyH("CENTER")
    title:SetJustifyV("CENTER")
    widget:AddChild(title)

    local widget_group = AceGUI:Create("SimpleGroup")
    widget.widget_group = widget_group
    widget_group:SetWidth(widget.frame:GetWidth())
    widget_group:SetHeight(widget.frame:GetHeight() - title.frame:GetHeight() - 20)
    widget_group:SetLayout("Fill")
    widget_group.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(widget_group)

    local scroll_frame = AceGUI:Create("ScrollFrame")
    widget.scroll_frame = scroll_frame
    scroll_frame:SetLayout("Flow")
    widget_group:AddChild(widget.scroll_frame)

    local button_add = AceGUI:Create("NastrandirRaidToolsMenuButton")
    button_add:Initialize()
    button_add:SetTitle("Add")
    button_add:SetWidth(widget.frame:GetWidth())
    widget:AddChild(button_add)

    local widget = {
        frame = widget.frame,
        widget = widget,
        title = title,
        widget_group = widget_group,
        scroll_frame = scroll_frame,
        button_add = button_add,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)