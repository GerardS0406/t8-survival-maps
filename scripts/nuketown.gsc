nuketown_main()
{
    setup_nuked_spawnpoints();
    doors = struct::get_array("bunker_door_electric", "script_noteworthy");
	foreach(door in doors)
	{
        door.var_ee00b371 = door.init_anim;
	}
    disableNuketownBarriers();
    deleteNuketownPortals();
    thread activate_zones_nuked();

    thread nuketown_Chests();

    thread rayguns_in_box();

    npl = [];
    npl[0] = struct::spawn((-1271,666,-59),(0,70,0));
    npl[1] = struct::spawn((1463,-24,-61),(0,90,0));
    npl[2] = struct::spawn((590,280,87),(0,-30,0));
    npl[3] = struct::spawn((-564,-151,-62),(0,25,0));
    npl[4] = struct::spawn((-2040,268,-52),(0,37,0));
    npl[5] = struct::spawn((-372,1295,-55),(0,-65,0));
    npl = array::randomize(npl);

    struct::get_array("perk_vapor_altar")[0] movePerk(npl[0].origin, npl[0].angles, 1);
    struct::get_array("perk_vapor_altar")[1] movePerk(npl[1].origin, npl[1].angles, 1);
    struct::get_array("perk_vapor_altar")[2] movePerk(npl[2].origin, npl[2].angles, 1);
    struct::get_array("perk_vapor_altar")[3] movePerk(npl[3].origin, npl[3].angles, 1);

    //level thread nuketown_perks();

    movepap(npl[4].origin, npl[4].angles + (0,90,0), 1);

    thread spawn_shield((98,547,-30),(0,160,0),#"hash_603fdd2e4ae5b2b0");

    thread nuketown_pap();
    thread nuketown_power();
}

disableNuketownBarriers()
{
    foreach(barrier in getentarray("zombie_debris", "targetname"))
    {
        if(barrier.origin == (266,-620,-4) || barrier.origin == (-196,-537,-4))
        {
            barrier.origin = (0,0,-10000);
        }
    }
}

nuketown_Chests()
{
    chests = struct::get_array("treasure_chest_use", "targetname");
    i = 0;
    foreach(chest in chests)
    {
        if(chest.script_noteworthy == "green_backyard_chest" || chest.script_noteworthy == "yellow_backyard_chest")
        {
            chest.start_exclude = 0;
            continue;
        }
        else
        {
            chest.start_exclude = 1;
            continue;
        }
    }
    level flag::wait_till("all_players_spawned");
    level.start_chest_name = "green_backyard_chest";
    level._zombiemode_custom_box_move_logic = &nuked_box_logic;
}

rayguns_in_box()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    foreach(weapon in level.zombie_weapons)
    {
        if(weapon.weapon.name == "ray_gun_mk2" || weapon.weapon.name == "ray_gun_mk2v" || weapon.weapon.name == "ray_gun_mk2x" || weapon.weapon.name == "ray_gun_mk2y" || weapon.weapon.name == "ray_gun_mk2z" || weapon.weapon.name == "ray_gun")
        {
            weapon.is_in_box = 1;
        }
    }
}

nuked_box_logic()
{
    old_chest = level.chests[level.chest_index].script_noteworthy;
    level.chests = array::randomize(level.chests);
    for(i = 0; i < level.chests.size; i++)
    {
        if(old_chest == level.chests[i].script_noteworthy)
            continue;
        if(level.chests[i].script_noteworthy == "cul_de_sac_chest" || level.chests[i].script_noteworthy == "green_backyard_chest" || level.chests[i].script_noteworthy == "yellow_backyard_chest")
        {
            level.chest_index = i;
            break;
        }
    }
}

nuketown_perks()
{
    level flag::wait_till("all_players_spawned");
    for(i=0;i<4;i++)
    {
        level.var_76a7ad28[i].origin += (0,0,-10000);
    }

    level waittill(#"start_of_round");
    iprintln("wait a round");
    level waittill(#"start_of_round");
    for(i=0;i<4;i++)
    {
        level.var_76a7ad28[i].origin += (0,0,10000);
    }
}

setup_nuked_spawnpoints()
{
    struct::get_array("initial_spawn", "script_noteworthy")[0].origin = (-289,359,-58);
    struct::get_array("initial_spawn", "script_noteworthy")[0].angles = (0,-40,0);
    struct::get_array("initial_spawn", "script_noteworthy")[1].origin = (-289,359,-58);
    struct::get_array("initial_spawn", "script_noteworthy")[1].angles = (0,-40,0);
    struct::get_array("initial_spawn", "script_noteworthy")[2].origin = (-289,359,-58);
    struct::get_array("initial_spawn", "script_noteworthy")[2].angles = (0,-40,0);
    struct::get_array("initial_spawn", "script_noteworthy")[3].origin = (-289,359,-58);
    struct::get_array("initial_spawn", "script_noteworthy")[3].angles = (0,-40,0);
}

activate_zones_nuked()
{
    level flag::wait_till("all_players_spawned");
    zm_zonemgr::enable_zone("zone_culdesac_green");
    zm_zonemgr::enable_zone("zone_culdesac_yellow");
    zm_zonemgr::enable_zone("zone_angled_house");
}

nuketown_power()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    level flag::set("power_on1");
    level flag::set("power_on2");
    foreach(pswitch in getentarray("use_elec_switch", "targetname"))
    {
        pswitch setinvisibletoall();
    }
}

nuketown_pap()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    level flag::set("pap_power_ready");
}

deleteNuketownPortals()
{
    foreach(portal in struct::get_array("white_portal"))
    {
        portal.origin = (0,0,-10000);
    }
}