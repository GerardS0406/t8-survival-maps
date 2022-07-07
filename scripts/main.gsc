init()
{
    //gametype started

    // example of shorthand struct initialization
    level.tutorial = 
    {
        #hello: "hello world!",
        #var: "Skipped!",
        #arrayShorthand: [#"hashkey":"value 1", 1:"value 2", 2:"value 3"],
        #arrayVariadic: array("value 1", "value 2", "value 3")
    };
    
}

onPlayerConnect()
{
    //connected
    self thread waitForNotify();
}

waitForNotify()
{
    self endon(#"disconnect");
    while(true)
    {
        result = self waittill(#"example notify");
        if(!isdefined(result.action)) continue;
        if(result.action == #"killround")
        {
            level.zombie_total = 0;
            foreach(ai in getaiteamarray(level.zombie_team)) ai kill();
            self iprintln(level.tutorial.var);
        }
    }
}

onPlayerSpawned()
{
    // notice how endon now takes variadic parameters
    self endon(#"disconnect", #"spawned_player");
    level endon(#"end_game", #"game_ended");
    //self thread InfiniteAmmo();
    //self thread currentZone();

    //self thread exo_suit();
    
    
    while(1)
    {
        if(self meleeButtonPressed())
        {
            //iprintln("====== POSITION ======");
            //self iprintln("Origin = " + self.origin);
            //self iprintln("Angles = " + self GetPlayerAngles());
            while(self meleeButtonPressed()) waitframe(1);
            self thread give_me_weapons();
            //thread unlockallcamosforgun1();
        }

        if(self.score < 10000) self.score = 10000;
        //self freezeControls(false);
        //self enableInvulnerability();
        //self setclientuivisibilityflag("hud_visible", 0);
        //self.lastslidestarttime = 0;

        // waits a single frame
        waitframe(1);
    }
}

give_me_weapons()
{
    IPrintLn("giving weapons");
    foreach(weapon in level.zombie_weapons)
    {
        IPrintLn("" + weapon.weapon.name);
        self zm_weapons::weapon_give(weapon.weapon);
        wait 2;
    }
}

unlockallcamosforgun1()
{
    foreach(weapon in level.zombie_weapons)
    {
        if(isdefined(weapon.weapon.name))
        {
            self addweaponstat(weapon.weapon, #"kills", 5000 );
            self addweaponstat(weapon.weapon, #"headshots", 5000 );
            self addweaponstat(weapon.weapon, #"hash_e2912dd096cfdc9", 5000 );
            self addweaponstat(weapon.weapon, #"hash_39ab7cda18fd5c74", 5000 );
            self addweaponstat(weapon.weapon, #"hash_5bc2650d1682f530", 5000 );
            self addweaponstat(weapon.weapon, #"hash_7c40f14330df4e0b", 5000 );
            self addweaponstat(weapon.weapon, #"hash_3b3dff9287f4dda9", 5000 );
            self addweaponstat(weapon.weapon, #"hash_1469d727cf2ce4db", 5000 );
            self addweaponstat(weapon.weapon, #"hash_b7261a853cfb61c", 5000 );
            self addweaponstat(weapon.weapon, #"hash_289883e2f7a6af52", 5000 );
            self addweaponstat(weapon.weapon, #"instakills", 5000 );
            self addweaponstat(weapon.weapon, #"hash_657e22dcdd18da77", 5000 );
            self addweaponstat(weapon.weapon, #"killstreak_5_attachment", 5000 );
            iprintln("Camo Unlocked");
            waitframe(1);
        }
    }
}

exo_suit()
{
    level endon(#"end_game");
    self endon(#"death", #"spawned_player");

    self.sprint_boost = 0;
	self.jump_boost = 0;
    self.slam_boost = 0;
	while(1)
	{
		if( !self IsOnGround() )
		{
			if(self JumpButtonPressed() || self SprintButtonPressed() || self StanceButtonPressed())
			{
				waitframe(1);
				continue;
			}
			self.sprint_boost = 0;
			self.jump_boost = 0;
            self.slam_boost = 0;
			while( !self IsOnGround() )
			{
				if( self JumpButtonPressed() && self.jump_boost < 1 )
				{
					self.is_flying_jetpack = true;
					self.jump_boost++;
					angles = self getplayerangles();
					angles = (0,angles[1],0);
					
					self.loop_value = 1;
					
					if( IsDefined(self.loop_value))
					{
						Earthquake( 0.22, .9, self.origin, 850 );
						direction = AnglesToUp(angles) * 400;
						self thread land();
						for(l = 0; l < self.loop_value; l++)
						{
							self SetVelocity( (self GetVelocity()[0], self GetVelocity()[1], 0) + direction );
							wait .1;
						}
					}
				}
				if( self SprintButtonPressed() && self.sprint_boost < 1 )
				{
					self.is_flying_jetpack = true;
					self.sprint_boost++;
					xvelo = self GetVelocity()[0];
                    yvelo = self GetVelocity()[1];
                    l = Length((xvelo, yvelo, 0));
                    if(l < 10)
                        continue;
                    if(l < 190)
                    {
                        xvelo = int(xvelo * 190/l);
                        yvelo = int(yvelo * 190/l);
                    }
					
					self.loop_value = 1;
					
					if( IsDefined(self.loop_value))
					{
						Earthquake( 0.22, .9, self.origin, 850 );
						if(self.jump_boost == 1)
							boostAmount = 1.75;
						else
							boostAmount = 2.25;
						self thread land();
						self SetVelocity( (xvelo * boostAmount, yvelo * boostAmount, self GetVelocity()[2]) );
					}
					while( !self isOnGround() )
						waitframe(1);
				}
                if( self StanceButtonPressed() && self.jump_boost > 0 && self.slam_boost < 1)
                {
                    self.slam_boost++;
                    self SetVelocity((self GetVelocity()[0], self GetVelocity()[1], -200));
                    self thread land();
                }
			    waitframe(1);
			}
            if(self.slam_boost > 0)
            {
                radiusdamage( self.origin, 200, 3000, 500, self, "MOD_GRENADE_SPLASH" );
                self playsound( #"wpn_grenade_explode" );
	            self clientfield::increment("" + #"hash_7b8ad0ed3ef67813");
            }
		}
	    waitframe(1);
	}
}

land()
{
	while( !self IsOnGround() )
		waitframe(1);
	self.is_flying_jetpack = false;
}

currentZone()
{
    self endon(#"death");
    level endon(#"end_game");
    currentzone = "";
    while(1)
    {
        if(!isdefined(self.zone_name))
        {
            wait 2;
            continue;
        }
        if(currentzone != self.zone_name)
        {
            currentzone = self.zone_name;
            self iprintln("Zone: " + self.zone_name);
        }
        wait 2;
    }
}

InfiniteAmmo()
{
    self endon(#"spawned_player", #"disconnect");
    level endon(#"end_game", #"game_ended");    
    while(true)
    {
        weapon  = self GetCurrentWeapon();
        offhand = self GetCurrentOffhand();
        if(!(!isdefined(weapon) || weapon === level.weaponNone || !isdefined(weapon.clipSize) || weapon.clipSize < 1))
        {
            self SetWeaponAmmoClip(weapon, 1337);
            self givemaxammo(weapon);
            self givemaxammo(offhand);
            self gadgetpowerset(2, 100);
            self gadgetpowerset(1, 100);
            self gadgetpowerset(0, 100);
        }
        if(isdefined(offhand) && offhand !== level.weaponNone) self givemaxammo(offhand);

        // waittill now returns a variable
        result = self waittill(#"weapon_fired", #"grenade_fire", #"missile_fire", #"weapon_change", #"melee");
    }
}