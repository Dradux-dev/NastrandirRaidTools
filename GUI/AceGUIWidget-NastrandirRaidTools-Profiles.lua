local Type, Version = "NastrandirRaidToolsProfiles", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 28

local WIDTH = {
    CURRENT = 0.47,
    COPY_FROM = 0.47,
    DELETE = 0.95,
    NEW = 0.67,
    CREATE = 0.24
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)

        self.current:SetList(self:GetProfileList(true))
        self.current:SetValue(self:GetCurrentProfile())

        local profiles, order = self:GetProfileList()
        self.copy_from:SetList(profiles, order)
        self.delete:SetList(profiles, order)

        self.current:SetCallback("OnValueChanged", function(dropdown, event, name)
            NastrandirRaidTools:GetDB():SetProfile(name)
            NastrandirRaidTools:ShowProfiles()
        end)

        self.copy_from:SetCallback("OnValueChanged", function(dropdown, event, name)
            self.copy_from:SetValue()
            NastrandirRaidTools:GetDB():CopyProfile(name)
            NastrandirRaidTools:ShowProfiles()
        end)

        self.delete:SetCallback("OnValueChanged", function(dropdown, event, name)
            self:AskDelete(name)
        end)

        self.create:SetCallback("OnClick", function()
            local name = self.new:GetText()
            if name == "" then
                return
            end

            self.new:SetText("")
            NastrandirRaidTools:GetDB():SetProfile(name)
            NastrandirRaidTools:ShowProfiles()
        end)
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnWidthSet"] = function(self, width)
        self.current:SetWidth(WIDTH.CURRENT * self.widget.frame:GetWidth())
        self.copy_from:SetWidth(WIDTH.COPY_FROM * self.widget.frame:GetWidth())
        self.delete:SetWidth(WIDTH.DELETE * self.widget.frame:GetWidth())
        self.new:SetWidth(WIDTH.NEW * self.widget.frame:GetWidth())
        self.create:SetWidth(WIDTH.CREATE * self.widget.frame:GetWidth())
    end,
    ["AskDelete"] = function(self, name)
        local question = AceGUI:Create("InlineGroup")
        question:SetLayout("Flow")
        question:SetWidth(self.bottom.frame:GetWidth())
        question:SetTitle("Are you sure?")
        self.bottom:AddChild(question)

        local spacer_left = AceGUI:Create("SimpleGroup")
        spacer_left:SetWidth(question.frame:GetWidth() / 4 - 5)
        spacer_left:SetLayout("Flow")
        spacer_left:SetHeight(25)
        spacer_left.frame:SetBackdropColor(0, 0, 0, 0)
        question:AddChild(spacer_left)

        local button_no = AceGUI:Create("Button")
        button_no:SetText("No")
        button_no:SetWidth(question.frame:GetWidth() / 4)
        button_no:SetCallback("OnClick", function()
            self.delete:SetValue()
            self.bottom:ReleaseChildren()
            NastrandirRaidTools:ShowProfiles()
        end)
        question:AddChild(button_no)

        local button_yes = AceGUI:Create("Button")
        button_yes:SetText("Yes")
        button_yes:SetWidth(question.frame:GetWidth() / 4)
        button_yes:SetCallback("OnClick", function()
            self.delete:SetValue()
            self.bottom:ReleaseChildren()
            NastrandirRaidTools:GetDB():DeleteProfile(name)
            NastrandirRaidTools:ShowProfiles()
        end)
        question:AddChild(button_yes)

        local spacer_right = AceGUI:Create("SimpleGroup")
        spacer_right:SetWidth(question.frame:GetWidth() / 4 - 5)
        spacer_right:SetLayout("Flow")
        spacer_right:SetHeight(25)
        spacer_right.frame:SetBackdropColor(0, 0, 0, 0)
        question:AddChild(spacer_right)
    end,
    ["GetCurrentProfile"] = function(self)
        local db = NastrandirRaidTools:GetDB()
        return db:GetCurrentProfile()
    end,
    ["GetProfileList"] = function(self, includeCurrent)
        local db = NastrandirRaidTools:GetDB()

        local profiles = db:GetProfiles()


        local FindCurrentProfile = function()
            local currentProfile = db:GetCurrentProfile()
            for pos, profileName in ipairs(profiles) do
                if profileName == currentProfile then
                    return pos
                end
            end
        end

        local pos = FindCurrentProfile()
        if not includeCurrent and pos then
            table.remove(profiles, pos)
        end

        local profile_list = {}
        local order = {}
        for index, profileName in ipairs(profiles) do
            profile_list[profileName] = profileName
            table.insert(order, profileName)
        end

        table.sort(order)

        return profile_list, order
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local current = AceGUI:Create("Dropdown")
    widget.current = current
    current:SetWidth(WIDTH.CURRENT * widget.frame:GetWidth())
    current:SetLabel("Current")
    widget:AddChild(current)

    local copy_from = AceGUI:Create("Dropdown")
    widget.copy_from = copy_from
    copy_from:SetWidth(WIDTH.COPY_FROM * widget.frame:GetWidth())
    copy_from:SetLabel("Copy From")
    widget:AddChild(copy_from)

    local delete = AceGUI:Create("Dropdown")
    widget.delete = delete
    delete:SetWidth(WIDTH.DELETE * widget.frame:GetWidth())
    delete:SetLabel("Delete")
    widget:AddChild(delete)

    local new = AceGUI:Create("EditBox")
    widget.new = new
    new:SetWidth(WIDTH.NEW * widget.frame:GetWidth())
    new:SetLabel("Create new profile")
    widget:AddChild(new)

    local create = AceGUI:Create("Button")
    widget.create = create
    create:SetWidth(WIDTH.CREATE * widget.frame:GetWidth())
    create:SetText("Create")
    widget:AddChild(create)

    local bottom = AceGUI:Create("SimpleGroup")
    widget.bottom = bottom
    bottom:SetWidth(widget.frame:GetWidth())
    bottom:SetLayout("Flow")
    bottom.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(bottom)

    local widget = {
        frame = widget.frame,
        widget = widget,
        current = current,
        copy_from = copy_from,
        delete = delete,
        new = new,
        create = create,
        bottom = bottom,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)