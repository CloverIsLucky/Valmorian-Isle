
/datum/action/cooldown/spell/raise_undead_guard
	name = "Conjure Undead"
	desc = "Invoke forbidden magicka to summon a mindless, shambling skeleton.\nMindless skeletons can be given orders to guard, patrol, and attack by their summoner.\nThese skeletons are weaker than their more complex-jointed counterparts, but are harder to incapacitate."
	background_icon = 'icons/mob/actions/zizomiracles.dmi'
	button_icon = 'icons/mob/actions/zizomiracles.dmi'
	button_icon_state = "skeleton"
	cast_range = 7
	sound = 'sound/magic/magnet.ogg'
	primary_resource_cost = 40
	primary_resource_type = SPELL_COST_STAMINA
	charge_required = TRUE
	charge_time = 6 SECONDS
	charge_slowdown = 1
	associated_skill = /datum/skill/magic/arcane
	cooldown_time = 1 MINUTES
	zizo_spell = TRUE
	invocations = list("Convoca spectres custodes!")
	invocation_type = INVOCATION_SHOUT
	var/spawn_lifespan

/datum/action/cooldown/spell/raise_undead_guard/cast(atom/cast_on)
	. = ..()

	if(istype(get_area(owner), /area/rogue/indoors/ravoxarena))
		to_chat(owner, span_userdanger("I reach for outer help, but something rebukes me! This challenge is only for me to overcome!"))
		reset_spell_cooldown()
		return FALSE

	var/turf/T = get_turf(cast_on)
	if(!isopenturf(T) || T.is_blocked_turf())
		to_chat(owner, span_warning("The targeted location is blocked. My summon fails to come forth."))
		return FALSE

	new /obj/effect/temp_visual/gib_animation(T, "gibbed-h")
	new /obj/effect/temp_visual/bluespace_fissure(T)
	var/mob/living/skeleton_new = new /mob/living/carbon/human/species/skeleton/npc/summon(T, owner)
	apply_mob_lifespan(skeleton_new, owner, spawn_lifespan)
	var/caster_name = owner.mind?.current?.real_name
	if(caster_name)
		addtimer(CALLBACK(src, PROC_REF(add_skeleton_faction), skeleton_new, owner, caster_name), 1.1 SECONDS)
	return TRUE

/// Delayed so it lands after the skeleton's own after_creation(). Mirrors
/// /mob/living/simple_animal/hostile/rogue/skeleton/Initialize(): the raised formation inherits the
/// caster's factions outright rather than keeping FACTION_UNDEAD, which is what lets those skeletons
/// engage hostile undead and cabal NPCs instead of standing around next to them.
/datum/action/cooldown/spell/raise_undead_guard/proc/add_skeleton_faction(mob/living/skeleton, mob/living/caster, caster_name)
	if(QDELETED(skeleton))
		return
	skeleton.summoner = caster_name
	if(!QDELETED(caster) && caster.mind?.current)
		skeleton.faction = caster.mind.current.faction.Copy()
	skeleton.faction |= list("cabal", "[caster_name]_faction")
	skeleton.ai_controller?.set_blackboard_key(BB_TARGETTING_DATUM, GLOB.undead_minion_targetting)
	if(!QDELETED(caster))
		caster.track_summon(skeleton)	// so relay_attack_to_summons() puts our attacker on its threat table
	pull_nearby_aggro(skeleton, caster)

/// Lifted from /datum/action/cooldown/spell/raise_undead_formation/cast() - shoves the new summon to
/// the top of every nearby hostile NPC's threat list so the fight starts on it, not on the caster.
/datum/action/cooldown/spell/raise_undead_guard/proc/pull_nearby_aggro(mob/living/skeleton, mob/living/caster)
	for(var/mob/living/M in view(8, skeleton))
		if(M == skeleton)
			continue
		if(M.stat == DEAD)
			continue
		if(M.mind)
			continue
		if(!M.ai_controller)
			continue
		if(is_passive_critter(M))	// don't hand the summon a war with the nearest chicken
			continue
		if(M.faction_check_mob(skeleton))
			continue
		if(caster && M.faction_check_mob(caster))
			continue

		M.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, skeleton)
		M.ai_controller.set_blackboard_key(BB_HIGHEST_THREAT_MOB, skeleton)

		var/datum/component/ai_aggro_system/aggro = M.GetComponent(/datum/component/ai_aggro_system)
		if(aggro)
			aggro.add_threat_to_mob(skeleton, 1000)
			if(caster)
				aggro.add_threat_to_mob(caster, -1000)

/datum/action/cooldown/spell/raise_undead_guard/necromancer
	spawn_lifespan = 45 MINUTES //Longer cooldown, therefore, technically less total than before -> more player skeles will fill in for this.
