local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Roster_ClassButton", function(self, parent, uid, name, class)
    local width = 300
    local height = 20

    local button = CreateFrame("BUTTON", name, parent, "OptionsListButtonTemplate")
    self:InitWidget(button)
    self:SetObjSize(button, width, height)

    local background = button:CreateTexture(nil, "BACKGROUND")
    button.background = background
    background:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp")
    background:SetBlendMode("ADD")
    background:SetVertexColor(0.5, 0.5, 0.5, 0.25)
    background:SetPoint("TOP", button, "TOP")
    background:SetPoint("BOTTOM", button, "BOTTOM")
    background:SetPoint("LEFT", button, "LEFT")
    background:SetPoint("RIGHT", button, "RIGHT")

    local icon_dimension = height - 4
    local icon = button:CreateTexture(nil, "OVERLAY")
    button.icon = icon
    icon:SetWidth(icon_dimension)
    icon:SetHeight(icon_dimension)
    icon:SetPoint("LEFT", button, "LEFT", 2, 0)
    icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")

    local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.title = title
    title:SetHeight(height)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("CENTER")
    title:SetPoint("TOP", button, "TOP")
    title:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    title:SetPoint("RIGHT", button, "RIGHT")
    title:SetPoint("BOTTOM", button, "BOTTOM")

    function button:SetName(name)
        button.title:SetText(name)
    end

    function button:GetName()
        return button.title:GetText()
    end

    function button:SetClass(class)
        button.class = class
        print("Class", class)
        local classColor = NastrandirRaidTools.class_colors[class]
        button.title:SetTextColor(unpack(classColor.foreground))
        button.background:SetVertexColor(unpack(classColor.background))
        button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
    end

    function button:GetClass()
        return button.class
    end

    function button:SetUID(uid)
        button.uid = uid
    end

    function button:GetUID()
        return button.uid
    end

    button:SetScript("OnClick", function()
        local Roster = NastrandirRaidTools:GetModule("Roster")
        Roster:ShowDetails(button.uid)
    end)

    button:SetUID(uid)
    button:SetName(name)
    button:SetClass(class)

    return button
end)