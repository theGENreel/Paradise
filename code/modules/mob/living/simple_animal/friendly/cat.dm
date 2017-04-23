//Cat
/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	icon_resting = "cat2_rest"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows", "mews")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	mob_size = MOB_SIZE_SMALL
	simplespecies = /mob/living/simple_animal/pet/cat
	childtype = /mob/living/simple_animal/pet/cat/kitten
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	var/eats_mice = 1

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/pet/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	icon_resting = "cat_rest"
	gender = FEMALE
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	var/list/family = list()
	var/lives = 9
	var/memory_saved = 0

/mob/living/simple_animal/pet/cat/Runtime/New()
	Read_Memory()
	..()

/mob/living/simple_animal/pet/cat/Runtime/Life()
	if(!stat && ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory()
	..()

/mob/living/simple_animal/pet/cat/Runtime/death()
	if(!memory_saved)
		Write_Memory(1)
	..()

/mob/living/simple_animal/pet/cat/Runtime/proc/Read_Memory()
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	S["family"] 			>> family
	S["lives"]				>> lives

	if(isnull(family))
		family = list()

	if(isnull(lives))
		lives = 9

	if(lives <= 0)
		lives = 10 //Lowers to 9 in Write_Memory
		Write_Memory(1)
		qdel(src)

	for(var/cat_type in family)
		if(family[cat_type] > 0)
			for(var/i in 1 to family[cat_type])
				new cat_type(loc)

/mob/living/simple_animal/pet/cat/Runtime/proc/Write_Memory(dead)
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	if(dead)
		S["lives"] 				<< lives - 1
	family = list()
	for(var/mob/living/simple_animal/pet/cat/C in mob_list)
		if(istype(C,type) || C.stat || !C.butcher_results || C.name == "SyndiCat")
			continue
		if(C.type in family)
			family[C.type] += 1
		else
			family[C.type] = 1
	S["family"]				<< family
	memory_saved = 1

/mob/living/simple_animal/pet/cat/handle_automated_action()
	..()

	//MICE!
	if(eats_mice && loc && isturf(loc) && !incapacitated())
		for(var/mob/living/simple_animal/mouse/M in view(1,src))
			if(!M.stat && Adjacent(M))
				custom_emote(1, "splats \the [M]!")
				M.splat()
				movement_target = null
				stop_automated_movement = 0
				break

	//attempt to mate
	make_babies()

/mob/living/simple_animal/pet/cat/handle_automated_movement()
	..()
	if(eats_mice && !incapacitated())
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)

/mob/living/simple_animal/pet/cat/Proc
	name = "Proc"

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	icon_resting = null
	gender = NEUTER
	density = 0
	pass_flags = PASSMOB

/mob/living/simple_animal/pet/cat/Syndi
	name = "SyndiCat"
	desc = "It's a SyndiCat droid."
	icon_state = "Syndicat"
	icon_living = "Syndicat"
	icon_dead = "Syndicat_dead"
	icon_resting = "Syndicat_rest"
	gender = FEMALE
	flags = NO_BREATHE
	faction = list("syndicate")
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	eats_mice = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0