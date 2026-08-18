/// Whether this mob has a tail the tail actions can use. A lamia's coils and a drider's abdomen are
/// /obj/item/bodypart/taur limbs rather than an ORGAN_SLOT_TAIL organ, so asking the organ slot alone
/// hides every tail action from exactly the species that most obviously has one.
/mob/living/proc/has_sex_tail()
	if(iscarbon(src))
		var/mob/living/carbon/carbon_src = src
		if(carbon_src.getorganslot(ORGAN_SLOT_TAIL))
			return TRUE
	return get_taur_tail()

/// Whether this mob has feet the foot actions can use. Taurs have none - but their lower body lists
/// both foot zones as subtargets, so get_bodypart() hands the taur limb back and nothing upstream
/// notices. Every foot action has to ask the owner of the feet explicitly.
/mob/living/proc/has_sex_feet()
	return !get_taur_tail()

/mob/living/carbon/human/proc/get_highest_grab_state_on(mob/living/carbon/human/victim)
	var/grabstate = null
	if(r_grab && r_grab.grabbed == victim)
		if(grabstate == null || r_grab.grab_state > grabstate)
			grabstate = r_grab.grab_state
	if(l_grab && l_grab.grabbed == victim)
		if(grabstate == null || l_grab.grab_state > grabstate)
			grabstate = l_grab.grab_state
	return grabstate

/proc/do_thrust_animate(atom/movable/user, atom/movable/target, pixels = 4, time = 2.7)
	var/oldx = user.pixel_x
	var/oldy = user.pixel_y
	var/target_x = oldx
	var/target_y = oldy
	var/dir = get_dir(user, target)
	if(user.loc == target.loc)
		dir = user.dir
	switch(dir)
		if(NORTH)
			target_y += pixels
		if(SOUTH)
			target_y -= pixels
		if(WEST)
			target_x -= pixels
		if(EAST)
			target_x += pixels

	animate(user, pixel_x = target_x, pixel_y = target_y, time = time)
	animate(pixel_x = oldx, pixel_y = oldy, time = time)

	// and wretch after wretch....i fought....
	// but it still wasnt enough
	// their bells were still beyond me...
	// thirty five yils...
	// thirty five yils without a jinglejob...
	SEND_SIGNAL(user, COMSIG_SEX_JOSTLE, target)
	SEND_SIGNAL(target, COMSIG_SEX_JOSTLE, user)

/mob/living/proc/start_sex_session(mob/living/target, head_focus = FALSE)
	if(!target)
		return
	var/datum/sex_session/old_session = get_sex_session(src, target)
	if(old_session)
		if(old_session.head_focus != head_focus)
			old_session.head_focus = head_focus
		old_session.show_ui()
		return old_session

	var/datum/sex_session/session = new /datum/sex_session(src, target)
	session.head_focus = head_focus
	LAZYADD(GLOB.sex_sessions, session)
	session.show_ui()
	return session

/mob/living/carbon/human/proc/make_sucking_noise()
	if(gender == FEMALE)
		playsound(src, pick('sound/misc/mat/girlmouth (1).ogg','sound/misc/mat/girlmouth (2).ogg'), 25, TRUE, ignore_walls = FALSE)
	else
		playsound(src, pick('sound/misc/mat/guymouth (2).ogg','sound/misc/mat/guymouth (3).ogg','sound/misc/mat/guymouth (4).ogg','sound/misc/mat/guymouth (5).ogg'), 35, TRUE, ignore_walls = FALSE)

/mob/living/carbon/human/proc/try_impregnate(mob/living/carbon/human/wife)
	var/obj/item/organ/testicles/testes = getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testes)
		return
	if(!is_virile())
		return
	var/obj/item/organ/vagina/vag = wife.getorganslot(ORGAN_SLOT_VAGINA)
	if(vag)
		if(!wife.is_fertile())
			return
		var/prob_for_impreg = 25
		if(HAS_TRAIT(wife, TRAIT_BAOTHA_FERTILITY_BOON))
			prob_for_impreg = min(prob_for_impreg * 2, 100)
		if(prob(prob_for_impreg))
			vag.be_impregnated(src)
	else if(HAS_TRAIT(wife, TRAIT_BAOTHA_FERTILITY_BOON))
		if(prob(25))
			to_chat(wife, span_love("I feel a strange surge of warmth inside me..."))

/mob/living/proc/can_do_sex()
	return TRUE

/mob/living/carbon/human/MiddleMouseDrop_T(atom/movable/dragged, mob/living/user)
	var/mob/living/carbon/human/target = src
	var/mob/living/carbon/human/human_user = user

	if(!istype(human_user))
		return
	// Need to drag yourself to the target. While in Revenant vision the head IS the self:
	// a headless dullahan viewing through their head may drag it onto a body in its reach.
	var/dragging_self = (dragged == user)
	if(!dragging_self && istype(dragged, /obj/item/bodypart/head/dullahan))
		var/obj/item/bodypart/head/dullahan/dragged_head = dragged
		if(!dragged_head.owner && dragged_head.original_owner == user)
			var/obj/item/organ/dullahan_vision/vision = human_user.getorganslot(ORGAN_SLOT_HUD)
			if(vision?.viewing_head && dragged_head.Adjacent(target))
				dragging_self = TRUE
	if(!dragging_self)
		if(user.mmb_intent)
			return ..() // Not an ERP drag - let the selected MMB intent have the drop.
		return
	if(!human_user.can_do_sex())
		to_chat(user, "<span class='warning'>I can't do this.</span>")
		return
	var/may_bang = client && client.prefs && client.prefs.sexable == TRUE
	#ifdef LOCALTEST
		may_bang = TRUE
	#endif

	if(!may_bang) // Don't bang someone that doesn't want it.
		to_chat(user, "<span class='warning'>[src] doesn't wish to be touched. (Their ERP preference under options)</span>")
		to_chat(src, "<span class='warning'>[user] failed to touch you. (Your ERP preference under options)</span>")
		return

	if(!user.start_sex_session(target))
		to_chat(user, "<span class='warning'>I'm already sexing.</span>")
		return

/proc/get_sex_session(mob/giver, mob/taker)
	for(var/datum/sex_session/session as anything in GLOB.sex_sessions)
		if(session.user != giver)
			continue
		if(session.target != taker)
			continue
		return session
	return null

/mob/living/proc/has_hands()
	return TRUE

/mob/living/proc/has_mouth()
	return TRUE

/mob/living/proc/mouth_is_free()
	return !is_mouth_covered()

/mob/living/carbon/human/has_mouth()
	return get_bodypart(BODY_ZONE_HEAD) || reachable_detached_dullahan_head(src, src)	//a headless dullahan's held/nearby head is their mouth

/mob/living/carbon/human/has_hands() // technically should be an and but i'll replicate original behavior
	return get_bodypart(BODY_ZONE_L_ARM) || get_bodypart(BODY_ZONE_R_ARM)


/mob/living/proc/return_character_information()
	var/list/data = list()
	if(has_hands())
		data += "<div>...have hands.</div>"
	if(has_mouth())
		data += "<div>...have a mouth, which is [mouth_is_free() ? "uncovered" : "covered"].</div>"
	return data

/mob/living/proc/get_active_precise_hand()
	var/active_hand = BODY_ZONE_PRECISE_L_HAND
	if(active_hand_index != 1)
		active_hand = BODY_ZONE_PRECISE_R_HAND
	return active_hand

/mob/proc/check_handholding()
	return

/mob/living/carbon/human/check_handholding()
	if(pulledby && pulledby != src)
		var/obj/item/bodypart/LH
		var/obj/item/bodypart/RH
		LH = get_bodypart(BODY_ZONE_PRECISE_L_HAND)
		RH = get_bodypart(BODY_ZONE_PRECISE_R_HAND)
		if(LH || RH)
			for(var/obj/item/grabbing/G in src.grabbedby)
				if(G.limb_grabbed == LH || G.limb_grabbed == RH)
					return TRUE

/proc/return_sessions_with_user(mob/living/carbon/human/user)
	var/list/sessions = list()
	for(var/datum/sex_session/session in GLOB.sex_sessions)
		if(user != session.target && user != session.user)
			continue
		sessions |= session
	return sessions

/proc/return_highest_priority_action(list/sessions = list(), mob/living/carbon/human/user)
	var/datum/sex_session/highest_session
	for(var/datum/sex_session/session in sessions)
		if(!session.current_action)
			continue
		if(!highest_session)
			highest_session = session
			continue
		if(user == session.target)
			if(session.current_action.target_priority > highest_session.current_action.target_priority)
				highest_session = session
				continue
		if(user == session.user)
			if(session.current_action.user_priority > highest_session.current_action.user_priority)
				highest_session = session
				continue
	return highest_session
