/datum/sex_action/oral/blowjob
	name = "Suck their pintle off"
	check_same_tile = FALSE
	target_priority = 100
	intensity = 4
	flipped = TRUE
	works_on_detached_head = TRUE
	debug_erp_panel_verb = FALSE

/datum/sex_action/oral/blowjob/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target && !detached_head_self_service(user))
		return FALSE
	if(is_head_focus(user, target))
		if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
			return FALSE
		if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
			return FALSE
		if(!user.getorganslot(ORGAN_SLOT_PENIS))
			return FALSE
	else
		if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
			return FALSE
		if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_MOUTH))
			return FALSE
		if(!target.getorganslot(ORGAN_SLOT_PENIS))
			return
	return TRUE

/datum/sex_action/oral/blowjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target && !detached_head_self_service(user))
		return FALSE
	if(is_head_focus(user, target))
		if(check_sex_lock(user, ORGAN_SLOT_PENIS))
			return FALSE
		if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
			return FALSE
		if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
			return FALSE
		if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
			return FALSE
		if(!user.getorganslot(ORGAN_SLOT_PENIS))
			return FALSE
	else
		if(check_sex_lock(target, ORGAN_SLOT_PENIS))
			return FALSE
		if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
			return FALSE
		if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
			return FALSE
		if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_MOUTH))
			return FALSE
		if(!target.getorganslot(ORGAN_SLOT_PENIS))
			return FALSE
	return TRUE

/datum/sex_action/oral/blowjob/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(user == target)
		user.visible_message(span_warning("[user] starts using [user.p_their()] severed head to suck [user.p_their()] own pintle..."))
	else if(is_head_focus(user, target))
		user.visible_message(span_warning("[user] slides [user.p_their()] pintle into [get_head_name(user, target)]'s mouth..."))
	else
		user.visible_message(span_warning("[user] starts sucking [target]'s pintle..."))

/datum/sex_action/oral/blowjob/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(is_head_focus(user, target))
		user.visible_message(span_warning("[user] pulls [user.p_their()] pintle from [get_head_name(user, target)]'s mouth..."))
	else
		user.visible_message(span_warning("[user] stops sucking [tgt_poss(user, target)] pintle ..."))

/datum/sex_action/oral/blowjob/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(user, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/oral/blowjob/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user] cums into [tgt_poss(user, target)] mouth!"))
	return "into"

/datum/sex_action/oral/blowjob/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	if(is_head_focus(user, target))
		user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] uses [get_head_name(user, target)] on [user.p_their()] pintle..."))
	else
		user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] sucks [tgt_poss(user, target)] pintle..."))

/datum/sex_action/oral/blowjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.make_sucking_noise()
	// you want to know how i got these scars?
	if(istype(user.head, /obj/item/clothing/head/roguetown/jester))
		playsound(user, SFX_JINGLE_BELLS, 30, TRUE, -2, ignore_walls = FALSE)
	if(user == target)
		if(!do_self_head_effects(user))
			do_thrust_animate(user, target)
	else if(is_head_focus(user, target))
		if(!do_head_focus_effects(user, target))
			do_thrust_animate(user, target)
	else
		do_thrust_animate(user, target)

	sex_session.perform_sex_action(target, 2, 0, TRUE)
