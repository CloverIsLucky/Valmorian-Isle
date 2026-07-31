// Ogre gear ported from Emerald Summit.

// -------- ES code/modules/clothing/rogueclothes/armor.dm --------

/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ogre
	name = "giant hauberk"
	desc = "A gigantic chainmail shirt, absurd to even think it would fit someone of normal size."
	sleeved = 'icons/roguetown/clothing/onmob/helpers/32x64/ogre_onmob_sleeves.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/armor.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_maille"
	allowed_race = OGRE_RACE_TYPES

/obj/item/clothing/suit/roguetown/armor/plate/half/ogre
	name = "giant cuirass"
	desc = "An absurdly large piece of armor, meant for an absurdly large man."
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/armor.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_cuirass"
	max_integrity = 600 // wow these guys are super weak
	allowed_race = OGRE_RACE_TYPES

// -------- ES code/modules/clothing/rogueclothes/cloaks.dm --------

/obj/item/clothing/cloak/apron/ogre
	name = "giant apron"
	desc = "An apron of such grand size could take the brunt of a whole spilled soup pot and still leave the cook dry..."
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/cloaks.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "cookapron"
	allowed_race = OGRE_RACE_TYPES

// -------- ES code/modules/clothing/rogueclothes/feet.dm --------

/obj/item/clothing/shoes/roguetown/armor/ogre
	name = "giant plate boots"
	desc = "When giants march to war, they need two things above all else. Something to eat, and boots to stomp around."
	sleeved = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/feet.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_plateboots"
	allowed_race = OGRE_RACE_TYPES
	max_integrity = 250
	//armor = ARMOR_BOOTS_PLATED_IRON //VALMORIAN: ES-only, needs port — ES armor list define absent (VI uses ARMOR_PLATE-style defines)
	armor_class = ARMOR_CLASS_HEAVY
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/iron
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_TWIST)

/obj/item/clothing/shoes/roguetown/boots/ogre
	name = "oversized boots"
	desc = "The hardest working set of boots this side of the mountains."
	sleeved = 'icons/roguetown/clothing/onmob/helpers/32x64/ogre_onmob_sleeves.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/feet.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_boots"
	allowed_race = OGRE_RACE_TYPES
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST)	//Same as gloves
	max_integrity = 150
	//armor = ARMOR_BOOTS //VALMORIAN: ES-only, needs port — ES armor list define absent

// -------- ES code/modules/clothing/rogueclothes/gloves.dm --------

/obj/item/clothing/gloves/roguetown/plate/ogre
	name = "oversized gauntlets"
	desc = "Huge, iron gaunlets - the size of a human head."
	sleeved = 'icons/roguetown/clothing/onmob/helpers/32x64/ogre_onmob_sleeves.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/gloves.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogregrabbers"
	allowed_race = OGRE_RACE_TYPES
	//armor = ARMOR_GLOVES_PLATE //VALMORIAN: ES-only, needs port — ES armor list define absent
	prevent_crits = list(BCLASS_CHOP, BCLASS_CUT, BCLASS_BLUNT, BCLASS_TWIST)

/obj/item/clothing/gloves/roguetown/leather/ogre
	name = "oversized gloves"
	desc = "Huge, leather gloves - the size of a human head."
	sleeved = 'icons/roguetown/clothing/onmob/helpers/32x64/ogre_onmob_sleeves.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/gloves.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogreglove"
	allowed_race = OGRE_RACE_TYPES
	//armor = ARMOR_GLOVES_LEATHER_GOOD //VALMORIAN: ES-only, needs port — ES armor list define absent
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_BLUNT)

// -------- ES code/modules/clothing/rogueclothes/hats.dm --------

/obj/item/clothing/head/roguetown/cookhat/ogre
	name = "giant chef's hat"
	desc = "This is the badge of a true gourmand. None should ever look upon you with anything less than utter respect."
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/head.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "cookhat"
	item_state = "cookhat"
	allowed_race = OGRE_RACE_TYPES

/obj/item/clothing/head/roguetown/helmet/heavy/ogre
	name = "giant iron barbute"
	desc = "When you have a big head, it needs a big helmet. This one is modeled after old imperial armor designs."
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/head.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "merchelmet"
	item_state = "merchelmet"
	allowed_race = OGRE_RACE_TYPES
	flags_inv = HIDEEARS|HIDEHAIR

/obj/item/clothing/head/roguetown/helmet/heavy/graggar/ogre
	name = "graggar's champion helmet"
	desc = "The mark of graggar's rampage, this is the helmet of his greatest warrior, his favorite child. Kill in the name of the father, inflict pain and torment."
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/head.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "warlhelmet"
	item_state = "warlhelmet"
	allowed_race = OGRE_RACE_TYPES
	flags_inv = HIDEEARS|HIDEHAIR

// -------- ES code/modules/clothing/rogueclothes/neck.dm --------

/obj/item/clothing/neck/roguetown/gorget/ogre
	name = "giant gorget"
	desc = "For the hardest working neck in the province, since you know people are going to target it first."
	icon = 'icons/roguetown/clothing/ogre/neck.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_gorget"
	allowed_race = OGRE_RACE_TYPES
	max_integrity = 300

// -------- ES code/modules/clothing/rogueclothes/pants.dm --------

/obj/item/clothing/under/roguetown/tights/ogre
	name = "giant pants"
	desc = "These pants provide a vital service to society"
	sleeved = 'icons/roguetown/clothing/onmob/helpers/32x64/ogre_onmob_sleeves.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/pants.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_pants"
	allowed_race = OGRE_RACE_TYPES
	max_integrity = 250

/obj/item/clothing/under/roguetown/chainlegs/ogre
	name = "giant chain chausses"
	desc = "The amount of chainmail used for these could make a regular sized hauberk for a humble town guard."
	sleeved = 'icons/roguetown/clothing/onmob/helpers/32x64/ogre_onmob_sleeves.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/pants.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_chain"
	allowed_race = OGRE_RACE_TYPES

// -------- ES code/modules/clothing/rogueclothes/shirts.dm --------

/obj/item/clothing/suit/roguetown/shirt/ogre
	name = "giant shirt"
	desc = " The difference between you and a more uncivilized giant is, you got this fancy dyed cloth that means you're cultured and important."
	sleeved = 'icons/roguetown/clothing/onmob/helpers/32x64/ogre_onmob_sleeves.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/shirts.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_shirt"
	allowed_race = OGRE_RACE_TYPES
	max_integrity = 250

// -------- ES code/modules/clothing/rogueclothes/wrists.dm --------

/obj/item/clothing/wrists/roguetown/bracers/ogre
	name = "thick bracers"
	desc = "Normal humans can fit a leg through this hunk of steel."
	sleeved = 'icons/roguetown/clothing/onmob/helpers/32x64/ogre_onmob_sleeves.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/wrists.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_bracers"
	allowed_race = OGRE_RACE_TYPES

// -------- ES code/game/objects/items/rogueweapons/melee/axes.dm --------

/obj/item/rogueweapon/greataxe/steel/doublehead/graggar/ogre
	name = "executioner's folly"
	desc = "Attempts have been made to cut off an ogre's head. Those who try forget how easily they break their chains, and how thick their necks are."
	icon = 'icons/roguetown/weapons/ogre64.dmi'
	icon_state = "ogre_axe"
	force = 20
	force_wielded = 40
	max_blade_int = 200
	item_flags = GIANT_WEAPON

/obj/item/rogueweapon/greataxe/steel/doublehead/graggar/ogre/pickup(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_HORDE))
		to_chat(user, "<font color='red'>WEAK HANDS CANNOT HANDLE MY STRENGTH. BE PUNISHED.</font>")
		user.adjust_fire_stacks(5)
		user.ignite_mob()
		user.Stun(10)
	..()

// -------- ES code/game/objects/items/rogueweapons/melee/blunt.dm --------

/obj/item/rogueweapon/mace/cudgel/ogre
	name = "Head Knockah"
	desc = "A bell ringer that's been repurposed by a crafty set of hands, its size can only be wielded effectively by a giant."
	force = 25
	icon = 'icons/roguetown/weapons/ogre64.dmi' //VALMORIAN: ES 64.dmi copied whole - VI's own 64.dmi lacks the ogre states
	icon_state = "ogre_cudgel"
	minstr = 13
	item_flags = GIANT_WEAPON
	pixel_y = -16
	pixel_x = -16
	bigboy = TRUE

// -------- ES code/game/objects/items/rogueweapons/melee/knives.dm --------

/obj/item/rogueweapon/huntingknife/cleaver/ogre
	name = "Meat Choppah"
	desc = "Any good cook needs to prep their meat. Chop it, slice it, maybe even kill it before you do all that. Meant for the hands of a giant."
	icon = 'icons/roguetown/weapons/ogre64.dmi' //VALMORIAN: ES 64.dmi copied whole - VI's own 64.dmi lacks the ogre states
	icon_state = "ogre_cleaver"
	force = 25
	wdefense = 4
	minstr = 13
	item_flags = GIANT_WEAPON
	pixel_y = -16
	pixel_x = -16
	bigboy = TRUE

// -------- ES code/game/objects/items/rogueweapons/melee/polearms.dm --------

/obj/item/rogueweapon/greatsword/zwei/ogre
	name = "Better Sword"
	desc = "The mind of an ogre does not see trash in a field of discarded swords and corpses. He sees material to make a new weapon, with a light snack.."
	icon = 'icons/roguetown/weapons/ogre64.dmi'
	icon_state = "ogre_sword"
	minstr = 15 //have you seen the size of this thing??
	item_flags = GIANT_WEAPON
	smelt_bar_num = 2
	force = 20
	force_wielded = 35
	max_blade_int = 250
	max_integrity = 260

/obj/item/rogueweapon/mace/goden/steel/ogre
	name = "Mace of Malum"
	desc = "Sometimes an ogre comes across an abandoned blacksmith's forge, and finds an intact anvil. Few minds but an ogre's can think to use a tool of pure creation to beat people to paste."
	icon = 'icons/roguetown/weapons/ogre64.dmi'
	icon_state = "ogre_anvil"
	force = 20
	//VALMORIAN: ES declared force_wielded twice (40 then 35); DM keeps the last, so live ES ran 35
	possible_item_intents = list(/datum/intent/mace/strike/reach)
	gripped_intents = list(/datum/intent/mace/strike/reach, /*/datum/intent/mace/smash/reach,*/ /*VALMORIAN: ES-only, needs port — smash/reach intent absent*/ /datum/intent/effect/daze)
	smeltresult = /obj/item/ingot/steel
	smelt_bar_num = 2
	minstr = 15
	item_flags = GIANT_WEAPON
	force_wielded = 35
	max_integrity = 260

/obj/item/rogueweapon/mace/goden/steel/ogre/graggar
	name = "Ogre's Mace"
	desc = "Only a giant can effectively make use of this weapon. It has fed one at the expense of many lives."
	icon = 'icons/roguetown/weapons/ogre64.dmi'
	icon_state = "ogre_mace"
	force = 25
	//VALMORIAN: ES declared force_wielded twice (45 then 35); DM keeps the last, so live ES ran 35
	gripped_intents = list(/datum/intent/mace/strike/reach, /*/datum/intent/mace/smash/reach,*/ /*VALMORIAN: ES-only, needs port — smash/reach intent absent*/ /datum/intent/effect/daze)
	smelt_bar_num = 2
	minstr = 15
	item_flags = GIANT_WEAPON
	force_wielded = 35
	max_blade_int = 250
	max_integrity = 280

/obj/item/rogueweapon/mace/goden/steel/ogre/graggar/pickup(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_HORDE))
		to_chat(user, "<font color='red'>WEAK HANDS CANNOT TOUCH ME. PUNISHMENT FOR YOU!</font>")
		user.adjust_fire_stacks(5)
		user.ignite_mob()
		user.Stun(40)
	..()

// -------- ES code/game/objects/items/rogueitems/undies.dm --------

/obj/item/undies/ogre
	name = "big briefs"
	desc = "An absolute necessity."
	icon_state = "under"
	icon = 'icons/mob/sprite_accessory/big_underwear.dmi'

/obj/item/undies/bikini/ogre
	name = "big bikini"
	icon_state = "ogre_bra"
	icon = 'icons/mob/sprite_accessory/big_underwear.dmi'
	covers_breasts = TRUE

// -------- ES code/modules/clothing/rogueclothes/storage.dm (dependency: referenced by all ogre outfits) --------

/obj/item/storage/belt/rogue/leather/ogre
	name = "giant belt"
	desc = "When you have to tighten a belt of this size, best start keeping your tastiest allies close."
	sleeved = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x64/ogre_onmob.dmi'
	icon = 'icons/roguetown/clothing/ogre/belts.dmi' //VALMORIAN: ES clothing dmi copy - VI's shared dmis lack the ogre states
	icon_state = "ogre_belt"
