/datum/advclass/templar/tempest
	name = "Tempest"
	tutorial = "You are a templar of the Church, trained in ranged combat to bring a Tempest of holy wrath upon your enemies."
	outfit = /datum/outfit/job/templar/tempest
	category_tags = list(CTAG_TEMPLAR)
	cmode_music = 'sound/music/combat_holy.ogg'

	subclass_languages = list(/datum/language/grenzelhoftian)
	traits_applied = list(TRAIT_MEDIUMARMOR)
	subclass_stats = list(
		STATKEY_SPD = 3,// +1 spd so they can use their missing DE a little better
		STATKEY_PER = 2,
		STATKEY_END = 1,
	)

	subclass_skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/bows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/holy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
	)

	subclass_stashed_items = list(
		"The Verses and Acts of the Ten" = /obj/item/book/rogue/bibble,
	)
	extra_context = "This subclass gains Expert skill in their weapon of choice."

/datum/outfit/job/templar/tempest/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/heavy/holysee
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	cloak = /obj/item/clothing/cloak/tabard/crusader/tief
	armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/fluted/holysee
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/holysee
	wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
	gloves = /obj/item/clothing/gloves/roguetown/chain
	belt = /obj/item/storage/belt/rogue/leather/black
	pants = /obj/item/clothing/under/roguetown/chainlegs
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	backr = /obj/item/storage/backpack/rogue/satchel
	id = /obj/item/clothing/ring/silver
	backpack_contents = list(
		/obj/item/ritechalk = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/storage/keyring/acolyte = 1
		)
	H.cmode_music = 'sound/music/cmode/church/combat_reckoning.ogg' // this is probably awful implementation. too bad!
	switch(H.patron?.type)
		if(/datum/patron/divine/undivided)
			wrists = /obj/item/clothing/neck/roguetown/psicross/undivided
			if(H.mind)
				var/cloaks = list("Cloak", "Tabard")
				var/cloakchoice = input(H,"Choose your covering", "TAKE UP FASHION") as anything in cloaks
				switch(cloakchoice)
					if("Cloak")
						cloak = /obj/item/clothing/cloak/undivided
					if("Tabard")
						cloak = /obj/item/clothing/cloak/templar/undivided_alt
				var/helms = list("Sallet", "Barbute")
				var/helmchoice = input(H, "Choose your headwear", "TAKE UP NOGGIN PROTECTION") as anything in helms
				switch(helmchoice)
					if("Sallet")
						head = /obj/item/clothing/head/roguetown/helmet/heavy/undivided
					if("Barbute")
						head = /obj/item/clothing/head/roguetown/helmet/heavy/holyseebarbute
		if(/datum/patron/divine/astrata)
			wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
			head = /obj/item/clothing/head/roguetown/helmet/heavy/astratan
			cloak = /obj/item/clothing/cloak/templar/astratan
		if(/datum/patron/divine/abyssor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/abyssor
			head = /obj/item/clothing/head/roguetown/helmet/heavy/abyssorgreathelm
			cloak = /obj/item/clothing/cloak/tabard/abyssorite
		if(/datum/patron/divine/xylix)
			cloak = /obj/item/clothing/cloak/templar/xylixian
			head = /obj/item/clothing/head/roguetown/helmet/heavy/xylixhelm
			H.cmode_music = 'sound/music/combat_jester.ogg'
		if(/datum/patron/divine/dendor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/dendor
			head = /obj/item/clothing/head/roguetown/helmet/heavy/dendorhelm
			cloak = /obj/item/clothing/cloak/tabard/crusader/dendor
			H.cmode_music = 'sound/music/cmode/garrison/combat_warden.ogg'
		if(/datum/patron/divine/necra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/necra
			head = /obj/item/clothing/head/roguetown/helmet/heavy/necran
			cloak = /obj/item/clothing/cloak/templar/necran
		if(/datum/patron/divine/pestra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/pestra
			head = /obj/item/clothing/head/roguetown/helmet/heavy/pestran
			cloak = /obj/item/clothing/cloak/templar/pestran
		if(/datum/patron/divine/eora) //Eora content from stonekeep
			wrists = /obj/item/clothing/neck/roguetown/psicross/eora
			head = /obj/item/clothing/head/roguetown/helmet/heavy/eoran
			cloak = /obj/item/clothing/cloak/templar/eoran
		if(/datum/patron/divine/noc)
			wrists = /obj/item/clothing/neck/roguetown/psicross/noc
			head = /obj/item/clothing/head/roguetown/helmet/heavy/nochelm
			cloak = /obj/item/clothing/cloak/tabard/devotee/noc
		if(/datum/patron/divine/ravox)
			wrists = /obj/item/clothing/neck/roguetown/psicross/ravox
			head = /obj/item/clothing/head/roguetown/helmet/heavy/ravoxhelm
			cloak = /obj/item/clothing/cloak/templar/ravox
			mask = /obj/item/clothing/head/roguetown/roguehood/ravoxgorget
		if(/datum/patron/divine/malum)
			wrists = /obj/item/clothing/neck/roguetown/psicross/malum
			cloak = /obj/item/clothing/cloak/templar/malumite
			head = /obj/item/clothing/head/roguetown/helmet/heavy/malum
		if(/datum/patron/old_god)
			wrists = /obj/item/clothing/neck/roguetown/psicross
			cloak = /obj/item/clothing/cloak/tabard/crusader/psydon
	// Patron dagger in satchel
	var/patron_dagger = get_templar_patron_dagger(H)
	if(patron_dagger)
		backpack_contents += patron_dagger

	H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/knight]
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_2)	//Capped to T2 miracles.
	if(H.mind)
		SStreasury.grant_savings(ECONOMIC_LOWER_MIDDLE_CLASS, H)

/datum/outfit/job/roguetown/templar/tempest/choose_loadout(mob/living/carbon/human/H)
	. = ..()
	var/weapons = list("Bow", "Crossbow")
	switch(H.patron?.type)
		if(/datum/patron/divine/eora)
			weapons += list("Harp Bow (long)", "Harp Bow (short)")
	var/weapon_choice = input(H,"Choose your WEAPON.", "TAKE UP YOUR GOD'S ARMS") as anything in weapons
	switch(weapon_choice)
		if("Crossbow")
			beltr = /obj/item/quiver/bolt/standard
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
		if("Bow")
			beltr = /obj/item/quiver/arrows
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
		if("Harp Bow (long)")
			beltr = /obj/item/quiver/arrows
			r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow/eora
		if("Harp Bow (short)")
			beltr = /obj/item/quiver/arrows
			r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve/eora
