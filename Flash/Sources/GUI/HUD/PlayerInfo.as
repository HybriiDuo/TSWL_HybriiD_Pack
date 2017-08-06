import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Dynel;
//import com.GameInterface.Inventory;
//import com.GameInterface.InventoryItem;
import mx.utils.Delegate;

#include "CharacterInfo.as"

//var m_PlayerShield:MovieClip;
//var m_Inventory:Inventory;
//var m_Shields:Object;

var m_EditModeMask:MovieClip;

/*
var PSYCHIC_SHIELD:Number = 111;
var TECH_SHIELD:Number = 113;
var DEMONIC_SHIELD:Number = 114;
*/

function onLoad() 
{
	ShowName(false);
	m_IsPlayer = true;
	Initialize();
	InitializeShieldSwap();
	CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	
	if(Character.GetClientCharacter() != undefined)
	{
		SetDynel( Character.GetClientCharacter());
		m_Dynel.SignalStatChanged.Connect(SlotStatChanged, this);
		
		/*
		var clientCharID:ID32 = Character.GetClientCharID();
		m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, clientCharID.GetInstance()));
		m_Inventory.SignalItemAdded.Connect(SlotItemAdded, this);
		m_Inventory.SignalItemLoaded.Connect(SlotItemLoaded, this);
		m_Inventory.SignalItemMoved.Connect(SlotItemMoved, this);
		m_Inventory.SignalItemChanged.Connect(SlotItemChanged, this);
		m_Inventory.SignalItemRemoved.Connect(SlotItemRemoved, this);
		
		FindAegisShields();
		UpdateShieldType();
		*/
	}
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
}

function SlotClientCharacterAlive()
{
	SetDynel( Character.GetClientCharacter());
	m_Dynel.SignalStatChanged.Connect(SlotStatChanged, this);
	/*
	UpdateShieldType();

	var clientCharID:ID32 = Character.GetClientCharID();
	m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, clientCharID.GetInstance()));
	m_Inventory.SignalItemAdded.Connect(SlotItemAdded, this);
	m_Inventory.SignalItemLoaded.Connect(SlotItemLoaded, this);
	m_Inventory.SignalItemMoved.Connect(SlotItemMoved, this);
	m_Inventory.SignalItemChanged.Connect(SlotItemChanged, this);
	m_Inventory.SignalItemRemoved.Connect(SlotItemRemoved, this);
	*/
	
	//FindAegisShields();
}

/*
function SlotStatChanged( stat:Number, value:Number  )
{
	if (stat == _global.Enums.Stat.e_PlayerAegisShieldType )
	{
		UpdateShieldType();
	}
}
*/

/*
function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number)
{
	var item:InventoryItem = m_Inventory.GetItemAt(itemPos);
	if (item.m_ItemType == _global.Enums.ItemType.e_ItemType_AegisShield)
	{
		switch (item.m_AegisItemType)
		{
			case PSYCHIC_SHIELD:
				m_Shields.psychic = itemPos;
				m_PlayerShield.m_SwapBar.m_Psychic.m_Icon._alpha = 100;
				break;
			case TECH_SHIELD:
				m_Shields.tech = itemPos;
				m_PlayerShield.m_SwapBar.m_Tech.m_Icon._alpha = 100;
				break;
			case DEMONIC_SHIELD:
				m_Shields.demonic = itemPos;
				m_PlayerShield.m_SwapBar.m_Demonic.m_Icon._alpha = 100;
				break
		}
	}
}
*/

/*
function SlotItemLoaded(inventoryID:com.Utils.ID32, itemPos:Number)
{
	SlotItemAdded(inventoryID, itemPos);
}

function SlotItemMoved(inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number)
{
	SlotItemAdded(inventoryID, toPos);
}

function SlotItemChanged(inventoryID:com.Utils.ID32, itemPos:Number)
{
	SlotItemRemoved(inventoryID, itemPos, false);
	SlotItemAdded(inventoryID, itemPos);
}

function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean)
{
	switch (itemPos)
	{
		case m_Shields.psychic:
			m_Shields.psychic = undefined;
			m_PlayerShield.m_SwapBar.m_Psychic.m_Icon._alpha = 20;
			break;
		case m_Shields.tech:
			m_Shields.tech = undefined;
			m_PlayerShield.m_SwapBar.m_Tech.m_Icon._alpha = 20;
			break;
		case m_Shields.demonic:
			m_Shields.demonic = undefined;
			m_PlayerShield.m_SwapBar.m_Demonic.m_Icon._alpha = 20;
			break;
	}
}
*/

/*
function FindAegisShields()
{
	m_Shields = new Object;
	m_PlayerShield.m_SwapBar.m_Psychic.m_Icon._alpha = 20;
	m_PlayerShield.m_SwapBar.m_Tech.m_Icon._alpha = 20;
	m_PlayerShield.m_SwapBar.m_Demonic.m_Icon._alpha = 20;
	for (var i=0; i<m_Inventory.GetMaxItems(); i++)
	{
		SlotItemAdded(m_Inventory.GetInventoryID(), i);
	}
}
*/

/*
function InitializeShieldSwap()
{
	m_PlayerShield = attachMovie("Shield_Swapper", "m_PlayerShield", getNextHighestDepth()); 
	m_PlayerShield._x = m_HealthBar.m_ShieldBar._x - m_PlayerShield.m_ShieldSwapButton._width - 5;
	m_PlayerShield._y = m_HealthBar.m_Bar._y + (m_HealthBar.m_Bar._height/2) - (m_PlayerShield.m_ShieldSwapButton._height/2);
	m_PlayerShield.m_SwapBar._visible = false;
	
	m_PlayerShield.m_ShieldSwapButton.onRelease = ToggleSwapBar;
	m_PlayerShield.m_SwapBar.m_Psychic.onRollOver = m_PlayerShield.m_SwapBar.m_Tech.onRollOver = m_PlayerShield.m_SwapBar.m_Demonic.onRollOver = HighlightShield;
	m_PlayerShield.m_SwapBar.m_Psychic.onRollOut = m_PlayerShield.m_SwapBar.m_Tech.onRollOut = m_PlayerShield.m_SwapBar.m_Demonic.onRollOut = DimShield;
	
	m_PlayerShield.m_SwapBar.m_Psychic.onRelease = EquipPsychicShield;
	m_PlayerShield.m_SwapBar.m_Tech.onRelease = EquipTechShield;
	m_PlayerShield.m_SwapBar.m_Demonic.onRelease = EquipDemonicShield;
}
*/

/*
function UpdateShieldType()
{
	switch(m_Dynel.GetStat( _global.Enums.Stat.e_PlayerAegisShieldType, 2))
	{
		case _global.Enums.AegisTypes.e_AegisNONE:
			m_PlayerShield.m_ShieldSwapButton._visible = false;
			break;
		case _global.Enums.AegisTypes.e_AegisPink:
			m_PlayerShield.m_ShieldSwapButton._visible = true;
			m_PlayerShield.m_ShieldSwapButton.m_Psychic._visible = true;
			m_PlayerShield.m_ShieldSwapButton.m_Tech._visible = false;
			m_PlayerShield.m_ShieldSwapButton.m_Demonic._visible = false;
			break;
		case _global.Enums.AegisTypes.e_AegisBlue:
			m_PlayerShield.m_ShieldSwapButton._visible = true;
			m_PlayerShield.m_ShieldSwapButton.m_Psychic._visible = false;
			m_PlayerShield.m_ShieldSwapButton.m_Tech._visible = true;
			m_PlayerShield.m_ShieldSwapButton.m_Demonic._visible = false;
			break;
		case _global.Enums.AegisTypes.e_AegisRed:
			m_PlayerShield.m_ShieldSwapButton._visible = true;
			m_PlayerShield.m_ShieldSwapButton.m_Psychic._visible = false;
			m_PlayerShield.m_ShieldSwapButton.m_Tech._visible = false;
			m_PlayerShield.m_ShieldSwapButton.m_Demonic._visible = true;
			break;
	}
}
*/

/*
function ToggleSwapBar()
{
	m_PlayerShield.m_SwapBar._visible = !m_PlayerShield.m_SwapBar._visible;
	if (m_PlayerShield.m_SwapBar._visible)
	{
		m_PlayerShield.m_SwapBar.onMouseUp = function()
		{ 
			if(!m_PlayerShield.m_ShieldSwapButton.hitTest(_root._xmouse, _root._ymouse) && !m_PlayerShield.m_SwapBar.hitTest(_root._xmouse, _root._ymouse))
			{
				this._visible = false; 
			}
		}		
	}
}
*/

 /*
function EquipPsychicShield()
{
	if (m_Shields.psychic != undefined)
	{
		m_Inventory.UseItem(m_Shields.psychic);
		ToggleSwapBar();
	}
}

function EquipTechShield()
{
	if (m_Shields.tech != undefined)
	{
		m_Inventory.UseItem(m_Shields.tech);
		ToggleSwapBar();
	}
}

function EquipDemonicShield()
{
	if (m_Shields.demonic != undefined)
	{
		m_Inventory.UseItem(m_Shields.demonic);
		ToggleSwapBar();
	}
}
*/

/*
function HighlightShield()
{
	this.m_Background._alpha = 20;
}

function DimShield()
{
	this.m_Background._alpha = 0;
}
*/

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if(edit)
	{
		m_EditModeMask.swapDepths(this.getNextHighestDepth());
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("PlayerInfoScale");
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
	scale *= DistributedValue.GetDValue("PlayerInfoScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "PlayerInfoX" );
	var newY:DistributedValue = DistributedValue.Create( "PlayerInfoY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);
	
}

function LayoutEditModeMask()
{
	m_EditModeMask._x = m_HealthBar.m_AegisDamageType._x - 5;
	m_EditModeMask._y = -33; //-33 to match the name on the target Info
	m_EditModeMask._width = m_HealthBar._width + 25;
	m_EditModeMask._height = m_HealthBar._height + 15 + 33;
}
