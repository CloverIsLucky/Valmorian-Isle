/datum/sex_action/force_milk_genitals
	name = "Forcibly milk cock"
	check_same_tile = FALSE
	require_grab = TRUE
	required_grab_state = GRAB_AGGRESSIVE
	debug_erp_panel_verb = FALSE

/datum/sex_action/force_milk_genitals/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(target.getorganslot(ORGAN_SLOT_PENIS) || target.getorganslot(ORGAN_SLOT_VAGINA))
		return TRUE
	return FALSE

/datum/sex_action/force_milk_genitals/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	var/holding = user.get_active_held_item()
	if(!istype(holding, /obj/item/reagent_containers/glass))
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS) && !target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/force_milk_genitals/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	user.visible_message(span_warning("[user] starts masturbating [target] over [user.get_active_held_item()]..."))

/datum/sex_action/force_milk_genitals/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] jerks [target]'s pintle into the [user.get_active_held_item()]..."))
	else
		user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] fingers [target]'s cunt over the [user.get_active_held_item()]..."))

/datum/sex_action/force_milk_genitals/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(target, sex_session.get_force_sound(), 50, TRUE, -2, ignore_walls = FALSE)
	sex_session.perform_sex_action(target, 2, 4, TRUE)

/datum/sex_action/force_milk_genitals/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		return span_warning("[user] stops jerking [target] into the container.")
	return span_warning("[user] stops fingering [target] over the container.")
