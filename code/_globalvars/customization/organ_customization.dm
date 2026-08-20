GLOBAL_LIST_INIT(customizer_choices, build_customizer_choices())
GLOBAL_LIST_INIT(customizers, build_customizers())

/proc/build_customizer_choices()
	. = list()
	for(var/type in typesof(/datum/customizer_choice))
		if(is_abstract(type))
			continue
		.[type] = new type()
	return .

/proc/build_customizers()
	. = list()
	for(var/type in typesof(/datum/customizer))
		if(is_abstract(type))
			continue
		.[type] = new type()
	return .

/// Standard character color picker — opens BYOND's native color dialog, so
/// every color choice (hair, eyes, skin tone, dyes, etc.) looks and behaves
/// the same everywhere in the game.
/proc/color_pick_native(mob/user, description, title, default_value)
	var/color = input(user, description, title, default_value) as color|null
	if(!color)
		return
	return sanitize_hexcolor(color)
