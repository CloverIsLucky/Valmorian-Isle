/datum/sex_action/tailgrope
	name = "Grope them with your tail"
	check_same_tile = FALSE
	debug_erp_panel_verb = FALSE

/datum/sex_action/tailgrope/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.has_sex_tail())
		return FALSE
	return TRUE

/datum/sex_action/tailgrope/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!user.Adjacent(target))
		return FALSE
	if(!user.has_sex_tail())
		return FALSE
	return TRUE

/datum/sex_action/tailgrope/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	user.visible_message(span_warning("[user] edges closer and reaches toward [target] with [user.p_their()] tail..."))

/datum/sex_action/tailgrope/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/zone_text = lowertext(parse_zone(user.zone_selected))
	var/action_verb
	if(user.zone_selected == BODY_ZONE_CHEST && target.getorganslot(ORGAN_SLOT_BREASTS))
		action_verb = pick("gropes","fondles","caresses","squeezes","massages")
		zone_text = "breasts"
	else
		action_verb = pick("strokes","fondles","caresses")
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] [action_verb] [target]'s [zone_text] with [user.p_their()] tail..."))

/datum/sex_action/tailgrope/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	if(sex_session.force > SEX_FORCE_HIGH)
		playsound(target, 'sound/misc/mat/fingering.ogg', 35, TRUE, -2, ignore_walls = FALSE)
	else
		user.make_sucking_noise()
	do_thrust_animate(user, target)
	sex_session.perform_sex_action(user, 0.5, 0.2, TRUE)
	sex_session.handle_passive_ejaculation(user)
	sex_session.perform_sex_action(target, 1, 0.5, TRUE)
	sex_session.handle_passive_ejaculation(target)

/datum/sex_action/tailgrope/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] releases [target] and withdraws [user.p_their()] tail...")
