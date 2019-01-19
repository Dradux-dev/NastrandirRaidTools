local Type, Version = "NastrandirRaidToolsAttendanceRaidRecordingRoster", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 200
local height = 400

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.players = {}
        self.scroll_frame:ReleaseChildren()
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnWidthSet"] = function(self, width)
        self.title:SetWidth(width)
        self.scroll_frame:SetWidth(width)
    end,
    ["AddPlayer"] = function(self, player)
        print("AddPlayer()", player)
        if not self:FindPlayer(player) then
            print("Adding")
            table.insert(self.players, player)
            self:CreatePlayerButtons()
        end
    end,
    ["lockButtons"] = function(self)
        self.buttons_locked = true
    end,
    ["unlockButtons"] = function(self)
        if self.buttons_locked then
            self.buttons_locked = false
            self:CreatePlayerButtons()
        end
    end,
    ["CreatePlayerButtons"] = function(self)
        if self.buttons_locked then
            return
        end

        self.scroll_frame:ReleaseChildren()

        if self.sortCallback then
            table.sort(self.players, self.sortCallback)
        end

        local Roster = NastrandirRaidTools:GetModule("Roster")
        for index, uid in ipairs(self.players) do
            local button = AceGUI:Create("NastrandirRaidToolsAttendanceRaidRecordingPlayer")
            button:Initialize()
            button:SetName(Roster:GetCharacterName(uid))
            button:SetClass(Roster:GetCharacterClass(uid))
            button:SetKey(uid)
            button:SetColumnContainer(self.column_container)
            button:SetRoster(self.roster)
            button:SetColumn(self)
            self.scroll_frame:AddChild(button)
        end

        self.title:SetText(string.format("%s (%d)","Roster", table.getn(self.players)))
    end,
    ["SetSortCallback"] = function(self, func)
        self.sortCallback = func
    end,
    ["SetDropTarget"] = function(self, state)
        -- Ignore
    end,
    ["RemovePlayer"] = function(self, uid)
        print("RemovePlayer()", uid)
        local pos = self:FindPlayer(uid)

        print("pos=", pos)
        if pos then
            print("Removing")
            table.remove(self.players, pos)
            self:CreatePlayerButtons()
        end
    end,
    ["FindPlayer"] = function(self, uid)
        for index, comp_uid in ipairs(self.players) do
            if uid == comp_uid then
                return index
            end
        end
    end,
    ["SetColumnContainer"] = function(self, container)
        self.column_container = container
    end,
    ["SetRoster"] = function(self, roster)
        self.roster = roster
    end,
    ["RemovePlayerByMain"] = function(self, player_uid)
        local pos = self:FindPlayerByMain(self:GetMainUID(player_uid))

        if pos then
            table.remove(self.players, pos)
            self:CreatePlayerButtons()
        end
    end,
    ["GetMainUID"] = function(self, player_uid)
        local Roster = NastrandirRaidTools:GetModule("Roster")
        return Roster:GetMainUID(player_uid)
    end,
    ["FindPlayerByMain"] = function(self, main_uid)
        for index, uid in ipairs(self.players) do
            local compare = self:GetMainUID(uid)
            if main_uid == compare then
                return index
            end
        end
    end,
    ["GetDropDown"] = function(self)
        return self.options_dropdown
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
    title:SetText("Roster")
    title:SetWidth(widget.frame:GetWidth())
    title:SetJustifyH("CENTER")
    widget:AddChild(title)

    local scroll_frame = AceGUI:Create("ScrollFrame")
    widget.scroll_frame = scroll_frame
    scroll_frame:SetWidth(widget.frame:GetWidth())
    scroll_frame:SetHeight(height - 30)
    widget:AddChild(scroll_frame)

    local options_dropdown = CreateFrame("Frame", "PullButtonsOptionsDropDown", nil, "L_UIDropDownMenuTemplate")
    widget.options_dropdown = options_dropdown

    local widget = {
        frame = widget.frame,
        widget = widget,
        title = title,
        scroll_frame = scroll_frame,
        options_dropdown = options_dropdown,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)