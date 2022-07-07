#include scripts\core_common\struct;
#include scripts\core_common\callbacks_shared;
#include scripts\core_common\clientfield_shared;
#include scripts\core_common\math_shared;
#include scripts\core_common\system_shared;
#include scripts\core_common\scoreevents_shared;
#include scripts\core_common\util_shared;
#include scripts\core_common\hud_util_shared;
#include scripts\core_common\hud_message_shared;
#include scripts\core_common\hud_shared;
#include scripts\core_common\array_shared;
#include scripts\core_common\flag_shared;
#include scripts\core_common\scene_shared.gsc;
#include scripts\zm_common\zm_zonemgr;
#include scripts\zm_common\zm_power;
#include scripts\zm_common\zm_blockers;
#include scripts\zm_common\zm_stats;
#include scripts\zm_common\zm_perks;
#include scripts\zm_common\zm_equipment;
#include scripts\core_common\gestures;
#include scripts\zm_common\zm_utility;
#include scripts\zm_common\zm_weapons;
#include scripts\zm_common\zm_loadout;
#include scripts\zm_common\zm;
#include scripts\zm_common\zm_score;
#include script_3f9e0dc8454d98e1;

#namespace clientids_shared;

//required
autoexec __init__sytem__()
{
	system::register("clientids_shared", &__init__, undefined, undefined);
}

//required
__init__()
{

    //WELCOME TO BONUS SURVIVAL MAPS. TO SELECT A MAP, PLEASE ENTER THE MAP NAME BELOW:

    level.customMap = "arena"; //arena, dininghall, docks, groomlake, library, temple, nuketown, beach


    callback::on_start_gametype(&init);
    callback::on_connect(&onPlayerConnect);
    //callback::on_spawned(&onPlayerSpawned);

    if(tolower(getdvarstring(#"hash_3b7b241b78207c96")) == "zm_towers")
    {
        //if(level.customMap == "arena")
            thread arena_main();
    }
    else if(tolower(getdvarstring(#"hash_3b7b241b78207c96")) == "zm_zodt8")
    {
        //if(level.customMap == "dininghall")
            thread dininghall_main();
    }
    else if(tolower(getdvarstring(#"hash_3b7b241b78207c96")) == "zm_escape")
    {
        //if(level.customMap == "docks")
            thread docks_main();
    }
    else if(tolower(getdvarstring(#"hash_3b7b241b78207c96")) == "zm_office")
    {
        //if(level.customMap == "groomlake")
            thread groomlake_main();
    }
    else if(tolower(getdvarstring(#"hash_3b7b241b78207c96")) == "zm_mansion")
    {
        //if(level.customMap == "library")
            thread library_main();
    }
    else if(tolower(getdvarstring(#"hash_3b7b241b78207c96")) == "zm_red")
    {
        //if(level.customMap == "temple")
            thread temple_main();
    }
    else if(tolower(getdvarstring(#"hash_3b7b241b78207c96")) == "zm_white")
    {
        //if(level.customMap == "nuketown")
            thread nuketown_main();
    }
    else if(tolower(getdvarstring(#"hash_3b7b241b78207c96")) == "zm_orange")
    {
        //if(level.customMap == "beach")
            thread beach_main();
    }

    //level.custom_debris_function = &debris_function;
    //level.custom_door_buy_check = &door_function;
    //thread getboxes();

    remove_buildables();

    thread box_weapons();

    thread disableGobbles();

    thread originalPointSystem();
}

box_weapons()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    foreach(weapon in level.zombie_weapons)
    {
        if(weapon.weapon.name == "bowie_knife")
        {
            weapon.is_in_box = 1;
        }
    }
}

originalPointSystem()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    level.a_func_score_events[#"damage_points"] = &damage_points;
    level.a_func_score_events[#"death"] = &death_points;
    callback::add_callback(#"hash_790b67aca1bf8fc0",&pack_callback);
}

pack_callback(upgradedweapon)
{
    if(!isdefined(self.var_2843d3cc))
	{
		return;
	}
    if(!isdefined(self.var_2843d3cc[upgradedweapon]))
	{
		return;
	}
    if(self.var_2843d3cc[upgradedweapon] == 1)
    {
        self.var_2843d3cc[upgradedweapon] = 2;
    }
    else if(self.var_2843d3cc[upgradedweapon] == 3)
    {
        self.var_2843d3cc[upgradedweapon] = 4;
    }
}

damage_points(event, mod, hit_location, zombie_team, damage_weapon)
{
    return 10;
}

death_points(event, mod, hit_location, zombie_team, damage_weapon)
{
    points = 50;
    if(mod == "MOD_MELEE" && (!isdefined(damage_weapon) || (!damage_weapon.isriotshield && !zm_loadout::is_hero_weapon(damage_weapon))))
    {
        scoreevents::processscoreevent("melee_kill", self, undefined, damage_weapon);
        points += 70;
    }
    else if(hit_location == "head" || hit_location == "helmet" || hit_location == "neck")
    {
        scoreevents::processscoreevent("headshot", self, undefined, damage_weapon);
        points += 40;
    }
    else
    {
        scoreevents::processscoreevent("kill", self, undefined, damage_weapon);
    }
    return points;
}

round_wait_override()
{
	level endon(#"restart_round");
	level endon( #"kill_round" );

	wait( 1 );

	while( 1 )
	{
		if( get_current_zombie_count() <= 0 || level.zombie_total <= 0 )
		{
			return;
		}			
			
		if( flag::get( "end_round_wait" ) )
		{
			return;
		}
		wait( 1.0 );
	}
}

spawn_shield(origin, angles, weaponname)
{
    level flag::wait_till("all_players_spawned");
    trigger = Spawn("trigger_radius_use", origin, 0, 100, 50);
    trigger triggerignoreteam();
    //trigger sethintstring(#"hash_53fd856df9288be7"); // already have one.
    trigger sethintstring(#"hash_6a4c5538a960189d");
    trigger setcursorhint("HINT_WEAPON", GetWeapon(weaponname));
    model = spawn("script_model", origin + (0,0,20));
    model.angles = angles;
    model SetModel(GetWeapon(weaponname).worldmodel);
    model NotSolid();
    if(isdefined(GetWeapon(weaponname).dualwieldweapon) && GetWeapon(weaponname).dualwieldweapon != level.weaponnone)
    {
        model = spawn("script_model", origin + (0,0,20));
        model.angles = angles;
        model SetModel(GetWeapon(weaponname).dualwieldweapon.worldmodel);
        model NotSolid();
    }
    for(;;)
    {
        s_result = undefined;
		s_result = trigger waittill(#"trigger");
        e_player = s_result.activator;
        if(e_player hasweapon(GetWeapon(weaponname)))
        {
            trigger sethintstring(#"hash_53fd856df9288be7");
            wait 2;
            trigger sethintstring(#"hash_6a4c5538a960189d");
        }
        else
        {
            e_player zm_weapons::weapon_give(GetWeapon(weaponname));
        }
    }
}

moveChest(origin, angles, col, plinth)
{
    if(!isdefined(col))
        col = 1;
    self.origin = origin;
    self.angles = angles;
    self.chest_box = getent( self.script_noteworthy + "_zbarrier", "script_noteworthy" );
    self.chest_box.origin = origin;
    self.chest_box.angles = angles;
    if(isdefined(plinth) && plinth)
    {
        struct::get(self.script_noteworthy + "_plinth", "targetname").origin = origin;
        struct::get(self.script_noteworthy + "_plinth", "targetname").angles = angles;
    }
    position = origin + (0,0,64);
    if(!col) return;
    col = spawn("script_model", position + AnglesToForward(angles)*30);
    col SetModel("collision_geo_32x32x128_standard");
    col.angles = angles;
    col Ghost();
    col = spawn("script_model", position);
    col SetModel("collision_geo_32x32x128_standard");
    col.angles = angles;
    col Ghost();
    col = spawn("script_model", position - AnglesToForward(angles)*30);
    col SetModel("collision_geo_32x32x128_standard");
    col.angles = angles;
    col Ghost();
}

movePerk(origin, angles, col)
{
    if(!isdefined(col))
        col = 1;
    self.origin = origin;
    self.angles = angles;
    if(isdefined(self.target))
    {
        struct::get(self.target, "targetname").origin = origin;
        struct::get(self.target, "targetname").angles = angles;
    }
    if(!col) return;
    col = spawn("script_model", origin + (0,0,64));
    col SetModel("collision_geo_cylinder_32x128_standard");
    col DisconnectPaths();
    col Ghost();
}

movePap(origin, angles, col)
{
    if(!isdefined(col))
        col = 1;
    getEntArray("zm_pack_a_punch", "targetname")[0].origin = origin;
    getEntArray("zm_pack_a_punch", "targetname")[0].angles = angles;
    col = spawn("script_model", origin + (0,0,64));
    col.angles = angles;
    col SetModel("collision_geo_64x64x128_standard");
    col DisconnectPaths();
    col Ghost();
}

power_on()
{
    SetGametypeSetting(#"zmpowerstate", 2);
}

pack_on()
{
    SetGametypeSetting(#"hash_19d48a0d4490b0a2",2);
}

get_current_zombie_count()
{
	enemies = get_round_enemy_array();
	return enemies.size;
}

get_round_enemy_array()
{
	a_ai_enemies = [];
	a_ai_valid_enemies = [];
	a_ai_enemies = getaiteamarray(level.zombie_team);
	for(i = 0; i < a_ai_enemies.size; i++)
	{
		if(isdefined(a_ai_enemies[i].ignore_enemy_count) && a_ai_enemies[i].ignore_enemy_count)
		{
			continue;
		}
		if(!isdefined(a_ai_valid_enemies))
		{
			a_ai_valid_enemies = [];
		}
		else if(!isarray(a_ai_valid_enemies))
		{
			a_ai_valid_enemies = array(a_ai_valid_enemies);
		}
		a_ai_valid_enemies[a_ai_valid_enemies.size] = a_ai_enemies[i];
	}
	return a_ai_valid_enemies;
}

speedupzambs()
{
    level endon(#"end_game");

    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    level.zombie_vars["zombie_between_round_time"] = 0;
    level.zombie_vars["zombie_spawn_delay"] = 0.1; 
    while(level.round_number <=8)
    {
        foreach(zombie in get_round_enemy_array())
            zombie zombie_utility::set_zombie_run_cycle_override_value("run");
        wait 1;
    }
}

debris_function()
{
    junk = getentarray(self.target, "targetname");
	for(i = 0; i < junk.size; i++)
	{
		if(isdefined(junk[i].script_noteworthy))
		{
			if(junk[i].script_noteworthy == "clip")
			{
				if(junk[i].script_string !== "skip_disconnectpaths")
				{
					junk[i] disconnectpaths();
				}
			}
		}
	}
    while(1)
    {
        waitresult = undefined;
        waitresult = self waittill(#"trigger");
        iprintln("Origin: " + self.origin);
        wait 1;
    }
}

door_function(door)
{
    iprintln("Origin: " + door.origin);
    return 1;
}

getboxes()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    foreach(chest in level.chests)
    {
        iprintln("" + chest.script_noteworthy);
    }
}

remove_buildables()
{
    foreach(item in getitemarray())
    {
        item.origin = (0,0,-10000);
    }
}

disableGobbles()
{
    //SetGametypeSetting(#"hash_3ab7cedcfef7eacc", 0);
    //SetGametypeSetting(#"hash_5374d50efd1e6b59", 0);
    //SetGametypeSetting(#"hash_5e1f08b8335a0ce0", 0);
    //SetGametypeSetting(#"hash_5746674cbab8264d", 0);
    //SetGametypeSetting(#"hash_7ea1426ffa93f34d", 0);

    SetGametypeSetting(#"hash_6230ef2b089aad7f",0);
}