import mx.utils.Delegate;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Utils;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Lore
import com.GameInterface.PvPMinigame.PvPMinigame;
import GUI.HUD.AbilitySlot;
import GUI.HUD.ActiveAbilitySlot;
import GUI.HUD.AbilityBase;

var m_EditModeMask:MovieClip;
var m_Slot:MovieClip;
var m_HotkeyLabel:MovieClip;

var m_AbilitySlot:ActiveAbilitySlot;
var m_Character:Character;
var m_UsedShortcut:Boolean;
var m_BarSwapped:Boolean;
var m_Visibility:Number;

var m_VisibilityMonitor:DistributedValue;
var m_ShowHotkeys:DistributedValue;

var VISIBILITY_NEVER:Number = 0;
var VISIBILITY_CHARGED:Number = 1;
var VISIBILITY_ALWAYS:Number = 2;

var ULTIMATE_ABILITY_UNLOCK:Number = 7783;

function onLoad() : Void
{	
	m_AbilitySlot = new ActiveAbilitySlot( m_Slot, _global.Enums.UltimateAbilityShortcutSlots.e_UltimateShortcutBarFirstSlot );
	m_HotkeyLabel = attachMovie("HotkeyLabel", "m_HotkeyLabel", getNextHighestDepth());
	m_HotkeyLabel._x = m_Slot._x + 5;
	m_HotkeyLabel._y = m_Slot._y + 5;
	
	/// connect the signals
	m_VisibilityMonitor = DistributedValue.Create( "ultimate_ability_visibility" );
	m_VisibilityMonitor.SignalChanged.Connect( SlotVisibilityChanged, this );
	m_ShowHotkeys = DistributedValue.Create( "ShortcutbarHotkeysVisible" );
    m_ShowHotkeys.SignalChanged.Connect( SlotShortcutbarHotkeysVisibleChanged, this);
	
	Shortcut.SignalShortcutAdded.Connect( SlotShortcutAdded, this  );
	Shortcut.SignalShortcutRemoved.Connect( SlotShortcutRemoved, this );
	Shortcut.SignalShortcutMoved.Connect( SlotShortcutMoved, this );
	Shortcut.SignalShortcutStatChanged.Connect( SlotShortcutStatChanged, this );
	/*
    Shortcut.SignalShortcutEnabled.Connect( SlotShortcutEnabled, this );
    Shortcut.SignalShortcutRangeEnabled.Connect( SlotShortcutRangeEnabled, this );
	*/
    Shortcut.SignalShortcutUsed.Connect( SlotShortcutUsed, this );
    Shortcut.SignalShortcutAddedToQueue.Connect( SlotShortcutAddedToQueue, this );
    Shortcut.SignalShortcutRemovedFromQueue.Connect( SlotShortcutRemovedFromQueue, this );
	Shortcut.SignalCooldownTime.Connect( SlotCooldownTime,this );
	Shortcut.SignalShortcutsRefresh.Connect( SlotShortcutsRefresh, this );
    Shortcut.SignalHotkeyChanged.Connect( SlotHotkeyChanged, this );
    Shortcut.SignalSwapShortcut.Connect( SlotSwapShortcut, this);
	Shortcut.SignalSwapBar.Connect( SlotSwapBar, this);
    Shortcut.SignalRestoreSwapBar.Connect( SlotRestoreSwapBar, this);
	
	m_Character = Character.GetClientCharacter();
    m_Character.SignalCommandStarted.Connect(SlotSignalCommandStarted, this);
    m_Character.SignalCommandEnded.Connect(SlotSignalCommandEnded, this);
    m_Character.SignalCommandAborted.Connect(SlotSignalCommandAborted, this);
	m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
	
	Lore.SignalTagAdded.Connect(SlotTagAdded, this);
	
	PvPMinigame.SignalPvPMatchMakingMatchRemoved.Connect( UpdateVisibility, this );
    PvPMinigame.SignalPvPMatchMakingMatchStarted.Connect( UpdateVisibility, this );
    PvPMinigame.SignalPvPMatchMakingMatchEnded.Connect( UpdateVisibility, this );
	    
    // Update Hotkey Labels
    SlotHotkeyChanged();
    SlotShortcutbarHotkeysVisibleChanged();

	//Setup editing controls
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;	
}

function OnModuleActivated()
{
	//We have to do this here, because the module system will set the visibility of the base component when it runs
	//Update the visibility
	SlotVisibilityChanged();
	//Refresh the shortcut
	SlotShortcutsRefresh();
}

function onUnload() : Void
{    
    Shortcut.SignalShortcutAdded.Disconnect( SlotShortcutAdded, this );
    Shortcut.SignalShortcutRemoved.Disconnect( SlotShortcutRemoved, this );
    Shortcut.SignalShortcutMoved.Disconnect( SlotShortcutMoved, this );
    Shortcut.SignalShortcutStatChanged.Disconnect( SlotShortcutStatChanged, this );
	/*
    Shortcut.SignalShortcutEnabled.Disconnect( SlotShortcutEnabled, this );
    Shortcut.SignalShortcutRangeEnabled.Disconnect( SlotShortcutRangeEnabled, this );
	*/
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
	m_Character.SignalStatChanged.Disconnect(SlotStatChanged, this);
	
	Lore.SignalTagAdded.Disconnect(SlotTagAdded, this);
}

function SlotTagAdded(tag:Number)
{
	if (tag == ULTIMATE_ABILITY_UNLOCK)
	{
		SlotVisibilityChanged();
	}
}

function SlotStatChanged(stat:Number) : Void
{
	if (stat == _global.Enums.Stat.e_AnimaEnergy)
	{
		if (m_Visibility == VISIBILITY_CHARGED)
		{
			SetVisibilityByCharge();
		}
	}
}

function SlotVisibilityChanged() : Void
{
	if (Lore.IsLocked(ULTIMATE_ABILITY_UNLOCK) || m_BarSwapped || PvPMinigame.InPvPPlayfield())
	{
		this._visible = false
	}
	else
	{
		m_Visibility = m_VisibilityMonitor.GetValue();
		switch(m_Visibility)
		{
			case VISIBILITY_NEVER:
				this._visible = false;
				break;
			case VISIBILITY_CHARGED:
				SetVisibilityByCharge();
				break;
			case VISIBILITY_ALWAYS:
				this._visible = true;
				break;
			default:
				this._visible = true;
		}
	}
}

function SetVisibilityByCharge() : Void
{
	if (Lore.IsLocked(ULTIMATE_ABILITY_UNLOCK) || m_BarSwapped)
	{
		this._visible = false
	}
	else
	{
		if (m_Character.GetStat( _global.Enums.Stat.e_AnimaEnergy, 2 ) >= 100 || m_EditModeMask._visible)
		{
			this._visible = true;
		}
		else
		{
			this._visible = false;
		}
	}
}

function SlotHotkeyChanged(hotkeyId:Number) : Void
{
	m_HotkeyLabel.m_HotkeyText.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
	m_HotkeyLabel.m_HotkeyText.text = "<variable name='hotkey:" + "Shortcutbar_Ultimate'/ >";
}

function SlotShortcutbarHotkeysVisibleChanged() : Void
{
	m_HotksyLabel._visible = Boolean(m_ShowHotkeys.GetValue());
}

/// Signal that triggers every time the player load the game or teleports or whatever, will call the 
/// SlotShortcutAdded for every shortcut item.
function SlotShortcutsRefresh() : Void
{ 
    Shortcut.RefreshShortcuts( _global.Enums.UltimateAbilityShortcutSlots.e_UltimateShortcutBarFirstSlot, 1 );
}

/// Signal sent when a shortcut has been added.
/// This also happens when you teleport to a new pf.
/// Note that you might get an SignalShortcutEnabled right afterward if the shortcut is disabled. And SignalCooldownTime if it's in cooldown.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotShortcutAdded( itemPos:Number) : Void
{
    if( IsUltimateShortcut(itemPos) )
    {
        var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
        var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
        if (spellData)
        {
            var abilitySlot:AbilitySlot = AbilitySlot( m_AbilitySlot );
			var showReflections:Boolean = false;
            abilitySlot.SetAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", showReflections, spellData.m_ResourceGenerator);
            abilitySlot.CloseTooltip();
        }
    }    
}

/// Signal sent when a shortcut has been removed.
/// This will not be sent if the shortcut changes position, moved.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotShortcutRemoved( itemPos:Number ) : Void
{
    if( IsUltimateShortcut(itemPos) )
    {
        if ( m_AbilitySlot != undefined )
        {
            m_AbilitySlot.Clear();
        }
    }
}

/// Signal sent when a shortcut has been move to some other spot.
/// This probably won't ever affect the Ultimate Ability, but pay attention just to be sure
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

/* Ultimate Ability is disabled while moving. This doesn't play well with the enabled/disabled GUI system, so just always show enabled

/// Signal sent when a shortcut is enabled/disabled.
/// Will also be send when you enter a new playfield.
/// @param itemPos:Number   The position of the item.
/// @param enabled:Number   0=disable, 1=enabled
function SlotShortcutEnabled( itemPos:Number, enabled:Boolean ) : Void
{
    if( IsUltimateShortcut(itemPos) )
    {
        if (m_AbilitySlot.IsActive)
        {
            m_AbilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_DISABLED );
        }
    }
}

/// Signal sent when a shortcut is enabled/disabled via range.
/// @param itemPos:Number   The position of the item.
/// @param enabled:Boolean   Enabled/Disabled
function SlotShortcutRangeEnabled(itemPos:Number, enabled:Boolean) : Void
{
    if( IsUltimateShortcut(itemPos) )
    {    
        if (m_AbilitySlot.IsActive)
        {
            m_AbilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_OUT_OF_RANGE );
        }
    }
}

*/

///Slot function called when an ability is used
/// @param itemPos:Number   The position of the item.
function SlotShortcutUsed(itemPos:Number) : Void
{
    if( IsUltimateShortcut(itemPos) )
    {
        m_UsedShortcut = true;
        m_AbilitySlot.Fire();
    }
	else
	{
		m_UsedShortcut = false;
	}
}

function SlotShortcutAddedToQueue(itemPos:Number) : Void
{
    if( IsUltimateShortcut(itemPos) )
    {
        m_AbilitySlot.AddToQueue();
    }
}

function SlotShortcutRemovedFromQueue(itemPos:Number) : Void
{
    if( IsUltimateShortcut(itemPos) )
    {
        m_AbilitySlot.RemoveFromQueue();
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
    if( IsUltimateShortcut(itemPos) )
    {
        var seconds:Number = cooldownEnd - cooldownStart;
        if (cooldownFlags > 0 && seconds > 0)
        {
            m_AbilitySlot.AddCooldown( cooldownStart, cooldownEnd, cooldownFlags );
        }
        else if (cooldownFlags == 0 && seconds <= 0)
        {
            m_AbilitySlot.RemoveCooldown();
        }
    }
}


/// Method invoked when a shortcut is enters its max momentum.
/// @param itemPos:Number   The position of the item.
function SlotSignalShortcutMaxMomentumEnabled( itemPos:Number, enabled:Boolean ) : Void
{
    if( IsUltimateShortcut(itemPos) )
    {
        if (m_AbilitySlot.IsActive)
        {
            m_AbilitySlot.UpdateAbilityFlags(enabled, AbilityBase.FLAG_MAX_MOMENTUM );
        }
    }
}


function SlotSignalCommandStarted( name:String, progressBarType:Number) : Void
{
	if (m_UsedShortcut)
	{
		//Check if it is really channeling
		if (m_AbilitySlot.IsActive && progressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty)
		{
			m_AbilitySlot.StartChanneling();
		}
	}
}

function SlotSignalCommandEnded() : Void
{
	if (m_AbilitySlot.IsActive && m_AbilitySlot.IsChanneling())
	{
		m_AbilitySlot.StopChanneling();
	}
}

function SlotSignalCommandAborted() : Void
{
	if (m_AbilitySlot.IsActive)
	{
		m_AbilitySlot.StopChanneling();
	}
}

function SlotSwapShortcut(itemPos:Number, templateID:Number, switchBackTime:Number):Void
{
    if( IsUltimateShortcut(itemPos) )
    {
        SwapAbilities(itemPos, switchBackTime);
    }
}

function SwapAbilities(itemPos:Number, swapBackTime:Number):Void
{
    if (itemPos != undefined)
    {
        if( IsUltimateShortcut(itemPos) )
        {
            var slotNo:Number = _global.Enums.UltimateAbilityShortcutSlots.e_UltimateShortcutBarFirstSlot;
            var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
            var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
            var abilitySlot:AbilitySlot = AbilitySlot( m_AbilitySlot );
			var showReflections:Boolean = false
            abilitySlot.SwapAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", showReflections, swapBackTime, spellData.m_ResourceGenerator);
            abilitySlot.CloseTooltip();
        }
    }
}

function SlotSwapBar(spellTemplates:Array):Void
{
	m_BarSwapped = true;
	SlotVisibilityChanged();
}

function SlotRestoreSwapBar():Void
{
	m_BarSwapped = false;
	SlotVisibilityChanged();
}

//Right now it just pulls the first equipped active
function IsUltimateShortcut(itemPos:Number):Boolean
{
    var slotNo:Number = itemPos - _global.Enums.UltimateAbilityShortcutSlots.e_UltimateShortcutBarFirstSlot;
    var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
    var checkSpell:Boolean = (shortcutData)?(shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_SpellShortcut) : true;
    if ( slotNo == 0 && checkSpell)
    {
        return true;
    }
    return false;
}

function SlotSetGUIEditMode(edit:Boolean) : Void
{	
	m_EditModeMask._visible = edit;
	if(edit)
	{
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("UltimateAbilityScale");
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
	SlotVisibilityChanged();
}

function SlotEditMaskPressed() : Void
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("UltimateAbilityScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased() : Void
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "UltimateAbilityX" );
	var newY:DistributedValue = DistributedValue.Create( "UltimateAbilityY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);
}

function LayoutEditModeMask() : Void
{	
	m_EditModeMask._x = -5;
	m_EditModeMask._width = m_Slot._width + 10;
	m_EditModeMask._y = -5;
	m_EditModeMask._height = m_Slot._height - 7;
}