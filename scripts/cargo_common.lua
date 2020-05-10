include "jumpdist.lua"
include "nextjump.lua"

-- Find an inhabited planet in specified range.
-- Defaults are minDistance = 1 and maxDistance = 9
-- Mutos 2013/06/13 : use sigma distribution and rounds up
function cargo_selectMissionDistance (minDistance, maxDistance)
	-- Declare local variables
	local meanDistance, intervalDistance, missionDistance

	-- Check arguments
	if minDistance==nil then
		minDistance = 1
	end
	if maxDistance==nil then
		maxDistance = 9
	end
	if minDistance > maxDistance then
		minDistance, maxDistance = maxDistance, minDistance
	end

	-- Compute a random distance
	meanDistance = (minDistance+maxDistance)/2
	intervalDistance = (maxDistance-minDistance)/2
	missionDistance = meanDistance + intervalDistance * rnd.sigma()

	return math.ceil(missionDistance)
end

-- Build a set of target lists {planet, system}
function cargo_selectPlanets(missdist, routepos)
	local planets = {}
	getsysatdistance(system.cur(), missdist, missdist,
		function(s)
			for i, v in ipairs(s:planets()) do
				if v:services()["inhabited"] and v ~= planet.cur() and v:class() ~= 0 and
						not (s==system.cur() and ( vec2.dist( v:pos(), routepos ) < 2500 ) ) and
						v:canLand() then
					planets[#planets + 1] = {v, s}
				end
			end
			return true
		end)

	return planets
end

-- Build a set of target systems
-- Todo : instead of selecting landable planets, select systems with no landable planet
function cargo_selectSystems(missdist, routepos, landable)
	if landable==nil then
		landable = true
	end
	local systems = {}
	getsysatdistance(system.cur(), missdist, missdist,
		function(s)
			-- System is current, not selectable
			if s == system.cur() then
				return true
			end
			-- Add the system to the list
			systems[#systems + 1] = s
		end
	)

	return systems
end

-- We have a destination, now we need to calculate how far away it is by simulating the journey there.
-- Assume shortest route with no interruptions.
-- This is used to calculate the reward.
function cargo_calculateDistance(routesys, routepos, destsys, destplanet)
	local traveldist = 0

	local tempList = getRouteList(routesys, destsys)
	local tempString = ""
	for i, j in pairs(tempList) do
		if i==1 then
			tempString = tempString .. j:name()
		else
			tempString = tempString .. ";" .. j:name()
		end
	end
	-- print ( string.format( "Final route is : \"%s\"", tempString ) )

	while routesys ~= destsys do
		-- We're not in the destination system yet.
		-- So, get the next system on the route, and the distance between our entry point and the jump point to the next system.
		-- Then, set the exit jump point as the next entry point.
		local tempsys = getNextSystem(routesys, destsys)
		local j,r = jump.get( routesys, tempsys )
		traveldist = traveldist + vec2.dist(routepos, j:pos())
		routepos = r:pos()
		routesys = tempsys
	end

	-- We ARE in the destination system now, so route from the entry point to the destination planet.
	traveldist = traveldist + vec2.dist(routepos, destplanet:pos())

	return traveldist
end

-- Compute a route
function cargo_calculateRoute ( bUseDestinationCommodities )
	-- Log enter
	-- print ( string.format( "\n\tcargo_calculateRoute() : entering" ) )

	-- declare local variables
	local origin_p = nil
	local origin_s = nil

	-- Check flag : if not specified, then false
	if bUseDestinationCommodities==nil then
		bUseDestinationCommodities = false
	end

	-- Planet of origin : if not specified, current planet
	origin_p, origin_s = planet.cur()
	local routesys = origin_s
	local routepos = origin_p:pos()

	-- Select mission tier.
	local tier = rnd.rnd(0, 4)

	-- Select a random distance
	local missdist = cargo_selectMissionDistance(1, 10)

	-- Find a possible planet at that distance
	local planets = cargo_selectPlanets(missdist, routepos)
	if #planets == 0 then
		-- print ( string.format( "\tcargo_calculateRoute() : exiting, planets list empty" ) )
		return
	end

	-- Select a planet from the returned list
	-- print ( string.format ( "\tcargo_calculateRoute() : \tNumber of planets found : %i.", #planets ) )
	local index	  = rnd.rnd(1, #planets)
	local destplanet = planets[index][1]
	local destsys	= planets[index][2]

	-- We have a destination, now we need to calculate how far away it is by simulating the journey there.
	-- Assume shortest route with no interruptions.
	-- This is used to calculate the reward.
	-- print ( string.format ( "\tcargo_calculateRoute() : using destination planet : \"%s\".", destplanet:name() ) )
	local numjumps   = origin_s:jumpDist(destsys)
	local traveldist = cargo_calculateDistance(routesys, routepos, destsys, destplanet)

	-- We now know where. But we don't know what yet. Randomly choose a commodity type.
	-- Mutos, 2012/11/11 : extract the cargo from the current planet's commodities list.
	-- Mutos, 2013/06/12 : added a flag to use destination instead, used for economic events.
	local availableCommodities
	local cargoes = {}
	if bUseDestinationCommodities then
		-- print ( string.format ( "\tcargo_calculateRoute() : using destination planet : \"%s\".", destplanet:name() ) )
		availableCommodities = destplanet:commoditiesSold()
	else
		-- print ( string.format ( "\tcargo_calculateRoute() : using origin planet : \"%s\".", origin_p:name() ) )
		availableCommodities = origin_p:commoditiesSold()
	end

	if #availableCommodities==0 then
		-- No commodity sold on either planet, so use default cargoes
		-- print ( string.format ( "\tcargo_calculateRoute() : \tNo commodity on planets, using default cargoes." ) )
		-- print ( string.format( "\tcargo_calculateRoute() : exiting with no return" ) )
		-- return
		cargoes = {"Generic Food", "Industrial Goods", "Medicine", "Luxury Goods", "Ore"}
	else
		-- Use commodities found on origin or destination planet
		for i,v in ipairs(availableCommodities) do
			-- print ( string.format ( "\tcargo_calculateRoute() : \tCommodity : \"%s\"", v:name() ) )
			table.insert(cargoes,v:name())
		end
	end
	local cargo = cargoes[rnd.rnd(1, #cargoes)]

	-- Log exit
	-- print ( string.format( "\tcargo_calculateRoute() : exiting returning a planet" ) )

	-- Return lots of stuff
	return destplanet, destsys, numjumps, traveldist, cargo, tier
end

-- Compute a route
function cargo_calculateSmugglerRoute (  )
	-- declare local variables
	local origin_p = nil
	local origin_s = nil

	-- Init startup position
	origin_p, origin_s = planet.cur()
	local routesys = origin_s
	local routepos = origin_p:pos()

	-- Select a random distance - longer trips than cargo missions
	local missDistMid = cargo_selectMissionDistance(5, 9)
	local missDistEnd = cargo_selectMissionDistance(12, 20)

	-- Find a possible planet at that distance
	local planets = cargo_selectPlanets(missdist, routepos)
	if #planets == 0 then
		return
	end

	local index	  = rnd.rnd(1, #planets)
	local destplanet = planets[index][1]
	local destsys	= planets[index][2]

	-- We have a destination, now we need to calculate how far away it is by simulating the journey there.
	-- Assume shortest route with no interruptions.
	-- This is used to calculate the reward.
	local numjumps   = origin_s:jumpDist(destsys)
	local traveldist = cargo_calculateDistance(routesys, routepos, destsys, destplanet)

end


-- Construct the cargo mission description text
function buildCargoMissionDescription( desc, priority, amount, ctype, destplanet, destsys )
	-- declare local variables
	local origin_p = nil
	local origin_s = nil

	origin_p, origin_s = planet.cur()
	local numjumps   = origin_s:jumpDist(destsys)
	local str = desc[rnd.rnd(1, #desc)]

	if priority ~= nil then
		str = priority .. " " .. str
	end
	if system.cur() ~= destsys then
		str = string.format( "%s in %s", str, destsys:name() )
	end
	if amount == nil then
		return string.format( "%s (%s jumps)", str:format( destplanet:name()), numjumps )
	else
		return string.format( "%s (%s tonnes, %s jumps)", str:format( destplanet:name()), amount, numjumps )
	end
end


-- Calculates the minimum possible time taken for the player to reach a destination.
function cargoGetTransit( timelimit, numjumps, traveldist )
	local pstats   = player.pilot():stats()
	local stuperpx = 1 / player.pilot():stats().speed_max * 30
	local arrivalt = time.get() + time.create(0, 0, traveldist * stuperpx + numjumps * pstats.jump_delay + 10180 + 240 * numjumps)
	return arrivalt
end
