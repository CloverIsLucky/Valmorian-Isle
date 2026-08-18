/datum/sex_action/knot_grinding
	name = "Grind your knot"
	check_same_tile = FALSE
	flipped = TRUE
	debug_erp_panel_verb = FALSE

/datum/sex_action/knot_grinding/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/component/knotting/knot = user.GetComponent(/datum/component/knotting)
	if(!knot)
		return FALSE
	if(knot.knotted_status != KNOTTED_AS_TOP)
		return FALSE
	return TRUE

/datum/sex_action/knot_grinding/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	var/datum/component/knotting/knot = user.GetComponent(/datum/component/knotting)
	if(!knot)
		return FALSE
	if(knot.knotted_status != KNOTTED_AS_TOP)
		return FALSE
	return TRUE

/datum/sex_action/knot_grinding/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	user.visible_message(span_warning("[user] begins to slowly grind [user.p_their()] knot inside [target]..."))

/datum/sex_action/knot_grinding/on_perform_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/verb = pick("grinds","rolls","pushes","presses","throbs")
	user.visible_message(sex_session.spanify_force("[user] [sex_session.get_generic_force_adjective()] [verb] [user.p_their()] knot inside [target]..."))

/datum/sex_action/knot_grinding/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	playsound(user, sex_session.get_force_sound(), 30, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target, pixels = 2)
	sex_session.perform_sex_action(user, 2.5, 0, TRUE)
	sex_session.perform_sex_action(target, 2.5, 5, FALSE)
	sex_session.handle_passive_ejaculation(user)
	sex_session.handle_passive_ejaculation(target)

/datum/sex_action/knot_grinding/handle_climax_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_love("[user]'s knot throbs and pulses as [user.p_they()] cum[user.p_s()] deep inside [target]!"))
	user.virginity = FALSE
	target.virginity = FALSE
	return "into"

/datum/sex_action/knot_grinding/get_finish_message(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return span_warning("[user] stops grinding [user.p_their()] knot inside [target].")
