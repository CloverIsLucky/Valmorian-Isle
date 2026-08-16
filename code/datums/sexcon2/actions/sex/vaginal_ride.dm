/datum/sex_action/sex/vaginal_ride
	name = "Ride them"
	stamina_cost = 1.0
	intensity = 4
	knot_on_finish = TRUE
	flipped = TRUE
	debug_erp_panel_verb = FALSE

/datum/sex_action/sex/vaginal_ride/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/sex/vaginal_ride/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_VAGINA))
		return FALSE
	return TRUE

/datum/sex_action/sex/vaginal_ride/get_start_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] gets on top of [target] and begins riding [target.p_them()] with [user.p_their()] cunt!")

/datum/sex_action/sex/vaginal_ride/get_start_sound(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg')

/datum/sex_action/sex/vaginal_ride/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] rides [target]."))

/datum/sex_action/sex/vaginal_ride/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(target, sex_session.get_force_sound(), 50, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target)
	do_onomatopoeia(user)
	sex_session.perform_sex_action(user, 2, 0, TRUE)
	if(sex_session.considered_limp(target))
		sex_session.perform_sex_action(target, 1.2, 3, FALSE)
	else
		sex_session.perform_sex_action(target, 2.4, 7, FALSE)
	sex_session.handle_passive_ejaculation(user)

/datum/sex_action/sex/vaginal_ride/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user] cums into [target]'s cunt!"))
	user.try_impregnate(target)
	user.virginity = FALSE
	target.virginity = FALSE
	return "into"

/datum/sex_action/sex/vaginal_ride/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] gets off [target].")

/datum/sex_action/sex/vaginal_ride/get_knot_count()
	return 1

/datum/sex_action/sex/vaginal_ride/lock_sex_object(mob/living/carbon/human/user, mob/living/carbon/human/target)
	sex_locks |= new /datum/sex_session_lock(user, ORGAN_SLOT_VAGINA)
