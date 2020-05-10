-- Choose the next system to jump to on the route from system nowsys to system finalsys.
function getNextSystem(nowsys, finalsys)
	 if nowsys == finalsys then
		  return nowsys
	 else
		  local neighs = nowsys:adjacentSystems()
		  local nearest = -1
		  local mynextsys = finalsys
		  for _, j in pairs(neighs) do
				if nearest == -1 or j:jumpDist(finalsys) < nearest then
					 nearest = j:jumpDist(finalsys)
					 mynextsys = j
				end
		  end
		  return mynextsys
	 end
end

-- Return the list of systems on the route from system nowsys to system finalsys.
function getRouteList(nowSystem, finalSystem)
	local systemsList
	local nextSystem

	-- print ( string.format( "\tEntering getRouteList()" ) )

	if nowSystem == nil or finalSystem == nil then
		return {}
	end

	-- print ( string.format( "\t\tOrigin System      : \"%s\"", nowSystem:name() ) )
	-- print ( string.format( "\t\tDestination System : \"%s\"", finalSystem:name() ) )

	 if nowSystem == finalSystem then
		  systemsList = {nowSystem}
	 else
		nextSystem = getNextSystem(nowSystem, finalSystem)
		systemsList = getRouteList(nextSystem, finalSystem)
		table.insert(systemsList, 1, nowSystem)
	 end

	-- print ( string.format( "\t\tNumber of systems in list : %d", #systemsList ) )
	-- print ( string.format( "\tExiting getRouteList()" ) )

	return systemsList
end