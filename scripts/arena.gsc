arena_main()
{
    chests = struct::get_array("treasure_chest_use", "targetname");
    i = 0;
    foreach(chest in chests)
    {
        if(i==0)
        {
            chest.start_exclude = 0;
            chest.no_fly_away = 1;
            chest moveChest((642,213,27),(0,105,0));
        }
        else
        {
            chest.start_exclude = 1;
        }
        i++;
    }

    thread scorp_in_box();

    foreach(challenge in getentarray("t_zm_towers_cleat_damage_trig", "script_noteworthy"))
    {
        challenge.origin = (0,0,-10000);
    }

    doors = getEntArray("zombie_door", "targetname");
    foreach(door in doors)
        door.origin = (0,0,-10000);

    struct::get_array("perk_vapor_altar")[1] movePerk((548.389,403.645,32.125), (0,215,0),1); //Odin
    struct::get_array("perk_vapor_altar")[3] movePerk((-538, 397, 32.5595), (0,325,0),1); //Ra
    struct::get_array("perk_vapor_altar")[2] movePerk((-545,-401,32.2005), (0,25,0),1); //Danu
    struct::get_array("perk_vapor_altar")[0] movePerk((540,-397,30.3028), (0,145,0),1); //Zeus
    movepap((-637, -210, 32),(0,105,0),1);

    thread spawn_shield((0,18,100),(0,90,0),#"hash_243cd42eb1bd6e10");

    thread arena_pap();
}

scorp_in_box()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    foreach(weapon in level.zombie_weapons)
    {
        if(weapon.weapon.name == #"hash_5aa162d2872d2bac")
        {
            weapon.is_in_box = 1;
        }
    }
}

arena_pap()
{
    level flag::wait_till("all_players_spawned");
    level flag::wait_till("initial_blackscreen_passed");
    level flag::set("zm_towers_pap_quest_completed");
}