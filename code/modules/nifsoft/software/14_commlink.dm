///////////
// Commlink - Has a bunch of extra stuff due to communicator defines.
/datum/nifsoft/commlink
	name = "Commlink"
	desc = "An internal communicator for keeping in touch with people."
	list_pos = NIF_COMMLINK
	cost = 500
	wear = 0
	p_drain = 0.01

	install()
		if((. = ..()))
			nif.comm = new(nif,src)

	activate()
		if((. = ..()))
			nif.set_flag(NIF_O_COMMLINK,NIF_FLAGS_OTHER)
			nif.comm.initialize_exonet(nif.human)
			nif.comm.ui_interact(nif.human,key_state = commlink_state)
			spawn(0)
				deactivate()

	deactivate()
		if((. = ..()))
			nif.clear_flag(NIF_O_COMMLINK,NIF_FLAGS_OTHER)

	stat_text()
		return "Show Commlink"

/datum/nifsoft/commlink/Topic(href, href_list)
	if(href_list["open"])
		activate()

/obj/item/device/communicator/commlink
	name = "commlink"
	desc = "An internal communicator, basically."
	occupation = "\[Commlink\]"
	var/obj/item/device/nif/nif
	var/datum/nifsoft/commlink/nifsoft

	New(var/newloc,var/soft)
		..()
		nif = newloc
		nifsoft = soft
		register_device(nif.human)
		qdel(camera) //Not supported on internal one.

	Destroy()
		if(nif)
			nif.comm = null
			nif = null
		..()

//So that only the owner's chat is relayed to others.
/obj/item/device/communicator/commlink/hear_talk(mob/living/M, text, verb, datum/language/speaking)
	if(M != nif.human) return
	for(var/obj/item/device/communicator/comm in communicating)

		var/turf/T = get_turf(comm)
		if(!T) return

		var/icon_object = src

		var/list/mobs_to_relay
		if(istype(comm,/obj/item/device/communicator/commlink))
			var/obj/item/device/communicator/commlink/CL = comm
			mobs_to_relay = list(CL.nif.human)
			icon_object = CL.nif.big_icon
		else
			var/list/in_range = get_mobs_and_objs_in_view_fast(T,world.view,0)
			mobs_to_relay = in_range["mobs"]

		for(var/mob/mob in mobs_to_relay)
			//Can whoever is hearing us understand?
			if(!mob.say_understands(M, speaking))
				if(speaking)
					text = speaking.scramble(text)
				else
					text = stars(text)
			var/name_used = M.GetVoice()
			var/rendered = null
			if(speaking) //Language being used
				rendered = "<span class='game say'>\icon[icon_object] <span class='name'>[name_used]</span> [speaking.format_message(text, verb)]</span>"
			else
				rendered = "<span class='game say'>\icon[icon_object] <span class='name'>[name_used]</span> [verb], <span class='message'>\"[text]\"</span></span>"
			mob.show_message(rendered, 2)

//Not supported by the internal one
/obj/item/device/communicator/commlink/show_message(msg, type, alt, alt_type)
	return

//The silent treatment
/obj/item/device/communicator/commlink/request(var/atom/candidate)
	if(candidate in voice_requests)
		return
	var/who = null
	if(isobserver(candidate))
		who = candidate.name
	else if(istype(candidate, /obj/item/device/communicator))
		var/obj/item/device/communicator/comm = candidate
		who = comm.owner
		comm.voice_invites |= src

	if(!who)
		return

	voice_requests |= candidate

	if(ringer && nif.human)
		nif.notify("New commlink call from [who]. (<a href='?src=\ref[nifsoft];open=1'>Open</a>)")

//Similar reason
/obj/item/device/communicator/commlink/request_im(var/atom/candidate, var/origin_address, var/text)
	var/who = null
	if(isobserver(candidate))
		var/mob/observer/dead/ghost = candidate
		who = ghost
		im_list += list(list("address" = origin_address, "to_address" = exonet.address, "im" = text))
	else if(istype(candidate, /obj/item/device/communicator))
		var/obj/item/device/communicator/comm = candidate
		who = comm.owner
		comm.im_contacts |= src
		im_list += list(list("address" = origin_address, "to_address" = exonet.address, "im" = text))
	else return

	im_contacts |= candidate

	if(!who)
		return

	if(ringer && nif.human)
		nif.notify("Commlink message from [who]: \"[text]\" (<a href='?src=\ref[nifsoft];open=1'>Open</a>)")
