local toc, data = ...
local addonID = toc.identifier
local TwinKing

TwinKing = {
    ranks = {
        ["Head Honcho"] = true,
        ["Guild Leaders"] = true
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
        -- ]]
        received = function(this, from, data)
        --    validate 'from'
            if this:isValidBroadcaster(from) then
                -- TODO: update information
            end
        end
    }
}

Command.Event.Attach(Event.Message.Receive, TwinKing.event.messageReceived, "Message received")
--[[
local ranks = Inspect.Guild.Rank.List()
for _, l in pairs(ranks) do
    print(l)
end
]]
