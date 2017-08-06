import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.Utils.ID32;

var m_CharacterId:ID32;
var m_WeaponInventory:Inventory;
var m_WeaponSlot:Number;
var m_WeaponStatus:MovieClip;
var m_FakeWeaponStatus:MovieClip;

function Init()
{	
	m_CharacterId = Character.GetClientCharID();
	
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
			if (m_WeaponStatus != undefined)
			{
				m_WeaponStatus.removeMovieClip();
				m_WeaponStatus = undefined;
			}
			if (m_FakeWeaponStatus != undefined)
			{
				m_FakeWeaponStatus.removeMovieClip();
				m_FakeWeaponStatus = undefined;
			}
			
			if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Death) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_Blood", "m_WeaponStatus", this.getNextHighestDepth());
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Jinx) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_Chaos", "m_WeaponStatus", this.getNextHighestDepth());
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Fire) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_Elemental", "m_WeaponStatus", this.getNextHighestDepth());
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Sword) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_Blade", "m_WeaponStatus", this.getNextHighestDepth());
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Fist) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_Fist", "m_WeaponStatus", this.getNextHighestDepth());
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Club) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_Hammer", "m_WeaponStatus", this.getNextHighestDepth());
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_AssaultRifle) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_AssaultRifle", "m_WeaponStatus", this.getNextHighestDepth());
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Handgun) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_Pistol", "m_WeaponStatus", this.getNextHighestDepth());
			}
			else if ((weapon.m_Type & _global.Enums.WeaponTypeFlag.e_WeaponType_Shotgun) != 0)
			{
				m_WeaponStatus = this.attachMovie("WeaponStatus_Shotgun", "m_WeaponStatus", this.getNextHighestDepth());
			}
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
		if (m_WeaponStatus != undefined)
		{
			m_WeaponStatus.removeMovieClip();
			m_WeaponStatus = undefined;
		}
	}
}
