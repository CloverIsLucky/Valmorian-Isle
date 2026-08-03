///Datum for basic mobs to define what they can attack.
/datum/targetting_datum

///Returns true or false depending on if the target can be attacked by the mob
/datum/targetting_datum/proc/can_attack(mob/living/living_mob, atom/target)
	return

///Returns something the target might be hiding inside of
/datum/targetting_datum/proc/find_hidden_mobs(mob/living/living_mob, atom/target)

	if(!QDELETED(target) || !target.loc)
		return

	var/atom/target_hiding_location
	if(istype(target.loc, /obj/structure/closet))
		target_hiding_location = target.loc
	return target_hiding_location

/datum/targetting_datum/basic

/datum/targetting_datum/basic/can_attack(mob/living/living_mob, atom/the_target)
	if(isturf(the_target) || !the_target) // bail out on invalids
		return FALSE

	var/mob/living/simple_animal/simple_mob = living_mob
	if(istype(simple_mob) && simple_mob.binded)
		return FALSE

	if(ismob(the_target)) //Target is in godmode, ignore it.
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE

	if(living_mob.see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isturf(the_target.loc) && living_mob.z != the_target.z)
		return FALSE

	if(isliving(the_target)) //Targetting vs living mobs
		var/mob/living/L = the_target
		if(living_mob.summoner && living_mob.summoner == the_target.name) // won't attack whomever summoned it
			return FALSE
		// Short circuits the expensive faction check call if they are dead
		if(L.stat || faction_check(living_mob, L))
			return FALSE
		return TRUE

	return FALSE

/datum/targetting_datum/basic/proc/faction_check(mob/living/living_mob, mob/living/the_target)
	return living_mob.faction_check_mob(the_target, FALSE)

/// Subtype which doesn't care about faction
/// Mobs which retaliate but don't otherwise target seek should just attack anything which annoys them
/datum/targetting_datum/basic/ignore_faction

/datum/targetting_datum/basic/ignore_faction/faction_check(mob/living/living_mob, mob/living/the_target)
	return FALSE

/// Livestock and other critters that never start a fight of their own - plain simple animals like
/// cows and chickens, plus the retaliate-only ones like goats and swine. Wolves, bears and the rest
/// of the seek-and-kill hostiles are not covered and stay fair game.
/proc/is_passive_critter(atom/thing)
	if(!istype(thing, /mob/living/simple_animal))
		return FALSE
	if(istype(thing, /mob/living/simple_animal/hostile) && !istype(thing, /mob/living/simple_animal/hostile/retaliate))
		return FALSE
	return TRUE

/// TRUE once a critter has picked the fight itself - it is hunting the minion or the minion's master,
/// or it has already earned a place on the minion's threat table by hitting it.
/proc/critter_has_provoked(mob/living/critter, mob/living/minion)
	var/mob/living/simple_animal/hostile/beast = critter
	if(istype(beast) && beast.target)
		if(beast.target == minion)
			return TRUE
		if(minion.summoner && beast.target.name == minion.summoner)
			return TRUE
	var/datum/ai_controller/controller = minion.ai_controller
	if(controller)
		var/list/aggro_table = controller.blackboard[BB_MOB_AGGRO_TABLE]
		if(islist(aggro_table) && aggro_table[critter])
			return TRUE
	return FALSE

GLOBAL_DATUM_INIT(undead_minion_targetting, /datum/targetting_datum/basic/undead_minion, new)

/// Raised minions hunt anything dangerous, but leave the farmyard alone until it swings first.
/datum/targetting_datum/basic/undead_minion

/datum/targetting_datum/basic/undead_minion/can_attack(mob/living/living_mob, atom/the_target)
	. = ..()
	if(!.)
		return FALSE
	if(!is_passive_critter(the_target))
		return TRUE
	return critter_has_provoked(the_target, living_mob)

GLOBAL_DATUM_INIT(conjured_targetting, /datum/targetting_datum/basic/conjured, new)

/datum/targetting_datum/basic/conjured

/datum/targetting_datum/basic/conjured/can_attack(mob/living/living_mob, atom/the_target)
	. = ..()
	if(!.)
		return FALSE
	var/datum/component/conjured_minion/comp = living_mob.GetComponent(/datum/component/conjured_minion)
	if(!comp)
		return TRUE
	var/mob/living/summoner = comp.summoner_ref?.resolve()
	if(!summoner || summoner.z != living_mob.z)
		return TRUE
	if(get_dist(the_target, summoner) > comp.leash_range + 1)
		return FALSE
