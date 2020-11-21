-- Helpers for landing function.
-- Helper function for determining the bribe cost multiplier for the player's current ship.
-- Returns the factor the bribe cost is multiplied by when the player tries to bribe.
-- NOTE: This should be replaced by something better in time.
function getshipmod()
	local light = {"Yacht", "Luxury Yacht", "Drone", "Fighter", "Bomber", "Scout"}
	local medium = {"Destroyer", "Corvette", "Courier", "Armoured Transport", "Freighter"}
	local heavy = {"Cruiser", "Carrier"}
	local ps = player.pilot():ship()
	for _, j in ipairs(light) do
		if ps == j then return 1 end
	end
	for _, j in ipairs(medium) do
		if ps == j then return 2 end
	end
	for _, j in ipairs(heavy) do
		if ps == j then return 4 end
	end
	return 1
end

-- Helper function for calculating bribe availability and cost.
-- Expects the faction, the minimum standing to land, the minimum standing to bribe, and a going rate for bribes.
-- Returns whether the planet can be bribed, and the cost for doing so.
function getcost(fct, land_floor, bribe_floor, rate)
	local standing = fct:playerStanding()
	if standing < bribe_floor then
      return _("\"I'm not dealing with dangerous criminals like you!\"")
	else
		-- Assume standing is always lower than the land_floor.
		return (land_floor - standing) * rate * getshipmod() + 5000
	end
end
