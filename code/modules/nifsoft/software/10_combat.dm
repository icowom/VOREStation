/datum/nifsoft/brute_armor
	name = "Bullhide Mod"
	desc = "A difficult-to-produce thickening of the dermis and skeletal structure, allowing a user to absorb more external trauma from physical sources."
	list_pos = NIF_BRUTEARMOR
	cost = 3200
	p_drain = 0.05
	illegal = TRUE
	wear = 3
	access = 999 //Prevents anyone from buying it without an emag.
	activates = FALSE //It's armor.

	install()
		if((. = ..()))
			nif.set_flag(NIF_C_BRUTEARMOR,NIF_FLAGS_COMBAT)

	uninstall()
		. = ..()
		nif.clear_flag(NIF_C_BRUTEARMOR,NIF_FLAGS_COMBAT)

/datum/nifsoft/burn_armor
	name = "Dragon's Skin"
	desc = "A thin layer of material under the skin provides heat disappation for burns, reducing the trauma from lasers and fire. Not effective against ongoing environmental heat."
	list_pos = NIF_BURNARMOR
	cost = 3200
	p_drain = 0.05
	illegal = TRUE
	wear = 3
	access = 999 //Prevents anyone from buying it without an emag.
	activates = FALSE //It's armor.

	install()
		if((. = ..()))
			nif.set_flag(NIF_C_BURNARMOR,NIF_FLAGS_COMBAT)

	uninstall()
		. = ..()
		nif.clear_flag(NIF_C_BURNARMOR,NIF_FLAGS_COMBAT)

/datum/nifsoft/painkillers
	name = "Nova Shock"
	desc = "A constant stream of high-grade painkillers numb the user's body to all pain. Generally results in extreme addiction or overdose."
	list_pos = NIF_PAINKILLERS
	cost = 2600
	a_drain = 1 //Gotta produce them drugs, yo.
	illegal = TRUE
	wear = 2
	access = 999 //Prevents anyone from buying it without an emag.
	tick_flags = NIF_ACTIVETICK

	activate()
		if((. = ..()))
			nif.set_flag(NIF_C_PAINKILLERS,NIF_FLAGS_COMBAT)

	deactivate()
		if((. = ..()))
			nif.clear_flag(NIF_C_PAINKILLERS,NIF_FLAGS_COMBAT)

	life()
		if((. = ..()))
			var/mob/living/carbon/human/H = nif.human
			H.bloodstr.add_reagent("numbenzyme",0.5)

/datum/nifsoft/hardclaws
	name = "Bloodletters"
	desc = "Generates monofilament wires from one's fingertips, allowing one to slash through almost any armor with relative ease. The monofilaments need to be replaced constantly, though, which does use power."
	list_pos = NIF_HARDCLAWS
	cost = 2200
	a_drain = 0.5
	illegal = TRUE
	wear = 4
	access = 999 //Prevents anyone from buying it without an emag.

	activate()
		if((. = ..()))
			nif.set_flag(NIF_C_HARDCLAWS,NIF_FLAGS_COMBAT)

	deactivate()
		if((. = ..()))
			nif.clear_flag(NIF_C_HARDCLAWS,NIF_FLAGS_COMBAT)

// The unarmed attack to go with the hardclaws
var/global/datum/unarmed_attack/hardclaws/unarmed_hardclaws = new()
/datum/unarmed_attack/hardclaws
	attack_verb = list("claws")
	attack_noun = list("talons")
	damage = 15
	attack_sound = "punch"
	miss_sound = 'sound/weapons/punchmiss.ogg'
	sharp = 1
	edge = 1
	sparring_variant_type = /datum/unarmed_attack/hardclaws

/datum/nifsoft/hidelaser
	name = "Dazzle"
	desc = "Fabricates a 2-shot holdout laser inside your body, which can be deployed (somewhat painfully) on demand. Only enough materials to generate one."
	list_pos = NIF_HIDDENLASER
	cost = 2200
	//a_drain = 50 //Done manually below.
	illegal = TRUE
	wear = 6
	access = 999 //Prevents anyone from buying it without an emag.
	var/used = FALSE

	activate()
		if((. = ..()))
			nif.set_flag(NIF_C_HIDELASER,NIF_FLAGS_COMBAT)
			if(used)
				nif.notify("You do not have a hidden weapon to deploy anymore!",TRUE)
				deactivate()
				return FALSE
			if(!nif.use_charge(50))
				nif.notify("Insufficient energy to deploy weapon!",TRUE)
				deactivate()
				return FALSE

			var/mob/living/carbon/human/H = nif.human
			H.adjustHalLoss(30)
			var/obj/item/weapon/gun/energy/gun/martin/dazzle/dgun = new(get_turf(H))
			H.put_in_hands(dgun)
			nif.notify("Weapon deployed!",TRUE)
			used = TRUE
			spawn(0)
				uninstall()

	deactivate()
		if((. = ..()))
			nif.clear_flag(NIF_C_HIDELASER,NIF_FLAGS_COMBAT)

//The gun to go with this implant
/obj/item/weapon/gun/energy/gun/martin/dazzle
	name = "Microlaser"
	desc = "A tiny nanofabricated laser."

	icon = 'icons/obj/gun_vr.dmi'
	icon_state = "PDW"
	item_state = "gun"
