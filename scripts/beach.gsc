beach_main()
{
    setup_beach_spawnpoints();
    thread activate_zones_beach();
    disableBeachBarriers();

    thread beach_Chests();

    thread wunderwaffe_in_box();

    struct::get_array("perk_vapor_altar")[0] movePerk((-1830,5,35), (0,124,0), 0); //cola
    struct::get_array("perk_vapor_altar")[1] movePerk((-2560,-270,20), (0,40,0), 1); //tonic
    struct::get_array("perk_vapor_altar")[2] movePerk((-1286,1174,10), (0,-120,10), 1); //brew
    struct::get_array("perk_vapor_altar")[3] movePerk((-2181,1639,115), (0,-60,0), 1); //soda

    thread spawn_shield((-2586,-78,20),(0,0,0),#"hash_603fdd2e4ae5b2b0");

    thread power_on();
    thread pack_on();
}

beach_Chests()
{
    chests = struct::get_array("treasure_chest_use", "targetname");
    i = 0;
    foreach(chest in chests)
    {
        if(chest.script_noteworthy == "beach_chest")
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
    level.start_chest_name = "beach_chest";
    level._zombiemode_custom_box_move_logic = &beach_box_logic;
}

beach_box_logic()
{
    old_chest = level.chests[level.chest_index].script_noteworthy;
    level.chests = array::randomize(level.chests);
    for(i = 0; i < level.chests.size; i++)
    {
        if(old_chest == level.chests[i].script_noteworthy)
            continue;
        if(level.chests[i].script_noteworthy == "dining_hall_chest")
        {
            level.chest_index = i;
            break;
        }
    }
}

setup_beach_spawnpoints()
{
    foreach(spawn in struct::get_array("initial_spawn", "script_noteworthy"))
    {
        spawn.origin = (-1763,868,-7);
        spawn.angles = (0,153,0);
    }
}

activate_zones_beach()
{
    level flag::wait_till("all_players_spawned");
    zm_zonemgr::enable_zone("beach");
}

disableBeachBarriers()
{
    foreach(barrier in getentarray("zombie_debris", "targetname"))
    {
        barrier.origin = (0,0,-10000);
    }
}

wunderwaffe_in_box()
{
    zm_weapons::include_zombie_weapon(#"hash_13a204ba6887b18f", 1);
    zm_weapons::include_zombie_weapon(#"hash_491ff8e9d1af03a8", 0);
    zm_weapons::add_zombie_weapon(#"hash_13a204ba6887b18f", #"hash_491ff8e9d1af03a8", 0, 0, undefined, undefined, 0, "", "special", 1, undefined, 1);
}