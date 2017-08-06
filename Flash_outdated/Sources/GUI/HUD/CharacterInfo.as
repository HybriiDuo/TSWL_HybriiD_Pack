import com.Utils.Signal;
import com.Components.StatBar;
import com.Components.NameBox;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.DistributedValue;
import com.Utils.ID32;
import com.Utils.Format;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.GameInterface.Tooltip.*;
import com.GameInterface.Nametags;
import flash.filters.DropShadowFilter;


var BATTLERANK_RDB_ID:Number = 8141667;
var GRADE_NORMAL:Number = 0;
var GRADE_SWARM:Number = 1;
var GRADE_ELITE:Number = 2;

var m_Name:NameBox;
var m_HealthBar:MovieClip;
var m_LockIcon:MovieClip;
var m_NightmareBackground:MovieClip;

var SizeChanged:Signal;

var m_ShowName:Boolean = false;

var m_Dynel:Dynel;
var m_DropShwadow:DropShadowFilter;

var m_IsPlayer:Boolean;
var m_ShowBuffs:DistributedValue;

function Initialize()
{
	Nametags.SignalNametagAggroUpdated.Connect(SlotNametagAggroUpdated, this);
	if (m_IsPlayer)
	{
		m_ShowBuffs = DistributedValue.Create( "ShowBuffsOnSelf" );
	}
	else
	{
		m_ShowBuffs = DistributedValue.Create( "ShowBuffsOnTarget" );
		m_NightmareBackground = attachMovie("NightmareBackground", "m_NightmareBackground", getNextHighestDepth());
		m_NightmareBackground._visible = false;
	}
	m_ShowBuffs.SignalChanged.Connect( SlotShowBuffsChanged, this);
	
	SizeChanged = new Signal();
    
    m_DropShwadow = new DropShadowFilter(1, 45, 0x000000, 100, 3, 3, 2, 10, false, false, false);

	var y:Number = 0;
	
	if (m_ShowName)
	{
		m_Name = attachMovie("NameBox", "name", getNextHighestDepth());
        m_Name._y = 10;
        m_Name._x = 0;

        y += 33;
	}
	           
	m_HealthBar = attachMovie("HealthBar2", "health", getNextHighestDepth()); 
    m_HealthBar.SetTextType( com.Components.HealthBar.STATTEXT_NUMBER );
    m_HealthBar.SetBarScale(100, 85, 70, 100);
    m_HealthBar.Show();
	m_HealthBar._x = 0;
	m_HealthBar._y = y;
	//m_HealthBar.Init(_global.Enums.Stat.e_Health, _global.Enums.Stat.e_Life, true);
	//m_HealthBar.SetFadeWhenInactive(false);
	
	if(Boolean(m_ShowBuffs.GetValue()))
	{
		AddBuffDisplay();
	}
}

function LayoutNightmareBackground()
{
	if (m_NightmareBackground == undefined || m_HealthBar == undefined)
	{
		return;
	}
	
	var HasPink:Boolean = m_Dynel.GetStat(_global.Enums.Stat.e_CurrentPinkShield, 2) != 0;
	var HasBlue:Boolean = m_Dynel.GetStat(_global.Enums.Stat.e_CurrentBlueShield, 2) != 0;
	var HasRed:Boolean = m_Dynel.GetStat(_global.Enums.Stat.e_CurrentRedShield, 2) != 0;
	
	var HasDamageType:Boolean = m_Dynel.GetStat(_global.Enums.Stat.e_ColorCodedDamageType, 2) != 0;
	var HasTwoShields:Boolean = (HasPink && HasBlue) ||
								(HasPink && HasRed) ||
								(HasBlue && HasRed);
	var HasThreeShields:Boolean = HasPink && HasBlue && HasRed;
	
	m_NightmareBackground._y = -10;
	m_NightmareBackground._x = -10
	m_NightmareBackground._height = 160;
	m_NightmareBackground._width = m_HealthBar.m_ShieldBar._width + 15;
	
	if (HasDamageType)
	{
		m_NightmareBackground._x += m_HealthBar.m_AegisDamageType._x + 5
		m_NightmareBackground._width -= m_HealthBar.m_AegisDamageType._x + 5;
	}
	
	if (HasTwoShields)
	{
		m_NightmareBackground._width += m_HealthBar.m_SecondShield._width + 10;
	}
	if (HasThreeShields)
	{
		m_NightmareBackground._width += m_HealthBar.m_ThirdShield._width + 5;
	}
}

function SlotShowBuffsChanged()
{
	if (Boolean(m_ShowBuffs.GetValue()))
	{
		AddBuffDisplay();
		if (m_Dynel != undefined)
		{
			m_Buffs.SetCharacter(Character.GetCharacter(m_Dynel.GetID()));
		}
	}
	else
	{
		if (m_Buffs != undefined)
		{
			removeMovieClip(m_Buffs);
		}
	}
}

function AddBuffDisplay()
{
	if (m_Buffs != undefined)
	{
		m_Buffs.removeMovieClip();
		m_Buffs = undefined;
	}
	m_Buffs = attachMovie("Buffs", "buffs", getNextHighestDepth());
	m_Buffs.SetMaxPerLine(4);
	if (m_IsPlayer) { m_Buffs._y = 0; }
	else { m_Buffs._y = 7; }
	m_Buffs._xscale = 80;
	m_Buffs._yscale = 80;
	m_Buffs.SetWidth(_width * (100/80));
	m_Buffs.SizeChanged.Connect(SlotBuffSizeChanged, this);
}

function SetDynel(dynel:Dynel)
{    
	if (m_Dynel != undefined)
	{
		m_Dynel.SignalLockedToTarget.Disconnect(SlotLockedToTarget, this);
	}
	
	m_Dynel = dynel;
	
	if (m_Name != undefined)
	{
		m_Name._x = 0;
		if (m_Dynel == undefined || 
		   (m_Dynel.GetID().GetType() != _global.Enums.TypeID.e_Type_GC_Character && 
			m_Dynel.GetID().GetType() != _global.Enums.TypeID.e_Type_GC_Destructible))
		{
			m_Name.m_Text.text = "";
			m_Name._visible = false;
		}
		else
		{
			m_Name.m_Text.text = m_Dynel.GetName();
			m_Name._visible = true;
		}
	}
	
	if (m_NightmareBackground != undefined)
	{
		m_NightmareBackground._visible = false;
	}
	
	if (m_MonsterBand != undefined)
	{
		m_MonsterBand.removeMovieClip();
		m_MonsterBand = undefined;
	}
	
	if (m_TooltipCatcher != undefined)
	{
		m_TooltipCatcher.removeMovieClip();
		m_TooltipCatcher = undefined;
	}
 	
	m_HealthBar.SetDynel(m_Dynel);
	
	var character:Character = undefined;

    if ( m_Dynel != undefined && m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_Character )
    {
        character = Character.GetCharacter(m_Dynel.GetID());
        
        if ( character != undefined)
        {			
			if (character.IsNPC())
			{
				UpdateConsiderSystem();
			}
        }
    }
	if (m_Buffs != undefined)
	{
		m_Buffs.SetCharacter(character);
	}
	
	if (m_Dynel != undefined)
	{
		m_Dynel.SignalLockedToTarget.Connect(SlotLockedToTarget, this);
		SlotLockedToTarget(m_Dynel.GetLockedTo());
	}
	else
	{
		RemoveLockIcon();
	}
	LayoutNightmareBackground();
}

function UpdateConsiderSystem()
{
	var character:Character = Character.GetCharacter(m_Dynel.GetID());
	if (character.IsNPC() && Nametags.GetAggroStanding(m_Dynel.GetID()) != _global.Enums.Standing.e_StandingFriend)
	{
		var bandNumber:Number = character.GetStat( _global.Enums.Stat.e_Band );
		if (m_Name != undefined)
		{
			m_Name.m_Text.text =  bandNumber + " - " + m_Dynel.GetName();
		}
	}

	return; // We don't want to rest of the con system visible for players.
	{
		var iconName:String = "";
		var conString:String = LDBFormat.LDBGetText("GenericGUI", "Con_Analysis") + "\n";
		var aggroStanding:Number = Nametags.GetAggroStanding(m_Dynel.GetID());
		switch(aggroStanding)
		{
			case _global.Enums.Standing.e_StandingFriend:
				conString += LDBFormat.LDBGetText("GenericGUI", "Con_Friendly") + "\n"
				break;
			case _global.Enums.Standing.e_StandingNeutral:
				conString += LDBFormat.LDBGetText("GenericGUI", "Con_Passive") + "\n"
				break;
			case _global.Enums.Standing.e_StandingEnemy:
				conString += LDBFormat.LDBGetText("GenericGUI", "Con_Aggressive") + "\n"
				break;
			default:
				conString += LDBFormat.LDBGetText("GenericGUI", "Con_Aggressive") + "\n"
		}
		
		conString += LDBFormat.LDBGetText("GenericGUI", "Con_Rank") + " " + bandNumber + "\n";
		
		var powerDiff:Number = GetPowerDifference();
		if (powerDiff <= -9){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Trivial") + "\n"; }
		else if (powerDiff <= -5){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Easy") + "\n"; }
		else if (powerDiff <= 4){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Even") + "\n"; }
		else if (powerDiff <= 8){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Challenging") + "\n"; }
		else if (powerDiff <= 12){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Demanding") + "\n"; }
		if (powerDiff >= 13){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Devastating") + "\n"; }
		
		var encounterType:Number = character.GetStat(_global.Enums.Stat.e_EncounterType);
		var gradeType:Number = character.GetStat( _global.Enums.Stat.e_GradeType );
		var isBoss:Boolean = character.IsBoss();
		var isLieutenant = character.IsQuestTarget();
		var isSmallGroup:Boolean = (encounterType == _global.Enums.EncounterType.e_EncounterType_SmallGroup);
		var isGroup:Boolean =  (encounterType == _global.Enums.EncounterType.e_EncounterType_Group);
		var isRaid:Boolean = (encounterType == _global.Enums.EncounterType.e_EncounterType_Raid);
		var isSwarm:Boolean = (gradeType == GRADE_SWARM);
		var isElite:Boolean = (gradeType == GRADE_ELITE);
		var isRare:Boolean = character.IsRare();
		var isNightmare:Boolean = (character.GetStat(_global.Enums.Stat.e_IsANightmareMob) != 0);
		
		if (isNightmare)
		{
			conString += LDBFormat.LDBGetText("GenericGUI", "Con_Nightmare") + "\n";
			m_NightmareBackground._visible = true;
		}
		
		if(character.IsMerchant())
		{
			iconName = "VendorIcon";
		}
		else if(character.IsBanker())
		{
			iconName = "TradepostIcon";
		}
		else
		{
			if (isBoss)
			{
				iconName = (isRare) ? "MT_RareBoss" : "MT_Boss";
				conString += LDBFormat.LDBGetText("GenericGUI", "Con_Boss") + "\n";
				if (isSmallGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_SmallGroup") + "\n"; }
				else if (isGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Group") + "\n"; }
				else if (isRaid){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Raid") + "\n"; }
				else{ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Solo") + "\n"; }
			}
			else if (isLieutenant)
			{
				iconName = "MT_Lieutenant";
				conString += LDBFormat.LDBGetText("GenericGUI", "Con_Lieutenant") + "\n";
				if (isSmallGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_SmallGroup") + "\n"; }
				else if (isGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Group") + "\n"; }
				else if (isRaid){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Raid") + "\n"; }
				else{ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Solo") + "\n"; }
			}
			else
			{
				if (isElite)
				{
					iconName = "MT_Elite";
					conString += LDBFormat.LDBGetText("GenericGUI", "Con_Elite") + "\n";
					if (isSmallGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_SmallGroup") + "\n"; }
					else if (isGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Group") + "\n"; }
					else if (isRaid){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Raid") + "\n"; }
					else{ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Solo") + "\n"; }
				}
				else if (isSwarm)
				{
					iconName = "MT_Swarm";
					conString += LDBFormat.LDBGetText("GenericGUI", "Con_Swarm") + "\n";
					if (isSmallGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_SmallGroup") + "\n"; }
					else if (isGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Group") + "\n"; }
					else if (isRaid){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Raid") + "\n"; }
					else{ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Solo") + "\n"; }
				}
				else
				{
					iconName = "MT_Normal";
					conString += LDBFormat.LDBGetText("GenericGUI", "Con_Control") + "\n";
					if (isSmallGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_SmallGroup") + "\n"; }
					else if (isGroup){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Group") + "\n"; }
					else if (isRaid){ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Raid") + "\n"; }
					else{ conString += LDBFormat.LDBGetText("GenericGUI", "Con_Solo") + "\n"; }
				}
			}
		}
		if (iconName != "")
		{
			if (m_MonsterBand != undefined)
			{
				m_MonsterBand.removeMovieClip();
				m_MonsterBand = undefined;
				m_Name._x = 0;
			}
			m_MonsterBand = attachMovie(iconName, "m_MonsterBand", getNextHighestDepth());
			UpdateNametagGroupSize(encounterType);
			UpdateNametagMonsterbandColor();
			m_MonsterBand._xscale = 40;
			m_MonsterBand._yscale = 40;
			m_MonsterBand._y = m_Name._y + 7;
			
			if (m_LockIcon != undefined)
			{
				m_MonsterBand._x = m_LockIcon._x + m_LockIcon._width + 5;
				m_Name._x = m_LockIcon._x + m_LockIcon._width + 5 + (encounterType > _global.Enums.EncounterType.e_EncounterType_SmallGroup) ? 25 : 10;
			}
			else
			{
				m_MonsterBand._x = (encounterType > _global.Enums.EncounterType.e_EncounterType_SmallGroup) ? 7.5 : 0;
				m_Name._x += (encounterType > _global.Enums.EncounterType.e_EncounterType_SmallGroup) ? 25 : 10;
			}
			
			if (m_TooltipCatcher != undefined)
			{
				m_TooltipCatcher.removeMovieClip();
				m_TooltipCatcher = undefined;
			}
			m_TooltipCatcher = attachMovie("TooltipCatcher", "m_TooltipCatcher", getNextHighestDepth());
			m_TooltipCatcher._x = 0;
			m_TooltipCatcher._y = m_MonsterBand._y;
			m_TooltipCatcher._width = m_HealthBar.m_Bar._width;
			m_TooltipCatcher._height = m_MonsterBand._height + m_HealthBar._height;
			
			TooltipUtils.AddTextTooltip(m_TooltipCatcher, conString, 250, TooltipInterface.e_OrientationHorizontal, true, true);
		}
	}
}

function GetPowerDifference()
{
	var monsterBand:Number = m_Dynel.GetStat(_global.Enums.Stat.e_Band);
	var playerBand:Number = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_PowerRank);
	return (monsterBand - playerBand);
}

function UpdateNametagMonsterbandColor()
{
	if (m_MonsterBand != undefined && m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_Character)
	{
		character = Character.GetCharacter(m_Dynel.GetID());
		if (character != undefined && character.IsNPC())
		{
			var bandColor:Number = 0xFFFFFF;
			if (m_Dynel.GetNametagCategory() == _global.Enums.NametagCategory.e_NameTagCategory_FriendlyNPC || m_NametagCategory == _global.Enums.NametagCategory.e_NameTagCategory_FriendlyPlayer)
			{
				bandColor = Colors.GetNametagColor(m_NametagCategory, m_AggroStanding);
			}
			else
			{
				bandColor = Colors.GetNametagIconColor(GetPowerDifference());
			}
			Colors.ApplyColor(m_MonsterBand, bandColor);
			Colors.ApplyColor(m_MonsterBand.m_GroupSize.m_Top, bandColor);
			Colors.ApplyColor(m_MonsterBand.m_GroupSize.m_Bottom, bandColor);
		}
	}
}

function UpdateNametagGroupSize(encounterType:Number)
{
	m_MonsterBand.m_GroupSize.m_Top._visible = false;
	m_MonsterBand.m_GroupSize.m_Bottom._visible = false;
	
	switch(encounterType)
	{
		case _global.Enums.EncounterType.e_EncounterType_SmallGroup:
			m_MonsterBand.m_GroupSize.m_Top._visible = true;
			break;
		case _global.Enums.EncounterType.e_EncounterType_Group:
			m_MonsterBand.m_GroupSize.m_Bottom._visible = true;
			break;
		case _global.Enums.EncounterType.e_EncounterType_Raid:
			m_MonsterBand.m_GroupSize.m_Top._visible = true;
			m_MonsterBand.m_GroupSize.m_Bottom._visible = true;
			break;
	}
}

function RemoveLockIcon()
{
	if (m_LockIcon != undefined)
	{
		var encounterType:Number = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_EncounterType);
		m_MonsterBand._x = (encounterType > _global.Enums.EncounterType.e_EncounterType_SmallGroup) ? 7.5 : 0;
		m_Name._x = (encounterType > _global.Enums.EncounterType.e_EncounterType_SmallGroup) ? 25 : 10;
		m_LockIcon.removeMovieClip();
		m_LockIcon = undefined;
	}
}

function SlotLockedToTarget(targetID:ID32)
{
	var clientCharacter:Character = Character.GetClientCharacter();
	if (targetID == undefined || targetID.IsNull() || targetID.Equal(clientCharacter.GetID()) || targetID.Equal(TeamInterface.GetClientTeamID()) || targetID.Equal(TeamInterface.GetClientRaidID()))
	{
		RemoveLockIcon();		
	}
	else
	{
		RemoveLockIcon();
		m_LockIcon = attachMovie("LockIcon", "m_LockIcon", getNextHighestDepth());
		m_LockIcon._x = 0;
		m_LockIcon._y = m_Name._y;
		
		m_MonsterBand._x = m_LockIcon._x + m_LockIcon._width + 5;
		var encounterType:Number = clientCharacter.GetStat(_global.Enums.Stat.e_EncounterType);
		m_Name._x = m_LockIcon._x + m_LockIcon._width + 5 + (encounterType > _global.Enums.EncounterType.e_EncounterType_SmallGroup) ? 25 : 10;
	}
}

function ShowName(show:Boolean)
{
	m_ShowName = show;
}

function SlotBuffSizeChanged()
{
	SizeChanged.Emit();
}

function SlotNametagAggroUpdated(characterID:ID32, aggroStatus:Number)
{
	if (characterID.Equal(m_Dynel.GetID()))
	{
		UpdateConsiderSystem();
	}
}
