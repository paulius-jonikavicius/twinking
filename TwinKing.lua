local toc, data = ...
local addonID = toc.identifier
local TwinKing

local dummyDB = {
    warrior = {
        [1] = {
            name = "Uogute",
            lastReceived = nil
        },
        [2] = { name = "Paseles" }
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
        -- Message received
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
        --  Returns position and player or nil
        -- ]]
        contains = function(player)
            for i, v in ipairs(tKingDB[player.class]) do
                if v.name == player.name then
                    return v, i
                end
            end
            return nil
        end,
        --[[
        --  Kills the 'king' by moving him to the end
        --  of the list
        -- ]]
        kill = function(king, pos)
            while pos < #tKingDB do
                tKingDB[pos] = tKingDB[pos + 1]
                pos = pos + 1
            end
            tKingDB[pos] = king
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
        -- @data = {
        --  class   = string
        --  name    = string
        -- ]]
        received = function(this, from, data)
        --    validate 'from'
            if this:isValidBroadcaster(from) then
                local king, pos = TwinKing.DB.contains(decode(data))

                if king ~= nil then
                    king.lastReceived = Inspect.Time.Server()
                    TwinKing.DB.kill(king, pos)
                end
            end
        end
    }
}

Command.Event.Attach(Event.Message.Receive, TwinKing.event.messageReceived, "Message received")