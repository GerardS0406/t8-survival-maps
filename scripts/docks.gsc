docks_main()
{
    setup_docks_spawnpoints();
    thread activate_zones_docks();
    disableDocksBarriers();

    thread docks_Chests();

    thread gats_in_box();

    //struct::get_array("perk_vapor_altar")[0] movePerk((-240,5513,-72), (0,-170,0), 1); //cola
    struct::get_array("perk_vapor_altar")[1] movePerk((-240,5513,-72), (0,-170,0), 1); //tonic
    struct::get_array("perk_vapor_altar")[2] movePerk((-578,6095,-36), (0,-170,0), 1); //brew
    struct::get_array("perk_vapor_altar")[3] movePerk((-26,6401,64), (0,100,0), 1); //soda

    thread power_on();
    thread pack_on();

    thread spawn_shield((-217,5719,16),(0,145,0),#"hash_42a45d43be3dba42");

    thread doggie();
}

docks_Chests()
{
    chests = struct::get_array("treasure_chest_use", "targetname");
    i = 0;
    foreach(chest in chests)
    {
        if(chest.script_noteworthy == "warden_house_chest")
        {
            chest moveChest((-309,6349,64),(0,10,0),1);
        }
        if(chest.script_noteworthy == "dock_chest" || chest.script_noteworthy == "warden_house_chest")
        {
            chest.start_exclude = 0;
            chest.no_fly_away = 1;
            continue;
        }
        else
        {
            chest.start_exclude = 1;
            continue;
        }
    }
    level flag::wait_till("all_players_spawned");
    level.start_chest_name = "dock_chest";
    level._zombiemode_custom_box_move_logic = &docks_box_logic;
}

gats_in_box()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    foreach(weapon in level.zombie_weapons)
    {
        if(weapon.weapon.name == #"hash_23882a5729dceca" || weapon.weapon.name == #"hash_25a13b6f6232a985")
        {
            weapon.is_in_box = 1;
        }
    }
}

docks_box_logic()
{
    old_chest = level.chests[level.chest_index].script_noteworthy;
    level.chests = array::randomize(level.chests);
    for(i = 0; i < level.chests.size; i++)
    {
        if(old_chest == level.chests[i].script_noteworthy)
            continue;
        if(level.chests[i].script_noteworthy == "dock_chest" || level.chests[i].script_noteworthy == "warden_house_chest")
        {
            level.chest_index = i;
            break;
        }
    }
}

setup_docks_spawnpoints()
{
    foreach(spawn in struct::get_array("initial_spawn", "script_noteworthy"))
    {
        spawn.origin = (-403,5466,-71);
        spawn.angles = (0,180,0);
    }
    struct::get_array("initial_spawn", "script_noteworthy")[0].origin = (-403,5466,-71);
    struct::get_array("initial_spawn", "script_noteworthy")[0].angles = (0,180,0);
    struct::get_array("initial_spawn", "script_noteworthy")[1].origin = (-403,5466,-71);
    struct::get_array("initial_spawn", "script_noteworthy")[1].angles = (0,180,0);
    struct::get_array("initial_spawn", "script_noteworthy")[2].origin = (-403,5466,-71);
    struct::get_array("initial_spawn", "script_noteworthy")[2].angles = (0,180,0);
    struct::get_array("initial_spawn", "script_noteworthy")[3].origin = (-403,5466,-71);
    struct::get_array("initial_spawn", "script_noteworthy")[3].angles = (0,180,0);
}

activate_zones_docks()
{
    level flag::wait_till("all_players_spawned");
    zm_zonemgr::enable_zone("zone_dock");
    zm_zonemgr::enable_zone("zone_dock_gondola");
    spots = struct::get_array("spawn_location", "script_noteworthy");
    foreach(spot in spots)
    {
        if(isdefined(spot.zone_name) && spot.zone_name == "zone_dock")
        {
            if(spot.origin == (-1548,5909,-55) || spot.origin == (-1550,5860,-55)) //(-1548,5909,-55) (-1550,5860,-55)
                spot.origin = (-1548,5665,-55);
            //iprintln("Origin: " + spot.origin);
        }
    }
    level.zones["zone_model_industries"].is_enabled = 0;
	level.zones["zone_model_industries"].is_spawning_allowed = 0;
    level.zones["zone_model_industries_upper"].is_enabled = 0;
	level.zones["zone_model_industries_upper"].is_spawning_allowed = 0;
}

disableDocksBarriers()
{
    foreach(barrier in getentarray("zombie_door", "targetname"))
    {
        if(barrier.origin == (-549,6893,112) || barrier.origin == (521,6867,224) || barrier.origin == (-275, 6937, 112))
        {
            barrier.origin = (0,0,-10000);
        }
    }
    foreach(trig in getentarray("gondola_call_trigger", "targetname"))
    {
        trig.origin = trig.origin + (0,0,-1000);
    }
}

doggie()
{
    zm::register_zombie_damage_override_callback(&doggie_points);
    count = 0;
    foreach(dog in struct::get_array("wolf_position"))
    {
        if(count == 0)
        {
            dog.origin = (235,6170,37);
            getent(dog.target, "targetname").origin = (235,6170,37);
            struct::get(dog.var_799fb8e9).origin = (8,6275,150);
            struct::get(dog.var_799fb8e9).angles = (0,-80,0);
            dog thread track_doges();
        }
        else
        {
            dog struct::delete();
        }
        count++;
    }
    thread customTomahawkPickup();
}

doggie_points(willbekilled, inflictor, attacker, damage, flags, mod, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex, surfacetype)
{
    if(self.archetype != "zombie")
	{
		return;
	}
	if(isdefined(self.var_bfffc79e) && self.var_bfffc79e || (isdefined(self.var_fc11268c) && self.var_fc11268c))
	{
		return;
	}
    if(isplayer(attacker) && (isdefined(willbekilled) && willbekilled || damage >= self.health))
	{
		for(i = 0; i < level.var_4952e1.size; i++)
		{
			if(self istouching(level.var_b5ca4338[i]))
			{
                attacker zm_score::player_add_points("death", mod, shitloc, self, 1, weapon, 0, 0);
            }
        }
    }
}

track_doges()
{
    self endon(#"hash_13c5316203561c4f");
    level flag::wait_till("all_players_spawned");
    count = 0;
    while(1)
    {
        if(self.var_43bd3b5 > 0)
        {
            self.var_43bd3b5 = 0;
            count++;
            if(count >= 12)
            {
                self.var_43bd3b5 = 6;
                break;
            }
        }
        waitframe(1);
    }
}

customTomahawkPickup()
{
    struct::get("t_tom_pos", "targetname").origin = (884,5795,264);
    struct::get("tom_pil").origin = (884,5795,164);
    level flag::wait_till("all_players_spawned");
    level flag::wait_till(#"soul_catchers_charged");
	var_fd22f9df = struct::get("tom_pil");
    zm_weapons::include_zombie_weapon("tomahawk_t8_upgraded",1);
    zm_weapons::add_zombie_weapon("tomahawk_t8_upgraded","", 0,0,undefined,undefined,"","",0,undefined,1);
	var_6e6ec518 = var_fd22f9df.scene_ents[#"prop 2"];
	wait(0.5);
	var_6e6ec518 playloopsound(#"amb_tomahawk_swirl");
	s_pos_trigger = struct::get("t_tom_pos", "targetname");
	if(isdefined(s_pos_trigger))
	{
		trigger = spawn("trigger_radius_use", s_pos_trigger.origin, 0, 100, 100);
		trigger.script_noteworthy = "rt_pickup_trigger";
		trigger triggerignoreteam();
		trigger sethintstring(#"hash_1cf1c33d78cb53aa");
		trigger setcursorhint("HINT_NOICON");
	}
	if(isdefined(trigger))
	{
		trigger thread tomahawk_pickup_trigger();
		foreach(e_player in getplayers())
		{
			e_player thread function_6300f001();
		}
		callback::on_connect(&function_6300f001);
	}
	level flag::set(#"tomahawk_pickup_complete");
}

tomahawk_pickup_trigger()
{
    while(true)
	{
		s_result = undefined;
		s_result = self waittill(#"trigger");
		e_player = s_result.activator;
		if(!e_player hasweapon(getweapon(#"tomahawk_t8")) && !e_player hasweapon(getweapon(#"tomahawk_t8_upgraded")))
		{
			self thread function_f0ef3897(e_player);
			waitframe(1);
		}
	}
}

function_f0ef3897(e_player)
{
    e_player notify(#"hash_78d7f70251d51f7c");
	e_player endon(#"hash_78d7f70251d51f7c", #"disconnect");
	var_fd22f9df = struct::get("tom_pil");
	var_6e6ec518 = var_fd22f9df.scene_ents[#"prop 2"];
	var_6e6ec518 setinvisibletoplayer(e_player);
	self setinvisibletoplayer(e_player);
	e_player zm_utility::disable_player_move_states(1);
	e_player.var_67e1d531 = e_player._gadgets_player[1];
	e_player zm_weapons::weapon_take(e_player._gadgets_player[1]);
	if(e_player flag::exists(#"hash_11ab20934759ebc3") && e_player flag::get(#"hash_11ab20934759ebc3"))
	{
		e_player zm_weapons::weapon_give(getweapon(#"tomahawk_t8_upgraded"));
		var_f8807d03 = #"hash_77bbe7cec9945ff5";
	}
	else
	{
		e_player zm_weapons::weapon_give(getweapon(#"tomahawk_t8"));
		var_f8807d03 = #"hash_a89ec051050c008";
	}
	e_player thread function_b5b00d86();
	e_player thread zm_equipment::show_hint_text(var_f8807d03);
	if(self.script_noteworthy == "rt_pickup_trigger")
	{
		e_player.retriever_trigger = self;
	}
	e_player clientfield::set_to_player("tomahawk_in_use", 1);
	e_player notify(#"player_obtained_tomahawk");
	level notify(#"hash_be544b0040afa0b");
	e_player zm_stats::increment_client_stat("prison_tomahawk_acquired", 0);
	if(e_player flag::exists(#"hash_11ab20934759ebc3") && e_player flag::get(#"hash_11ab20934759ebc3"))
	{
		e_player clientfield::set_to_player("" + #"upgraded_tomahawk_in_use", 1);
	}
	e_player zm_utility::enable_player_move_states();
}

function_b5b00d86()
{
    self gestures::function_56e00fbf("gestable_zombie_tomahawk_flourish", undefined, 0);
}

function_6300f001()
{
    self endon(#"disconnect");
    var_6668e57a = getent("rt_pickup_trigger", "script_noteworthy");
	var_fd22f9df = struct::get("tom_pil");
	var_6e6ec518 = var_fd22f9df.scene_ents[#"prop 2"];
	while(isplayer(self))
	{
		if(isdefined(var_6668e57a))
		{
			if(level flag::get(#"soul_catchers_charged") && !self hasweapon(getweapon(#"tomahawk_t8")) && !self hasweapon(getweapon(#"tomahawk_t8_upgraded")))
			{
				if(!self flag::exists(#"hash_120fbb364796cd32") && !self flag::exists(#"hash_11ab20934759ebc3") || (!self flag::get(#"hash_120fbb364796cd32") || self flag::get(#"hash_11ab20934759ebc3")))
				{
					var_6668e57a setvisibletoplayer(self);
					var_6e6ec518 setvisibletoplayer(self);
					if(self flag::exists(#"hash_11ab20934759ebc3") && self flag::get(#"hash_11ab20934759ebc3"))
					{
						self clientfield::set_to_player("" + #"hash_51657261e835ac7c", 1);
					}
					else
					{
						self clientfield::set_to_player("" + #"tomahawk_pickup_fx", 1);
					}
				}
				else
				{
					var_6668e57a setinvisibletoplayer(self);
					var_6e6ec518 setinvisibletoplayer(self);
					self clientfield::set_to_player("" + #"tomahawk_pickup_fx", 0);
					self clientfield::set_to_player("" + #"hash_51657261e835ac7c", 0);
					waitframe(1);
				}
			}
			else
			{
				var_6668e57a setinvisibletoplayer(self);
				var_6e6ec518 setinvisibletoplayer(self);
				self clientfield::set_to_player("" + #"tomahawk_pickup_fx", 0);
				self clientfield::set_to_player("" + #"hash_51657261e835ac7c", 0);
				waitframe(1);
			}
		}
		wait(1);
	}
}