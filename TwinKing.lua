local toc, data = ...
local addonID = toc.identifier
local TwinKing
local playerID = Inspect.Unit.Lookup("player") -- get player id

local dummyDB = {
    warrior = {
        [1] = "Uogute",
        [2] = "Paseles",
        ["Uogute"] = nil,
        ["Paseles"] = nil
    },
    cleric = {},
    rogue = {},
    mage = {}
}

TwinKing = {
    ranks = {
        ["Head Honcho"] = true,
        ["Guild Leaders"] = true,
        ["Crusader"] = true
    },
    event = {
        --[[
        --  Handles broadcasted messages
        -- ]]
        messageReceived = function(handle, from, type, channel, identifier, data)
            if identifier == addonID then
                -- TODO: call function based on data
                TwinKing.MSG:received(from, data)
            end
        end
    },
    DB = {
        --[[
        --  Checks if player is in the database.
        --  Returns position and player name or nil
        -- ]]
        contains = function(player)
            if tKingDB[player.class][player.name] then
                for i, v in ipairs(tKingDB[player.class]) do
                    if v == player.name then
                        return v, i
                    end
                end
            end

            return nil
        end,
        --[[
        --  Kills the 'king' by moving him to the end
        --  of the list and updating time
        --  @data = {}
        --      class   = string
        --      name    = string
        --  @pos = int
        -- ]]
        kill = function(data, pos)
            while pos < #tKingDB[data.class] do
                tKingDB[data.class][pos] = tKingDB[data.class][pos + 1]
                pos = pos + 1
            end
            tKingDB[data.class][pos] = data.name
            tKingDB[data.class][data.name] = Inspect.Time.Server() -- update time
        end
    },
    MSG = {
        --[[
        -- Checks if the message was broadcaster by correct person
        -- ]]
        isValidBroadcaster = function(this, from)
        -- User is the broadcaster
            if from == Inspect.Unit.Detail("player").name then
                return false
            end

            -- Broadcaster is not a member of the guild
            from = Inspect.Guild.Roster.Detail(from)
            if from == nil then
                return false
            end

            -- Broadcaster has insufficient rank
            if not this.ranks[from.rank] then
                return false
            end

            return true
        end,
        --[[
        -- Broadcasted message receiver
        -- @from = string, player name
        -- @data = {}
        --  class   = string
        --  name    = string
        -- ]]
        received = function(this, from, data)
        --    validate 'from'
            if this:isValidBroadcaster(from) then
                local data = decode(data)
                local king, pos = TwinKing.DB.contains(data)

                if king ~= nil then
                    TwinKing.DB.kill(data, pos)
                end
            end
        end,
        broadcast = {
            kill = function(name)
                detail = Inspect.Guild.Roster.Detail(name)
                king = Inspect.Unit.Detail(detail.id)
            end
        }
    },
    test = function(h, t, c, a)

    end
}

Command.Event.Attach(Event.Message.Receive, TwinKing.event.messageReceived, "Message received")
Command.Event.Attach(Event.Unit.Availability.Full, TwinKing.test, "Test King")

--print_r(Inspect.Unit.Lookup("Uogute"))