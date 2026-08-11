// Scarlet Reach has no loot subtree at all - its NPCs only ever idle. We keep ours, because the
// consumable subtrees (use_bandage / use_powder / use_healing_drink / use_throwable) are useless if
// nothing ever stocks them, but it is scoped so that scavenging is opportunistic rather than the
// NPC's whole personality. Before this, looting was literally the only thing a human NPC did with
// an empty plan, so they crossed rooms for any bottle in sight, forever.
/datum/ai_planning_subtree/loot
	/// Deliberately short. This is "pick up what's underfoot", not "go shopping" - a wider radius
	/// is what produced the NPCs marching across the map after a bottle they had no use for.
	var/scan_range = 3
	/// Minimum time between world scans. Loot isn't time-sensitive, so we skip most ticks.
	var/scan_cooldown = 4 SECONDS
	/// How many of one item class an NPC will carry before it stops wanting more.
	var/carry_limit = 2

/datum/ai_planning_subtree/loot/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	if(controller.blackboard[BB_BASIC_MOB_FLEEING])
		return

	var/next_scan = controller.blackboard[BB_LOOT_NEXT_SCAN]
	if(next_scan && world.time < next_scan)
		return

	var/mob/living/pawn = controller.pawn
	var/datum/component/ai_inventory_manager/inv = controller.get_inventory()
	if(!inv)
		return
	if(!inv.has_any_space())
		controller.set_blackboard_key(BB_LOOT_NEXT_SCAN, world.time + scan_cooldown * 3)
		return

	controller.set_blackboard_key(BB_LOOT_NEXT_SCAN, world.time + scan_cooldown)

	var/list/blacklist = controller.blackboard[BB_LOOT_BLACKLIST]

	for(var/obj/item/candidate in view(scan_range, pawn))
		if(!isturf(candidate.loc))
			continue
		if(_is_blacklisted(blacklist, candidate))
			continue
		if(!_item_is_wanted(inv, pawn, candidate))
			continue
		controller.set_blackboard_key(BB_LOOT_TARGET, candidate)
		controller.queue_behavior(/datum/ai_behavior/loot_pick_up, BB_LOOT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/loot/proc/_is_blacklisted(list/blacklist, obj/item/candidate)
	if(!blacklist)
		return FALSE
	if(candidate in blacklist)
		return TRUE
	return FALSE

/datum/ai_planning_subtree/loot/proc/_item_is_wanted(datum/component/ai_inventory_manager/inv, mob/living/pawn, obj/item/candidate)
	if(!candidate.flags_ai_inventory)
		return FALSE
	if(istype(candidate, /obj/item/gun))
		return FALSE
	if(istype(candidate, /obj/item/rogueweapon))
		return FALSE
	if(candidate.anchored)
		return FALSE
	if(HAS_TRAIT(candidate, TRAIT_NODROP))
		return FALSE
	return _has_room_for(inv, candidate)

/// TRUE if we're still short in any class this item counts as. An NPC already carrying two healing
/// draughts has no business walking to a third.
/datum/ai_planning_subtree/loot/proc/_has_room_for(datum/component/ai_inventory_manager/inv, obj/item/candidate)
	for(var/ai_flag in inv.inventory_map)
		if(!(candidate.flags_ai_inventory & ai_flag))
			continue
		if(length(inv.inventory_map[ai_flag]) < carry_limit)
			return TRUE
	return FALSE


/datum/ai_behavior/loot_pick_up
	action_cooldown = 0.5 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	var/loot_delay = 2 SECONDS

/datum/ai_behavior/loot_pick_up/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isturf(target.loc))
		return FALSE
	set_movement_target(controller, target)
	return TRUE

/datum/ai_behavior/loot_pick_up/perform(delta_time, datum/ai_controller/controller, target_key)
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isturf(target.loc))
		finish_action(controller, FALSE, target_key)
		return

	var/mob/living/carbon/human/pawn = controller.pawn
	if(!pawn.Adjacent(target))
		finish_action(controller, FALSE, target_key)
		return

	var/datum/component/ai_inventory_manager/inv = controller.get_inventory()
	if(!inv)
		finish_action(controller, FALSE, target_key)
		return

	if(QDELETED(target) || !isturf(target.loc))
		finish_action(controller, FALSE, target_key)
		return

	var/slot_flag = inv.find_space_for(target)
	if(!slot_flag)
		pawn.visible_message(span_notice("[pawn] looks at [target] but has no room for it."))
		controller.add_blackboard_key_lazylist(BB_LOOT_BLACKLIST, target)
		// Prune it after 5 minutes so the list doesn't grow forever
		addtimer(CALLBACK(controller, TYPE_PROC_REF(/datum/ai_controller, remove_thing_from_blackboard_key), BB_LOOT_BLACKLIST, target), 5 MINUTES)
		finish_action(controller, FALSE, target_key)
		return

	var/obj/item/container = inv.container_refs[slot_flag]
	var/datum/component/storage/STR = container?.GetComponent(/datum/component/storage)
	if(!STR)
		finish_action(controller, FALSE, target_key)
		return

	STR.handle_item_insertion(target, prevent_warning = TRUE, user = pawn)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/loot_pick_up/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
