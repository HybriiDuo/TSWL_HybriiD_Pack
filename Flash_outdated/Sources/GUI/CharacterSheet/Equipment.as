import gfx.core.UIComponent;
import gfx.controls.CheckBox;
import gfx.controls.Button;
import flash.filters.GlowFilter;
import com.Components.ItemSlot;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Lore;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.GearManager;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.TooltipUtils;
import com.Utils.DragObject;
import com.Utils.LDBFormat;
import com.Utils.ID32;

class GUI.CharacterSheet.Equipment extends UIComponent
{
	//Components created in .fla
	private var m_PrimaryTitle:TextField;
	private var m_SecondaryTitle:TextField;
	//private var m_AuxiliaryTitle:TextField;
	private var icon_chakra_1:MovieClip;
	private var icon_chakra_2:MovieClip;
	private var icon_chakra_3:MovieClip;
	private var icon_chakra_4:MovieClip;
	private var icon_chakra_5:MovieClip;
	private var icon_chakra_6:MovieClip;
	private var icon_chakra_7:MovieClip;
	private var icon_gadget:MovieClip;
	private var icon_firstweapon:MovieClip;
	private var icon_secondweapon:MovieClip;
	//private var icon_thirdweapon:MovieClip;
	private var m_PrimaryCheckbox:CheckBox;
	private var m_SecondaryCheckbox:CheckBox;
	//private var m_AuxCheckbox:CheckBox;
	private var m_UpgradeButton:Button;
	
	//Variables
	private var m_Inventory:Inventory;
	private var m_ItemSlots:Object;
	private var m_WeaponSlots:Array;
	private var m_Character:Character;
	private var m_GlowFilter:GlowFilter;
	
	//Statics
	private static var AUXILIARY_SLOT_ACHIEVEMENT:Number = 5437;
	private static var AUXILIARY_WEAPON_SLOT:Number = 20;
	
	public function Equipment() 
	{
		super();
		
		m_Character = Character.GetClientCharacter();
		
		m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharID().GetInstance()));
		m_Inventory.SignalItemAdded.Connect( SlotItemAdded, this);
		m_Inventory.SignalItemAdded.Connect( SlotItemLoaded, this);
		m_Inventory.SignalItemMoved.Connect( SlotItemMoved, this);
		m_Inventory.SignalItemRemoved.Connect( SlotItemRemoved, this);
		m_Inventory.SignalItemChanged.Connect( SlotItemChanged, this);
		m_Inventory.SignalItemStatChanged.Connect( SlotItemStatChanged, this);
		
		m_ItemSlots = new Object;
		
		gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "onDragBegin" );
    	gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );
		
		m_GlowFilter = new GlowFilter();
		m_GlowFilter.alpha = 1;
		m_GlowFilter.color = 0x222222;
		m_GlowFilter.blurX = 1;
		m_GlowFilter.blurY = 1;
		m_GlowFilter.inner = false;
		m_GlowFilter.strength = 15;
	}
	
	public function configUI():Void
    {
        super.configUI();
		
		SetTalismanPanel();
    	SetWeaponBox();
		
		for ( var i:Number = 0 ; i < m_Inventory.GetMaxItems(); ++i )
		{
			if (m_ItemSlots[i] != undefined)
			{
				m_ItemSlots[i].GetSlotMC().m_Watermark._visible = true;
				if (m_ItemSlots[i] != undefined && m_Inventory.GetItemAt(m_ItemSlots[i].GetSlotID()) != undefined)
				{
					m_ItemSlots[i].SetData(m_Inventory.GetItemAt(m_ItemSlots[i].GetSlotID()));
					m_ItemSlots[i].GetSlotMC().m_Watermark._visible = false;
				}
			}
		}
		
		m_UpgradeButton.addEventListener( "click", this, "SlotUpgradeClicked" );
		m_UpgradeButton.label = LDBFormat.LDBGetText("MiscGUI", "ItemUpgradeTitle");
		m_UpgradeButton.disabled = !DistributedValue.GetDValue("Crafting_Allowed")
	}
	
	function SlotUpgradeClicked()
	{
		Selection.setFocus(null);
		DistributedValue.SetDValue("ItemUpgradeWindow", !DistributedValue.GetDValue("ItemUpgradeWindow"));
	}
	
	private function SetTalismanPanel():Void
	{    		
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_1, icon_chakra_1)		
		
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_2, icon_chakra_2);
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_3, icon_chakra_3);
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_4, icon_chakra_4);
		
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_5, icon_chakra_5);
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_6, icon_chakra_6);
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_7, icon_chakra_7);
		
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Aegis_Talisman_1, icon_gadget);
	}
	
	private function SetWeaponBox():Void
	{    
		m_PrimaryTitle.text = LDBFormat.LDBGetText("GenericGUI", "Primary");
		m_SecondaryTitle.text = LDBFormat.LDBGetText("GenericGUI", "Secondary");
		//m_AuxiliaryTitle.text = LDBFormat.LDBGetText("GenericGUI", "Auxilliary");
	
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot, icon_firstweapon);
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot, icon_secondweapon);
		//InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot, icon_thirdweapon);
		
		m_WeaponSlots = [];
		
		m_WeaponSlots.push(m_ItemSlots[ _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ]);
		m_WeaponSlots.push(m_ItemSlots[ _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot ]);
		m_WeaponSlots.push(m_ItemSlots[ _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot ]);
		/*
		if (Lore.IsLocked(AUXILIARY_SLOT_ACHIEVEMENT))
		{
			m_AuxiliaryTitle._visible = false;
			icon_thirdweapon._visible = false;
			m_AuxCheckbox._visible = false;
		}
		*/
				
		m_PrimaryCheckbox.selected = !GearManager.IsPrimaryWeaponHidden();
		m_SecondaryCheckbox.selected = !GearManager.IsSecondaryWeaponHidden();
		//m_AuxCheckbox.selected = !GearManager.IsAuxiliaryWeaponHidden();
		m_PrimaryCheckbox.addEventListener("click", this, "UpdateShownWeapons");
		m_SecondaryCheckbox.addEventListener("click", this, "UpdateShownWeapons");
		//m_AuxCheckbox.addEventListener("click", this, "UpdateShownWeapons");		
	}
	
	function UpdateShownWeapons()
	{
		GearManager.SetPrimaryWeaponHidden(!m_PrimaryCheckbox.selected);
		GearManager.SetSecondaryWeaponHidden(!m_SecondaryCheckbox.selected);
		//GearManager.SetAuxiliaryWeaponHidden(m_AuxCheckbox.selected);
		Selection.setFocus(null);
	}
	
	private function InitializeSlot(itemPos:Number, icon:MovieClip):Void
	{
		m_ItemSlots[itemPos] = new ItemSlot(m_Inventory.m_InventoryID, itemPos, icon);
		m_ItemSlots[itemPos].SignalMouseDown.Connect(SlotMouseDownItem, this);
		m_ItemSlots[itemPos].SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[itemPos].SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[itemPos].SignalStartDrag.Connect(SlotStartDragItem, this);
	}
	
	private function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number):Void
	{
		if (m_Inventory.GetItemAt(itemPos) != undefined)
		{
			for ( var i:Number = 0; i < m_Inventory.GetMaxItems(); i++)
			{
				//RemoveSimpleTooltips(i)
				if (m_ItemSlots[i].GetSlotID() == itemPos)
				{
					m_ItemSlots[i].SetData(m_Inventory.GetItemAt(itemPos));
					m_ItemSlots[i].GetSlotMC().m_Watermark._visible = false;
				}
			}        			
		}
	}
	
	private function SlotItemLoaded(inventoryID:com.Utils.ID32, itemPos:Number):Void
	{
		SlotItemAdded(inventoryID, itemPos);
	}
	
	//Slot Item Moved
	private function SlotItemMoved(inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number):Void
	{
		m_ItemSlots[fromPos].SetData(m_Inventory.GetItemAt(fromPos));
		m_ItemSlots[toPos].SetData(m_Inventory.GetItemAt( toPos));
	}
	
	//Slot Item Removed
	private function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean):Void
	{
		for (var i:Number = 0; i<m_Inventory.GetMaxItems(); i++)
		{
			if (m_ItemSlots[i].GetSlotID() == itemPos)
			{
				m_ItemSlots[i].Clear();
				m_ItemSlots[i].GetSlotMC().m_Watermark._visible = true;
			}
		}
	}
	 
	//Slot Item Changed
	private function SlotItemChanged(inventoryID:com.Utils.ID32, itemPos:Number):Void
	{
		for (var i:Number = 0; i<m_Inventory.GetMaxItems(); i++)
		{
			if (m_ItemSlots[i].GetSlotID() == itemPos)
			{
				m_ItemSlots[i].SetData(m_Inventory.GetItemAt(itemPos));
				m_ItemSlots[i].GetSlotMC().m_Watermark._visible = false;
			}
		}
		m_ItemSlots[itemPos].SetData(m_Inventory.GetItemAt(itemPos));
		m_ItemSlots[itemPos].GetSlotMC().m_Watermark._visible = false;
	}
	
	private function SlotItemStatChanged(inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number )
	{
		SlotItemChanged(inventoryID, itemPos);
	}
	
	private function SlotStartDragItem(itemSlot:ItemSlot, stackSize:Number)
	{
		var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSize);
		dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
		dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
	}
	
	private function SlotItemDroppedOnDesktop()
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
	
		if (currentDragObject.type == "item")
		{
			SlotDeleteItem(m_ItemSlots[currentDragObject.inventory_slot]);
		}
	}
	
	private function SlotDragHandled()
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
		
		if (m_ItemSlots[currentDragObject.inventory_slot] != undefined)
		{
			 m_ItemSlots[currentDragObject.inventory_slot].SetAlpha(100);
			 m_ItemSlots[currentDragObject.inventory_slot].UpdateFilter();
		}
	}
	
	private function SlotMouseDownItem(itemSlot:ItemSlot, buttonIndex:Number, clickCount:Number)
	{
		if (clickCount == 2 && buttonIndex == 1)
		{
			if (m_Character != undefined)
			{
				m_Character.AddEffectPackage( "sound_fxpackage_GUI_item_slot.xml" );
			}
			m_Inventory.UseItem(itemSlot.GetSlotID());
		}
	}
	
	private function SlotMouseUpItem(itemSlot:ItemSlot, buttonIndex:Number)
	{
		if (buttonIndex == 2 && !Key.isDown(Key.CONTROL))
		{
			if (m_Character != undefined)
			{
				m_Character.AddEffectPackage( "sound_fxpackage_GUI_item_slot.xml" );
			}
			//Because gadgets can be used, we have to manually move them to the backpack instead of letting
			//useItem take care of it.
			if (itemSlot.GetSlotID() == _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1)
			{
				var backpackInventory:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharID().GetInstance()));			
				backpackInventory.AddItem(m_Inventory.m_InventoryID, _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1, backpackInventory.GetFirstFreeItemSlot());
			}
			//Upgrading
			else if (GUIModuleIF.FindModuleIF("ItemUpgradeGUI").IsActive())
			{
				com.Utils.GlobalSignal.SignalSendItemToUpgrade.Emit(m_Inventory.m_InventoryID, itemSlot.GetSlotID());
			}
			else
			{
				m_Inventory.UseItem(itemSlot.GetSlotID());
			}
		}
	}
	
	//On Drag End
	private function onDragEnd(event:Object):Void
	{
		if(Mouse["IsMouseOver"](this))
		{
			if ( event.data.type == "item" )
			{
				var dstID = GetMouseSlotID();
				
				if (dstID > 0)
				{
					switch (dstID)
					{
						//Weapon Slots
						case _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot:   // Continue
						case _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot:
																						if (event.data.inventory_id.Equal(m_Inventory.m_InventoryID) && !(event.data.inventory_slot == dstID))
																						{
																							var fifoMessage:String = LDBFormat.LDBGetText("Gamecode", "CantSwapWeapons");
																							com.GameInterface.Chat.SignalShowFIFOMessage.Emit(fifoMessage, 0);
																							break;
																						}
						
						case _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1:
						case _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot:     m_Inventory.AddItem(event.data.inventory_id, event.data.inventory_slot, dstID);
																						break;
						
						//Chakras Slots
						default:    if (!event.data.inventory_id.Equal(m_Inventory.m_InventoryID))
									{
										var inventory:Inventory = new Inventory(event.data.inventory_id);
										inventory.UseItem(event.data.inventory_slot);
									}
					}
		
					event.data.DragHandled();
					
				}
				UnHighLightAll();
			}
		}
	}
	
	//On Drag Begin
	private function onDragBegin(event:Object):Void
	{
		if ( event.data.type == "item" )
		{
			var inventory:Inventory = new Inventory(event.data.inventory_id);
			var item:InventoryItem = inventory.GetItemAt(event.data.inventory_slot);
			
			for (var i in m_ItemSlots)
			{
				var itemSlot:ItemSlot = m_ItemSlots[i];
				if ( i == item.m_DefaultPosition ||  item.m_DefaultPosition == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot && i == _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot)
				{
					HighLightSlot(itemSlot.GetSlotMC(), true);
				}
			}
		}
	}
	
	private function HighLightSlot(slot:MovieClip, highlight:Boolean) : Void
	{
		slot.filters = (highlight)?[m_GlowFilter]:[];
	}
	
	private function UnHighLightAll() : Void
	{
		for (var prop in m_ItemSlots)
		{
			HighLightSlot(m_ItemSlots[prop].GetSlotMC(), false)
		}
	}
	
	//Get Mouse Slot ID
	private function GetMouseSlotID():Number
	{
		var hitSlot:ItemSlot = undefined;
		for (var i in m_ItemSlots)
		{
			var itemSlot:ItemSlot = m_ItemSlots[i];
			
			if ( itemSlot.HitTest( _root._xmouse, _root._ymouse) && itemSlot.GetSlotMC()._visible)
			{
				if (itemSlot.GetSlotID() == AUXILIARY_WEAPON_SLOT && Lore.IsLocked(AUXILIARY_SLOT_ACHIEVEMENT))
				{
					return -1;
				}
				else 
				{ 
					if (hitSlot == undefined || hitSlot.GetSlotMC().getDepth() < itemSlot.GetSlotMC().getDepth())
					{
						hitSlot = itemSlot; 
					}
				}
			}
		}    
		if (hitSlot != undefined){ return hitSlot.GetSlotID(); }
		return -1;
	}
	
	private function SlotDeleteItem(itemSlot:ItemSlot):Void
	{
		var isGM:Boolean = m_Character.GetStat(_global.Enums.Stat.e_GmLevel) != 0;
		var isInCombat:Boolean = m_Character.IsInCombat();
		
		if ((itemSlot.GetData().m_Deleteable || isGM) && !isInCombat)
		{
			var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ConfirmDeleteItem"), itemSlot.GetData().m_Name);
			var dialogIF = new com.GameInterface.DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "DeleteItem" );
			dialogIF.SignalSelectedAS.Connect( SlotDeleteItemDialog, this );
			dialogIF.Go( itemSlot.GetSlotID() ); // <-  the slotid is userdata.
		}
	}
	
	private function SlotDeleteItemDialog(buttonID:Number, itemSlotID:Number):Void
	{
		if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			m_Inventory.DeleteItem(itemSlotID);
		}
	}
}