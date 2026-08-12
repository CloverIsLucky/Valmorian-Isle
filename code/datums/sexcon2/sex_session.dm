/// How long a session with no running action lingers before it is reaped. Sessions used to live
/// forever - nothing ever qdel'd one - which left stale partners on the panel and made
/// start_sex_session() hand back a dead session instead of opening a new one.
#define SEX_SESSION_IDLE_TIMEOUT (4 MINUTES)

/datum/sex_session //! TODO SEX SOUNDS
	/// The initiating user
	var/mob/living/carbon/human/user
	/// Target of our actions
	var/mob/living/carbon/human/target
	/// Whether the user desires to stop current action
	var/desire_stop = FALSE
	/// What is the current performed action
	var/datum/sex_action/current_action = null
	/// Enum of desired speed
	var/speed = SEX_SPEED_MID
	/// TRUE when this session was opened by dropping onto a detached dullahan head - the menu
	/// then only offers head-appropriate (mouth) actions, not the target's whole body.
	var/head_focus = FALSE
	/// Enum of desired force
	var/force = SEX_FORCE_MID
	/// Makes genital arousal automatic by default
	var/manual_arousal = SEX_MANUAL_AROUSAL_DEFAULT
	/// Whether we want to screw until finished, or non stop
	var/do_until_finished = TRUE
	///inactivity bumps
	var/inactivity = 0
	/// Timer id for the idle reap, so starting an action can cancel it.
	var/reap_timer
	/// Reference to the collective this session belongs to
	var/datum/collective_message/collective = null
	///have we just climaxed?
	var/just_climaxed = FALSE
	/// Whether to use knot when fucking (for knotted penis types)
	var/do_knot_action = FALSE

	var/static/sex_id = 0
	var/our_sex_id = 0 //this is so we can have more then 1 sex id open at once

	// Moved here from proc/get_generic_force_adjective to reduce list initialization/destruction
	var/static/list/low_force_adjectives 		= list("gently", "carefully", "tenderly", "gingerly", "delicately", "lazily")
	var/static/list/mid_force_adjectives 		= list("firmly", "vigorously", "eagerly", "steadily", "intently")
	var/static/list/high_force_adjectives 		= list("roughly", "carelessly", "forcefully", "fervently", "fiercely")
	var/static/list/extreme_force_adjectives 	= list("brutally", "violently", "relentlessly", "savagely", "mercilessly")
	var/static/list/ludicrous_force_adjectives 	= list("madly", "uncontrollably", "desperately", "deliriously", "freekishly")

/datum/sex_session/New(mob/living/carbon/human/session_user, mob/living/carbon/human/session_target)
	user = session_user
	target = session_target
	sex_id++
	our_sex_id = sex_id
	assign_to_collective()

	RegisterSignal(user, COMSIG_SEX_CLIMAX, PROC_REF(on_climax))
	RegisterSignal(user, COMSIG_SEX_AROUSAL_CHANGED, PROC_REF(on_arousal_changed), TRUE)

	// A session outlives neither participant, and doesn't outlive going idle.
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(on_participant_deleted))
	if(target && target != user)
		RegisterSignal(target, COMSIG_SEX_CLIMAX, PROC_REF(on_climax))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_participant_deleted))
	schedule_idle_reap()

/// Either the initiator or the target is being deleted, so the session can't continue.
/datum/sex_session/proc/on_participant_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// (Re)arms the idle reap. Firing while an action is running is harmless - stop_current_action()
/// arms it again once that action ends.
/datum/sex_session/proc/schedule_idle_reap()
	reap_timer = addtimer(CALLBACK(src, PROC_REF(reap_if_idle)), SEX_SESSION_IDLE_TIMEOUT, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/datum/sex_session/proc/reap_if_idle()
	if(current_action)
		return
	qdel(src)

/datum/sex_session/Destroy(force, ...)
	deltimer(reap_timer)
	if(user?.client)
		user << browse(null, "window=sexcon")
	UnregisterSignal(user, list(COMSIG_SEX_CLIMAX, COMSIG_SEX_AROUSAL_CHANGED, COMSIG_PARENT_QDELETING))
	if(target && target != user)
		UnregisterSignal(target, list(COMSIG_SEX_CLIMAX, COMSIG_PARENT_QDELETING))
	if(collective)
		collective.sessions -= src
		// If this was the last session in the collective, remove the collective
		if(!length(collective.sessions))
			LAZYREMOVE(GLOB.sex_collectives, collective)
			qdel(collective)

	GLOB.sex_sessions -= src
	. = ..()


/datum/sex_session/proc/assign_to_collective()
	// Check if we can merge with an existing collective
	for(var/datum/collective_message/existing_collective in GLOB.sex_collectives)
		if(existing_collective.can_merge_session(src))
			existing_collective.merge_session(src)
			return

	// No existing collective found, create a new one
	var/datum/collective_message/new_collective = new /datum/collective_message(src)
	LAZYADD(GLOB.sex_collectives, new_collective)
	collective = new_collective

/datum/sex_session/proc/on_arousal_changed()
	return

/datum/sex_session/proc/check_climax()
	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if(arousal_data["arousal"] < ACTIVE_EJAC_THRESHOLD)
		return FALSE
	return TRUE

/datum/sex_session/proc/try_start_action(action_type)
	if(action_type == current_action)
		try_stop_current_action()
		return
	if(current_action != null)
		try_stop_current_action()
		return
	if(!action_type)
		return
	if(!can_perform_action(action_type))
		return

	desire_stop = FALSE
	current_action = action_type
	inactivity = 0
	// Don't reap a session that's actively doing something.
	deltimer(reap_timer)
	var/datum/sex_action/action = SEX_ACTION(current_action)
	log_combat(user, target, "Started sex action: [action.name] with [target.name].")
	INVOKE_ASYNC(src, PROC_REF(sex_action_loop))

/datum/sex_session/proc/try_stop_current_action()
	if(!current_action)
		return
	desire_stop = TRUE

/datum/sex_session/proc/considered_limp(mob/limper)
	if(QDELETED(limper))
		return TRUE // If no limper or deleted, consider it limp
	var/list/arousal_data = list()
	SEND_SIGNAL(limper, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/arousal_value = arousal_data["arousal"]
	if(arousal_value >= AROUSAL_HARD_ON_THRESHOLD)
		return FALSE
	return TRUE

/datum/sex_session/proc/sex_action_loop()
	var/performed_action_type = current_action
	var/datum/sex_action/action = SEX_ACTION(current_action)
	var/base_speed = -1
	var/base_force = -1
	action.on_start(user, target)

	while(TRUE)
		#ifndef LOCALTEST
		// DO NOT allow NPC sex except on local, for testing
		if(isnull(target.client))
			break
		#endif

		var/stamina_cost = action.stamina_cost * get_stamina_cost_multiplier()
		if(!user.stamina_add(stamina_cost))
			break

		var/do_time = action.do_time / get_speed_multiplier()
		// When the severed head is the working part (mouth-gives), the progress dots belong
		// over it, not the distant body. Throat and other body-gives stay on the person.
		var/atom/progress_anchor
		if(action.works_via_own_detached_head)
			progress_anchor = get_detached_dullahan_head(user)
		if(!do_after(user, do_time, target = target, progress_anchor = progress_anchor))
			break

		if(current_action == null || performed_action_type != current_action)
			break
		if(!can_perform_action(current_action, TRUE))
			break
		if(action.is_finished(user, target))
			break
		if(desire_stop)
			break

		if (speed != base_speed || force != base_force)
			base_force = force
			base_speed = speed
			action.on_perform_message(user, target)

		action.on_perform(user, target)

		action.show_sex_effects(user)

		if(action.is_finished(user, target))
			break
		if(!action.continous)
			break

	stop_current_action()

/datum/sex_session/proc/stop_current_action()
	if(!current_action)
		return
	var/datum/sex_action/action = SEX_ACTION(current_action)
	action.on_finish(user, target)
	desire_stop = FALSE
	current_action = null
	schedule_idle_reap()
	show_ui()

/datum/sex_session/proc/can_perform_action(action_type, performing = FALSE)
	if(!action_type)
		return FALSE
	var/datum/sex_action/action = SEX_ACTION(action_type)
	if(!inherent_perform_check(action_type))
		return FALSE
	if(!action.can_perform(user, target) && !performing)
		return FALSE
	return TRUE

/datum/sex_session/proc/inherent_perform_check(action_type)
	var/datum/sex_action/action = SEX_ACTION(action_type)
	if(!target)
		return FALSE
	if(user.stat != CONSCIOUS)
		return FALSE
	// A dullahan whose head is in your hands is reachable even though their body isn't. The head
	// then stands in for the body's position, so the proximity and grab gates below are measured
	// against the head instead - the body could be a floor away and it wouldn't matter.
	// Only relevant when the body itself is out of reach - if you can touch them normally, nothing
	// here applies and the head is just a head.
	var/obj/item/bodypart/head/detached_head = user.Adjacent(target) ? null : reachable_detached_dullahan_head(target, user)
	if(detached_head && !action.works_on_detached_head)
		return FALSE // Everything but their mouth is somewhere else.
	// Mirror case: the user is a headless dullahan whose own head sits beside (or in the hands
	// of) the target - their mouth can give from there even though their body is far away.
	var/obj/item/bodypart/head/working_head
	if(!user.Adjacent(target) && !detached_head && user != target)
		working_head = reachable_detached_dullahan_head(user, target)
	if(working_head && !action.works_via_own_detached_head)
		return FALSE // Only their mouth made the trip.
	if(!user.Adjacent(target) && !action.ranged_action && !detached_head && !working_head)
		return FALSE
	if(action.check_incapacitated && user.incapacitated())
		return FALSE
	if(action.check_same_tile && !detached_head && !working_head)
		var/same_tile = (get_turf(user) == get_turf(target))
		var/grab_bypass = (action.aggro_grab_instead_same_tile && user.get_highest_grab_state_on(target) == GRAB_AGGRESSIVE)
		if(!same_tile && !grab_bypass)
			return FALSE
	if(action.require_grab && !detached_head && !working_head)
		var/grabstate = user.get_highest_grab_state_on(target)
		if(grabstate == null || grabstate < action.required_grab_state)
			return FALSE
	return TRUE

/datum/sex_session/proc/perform_sex_action(mob/living/carbon/human/action_target, arousal_amt, pain_amt, giving)
	SEND_SIGNAL(action_target, COMSIG_SEX_RECEIVE_ACTION, arousal_amt, pain_amt, giving, force, speed)

/datum/sex_session/proc/handle_passive_ejaculation(mob/living/carbon/human/handler)
	if(!handler)
		handler = user
	var/list/arousal_data = list()
	SEND_SIGNAL(handler, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/arousal_multiplier = arousal_data["arousal_multiplier"]
	var/arousal_value = arousal_data["arousal"]

	if(arousal_multiplier > 1.5 && user.check_handholding())
		if(prob(5))
			SEND_SIGNAL(handler, COMSIG_SEX_RECEIVE_ACTION, 3, 0, 1, 0)
		if(arousal_value < 70)
			SEND_SIGNAL(handler, COMSIG_SEX_ADJUST_AROUSAL, 0.2)

		if(handler.handcuffed)
			if(prob(8))
				var/chaffepain = pick(10,10,10,10,20,20,30)
				SEND_SIGNAL(handler, COMSIG_SEX_RECEIVE_ACTION, 3, chaffepain, 1, 0)
				handler.visible_message(("<span class='love_mid'>[handler] squirms uncomfortably in [handler.p_their()] restraints.</span>"), \
					("<span class='love_extreme'>I feel [handler.handcuffed] rub uncomfortably against my skin.</span>"))
			if(arousal_value < ACTIVE_EJAC_THRESHOLD)
				SEND_SIGNAL(handler, COMSIG_SEX_ADJUST_AROUSAL, 0.25)


/datum/sex_session/proc/get_speed_multiplier()
	switch(speed)
		if(SEX_SPEED_LOW)
			return 1.0
		if(SEX_SPEED_MID)
			return 1.5
		if(SEX_SPEED_HIGH)
			return 2.0
		if(SEX_SPEED_EXTREME)
			return 2.5
		if(SEX_SPEED_LUDICROUS)
			return 3

/datum/sex_session/proc/get_stamina_cost_multiplier()
	switch(force)
		if(SEX_FORCE_LOW)
			return 1.0
		if(SEX_FORCE_MID)
			return 1.5
		if(SEX_FORCE_HIGH)
			return 2.0
		if(SEX_FORCE_EXTREME)
			return 2.5
		if(SEX_FORCE_LUDICROUS)
			return 2.5

///The fifth (FURIOUS/FERAL) tier is reserved for the Bed Breaker trait (ogres) and the Fallen -
///everyone else caps one below. ES also granted it to emberwine drinkers; that status effect
///is not ported here.
/datum/sex_session/proc/get_setting_cap()
	if(HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || HAS_TRAIT(user, TRAIT_DEPRAVED))
		return SEX_SPEED_MAX
	return SEX_SPEED_MAX - 1

/datum/sex_session/proc/adjust_speed(amt)
	speed = clamp(speed + amt, SEX_SPEED_MIN, get_setting_cap())

/datum/sex_session/proc/adjust_force(amt)
	force = clamp(force + amt, SEX_FORCE_MIN, get_setting_cap())

/datum/sex_session/proc/finished_check()
	if(!do_until_finished)
		return FALSE
	if(just_climaxed)
		just_climaxed = FALSE
		return TRUE
	return FALSE

/datum/sex_session/proc/on_climax(mob/source)
	if(!do_until_finished)
		return
	just_climaxed = TRUE


/datum/sex_session/proc/get_force_string()
	switch(force)
		if(SEX_FORCE_LOW)
			return "<font color='#eac8de'>GENTLE</font>"
		if(SEX_FORCE_MID)
			return "<font color='#e9a8d1'>FIRM</font>"
		if(SEX_FORCE_HIGH)
			return "<font color='#f05ee1'>ROUGH</font>"
		if(SEX_FORCE_EXTREME)
			return "<font color='#d146f5'>BRUTAL</font>"
		if(SEX_FORCE_LUDICROUS)
			return "<font color='#d61a43'>FERAL</font>"

/datum/sex_session/proc/get_speed_string()
	switch(speed)
		if(SEX_SPEED_LOW)
			return "<font color='#eac8de'>SLOW</font>"
		if(SEX_SPEED_MID)
			return "<font color='#e9a8d1'>STEADY</font>"
		if(SEX_SPEED_HIGH)
			return "<font color='#f05ee1'>QUICK</font>"
		if(SEX_SPEED_EXTREME)
			return "<font color='#d146f5'>UNRELENTING</font>"
		if(SEX_SPEED_LUDICROUS)
			return "<font color='#d61a43'>FURIOUS</font>"

/datum/sex_session/proc/get_manual_arousal_string()
	switch(manual_arousal)
		if(SEX_MANUAL_AROUSAL_DEFAULT)
			return "<font color='#eac8de'>NATURAL</font>"
		if(SEX_MANUAL_AROUSAL_UNAROUSED)
			return "<font color='#e9a8d1'>UNAROUSED</font>"
		if(SEX_MANUAL_AROUSAL_PARTIAL)
			return "<font color='#f05ee1'>PARTIALLY ERECT</font>"
		if(SEX_MANUAL_AROUSAL_FULL)
			return "<font color='#d146f5'>FULLY ERECT</font>"

/datum/sex_session/proc/get_generic_force_adjective()
	switch(force)
		if(SEX_FORCE_LOW)
			return pick(low_force_adjectives)
		if(SEX_FORCE_MID)
			return pick(mid_force_adjectives)
		if(SEX_FORCE_HIGH)
			return pick(high_force_adjectives)
		if(SEX_FORCE_EXTREME)
			return pick(extreme_force_adjectives)
		if(SEX_FORCE_LUDICROUS)
			return pick(ludicrous_force_adjectives)

/datum/sex_session/proc/spanify_force(string)
	switch(force)
		if(SEX_FORCE_LOW)
			return "<span class='love_low'>[string]</span>"
		if(SEX_FORCE_MID)
			return "<span class='love_mid'>[string]</span>"
		if(SEX_FORCE_HIGH)
			return "<span class='love_high'>[string]</span>"
		if(SEX_FORCE_EXTREME)
			return "<span class='love_extreme'>[string]</span>"
		if(SEX_FORCE_LUDICROUS)
			return "<span class='love_ludicrous'>[string]</span>"

/datum/sex_session/proc/get_force_sound()
	switch(force)
		if(SEX_FORCE_LOW, SEX_FORCE_MID)
			return pick(SEX_SOUNDS_SLOW)
		if(SEX_FORCE_HIGH, SEX_FORCE_EXTREME, SEX_FORCE_LUDICROUS)
			return pick(SEX_SOUNDS_HARD)

/datum/sex_session/proc/show_ui()
	var/list/dat = list()
	var/force_name = get_force_string()
	var/speed_name = get_speed_string()
	var/obj/item/organ/penis/got_cock = user.getorganslot(ORGAN_SLOT_PENIS)

	dat += "<center><a href='?src=[REF(src)];task=speed_down'>\<</a> [speed_name] <a href='?src=[REF(src)];task=speed_up'>\></a>"
	dat += " ~|~ <a href='?src=[REF(src)];task=force_down'>\<</a> [force_name] <a href='?src=[REF(src)];task=force_up'>\></a>"
	if(got_cock)
		var/manual_arousal_name = get_manual_arousal_string()
		dat += " ~|~ <a href='?src=[REF(src)];task=manual_arousal_down'>\<</a> [manual_arousal_name] <a href='?src=[REF(src)];task=manual_arousal_up'>\></a>"
	dat += "</center>"

	dat += "<center><a href='?src=[REF(src)];task=toggle_finished'>[do_until_finished ? "UNTIL IM FINISHED" : "UNTIL I STOP"]</a>"

	if(current_action && !desire_stop)
		var/datum/sex_action/action = SEX_ACTION(current_action)
		if(action.knot_on_finish)
			if(got_cock)
				switch(got_cock.penis_type)
					if(PENIS_TYPE_KNOTTED, PENIS_TYPE_TAPERED_DOUBLE_KNOTTED, PENIS_TYPE_BARBED_KNOTTED)
						if(do_knot_action)
							dat += " | <a href='?src=[REF(src)];task=toggle_knot'><font color='#d146f5'>USING KNOT</font></a>"
						else
							dat += " | <a href='?src=[REF(src)];task=toggle_knot'><font color='#eac8de'>NOT USING KNOT</font></a>"
	dat += "</center>"

	dat += "<center><a href='?src=[REF(src)];task=set_arousal'>SET AROUSAL</a> | <a href='?src=[REF(src)];task=freeze_arousal'>[get_arousal_frozen() ? "UNFREEZE AROUSAL" : "FREEZE AROUSAL"]</a></center>"

	if(target == user)
		dat += "<center>Doing unto yourself[head_focus ? "'s head" : ""]</center>"
	else
		dat += "<center>Doing unto [target][head_focus ? "'s head" : ""]</center>"

	if(current_action && !desire_stop)
		dat += "<center><a href='?src=[REF(src)];task=stop'>Stop</a></center>"
	else
		dat += "<br>"

	dat += "<table width='100%'><td width='50%'></td><td width='50%'></td><tr>"
	var/i = 0
	for(var/action_type in GLOB.sex_actions)
		var/datum/sex_action/action = SEX_ACTION(action_type)
		if(head_focus && !action.works_on_detached_head)
			continue
		if(!action.shows_on_menu(user, target))
			continue
		dat += "<td>"
		var/link = ""
		if(!can_perform_action(action_type))
			link = "linkOff"
		if(current_action == action_type)
			link = "linkOn"
		dat += "<center><a class='[link]' href='?src=[REF(src)];task=action;action_type=[action_type]'>[action.name]</a></center>"
		dat += "</td>"
		i++
		if(i >= 2)
			i = 0
			dat += "</tr><tr>"
	dat += "</tr></table>"

	var/datum/browser/popup = new(user, "sexcon", "<center>Sate Desire</center>", 500, 550)
	popup.set_content(dat.Join())
	popup.open()

/datum/sex_session/proc/get_arousal_frozen()
	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)
	return arousal_data["frozen"] || FALSE

/datum/sex_session/Topic(href, href_list)
	if(usr != user)
		return
	switch(href_list["task"])
		if("action")
			var/action_path = text2path(href_list["action_type"])
			if(!action_path)
				return
			try_start_action(action_path)
		if("stop")
			try_stop_current_action()
		if("speed_up")
			adjust_speed(1)
		if("speed_down")
			adjust_speed(-1)
		if("force_up")
			adjust_force(1)
		if("force_down")
			adjust_force(-1)
		if("manual_arousal_up")
			manual_arousal = clamp(manual_arousal + 1, SEX_MANUAL_AROUSAL_MIN, SEX_MANUAL_AROUSAL_MAX)
		if("manual_arousal_down")
			manual_arousal = clamp(manual_arousal - 1, SEX_MANUAL_AROUSAL_MIN, SEX_MANUAL_AROUSAL_MAX)
		if("toggle_finished")
			do_until_finished = !do_until_finished
		if("toggle_knot")
			do_knot_action = !do_knot_action
		if("set_arousal")
			var/amount = input(user, "Value above 120 will immediately cause orgasm!", "Set Arousal") as null|num
			if(!isnull(amount))
				SEND_SIGNAL(user, COMSIG_SEX_SET_AROUSAL, amount)
				user.apply_status_effect(/datum/status_effect/debuff/no_coom_cheating)
		if("freeze_arousal")
			SEND_SIGNAL(user, COMSIG_SEX_FREEZE_AROUSAL)
	show_ui()

/datum/sex_session/proc/get_current_speed()
	return speed || SEX_SPEED_LOW

/datum/sex_session/proc/get_current_force()
	return force || SEX_FORCE_LOW

#undef SEX_SESSION_IDLE_TIMEOUT
