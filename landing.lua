--[[
   Prototype function:

      Parameter: pnt - Planet to set landing stuff about.
      Return: 1) Boolean whether or not can land
              2) Land message which should be denial if can't land or acceptance if can
              3) (optional) Bribe price or message that can't be bribed or nil in the case of no possibility to bribe.
              4) (Needed with bribe price) Bribe message telling the price to pay
              5) (Needed with bribe price) Bribe acceptance message

   Examples:

   function yesland( pnt )
      return true, "Come on in dude"
   end

   function noland( pnt )
      return false, "Nobody expects the Spanish Inquisition!"
   end

   function noland_nobribe( pnt )
      return false, "No can do.", "Seriously, don't even think of bribing me dude."
   end

   function noland_yesbribe( pnt )
      return false, "You can't land buddy", 500, "But you can bribe for 500 credits", "Thanks for the money"
   end

--]]

-- Debug facility
require "scripts/debug/debug.lua"

-- Toolsets
require "scripts/numstring.lua"

-- Actual landing functions
require "scripts/landing/landing_hooks.lua"				-- Any function actually called by an asset's XML <land> tag goes there
require "scripts/landing/landing_generic.lua"			-- Generic landing logics called by landing_hooks functions
require "scripts/landing/landing_specific.lua"			-- Functions called by landing_hooks functions for a given planet, faction, species or other criteria
require "scripts/landing/landing_helpers.lua"			-- Helper functions called by landing_hooks functions
require "scripts/landing/landing_params_factions.lua"	-- Parameters table used by the faction-based functions.
require "scripts/landing/landing_params_passes.lua"		-- Parameters table used by the passes-based functions.
