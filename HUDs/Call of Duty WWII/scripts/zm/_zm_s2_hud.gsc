#using scripts\codescripts\struct;

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

#using scripts\zm\_zm_weap_mad_minute;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

REGISTER_SYSTEM_EX( "zm_s2_hud", &__init__, &__main__, undefined )

function __init__()
{
    clientfield::register( "clientuimodel", "S2.Health", VERSION_SHIP, GetMinBitCountForNum( 200 ), "int" );
    clientfield::register( "clientuimodel", "S2.MuleKick", VERSION_SHIP, 1, "int" );
    clientfield::register( "clientuimodel", "S2.PerkSlots", VERSION_SHIP, GetMinBitCountForNum( 31 ), "int" );
}

function __main__()
{
    callback::on_spawned( &on_player_spawned );
}

function on_player_spawned()
{
	self thread player_health_monitor();
	self thread mule_kick_monitor();
	self thread perk_slots_monitor();
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
				if( !IS_EQUAL( self clientfield::get_player_uimodel( "S2.Health" ), self.health ) )
					self clientfield::set_player_uimodel( "S2.Health", self.health );
			}
			else
			{
				if( !IS_EQUAL( self clientfield::get_player_uimodel( "S2.Health" ), 0 ) )
					self clientfield::set_player_uimodel( "S2.Health", 0 );
			}
		}

		WAIT_SERVER_FRAME;
	}
}

function mule_kick_monitor()
{
    self endon( "bled_out" );
    self endon( "disconnect" );
    self endon( "spawned_player" );

	while( true )
	{
		if( isdefined( self ) )
		{
			if( zm_utility::is_player_valid( self ) && isdefined( self GetWeaponsListPrimaries()[2] ) )
			{
				current_weapon = self GetCurrentWeapon();

				if( IS_EQUAL( current_weapon, self GetWeaponsListPrimaries()[2] ) && !IS_EQUAL( current_weapon, level.zombie_powerup_weapon["minigun"] ) )
				{
					if( !IS_EQUAL( self clientfield::get_player_uimodel( "S2.MuleKick" ), 1 ) )
						self clientfield::set_player_uimodel( "S2.MuleKick", 1 );
				}
				else
				{
					if( !IS_EQUAL( self clientfield::get_player_uimodel( "S2.MuleKick" ), 0 ) )
						self clientfield::set_player_uimodel( "S2.MuleKick", 0 );
				}
			}
			else
			{
				if( !IS_EQUAL( self clientfield::get_player_uimodel( "S2.MuleKick" ), 0 ) )
					self clientfield::set_player_uimodel( "S2.MuleKick", 0 );
			}
		}

		WAIT_SERVER_FRAME;
	}
}

function perk_slots_monitor()
{
    self endon( "bled_out" );
    self endon( "disconnect" );
    self endon( "spawned_player" );

	while( true )
	{
		n_perk_limit = self zm_utility::get_player_perk_purchase_limit();

		if( isdefined( self ) && isdefined( n_perk_limit ) )
		{
			if( !IS_EQUAL( self clientfield::get_player_uimodel( "S2.PerkSlots" ), n_perk_limit ) )
			{
				if( n_perk_limit <= 31 ) // Set a max, people shouldn't exceed 31 perks...I hope
					self clientfield::set_player_uimodel( "S2.PerkSlots", n_perk_limit );
			}
		}

		WAIT_SERVER_FRAME;
	}
}
