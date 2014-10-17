local toc, data = ...
local addonID = toc.identifier
local context = UI.CreateContext("TwinKingContext")
local playerID = Inspect.Unit.Lookup("player") -- get player id

local label = addonID .. ": Interface: " -- label for UI elements

local config = {
    body = {
        width = 300,
        height = 500,
        bg = { 30 / 255, 30 / 255, 30 / 255, 0.95 },
        top = UIParent:GetHeight() / 2 - 250,
        left = UIParent:GetWidth() / 2 - 150,
    },
    header = {
        height = 25,
        bg = { 11 / 255, 11 / 255, 11 / 255, 1 },
        color = { 1, 1, 1, 1 },
        size = 16,
        title = addonID .. " <>",
        close = {
            bg = { 1, 0, 0, 0.5 },
            bgHover = { 1, 0, 0, 1 },
            color = { 1, 1, 1, 1 },
            size = 14
        }
    },
    menu = {
        height = 25,
        bg = { 30 / 255, 30 / 255, 30 / 255, 1 },
        bgActive = { 11 / 255, 11 / 255, 11 / 255, 1 },
        bgHover = { 11 / 255, 11 / 255, 11 / 255, 1 },
        color = { 1, 1, 1, 1 },
        icon = {
            width = 25,
            height = 25,
            src = "images/ico_menu.png"
        },
    },
}

local TKMENU -- TwinKing Interface Menu
local TKI -- TwinKingInterface

TKI = {
    -- Holds main UI elements
    elements = {
        body,
        header,
        menu,
        content,
    },

    -- Initialize UI elemenets
    init = function(this)
        if tKingUI == nil then tKingUI = config end -- setup default config
        tKingUI = config
        -- Create body and its elements
        this.build.body()
        this.build.header()
        this.build.menu()

        -- enable dragging
        Drag(this.elements.header, this.elements.body)
    end,

    -- Set Addon's header
    setHeader = function(this, title)
        this.elements.header.title:SetText(addonID .. "<" .. title .. ">")
    end,

    -- Holds functions for building elements
    build = {
        -- Creates main body element
        body = function()
            local el = UI.CreateFrame("Frame", label .. "body", context)
            el:SetPoint("TOPLEFT", UIParent, "TOPLEFT", tKingUI.body.left, tKingUI.body.top)
            el:SetWidth(tKingUI.body.width)
            el:SetHeight(tKingUI.body.height)
            el:SetBackgroundColor(unpack(tKingUI.body.bg))

            el.SavePoint = function(this)
                tKingUI.body.left = this:GetLeft()
                tKingUI.body.top = this:GetTop()
            end

            TKI.elements.body = el
        end,

        -- Creates header element
        header = function()
            local body = TKI.elements.body
            local label = label .. "header"

            -- background
            local el = UI.CreateFrame("Frame", label, body)
            el:SetPoint("TOPLEFT", body, "TOPLEFT", 0, 0)
            el:SetWidth(body:GetWidth())
            el:SetHeight(tKingUI.header.height)
            el:SetBackgroundColor(unpack(tKingUI.header.bg))

            -- title
            el.title = UI.CreateFrame("Text", label .. ": title", el)
            el.title:SetPoint("CENTERLEFT", el, "CENTERLEFT", 10, 0)
            el.title:SetWidth(el:GetWidth())
            el.title:SetHeight(el:GetHeight())
            el.title:SetFontColor(unpack(tKingUI.header.color))
            el.title:SetFontSize(tKingUI.header.size)
            el.title:SetText(tKingUI.header.title)

            -- close
            el.close = UI.CreateFrame("Frame", label .. ": close", el)
            el.close:SetPoint("TOPRIGHT", el, "TOPRIGHT", 0, 0)
            el.close:SetWidth(el:GetHeight())
            el.close:SetHeight(el:GetHeight())
            el.close:SetBackgroundColor(unpack(tKingUI.header.close.bg))

            -- close text
            el.close.text = UI.CreateFrame("Text", addonID .. ": close text", el.close)
            el.close.text:SetPoint("CENTER", el.close, "CENTER", 0, 0)
            el.close.text:SetFontColor(unpack(tKingUI.header.close.color))
            el.close.text:SetFontSize(tKingUI.header.close.size)
            el.close.text:SetText("X")

            -- add events
            local function MouseIn(close)
                close:SetBackgroundColor(unpack(tKingUI.header.close.bgHover))
            end

            local function MouseOut(close)
                close:SetBackgroundColor(unpack(tKingUI.header.close.bg))
            end

            local function LeftClick(close)
                body:SetVisible(false)
            end

            el.close:EventAttach(Event.UI.Input.Mouse.Cursor.In, MouseIn, "mouse cursor in")
            el.close:EventAttach(Event.UI.Input.Mouse.Cursor.Out, MouseOut, "mouse cursor out")
            el.close:EventAttach(Event.UI.Input.Mouse.Left.Click, LeftClick, "mouse left click")

            TKI.elements.header = el
        end,

        -- Creates menu element
        menu = function()
            local body = TKI.elements.body
            local header = TKI.elements.header
            local label = label .. "menu"

            -- background
            local el = UI.CreateFrame("Frame", label, body)
            el:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
            el:SetWidth(body:GetWidth())
            el:SetHeight(tKingUI.menu.height)
            el:SetBackgroundColor(unpack(tKingUI.menu.bg))

            -- icon
            el.icon = UI.CreateFrame("Texture", label .. ": icon", el)
            el.icon:SetPoint("CENTERRIGHT", el, "CENTERRIGHT", 0, 0)
            el.icon:SetWidth(tKingUI.menu.icon.width)
            el.icon:SetHeight(tKingUI.menu.icon.height)
            el.icon:SetTexture(addonID, tKingUI.menu.icon.src)

            TKI.elements.menu = el
        end
    }
}

TKMENU = {}


Command.Event.Attach(Event.Addon.SavedVariables.Load.End, function(handle, id) if id == addonID then TKI:init() end end, 'Load saved variables')