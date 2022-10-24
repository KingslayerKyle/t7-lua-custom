#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#precache( "lui_menu_data", "csgo_first_weapon" );
#precache( "lui_menu_data", "csgo_first_weapon_aat" );
#precache( "lui_menu_data", "csgo_second_weapon" );
#precache( "lui_menu_data", "csgo_second_weapon_aat" );
#precache( "lui_menu_data", "csgo_third_weapon" );
#precache( "lui_menu_data", "csgo_third_weapon_aat" );
#precache( "lui_menu_data", "csgo_zone_name" );

REGISTER_SYSTEM_EX( "zm_csgo_hud", &__init__, &__main__, undefined )

function __init__()
{
    clientfield::register( "clientuimodel", "CSGO.Health", VERSION_SHIP, GetMinBitCountForNum( 200 ), "int" );
}

function __main__()
{
    callback::on_spawned( &on_player_spawned );
}

function on_player_spawned()
{
	self thread player_health_monitor();
	self thread weapons_aats_monitor();
	self thread zone_name_monitor();
}

function player_health_monitor()
{
    self endon( "bled_out" );
    self endon( "disconnect" );
    self endon( "spawned_player" );
    
	while( true )
	{
		if( isdefined( self ) )
		{
			if( zm_utility::is_player_valid( self ) )
			{
				if( !IS_EQUAL( self clientfield::get_player_uimodel( "CSGO.Health" ), self.health ) )
					self clientfield::set_player_uimodel( "CSGO.Health", self.health );
			}
			else
			{
				if( !IS_EQUAL( self clientfield::get_player_uimodel( "CSGO.Health" ), 0 ) )
					self clientfield::set_player_uimodel( "CSGO.Health", 0 );
			}
		}

		WAIT_SERVER_FRAME;
	}
}

function weapons_aats_monitor()
{
    self endon( "bled_out" );
    self endon( "disconnect" );
    self endon( "spawned_player" );

	self waittill( "weapon_change_complete" ); // Wait until the player has a weapon before we begin the loop

	weapons = array( [], [], [] );
	weapons[0]["weapon_model"] = "csgo_first_weapon";
	weapons[1]["weapon_model"] = "csgo_second_weapon";
	weapons[2]["weapon_model"] = "csgo_third_weapon";

	while( true )
	{
		if( isdefined( self ) )
		{
			for( i = 0; i < weapons.size; i++ )
			{
				weapons[i]["aat_model"] = weapons[i]["weapon_model"] + "_aat";

				if( isdefined( self GetWeaponsListPrimaries()[i] ) )
				{
					weapons[i]["weapon"] = self GetWeaponsListPrimaries()[i];

					if( IS_EQUAL( weapons[i]["weapon"], level.zombie_powerup_weapon["minigun"] ) )
					{
						if( !IS_EQUAL( self GetControllerUIModelValue( weapons[i]["weapon_model"] ), "none" ) )
							self SetControllerUIModelValue( weapons[i]["weapon_model"], "none" );

						if( !IS_EQUAL( self GetControllerUIModelValue( weapons[i]["aat_model"] ), "none" ) )
							self SetControllerUIModelValue( weapons[i]["aat_model"], "none" );

						continue;
					}

					weapons[i]["aat"] = ( isdefined( self aat::getAATOnWeapon( weapons[i]["weapon"] ) ) ? self aat::getAATOnWeapon( weapons[i]["weapon"] ).name : "none" );

					if( !IS_EQUAL( self GetControllerUIModelValue( weapons[i]["weapon_model"] ), weapons[i]["weapon"].name ) )
						self SetControllerUIModelValue( weapons[i]["weapon_model"], weapons[i]["weapon"].name );

					if( !IS_EQUAL( self GetControllerUIModelValue( weapons[i]["aat_model"] ), weapons[i]["aat"] ) )
						self SetControllerUIModelValue( weapons[i]["aat_model"], weapons[i]["aat"] );
				}
				else
				{
					if( !IS_EQUAL( self GetControllerUIModelValue( weapons[i]["weapon_model"] ), "none" ) )
						self SetControllerUIModelValue( weapons[i]["weapon_model"], "none" );

					if( !IS_EQUAL( self GetControllerUIModelValue( weapons[i]["aat_model"] ), "none" ) )
						self SetControllerUIModelValue( weapons[i]["aat_model"], "none" );
				}
			}
		}

		WAIT_SERVER_FRAME;
	}
}

function zone_name_monitor()
{
    self endon( "bled_out" );
    self endon( "disconnect" );
    self endon( "spawned_player" );

	self waittill( "weapon_change_complete" ); // Wait until the player has a weapon before we begin the loop

	while( true )
	{
		if( isdefined( self ) )
		{
			if( isdefined( GetEnt( self zm_utility::get_current_zone(), "targetname" ).script_string ) )
			{
				if( !IS_EQUAL( self GetControllerUIModelValue( "csgo_zone_name" ), GetEnt( self zm_utility::get_current_zone(), "targetname" ).script_string ) )
					self SetControllerUIModelValue( "csgo_zone_name", GetEnt( self zm_utility::get_current_zone(), "targetname" ).script_string );
			}
			else
			{
				if( !IS_EQUAL( self GetControllerUIModelValue( "csgo_zone_name" ), "none" ) )
					self SetControllerUIModelValue( "csgo_zone_name", "none" );
			}
		}

		WAIT_SERVER_FRAME;
	}
}
