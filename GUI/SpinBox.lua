local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_SpinBox", function(self, parent)
    local width = 110
    local height = 30

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local value = StdUi:EditBox(widget, 50, 30, "0")
    widget.value = value
    StdUi:GlueTop(value, widget, 0, 0)

    local minus = StdUi:SquareButton(widget, 30, 30, "DOWN")
    widget.minus = minus
    StdUi:GlueLeft(minus, widget, 0, 0)

    local plus = StdUi:SquareButton(widget, 30, 30, "UP")
    widget.plus = plus
    StdUi:GlueRight(plus, widget, 0, 0)

    function widget:SetMin(min)
        widget.min = min
    end

    function widget:SetMax(max)
        widget.max = max
    end

    function widget:SetValue(value)
        widget.value:SetText(string.format("%d", math.min(widget.max or 100, math.max(widget.min or 1, value))))
    end

    function widget:SetStep(step)
        widget.step = step
    end

    function widget:GetMin()
        return widget.min or 1
    end

    function widget:GetMax()
        return widget.max or 100
    end

    function widget:GetValue()
        return tonumber(widget.value:GetText())
    end

    function widget:GetStep()
        return widget.step or 1
    end

    widget.minus:SetCallback("OnClick", function()
        widget:SetValue(widget:GetValue() - widget:GetStep())
    end)

    widget.plus:SetCallback("OnClick", function()
        widget:SetValue(widget:GetValue() + widget:GetStep())
    end)

    widget.value:SetCallback("OnEnterPressed", function()
        widget:SetValue(widget:GetValue())
    end)

    return widget
end)