/datum/virtue/size/giant
	name = "Giant"
	desc = "I've always been larger, stronger and hardier than the average person. I tend to lumber around a lot, and my immense size can break down frail, wooden doors."
	added_traits = list(TRAIT_BIGGUY)
	added_stats = list(STATKEY_CON = 1)
	custom_text = "Increases your sprite size. Grants +1 CON."

/datum/virtue/size/giant/apply_to_human(mob/living/carbon/human/recipient)
	if(recipient.dna?.species?.fixed_body_size) //species with sprite-baked size don't get the scale transform
		return
	recipient.transform = recipient.transform.Scale(1.25, 1.25)
	recipient.transform = recipient.transform.Translate(0, (0.25 * 16))
	recipient.update_transform()
