require("factions/spawn/common.lua")

-- ================================================================================================
--   Spawn functions
-- ================================================================================================
--

function spawn_patrol_Eershlan ()
	return scom.Ship( "Eershlan", scom.PresenceTable["Eershlan"], "Shoden Clusters" );
end

function spawn_patrol_Eresslih ()
	return scom.Ship( "Eresslih", scom.PresenceTable["Eresslih"], "Shoden Clusters" );
end

function spawn_patrol_Arshiilan ()
	return scom.Ship( "Arshiilan", scom.PresenceTable["Arshiilan"], "Shoden Clusters" );
end

--
-- ================================================================================================


-- ================================================================================================
--   Weights table
-- ================================================================================================
--

function createWeightTable ( )
	local weights = {}

	-- Create weights for spawn table
	weights[ spawn_patrol_Eershlan    ] =  5
	weights[ spawn_patrol_Eresslih    ] =  2
	weights[ spawn_patrol_Arshiilan   ] =  1

	return weights
end

--
-- ================================================================================================


-- ================================================================================================
--   Hooks for spawning process
-- ================================================================================================
--

-- @brief Creation hook.
function create ( max )
	local strPrefix = string.format( "shoden.lua:create()" )
	local boolDebug = false

	dbg.stdOutput( strPrefix, -1, "entering", boolDebug )
	dbg.stdOutput( strPrefix, 1, string.format( "Parameters : max=%i", max ), boolDebug )

	local weights = createWeightTable ()

	-- Create spawn table base on weights
	spawn_table = scom.createSpawnTable( weights )

	-- Calculate spawn data
	spawn_data = scom.choose( spawn_table )

	dbg.stdOutput( strPrefix, 0, "exiting", boolDebug )
	return scom.calcNextSpawn( 0, scom.presence(spawn_data), max )
end


-- @brief Spawning hook
function spawn ( presence, max )
	--DEBUG
	local strPrefix = "shoden.lua:spawn()"
	local boolDebug = false
	dbg.stdOutput( strPrefix, -1, "entering", boolDebug )
	dbg.stdOutput( strPrefix, 1, string.format( "Parameters : presence:%i, max:%i", presence, max ), boolDebug )

	local pilots

	-- Over limit
	if presence > max then
		dbg.stdOutput( strPrefix, 1, string.format( "presence>max : no spawn, returning 5" ), boolDebug )
		dbg.stdOutput( strPrefix, 0, "exiting", boolDebug )
		return 5
	end

	-- Actually spawn the pilots
	-- If system is held by Shoden or allies, spawn patrols, else raiders
	local sysCurrent    = system.cur()
	local fctSysFaction = system.faction(sysCurrent)
	local fctShoden     = faction.get("Shoden Clusters")
	local strAI  = ""
	local strTag = ""
	if fctSysFaction~=nil and faction.areAllies(fctSysFaction,fctShoden) then
		dbg.stdOutput( strPrefix, 1, string.format( "System \"%s\" is allied with Shoden, spawning Patrol", sysCurrent:name() ), boolDebug )
		strAI  = "shoden_patrol"
		strTag = "Patrol"
	else
		dbg.stdOutput( strPrefix, 1, string.format( "System \"%s\" is not allied with Shoden, spawning Raider", sysCurrent:name() ), boolDebug )
		strAI  = "shoden_raider"
		strTag = "Raider"
	end
	pilots = scom.spawn( spawn_data , "Shoden Clusters" , strAI )
	for k,v in ipairs(pilots) do
		v["pilot"]:rename( "Shoden " .. v["pilot"]:name() .. " " .. strTag )
	end

	-- Calculate spawn data
	spawn_data = scom.choose( spawn_table )

	-- DEBUG
	dbg.stdOutput( strPrefix, 0, "exiting", boolDebug )

	return scom.calcNextSpawn( presence, scom.presence(spawn_data), max ), pilots
end

--
-- ================================================================================================
