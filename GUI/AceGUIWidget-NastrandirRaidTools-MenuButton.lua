local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_MenuButton", function(self, parent, text, onClick)
    local width = 248
    local height = 24

    local button = CreateFrame("BUTTON", text, parent, "OptionsListButtonTemplate")
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

    local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.title = title
    title:SetHeight(height)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("CENTER")
    title:SetPoint("TOP", button, "TOP")
    title:SetPoint("LEFT", button, "LEFT", 5, 0)
    title:SetPoint("BOTTOM", button, "BOTTOM")
    title:SetPoint("RIGHT", button, "RIGHT")
    title:SetText("")

    function button:SetText(title)
        self.title:SetText(title)
    end

    function button:SetUserFunction(func)
        button:SetScript("OnClick", func)
    end

    button:SetScript("OnClick", onClick)
    button:SetText(text)

    return button
end)