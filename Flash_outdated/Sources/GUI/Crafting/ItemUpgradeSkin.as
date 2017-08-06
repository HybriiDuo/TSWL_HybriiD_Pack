import com.GameInterface.LoreBase;
import com.GameInterface.InventoryItem;
import com.GameInterface.Game.Character;
import GUI.Crafting.CraftingSkin;
import com.Components.ItemSlot;
import com.Components.FCButton;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
import mx.transitions.easing.Strong;
import gfx.controls.Button;

class GUI.Crafting.ItemUpgradeSkin extends CraftingSkin
{	
	private var m_Title:TextField;
	private var m_DirectionsText:TextField;
	private var m_Background:MovieClip;
	private var m_CloseButton:Button;
	private var m_HelpButton:Button;
	private var m_AssembleButton:Button;
	private var m_ClearButton:FCButton;
	private var m_TargetSlot:MovieClip;
	private var m_UpgradeSlot:MovieClip;
	private var m_ResultSlot:MovieClip;
	private var m_TargetBG:MovieClip;
	private var m_UpgradeBG:MovieClip;
	private var m_ResultBG:MovieClip;
	private var m_TargetFrame:MovieClip;
	private var m_UpgradeFrame:MovieClip;
	private var m_ResultFrame:MovieClip;
	private var m_TargetUpgradeLink:MovieClip;
	private var m_UpgradeResultLink:MovieClip;
	private var m_TargetSlotTextInfo:TextField;
	private var m_UpgradeSlotTextInfo:TextField;
	private var m_ResultSlotTextInfo:TextField;
	private var m_LevelUpgrade:MovieClip;
	private var m_UpgradeProgress:MovieClip;
	private var m_PercentChanceText:TextField;
	private var m_TargetEmptyText:TextField;
	
	private var m_IsCrafting:Boolean;
	private var m_UpgradeSlotEnabled:Boolean;
	
	private var m_AssembleText:String;
	private var m_TargetSlotIndex:Number;
	private var m_UpgradeSlotIndex:Number;
	private var m_ResultSlotIndex:Number;
	
	private var DISABLED_SLOT_ALPHA = 50;
	
	public function ItemUpgradeSkin()
	{
		super();
		m_AssembleText = LDBFormat.LDBGetText("GenericGUI", "CraftingAssemble");
		m_TargetSlotIndex = 0;
		m_UpgradeSlotIndex = 1;
		m_ResultSlotIndex = 2;
		
		m_LevelUpgrade._visible = false;
		m_UpgradeProgress._visible = false;
		m_PercentChanceText._visible = false;
		m_TargetEmptyText._visible = true;
		
		m_UpgradeSlotEnabled = false;
		m_UpgradeBG._alpha = DISABLED_SLOT_ALPHA;
		m_UpgradeSlotTextInfo._alpha = DISABLED_SLOT_ALPHA;
		m_ResultBG._alpha = DISABLED_SLOT_ALPHA;
		m_ResultSlotTextInfo._alpha = DISABLED_SLOT_ALPHA;
	}
	
	public function configUI()
	{
		super.configUI();
		m_Background.onRelease = Delegate.create(this, SlotStopDrag);
		m_Background.onReleaseOutside = Delegate.create(this, SlotStopDrag);
		m_Background.onPress = Delegate.create(this, SlotStartDrag);
		
		m_Title.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingTitle");
		m_DirectionsText.htmlText = LDBFormat.LDBGetText("Crafting", "UpgradeStep1");
		m_TargetEmptyText.htmlText = LDBFormat.LDBGetText("Crafting", "TargetSlotEmpty");
		
		m_CloseButton.disableFocus = true;
		m_HelpButton.disableFocus = true;
		m_AssembleButton.disableFocus = true;
		m_ClearButton.disableFocus = true;
        m_ClearButton.SetTooltipText(LDBFormat.LDBGetText("GenericGUI", "ClearAssemblyItemsTooltip"));
		
		m_CloseButton.addEventListener("click", this, "SlotClose");
		m_HelpButton.addEventListener("click", this, "SlotHelp");
		m_ClearButton.addEventListener("click", this, "SlotClear");		
		m_AssembleButton.addEventListener( "click", this, "SlotStartCrafting" );
		
		m_AssembleButton.disabled = true;
		m_AssembleButton.label = m_AssembleText;
		
		com.Utils.GlobalSignal.SignalSendItemToCrafting.Connect(SlotReceiveItem, this);
		
		ResetIfEmpty();
		UpdateStep();
	}
	
	public function SlotReceiveItem(srcInventory:ID32, srcSlot:Number)
	{
		//Make sure we're set up to receive items
		if (m_Inventory != undefined)
		{
			var firstFree:Number = m_Inventory.GetFirstFreeItemSlot();
			//Only allow movement to the target and modification slots (slots 0 and 1)
			if (firstFree < m_ResultSlotIndex)
			{
				m_Inventory.AddItem(srcInventory, srcSlot, firstFree);
			}
		}
	}
	
	public function SlotClear()
	{
		SignalClear.Emit();
		m_ClearButton.disabled = true;
		m_IsEmpty = true;
	}

	function SlotClose()
	{
		SignalClose.Emit();
	}	

	function SlotHelp():Void
	{
		Selection.setFocus(null);		
		LoreBase.OpenTag(5221)
	}	
		
	function SlotStartCrafting()
	{
		if (m_IsCrafting)
		{
			SignalStartCraft.Emit();
		}
		else
		{
			SignalStartDisassembly.Emit();
		}
	}
	
	public function InitializeItemSlots()
	{
		super.InitializeItemSlots();
		
		m_ItemSlots[m_TargetSlotIndex] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, m_TargetSlotIndex, m_TargetSlot), m_IsPreview:false};
		m_ItemSlots[m_TargetSlotIndex].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[m_TargetSlotIndex].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[m_TargetSlotIndex].m_ItemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
		m_ItemSlots[m_TargetSlotIndex].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[m_TargetSlotIndex].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[m_TargetSlotIndex].m_ItemSlot.SetData(m_Inventory.GetItemAt(m_TargetSlotIndex));
		UpdateTargetSlotItemInfo(m_Inventory.GetItemAt(m_TargetSlotIndex));
		
		m_ItemSlots[m_UpgradeSlotIndex] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, m_UpgradeSlotIndex, m_UpgradeSlot), m_IsPreview:false};
		m_ItemSlots[m_UpgradeSlotIndex].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[m_UpgradeSlotIndex].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[m_UpgradeSlotIndex].m_ItemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
		m_ItemSlots[m_UpgradeSlotIndex].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[m_UpgradeSlotIndex].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[m_UpgradeSlotIndex].m_ItemSlot.SetData(m_Inventory.GetItemAt(m_UpgradeSlotIndex));
		UpdateUpgradeSlotItemInfo(m_Inventory.GetItemAt(m_UpgradeSlotIndex));
		
		m_ItemSlots[m_ResultSlotIndex] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, m_ResultSlotIndex, m_ResultSlot), m_IsPreview:false};
		m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
		m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SetData(m_Inventory.GetItemAt(m_ResultSlotIndex));
		UpdateResultSlotItemInfo(m_Inventory.GetItemAt(m_ResultSlotIndex));
	}
	
	private function UpdateUpgradeSlotItemInfo(item:InventoryItem)
	{
		if ( item != undefined)
		{
			var upgradeText:String = item.m_Name;
			m_UpgradeSlotTextInfo.htmlText = upgradeText;
			m_UpgradeFrame._visible = true;
		}
		else
		{
			m_UpgradeSlotTextInfo.htmlText = LDBFormat.LDBGetText("Crafting", "ModificationSlot");
			m_UpgradeFrame._visible = false;
		}
		UpdateStep();
	}
	
	private function UpdateTargetSlotItemInfo(item:InventoryItem)
	{
		if ( item != undefined)
		{
			m_TargetEmptyText._visible = false;
			var targetText:String = item.m_Name;
			m_TargetSlotTextInfo.htmlText = targetText;
			m_TargetFrame._visible = true;
			
			m_UpgradeProgress._visible = true;
			var levelXP:Number = item.m_XP - item.m_XPToCurrentLevel;
			var XPToLevel:Number = item.m_XPToNextLevel - item.m_XPToCurrentLevel;
						
			var currentPercent:Number = (levelXP / XPToLevel) * 100;
			m_UpgradeProgress.m_CurrentXP._xscale = Math.min(currentPercent, 100);
			m_UpgradeProgress.m_UpgradeXP._xscale = 0;
			m_UpgradeProgress.m_Text.text = "";
			
			m_LevelUpgrade._visible = true;
			m_LevelUpgrade.m_Arrow._visible = false;
			m_LevelUpgrade.m_UpgradeLevel._visible = false;
			m_LevelUpgrade.m_CurrentLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + item.m_Rank;
		}
		else
		{
			m_TargetEmptyText._visible = true;
			m_TargetSlotTextInfo.htmlText = LDBFormat.LDBGetText("Crafting", "TargetSlot");
			m_TargetFrame._visible = false;
			m_LevelUpgrade._visible = false;
			m_UpgradeProgress._visible = false;
			m_PercentChanceText._visible = false;
		}
		UpdateStep();
	}
	
	private function UpdateResultSlotItemInfo(item:InventoryItem)
	{
		if ( item != undefined)
		{
			var resultText:String = item.m_Name ;
			m_ResultSlotTextInfo.htmlText = resultText;
			m_ResultSlotTextInfo.textColor = 0xCCCC00;
			m_ResultFrame._visible = true;
		}
		else
		{
			m_ResultSlotTextInfo.htmlText = LDBFormat.LDBGetText("Crafting", "ResultSlot");
			m_ResultSlotTextInfo.textColor = 0xFFFFFF;
			m_ResultFrame._visible = false;
			m_PercentChanceText._visible = false;
			ClearResultDisplay();
		}
		UpdateStep();
	}
	
	private function UpdateStep()
	{
		var upgradeExists:Boolean = m_Inventory.GetItemAt(m_UpgradeSlotIndex) != undefined;
		var targetExists:Boolean = m_Inventory.GetItemAt(m_TargetSlotIndex) != undefined;
		var resultExists:Boolean = m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.HasItem();
		
		if (targetExists && !m_UpgradeSlotEnabled)
		{
			m_UpgradeBG._alpha = 100;
			m_UpgradeSlotTextInfo._alpha = 100;
			m_UpgradeSlotEnabled = true;
			m_DirectionsText.htmlText = LDBFormat.LDBGetText("Crafting", "UpgradeStep2");
		}
		else if (!targetExists && m_UpgradeSlotEnabled)
		{
			m_UpgradeSlotEnabled = false;
			m_UpgradeBG._alpha = DISABLED_SLOT_ALPHA;
			m_UpgradeSlotTextInfo._alpha = DISABLED_SLOT_ALPHA;
			if (upgradeExists)
			{
				SlotClear();
			}
			m_DirectionsText.htmlText = LDBFormat.LDBGetText("Crafting", "UpgradeStep1");
		}
		
		if (targetExists && upgradeExists)
		{
			m_ResultBG._alpha = 100;
			m_ResultSlotTextInfo._alpha = 100;
		}
		else
		{
			m_ResultBG._alpha = DISABLED_SLOT_ALPHA;
			m_ResultSlotTextInfo._alpha = DISABLED_SLOT_ALPHA;
		}
		
		m_TargetUpgradeLink._visible = false;
		m_UpgradeResultLink._visible = false;
		if (upgradeExists && targetExists)
		{
			m_TargetUpgradeLink._visible = true;
			if (resultExists)
			{
				m_UpgradeResultLink._visible = true;
				m_DirectionsText.htmlText = LDBFormat.LDBGetText("Crafting", "UpgradeStep3");
			}
		}
		else if (resultExists)
		{
			m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SetCanDrag(true);
			m_TargetEmptyText._visible = false;
			m_ResultBG._alpha = 100;
			m_ResultSlotTextInfo._alpha = 100;
			m_DirectionsText.htmlText = LDBFormat.LDBGetText("Crafting", "UpgradeStep2");
		}
		if (!targetExists && !upgradeExists && !resultExists)
		{
			m_DirectionsText.htmlText = LDBFormat.LDBGetText("Crafting", "UpgradeStep1");
		}
	}
	
	//OVERRIDING THIS: We don't want the result slot to ever accept items from drag & drop
	function onDragEnd( event:Object ) : Void
	{
		if ( Mouse["IsMouseOver"](this) )
		{
			var succeded:Boolean = false;
			if ( event.data.type == "item")
			{
				var dstID = GetMouseSlotID();
				if ( dstID >= 0 && dstID != m_ResultSlotIndex && (dstID != m_UpgradeSlotIndex || m_UpgradeSlotEnabled) )
				{
					if (event.data.split)
					{
						m_Inventory.SplitItem(event.data.inventory_id, event.data.inventory_slot, dstID, event.data.stack_size);
					}
					else
					{
						m_Inventory.AddItem(event.data.inventory_id, event.data.inventory_slot, dstID);
					}
			   
					succeded = true;
				}
			}
			event.data.DragHandled();
			Character.GetClientCharacter().AddEffectPackage((succeded) ? "sound_fxpackage_GUI_item_slot.xml" : "sound_fxpackage_GUI_item_slot_fail.xml");
		}
	}
	
	function SlotItemAdded( inventoryId:ID32, itemPos:Number )
	{
		m_ItemSlots[itemPos].m_ItemSlot.SetData(m_Inventory.GetItemAt(itemPos));
		m_ItemSlots[itemPos].m_IsPreview = false;
		m_ItemSlots[itemPos].m_ItemSlot.SetCanDrag(true);
		
		var item:InventoryItem = m_Inventory.GetItemAt(itemPos);
		switch (itemPos)
		{
			case m_TargetSlotIndex:
				UpdateTargetSlotItemInfo(item);
				break;
			case m_UpgradeSlotIndex:
				UpdateUpgradeSlotItemInfo(item);
				break;
			case m_ResultSlotIndex:
				UpdateResultSlotItemInfo(item);
				break;
		}
		m_IsEmpty = false;
	}
	
	function SlotItemMoved( inventoryID:ID32, fromPos:Number, toPos:Number )
	{
	}

	function SlotItemRemoved( inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
	{
		switch (itemPos)
		{
			case m_TargetSlotIndex:
				UpdateTargetSlotItemInfo(undefined);
				break;
			case m_UpgradeSlotIndex:
				UpdateUpgradeSlotItemInfo(undefined);
				break;
			case m_ResultSlotIndex:
				UpdateResultSlotItemInfo(undefined);
				break;
		}
		m_ItemSlots[itemPos].m_ItemSlot.Clear();        
        ResetIfEmpty();
	}

	function SlotItemChanged( inventoryID:com.Utils.ID32, itemPos:Number )
	{
		SlotItemAdded(inventoryID, itemPos);
	}


	function SlotItemStatChanged( inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number  )
	{  
		if (stat == _global.Enums.Stat.e_StackSize)
		{
			var itemSlot:ItemSlot = m_ItemSlots[itemPos].m_ItemSlot;
			if (itemSlot != undefined)
			{
				itemSlot.UpdateStackSize(m_Inventory.GetItemAt(itemPos));
				return;
			}
			
		}
		SlotItemChanged(inventoryID, itemPos);
	}
	
	function CraftingResultFeedback(result:Number, numItems:Number, feedback:String, items:Array, percentChance:Number)
	{
		ResetPreview();
		ResetIfEmpty();
		switch(result)
		{
			case _global.Enums.CraftingPhase.e_NoRecipes:
			case _global.Enums.CraftingPhase.e_Phase1CheckRelevantRecipes:
			case _global.Enums.CraftingPhase.e_Phase2CheckGridNumbers:
			case _global.Enums.CraftingPhase.e_Phase3CheckPositioning:
				SetState(STATE_CRAFTING_NOT_READY);
				break;
			case _global.Enums.CraftingPhase.e_Phase4CheckStackSizes:
				SetState(STATE_CRAFTING_NEED_TOOL);
				break;
			case _global.Enums.CraftingPhase.e_NoUpdate:
				break;
			case _global.Enums.CraftingPhase.e_Phase5CheckTools:
				SetState(STATE_CRAFTING_SCRIPT_FAILED);
				break;
			case _global.Enums.CraftingPhase.e_LuaSuccess:
				SetState(STATE_CRAFTING_READY);
				if (items[0] != undefined)
				{
					m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SetData(items[0]);
					m_ItemSlots[m_ResultSlotIndex].m_ItemSlot.SetCanDrag(false);
					m_ItemSlots[m_ResultSlotIndex].m_IsPreview = true;
					SetResultDisplay(items[0], percentChance);
				}
				break;
			case _global.Enums.CraftingPhase.e_DisassemblyPass:
			case _global.Enums.CraftingPhase.e_Disassembled:				
			case _global.Enums.CraftingPhase.e_LuaFailed:
			case _global.Enums.CraftingPhase.e_Crafted:
			case _global.Enums.CraftingPhase.e_ClearGrid:
			case _global.Enums.CraftingPhase.e_SetData:
			default:
				break;
		}
		UpdateResultSlotItemInfo(items[0]);
		ResetIfEmpty()
	}
	
	function SetResultDisplay(item:InventoryItem, chance:Number)
	{		
		var targetItem:InventoryItem = m_ItemSlots[m_TargetSlotIndex].m_ItemSlot.GetData();
		if (item.m_XP != targetItem.m_XP)
		{
			m_UpgradeProgress._visible = true;
			
			var currentLevelXP:Number = targetItem.m_XP - targetItem.m_XPToCurrentLevel;
			var currentXPToLevel:Number = targetItem.m_XPToNextLevel - targetItem.m_XPToCurrentLevel;
			var currentPercent:Number = (currentLevelXP / currentXPToLevel) * 100;
			
			var levelXP:Number = item.m_XP - item.m_XPToCurrentLevel;
			var XPToLevel:Number = item.m_XPToNextLevel - item.m_XPToCurrentLevel;
			var upgradePercent:Number = (levelXP / XPToLevel) * 100;
						
			m_UpgradeProgress.m_CurrentXP._xscale = Math.min(currentPercent, 100);
			m_UpgradeProgress.m_UpgradeXP._xscale = Math.min(upgradePercent, 100);
			var xpDiff:Number = item.m_XP - targetItem.m_XP
			m_UpgradeProgress.m_Text.text = xpDiff > 0 ? "+ " + xpDiff + " " + LDBFormat.LDBGetText("Crafting", "XP") : "";
		}
		if (item.m_Rank != targetItem.m_Rank)
		{
			m_LevelUpgrade._visible = true;
			m_LevelUpgrade.m_Arrow._visible = true;
			m_LevelUpgrade.m_UpgradeLevel._visible = true;
			m_LevelUpgrade.m_CurrentLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + targetItem.m_Rank;
			m_LevelUpgrade.m_UpgradeLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + item.m_Rank;
			//We are on the next rank, so current progress on this rank is 0
			m_UpgradeProgress.m_CurrentXP._xscale = 0;
		}
		if (chance < 100)
		{
			m_PercentChanceText._visible = true;
			m_PercentChanceText.text = chance + "% " + LDBFormat.LDBGetText("Crafting", "Chance");
		}
	}
	
	function ClearResultDisplay()
	{
		UpdateTargetSlotItemInfo(m_Inventory.GetItemAt(m_TargetSlotIndex));
	}
	
	function SetState(newState:Number)
	{
		switch(newState)
		{
			case CraftingSkin.STATE_EMPTY:
				m_AssembleButton.disabled = true;
				m_AssembleButton.label = m_AssembleText;
				m_ClearButton.disabled = true;
				break;
			case CraftingSkin.STATE_CRAFTING_NOT_READY:
				m_AssembleButton.disabled = true;
				m_AssembleButton.label = m_AssembleText;
				m_ClearButton.disabled = m_IsEmpty;
				m_IsCrafting = true;
				break;
			case CraftingSkin.STATE_CRAFTING_NEED_TOOL:
				m_AssembleButton.disabled = true;
				m_AssembleButton.label = m_AssembleText;
				m_IsCrafting = true;
				m_ClearButton.disabled = false;				
				break;
			case CraftingSkin.STATE_CRAFTING_SCRIPT_FAILED:
				m_AssembleButton.disabled = true;
				m_AssembleButton.label = m_AssembleText;                
				m_IsCrafting = true;
				m_ClearButton.disabled = false;
				break;
			case CraftingSkin.STATE_CRAFTING_READY:
				m_AssembleButton.disabled = false;
				m_AssembleButton.label = m_AssembleText;
				m_IsCrafting = true;
				m_ClearButton.disabled = false;
				break;
			default:
				break;
		}
	}
}