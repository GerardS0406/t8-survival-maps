dininghall_main()
{
    setup_dining_spawnpoints();
    thread activate_zones_dining();
    disableDiningBarriers();

    thread dining_Chests();

    thread krakens_in_box();

    struct::get_array("perk_vapor_altar")[0] movePerk((575,-1375,1056), (0,90,0), 1);
    struct::get_array("perk_vapor_altar")[2] movePerk((-600,-15,1056), (0,0,0), 1);
    struct::get_array("perk_vapor_altar")[3] movePerk((-190,-1385,1056), (0,90,0), 1);

    movepap((610,-529,1056), (0,180,0) + (0,90,0), 1);

    thread spawn_shield((147,-1385,1056),(0,45,0),#"hash_3a1959bb039f2be3");

    thread pack_on();
}

dining_Chests()
{
    chests = struct::get_array("treasure_chest_use", "targetname");
    i = 0;
    foreach(chest in chests)
    {
        if(chest.script_noteworthy == "dining_hall_chest")
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
    level.start_chest_name = "dining_hall_chest";
    level._zombiemode_custom_box_move_logic = &dining_box_logic;
}

krakens_in_box()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    foreach(weapon in level.zombie_weapons)
    {
        if(weapon.weapon.name == #"hash_7d7f0dbb00201240" || weapon.weapon.name == #"hash_95dd69e40d99560" || weapon.weapon.name == #"hash_539f784146391d2" || weapon.weapon.name == #"hash_5004e2171c2be97d")
        {
            weapon.is_in_box = 1;
        }
    }
}

dining_box_logic()
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

setup_dining_spawnpoints()
{
    foreach(spawn in struct::get_array("initial_spawn", "script_noteworthy"))
    {
        spawn.origin = (-284,-1119,1056);
        spawn.angles = (0,66,0);
    }
}

activate_zones_dining()
{
    level flag::wait_till("all_players_spawned");
    zm_zonemgr::enable_zone("zone_galley");
    zm_zonemgr::enable_zone("zone_dining_hall_aft");
    zm_zonemgr::enable_zone("zone_dining_hall_fore");
}

disableDiningBarriers()
{
    foreach(barrier in getentarray("zombie_door", "targetname"))
    {
        if(barrier.origin == (-189,-1413,1110) || barrier.origin == (-126,507,1102) || barrier.origin == (127,512,1104) || barrier.origin == (190,-1407,1105))
        {
            barrier.origin = (0,0,-10000);
        }
    }
}