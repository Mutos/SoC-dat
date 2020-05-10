include("dat/ai/tpl/escort.lua")
include("dat/ai/personality/patrol.lua")

include "debug/debug.lua"

-- Settings
mem.aggressive = true


function create ()
	local strPrefix = "AI Player Escort script create()"
	local boolDebug = false

	dbg.stdOutput( strPrefix, -1, "entering", boolDebug )

   mem.loiter = 3 -- This is the amount of waypoints the pilot will pass through before leaving the system

	mem.escort = player.pilot()

	dbg.stdOutput( strPrefix, 0, "exiting", boolDebug )
end

