// WOE: SPELLBLADE DODGE EXPERT POLEARM BUILD UPON YE.
/datum/advclass/wretch/blackoakstalker
	name = "Black Oaken Stalker"
	tutorial = "A highly experienced member of the Black Oaks, a shadowy paramilitary group from Amerland, you are here not to earn money and bring it home like the rest of your kind, \
	but to hunt down and punish political refugees and dissenters from Amerland who hoped to escape retribution in a foreign land. \
	Furthermore, you ensure that your fellow Black Oaks don't stray from their path and don't collaborate with traitors and rebels."
	allowed_sexes = list(MALE, FEMALE)
	forbidden_races = list(RACES_BLACKOAK_SUPREME)
	outfit = /datum/outfit/job/roguetown/wretch/blackoakstalker
	cmode_music = 'sound/music/combat_blackoak.ogg'
	maximum_possible_slots = 1
	class_select_category = CLASS_CAT_RACIAL
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_AZURENATIVE, TRAIT_OUTDOORSMAN, TRAIT_BLACKOAK, TRAIT_DODGEEXPERT, TRAIT_ARCYNE, TRAIT_WOODWALKER, TRAIT_EXPERT_HUNTER)
	//lower-than-avg stats for wretch but their traits are insanely good
	subclass_stats = list(
		STATKEY_INT = 1,
		STATKEY_PER = 2,
		STATKEY_SPD = 2,
		STATKEY_WIL = 2,
		STATKEY_CON = 1
	) //This was +7 weighted total but we are giving them +9 weighted total like the rest of Wretches because LITERALLY ONE SLOT.
	subclass_mage_aspects = list("mastery" = FALSE, "major" = 0, "minor" = 0, "utilities" = 4)
	subclass_languages = list(/datum/language/elvish)
	subclass_skills = list(
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT, //Why the fuck did the treeclimber role have worse skills than THE KNIGHTS?
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/tanning = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/farming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/hunting = SKILL_LEVEL_NOVICE,
	)
	subclass_stashed_items = list(
        "Sewing Kit" =  /obj/item/repair_kit,
    )
	extra_context = "This class is restricted to the Elf and Dark Elf species."


/datum/outfit/job/roguetown/wretch/blackoakstalker
	var/subclass_selected

/datum/outfit/job/roguetown/wretch/blackoakstalker/Topic(href, href_list)
	. = ..()
	if(href_list["subclass"])
		subclass_selected = href_list["subclass"]
	else if(href_list["close"])
		if(!subclass_selected)
			subclass_selected = "blade"

/datum/outfit/job/roguetown/wretch/blackoakstalker/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/trophyfur
	shoes = /obj/item/clothing/shoes/roguetown/boots/elven_boots
	cloak = /obj/item/clothing/cloak/forrestercloak
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	gloves = /obj/item/clothing/gloves/roguetown/elven_gloves
	belt = /obj/item/storage/belt/rogue/leather/black
	backl = /obj/item/storage/backpack/rogue/satchel
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	pants = /obj/item/clothing/under/roguetown/trou/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	beltl = /obj/item/rogueweapon/huntingknife/idagger/steel/special
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/chalk = 1,
		)

	to_chat(H, span_warning("You start with Bind Weapon. Remember to Bind your weapon so you can use your abilities and build up Arcyne Momentum."))

	subclass_selected = null
	var/selection_html = get_spellblade_chant_html(src, H, "blackoak")
	H << browse(selection_html, "window=spellblade_chant;size=1100x900")
	onclose(H, "spellblade_chant", src)

	var/open_time = world.time
	while(!subclass_selected && world.time - open_time < 5 MINUTES)
		stoplag(1)
	H << browse(null, "window=spellblade_chant")

	if(!subclass_selected)
		subclass_selected = "blade"

	var/datum/status_effect/buff/arcyne_momentum/momentum = H.apply_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(momentum)
		momentum.chant = subclass_selected

	if(H.mind)
		switch(subclass_selected)
			if("blade")
				H.mind.AddSpell(new /datum/action/cooldown/spell/caedo)
				H.mind.AddSpell(new /datum/action/cooldown/spell/air_strike)
				H.mind.AddSpell(new /datum/action/cooldown/spell/leyline_anchor)
				H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/blade_storm)
			if("phalangite")
				H.mind.AddSpell(new /datum/action/cooldown/spell/valmorian_phalanx)
				H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/valmorian_pilum)
				H.mind.AddSpell(new /datum/action/cooldown/spell/advance)
				H.mind.AddSpell(new /datum/action/cooldown/spell/gate_of_reckoning)
			if("macebearer")
				H.mind.AddSpell(new /datum/action/cooldown/spell/telegraphed_strike/spellblade/shatter)
				H.mind.AddSpell(new /datum/action/cooldown/spell/telegraphed_strike/spellblade/tremor)
				H.mind.AddSpell(new /datum/action/cooldown/spell/charge)
				H.mind.AddSpell(new /datum/action/cooldown/spell/cataclysm)

		H.mind.AddSpell(new /datum/action/cooldown/spell/recall_weapon)
		H.mind.AddSpell(new /datum/action/cooldown/spell/empower_weapon)
		H.mind.AddSpell(new /datum/action/cooldown/spell/bind_weapon)
		H.mind.AddSpell(new /datum/action/cooldown/spell/mending)

	switch(subclass_selected)
		if("blade")
			var/weapons = list("Elvish Longsword", "Elvish Saber", "Elvish Curveblade", "Steel Dagger")
			var/weapon_choice = input(H, "Choose your WEAPON.", "FOR THE OAKS AND THE PEAKS.") as anything in weapons
			switch(weapon_choice)
				if("Elvish Longsword")
					r_hand = /obj/item/rogueweapon/sword/long/elvish
					beltr = /obj/item/rogueweapon/scabbard/sword
					backr = /obj/item/rogueweapon/shield/wood
				if("Elvish Saber")
					r_hand = /obj/item/rogueweapon/sword/sabre/elf
					beltr = /obj/item/rogueweapon/scabbard/sword
					backr = /obj/item/rogueweapon/shield/wood
				if("Elvish Curveblade")
					r_hand = /obj/item/rogueweapon/greatsword/elvish
					backr = /obj/item/rogueweapon/scabbard/gwstrap
				if("Steel Dagger")
					beltr = /obj/item/rogueweapon/huntingknife/idagger/steel
					backr = /obj/item/rogueweapon/shield/wood
			if(weapon_choice == "Steel Dagger")
				H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_EXPERT, TRUE)
			else
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
		if("phalangite")
			r_hand = /obj/item/rogueweapon/halberd/glaive/elvish
			backr = /obj/item/rogueweapon/scabbard/gwstrap
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_EXPERT, TRUE)
		if("macebearer")
			backr = /obj/item/rogueweapon/shield/wood
			var/mace_weapons = list("Steel Mace", "Steel Warhammer", "Grand Mace", "Battle Axe", "Steel Greataxe")
			var/mace_choice = input(H, "Choose your WEAPON.", "FOR THE OAKS AND THE PEAKS.") as anything in mace_weapons
			var/picked_axe = FALSE
			switch(mace_choice)
				if("Steel Mace")
					r_hand = /obj/item/rogueweapon/mace/steel
				if("Steel Warhammer")
					r_hand = /obj/item/rogueweapon/mace/warhammer/steel
				if("Grand Mace")
					r_hand = /obj/item/rogueweapon/mace/goden/steel
					backr = /obj/item/rogueweapon/scabbard/gwstrap
				if("Battle Axe")
					r_hand = /obj/item/rogueweapon/stoneaxe/battle
					picked_axe = TRUE
				if("Steel Greataxe")
					r_hand = /obj/item/rogueweapon/greataxe/steel
					backr = /obj/item/rogueweapon/scabbard/gwstrap
					picked_axe = TRUE
			if(picked_axe)
				H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_EXPERT, TRUE)
			else
				H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_EXPERT, TRUE)

	var/helmets = list("Woad Elven Barbute", "Elven Barbute", "Winged Elven Barbute")
	var/helmet_choice = input(H, "Choose your HELMET.", "LEAVES OVER STEEL.") as anything in helmets
	switch(helmet_choice)
		if("Woad Elven Barbute")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/elven_helm/light, SLOT_HEAD, TRUE)
		if("Elven Barbute")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/elvenbarbute/blackoak, SLOT_HEAD, TRUE)
		if("Winged Elven Barbute")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/elvenbarbute/winged/blackoak, SLOT_HEAD, TRUE)

	wretch_select_bounty(H)
