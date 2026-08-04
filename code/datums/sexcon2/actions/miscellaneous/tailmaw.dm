/// Checks whether a mob has a tail with a maw (can_suck sprite accessory).
/proc/has_tail_maw(mob/living/carbon/human/user)
	var/obj/item/organ/tail/tail = user.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail?.accessory_type)
		return FALSE
	var/datum/sprite_accessory/tail/tail_type = tail.accessory_type
	return initial(tail_type.can_suck)

/datum/sex_action/tailmaw_fuck
	name = "Fuck their tailmaw"
	check_same_tile = FALSE
	stamina_cost = 1.0
	intensity = 4
	debug_erp_panel_verb = FALSE

/datum/sex_action/tailmaw_fuck/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!has_tail_maw(target))
		return FALSE
	return TRUE

/datum/sex_action/tailmaw_fuck/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!has_tail_maw(target))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/tailmaw_fuck/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] grabs [target]'s tail, and slides [user.p_their()] pintle inside!")

/datum/sex_action/tailmaw_fuck/get_start_sound(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg')

/datum/sex_action/tailmaw_fuck/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] fucks [target]'s tailmaw."))

/datum/sex_action/tailmaw_fuck/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(target, sex_session.get_force_sound(), 50, TRUE, -2, ignore_walls = FALSE)
	if(prob(50))
		user.make_sucking_noise()
	do_thrust_animate(user, target)
	sex_session.perform_sex_action(user, 2, 0, TRUE)
	sex_session.perform_sex_action(target, 2.4, 7, FALSE)
	sex_session.handle_passive_ejaculation(target)

/datum/sex_action/tailmaw_fuck/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user] cums into [target]'s tailmaw!"))
	user.virginity = FALSE
	target.virginity = FALSE
	return "into"

/datum/sex_action/tailmaw_fuck/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [user.p_their()] pintle out of [target]'s tailmaw.")

/datum/sex_action/tailmaw_fuck/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(user, ORGAN_SLOT_PENIS)

/datum/sex_action/tailmaw_blowjob
	name = "Suck their pintle with your tailmaw"
	check_same_tile = FALSE
	flipped = TRUE
	debug_erp_panel_verb = FALSE

/datum/sex_action/tailmaw_blowjob/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!has_tail_maw(user))
		return FALSE
	return TRUE

/datum/sex_action/tailmaw_blowjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!has_tail_maw(user))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/tailmaw_blowjob/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(user == target)
		user.visible_message(span_warning("[user] moves [user.p_their()] tail into place and begins to envelop [user.p_their()] own pintle..."))
	else
		user.visible_message(span_warning("[user] moves [user.p_their()] tail into place and begins to envelop [target]'s pintle..."))
	playsound(user, pick('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/tailmaw_blowjob/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/verb = pick("sucks","slurps","suckles","engulfs","twists around","massages")
	if(user == target)
		user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] [verb] [user.p_their()] own pintle with [user.p_their()] tailmaw."))
	else
		user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] [verb] [target]'s pintle with [user.p_their()] tailmaw."))

/datum/sex_action/tailmaw_blowjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(user, sex_session.get_force_sound(), 30, TRUE, -2, ignore_walls = FALSE)
	if(prob(50))
		user.make_sucking_noise()
	sex_session.perform_sex_action(target, 2, 0, TRUE)
	sex_session.handle_passive_ejaculation(user)

/datum/sex_action/tailmaw_blowjob/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[target] ejaculates into [user]'s tailmaw!"))
	return "into"

/datum/sex_action/tailmaw_blowjob/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return span_warning("[user] releases [user.p_their()] own pintle from [user.p_their()] tailmaw.")
	return span_warning("[user] releases [target]'s pintle from [user.p_their()] tailmaw.")

/datum/sex_action/tailmaw_cunnilingus
	name = "Suck their cunt with your tailmaw"
	check_same_tile = FALSE
	flipped = TRUE
	debug_erp_panel_verb = FALSE

/datum/sex_action/tailmaw_cunnilingus/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!has_tail_maw(user))
		return FALSE
	return TRUE

/datum/sex_action/tailmaw_cunnilingus/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!has_tail_maw(user))
		return FALSE
	return TRUE

/datum/sex_action/tailmaw_cunnilingus/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	user.visible_message(span_warning("[user]'s tail moves into place and opens, beginning to envelop [target]'s groin..."))

/datum/sex_action/tailmaw_cunnilingus/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/verb = pick("sucks","slurps","suckles","engulfs","licks","teases")
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] [verb] [target]'s cunt with [user.p_their()] tailmaw..."))

/datum/sex_action/tailmaw_cunnilingus/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.make_sucking_noise()
	do_thrust_animate(user, target)
	sex_session.perform_sex_action(target, 2, 3, TRUE)
	sex_session.handle_passive_ejaculation(target)

/datum/sex_action/tailmaw_cunnilingus/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[target] ejaculates into [user]'s tailmaw!"))
	return "into"

/datum/sex_action/tailmaw_cunnilingus/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] withdraws [user.p_their()] tail and releases [target]'s cunt...")

/datum/sex_action/tailmaw_breast_suckle
	name = "Suck their breasts with your tailmaw"
	check_same_tile = FALSE
	debug_erp_panel_verb = FALSE

/datum/sex_action/tailmaw_breast_suckle/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	if(!has_tail_maw(user))
		return FALSE
	return TRUE

/datum/sex_action/tailmaw_breast_suckle/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	if(!has_tail_maw(user))
		return FALSE
	return TRUE

/datum/sex_action/tailmaw_breast_suckle/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	user.visible_message(span_warning("[user] opens [user.p_their()] tailmaw, raising and pressing it around one of [target]'s breasts..."))

/datum/sex_action/tailmaw_breast_suckle/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/verb = pick("sucks","slurps","suckles","engulfs","licks","teases","squeezes","massages")
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] [verb] [target]'s breasts with [user.p_their()] tailmaw..."))

/datum/sex_action/tailmaw_breast_suckle/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	if(prob(50))
		user.make_sucking_noise()
	do_thrust_animate(user, target)
	sex_session.perform_sex_action(target, 2, 2, TRUE)

/datum/sex_action/tailmaw_breast_suckle/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls away, and releases [target]'s breasts...")
