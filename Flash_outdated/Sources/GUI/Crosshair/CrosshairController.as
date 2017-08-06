import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Character;
import com.GameInterface.ProjectUtils;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;

var m_ReticuleClip:MovieClip;
var m_UseBox:MovieClip;
var m_HadEnemy:Boolean;
var m_Dynel:Dynel;
var m_DistanceCheckInterval:Number;
var m_InCombat:Boolean;
var m_Character:Character;

var m_CrosshairTypeMonitor:DistributedValue;

var NOTARGETFIRSTFRAME:Number = 1;
var NOTARGETFINALFRAME:Number = 10;
var TARGETFIRSTFRAME:Number = 11;
var TARGETFINALFRAME:Number = 20;
var OFFTARGETFIRSTFRAME:Number = 21;
var OFFTARGETFINALFRAME:Number = 30;
var MISSIONFRIENDLYFIRSTFRAME:Number = 31;
var MISSIONFRIENDLYFINALFRAME:Number = 40;
var DYNELFIRSTFRAME:Number = 41;
var DYNELFINALFRAME:Number = 50;

var ANIMATIONDURATION:Number = 0.1;
var DYNELACTIONDISTANCE:Number = 2.5;
var DYNELDISPLAYDISTANCE:Number; // = 10; // Used to determine when the icon should display that you have a friendly NPC or 

function onLoad()
{
	DYNELDISPLAYDISTANCE = com.GameInterface.Utils.GetGameTweak("ReticuleFlashDynelDisplayDistance");
	m_HadEnemy = false;
	m_InCombat = false;
	m_Dynel = undefined;
	
	m_ReticuleClip = this.attachMovie("Final_All_States", "Final_All_States", this.getNextHighestDepth());
	
	m_UseBox = this.attachMovie("Final_Frame", "Final_Frame", this.getNextHighestDepth());
	m_UseBox.UseBoxHotKey.text = "<variable name='hotkey:ActionModeTargeting_Use'/>";
	m_UseBox._alpha = 0;

	m_UseBox.UseBoxAction.text = "";
	m_UseBox.UseBoxName.text = "";
	
	m_ReticuleClip.gotoAndStop(NOTARGETFINALFRAME);
	
	// ActionMode_Targeting.cpp
	com.Utils.GlobalSignal.SignalCrosshairTargetUpdated.Connect(SlotCrosshairTargetUpdated, this);
	
	Character.GetClientCharacter().SignalToggleCombat.Connect(SlotToggleCombat, this);
	Character.GetClientCharacter().SignalCharacterTeleported.Connect(SlotCharacterTeleported, this);
	
	
	m_DistanceCheckInterval = setInterval(DistanceCheck, 100);
	
	m_Character = Character.GetClientCharacter();

	m_CrosshairTypeMonitor = DistributedValue.Create("CrosshairType");
	m_CrosshairTypeMonitor.SignalChanged.Connect(SlotCrosshairTypeChanged, this);

	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	
	Layout();
}

function SlotSetGUIEditMode(edit:Boolean)
{
	if (!edit)
	{
		Layout(); //Just to get the new values in
	}
}

function SlotCrosshairTypeChanged()
{
	Layout();
}

function SlotCharacterTeleported()
{
	SlotToggleCombat(false);
}

function SlotToggleCombat(IsInCombat:Boolean)
{
	m_InCombat = IsInCombat;
	
	if (m_InCombat && m_Dynel == undefined)
	{
		m_ReticuleClip.gotoAndStop(OFFTARGETFINALFRAME);
	}
	else if (!m_IsInCombat && m_Dynel == undefined)
	{
		m_ReticuleClip.gotoAndStop(NOTARGETFIRSTFRAME);
	}
	
	if (m_InCombat)
	{
		m_UseBox._alpha = 0;
	}
}


function DistanceCheck() // Interval
{
	m_UseBox.tweenEnd();
	if (m_Dynel == undefined || m_InCombat)
	{
		if (m_UseBox._alpha != 0)
		{
			m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha:0});
		}
		return;
	}
	
	
	var useBoxAlpha:Number = (m_Dynel.GetDistanceToPlayer() > DYNELACTIONDISTANCE || m_Dynel.IsEnemy()) ? 0 : 100;

	if (useBoxAlpha != 0)
	{
		if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_Character)
		{
			var character:Character = Character.GetCharacter(m_Dynel.GetID());
			if (character != undefined && character.IsNPC() && (m_Dynel.GetStat(_global.Enums.Stat.e_CarsGroup) == 0 || m_Dynel.GetStat(_global.Enums.Stat.e_CarsGroup) == 2)/* || m_Character.IsGhosting()*/)
			{
				useBoxAlpha = 0;
			}
		}
	}
	
	
	if (m_UseBox._alpha != useBoxAlpha)
	{
		m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha: useBoxAlpha});
	}
	
	
	if (m_Dynel != undefined && !m_Dynel.IsEnemy())
	{
		if (m_Dynel.GetDistanceToPlayer() > DYNELDISPLAYDISTANCE)
		{
			m_ReticuleClip.gotoAndStop(NOTARGETFINALFRAME);
		}
		else if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_LootBag)
		{
			m_ReticuleClip.gotoAndStop(DYNELFIRSTFRAME);
		}
		else if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_ClimbingDynel)
		{
			m_ReticuleClip.gotoAndStop(DYNELFIRSTFRAME);
		}
		else if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_SimpleDynel)
		{
			m_ReticuleClip.gotoAndStop(DYNELFIRSTFRAME);
		}
		else // NPCs and players only at this point
		{
			m_ReticuleClip.gotoAndStop(MISSIONFRIENDLYFINALFRAME);
		}
	}
}

function ResizeHandler( w, h ,x, y )
{
	Layout();
}

function Layout()
{
	m_ReticuleClip.removeMovieClip();
	switch (m_CrosshairTypeMonitor.GetValue())
	{
		case 0:
			m_ReticuleClip = this.attachMovie("Final_All_States", "Final_All_States", this.getNextHighestDepth());
			m_ReticuleClip._xscale = 25;
			m_ReticuleClip._yscale = 25;
			break;
		case 1:
			m_ReticuleClip = this.attachMovie("Reticle_Set_Dot_01", "Reticle_Set_Dot_01", this.getNextHighestDepth());
			m_ReticuleClip._xscale = 25;
			m_ReticuleClip._yscale = 25;
			break;
		case 2:
			m_ReticuleClip = this.attachMovie("Reticle_Set_CrossHair", "Reticle_Set_CrossHair", this.getNextHighestDepth());
			break;
		case 3:
			m_ReticuleClip = this.attachMovie("Reticle_Set_Square", "Reticle_Set_Square", this.getNextHighestDepth());
			break;
		case 4:
			m_ReticuleClip = this.attachMovie("Reticle_Set_Square_02", "Reticle_Set_Square_02", this.getNextHighestDepth());
			break;
		case 5:
			m_ReticuleClip = this.attachMovie("Reticle_Set_Triangle_01", "Reticle_Set_Triangle_01", this.getNextHighestDepth());
			break;
		case 6:
			m_ReticuleClip = this.attachMovie("Reticle_Set_Triangle_02", "Reticle_Set_Triangle_02", this.getNextHighestDepth());
			break;
		case 7:
			m_ReticuleClip = this.attachMovie("Reticle_Set_Diamond", "Reticle_Set_Diamond", this.getNextHighestDepth());
			break;
		case 8:
			m_ReticuleClip = this.attachMovie("Reticle_Set_V_01", "Reticle_Set_V_01", this.getNextHighestDepth());
			break;
		case 9:
			m_ReticuleClip = this.attachMovie("Reticle_Set_X_01", "Reticle_Set_X_01", this.getNextHighestDepth());
			break;
		case 10:
			m_ReticuleClip = this.attachMovie("Reticle_Set_X_02", "Reticle_Set_X_02", this.getNextHighestDepth());
			break;
		case 11:
			//This is an empty fake clip for not showing any crosshairs. Always move it to the end.
			m_ReticuleClip = this.attachMovie("Reticle_Set_Empty", "Reticle_Set_Empty", this.getNextHighestDepth());
			break;
		default:
			m_ReticuleClip = this.attachMovie("Final_All_States", "Final_All_States", this.getNextHighestDepth());
			break;

	}
	
	//m_ReticuleClip._xscale = 25;
	//m_ReticuleClip._yscale = 25;
	m_UseBox._xscale = 50;
	m_UseBox._yscale = 50;
	
	m_ReticuleClip._x = (Stage["visibleRect"].width - m_ReticuleClip._width) / 2;
	m_ReticuleClip._y = (Stage["visibleRect"].height - m_ReticuleClip._height) / 2;

	var useX:Number;
	var useIconX = DistributedValue.Create("UseIconX");
	if (useIconX.GetValue() != "undefined")
	{
		useX = useIconX.GetValue();
	}
	else
	{
		useX = m_ReticuleClip._x + 150;
		useIconX.SetValue(useX);
	}

	var useY:Number;
	var useIconY = DistributedValue.Create("UseIconY");
	if (useIconY.GetValue() != "undefined")
	{
		useY = useIconY.GetValue();
	}
	else
	{
		useY = m_ReticuleClip._y - 13;
		useIconY.SetValue(useY);
	}

	m_UseBox._x = useX;
	m_UseBox._y = useY;

	m_UseBox._alpha = 0;

	m_ReticuleClip.gotoAndStop(NOTARGETFINALFRAME);
}

function SlotCrosshairTargetUpdated(dynelID:ID32)
{
	//trace("SlotCrosshairTargetUpdated: " + dynelID.toString());
	m_UseBox.tweenEnd();
	m_Dynel = Dynel.GetDynel(dynelID);
	var ALPHA:Number = 100;
	if (m_Dynel == undefined || m_Dynel.GetDistanceToPlayer() > DYNELACTIONDISTANCE || m_InCombat)
	{
		ALPHA = 0;
	}
	
	
	if (m_Dynel == undefined && m_HadEnemy)
	{
		m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha: ALPHA});
		m_HadEnemy = false;
		m_ReticuleClip.gotoAndPlay(OFFTARGETFIRSTFRAME);
		m_ReticuleClip.onEnterFrame = function()
		{
			if (m_ReticuleClip._currentframe == OFFTARGETFINALFRAME)
			{
				if (m_InCombat)
				{
					m_ReticuleClip.stop();
				}
				else
				{
					m_ReticuleClip.gotoAndStop(NOTARGETFIRSTFRAME);
				}
			}
		}
		return;
	}
	else if (m_Dynel == undefined)
	{
		m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha: ALPHA});
		if (m_InCombat)
		{
			m_ReticuleClip.gotoAndStop(OFFTARGETFINALFRAME);
		}
		else
		{
			m_ReticuleClip.gotoAndStop(NOTARGETFINALFRAME);
		}
		return;
	}
	
	if (m_Dynel.IsEnemy())
	{
		m_HadEnemy = true;
		m_ReticuleClip.gotoAndPlay(TARGETFIRSTFRAME);
		m_ReticuleClip.onEnterFrame = function()
		{
			if (m_ReticuleClip._currentframe == TARGETFINALFRAME)
			{
				m_ReticuleClip.stop();
			}
		}
		return;
	}
	
	if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_LootBag)
	{
		m_UseBox.removeMovieClip();
		m_UseBox = this.attachMovie("Open-Lootbag-Frame", "Open-Lootbag-Frame", this.getNextHighestDepth());
		m_UseBox.UseBoxHotKey.text = "<variable name='hotkey:ActionModeTargeting_Use'/>";
		m_UseBox.UseBoxAction.text = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Loot"));
		m_UseBox.UseBoxName.text = m_Dynel.GetName();
		
		Layout();
		
		m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha: ALPHA});
		
		if (m_Dynel.GetDistanceToPlayer() < DYNELDISPLAYDISTANCE)
		{
			m_ReticuleClip.gotoAndPlay(DYNELFIRSTFRAME);
			m_ReticuleClip.onEnterFrame = function()
			{
				if (m_ReticuleClip._currentframe == DYNELFINALFRAME)
				{
					m_ReticuleClip.stop();
				}
			}
		}
		return;
	}
	
	if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_ClimbingDynel)
	{
		m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha: ALPHA});
		
		m_UseBox.removeMovieClip();
		m_UseBox = this.attachMovie("Climb-Frame", "Climb-Frame", this.getNextHighestDepth());
		m_UseBox.UseBoxHotKey.text = "<variable name='hotkey:ActionModeTargeting_Use'/>";
		m_UseBox.UseBoxAction.text = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Climb"), "");
		m_UseBox.UseBoxName.text = m_Dynel.GetName();
		
		Layout();
		
		if (m_Dynel.GetDistanceToPlayer() < DYNELDISPLAYDISTANCE)
		{
			m_ReticuleClip.gotoAndPlay(DYNELFIRSTFRAME);
			m_ReticuleClip.onEnterFrame = function()
			{
				if (m_ReticuleClip._currentframe == DYNELFINALFRAME)
				{
					m_ReticuleClip.stop();
				}
			}
		}
		return;
	}
	
	if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_SimpleDynel)
	{
		if (!m_Character.IsGhosting() && m_Dynel.IsMissionGiver())
		{
			m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha: ALPHA});
		}
		
		if (m_Dynel.IsMissionGiver() && m_Dynel.HasVisibleMission())
		{
			m_UseBox.removeMovieClip();
			m_UseBox = this.attachMovie("Final_Frame_Mission", "Final_Frame_Mission", this.getNextHighestDepth());
			m_UseBox.UseBoxHotKey.text = "<variable name='hotkey:ActionModeTargeting_Use'/>";
			m_UseBox.UseBoxAction.text = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Mission"));
			m_UseBox.UseBoxName.text = m_Dynel.GetName();
			
			Layout();
			
			if (m_Dynel.GetDistanceToPlayer() < DYNELDISPLAYDISTANCE)
			{
				m_ReticuleClip.gotoAndPlay(MISSIONFRIENDLYFIRSTFRAME);
				m_ReticuleClip.onEnterFrame = function()
				{
					if (m_ReticuleClip._currentframe == MISSIONFRIENDLYFINALFRAME)
					{
						m_ReticuleClip.stop();
					}
				}
			}
		}
		else
		{
			m_UseBox.removeMovieClip();
			m_UseBox = this.attachMovie(GetMovieClipName(m_Dynel), GetMovieClipName(m_Dynel), this.getNextHighestDepth());
			m_UseBox.UseBoxHotKey.text = "<variable name='hotkey:ActionModeTargeting_Use'/>";
			m_UseBox.UseBoxAction.text = GetInteractionText(m_Dynel);
			m_UseBox.UseBoxName.text = m_Dynel.GetName();
			
			Layout();
			
			if (m_Dynel.GetDistanceToPlayer() < DYNELDISPLAYDISTANCE)
			{
				m_ReticuleClip.gotoAndPlay(DYNELFIRSTFRAME);
				m_ReticuleClip.onEnterFrame = function()
				{
					if (m_ReticuleClip._currentframe == DYNELFINALFRAME)
					{
						m_ReticuleClip.stop();
					}
				}
			}
		}
		return;
	}
	
	
	if (m_Dynel.IsFriend())
	{
		var character:Character = Character.GetCharacter(m_Dynel.GetID())
		if (character != undefined && !character.IsNPC())
		{
			m_UseBox.removeMovieClip();
			m_UseBox = this.attachMovie("InteractionOtherPlayer-Frame", "InteractionOtherPlayer-Frame", this.getNextHighestDepth());
			m_UseBox.UseBoxHotKey.text = "<variable name='hotkey:ActionModeTargeting_Use'/>";
			m_UseBox.UseBoxAction.text = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Player"));
			m_UseBox.UseBoxName.text = m_Dynel.GetName();
			
			Layout();
			
			m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha: ALPHA});
		}
		else if (m_Dynel.GetStat(_global.Enums.Stat.e_CarsGroup) != 0 && m_Dynel.GetStat(_global.Enums.Stat.e_CarsGroup) != 2)
		{
			if (m_Dynel.IsMissionGiver() && m_Dynel.HasVisibleMission())
			{
				m_UseBox.removeMovieClip();
				m_UseBox = this.attachMovie("Final_Frame_Mission", "Final_Frame_Mission", this.getNextHighestDepth());
				m_UseBox.UseBoxHotKey.text = "<variable name='hotkey:ActionModeTargeting_Use'/>";
				m_UseBox.UseBoxAction.text = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Mission"));
				Layout();
			}
			else
			{
				m_UseBox.removeMovieClip();
				m_UseBox = this.attachMovie(GetMovieClipName(m_Dynel), GetMovieClipName(m_Dynel), this.getNextHighestDepth());
				m_UseBox.UseBoxHotKey.text = "<variable name='hotkey:ActionModeTargeting_Use'/>";
				m_UseBox.UseBoxAction.text = GetInteractionText(m_Dynel);
				Layout();
			}
			m_UseBox.UseBoxName.text = m_Dynel.GetName();
			
			m_UseBox.tweenTo(ANIMATIONDURATION, {_alpha: ALPHA});
		}
		if (m_Dynel.GetDistanceToPlayer() < DYNELDISPLAYDISTANCE)
		{
			m_ReticuleClip.gotoAndPlay(MISSIONFRIENDLYFIRSTFRAME);
			m_ReticuleClip.onEnterFrame = function()
			{
				if (m_ReticuleClip._currentframe == MISSIONFRIENDLYFINALFRAME)
				{
					m_ReticuleClip.stop();
				}
			}
		}
		return;
	}
}

function GetMovieClipName(dynel:Dynel):String
{
	var movieName:String = "Final_Frame";
	if (dynel != undefined)
	{
		switch(dynel.GetStat(_global.Enums.Stat.e_OverrideCursor)) // Cursor IDs defined in guidefines.h (enum MousePointerID_e)
		{
			case 8:
				movieName = "Open-Frame";
				break;
			case 14: // Talk
				movieName = "Talk-Frame";
				break;
			case 15:
				movieName = "Open-Lootbag-Frame";
				break;
			case 16: // Climb
				movieName = "Climb-Fram";
				break;
			case 18: // Use
				movieName = "Final_Frame";
				break;
			case 20: // Trade with vendor
				movieName = "Trade-Frame";
				break;
			case 26: // Inspect
				movieName = "Inspect-Frame";
				break;
			case 28: // Ghost (Hack)
				movieName = "HACK-Frame";
				break;
			case 35: // Take
				movieName = "Take_Dynel-Frame";
				break;
			case 36: // Dig
				movieName = "Dig-Frame";
				break;
			case 37: // Accuse
				movieName = "Accuse-Frame";
				break;
			case 38: // Travel
				movieName = "TravelTo-Frame";
				break;
			case 39: // Enter dungeon
				movieName = "EnterDungeon-Frame";
				break;
			case 40: // Place (empty brackets)
				movieName = "Place-Frame";
				break;
			case 41: // Help
				movieName = "Help-Frame";
				break;
			case 42: //Ignite
				movieName = "Ignite-Frame";
				break;
			case 43: // Resurrect
				movieName = "Resurrect-Frame";
				break;
			case 44: // Search
				movieName = "Search-Frame";
				break;
			case 45: // Learn
				movieName = "Learn-Frame";
				break;
			case 46: // Examine
				movieName = "Examine-Frame";
				break;
			case 47: // Open chest
				movieName = "OpenChest-Frame";
				break;
			default:
				if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_Character)
				{
					movieName = "Talk-Frame";
				}
				else
				{
					movieName = "Final_Frame";
				}
				break;
		}
	}
	return movieName;
}

function GetInteractionText(dynel:Dynel):String
{
	var text:String = "";
	if (dynel != undefined)
	{
		switch(dynel.GetStat(_global.Enums.Stat.e_OverrideCursor)) // Cursor IDs defined in guidefines.h (enum MousePointerID_e)
		{
			case 8: // Open
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Loot"));
				break;
			case 14: // Talk
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Talk_Single"));
				break;
			case 15: // open lootbag
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Loot"));
				break;
			case 16: // Climb
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Climb_Single"));
				break;
			case 18: // Use
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Use_Single"));
				break;
			case 20: // Trade with vendor
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Shop"));
				break;
			case 26: // Inspect
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Inspect"));
				break;
			case 28: // Ghost (Hack)
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Hack"));
				break;
			case 35: // Take
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Take"));
				break;
			case 36: // Dig
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Dig"));
				break;
			case 37: // Accuse
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Accuse"));
				break;
			case 38: // Travel
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Travel"));
				break;
			case 39: // Enter dungeon
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Enter"));
				break;
			case 40: // Place (empty brackets)
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Place"));
				break;
			case 41: // Help
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Help"));
				break;
			case 42: //Ignite
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Ignite"));
				break;
			case 43: // Resurrect
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Resurrect"));
				break;
			case 44: // Search
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Search"));
				break;
			case 45: // Learn
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Learn"));
				break;
			case 46: // Examine
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Examine_Single"));
				break;
			case 47: // Open chest
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Loot"));
				break;
			default:
				if (m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_Character)
				{
					text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Talk_Single"));
				}
				else
				{
					text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Use_Single"));
				}
				break;
		}
	}
	return text;
}