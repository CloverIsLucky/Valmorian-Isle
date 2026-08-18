/datum/sex_action/force_footjob
	name = "Use their feet to get off"
	check_same_tile = FALSE
	require_grab = TRUE
	required_grab_state = GRAB_AGGRESSIVE
	stamina_cost = 1.0
	debug_erp_panel_verb = FALSE

/datum/sex_action/force_footjob/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!target.has_sex_feet())
		return FALSE
	return TRUE

/datum/sex_action/force_footjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_L_FOOT))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_R_FOOT))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/force_footjob/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	user.visible_message(span_warning("[user] grabs [target]'s feet and clamps them around [user.p_their()] pintle!"))

/datum/sex_action/force_footjob/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] uses [target]'s feet to jerk off."))

/datum/sex_action/force_footjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(target, sex_session.get_force_sound(), 50, TRUE, -2, ignore_walls = FALSE)
	sex_session.perform_sex_action(user, 2, 4, TRUE)
	sex_session.handle_passive_ejaculation(target)

/datum/sex_action/force_footjob/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user] cums on [target]'s feet!"))
	return "onto"

/datum/sex_action/force_footjob/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [user.p_their()] pintle out from between [target]'s feet.")

/datum/sex_action/force_footjob/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(user, ORGAN_SLOT_PENIS)
