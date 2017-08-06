import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Resource;
import com.GameInterface.Tooltip.*;
import com.Components.ResourceBase;
import com.Utils.ID32;

var m_CharacterId:ID32;
var m_WeaponInventory:Inventory;
var m_WeaponSlot:Number;
var m_WeaponResource:ResourceBase;
var m_ResourceType:Number;
var m_FakeResource:MovieClip;

function Init()
{	
	m_CharacterId = Character.GetClientCharID();
	Resource.SignalResourceChanged.Connect( SlotResourceUpdated, this );
	
	m_WeaponInventory = new Inventory( new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, m_CharacterId.GetInstance()));
	m_WeaponInventory.SignalItemAdded.Connect( SlotWeaponAdded, this);
	m_WeaponInventory.SignalItemLoaded.Connect( SlotWeaponAdded, this );
	m_WeaponInventory.SignalItemChanged.Connect( SlotWeaponChanged, this);        
	m_WeaponInventory.SignalItemRemoved.Connect( SlotWeaponRemoved, this);
	
	var weapon:InventoryItem = m_WeaponInventory.GetItemAt(m_WeaponSlot);
	if (weapon != undefined)
	{
		SlotWeaponAdded(m_WeaponInventory.m_InventoryID, m_WeaponSlot);
	}
}

function SlotWeaponAdded(inventoryID:com.Utils.ID32, itemPos:Number)
{
	if (itemPos == m_WeaponSlot)
	{
		var weapon:InventoryItem = m_WeaponInventory.GetItemAt( itemPos );
		if (weapon != undefined)
		{
			if (m_FakeResource != undefined)
			{
				m_FakeResource.removeMovieClip();
				m_FakeResource = undefined;
			}
			if (m_WeaponResource != undefined)
			{
				m_WeaponResource.removeMovieClip();
				m_WeaponResource = undefined;
			}
			
			m_ResourceType = 0;		
			if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Death) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_Blood", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_BloodResourceType;	
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Jinx) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_Chaos", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_ChaosResourceType;				
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Fire) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_Elemental", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_ElementalResourceType;
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Sword) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_Blade", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_CutResourceType;
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Fist) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_Fist", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_StrikeResourceType;
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Club) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_Hammer", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_SlamResourceType;
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_AssaultRifle) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_AssaultRifle", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_ClipResourceType;
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Handgun) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_Pistol", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_BulletResourceType;
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Shotgun) != 0)
			{
				m_WeaponResource = this.attachMovie("Player_Resource_Shotgun", "m_WeaponResource", this.getNextHighestDepth());
				m_ResourceType = _global.Enums.ResourceType.e_ShellResourceType;
			}
			var resourceAmount:Number = Resource.GetResourceAmount(m_ResourceType, m_CharacterId);
			SlotResourceUpdated(m_ResourceType, resourceAmount, m_CharacterId);
			
			var tooltipText = "";
			if(m_WeaponSlot == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot)
			{
				tooltipText = LDBFormat.LDBGetText("MiscGUI", "PrimaryWeaponEnergyTooltip");
			}
			else
			{
				tooltipText = LDBFormat.LDBGetText("MiscGUI", "SecondaryWeaponEnergyTooltip");
			}
			TooltipUtils.AddTextTooltip( m_WeaponResource, tooltipText, 230, TooltipInterface.e_OrientationHorizontal, true, true);
		}
	}
}

function SlotWeaponChanged(inventoryID:com.Utils.ID32, itemPos:Number)
{
	SlotWeaponRemoved(inventoryID, itemPos, false);
	SlotWeaponAdded(inventoryID, itemPos);
}

function SlotWeaponRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean)
{
	if (itemPos == m_WeaponSlot)
	{
		if (m_WeaponResource != undefined)
		{
			m_WeaponResource.removeMovieClip();
			m_WeaponResource = undefined;
		}
		m_ResourceType = 0;
	}
}

function SlotResourceUpdated(resourceType:Number, resourceAmount:Number, targetID:ID32)
{
	if (resourceType == 0 || resourceType != m_ResourceType || !targetID.Equal( m_CharacterId ))
	{
		return;
	}
	m_WeaponResource.SetAmount( resourceAmount, false );
}
