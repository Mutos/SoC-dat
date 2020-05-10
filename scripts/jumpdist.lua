--[[
-- @brief Fetches an array of systems from min to max jumps away from the given
--       system sys.
--
-- The following example gets a random Sirius M class planet between 1 to 6 jumps away.
--
-- @code
-- local planets = {} 
-- getsysatdistance( system.cur(), 1, 6,
--     function(s)
--         for i, v in ipairs(s:planets()) do
--             if v:faction() == faction.get("Sirius") and v:class() == "M" then
--                 planets[#planets + 1] = {v, s}
--             end
--         end 
--         return false
--     end )
-- 
-- if #planets == 0 then abort() end -- Sanity in case no suitable planets are in range.
-- 
-- local index = rnd.rnd(1, #planets)
-- destplanet = planets[index][1]
-- destsys = planets[index][2]     
-- @endcode
--
--    @param sys System to calculate distance from or nil to use current system
--    @param min Minimum distance to check for.
--    @param max Maximum distance to check for.
--    @param filter Optional filter function to use for more details.
--    @param data Data to pass to filter
--    @return The table of systems n jumps away from sys
--]]
function getsysatdistance( sys, min, max, filter, data )
	-- Get default parameters
	if sys == nil then
		sys = system.cur()
	end
	if max == nil or max < min then
		max = min
	end
	-- Begin iteration
	return _getsysatdistance( sys, min, max, sys, max, {}, filter, data )
end


-- The first call to this function should always have n >= max
function _getsysatdistance( target, min, max, sys, n, t, filter, data )
	-- print ( string.format( "\t\tRunning _getsysatdistance (target=\"%s\", min=%i, max=%i, sys=\"%s\", n=%i, t[%i], data)", target:name(), min, max, sys:name(), n, #t ) )
	if n == 0 then -- This is a leaf call - perform checks and add if appropriate
		local d = target:jumpDist(sys)

		-- Check bounds
		if d < min or d > max then
			-- print ( string.format( "\t\t\tSystem out of bounds : %i for [%i, %i]", d, min, max ) )
			return t
		end

		-- Don't add a system already in our array
		for _,i in ipairs(t) do
			if i == sys then
				-- print ( string.format( "\t\t\tSystem already in return table" ) )
				return t
			end
		end

		-- Case filter function is available
		if filter ~= nil and not filter(sys, data) then
			-- print ( string.format( "\t\t\tSystem does not pass filter" ) )
			return t
		end

		-- All test are OK, add to the tab
		-- print ( string.format( "\t\t\tSystem OK : adding to return table : \"%s\"", sys:name() ) )
		t[#t+1] = sys
	else -- This is a branch call - recursively call over all adjacent systems
		for _,i in pairs( sys:adjacentSystems() ) do
			t = _getsysatdistance(target, min, max, i, n-1, t, filter, data)
		end
	end

	-- Finally return the table
	return t
end


