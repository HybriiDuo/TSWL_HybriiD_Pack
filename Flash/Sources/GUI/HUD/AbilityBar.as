/// this is all the logic applying to the AbilityBar
import GUI.HUD.AbilitySlot;
import GUI.HUD.ActiveAbilitySlot;
import GUI.HUD.AbilityBase;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Game.BuffData;
import com.GameInterface.SpellBase;
import com.GameInterface.InventoryItem;
import com.GameInterface.Inventory;
import com.GameInterface.Tooltip.*;
import com.GameInterface.Utils;
import com.GameInterface.DistributedValue;
import com.GameInterface.Log;
import com.GameInterface.ProjectUtils;
import com.GameInterface.PlayerDeath;
import com.Utils.DragObject;
import com.Utils.ID32;
import com.Utils.Archive;
import com.Utils.HUDController;
import com.Utils.LDBFormat;
import com.Components.AnimaPotion;
import com.Components.ItemSlot;
import mx.utils.Delegate;

var m_GadgetSlot:MovieClip;
var m_DodgeBar:MovieClip;
var m_PotionSlot:AnimaPotion;
var m_DeathPenalty:MovieClip;
var m_DeathOverlay:MovieClip;
var m_SprintIcon:MovieClip;
var m_MainBar:MovieClip;
var m_ItemBG:MovieClip;
var m_CombatIndicator:MovieClip;
var m_LMB_Hotkey:MovieClip;
var m_RMB_Hotkey:MovieClip;
var m_DodgeAnim:MovieClip;

var m_AbilitySlots:Array = [];
var m_ItemSlots:Array = [];
var m_AbilityBarVisible:DistributedValue;
var m_ShowHotkeys:DistributedValue;
var m_Character:Character;
var m_UsedShortcut:Number;
var m_Inventory:Inventory;

var STATE_WRONG_HEAPON:Number = 0;
var STATE_OUT_OF_RANGE:Number = 1;
var STATE_NO_RESOURCE:Number = 2;
var STATE_CASTING:Number = 3;
var STATE_CHANNELING:Number = 4;
var STATE_COOLDOWN:Number = 5;
var STATE_GLOBAL_COOLDOWN:Number = 6;
var STATE_ACTIVE:Number = 7;
var STATE_MAX_MOMENTUM:Number = 9;

var PLAYER_MAX_ACTIVE_SPELLS:String = "PlayerMaxActiveSpells";
var PLAYER_START_SLOT_SPELLS:String = "PlayerStartSlotSpells";
var PLAYER_START_SLOT_POCKET:String = "PlayerStartSlotPocket";
var PLAYER_MAX_ITEM_SHORTCUTS:Number = 3;
var SPRINT_BUFFS:Array = [7481588, 7758936, 7758937, 7758938, 9114480, 9115262];

var DEATH_PENALTY_BUFF:Number = 9285457;

var m_BaseWidth:Number;
var m_BigWidth:Number;
var m_BaseHeight:Number;
var m_InitialY:Number;
var m_SpellTemplatesSwap:Array;

var m_DodgeBuffSpellID:Number;
var m_DodgeIntervalID:Number;
var m_DodgeStartTime:Number;
var m_DodgeDuration:Number;

var m_DeathPenaltyTooltip:TooltipInterface;
var m_DeathPenaltyTooltipTimeout:Number;

var m_EditModeMask:MovieClip;


function onLoad()
{
    /*
     *  m_BaseWidth is referenced from com.Utils.HUDController.as to serve
     *  as a constant.  Without this constant, unintentional repositioning of
     *  the AbilityBar will occur:
     * 
     *  http://jira.funcom.com/browse/TSW-101595
     *
     */
    m_BaseWidth = m_MainBar._width;
	m_BigWidth = m_BaseWidth + m_ItemBG._width;
	m_BaseHeight = _height;
    
    gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "onDragBegin" );
    gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );

    m_ShowHotkeys = DistributedValue.Create( "ShortcutbarHotkeysVisible" );
    m_ShowHotkeys.SignalChanged.Connect( SlotShortcutbarHotkeysVisibleChanged, this);
	m_AbilityBarVisible = DistributedValue.Create( "ability_bar_visibility" );
    m_AbilityBarVisible.SignalChanged.Connect( SlotAbilityBarVisibilityChanged, this);
	
	m_DodgeBuffSpellID = ProjectUtils.GetUint32TweakValue("DashCooldownSpellID");

    // loop the hive and push each of the slots in the m_AbilitySlots array.
    for( var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
    {
        var mc_slot:MovieClip = MovieClip( this["slot_"+i] );

        if( mc_slot != null )
        {
            m_AbilitySlots.push( new ActiveAbilitySlot( mc_slot, ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS) + i ) );
            var hotkey:MovieClip = attachMovie("HotkeyLabel", "m_HotkeyLabel" + i, getNextHighestDepth());
			hotkey.m_HotkeyText.autoSize = "left";
            hotkey._y = mc_slot._y + mc_slot._height - hotkey._height + 6;
        }
        else
        {
            Log.Error( "AbilityBar", "Failed to retrieve a valid slot at index "+i); 
        }
    }
		
	for( var i:Number = 0; i < PLAYER_MAX_ITEM_SHORTCUTS; i++)
    {
        var mc_slot:MovieClip = MovieClip( this["m_ItemSlot_"+i] );

        if( mc_slot != null )
        {
			var slot:MovieClip = CreateItemSlot(i);
			slot.attachMovie("UseAnimation", "m_UseAnimation", slot.getNextHighestDepth());
			slot.m_UseAnimation._width = slot.i_Background._width;
            slot.m_UseAnimation._height = slot.i_Background._height;
            var hotkey:MovieClip = slot.attachMovie("HotkeyLabel", "m_ItemHotkeyLabel", slot.getNextHighestDepth());
			hotkey.m_HotkeyText.autoSize = "left";
            hotkey._y = slot._height - hotkey._height + 6;
        }
        else
        {
            Log.Error( "AbilityBar", "Failed to retrieve a valid slot at index "+i); 
        }
    }
	
	//Add the hotkey for the gadget slot
	var hotkey:MovieClip = attachMovie("HotkeyLabel", "m_HotkeyLabel_Gadget", getNextHighestDepth());
	hotkey.m_HotkeyText.autoSize = "left";
	hotkey._y = m_GadgetSlot._y + m_GadgetSlot._height - hotkey._height + 18;
	
	//Add the hotkey for the potion slot
	var hotkey:MovieClip = attachMovie("HotkeyLabel", "m_HotkeyLabel_Potion", getNextHighestDepth());
	hotkey.m_HotkeyText.autoSize = "left";
	hotkey._y = m_PotionSlot._y + m_PotionSlot._height - 30 - hotkey._height + 5;
	
	//Add the hotkey for sprint
	var hotkey:MovieClip = attachMovie("HotkeyLabel", "m_HotkeyLabel_Sprint", getNextHighestDepth());
	hotkey.m_HotkeyText.autoSize = "left";
	hotkey._y = m_SprintIcon._y + m_SprintIcon._height - hotkey._height + 6;
    
    /// connect the signals
	Shortcut.SignalShortcutAdded.Connect( SlotShortcutAdded, this  );
	Shortcut.SignalShortcutRemoved.Connect( SlotShortcutRemoved, this );
	Shortcut.SignalShortcutMoved.Connect( SlotShortcutMoved, this );
	Shortcut.SignalShortcutStatChanged.Connect( SlotShortcutStatChanged, this );
//	Shortcut.SignalShortcutResourceEnabled.Connect( SlotShortcutResourceEnabled, this );
    Shortcut.SignalShortcutEnabled.Connect( SlotShortcutEnabled, this );
    Shortcut.SignalShortcutRangeEnabled.Connect( SlotShortcutRangeEnabled, this );
    Shortcut.SignalShortcutUsed.Connect( SlotShortcutUsed, this );
    Shortcut.SignalShortcutAddedToQueue.Connect( SlotShortcutAddedToQueue, this );
    Shortcut.SignalShortcutRemovedFromQueue.Connect( SlotShortcutRemovedFromQueue, this );
	Shortcut.SignalCooldownTime.Connect( SlotCooldownTime,this );
	Shortcut.SignalShortcutsRefresh.Connect( SlotShortcutsRefresh, this );
    Shortcut.SignalHotkeyChanged.Connect( SlotHotkeyChanged, this );
    Shortcut.SignalSwapShortcut.Connect( SlotSwapShortcut, this);
    Shortcut.SignalSwapBar.Connect( SlotSwapBar, this);
    Shortcut.SignalRestoreSwapBar.Connect( SlotRestoreSwapBar, this);
    
//    Shortcut.SignalShortcutMaxMomentumEnabled.Connect( SlotSignalShortcutMaxMomentumEnabled, this);
	
    m_Character = Character.GetClientCharacter();
    m_Character.SignalCommandStarted.Connect(SlotSignalCommandStarted, this);
    m_Character.SignalCommandEnded.Connect(SlotSignalCommandEnded, this);
    m_Character.SignalCommandAborted.Connect(SlotSignalCommandAborted, this);
	m_Character.SignalInvisibleBuffAdded.Connect(SlotInvisibleBuffAdded, this);
	m_Character.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
	m_Character.SignalToggleCombat.Connect(SlotToggleCombat, this);
	PlayerDeath.SignalPlayerCharacterDead.Connect(SlotCharacterDead, this);
    m_Character.SignalCharacterRevived.Connect(SlotCharacterAlive, this);
	
	m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharID().GetInstance()));
	m_Inventory.SignalItemRemoved.Connect(SlotItemRemoved, this);
	m_Inventory.SignalItemLoaded.Connect(SlotShortcutsRefresh, this);
	m_Inventory.SignalItemCooldown.Connect(SlotItemCooldown, this);
    m_Inventory.SignalItemCooldownRemoved.Connect(SlotItemCooldownRemoved, this);
	
	m_SprintIcon.attachMovie("UseAnimation", "m_UseAnimation", m_SprintIcon.getNextHighestDepth());
	m_SprintIcon.m_UseAnimation._height = m_SprintIcon.m_Inactive._height;
	m_SprintIcon.m_UseAnimation._width = m_SprintIcon.m_Inactive._width;
	m_SprintIcon.onMouseUp = Delegate.create(this, SprintMouseUp);
	TooltipUtils.AddTextTooltip( m_SprintIcon, LDBFormat.LDBGetText( "GenericGUI", "MainMenuToggleSprintTooltip" ), 140, TooltipInterface.e_OrientationHorizontal,  true, true); 
	UpdateSprint();
	
	m_DeathPenalty.onMouseDown = Delegate.create(this, DeathPenaltyMouseDown);
	m_DeathPenalty.onMouseUp = Delegate.create(this, DeathPenaltyMouseUp);
	m_DeathPenalty.onRollOver = Delegate.create(this, DeathPenaltyRollOver);
	m_DeathPenalty.onRollOut = Delegate.create(this, DeathPenaltyRollOut);
	m_DeathPenalty.onDragOut = Delegate.create(this, DeathPenaltyRollOut);
	UpdateDeathPenalty();	
	m_DeathOverlay.m_Text.text = LDBFormat.LDBGetText("MiscGUI", "DeathOverlayText");
	UpdateDeathOverlay();
	
	m_CombatIndicator._alpha = 0;
	m_CombatIndicator.gotoAndStop(1);
	SlotToggleCombat(m_Character.IsThreatened());
	
	m_PotionSlot.SetCharacter(m_Character);
	
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
       
    /// Update Hotkey Labels
    SlotHotkeyChanged();
    SlotShortcutbarHotkeysVisibleChanged();
			
	this._visible = Boolean(m_AbilityBarVisible.GetValue());	
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
}

function OnModuleActivated(config:Archive):Void
{
    //Nasty hack to avoid dispacement of the bar on reloadui while the bar is swapped
    _global.setTimeout( Delegate.create(this, SlotShortcutsRefresh), 300);
	_global.setTimeout( Delegate.create(this, UpdateDeathOverlay), 100);
}

function onUnload()
{
    gfx.managers.DragManager.instance.removeEventListener( "dragBegin", this, "onDragBegin" );
    gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "onDragEnd" );
    
    Shortcut.SignalShortcutAdded.Disconnect( SlotShortcutAdded, this );
    Shortcut.SignalShortcutRemoved.Disconnect( SlotShortcutRemoved, this );
    Shortcut.SignalShortcutMoved.Disconnect( SlotShortcutMoved, this );
    Shortcut.SignalShortcutStatChanged.Disconnect( SlotShortcutStatChanged, this );
    Shortcut.SignalShortcutEnabled.Disconnect( SlotShortcutEnabled, this );
    Shortcut.SignalShortcutRangeEnabled.Disconnect( SlotShortcutRangeEnabled, this );
    Shortcut.SignalShortcutUsed.Disconnect( SlotShortcutUsed, this );
    Shortcut.SignalShortcutAddedToQueue.Disconnect( SlotShortcutAddedToQueue, this );
    Shortcut.SignalShortcutRemovedFromQueue.Disconnect( SlotShortcutRemovedFromQueue, this );
    Shortcut.SignalCooldownTime.Disconnect( SlotCooldownTime,this );
    Shortcut.SignalShortcutsRefresh.Disconnect( SlotShortcutsRefresh, this );
    Shortcut.SignalHotkeyChanged.Disconnect( SlotHotkeyChanged, this );
    Shortcut.SignalSwapShortcut.Disconnect( SlotSwapShortcut, this);
    Shortcut.SignalSwapBar.Disconnect( SlotSwapBar, this);
    Shortcut.SignalRestoreSwapBar.Disconnect( SlotRestoreSwapBar, this);
    
    m_Character.SignalCommandStarted.Disconnect(SlotSignalCommandStarted, this);
    m_Character.SignalCommandEnded.Disconnect(SlotSignalCommandEnded, this);
    m_Character.SignalCommandAborted.Disconnect(SlotSignalCommandAborted, this);
	m_Character.SignalInvisibleBuffAdded.Disconnect(SlotInvisibleBuffAdded, this);
	m_Character.SignalBuffRemoved.Disconnect(SlotBuffRemoved, this);
	PlayerDeath.SignalPlayerCharacterDead.Disconnect(SlotCharacterDead, this);
    m_Character.SignalCharacterRevived.Disconnect(SlotCharacterAlive, this);
    
	clearInterval( m_DodgeIntervalID );
	CloseDeathPenaltyTooltip();
}

function SlotToggleCombat(isInCombat)
{
	if(isInCombat)
	{ 
		m_CombatIndicator.tweenTo(1, {_alpha:100}, Strong.easeIn) 
		m_CombatIndicator.gotoAndPlay(1);
	}
	else
	{ 
		m_CombatIndicator.tweenTo(2, {_alpha:0}, Strong.easeOut) 
		m_CombatIndicator.onTweenComplete = function()
		{
			this.gotoAndStop(1);
			this.onTweenComplete = function(){};
		}
	}
}

function CreateItemSlot(slotID:Number):MovieClip
{	
	var mc:MovieClip = this.attachMovie("IconSlotTransparent", "RealItemSlot_" + slotID, this.getNextHighestDepth());
	mc._x = this["m_ItemSlot_"+slotID]._x;
	mc._y = this["m_ItemSlot_"+slotID]._y;
	
	var itemSlot:ItemSlot = new ItemSlot(new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharID().GetInstance()), slotID, mc);
	itemSlot.SetFilteringSupport( true );
	itemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
	itemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
	itemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
	m_ItemSlots[slotID] = itemSlot;
	return mc;
}

function SlotInvisibleBuffAdded(buffId:Number) : Void
{
	if (m_Character == undefined){ return; }
    if (buffId == m_DodgeBuffSpellID)
	{	
		if (m_DodgeIntervalID != undefined)
		{
			clearInterval(m_DodgeIntervalID);
			m_DodgeIntervalID = undefined;
		}
		
		m_DodgeStartTime = Utils.GetNormalTime();
		m_DodgeDuration = m_Character.m_InvisibleBuffList[m_DodgeBuffSpellID].m_TotalTime/1000 - m_DodgeStartTime;
		m_IntervalId = setInterval( Delegate.create( this, UpdateDodgeBar ), 20 );		
	}
	else if (buffId == DEATH_PENALTY_BUFF)
	{
		UpdateDeathPenalty();
	}
	else 
	{
		for (var i:Number = 0; i < SPRINT_BUFFS.length; i++)
		{
			if (buffId == SPRINT_BUFFS[i])
			{
				UpdateSprint();
				break;
			}
		}
	}
}

function SlotBuffRemoved(buffId:Number) : Void
{
	if (m_Character == undefined){ return; }
    if (buffId == m_DodgeBuffSpellID) 
	{
		m_DodgeBar.m_Mask._xscale = 100;
		clearInterval( m_DodgeIntervalID );
		m_DodgeAnim.gotoAndPlay(1);
	}
	else if (buffId == DEATH_PENALTY_BUFF)
	{
		UpdateDeathPenalty();
	}
	else 
	{
		for (var i:Number = 0; i < SPRINT_BUFFS.length; i++)
		{
			if (buffId == SPRINT_BUFFS[i])
			{
				UpdateSprint();
				break;
			}
		}
	}
}

function UpdateDeathPenalty()
{
	var buff:BuffData = m_Character.m_InvisibleBuffList[DEATH_PENALTY_BUFF];
	if (buff == undefined)
	{
		m_DeathPenalty.m_Blue._visible = true;
		m_DeathPenalty.m_Yellow._visible = false;
		m_DeathPenalty.m_Red._visible = false;
		return;
	}
	var maxCount:Number = buff.m_MaxCounters;
	var currentCount:Number = buff.m_Count;
	
	//Whole or broken
	if (currentCount == maxCount)
	{
		m_DeathPenalty.m_Red.gotoAndPlay(1);
	}
	else
	{
		m_DeathPenalty.m_Red.gotoAndStop(1);
	}
	
	//Color
	//Broken or almost broken is red
	if (currentCount > maxCount - 2)
	{
		m_DeathPenalty.m_Blue._visible = false;
		m_DeathPenalty.m_Yellow._visible = false;
		m_DeathPenalty.m_Red._visible = true;
	}
	//Halfway to almost broken is yellow
	else if (currentCount > (maxCount - 2) / 2)
	{
		m_DeathPenalty.m_Blue._visible = false;
		m_DeathPenalty.m_Yellow._visible = true;
		m_DeathPenalty.m_Red._visible = false;
	}
	//Less than halfway to almost broken is blue
	else
	{
		m_DeathPenalty.m_Blue._visible = true;
		m_DeathPenalty.m_Yellow._visible = false;
		m_DeathPenalty.m_Red._visible = false;
	}
}

function SlotCharacterDead()
{
	UpdateDeathOverlay();
}

function SlotCharacterAlive()
{
	UpdateDeathOverlay();
}

function UpdateDeathOverlay()
{
	if (m_Character.IsDead() || m_Character.IsGhosting())
	{
		m_DeathOverlay.swapDepths(this.getNextHighestDepth());
		m_DeathOverlay._visible = true;
	}
	else
	{
		m_DeathOverlay._visible = false;
	}
}

function UpdateSprint()
{
	for (var i:Number = 0; i < SPRINT_BUFFS.length; i++)
	{
		var buff:BuffData = m_Character.m_InvisibleBuffList[SPRINT_BUFFS[i]];
		if (buff != undefined)
		{
			m_SprintIcon.gotoAndStop("Active");
			return;
		}
	}
	m_SprintIcon.gotoAndStop("Off");
}

function SprintMouseUp()
{
	if (m_SprintIcon.hitTest(_root._xmouse, _root._ymouse))
	{
		m_SprintIcon.m_UseAnimation.gotoAndPlay("Start");
		SpellBase.SummonMountFromTag();
	}
}

function DeathPenaltyMouseDown()
{
	if (m_DeathPenalty.hitTest(_root._xmouse, _root._ymouse))
	{
		DeathPenaltyRollOut();
	}
}

function DeathPenaltyMouseUp()
{
	if (m_DeathPenalty.hitTest(_root._xmouse, _root._ymouse))
	{
		Character.ClearDeathPenalty();
	}
}

function DeathPenaltyRollOver()
{
	StartDeathPenaltyTooltipTimeout();
}

function DeathPenaltyRollOut()
{
	StopDeathPenaltyTooltipTimeout();
	if (m_DeathPenaltyTooltip != undefined)
	{
		CloseDeathPenaltyTooltip();
	}
}

function StartDeathPenaltyTooltipTimeout()
{
	if (m_DeathPenaltyTooltipTimeout != undefined)
	{
		return;
	}
	var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelay");
	if (delay == 0)
	{
		OpenDeathPenaltyTooltip();
		return;
	}
	m_DeathPenaltyTooltipTimeout = _global.setTimeout( Delegate.create( this, OpenDeathPenaltyTooltip ), delay*1000 );
}

function StopDeathPenaltyTooltipTimeout()
{
	if (m_DeathPenaltyTooltipTimeout != undefined)
	{
		_global.clearTimeout(m_DeathPenaltyTooltipTimeout);
		m_DeathPenaltyTooltipTimeout = undefined;
	}
}

function OpenDeathPenaltyTooltip()
{
	StopDeathPenaltyTooltipTimeout();
	if (m_DeathPenaltyTooltip == undefined)
	{
		var tooltipData:TooltipData = TooltipDataProvider.GetBuffTooltip( DEATH_PENALTY_BUFF, m_Character.GetID() );
		m_DeathPenaltyTooltip = TooltipManager.GetInstance().ShowTooltip( m_DeathPenalty, TooltipInterface.e_OrientationHorizontal, 0, tooltipData );
	}
}

function CloseDeathPenaltyTooltip()
{
	StopDeathPenaltyTooltipTimeout();
	if ( m_DeathPenaltyTooltip != undefined && !m_DeathPenaltyTooltip.IsFloating() )
	{
		m_DeathPenaltyTooltip.Close();
	}
	m_DeathPenaltyTooltip = undefined;
}

function UpdateDodgeBar(): Void
{
    if (m_Character != undefined)
    {
        var percentCompleteFactor:Number = (Utils.GetNormalTime() - m_DodgeStartTime) / m_DodgeDuration;
        m_DodgeBar.m_Mask._xscale = percentCompleteFactor * 100;
    }
}

function SlotAbilityBarVisibilityChanged()
{
	this._visible = Boolean(m_AbilityBarVisible.GetValue());
}

function SlotHotkeyChanged(hotkeyId:Number) : Void
{
	m_LMB_Hotkey._visible = true;
	m_RMB_Hotkey._visible = true;
    for( var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
    {
        var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel" + i] );
        hotkey.m_HotkeyText.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
        hotkey.m_HotkeyText.text = "<variable name='hotkey_short:" + "Shortcutbar_" + (i + 1) + "'/ >";
		hotkey.m_Background._width = Math.max(hotkey.m_HotkeyText._width, 22);
		hotkey.m_HotkeyText._x = hotkey.m_Background._width/2 - hotkey.m_HotkeyText._width/2;
		if (hotkey.m_HotkeyText.text == "") 
		{ 
			hotkey.m_Background._visible = false;
		}
		else
		{
			if (i == 1)
			{
				m_LMB_Hotkey._visible = false;
			}
			if (i == 3)
			{
				m_RMB_Hotkey._visible = false;
			}
			hotkey.m_Background._visible = true;
		}
		
		var mc_slot:MovieClip = MovieClip( this["slot_"+i] );
		hotkey._x = mc_slot._x + mc_slot._width/2 - hotkey.m_Background._width/2;
    }
	for( var i:Number = 0; i < PLAYER_MAX_ITEM_SHORTCUTS; i++)
    {
        var hotkey:MovieClip = MovieClip( m_ItemSlots[i].GetSlotMC()["m_ItemHotkeyLabel"] );
        hotkey.m_HotkeyText.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
        hotkey.m_HotkeyText.text = "<variable name='hotkey_short:" + "InventoryShortcuts_" + (i + 1) + "'/ >";
		hotkey.m_Background._width = Math.max(hotkey.m_HotkeyText._width, 22);
		hotkey.m_HotkeyText._x = hotkey.m_Background._width/2 - hotkey.m_HotkeyText._width/2;
		if (hotkey.m_HotkeyText.text == "") 
		{ 
			hotkey.m_Background._visible = false; 
		}
		else
		{
			hotkey.m_Background._visible = true;
		}
		
		var mc_slot:MovieClip = MovieClip( m_ItemSlots[i].GetSlotMC() );
		hotkey._x = mc_slot._width/2 - hotkey.m_Background._width/2;
    }
	var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel_Gadget"] );
	hotkey.m_HotkeyText.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
    hotkey.m_HotkeyText.text = "<variable name='hotkey_short:" + "Use_Gadget" + "'/ >";
	hotkey.m_Background._width = Math.max(hotkey.m_HotkeyText._width, 22);
	hotkey.m_HotkeyText._x = hotkey.m_Background._width/2 - hotkey.m_HotkeyText._width/2;
	if (hotkey.m_HotkeyText.text == "") 
	{ 
		hotkey.m_Background._visible = false; 
	}
	else
	{
		hotkey.m_Background._visible = true;
	}
	hotkey._x = m_GadgetSlot._x + m_GadgetSlot._width/2 - hotkey.m_Background._width/2;
	
	var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel_Potion"] );
	hotkey.m_HotkeyText.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
    hotkey.m_HotkeyText.text = "<variable name='hotkey_short:" + "Use_Potion" + "'/ >";
	hotkey.m_Background._width = Math.max(hotkey.m_HotkeyText._width, 22);
	hotkey.m_HotkeyText._x = hotkey.m_Background._width/2 - hotkey.m_HotkeyText._width/2;
	if (hotkey.m_HotkeyText.text == "") 
	{ 
		hotkey.m_Background._visible = false; 
	}
	else
	{
		hotkey.m_Background._visible = true;
	}
	hotkey._x = m_PotionSlot._x + m_PotionSlot._width/2 - hotkey.m_Background._width/2;
	
	var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel_Sprint"] );
	hotkey.m_HotkeyText.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
    hotkey.m_HotkeyText.text = "<variable name='hotkey_short:" + "Movement_SprintToggle" + "'/ >";
	hotkey.m_Background._width = Math.max(hotkey.m_HotkeyText._width, 22);
	hotkey.m_HotkeyText._x = hotkey.m_Background._width/2 - hotkey.m_HotkeyText._width/2;
	if (hotkey.m_HotkeyText.text == "") 
	{ 
		hotkey.m_Background._visible = false; 
	}
	else
	{
		hotkey.m_Background._visible = true;
	}
	hotkey._x = m_SprintIcon._x + m_SprintIcon._width/2 - hotkey.m_Background._width/2;
}

function SlotShortcutbarHotkeysVisibleChanged()
{
    for( var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
    {
        var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel" + i] );
        hotkey._visible = Boolean(m_ShowHotkeys.GetValue());
    }
	for( var i:Number = 0; i < PLAYER_MAX_ITEM_SHORTCUTS; i++)
    {
        var hotkey:MovieClip = MovieClip( m_ItemSlots[i].GetSlotMC()["m_ItemHotkeyLabel"] );
        hotkey._visible = Boolean(m_ShowHotkeys.GetValue());
    }
	
	var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel_Gadget"] );
	hotkey._visible = Boolean(m_ShowHotkeys.GetValue());
	
	var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel_Potion"] );
	hotkey._visible = Boolean(m_ShowHotkeys.GetValue());
	
	var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel_Sprint"] );
	hotkey._visible = Boolean(m_ShowHotkeys.GetValue());
	SlotHotkeyChanged();
}

function SlotMouseUpItem(itemSlot:ItemSlot, buttonIndex:Number)
{
	if (buttonIndex == 1)
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
		if (currentDragObject != undefined)
		{
			if (currentDragObject.type == "item")
			{
				var shortcutPos:Number = ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET) + itemSlot.GetSlotID();
				Shortcut.RemoveFromShortcutBar(shortcutPos);
				Shortcut.AddItem(shortcutPos, currentDragObject.inventory_id, currentDragObject.inventory_slot);
				currentDragObject.DragHandled();
			}
			else
			{
				gfx.managers.DragManager.instance.cancelDrag();
			}
		}
		else
		{
			Shortcut.UseShortcut(itemSlot.GetSlotID() + ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET));
		}
	}
	else if (buttonIndex == 2)
	{
		Shortcut.UseShortcut(itemSlot.GetSlotID() + ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET));
	}
}

function SlotStartDragItem(itemSlot:ItemSlot, stackSize:Number)
{
	var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSize);
	dragObject.type = "shortcut_items";
	dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
	dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
}

function SlotMouseUpEmptySlot(itemSlot:ItemSlot, buttonIdx:Number)
{
	if (buttonIdx == 1)
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
		if (currentDragObject != undefined && currentDragObject.type == "item")
		{
			var shortcutPos:Number = ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET) + itemSlot.GetSlotID();
			Shortcut.AddItem(shortcutPos, currentDragObject.inventory_id, currentDragObject.inventory_slot);
			currentDragObject.DragHandled();
		}
	}
}

function SlotItemDroppedOnDesktop()
{
	var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
	if (currentDragObject.type == "shortcut_items")
	{
		var shortcutPos:Number = ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET) + currentDragObject.inventory_slot;
		Shortcut.RemoveFromShortcutBar(shortcutPos);
	}
}

function SlotDragHandled()
{
	var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
	var itemSlot:ItemSlot = m_ItemSlots[currentDragObject.inventory_slot];
	itemSlot.SetAlpha(100);
	itemSlot.UpdateFilter();
}

//Signal set when a shortcut should be swapped with another one.
//@param itemPos:Number the position of the item to swap
//@param templateID:Number the id of the new shortcut
function SlotSwapShortcut(itemPos:Number, templateID:Number, switchBackTime:Number):Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        SwapAbilities(itemPos, switchBackTime);
    }
}

function SlotRestoreSwapBar():Void
{
    SlotSwapBar(undefined);
    _global.setTimeout( Delegate.create(this, ShowHotkeyLabels), 300);
}

function ShowHotkeyLabels():Void
{    
    for (var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); ++i)
    {
        this["m_HotkeyLabel" + i]._visible = true;
        this["slot_" + i]._alpha = 100;
    }
	for (var i:Number = 0; i < PLAYER_MAX_ITEM_SHORTCUTS; ++i)
    {
        m_ItemSlots[i].GetSlotMC()["m_ItemHotkeyLabel"]._visible = true;
    }
	this["m_HotkeyLabel_Gadget"]._visible = true;
	this["m_HotkeyLabel_Potion"]._visible = true;
	this["m_HotkeyLabel_Sprint"]._visible = true;
}

function SlotSwapBar(spellTemplates:Array):Void
{
    //Hide Bar
    var currentPosition:Number = m_InitialY + 50;
    //if (_y > 0)
    {
        this.tweenTo(0.3, { _y:currentPosition, _alpha:0 }, mx.transitions.easing.Regular.easeOut );
    }
    //else
    {
    //    this.tweenTo(0.3, { _alpha:0 }, mx.transitions.easing.Regular.easeOut );
    }
    m_SpellTemplatesSwap = spellTemplates;
    this.onTweenComplete = Delegate.create(this, UpdateSwappedBar);
}

function UpdateSwappedBar():Void
{
    var spellStart:Number = ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS)
    if (m_SpellTemplatesSwap)
    {
        for (var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); ++i)
        {
            if (m_SpellTemplatesSwap[i] == undefined || m_SpellTemplatesSwap[i] == 0)
            {
                SlotShortcutRemoved(spellStart + i);
                this["m_HotkeyLabel" + i]._visible = false;
                this["slot_" + i]._alpha = 35;
            }
            else
            {
                SlotShortcutAdded(spellStart + i);
                this["m_HotkeyLabel" + i]._visible = true;
            }
			m_AbilitySlots[i].m_ShowAugments = false;
        }
        
		SlotShortcutsRefresh();
    }
    else
    {
        SlotShortcutsRefresh();
		for (var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); ++i)
        {
			m_AbilitySlots[i].m_ShowAugments = true;
		}
    }

    //ShowBar
    var currentPosition:Number = m_InitialY;
   // if ( currentPosition > 0 )
    {    
        this.tweenTo(0.3, { _y:currentPosition, _alpha:100 }, mx.transitions.easing.Regular.easeOut );
    }
    //else
    {
      //  this.tweenTo(0.3, { _alpha:100 }, mx.transitions.easing.Regular.easeOut );
    }
    
    this.onTweenComplete = function() { };
    m_SpellTemplatesSwap = undefined;
}

function IsAbilityShortcut(itemPos:Number):Boolean
{
    var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
    var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
    var checkSpell:Boolean = (shortcutData)?(shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_SpellShortcut) : true;
    if ( slotNo >= 0 && slotNo < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS) && checkSpell)
    {
        return true;
    }
    return false;
}

function IsItemShortcut(itemPos:Number):Boolean
{
	var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET);
    var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
	var checkItem:Boolean = (shortcutData)?(shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_ItemShortcut) : true;
    if ( slotNo >= 0 && slotNo < PLAYER_MAX_ITEM_SHORTCUTS && checkItem)
    {
        return true;
    }
    return false;
}

function SwapAbilities(itemPos:Number, swapBackTime:Number):Void
{
    if (itemPos != undefined)
    {
        if( IsAbilityShortcut(itemPos) )
        {
            var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
            var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
            var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
            var abilitySlot:AbilitySlot = AbilitySlot( m_AbilitySlots[ slotNo ] );
            abilitySlot.SwapAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", false, swapBackTime, spellData.m_ResourceGenerator);
            abilitySlot.CloseTooltip();
			ActiveAbilitySlot(abilitySlot).StopChanneling();
        }
    }
}

/// Signal sent when a shortcut has been added.
/// This also happens when you teleport to a new pf.
/// Note that you might get an SignalShortcutEnabled right afterward if the shortcut is disabled. And SignalCooldownTime if it's in cooldown.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotShortcutAdded( itemPos:Number) : Void
{
//    Log.Info2( "AbilityBar", "SlotShortcutAdded(" + itemPos + ") ");
    if( IsAbilityShortcut(itemPos) )
    {
        var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
        var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
        var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
        if (spellData)
        {
            var abilitySlot:AbilitySlot = AbilitySlot( m_AbilitySlots[ slotNo ] );
            abilitySlot.SetAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", false, spellData.m_ResourceGenerator);
            abilitySlot.CloseTooltip();
        }
    }
	else if (IsItemShortcut(itemPos))
	{
		var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET);
		var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
		var inventory:Inventory = new Inventory(shortcutData.m_InventoryId);
		if (m_ItemSlots[slotNo].HasItem())
		{
			m_ItemSlots[slotNo].Clear();
		}
		m_ItemSlots[slotNo].SetData(inventory.GetItemAt(shortcutData.m_InventoryPos));		
		m_ItemSlots[slotNo].GetSlotMC()["m_ItemHotkeyLabel"].swapDepths(m_ItemSlots[slotNo].GetIcon());
	}
}

/// Signal sent when a shortcut has been removed.
/// This will not be sent if the shortcut changes position, moved.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotShortcutRemoved( itemPos:Number ) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);

        if ( abilitySlot != undefined )
        {
            abilitySlot.Clear( );
        }        
    }
	else if (IsItemShortcut(itemPos))
	{
		var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET);
		m_ItemSlots[slotNo].Clear();
	}
}


/// Signal sent when a shortcut has been move to some other spot.
/// No add/remove signal will be triggered.
/// @param fromPos:Number   The position the item was move from.
/// @param toPos:Number     The position the item was move to.
function SlotShortcutMoved( p_from:Number, p_to:Number ) : Void
{ 
    SlotShortcutRemoved(p_to);
    SlotShortcutRemoved(p_from);
    
    SlotShortcutAdded(p_to);
    if (Shortcut.m_ShortcutList.hasOwnProperty(p_from+""))
    {
        SlotShortcutAdded(p_from);
    }
}


/// Signal sent when a shortcut is enabled/disabled.
/// Will also be send when you enter a new playfield.
/// @param itemPos:Number   The position of the item.
/// @param enabled:Number   0=disable, 1=enabled
function SlotShortcutEnabled( itemPos:Number, enabled:Boolean ) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        if (abilitySlot.IsActive)
        {
            abilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_DISABLED );
        }
    }
}


/// Signal sent when a shortcut is enabled/disabled via range.
/// @param itemPos:Number   The position of the item.
/// @param enabled:Boolean   Enabled/Disabled
function SlotShortcutRangeEnabled(itemPos:Number, enabled:Boolean) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        
        if (abilitySlot.IsActive)
        {
            abilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_OUT_OF_RANGE );
        }
    }
}


/// Signal sent when a shortcut is enabled/disabled via resource.
/// @param itemPos:Number   The position of the item.
/// @param enabled:Boolean   Enabled/Disabled
function SlotShortcutResourceEnabled(itemPos:Number, enabled:Boolean) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        if (abilitySlot.IsActive)
        {
            abilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_NO_RESOURCE );
        }
    }
}


///Slot function called when an ability is used
/// @param itemPos:Number   The position of the item.
function SlotShortcutUsed(itemPos:Number)
{
    if( IsAbilityShortcut(itemPos) )
    {
        m_UsedShortcut = itemPos;
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        abilitySlot.Fire();
    }
	else if (IsItemShortcut(itemPos))
	{
		var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET);
		m_ItemSlots[slotNo].GetSlotMC().m_UseAnimation.gotoAndPlay("Start");
	}
}

function SlotShortcutAddedToQueue(itemPos:Number)
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        abilitySlot.AddToQueue();
    }
}

function SlotShortcutRemovedFromQueue(itemPos:Number)
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        abilitySlot.RemoveFromQueue();
    }
}

/// Signal that triggers every time the player load the game or teleports or whatever, will call the 
/// SlotShortcutAdded for every shortcut item.
function SlotShortcutsRefresh() : Void
{ 
    Shortcut.RefreshShortcuts( ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS), ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS) );
	Shortcut.RefreshShortcuts( ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET), PLAYER_MAX_ITEM_SHORTCUTS );
}


/// Signal sent when a shortcut changed one of it's stats. Probably most usefull for stacksize changes.
/// @param itemPos:Number   The position of the item.
/// @param stat:Number      The stat that changed. See Enums/Stats.as
/// @param value:Number     The new value for the stat.
function SlotShortcutStatChanged( itemPos:Number, stat:Number, value:Number ) : Void
{
	if (IsItemShortcut(itemPos))
	{
		if (stat == _global.Enums.Stat.e_StackSize)
		{
			var shortcutSlot:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET);
			var itemSlot:ItemSlot = m_ItemSlots[shortcutSlot];
			if (itemSlot != undefined)
			{
				var inventory:Inventory = new Inventory(itemSlot.GetInventoryID());
				var inventoryPosition:Number = itemSlot.GetData().m_InventoryPos;
				itemSlot.UpdateStackSize(inventory.GetItemAt(inventoryPosition));
				return;
			}
		}
		else
		{
			Shortcut.RefreshShortcuts(itemPos, 1);
		}
	}
}

function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean)
{
	for( var i:Number = 0; i < PLAYER_MAX_ITEM_SHORTCUTS; i++)
    {
		var itemSlot = m_ItemSlots[i];
		if (itemSlot.GetInventoryID().Equal(inventoryID) && itemSlot.GetData().m_InventoryPos == itemPos)
		{
			itemSlot.Clear();
		}
	}
}

function SlotItemCooldown(inventoryID:com.Utils.ID32, itemPos:Number, seconds:Number)
{    
    for( var i:Number = 0; i < PLAYER_MAX_ITEM_SHORTCUTS; i++)
    {
		var itemSlot:ItemSlot = m_ItemSlots[i];
		if (itemSlot.GetInventoryID().Equal(inventoryID) && itemSlot.GetData().m_InventoryPos == itemPos)
		{
			if (seconds > 0)
			{
				itemSlot.SetCooldown(seconds);
			}
		}
	}
}

function SlotItemCooldownRemoved(inventoryID:com.Utils.ID32, itemPos:Number)
{
    for( var i:Number = 0; i < PLAYER_MAX_ITEM_SHORTCUTS; i++)
    {
		var itemSlot:ItemSlot = m_ItemSlots[i];
		if (itemSlot.GetInventoryID().Equal(inventoryID) && itemSlot.GetData().m_InventoryPos == itemPos)
		{			
			itemSlot.RemoveCooldown();
		}
	}
}

// Signal sent when a shortcut enters cooldown.
/// Will also be send when you enter a new playfield.
/// @param itemPos:Number       The position of the item.
/// @param cooldownStart:Number The start of the cooldown.
/// @param cooldownEnd:Number The end of the cooldown.
/// @param cooldownFlags:Number  The cooldown type from Enums.TemplateLock...
function SlotCooldownTime( itemPos:Number, cooldownStart:Number, cooldownEnd:Number,  cooldownFlags:Number ) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);

        var seconds:Number = cooldownEnd - cooldownStart;
        if (cooldownFlags > 0 && seconds > 0)
        {
            abilitySlot.AddCooldown( cooldownStart, cooldownEnd, cooldownFlags );
        }
        else if (cooldownFlags == 0 && seconds <= 0)
        {
            abilitySlot.RemoveCooldown();
        }
    }
	else if (IsItemShortcut(itemPos))
	{
		var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_POCKET);
		var currentTime = com.GameInterface.Utils.GetGameTime()
        var currentDuration =  currentTime - cooldownStart;
        var timeLeft = cooldownEnd - currentTime;
		
		var itemSlot:ItemSlot = m_ItemSlots[slotNo];        
        if (itemSlot && timeLeft > 0)
        {
            itemSlot.SetCooldown(timeLeft);
        }
	}
}


/// Method invoked when a shortcut is enters its max momentum.
/// @param itemPos:Number   The position of the item.
function SlotSignalShortcutMaxMomentumEnabled( itemPos:Number, enabled:Boolean ) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        if (abilitySlot.IsActive)
        {
            abilitySlot.UpdateAbilityFlags(enabled, AbilityBase.FLAG_MAX_MOMENTUM );
        }
    }
}


function SlotSignalCommandStarted( name:String, progressBarType:Number) : Void
{
    var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(m_UsedShortcut);
	//Check if it is really channeling
    if (abilitySlot.IsActive && progressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty)
    {
        abilitySlot.StartChanneling();
    }
}

function SlotSignalCommandEnded()
{
	for (var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
	{
		var abilitySlot:ActiveAbilitySlot = m_AbilitySlots[i];
		if (abilitySlot.IsActive && abilitySlot.IsChanneling())
		{
			abilitySlot.StopChanneling();
		}
	}
}

function SlotSignalCommandAborted()
{
    for (var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
	{
		var abilitySlot:ActiveAbilitySlot = m_AbilitySlots[i];
		if (abilitySlot.IsActive)
		{
			abilitySlot.StopChanneling();
		}
	}
}


function GetAbilitySlot(itemPos:Number) : GUI.HUD.ActiveAbilitySlot
{
    var slotID:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
    
    if ( slotID >= 0 && slotID < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS))
    {
        return m_AbilitySlots[ slotID ];
    }
    return null;
    /*
    else
    {
        Log.Warning("AbilityBar", "GetAbilitySlot(), No slot found at " + itemPos);
        return null;
    }*/
}

function onDragBegin( event:Object )
{
    // TODO: HIGLIGHT SLOTS THAT CAN ACCEPT THE DRAGGED OBJECT IF ANY.
    //trace( "Begin drag: " + event.data.type + "(" + event.dropTarget + ")" );
}

function GetMouseSlotID() : Number
{
    var mousePos:flash.geom.Point = new flash.geom.Point;

    mousePos.x = _root._xmouse;
    mousePos.y = _root._ymouse;

    for ( var i in m_AbilitySlots )
    {
        var abilitySlot:AbilitySlot = m_AbilitySlots[i];

        if ( abilitySlot.Slot.hitTest( mousePos.x, mousePos.y, true ) )
        {
            return abilitySlot.GetSlotId();
        }
    }
    return -1;
}

function onDragEnd( event:Object )
{
    //Check if the mouse is really hovering this movieclip (and not something above it)
    if (Mouse["IsMouseOver"](this))
    {
        if ( event.data.type == "spell" )
        {
            var dstID = GetMouseSlotID();
            if ( dstID >= 0 )
            {
                event.data.DragHandled();
                Shortcut.AddSpell( dstID, event.data.id );
            }
        }
        else if ( event.data.type == "shortcutbar/activeability" )
        {
            var dstID = GetMouseSlotID();

            if ( dstID >= 0 )
            {
                Shortcut.MoveShortcut( event.data.slot_index, dstID );
                event.data.DragHandled();
            }
        }
    }
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if(edit)
	{
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("AbilityBarScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("AbilityBarScale", 100) / 100;
	var yModifier:Number = 0;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y - yModifier) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "AbilityBarX" );
	var newY:DistributedValue = DistributedValue.Create( "AbilityBarY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);
	m_InitialY = this._y;
}

function LayoutEditModeMask()
{
	m_EditModeMask.swapDepths(this.getNextHighestDepth());
	m_EditModeMask._x = -5;
	m_EditModeMask._width = m_BigWidth + 15;
	m_EditModeMask._y = -5;
	m_EditModeMask._height = m_BaseHeight + 10
}


