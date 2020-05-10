-- Toolsets include
include "numstring.lua"
include "debug/debug.lua"

-- Landing functions include
include "landing/landing_hooks.lua"				-- Any function actually called by an asset's XML <land> tag goes there
include "landing/landing_generic.lua"			-- Generic functions called by landing_hooks functions
include "landing/landing_specific.lua"			-- Functions called by landing_hooks functions for a given planet, faction, species or other criteria
include "landing/landing_params_factions.lua"	-- Parameters table used by the faction-based functions.
include "landing/landing_params_passes.lua"		-- Parameters table used by the passes-based functions.
