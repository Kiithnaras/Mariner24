/obj/structure/fitness
	icon = 'icons/obj/stationobjs.dmi'
	anchored = 1
	var/being_used = 0

/obj/structure/fitness/punchingbag
	name = "punching bag"
	desc = "A punching bag."
	icon_state = "punchingbag"
	density = 1
	var/list/hit_message = list("hit", "punch", "kick", "robust")

/obj/structure/fitness/punchingbag/attack_hand(var/mob/living/carbon/human/user)
	if(!istype(user))
		..()
		return
	var/synth = user.isSynthetic()
	if(!synth && user.nutrition < 20)
		to_chat(user, "<span class='warning'>You need more energy to use the punching bag. Go eat something.</span>")
	else
		if(user.a_intent == I_HURT)
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			flick("[icon_state]_hit", src)
			playsound(src.loc, 'sound/effects/woodhit.ogg', 25, 1, -1)
			user.do_attack_animation(src)
			if(!synth)
				user.nutrition = user.nutrition - 5
			var/trainprob = 20 / user.get_skill_value(SKILL_COMBAT) ** 2
			to_chat(user, "<span class='warning'>You [pick(hit_message)] \the [src].</span>")
			if(!synth && prob(trainprob))
				if(user.too_many_buffs(/datum/skill_buff/fitness))
					to_chat(user,"<span class='notice'>You've trained hard enough today already.</span>")
				else if(user.get_skill_value(SKILL_COMBAT) == SKILL_MAX)
					to_chat(user,"<span class='notice'>You're already aces at this, hitting a sack isn't going to help any more.</span>")
				else
					to_chat(user,"<span class='notice'>Surprisingly, you feel like you're getting better by just hitting this thing.</span>")
					var/list/buff = list(SKILL_COMBAT = 1)
					var/buffpath = /datum/skill_buff/fitness
					user.buff_skill(buff, 0, buffpath)

/obj/structure/fitness/weightlifter
	name = "weightlifting machine"
	desc = "A machine used to lift weights."
	icon_state = "weightlifter"
	var/weight = 1
	var/max_weight = 5
	var/list/success_message = list("with great effort", "straining hard", "without any trouble", "with ease")
	var/list/fail_message = list(", lifting them part of the way and then letting them drop", ", unable to even budge them")

/obj/structure/fitness/weightlifter/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isWrench(W))
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 75, 1)
		weight = (weight % max_weight) + 1
		to_chat(user, "You set the machine's weight level to [weight].")

/obj/structure/fitness/weightlifter/attack_hand(var/mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/synth = user.isSynthetic()
	if(user.loc != src.loc)
		to_chat(user, "<span class='warning'>You must be on the weight machine to use it.</span>")
		return
	if(!synth && user.nutrition < 50)
		to_chat(user, "<span class='warning'>You need more energy to lift weights. Go eat something.</span>")
		return
	if(being_used)
		to_chat(user, "<span class='warning'>The weight machine is already in use by somebody else.</span>")
		return
	else
		being_used = 1
		playsound(src.loc, 'sound/effects/weightlifter.ogg', 50, 1)
		user.set_dir(SOUTH)
		flick("[icon_state]_[weight]", src)
		if(do_after(user, 20 + (weight * 10)))
			playsound(src.loc, 'sound/effects/weightdrop.ogg', 25, 1)
			var/skill = max_weight * user.get_skill_value(SKILL_HAULING)/SKILL_MAX
			var/message
			if(skill < weight)
				if(weight - skill > max_weight/2)
					if(prob(50))
						message = ", getting hurt in the process"
						user.apply_damage(5 * (weight - skill)) //Set very high with untrained louts, this could ~really~ hurt. Antag opportunities.
					else
						message = "; this does not look safe"
				else
					message = fail_message[min(1 + round(weight - skill), fail_message.len)]
				user.visible_message("<span class='notice'>\The [user] fails to lift the weights[message].</span>", "<span class='notice'>You fail to lift the weights[message].</span>")
			else
				if(!synth)
					user.nutrition -= weight * 5
				message = success_message[min(1 + round(skill - weight), fail_message.len)]
				user.visible_message("<span class='notice'>\The [user] lift\s the weights [message].</span>", "<span class='notice'>You lift the weights [message].</span>")
				var/toneprob = (20 * weight) / (user.get_skill_value(SKILL_HAULING) ** 2)
				if(!synth && prob(toneprob))
					if(user.too_many_buffs(/datum/skill_buff/fitness))
						to_chat(user,"<span class='notice'>You feel like you have toned yourself as much as you possibly can today.</span>")
					else if(skill == SKILL_MAX)
						to_chat(user,"<span class='notice'>Lifting these weights is a breeze.</span>")
					else
						to_chat(user,"<span class='notice'>You feel a little more at ease lifting these weights.</span>")
						var/buff = list(SKILL_HAULING = 1)
						var/buffpath = /datum/skill_buff/fitness
						user.buff_skill(buff, 0, buffpath)
			being_used = 0
		else
			to_chat(user, "<span class='notice'>Against your previous judgement, perhaps working out is not for you.</span>")
			being_used = 0

/datum/skill_buff/fitness
	limit = 3