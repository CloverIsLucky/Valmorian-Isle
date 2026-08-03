// Harpy natural gear ported from Emerald Summit (dummy_items.dm + species/harpy.dm).

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons
	name = "talons"
	desc = "Harpy talons. Birds of prey and all..."
	experimental_inhand = FALSE
	icon = 'modular/emerald_summit/icons/harpy_misc32.dmi' //VALMORIAN: VI's misc32.dmi lacks the harpy_talon state, ES copy shipped under modular
	icon_state = "harpy_talon" // coder kitbash 5 minute sprite ugh
	drop_sound = 'sound/blank.ogg'
	gripped_intents = list(/datum/intent/wing/cut, /datum/intent/wing/shred, /datum/intent/wing/grab, /datum/intent/wing/pick)
	associated_skill = /datum/skill/combat/unarmed
	w_class = WEIGHT_CLASS_HUGE
	wlength = WLENGTH_GREAT
	twohands_required = TRUE
	force = 20
	max_blade_int = 200
	max_integrity = 250
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	no_effect = FALSE
	pickup_sound = 'sound/blank.ogg'

	var/repair_amount = 5 //The amount of integrity the tattoos will repair themselves
	var/repair_time = 250 //The amount of time between each repair
	var/last_repair //last time the tattoos got repaired

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration)
	. = ..()
	if(obj_integrity < max_integrity)
		START_PROCESSING(SSobj, src)
		return

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons/process()
	if(obj_integrity >= max_integrity)
		STOP_PROCESSING(SSobj, src)
		src.visible_message(span_notice("[src] are in a much better shape now, enough resting!"), vision_distance = 1)
		return
	else if(world.time > src.last_repair + src.repair_time)
		src.last_repair = world.time
		obj_integrity = min(obj_integrity + src.repair_amount, src.max_integrity)
	..()

/datum/intent/wing/cut
	name = "cut"
	icon_state = "incut"
	attack_verb = list("cuts", "slashes")
	animname = "cut"
	blade_class = BCLASS_CUT
	hitsound = list('sound/combat/hits/bladed/smallslash (1).ogg', 'sound/combat/hits/bladed/smallslash (2).ogg', 'sound/combat/hits/bladed/smallslash (3).ogg')
	penfactor = PEN_NONE //VALMORIAN: ES penfactors are a 0-100 percentage; VI uses PEN_* tiers (0-4)
	chargetime = 0
	swingdelay = 0
	clickcd = 8
	item_d_type = "slash"

/datum/intent/wing/shred
	name = "shred"
	icon_state = "inchop"
	attack_verb = list("shreds")
	animname = "chop"
	blade_class = BCLASS_CHOP
	hitsound = list('sound/combat/hits/bladed/smallslash (1).ogg', 'sound/combat/hits/bladed/smallslash (2).ogg', 'sound/combat/hits/bladed/smallslash (3).ogg')
	penfactor = PEN_LIGHT //VALMORIAN: ES 10/100 — a chop that bites through trash armor only
	damfactor = 1.5
	swingdelay = 5
	clickcd = 10
	item_d_type = "slash"

/datum/intent/wing/grab
	name = "talon grab"
	icon_state = "ingrab"
	attack_verb = list("digs", "impales")
	hitsound = list('sound/combat/hits/bladed/genstab (1).ogg', 'sound/combat/hits/bladed/genstab (2).ogg', 'sound/combat/hits/bladed/genstab (3).ogg')
	penfactor = PEN_BSTEEL //VALMORIAN: ES 90/100 — the grab is the talons' armor-defeating bite
	clickcd = 15
	swingdelay = 0
	damfactor = 1.3
	blade_class = BCLASS_PICK

/datum/intent/wing/pick
	name = "talon pick"
	icon_state = "inpick"
	attack_verb = list("stabs", "impales")
	hitsound = list('sound/combat/hits/bladed/genstab (1).ogg', 'sound/combat/hits/bladed/genstab (2).ogg', 'sound/combat/hits/bladed/genstab (3).ogg')
	penfactor = PEN_HEAVY //VALMORIAN: ES 75/100 — pierces mail/plate, a step under the grab
	clickcd = 14
	swingdelay = 12
	damfactor = 1.1
	blade_class = BCLASS_PICK

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons/equipped(mob/user, slot, initial)
	. = ..()
	wielded = TRUE

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons/attack_self(mob/user)
	if(user.pulling)
		var/mob/living/passenger = user.pulling
		user.stop_pulling()
		passenger.remove_status_effect(/datum/status_effect/debuff/harpy_passenger)
		return

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NOEMBED, TRAIT_GENERIC)

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons/dropped(mob/living/carbon/human/user)
	. = ..()
	src.moveToNullspace()
	if(user.pulling)
		var/mob/living/passenger = user.pulling
		user.stop_pulling(TRUE)
		passenger.remove_status_effect(/datum/status_effect/debuff/harpy_passenger)
	user.remove_status_effect(/datum/status_effect/debuff/harpy_flight)

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons/intercept_zImpact(atom/movable/AM, levels = 1) // with this shit it doesn't generate "X falls through open space". thank u guppyluxx
	. = ..()
	. |= FALL_NO_MESSAGE

/obj/item/rogueweapon/huntingknife/idagger/harpy_talons/attack(mob/living/target, mob/living/carbon/human/user)
	if(user.used_intent.type == /datum/intent/wing/grab)
		if(isliving(target))
			if(target != user)
				if(user.pulling)
					user.stop_pulling(TRUE)
					return ..() // remove ..() if problems arise
				if(target.checkdefense(user.used_intent, user))
					return FALSE
				user.start_pulling(target, state = 1, supress_message = TRUE, item_override = src) // STATE = 1 OH GOD!! GRAB STATE PASSIVE = 0, AGRO = 1
				if(user.pulling)
					to_chat(user, span_bloody("I am carrying [target] with my talons!! Ha ha ha!!"))
					var/obj/item/grabbing/I = user.get_inactive_held_item()
					if(istype(I, /obj/item/grabbing/))
						I.icon_state = null
					target.apply_status_effect(/datum/status_effect/debuff/harpy_passenger)
					user.buckle_mob(target, TRUE, TRUE) //VALMORIAN: VI buckle_mob(M, force, check_loc) — extra ES args dropped
					user.buckle_mob(target, TRUE, TRUE) // brute forcing this shit vro..
					return ..() // remove ..() if problems arise
	else
		return ..()

/obj/item/harpy_leg
	name = "harpy's leg"
	item_state = "grabbing"
	icon_state = "grabbing"
	icon = 'icons/mob/roguehudgrabs.dmi'
	drop_sound = 'sound/blank.ogg'
	experimental_inhand = FALSE
	max_integrity = 10
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	no_effect = TRUE

/obj/item/harpy_leg/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/harpy_leg/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/harpy_leg/intercept_zImpact(atom/movable/AM, levels = 1) // with this shit it doesn't generate "X falls through open space". thank u guppyluxx
	. = ..()
	. |= FALL_NO_MESSAGE

// Natural feet armor. //VALMORIAN: reparented from ES /armor/skin_armor onto VI's regenerating skin base,
// which already provides TRAIT_NODROP on Initialize, qdel-on-drop, and passive self-repair.
/obj/item/clothing/suit/roguetown/armor/regenerating/skin/harpy_skin
	slot_flags = null
	name = "harpy's feet skin"
	desc = ""
	icon_state = null
	body_parts_covered = FEET|LEGS
	body_parts_inherent = FEET|LEGS
	//VALMORIAN: translated from ES's 0-100 scale (90/90/50/20) onto VI's tier defines - strong
	//blunt/slash on the taloned legs, middling stab, poor pierce, no fire. A step below the
	//gnoll's full-body ARMOR_GNOLL_STANDARD since this only covers feet and legs.
	armor = list("blunt" = DR_SUPER, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_LIGHT, "fire" = DR_NONE)
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST) //VALMORIAN: var lives in modular/emerald_summit/_extensions.dm
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = FALSE
	max_integrity = 75
	resistance_flags = FIRE_PROOF
	//VALMORIAN: mandatory on any /regenerating subtype. take_damage() passes repair_time straight to
	//addtimer(), whose ASSERT(isnum(wait)) fails on null - DM only applies a default argument when
	//the argument is omitted, not when null is passed explicitly. Leaving this unset meant a runtime
	//on every hit to the legs and skin that never regenerated. 20% of 75 per tick.
	repair_time = 30 SECONDS

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/harpy_skin/obj_destruction()
	visible_message("The skin on the feet is torn!", span_bloody("<b>THE SKIN ON MY FEET IS TORN!!</b>")) // deliberately no ..() — the skin is never deleted, matching ES behavior

// --------- Flight movement (shared by the Fly Up/Down keybinds and the Flight tab verbs) ---------

///One z-step of winged flight: athletics-scaled stamina cost, slower/costlier while carrying a
///grabbed passenger, who comes along. Returns TRUE on a successful move.
/mob/living/carbon/proc/try_fly_move(dir)
	if(!flying)
		to_chat(src, span_red("I'm not flying!"))
		return FALSE
	var/turf/open/transparent/openspace/target_turf = get_step_multiz(src, dir)
	if(!canZMove(dir, target_turf))
		to_chat(src, span_red("I can't fly [dir == UP ? "up" : "down"] there!!"))
		return FALSE
	var/athletics_skill = max(get_skill_level(/datum/skill/misc/athletics), SKILL_LEVEL_NOVICE)
	var/stamina_cost_final = round((10 - athletics_skill), 1)
	var/mob/living/carbon/human/pulled = pulling
	var/time_taken = (dir == UP) ? 1 SECONDS : 0.5 SECONDS
	if(ismob(pulled))
		stamina_cost_final *= 1.5 //higher stamina cost if we're pulling someone with us
		if(dir == UP)
			time_taken *= 2.5
	if(!do_after(src, time_taken))
		return FALSE
	if(ismob(pulled))
		pulled.forceMove(target_turf)
	forceMove(target_turf)
	if(ismob(pulled)) //re-establish the talon grab broken by the z-move
		start_pulling(pulled, state = 1, supress_message = TRUE)
		if(pulling)
			buckle_mob(pulled, TRUE, TRUE)
			var/obj/item/grabbing/I = get_inactive_held_item()
			if(istype(I, /obj/item/grabbing/))
				I.icon_state = null
	stamina_add(stamina_cost_final)
	to_chat(src, span_notice("I fly [dir == UP ? "upwards" : "downwards"]."))
	return TRUE

/mob/living/carbon/human/proc/harpy_fly_up()
	set name = "Fly Up"
	set category = "Harpy"
	try_fly_move(UP)

/mob/living/carbon/human/proc/harpy_fly_down()
	set name = "Fly Down"
	set category = "Harpy"
	try_fly_move(DOWN)
