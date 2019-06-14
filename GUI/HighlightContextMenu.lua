local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("HighlightContextMenu", function(self, parent, options)
    local context = StdUi:ContextMenu(parent, {})
    context.highlightTextColor = { 1, 1, 1, 1}
    context.normalTextColor = { 1, 1, 1, 1}

    context.newOnEnter = function(itemFrame)
        context:CloseSubMenus();

        if itemFrame.childContext then
            itemFrame.childContext:ClearAllPoints();
            itemFrame.childContext:SetPoint('TOPLEFT', itemFrame, 'TOPRIGHT', 0, 0);
            itemFrame.childContext:Show();
        end

        if itemFrame.text then
            itemFrame.text:SetTextColor(unpack(context.highlightTextColor))
        end
    end

    context.newOnLeave = function(itemFrame)
        if itemFrame.text then
            itemFrame.text:SetTextColor(unpack(context.normalTextColor))
        end
    end

    context.originalDrawOptions = context["DrawOptions"]

    function context:DrawOptions(options)
        for _, option in ipairs(options) do
            if not option.events then
                option.events = {}
            end

            if not option.events.OnEnter then
                option.events.OnEnter = context.newOnEnter
            end

            if not option.events.OnLeave then
                option.events.OnLeave = context.newOnLeave
            end

            if option.close then
                if not option.userCallbackCreated then
                    option.userCallback = option.callback
                    option.userCallbackCreated = true
                end
                option.callback = function()
                    context:CloseMenu()

                    if option.userCallback then
                        option.userCallback()
                    end
                end
            end
        end

        if context.originalDrawOptions then
            context.originalDrawOptions(context, options)
        end
    end

    function context:SetHighlightTextColor(r, g, b, a)
        context.highlightTextColor = {r, g, b, a}
    end

    function context:SetNormalTextColor(r, g, b, a)
        context.normalTextColor = {r, g, b, a}
    end

    context:DrawOptions(options)
    return context
end)