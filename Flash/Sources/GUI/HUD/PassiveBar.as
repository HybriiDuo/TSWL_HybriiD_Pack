/// this is all the logic applying to the PassiveBar
import GUI.HUD.AbilitySlot;
import GUI.HUD.AbilityBase;
import GUI.HUD.PassiveAbilitySlot;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Game.Character;
import com.GameInterface.Spell;
import com.GameInterface.SpellData;
import com.GameInterface.SpellBase;
import com.GameInterface.DistributedValue;
import com.GameInterface.Lore
import com.GameInterface.Log;
import com.GameInterface.Utils;
import com.Utils.Colors;
import com.Utils.Signal;
import com.Utils.Archive;
import com.Utils.LDBFormat;
import com.Utils.GlobalSignal;
import mx.utils.Delegate;
import com.Components.FCButton;
import gfx.motion.Tween;
import mx.transitions.easing.*;

var m_PassiveAbilitySlots:Array;
var m_NumAbilities:Number = 8;
var m_PassiveBarActive:Boolean;
var m_AbilityBarVisible:DistributedValue;

var SizeChanged:Signal;

var ULTIMATE_ABILITY_UNLOCK:Number = 7783;

var m_UltimateProgress:MovieClip;

var m_Character:Character;
var m_BaseWidth:Number;
var m_InitialY:Number;

function onLoad()
{
	m_BaseWidth = _width;
	
	/// connect the signals
	Spell.SignalPassiveUpdate.Connect( GetAllPassives, this );
	Spell.SignalPassiveAdded.Connect( SlotPassiveAdded, this  );
	Spell.SignalPassiveRemoved.Connect( SlotPassiveRemoved, this );
    
    Shortcut.SignalSwapBar.Connect( SlotSwapBar, this);
    Shortcut.SignalRestoreSwapBar.Connect( SlotRestoreSwapBar, this);
	
	com.Utils.GlobalSignal.SignalAbilityBarDrag.Connect(SlotAbilityBarDrag, this);
	
	/// check if the passives bar opens or closes
	m_PassiveBarActive = false;
    
	// the button that moves the bar up and down.
	GlobalSignal.SignalShowPassivesBar.Connect(SlotShowPassivesBar, this);
	m_Button.addEventListener("press", this, "SlotTogglePassiveBar");
    gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "SlotDragBegin" );
    gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "SlotDragEnd" );
    SizeChanged = new Signal();

    InitializeBar();   
    GetAllPassives(); 

    m_Bar._alpha = 0;    
    m_Bar.onTweenComplete = function()
    { 
       	SizeChanged.Emit();
    }
	
	m_AbilityBarVisible = DistributedValue.Create( "ability_bar_visibility" );
    m_AbilityBarVisible.SignalChanged.Connect( SlotAbilityBarVisibilityChanged, this);
	
	Lore.SignalTagAdded.Connect(SlotTagAdded, this);
	
	m_Character = Character.GetClientCharacter();
	m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
		
	if (!Lore.IsLocked(ULTIMATE_ABILITY_UNLOCK))
	{
		CreateUltimateAbilityProgress();
	}
	
	this._visible = Boolean(m_AbilityBarVisible.GetValue());
}


function onUnload()
{
    Spell.SignalPassiveUpdate.Disconnect( GetAllPassives, this );
    Spell.SignalPassiveAdded.Disconnect( SlotPassiveAdded, this  );
    Spell.SignalPassiveRemoved.Disconnect( SlotPassiveRemoved, this );
    
    Shortcut.SignalSwapBar.Disconnect( SlotSwapBar, this);
    Shortcut.SignalRestoreSwapBar.Disconnect( SlotRestoreSwapBar, this);

    gfx.managers.DragManager.instance.removeEventListener( "dragBegin", this, "SlotDragBegin" );
    gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "SlotDragEnd" );

    Lore.SignalTagAdded.Disconnect(SlotTagAdded, this);
}

function SlotAbilityBarVisibilityChanged()
{
	this._visible = Boolean(m_AbilityBarVisible.GetValue());
}

function SlotStatChanged(statID:Number):Void
{
	if (statID == _global.Enums.Stat.e_AnimaEnergy)
	{
		UpdateUltimateAbilityProgress();
	}
}

function SlotTagAdded(tag:Number)
{
	if (tag == ULTIMATE_ABILITY_UNLOCK)
	{
		CreateUltimateAbilityProgress();
	}
}

/// sets up the empty PassiveAbilityslots, and if opened, opens the passive bar
function InitializeBar()
{
    m_PassiveAbilitySlots = [];
 
    // loop the hive and push each of the slots in the m_AbilitySlots array.
    for( var i:Number = 0; i < m_NumAbilities; i++)
    {
        var mc_slot:MovieClip = MovieClip( m_Bar["slot_"+i] );

        if( mc_slot != null )
        {
            m_PassiveAbilitySlots.push( new PassiveAbilitySlot( mc_slot, i ) );
        }
        else
        {
            Log.Error( "PassiveBar", " Failed to retrieve a valid slot at index "+i);
        }
    }
}


/// triggers when there is a change to the Passive Lists distributed value
function SlotPassiveListOpenValueChanged(value:DistributedValue)
{
    var isOpen:Boolean = Boolean( value.GetValue() );
    m_Button.disabled = isOpen;
    TogglePassiveBar(isOpen);
}

function SlotTogglePassiveBar(e:Object)
{
    m_PassiveBarActive = !m_PassiveBarActive;
    TogglePassiveBar(m_PassiveBarActive);
}

function SlotShowPassivesBar(show:Boolean)
{
	TogglePassiveBar(show);
}

function TogglePassiveBar(show:Boolean)
{
    if (show)
    {
        OpenPassiveBar();
    }
    else
    {
        ClosePassiveBar();
    }
}

// opens the bar as a result of the button being pressed or the the passivelist being opened
function OpenPassiveBar()
{
	var riseHeight:Number = -40;
    m_Bar.tweenTo(0.3, { _y: riseHeight, _alpha:100 }, Regular.easeOut );
	m_UltimateProgress.tweenTo(0.3, { _y: 0 - 13 + riseHeight }, Regular.easeOut );
    m_Button._rotation = 180; 
}

// opens the bar as a result of the button being pressed or the the passivelist being opened
function ClosePassiveBar()
{
	var riseHeight:Number = 40;
    m_Bar.tweenTo(0.3, { _y: 0, _alpha:0}, Regular.easeOut );
	m_UltimateProgress.tweenTo(0.3, { _y: 0 - 13 }, Regular.easeOut );
    m_Button._rotation = 0;
}

/// Gets all the equipped passives and 
function GetAllPassives()  : Void
{
	for ( var i:Number = 0; i < m_NumAbilities; i++)
	{
		var passiveID:Number = Spell.GetPassiveAbility(i);
        var passiveData:SpellData = Spell.m_PassivesList[passiveID];
        var abilityslot:AbilitySlot = AbilitySlot( m_PassiveAbilitySlots[ i ] );
		if (passiveData != undefined)
		{
			abilityslot.SetAbilityData( Utils.CreateResourceString(passiveData.m_Icon), passiveData.m_ColorLine, passiveData.m_Id, passiveData.m_SpellType, "Passive", false, passiveData.m_ResourceGenerator );
		}
        else if(abilityslot.IsActive)
        {
            abilitiyslot.Clear();
        }
	}
}

function debugObject(obj:Object)
{
    for (var prop in obj)
    {
        if ( obj[prop].toString() == "[object Object]" )
        {
            debugObject( obj[prop] )
        }
        
    }
}

function SlotDragBegin( event:Object )
{
    // TODO: HIGLIGHT SLOTS THAT CAN ACCEPT THE DRAGGED OBJECT IF ANY.
}


function SlotDragEnd( event:Object )
{
    //Check if the mouse is really hovering this movieclip (and not something above it)
    if (Mouse["IsMouseOver"](this))
    {
        if (event.data.type == "passive")
        {
            var dstID = GetMouseSlotID();
            if ( dstID >= 0 ) 
            {
                event.data.DragHandled();
                Spell.EquipPassiveAbility( dstID, event.data.id );
            }
         }
        else if ( event.data.type == "shortcutbar/passiveability" ) //Dragging from a passive ability bar
        {
            var dstID = GetMouseSlotID();

            if ( dstID >= 0)
            {
                event.data.DragHandled();
                if (dstID != event.data.slot_index && m_PassiveAbilitySlots[ event.data.slot_index ].IsActive)
                {
                    Spell.MovePassiveAbility(event.data.slot_index, dstID);
                }
            }
        }
    }
}

function GetMouseSlotID() : Number
{
  var mousePos:flash.geom.Point = new flash.geom.Point;

  mousePos.x = _root._xmouse;
  mousePos.y = _root._ymouse;

  for ( var i in m_PassiveAbilitySlots )
  {
    var abilitySlot:AbilitySlot = m_PassiveAbilitySlots[i];
	
    if ( abilitySlot.Slot.hitTest( mousePos.x, mousePos.y, true ) )
	{
		return abilitySlot.GetSlotId();
	}
  }
  return -1;
}

/// Signal sent when a shortcut has been added.
/// This also happens when you teleport to a new pf.
/// Note that you might get an SignalShortcutEnabled right afterward if the shortcut is disabled. And SignalCooldownTime if it's in cooldown.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotPassiveAdded( itemPos:Number) : Void
{
    //Add the icon
	if ( itemPos >= 0 && itemPos < m_NumAbilities )
	{
        var passiveID:Number = Spell.GetPassiveAbility(itemPos);
        var passiveData:SpellData = Spell.m_PassivesList[passiveID];
        // First make sure it's removed. Might be something here if messages from server are delayed.
        SlotPassiveRemoved(itemPos);
		var abilityslot:AbilitySlot = AbilitySlot( m_PassiveAbilitySlots[ itemPos ] );

		abilityslot.SetAbilityData(  Utils.CreateResourceString(passiveData.m_Icon), passiveData.m_ColorLine, passiveData.m_Id, passiveData.m_SpellType, "Passive", false, passiveData.m_ResourceGenerator );
	} 
	else 
	{
		Log.Error( "PassiveBar", "SlotPassiveAdded failed when adding passive to slot: "+itemPos);
	}
}

/// Signal sent when a shortcut has been removed.
/// This will not be sent if the shortcut changes position, moved.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotPassiveRemoved( itemPos:Number ) : Void
{
	if ( itemPos >= 0 && itemPos < m_NumAbilities )
	{
        var abilityslot:AbilitySlot = m_PassiveAbilitySlots[ itemPos ];
        abilityslot.Clear( );
	}
	else 
	{
		Log.Error( "PassiveBar", "SlotPassiveRemoved failed when removing an ability from slot: "+itemPos);
	}
}

function SlotSwapBar(templates:Array):Void
{
    var position:Number = m_InitialY + 50;
    this.tweenTo(0.3, { _y:position, _alpha:0 }, mx.transitions.easing.Regular.easeOut );
    this.onTweenComplete = function() { this._visible = false;  };
}
    
function SlotRestoreSwapBar(templates:Array):Void
{
    //Delay other 0.3s the animation, so ActiveBar can appear
    _global.setTimeout( Delegate.create(this, RestoreSwapBar), 300);
}

function RestoreSwapBar():Void
{
    if (!this._visible)
    {
        this._visible = true;
        var position:Number = m_InitialY;
        this.tweenTo(0.3, { _y:position, _alpha:100 }, mx.transitions.easing.Regular.easeOut );
        this.onTweenComplete = function() { };
    }
}

function CreateUltimateAbilityProgress()
{
	if (m_UltimateProgress != undefined)
	{
		return;
	}
	m_UltimateProgress = attachMovie("UltimateProgressBar", "m_UltimateProgress", getNextHighestDepth());
	m_UltimateProgress._y = -13;
	m_UltimateProgress._x = 32;
	UpdateUltimateAbilityProgress();
}

function UpdateUltimateAbilityProgress()
{
	if (m_UltimateProgress != undefined)
	{
		var charge:Number = m_Character.GetStat( _global.Enums.Stat.e_AnimaEnergy, 2 );
		var percentage:Number = Math.min(charge/100, 1); //if charge is over 100%, just show 100%
		m_UltimateProgress.m_Content._width = (m_UltimateProgress.m_Background._width - 1) * percentage;
		if (percentage < 1)
		{
			if (m_UltimateProgress.m_Glow.onTweenComplete != undefined)
			{
				m_UltimateProgress.m_Glow.tweenEnd();
				m_UltimateProgress.m_Glow.onTweenComplete = undefined;
			}
			m_UltimateProgress.m_Glow._alpha = percentage * 100;
		}
		else if (m_UltimateProgress.m_Glow.onTweenComplete == undefined)
		{
			m_UltimateProgress.m_Glow.tweenTo(0.6, {_alpha:0}, None.easeNone);
			m_UltimateProgress.m_Glow.onTweenComplete = Delegate.create(this, PulseUltimate);
		}
	}
}

function PulseUltimate()
{
	if (m_UltimateProgress.m_Glow._alpha == 0)
	{
		m_UltimateProgress.m_Glow.tweenTo(0.6, {_alpha:100}, None.easeNone);
	}
	else
	{
		m_UltimateProgress.m_Glow.tweenTo(0.6, {_alpha:0}, None.easeNone);
	}
}

function onLoadInit(target:MovieClip)
{
	target._xscale = 35;
	target._yscale = 35;
}

function SlotAbilityBarDrag(newX:Number, newY:Number)
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("AbilityBarScale", 100) / 100;
	this._x = newX + 25 * scale;
	this._y = newY;
	m_InitialY = this._y;
}

