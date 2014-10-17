local toc, data = ...
local addonID = toc.identifier
local TwinKing

TwinKing = {
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
print(Inspect.Guild.Roster.Detail("Uogutes"))