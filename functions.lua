--[[
	Adding a number of functions to support data/elements management
]] --

--[[
-- Handles Frame drag
 -
    Note: Must be used on the frame that needs to be dragged (no child or parent frames)
    Note: Sender must have SavePoint() function to store its location
 -
 ]]
Drag = setmetatable({
    new = function(frame, dragable)
        local dragable = dragable and dragable or frame

        local drag
        local offset

        local function dragFrame(action, cursor)
            if action == "START" then
                drag = true
            elseif action == "END" then
                drag = false
                offset = nil
                dragable:SavePoint()
            elseif action == "MOVE" then
                if drag == true then
                    if not offset then
                        -- setting difference between mouse and frame's position
                        offset = {
                            left = cursor.left - dragable:GetLeft(),
                            top = cursor.top - dragable:GetTop()
                        }
                    end
                    -- moving frame
                    local moveLeft = cursor.left - offset.left
                    local moveTop = cursor.top - offset.top
                    dragable:SetPoint("TOPLEFT", UIParent, "TOPLEFT", moveLeft, moveTop)
                end
            end
        end

        local function rightDown(sender, handle)
            dragFrame("START")
        end

        local function rightUp(sender, handle)
            dragFrame("END")
        end

        local function move(sender, handle, x, y)
            dragFrame("MOVE", { left = x, top = y })
        end

        frame:EventAttach(Event.UI.Input.Mouse.Right.Down, rightDown, "mouse left down")
        frame:EventAttach(Event.UI.Input.Mouse.Right.Up, rightUp, "mouse left up")
        frame:EventAttach(Event.UI.Input.Mouse.Right.Upoutside, rightUp, "mouse left upoutside")
        frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, move, "mouse left upoutside")
    end
}, {
    __call = function(drag, frame, dragable)
        drag.new(frame, dragable)
    end
})

--[[
	Print out contents of table
	@require table t, number indent, table done
	@return void
]] --
function print_r(t, indent, done)
    done = done or {}
    indent = indent or ''
    local nextIndent -- Storage for next indentation value
    for key, value in pairs(t) do
        if type(value) == "table" and not done[value] then
            nextIndent = nextIndent or
                    (indent .. string.rep(' ', string.len(tostring(key)) + 2))
            -- Shortcut conditional allocation
            done[value] = true
            print(indent .. "[" .. tostring(key) .. "] => Table {");
            print(nextIndent .. "{");
            print_r(value, nextIndent .. string.rep(' ', 2), done)
            print(nextIndent .. "}");
        else
            print(indent .. "[" .. tostring(key) .. "] => " .. tostring(value) .. "")
        end
    end
end

--[[
	Print out keys of table
	@require table t
	@return void
]] --
function print_keys(t)
    for k, _ in pairs(t) do
        print(tostring(k))
    end
end

--[[
	Returns a deep copy of passed table
	@require table orig
	@return table
]] --
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[
	Trim passed text
	@require string s
	@return 
]] --
function trim(s)
    local from = s:match "^%s*()"
    return from > #s and "" or s:match(".*%S", from)
end

--[[
	Concatinate multiple tables
	@require list<table> ...
	@return table
]] --
function array_concat(...)
    local t = {}
    for n = 1, select("#", ...) do
        local arg = select(n, ...)
        if type(arg) == "table" then
            for _, v in ipairs(arg) do
                t[#t + 1] = v
            end
        else
            t[#t + 1] = arg
        end
    end
    return t
end

--[[
	Check if value is inside indexed table
]] --
function in_array(arr, value)
    for _, v in pairs(arr) do
        if v == value then return true end
    end
    return false
end

--[[
	get key for value in array
]] --
function get_key(arr, value)
    for k, v in pairs(arr) do
        if v == value then return k end
    end
    return nil
end

--[[
	Returns a list containing array keys
]] --
function get_keys(arr)
    local keys = {}
    for k, _ in pairs(arr) do
        keys[#keys + 1] = k
    end
    return keys
end

--[[
	Returns new array with values removed
]] --
function remove_values(arr, values)
    local clean = {}
    for _, v in pairs(arr) do
        if not in_array(values, v) then clean[#clean + 1] = v end
    end
    return clean
end

--[[
	Makes human readable time
	@require number time
	@return string formated time
]] --
function format_time(t)
    local rTime, rSuffix
    if t <= 60 then
        rTime = math.floor(t)
        rSuffix = 's'
    elseif t <= 3600 then
        rTime = math.floor(t / 60)
        rSuffix = 'm'
    else
        rTime = math.floor(t / 3600)
        rSuffix = 'h'
    end

    return rTime .. rSuffix
end

--[[
	Isert value into sorted table
]] --
local fcomp_default = function(a, b) return a < b end
function table.bininsert(t, value, fcomp)
    -- Initialise compare function
    local fcomp = fcomp or fcomp_default
    --  Initialise numbers
    local iStart, iEnd, iMid, iState = 1, #t, 1, 0
    -- Get insert position
    while iStart <= iEnd do
        -- calculate middle
        iMid = math.floor((iStart + iEnd) / 2)
        -- compare
        if fcomp(value, t[iMid]) then
            iEnd, iState = iMid - 1, 0
        else
            iStart, iState = iMid + 1, 1
        end
    end
    table.insert(t, (iMid + iState), value)
    return (iMid + iState)
end


