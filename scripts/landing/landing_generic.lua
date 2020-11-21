-- Generic landing function using faction pre-set parameters.
-- If 2nd parameter is nil, defaults to planet's faction
function land_faction( pnt, fct )
	-- DEBUG
	local strPrefix = "landing.lua:land_faction()"
	local boolDebug = false
	dbg.stdOutput( strPrefix, -1, "entering", boolDebug )

	-- Define local variables to be returned
	local tabReturn = {
		boolCanLand                  = false,
		strMessage                   = land_factions["default"].land_no_msg,
		optBribePriceOrDenialMessage = nil,
		strBribeMessage              = nil,
		strBribeAckMessage           = nil,
	}

	-- Parameters check
	if pnt==nil then
		-- No planet => no landing, default message
		dbg.stdOutput( strPrefix, 0, "exiting (no planet passed)", boolDebug )
		return tabReturn.boolCanLand, tabReturn.strMessage
	end

	-- Get planet name
	local strPlanetName = pnt:name()
	dbg.stdOutput( strPrefix, 1, string.format( "Planet : \"%s\"", strPlanetName ), boolDebug )

	-- If faction is not passed, use planet's faction
	if fct==nil then
		dbg.stdOutput( strPrefix, 1, "No faction passed, assuming planet faction.", boolDebug )
		fct = pnt:faction()
	end

	-- Get faction name
	local strFactionName = fct:name()
	dbg.stdOutput( strPrefix, 1, string.format( "Faction : \"%s\"", strFactionName ), boolDebug )

	-- Get landing parameters from faction
	local tabLandingParams = {}
	for i,v in pairs(land_factions[ "default" ]) do
		tabLandingParams[i] = v
	end
	if land_factions[ strFactionName ] ~= nil then
		dbg.stdOutput( strPrefix, 1, "Faction found in parameters table, replacing default parameters.", boolDebug )
		for i,v in pairs(land_factions[ strFactionName ]) do
			dbg.stdOutput( strPrefix, 2, string.format( "\"%s\" : replacing \"%s\" by \"%s\"", tostring(i), tostring(tabLandingParams[i]), tostring(v) ), boolDebug )
			tabLandingParams[i] = v
		end
	end

	-- DEBUG
	dbg.stdOutput( strPrefix, 1, "Landing parameters :", boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"land_floor\"      ] = \"%s\"", tostring(tabLandingParams.land_floor)      ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"bribe_floor\"     ] = \"%s\"", tostring(tabLandingParams.bribe_floor)     ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"land_msg\"        ] = \"%s\"", tostring(tabLandingParams.land_msg)        ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"land_warn_msg\"   ] = \"%s\"", tostring(tabLandingParams.land_warn_msg)   ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"land_bribe_msg\"  ] = \"%s\"", tostring(tabLandingParams.land_bribe_msg)  ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"land_no_msg\"     ] = \"%s\"", tostring(tabLandingParams.land_no_msg)     ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"bribe_base\"      ] = \"%s\"", tostring(tabLandingParams.bribe_base)      ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"bribe_rate\"      ] = \"%s\"", tostring(tabLandingParams.bribe_rate)      ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"bribe_ack_msg\"   ] = \"%s\"", tostring(tabLandingParams.nobribe_msg)     ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"nobribe_msg\"     ] = \"%s\"", tostring(tabLandingParams.bribeprice_fmsg) ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabLandingParams.[\"bribeprice_fmsg\" ] = \"%s\"", tostring(tabLandingParams.bribe_ack_msg)   ), boolDebug )
	dbg.stdOutput( strPrefix, 1, "}", boolDebug )

	-- Get bare landing status
	local numPlayerReputation       = fct:playerStanding()
		tabReturn.boolCanLand       = (numPlayerReputation >= tabLandingParams.land_floor)
	local boolCanBribe              = (numPlayerReputation >= tabLandingParams.bribe_floor)
	local boolIsPositive            = (numPlayerReputation >= 0)

	-- DEBUG
	dbg.stdOutput( strPrefix, 1, string.format( "Player can land (%s) / bribe (%s) / has positive reputation (%s)", tostring(tabReturn.boolCanLand), tostring(boolCanBribe), tostring(boolIsPositive) ), boolDebug )

	-- Branch according to the status
	if tabReturn.boolCanLand then
		if boolIsPositive then
			tabReturn.strMessage                   = tabLandingParams.land_msg
		else
			tabReturn.strMessage                   = tabLandingParams.land_warn_msg
		end
	else
		if boolCanBribe then
			tabReturn.strMessage = tabLandingParams.land_bribe_msg
			tabReturn.optBribePriceOrDenialMessage = (tabLandingParams.land_floor - numPlayerReputation) * tabLandingParams.bribe_rate * getshipmod() + tabLandingParams.bribe_base
			tabReturn.strBribeMessage = string.format( tabLandingParams.bribeprice_fmsg, tostring(tabReturn.optBribePriceOrDenialMessage) )
			tabReturn.strBribeAckMessage = tabLandingParams.bribe_ack_msg
		else
			tabReturn.strMessage = tabLandingParams.land_no_msg
			tabReturn.optBribePriceOrDenialMessage = tabLandingParams.nobribe_msg
		end
	end

	-- DEBUG
	dbg.stdOutput( strPrefix, 1, "Return parameters : {", boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabReturn.[\"boolCanLand\"                 ] = \"%s\"", tostring(tabReturn.boolCanLand)                  ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabReturn.[\"strMessage\"                  ] = \"%s\"", tostring(tabReturn.strMessage)                   ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabReturn.[\"optBribePriceOrDenialMessage\"] = \"%s\"", tostring(tabReturn.optBribePriceOrDenialMessage) ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabReturn.[\"strBribeMessage\"             ] = \"%s\"", tostring(tabReturn.strBribeMessage)              ), boolDebug )
	dbg.stdOutput( strPrefix, 2, string.format( "tabReturn.[\"strBribeAckMessage\"          ] = \"%s\"", tostring(tabReturn.strBribeAckMessage)           ), boolDebug )
	dbg.stdOutput( strPrefix, 1, "}", boolDebug )

	-- DEBUG
	dbg.stdOutput( strPrefix, 0, "exiting", boolDebug )

	-- Return landing variables
	return tabReturn.boolCanLand, tabReturn.strMessage, tabReturn.optBribePriceOrDenialMessage, tabReturn.strBribeMessage, tabReturn.strBribeAckMessage
end

-- Low-class landing function. Low class planets let you land and bribe at much lower standings.
function land_lowclass( pnt )
   return land_civilian(pnt, -20, -80)
end

-- High class landing function. High class planets can't be bribed.
function land_hiclass( pnt )
   return land_civilian(pnt, 0, 0)
end

-- Civilian planet landing logic.
-- Expects the planet, the lowest standing at which landing is allowed, and the lowest standing at which bribing is allowed.
function land_civilian( pnt, land_floor, bribe_floor )
   local fct = pnt:faction()
   local can_land = fct:playerStanding() >= land_floor or pnt:getLandOverride()

   -- Get land message
   local land_msg
   if can_land then
      land_msg = _("Permission to land granted.")
   else
      land_msg = _("Landing request denied.")
   end

   local bribe_msg, bribe_ack_msg
   -- Calculate bribe price. Note: Assumes bribe floor < land_floor.
   local bribe_price = getcost(fct, land_floor, bribe_floor, 1000) -- TODO: different rates for different factions.
   if not can_land and type(bribe_price) == "number" then
       local str      = numstring( bribe_price )
       bribe_msg      = string.format(
            gettext.ngettext(
               "\"I'll let you land for the modest price of %s credit.\"\n\nPay %s credit?",
               "\"I'll let you land for the modest price of %s credits.\"\n\nPay %s credits?",
               bribe_price),
            str, str )
       bribe_ack_msg  = _("Make it quick.")
   end
   return can_land, land_msg, bribe_price, bribe_msg, bribe_ack_msg
end

-- Military planet landing logic.
-- Expects the planet, the lowest standing at which landing is allowed, and four strings:
-- Landing granted string, standing too low string, landing denied string, message upon bribe attempt.
function land_military( pnt, land_floor, ok_msg, notyet_msg, no_msg, nobribe )
   local fct = pnt:faction()
   local standing = fct:playerStanding()
   local can_land = standing >= land_floor or pnt:getLandOverride()

   local land_msg
   if can_land then
      land_msg = ok_msg
   elseif standing >= 0 then
      land_msg = notyet_msg
   else
      land_msg = no_msg
   end

   return can_land, land_msg, nobribe
end

-- Planet landing logic based on strict reputation limits and no bribe at all.
-- Expects the planet, the faction, the lowest standing at which landing is allowed, and four strings:
-- Landing granted string, standing too low string, landing denied string, message upon bribe attempt.
function land_reputation_strict( pnt, fct, land_floor, ok_msg, notyet_msg, no_msg, nobribe_msg )
	local standing = fct:playerStanding()
	local can_land = standing >= land_floor

	local land_msg
	if can_land then
		land_msg = ok_msg
	elseif standing >= 0 then
		land_msg = notyet_msg
	else
		land_msg = no_msg
	end

	return can_land, land_msg, nobribe_msg
end
