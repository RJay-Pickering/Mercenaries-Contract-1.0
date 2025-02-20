Make a new project to start making Gareth's move-set work and create a generic as F#@$ template platforming map. Do the starts and gets overtime stuff and upload it to Itch as a browser game to have Stanlee play-test and use it for map design and character art.

1. Starts:
	- [x] walking 
	- [x] single jump 
	- [x] dash (basic) 
		- [x] Can dash when standing still.
		- [x] Small enemies stun when dashed.
		- [x] Bigger enemies that are not bosses stun when charged dashed.
		- [x] Bigger enemies that are not bosses will stun you when not charged dashed.
		- [x] Cannot dash more than once in the air.
		- [x] Second delay before next dash
	- [x] Basic up, down, left, and right attacks.
		- [x] Down-attacking enemies can make you pogo off of them.
		- [x] Combos do more damage.
		- [x] Charged attacks do lots of damage.
	- [x] Is still able to jump if they haven't jumped yet but are falling
2. Gets over time:
	- [x] Double jump
	- [x] Charged dash
	- [x] Wall jump
	- [x] Go through the background layer to interact in the background.
		- *NOTE:* Goes through orange walls when dashing, and with this enabled
	- [x] Second wind (second life type thing)
		- *NOTE*: When they die and revive, health lowers until enemies or players die

3. Upgrades (do this once approved and discussed on how the enhancements look):
	- [ ] Upgrade health (starts with 5 bars of health)
	- [ ] Dash upgrades (how many times you can dash in the air)
	- [ ] Rage upgrades (how long it lasts)
	- [ ] Health items (stores however many items you have)
	- [ ] Talismans/charm type thing (not an upgrade but benefits the player, maybe they could be how the user does the "gets over time"...)


4. Fixes to make:
	- [x] So when the player dies, they drop their gold.
	- [x] If the player dies, the gold is lost and replaced with the new loot drop.
	- [x] If the player does not use second wind or does not have it, when its on screen, they will have 10 seconds to retrieve their stuff before it disappears.
	- [x] If the player uses second winds but does not die, you keep gold in hand.
	- [x] If the player uses the second wind but dies, you will drop the gold, but there is no time limit on when you can pick it up
	- [x] If you use second wind and kill everything, your health resets to 100.
