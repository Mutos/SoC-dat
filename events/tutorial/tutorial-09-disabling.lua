-- This is the tutorial: disabling.

require("events/tutorial/tutorial-common.lua")
require("scripts/fleethelper.lua")

-- localization stuff, translators would work here
lang = naev.lang()
if lang == "es" then
else -- default english
	 title1 = "Tutorial: Disabling"
	 message1 = [[Welcome to the disabling tutorial.

During the game it is sometimes desirable or necessary to disable another ship, and other ships may end up disabling you as well. This tutorial shows you how disabling works and shows what happens when you yourself are disabled.]]
	 message2 = [[The first thing you should know about disabling is that it cannot be done reliably with most weapons in the game. Each weapon deals two kinds of damage on each hit: regular damage and "stress" damage. Stress damage is what causes ships to become disabled.

A target practice drone has been placed in the system near your location. Target it and fire at it using your Ion Cannons (they're secondary weapons by default). Pay close attention to the target's armour bar.]]
	 message3 = [[Good. As you will have noticed, the target's armour bar filled up with a different colour while you were shooting at it. This is how stress damage is represented in the game. Stress damage builds up in the armour bar until all remaining armour is filled with stress damage. Stress damage disappears from a ship at a constant rate, unless the ship is actually disabled. This means that to successfully disable a ship, you will need to keep dealing enough stress damage to overcome this falloff.
	 
A ship becomes disabled as soon as the total amount of stress it has accrued equals its remaining hit points. This means that the less armour the ship has, the easier it is to disable. In addition, dealing regular damage to a ship not only removes armour, it also proportionally reduces stress damage! What this means is that it's not possible to first deal stress damage, and then reduce the ship's armour to go below it.]]
	 message4 = [[You can disable enemies, but of course enemies can do the same to you. In a moment, some pirates will attack you with Ion Cannons. For the purpose of this tutorial you will not be able to fight back, but don't worry. You can't die from this attack.

Close this message and observe.]]
	 message5 = [[As you will see in a second, time compression automatically kicks in when you are disabled. The reason for this is simple: disabled ships don't stay disabled forever. Ships will eventually repair themselves and become mobile once again. When this happens to you, the player, time compression makes sure you don't have to wait too long. Of course, you can still be destroyed and boarded in the meantime! Now wait for your ship to repair itself.]]
	 message6 = [[You now know how to disable ships and what happens when you are disabled yourself. As a final tip, remember that you can see how much stress damage each weapon does on the outfitter and equipment screens.

Congratulations! This concludes the disabling tutorial.]]
end

function create()
	 -- Set up the player here.
	player.teleport("Nyotekundu")
	 pilot.clear()
	 pilot.toggleSpawn(false) -- To prevent NPCs from getting targeted for now.

	 pp = player.pilot()
	 pp:setPos(vec2.new(0, 0))
	player.swapShip("Nelk'Tan", "Nelk'Tan", "Earth", true, true)
	 pp:rmOutfit("all")
	 pp:addOutfit("Fighter Ion Cannon", 4)
	 pp:setDir(90)
	 player.msgClear()

	pp:setNoLand()
	pp:setNoJump()

	 tk.msg(title1, message1)
	 tk.msg(title1, message2)
	 dummypractice()
end

-- Hooked function, initiates drone target practice.
function dummypractice()
	 drone = pilot.add("Angry Bee Drone", "dummy", player.pilot():pos() + vec2.new(200, 0))[1]
	 drone:rename("Target drone")
	 drone:rmOutfit("all")
	 drone:setHealth(100, 0)
	 drone:setHostile()
	 drone:setVisplayer(true)
	 hook.pilot(drone, "death", "dronedeath")
	 hook.pilot(drone, "attacked", "dronedamage")
	 hook.pilot(drone, "disable", "dronedisable")
end

-- Drone death hook. This drone isn't supposed to die.
function dronedeath()
	 drone:rm()
	 dummypractice()
end

-- Drone attack hook. To make sure it doesn't drift off.
function dronedamage()
	 drone:setVel(vec2.new())
end

-- Drone disable hook.
function dronedisable()
	 drone:setVel(vec2.new())
	 drone:setInvincible()
	 hook.timer(2000, "getdisabled")
end

-- Make pirates disable the player ship.
function getdisabled()
	 tk.msg(title1, message3)
	 tk.msg(title1, message4)
	 drone:rm()
	 pp:control()
	 pirates = addRawShips( "Nelk'Tan", "pirate", pp:pos() + vec2.new(1000, 0), "Pirate", 2 )
	 pirates[1]:rmOutfit("all")
	 pirates[1]:addOutfit("Fighter Ion Cannon", 4)
	 pirates[2]:rmOutfit("all")
	 pirates[2]:addOutfit("Fighter Ion Cannon", 4)
	 pirates[1]:control()
	 pirates[2]:control()
	 pirates[1]:attack(pp)
	 pirates[2]:attack(pp)
	 hook.pilot(pp, "attacked", "playerattacked")
	 hook.pilot(pp, "disable", "playerdisabled")
end

-- Player attacked hook. Make sure the player can't die.
function playerattacked()
	_, shi, str = pp:health()
	pp:setHealth(100, shi, str)
end

-- Player is disabled
function playerdisabled()
	player.pilot():setInvincible(true)
	pirates[1]:control()
	pirates[2]:control()
	pirates[1]:hyperspace()
	pirates[2]:hyperspace()
	hook.timer(1000, "duringdisabled")
end

-- Message during the disabled state
function duringdisabled()
	tk.msg(title1, message5)
	hook.timer(25000, "afterdisabled")
end

-- Message during the disabled state
function afterdisabled()
	tk.msg(title1, message6)
	hook.safe( "cleanup" )
end

-- Cleanup function. Should be the exit point for the module in all cases.
function cleanup()
	 if not (omsg == nil) then player.omsgRm(omsg) end
	 naev.keyEnableAll()
	 naev.eventStart("Tutorial")
	 evt.finish(true)
end
