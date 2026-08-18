/datum/sex_action/force_blowjob
	name = "Force them to suck"
	require_grab = TRUE
	required_grab_state = GRAB_AGGRESSIVE
	stamina_cost = 1.0
	intensity = 4
	knot_on_finish = TRUE
	debug_erp_panel_verb = FALSE

/datum/sex_action/force_blowjob/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/force_blowjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/force_blowjob/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	user.visible_message(span_warning("[user] forces [target]'s head down to swallow and suck on [user.p_their()] pintle!"))
	playsound(target, pick('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/force_blowjob/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] forces [target] to suck [user.p_their()] pintle."))

/datum/sex_action/force_blowjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.make_sucking_noise()
	do_thrust_animate(target, user)
	sex_session.perform_sex_action(user, 2, 4, TRUE)
	sex_session.perform_sex_action(target, 0, 7, FALSE)
	sex_session.handle_passive_ejaculation(target)

/datum/sex_action/force_blowjob/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user] cums into [target]'s throat!"))
	return "into"

/datum/sex_action/force_blowjob/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] pulls [user.p_their()] pintle out of [target]'s throat.")

/datum/sex_action/force_blowjob/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(user, ORGAN_SLOT_PENIS)
	sex_locks |= new /datum/sex_session_lock(target, BODY_ZONE_PRECISE_MOUTH)
