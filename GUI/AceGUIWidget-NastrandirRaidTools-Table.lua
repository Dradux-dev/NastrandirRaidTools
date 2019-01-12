local Type, Version = "NastrandirRaidToolsTable", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 180
local height = 300

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
        self:SetColumns(3)
        self:SetRows(3)
    end,
    ["SetWidth"] = function(self, w)
        self.width = w
        self.widget:SetWidth(w)
        self:Rearrange()
    end,
    ["SetHeight"] = function(self, h)
        self.height = h
        self.widget:SetHeight(h)
        self:Rearrange()
    end,
    ["SetRows"] = function(self, rows)
        self:CreateCells(rows, self.columns or 0)
        self.rows = rows
        self:Rearrange()
    end,
    ["SetColumns"] = function(self, columns)
        self:CreateCells(self.rows or 0, columns)
        self.columns = columns
        self:Rearrange()
    end,
    ["SetData"] = function(self, row, column, data)
        local cell = self:GetCell(row, column)
        cell.data = data
        cell.child:SetData(data)
    end,
    ["GetData"] = function(self, row, column)
        local cell = self:GetCell(row, column)
        return cell.data
    end,
    ["SetText"] = function(self, row, column, text)
        local cell = self:GetCell(row, column)
        cell.text = text
        cell.child:SetText(text)
    end,
    ["GetText"] = function(self, row, column)
        local cell = self:GetCell(row, column)
        return cell.text
    end,
    ["SetClickCallback"] = function(self, row, column, func)
        local cell = self:GetCell(row, column)
        cell.click_callback = func
        cell.child:SetClickCallback(func)
    end,
    ["GetClickCallback"] = function(self, row, column)
        local cell = self:GetCell(row, column)
        return cell.click_callback
    end,
    ["GetCell"] = function(self, row, column)
        if not self.cells then
            self.cells = {}
        end

        if not self.cells[row] then
            self.cells[row] = {}
        end

        if not self.cells[row][column] then
            self.cells[row][column] = {}
        end

        return self.cells[row][column]
    end,
    ["SetChild"] = function(self, row, column, child)
        local cell = self:GetCell(row, column)
        cell.child = child
    end,
    ["Enable"] = function(self)
        self.frame:Enable()
    end,
    ["Disable"] = function(self)
        self.frame:Disable()
    end,
    ["Rearrange"] = function(self)
        local width = self.width
        local height = self.height
        local rows = self.rows or 0
        local columns = self.columns or 0

        if rows <= 0 or columns <= 0 then
            return
        end

        local row_height = height / rows
        local column_width = width / columns

        for index, button in pairs(self.widget.children) do
            button:SetHeight(row_height)
            button:SetWidth(column_width)
        end
    end,
    ["CreateCells"] = function(self, rows, columns)
        local new_cells = {}

        self.widget:ReleaseChildren()
        for r=1, rows do
            new_cells[r] = {}

            for c=1, columns do
                local cell = self:GetCell(r, c)
                cell.child = nil

                local button = AceGUI:Create("NastrandirRaidToolsTableCell")
                button:SetText(cell.text)
                button:SetData(cell.data)
                button:SetClickCallback(cell.click_callback)
                self.widget:AddChild(button)
                cell.child = button

                new_cells[r][c] = cell
            end
        end

        self.cells = new_cells
    end,
    ["Sort"] = function(self, column, func)
        if column > (self.columns or 0) then
            return
        end

        local t = {}
        for r=1, self.rows or 0 do
            local cell = self:GetCell(r, column)
            table.insert(t, {
                row = r,
                text = cell.text,
                data = cell.data
            })
        end

        table.sort(t, func)

        local new_cells = {}
        for index, entry in ipairs(t) do
            new_cells[index] = self.cells[entry.row]
        end

        self.cells = new_cells
        self:CreateCells(self.rows or 0, self.columns or 0)
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetLayout("Flow")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local widget = {
        frame = widget.frame,
        widget = widget,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)