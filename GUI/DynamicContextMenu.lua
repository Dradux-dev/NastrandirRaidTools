local StdUi = LibStub("StdUi")

local contextMenus = {}

StdUi:RegisterWidget("DynamicContextMenu", function(self, parent, options, stopHook, level)
    local context = StdUi:ContextMenu(parent, {}, stopHook, level)
    context.unusedItemFrames = {
        title = {},
        checkbox = {},
        radio = {},
        text = {},
        isSeparator = {}
    }
    context.highlightTextColor = { 1, 1, 1, 1}
    context.normalTextColor = { 1, 1, 1, 1}

    function context:IsSameItemFrameType(oldData, newData, types)
        local oldType
        local newType
        local result = false

        for _, typeName in ipairs(types) do
            if oldData[typeName] and newData[typeName] then
                oldType = typeName
                newType = typeName
                result = true
            elseif oldData[typeName] and not oldType then
                oldType = typeName
            elseif newData[typeName] and not newType then
                newType = typeName
            end
        end

        return result, oldType, newType
    end

    function context:ObjectList(parent, itemsTable, create, update, data, padding, oX, oY)
        oX = oX or 1;
        oY = oY or -1;
        padding = padding or 0;

        if not itemsTable then
            itemsTable = {};
        end

        for i = 1, #itemsTable do
            itemsTable[i]:Hide();
        end

        local totalHeight = -oY;

        for i = 1, #data do
            local itemFrame = itemsTable[i];

            if not itemFrame then
                if type(create) == 'string' then
                    -- create a widget and anchor it to
                    itemsTable[i] = self[create](self, parent);
                else
                    itemsTable[i] = create(parent, data[i], i);
                end
                itemFrame = itemsTable[i];
            end

            -- Check if both item frames where the same type
            local sameTypes, oldType, newType = context:IsSameItemFrameType(itemFrame.data, data[i], {"title", "checkbox", "radio", "text", "isSeparator"})
            if not sameTypes then
                -- Store old frame, for possible reuse
                table.insert(context.unusedItemFrames[oldType], itemFrame)
                itemFrame:Hide()

                if table.getn(context.unusedItemFrames[newType]) >= 1 then
                    -- Can reuse another item frame
                    itemFrame = context.unusedItemFrames[newType][1]
                    table.remove(context.unusedItemFrames[newType], 1)
                else
                    -- Can't reuse another item frame --> create new one
                    itemFrame = create(parent, data[i], i)
                end

                context.optionFrames[i] = itemFrame
            end

            -- If you create simple widget you need to handle anchoring yourself
            update(parent, itemFrame, data[i], i);
            itemFrame:Show();

            totalHeight = totalHeight + itemFrame:GetHeight();
            if i == 1 then
                -- glue first item to offset
                StdUi:GlueTop(itemFrame, parent, oX, oY, 'LEFT');
            else
                -- glue next items to previous
                StdUi:GlueBelow(itemFrame, itemsTable[i - 1], 0, -padding);
                totalHeight = totalHeight + padding;
            end
        end

        return itemsTable, totalHeight;
    end

    function context:CreateItem(parent, data, i)
        local itemFrame;

        if data.title then
            itemFrame = parent.stdUi:Frame(parent, nil, 20);
            itemFrame.text = parent.stdUi:Label(itemFrame);
            itemFrame.text:SetTextColor(unpack(context.normalTextColor))
            parent.stdUi:GlueLeft(itemFrame.text, itemFrame, 0, 0, true);
        elseif data.isSeparator then
            itemFrame = parent.stdUi:Frame(parent, nil, 20);
            itemFrame.texture = parent.stdUi:Texture(itemFrame, nil, 8,
                    [[Interface\COMMON\UI-TooltipDivider-Transparent]]);
            itemFrame.texture:SetPoint('CENTER');
            itemFrame.texture:SetPoint('LEFT');
            itemFrame.texture:SetPoint('RIGHT');
        elseif data.checkbox then
            itemFrame = parent.stdUi:Checkbox(parent, '');
        elseif data.radio then
            itemFrame = parent.stdUi:Radio(parent, '', data.radioGroup);
        elseif data.text then
            itemFrame = parent.stdUi:HighlightButton(parent, nil, 20);
        end

        itemFrame.data = data
        if not data.isSeparator then
            itemFrame.text:SetJustifyH('LEFT');
        end

        if not data.isSeparator and data.children then
            itemFrame.icon = parent.stdUi:Texture(itemFrame, 10, 10, [[Interface\Buttons\SquareButtonTextures]]);
            itemFrame.icon:SetTexCoord(0.42187500, 0.23437500, 0.01562500, 0.20312500);
            parent.stdUi:GlueRight(itemFrame.icon, itemFrame, -4, 0, true);

            itemFrame.childContext = parent.stdUi:DynamicContextMenu(parent, data.children, true, parent.level + 1);
            itemFrame.childContext:SetNormalTextColor(unpack(context.normalTextColor))
            itemFrame.childContext:SetHighlightTextColor(unpack(context.highlightTextColor))
            itemFrame.parentContext = parent;
            -- this will keep propagating mainContext thru all children
            itemFrame.mainContext = parent.mainContext;

            itemFrame:HookScript('OnEnter', function(itemFrame, button)
                parent:CloseSubMenus();

                itemFrame.childContext:ClearAllPoints();
                itemFrame.childContext:SetPoint('TOPLEFT', itemFrame, 'TOPRIGHT', 0, 0);
                itemFrame.childContext:Show();

                if itemFrame.text then
                    itemFrame.text:SetTextColor(unpack(context.highlightTextColor))
                end
            end);

            itemFrame:HookScript('OnLeave', function(itemFrame, button)
                if itemFrame.text then
                    itemFrame.text:SetTextColor(unpack(context.normalTextColor))
                end
            end);
        elseif not data.isSeparator then
            itemFrame:HookScript('OnEnter', function(itemFrame, button)
                parent:CloseSubMenus();

                if itemFrame.text then
                    itemFrame.text:SetTextColor(unpack(context.highlightTextColor))
                end
            end);

            itemFrame:HookScript('OnLeave', function(itemFrame, button)
                if itemFrame.text then
                    itemFrame.text:SetTextColor(unpack(context.normalTextColor))
                end
            end);
        end

        if data.events then
            for eventName, eventHandler in pairs(data.events) do
                itemFrame:SetScript(eventName, eventHandler);
            end
        end

        if data.callback then
            itemFrame:SetScript('OnMouseUp', function(frame, button)
                if button == 'LeftButton' then
                    data.callback(frame, frame.parentContext)
                end
            end)
        end

        if data.custom then
            for key, value in pairs(data.custom) do
                itemFrame[key] = value;
            end
        end

        return itemFrame;
    end

    function context:UpdateItem(parent, itemFrame, data, i)
        local padding = parent.padding;

        if data.title then
            itemFrame.text:SetText(data.title);
            parent.stdUi:ButtonAutoWidth(itemFrame);
        elseif data.checkbox or data.radio then
            itemFrame.text:SetText(data.checkbox or data.radio);
            itemFrame:AutoWidth();
            if data.value then
                itemFrame:SetValue(data.value);
            end
        elseif data.text then
            itemFrame:SetText(data.text);
            parent.stdUi:ButtonAutoWidth(itemFrame);
        end

        if data.children then
            -- add arrow size
            itemFrame:SetWidth(itemFrame:GetWidth() + 16);
        end

        if (parent:GetWidth() -  padding * 2) < itemFrame:GetWidth() then
            parent:SetWidth(itemFrame:GetWidth() + padding * 2);
        end

        itemFrame:SetPoint('LEFT', padding, 0);
        itemFrame:SetPoint('RIGHT', -padding, 0);

        if data.color and not data.isSeparator then
            itemFrame.text:SetTextColor(unpack(data.color));
        end

        if data.events then
            for eventName, eventHandler in pairs(data.events) do
                itemFrame:SetScript(eventName, eventHandler);
            end
        end

        if data.callback then
            itemFrame:SetScript('OnMouseUp', function(frame, button)
                if button == 'LeftButton' then
                    data.callback(frame, frame.parentContext)
                end
            end)
        end

        if data.custom then
            for key, value in pairs(data.custom) do
                itemFrame[key] = value;
            end
        end

        -- Hide Sub menu option
        if itemFrame.childContext and not data.children then
            itemFrame.icon:Hide()
            itemFrame:HookScript('OnEnter', function(itemFrame, button)
                parent:CloseSubMenus();

                if itemFrame.text then
                    itemFrame.text:SetTextColor(unpack(context.highlightTextColor))
                end
            end);
        elseif not itemFrame.childContext and data.childContext and not data.isSeparator then
            itemFrame.icon = parent.stdUi:Texture(itemFrame, 10, 10, [[Interface\Buttons\SquareButtonTextures]]);
            itemFrame.icon:SetTexCoord(0.42187500, 0.23437500, 0.01562500, 0.20312500);
            parent.stdUi:GlueRight(itemFrame.icon, itemFrame, -4, 0, true);

            itemFrame.childContext = parent.stdUi:DynamicContextMenu(parent, data.children, true, parent.level + 1);
            itemFrame.childContext:SetNormalTextColor(unpack(context.normalTextColor))
            itemFrame.childContext:SetHighlightTextColor(unpack(context.highlightTextColor))
            itemFrame.parentContext = parent;
            -- this will keep propagating mainContext thru all children
            itemFrame.mainContext = parent.mainContext;

            itemFrame:HookScript('OnEnter', function(itemFrame, button)
                parent:CloseSubMenus();

                itemFrame.childContext:ClearAllPoints();
                itemFrame.childContext:SetPoint('TOPLEFT', itemFrame, 'TOPRIGHT', 0, 0);
                itemFrame.childContext:Show();

                if itemFrame.text then
                    itemFrame.text:SetTextColor(unpack(context.highlightTextColor))
                end
            end);

            itemFrame:HookScript('OnLeave', function(itemFrame, button)
                if itemFrame.text then
                    itemFrame.text:SetTextColor(unpack(context.normalTextColor))
                end
            end);
        end

        itemFrame.data = data
    end

    function context:DrawOptions(options)
        if not context.optionFrames then
            context.optionFrames = {};
        end

        local _, totalHeight = context:ObjectList(
                context,
                context.optionFrames,
                function(parent, data, i)
                    return context:CreateItem(parent, data, i)
                end,
                function(parent, itemFrame, data, i)
                    context:UpdateItem(parent, itemFrame, data, i)
                end,
                options,
                0,
                context.padding,
                -context.padding
        );

        self:SetHeight(totalHeight + self.padding);
    end

    function context:SetHighlightTextColor(r, g, b, a)
        context.highlightTextColor = {r, g, b, a}
    end

    function context:SetNormalTextColor(r, g, b, a)
        context.normalTextColor = {r, g, b, a}
    end

    context:SetScript("OnShow", function()
        if context.level == 1 then
            for _, otherContext in ipairs(contextMenus) do
                if otherContext ~= context then
                    otherContext:CloseMenu()
                end
            end
        end
    end)

    context:DrawOptions(options)
    if context.level == 1 then
        table.insert(contextMenus, context)
    end

    return context
end)