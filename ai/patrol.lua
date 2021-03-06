include("dat/ai/tpl/generic.lua")
include("dat/ai/personality/patrol.lua")

-- Settings
mem.armour_run = 40
mem.armour_return = 70
mem.aggressive = true
mem.nojump = true

function create ()
	-- Not too many credits.
	ai.setcredits( rnd.rnd(ai.pilot():ship():price()/300, ai.pilot():ship():price()/70) )

	-- Lines to annoy the player. Shouldn't be too common.
	r = rnd.rnd(0,20)
	if r == 0 then
	  ai.pilot():broadcast("We are watching you.")
	 elseif r == 1 then
		ai.pilot():broadcast("The Patrol sees all.")
	end

	-- Get refuel chance
	p = player.pilot()
	if p:exists() then
		standing = ai.getstanding( p ) or -1
		mem.refuel = rnd.rnd( 2000, 4000 )
		if standing < 20 then
			mem.refuel_no = "\"My fuel is not mine to give away.\""
		elseif standing < 70 then
			if rnd.rnd() > 0.2 then
				mem.refuel_no = "\"My fuel is not mine to give away.\""
			end
		else
			mem.refuel = mem.refuel * 0.6
		end
		-- Most likely no chance to refuel
		mem.refuel_msg = string.format( "\"I suppose I could spare some fuel for %d credits.\"", mem.refuel )
	end

	-- See if can be bribed
	if rnd.rnd() > 0.7 then
		mem.bribe = math.sqrt( ai.pilot():stats().mass ) * (500. * rnd.rnd() + 1750.)
		mem.bribe_prompt = string.format("\"For some %d credits I could forget about seeing you.\"", mem.bribe )
		mem.bribe_paid = "\"Now scram before I change my mind.\""
	else
	  bribe_no = {
				"\"You won't buy your way out of this one.\"",
				"\"The Patrol likes to make examples out of scum like you.\"",
				"\"You've made a huge mistake.\"",
				"\"Bribery carries a harsh penalty, scum.\"",
				"\"I'm not interested in your blood money!\"",
				"\"All the money in the world won't save you now!\""
	  }
	  mem.bribe_no = bribe_no[ rnd.rnd(1,#bribe_no) ]
	  
	end

	mem.loiter = 3                    -- This is the amount of waypoints the pilot will pass through before landing or leaving the system

	-- Finish up creation
	create_post()
end

-- taunts
function taunt ( target, offense )

	-- Only 50% of actually taunting.
	if rnd.rnd(0,1) == 0 then
		return
	end

	-- some taunts
	if offense then
		taunts = {
				"There is no room in this universe for scum like you!",
				"The Patrol will enjoy your death!",
				"None can wreck havoc on the spaceways!",
				"Enjoy your last moments, criminal!"
		}
	else
		taunts = {
				"You dare attack me!",
				"You are no match for the Patrol!",
				"The Patrol will have your head!",
				"You'll regret that!",
				"That was a fatal mistake!"
		}
	end

	ai.pilot():comm(target, taunts[ rnd.rnd(1,#taunts) ])
end


