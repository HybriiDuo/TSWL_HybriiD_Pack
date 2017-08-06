import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import com.Utils.DragObject;
import com.Utils.ID32;
import com.Utils.Colors;
import com.Utils.Text;
import com.GameInterface.Utils;
import mx.utils.Delegate;
import gfx.controls.Button;
import com.Components.ItemSlot;
import com.GameInterface.Lore;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory
import com.GameInterface.InventoryItem;
import com.GameInterface.CraftingInterface;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.ShopInterface;
import com.GameInterface.DialogIF;

class GUI.ItemUpgrade.ItemUpgradeContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_TargetSlot:MovieClip;
	private var m_StatsHeader:MovieClip;
	private var m_LevelUpgrade:MovieClip;
	private var m_GlyphLevelUpgrade:MovieClip;
	private var m_SignetLevelUpgrade:MovieClip;
	private var m_UpgradeProgress:MovieClip;
	private var m_GlyphUpgradeProgress:MovieClip;
	private var m_SignetUpgradeProgress:MovieClip;
	private var m_TargetBG:MovieClip;
	private var m_StatChangeBG:MovieClip;
	private var m_StatChangeIcon:MovieClip;
	private var m_EmpowermentTab:MovieClip;
	private var m_FusionTab:MovieClip;
	private var m_DestroyGlyphButton:Button;
	private var m_RecoverGlyphButton:Button;
	private var m_DestroySignetButton:Button;
	private var m_RecoverSignetButton:Button;
	private var m_GlyphHeader:TextField;
	private var m_GlyphHeaderBG:MovieClip;
	private var m_SignetHeader:TextField;
	private var m_SignetHeaderBG:MovieClip;
	private var m_HelpText:TextField;
	private var m_RulesHeader:TextField;
		
	//Variables
	private var m_Inventory:Inventory;
	private var m_ItemSlots:Array;
	private var m_CurrentTab:Number;
	private var m_SlotPadding = 12;
	private var m_CurrentResult:InventoryItem;
	private var m_CurrentCost:Number;
	private var m_Character:Character;
	private var m_TutorialBlocker:MovieClip;
	private var m_ForcedInventory:Boolean;
	private var m_FromEquipped:Array;
	private var m_SlotStates:Array;
	private var m_ValidFeedback:Number;
	private var m_BonusFeedback:Number;
	private var m_FusionFeedback:Number;
	
	//Statics
	private var EMPOWERMENT_TAB = 0;
	private var FUSION_TAB = 1;
	private var TARGET_SLOT:Number = 0;
	private var FUSION_SLOT:Number = 1;
	private var RESULT_SLOT:Number = 2;
	private var EMPOWER_SLOT_0:Number = 3;
	private var EMPOWER_SLOT_1:Number = 4;
	private var EMPOWER_SLOT_2:Number = 5;
	private var EMPOWER_SLOT_3:Number = 6;
	private var EMPOWER_SLOT_4:Number = 7;
	
	private var FUSION_UNLOCK_TAG = 9452;
	private var GLYPH_UNLOCK_TAG = 9521;
	private var TUTORIAL_COMPLETE_TAG = 9469;
	private var FUSION_TUTORIAL_COMPLETE_TAG = 9516;
	private var GLYPH_TUTORIAL_COMPLETE_TAG = 9520;
	
	private var LDB_ASSEMBLE:String = "";
	private var LDB_FUSE:String = "";
	
	public function ItemUpgradeContent()
	{
		super();
		m_ValidFeedback = 0;
		m_BonusFeedback = 0;
		m_FusionFeedback = 0;
		m_FromEquipped = new Array();
		SwitchToEmpowerment();
		ClearStatsDisplay();
		gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );
		//Open the inventory when this is opened, because we always need stuff from the inventory for this
		m_ForcedInventory = !DistributedValue.GetDValue("inventory_visible", false);
		DistributedValue.SetDValue("inventory_visible", true);
	}
	
	private function configUI():Void
	{		
		super.configUI();
		
		m_DestroyGlyphButton._visible = false;
		m_RecoverGlyphButton._visible = false;
		m_DestroySignetButton._visible = false;
		m_RecoverSignetButton._visible = false;
		m_GlyphHeader._visible = false;
		m_GlyphHeaderBG._visible = false;
		m_SignetHeader._visible = false;
		m_SignetHeaderBG._visible = false;
		
		m_Character = Character.GetClientCharacter();
		if (Lore.IsLocked(TUTORIAL_COMPLETE_TAG))
		{
			m_TutorialBlocker = this.attachMovie("TutorialBlocker", "m_TutorialBlocker", this.getNextHighestDepth());
			
			//Some really, truly unfortunate things are about to happen.
			//This maps the starting weapons given out to players to the starting classes
			var startingClass = m_Character.GetStat(_global.Enums.Stat.e_CharacterClass, 2);
			var weapon1Name:String = "";
			var weapon2Name:String = "";
			switch (startingClass)
			{
				case 1:	weapon1Name = LDBFormat.LDBGetText(50200, 9262318);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265252);
						break;
				case 2:	weapon1Name = LDBFormat.LDBGetText(50200, 9262319);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265253);
						break;
				case 3:	weapon1Name = LDBFormat.LDBGetText(50200, 9262326);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265259);
						break;
				case 4:	weapon1Name = LDBFormat.LDBGetText(50200, 9262325);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265258);
						break;
				case 5:	weapon1Name = LDBFormat.LDBGetText(50200, 9262322);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265255);
						break;
				case 6:	weapon1Name = LDBFormat.LDBGetText(50200, 9262324);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265257);
						break;
				case 7:	weapon1Name = LDBFormat.LDBGetText(50200, 9262323);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265256);
						break;
				case 8:	weapon1Name = LDBFormat.LDBGetText(50200, 9262316);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265251);
						break;
				case 9:	weapon1Name = LDBFormat.LDBGetText(50200, 9262321);
						weapon2Name = LDBFormat.LDBGetText(50200, 9265254);
						break;
			}
			m_TutorialBlocker.m_TutorialStep1.htmlText = LDBFormat.Printf(LDBFormat.LDBGetText("Crafting", "TutorialStep1"), weapon1Name);
			m_TutorialBlocker.m_TutorialStep2.htmlText = LDBFormat.Printf(LDBFormat.LDBGetText("Crafting", "TutorialStep2"));
			m_TutorialBlocker.m_TutorialStep3.htmlText = LDBFormat.LDBGetText("Crafting", "TutorialStep3");
			m_StatsHeader.swapDepths(this.getNextHighestDepth());
			m_LevelUpgrade.swapDepths(this.getNextHighestDepth());
			m_UpgradeProgress.swapDepths(this.getNextHighestDepth());
		}
		
		if (Lore.IsLocked(FUSION_UNLOCK_TAG))
		{
			m_FusionTab._alpha = 33;
		}
		else
		{
			m_FusionTab.m_LockIcon._visible = false;
			if (Lore.IsLocked(FUSION_TUTORIAL_COMPLETE_TAG))
			{
				m_TutorialBlocker = this.attachMovie("FusionTutorialBlocker", "m_TutorialBlocker", this.getNextHighestDepth());
				m_TutorialBlocker.m_FuseItems.onRelease = function(){};
				m_TutorialBlocker.m_FuseItems._visible = false;
				
				m_TutorialBlocker.m_SelectFusion.m_FusionTutorialStep1.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep1");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep2.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep2");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep3.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep3");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep4.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep4");
				m_StatsHeader.swapDepths(this.getNextHighestDepth());
				m_LevelUpgrade.swapDepths(this.getNextHighestDepth());
				m_UpgradeProgress.swapDepths(this.getNextHighestDepth());
			}
			else if (!Lore.IsLocked(GLYPH_UNLOCK_TAG) && Lore.IsLocked(GLYPH_TUTORIAL_COMPLETE_TAG))
			{
				m_TutorialBlocker = this.attachMovie("FusionTutorialBlocker", "m_TutorialBlocker", this.getNextHighestDepth());
				m_TutorialBlocker.m_FuseItems.onRelease = function(){};
				m_TutorialBlocker.m_FuseItems._visible = false;
				
				m_TutorialBlocker.m_SelectFusion.m_FusionTutorialStep1.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep1");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep2.htmlText = LDBFormat.LDBGetText("Crafting", "GlyphTutorialStep2");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep3.htmlText = LDBFormat.LDBGetText("Crafting", "GlyphTutorialStep3");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep4.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep4");
				m_StatsHeader.swapDepths(this.getNextHighestDepth());
				m_LevelUpgrade.swapDepths(this.getNextHighestDepth());
				m_UpgradeProgress.swapDepths(this.getNextHighestDepth());
			}
		}
		
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
		
		m_Character.SignalTokenAmountChanged.Connect(SlotTokenChanged, this);
		
		CraftingInterface.SignalCraftingResultFeedback.Connect(SlotCraftingResultFeedback, this);
		
		m_Inventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_CraftingInventory, Character.GetClientCharID().GetInstance()));
		m_Inventory.SignalItemAdded.Connect( SlotItemAdded, this);
		m_Inventory.SignalItemLoaded.Connect( SlotItemAdded, this);
		m_Inventory.SignalItemMoved.Connect( SlotItemMoved, this);
		m_Inventory.SignalItemRemoved.Connect( SlotItemRemoved, this);
		m_Inventory.SignalItemChanged.Connect( SlotItemChanged, this);
		m_Inventory.SignalItemStatChanged.Connect( SlotItemStatChanged, this );
		
		InitializeItemSlots();
		com.Utils.GlobalSignal.SignalSendItemToUpgrade.Connect(SlotReceiveItem, this);
		
		m_EmpowermentTab.m_AssembleButton.disableFocus = true;
		m_EmpowermentTab.m_AssembleButton.disabled = true;
		m_EmpowermentTab.m_AssembleButton.addEventListener( "click", this, "SlotStartEmpowerment" )
		m_FusionTab.m_AssembleButton.disableFocus = true;
		m_FusionTab.m_AssembleButton.disabled = true;
		m_FusionTab.m_AssembleButton.addEventListener( "click", this, "SlotStartFusion" );
		m_DestroyGlyphButton.disableFocus = true;
		m_DestroyGlyphButton.addEventListener( "click", this, "SlotDestroyGlyph" );
		m_RecoverGlyphButton.disableFocus = true;
		m_RecoverGlyphButton.addEventListener( "click", this, "SlotRecoverGlyph" );
		m_DestroySignetButton.disableFocus = true;
		m_DestroySignetButton.addEventListener( "click", this, "SlotDestroySignet" );
		m_RecoverSignetButton.disableFocus = true;
		m_RecoverSignetButton.addEventListener( "click", this, "SlotRecoverSignet" );
						
		m_EmpowermentTab.m_HitArea.onRelease = Delegate.create(this, SwitchToEmpowerment);
		m_FusionTab.m_HitArea.onRelease = Delegate.create(this, SwitchToFusion);
		
		m_EmpowermentTab.m_InstantBuy.onRelease = Delegate.create(this, BuyEmpowerBoosters);
		m_FusionTab.m_InstantBuy.onRelease = Delegate.create(this, BuyFusionBoosters);
		
		SetLabels();
	}
	
	//Set Labels
    private function SetLabels():Void
    {	   
	   m_EmpowermentTab.m_TabName.text = LDBFormat.LDBGetText("Crafting", "Empowerment");
	   m_EmpowermentTab.m_AssembleButton.label = LDB_ASSEMBLE = LDBFormat.LDBGetText("GenericGUI", "CraftingAssemble");
	   m_EmpowermentTab.m_AssembleButton.m_Token._visible = false;
	   m_EmpowermentTab.m_AssembleButton.m_Token.m_T201._visible = false;
	   m_EmpowermentTab.m_CompareHeader.text = LDBFormat.LDBGetText("Crafting", "StatChanges");
	   
	   m_FusionTab.m_TabName.text = LDBFormat.LDBGetText("Crafting", "Fusion");
	   m_FusionTab.m_AssembleButton.label = LDB_FUSE = LDBFormat.LDBGetText("Crafting", "Fuse");
	   m_FusionTab.m_AssembleButton.m_Token._visible = false;
	   m_FusionTab.m_AssembleButton.m_Token.m_T10._visible = false;
	   m_DestroyGlyphButton.label = LDBFormat.LDBGetText("Crafting", "DestroyGlyph");
	   m_DestroySignetButton.label = LDBFormat.LDBGetText("Crafting", "DestroySignet");
	   m_FusionTab.m_FusionEmptyText.text = LDBFormat.LDBGetText("Crafting", "FusionSlotInstructions");
	   
	   m_RulesHeader.text = LDBFormat.LDBGetText("Crafting", "RulesHeader");
	   m_GlyphHeader.text = LDBFormat.LDBGetText("ItemTypeGUI", "Glyph").toUpperCase();
	   m_SignetHeader.text = LDBFormat.LDBGetText("ItemTypeGUI", "Signet").toUpperCase();
	   
	   m_RecoverGlyphButton["textHeader"].text = LDBFormat.LDBGetText("Crafting", "RecoverGlyph");
	   m_RecoverGlyphButton.textField.text = Text.AddThousandsSeparator(Utils.GetGameTweak("GlyphRecoveryCost"));
	   
	   m_RecoverSignetButton["textHeader"].text = LDBFormat.LDBGetText("Crafting", "RecoverSignet");
	   m_RecoverSignetButton.textField.text = Text.AddThousandsSeparator(Utils.GetGameTweak("SignetRecoveryCost"));	   
    }
	
	private function InitializeItemSlots()
	{
		m_ItemSlots = new Array();
		m_ItemSlots[TARGET_SLOT] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, TARGET_SLOT, m_TargetSlot), m_IsPreview:false};
		m_ItemSlots[TARGET_SLOT].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[TARGET_SLOT].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[TARGET_SLOT].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[TARGET_SLOT].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[TARGET_SLOT].m_ItemSlot.SetData(m_Inventory.GetItemAt(TARGET_SLOT));
		
		m_ItemSlots[FUSION_SLOT] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, FUSION_SLOT, m_FusionTab.m_FusionSlot), m_IsPreview:false};
		m_ItemSlots[FUSION_SLOT].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[FUSION_SLOT].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[FUSION_SLOT].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[FUSION_SLOT].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[FUSION_SLOT].m_ItemSlot.SetData(m_Inventory.GetItemAt(FUSION_SLOT));
		
		m_ItemSlots[RESULT_SLOT] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, RESULT_SLOT, m_FusionTab.m_ResultSlot), m_IsPreview:true};
		m_ItemSlots[RESULT_SLOW].m_ItemSlot.SetCanDrag(false);
		m_ItemSlots[RESULT_SLOT].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[RESULT_SLOT].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[RESULT_SLOT].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[RESULT_SLOT].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[RESULT_SLOT].m_ItemSlot.SetData(m_Inventory.GetItemAt(RESULT_SLOT));
		
		m_ItemSlots[EMPOWER_SLOT_0] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, EMPOWER_SLOT_0, m_EmpowermentTab.m_EmpowerSlot_0), m_IsPreview:false};
		m_ItemSlots[EMPOWER_SLOT_0].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[EMPOWER_SLOT_0].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[EMPOWER_SLOT_0].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[EMPOWER_SLOT_0].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[EMPOWER_SLOT_0].m_ItemSlot.SetData(m_Inventory.GetItemAt(EMPOWER_SLOT_0));
		
		m_ItemSlots[EMPOWER_SLOT_1] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, EMPOWER_SLOT_1, m_EmpowermentTab.m_EmpowerSlot_1), m_IsPreview:false};
		m_ItemSlots[EMPOWER_SLOT_1].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[EMPOWER_SLOT_1].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[EMPOWER_SLOT_1].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[EMPOWER_SLOT_1].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[EMPOWER_SLOT_1].m_ItemSlot.SetData(m_Inventory.GetItemAt(EMPOWER_SLOT_1));
		
		m_ItemSlots[EMPOWER_SLOT_2] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, EMPOWER_SLOT_2, m_EmpowermentTab.m_EmpowerSlot_2), m_IsPreview:false};
		m_ItemSlots[EMPOWER_SLOT_2].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[EMPOWER_SLOT_2].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[EMPOWER_SLOT_2].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[EMPOWER_SLOT_2].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[EMPOWER_SLOT_2].m_ItemSlot.SetData(m_Inventory.GetItemAt(EMPOWER_SLOT_2));
		
		m_ItemSlots[EMPOWER_SLOT_3] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, EMPOWER_SLOT_3, m_EmpowermentTab.m_EmpowerSlot_3), m_IsPreview:false};
		m_ItemSlots[EMPOWER_SLOT_3].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[EMPOWER_SLOT_3].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[EMPOWER_SLOT_3].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[EMPOWER_SLOT_3].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[EMPOWER_SLOT_3].m_ItemSlot.SetData(m_Inventory.GetItemAt(EMPOWER_SLOT_3));
		
		m_ItemSlots[EMPOWER_SLOT_4] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, EMPOWER_SLOT_4, m_EmpowermentTab.m_EmpowerSlot_4), m_IsPreview:false};
		m_ItemSlots[EMPOWER_SLOT_4].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[EMPOWER_SLOT_4].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[EMPOWER_SLOT_4].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[EMPOWER_SLOT_4].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[EMPOWER_SLOT_4].m_ItemSlot.SetData(m_Inventory.GetItemAt(EMPOWER_SLOT_4));
	}
	
	function SlotCraftingResultFeedback(result:Number, numItems:Number, feedback:String, items:Array, percentChance:Number, cost:Number, crit:Boolean, leveled:Boolean, stateArray:Array, validFeedback:Number, bonusFeedback:Number, fusionFeedback:Number)
	{
		switch(result)
		{
			case _global.Enums.CraftingPhase.e_LuaSuccess:
				m_CurrentCost = cost;
				m_CurrentResult = items[0];
				break;
			case _global.Enums.CraftingPhase.e_Crafted:
				var assembleAnim:MovieClip = m_TargetSlot.attachMovie("FuseAssembleAnimation_Centered", "fuseAssembleAnim_"+m_TargetSlot.UID(), m_TargetSlot.getNextHighestDepth());
				assembleAnim._xscale = assembleAnim._yscale = 65;
				if (crit)
				{
					if (m_Character != undefined && DistributedValue.GetDValue("NoncombatVoiceHelp", true))
					{
						m_Character.AddEffectPackage("sound_fxpackage_GUI_critical_empowerment_results.xml");
					}
					var critAnim:MovieClip = m_TargetSlot.attachMovie("CritAnim_1", "CritAnim_"+m_TargetSlot.UID(), m_TargetSlot.getNextHighestDepth());
					critAnim._xscale = critAnim._yscale = 45;
				}
				if (leveled)
				{
					if (m_Character != undefined)
					{
						m_Character.AddEffectPackage("sound_fxpackage_GUI_weapon_upgrade_arrows");
					}
					m_TargetSlot.attachMovie("WeaponLevelAnim_Centered", "weaponLevelAnim_"+m_TargetSlot.UID(), m_TargetSlot.getNextHighestDepth());
				}
			case _global.Enums.CraftingPhase.e_NoRecipes:
			case _global.Enums.CraftingPhase.e_Phase1CheckRelevantRecipes:
			case _global.Enums.CraftingPhase.e_Phase2CheckGridNumbers:
			case _global.Enums.CraftingPhase.e_Phase3CheckPositioning:
			case _global.Enums.CraftingPhase.e_Phase4CheckStackSizes:
			case _global.Enums.CraftingPhase.e_NoUpdate:
			case _global.Enums.CraftingPhase.e_Phase5CheckTools:
			case _global.Enums.CraftingPhase.e_DisassemblyPass:
			case _global.Enums.CraftingPhase.e_Disassembled:				
			case _global.Enums.CraftingPhase.e_LuaFailed:
			case _global.Enums.CraftingPhase.e_ClearGrid:
			case _global.Enums.CraftingPhase.e_SetData:
			default:
				m_CurrentResult = undefined;
				m_CurrentCost = undefined;
				break;
		}
		
		m_ValidFeedback = validFeedback;
		m_BonusFeedback = bonusFeedback;
		m_FusionFeedback = fusionFeedback;
		
		UpdateFeedback();
		UpdateResult();
		UpdateSlotStates(stateArray);
		UpdateAssembleButton();
	}
	
	private function UpdateFeedback()
	{
		if (m_ValidFeedback != 0 && m_BonusFeedback != 0 && m_CurrentTab == EMPOWERMENT_TAB)
		{
			m_HelpText.htmlText = LDBFormat.LDBGetText("Crafting", m_BonusFeedback) + "<br>" + LDBFormat.LDBGetText("Crafting", m_ValidFeedback);
		}
		else if (m_FusionFeedback != 0 && m_CurrentTab == FUSION_TAB)
		{
			m_HelpText.htmlText = LDBFormat.LDBGetText("Crafting", m_FusionFeedback);
		}
		else
		{
			m_HelpText.htmlText = "";
		}
	}
	
	private function UpdateSlotStates(stateArray)
	{
		trace("UPDATING SLOT STATES");
		ClearSlotStates();
		if (stateArray != undefined)
		{
			trace("STATE ARRAY: " + stateArray);
			if (m_CurrentTab == EMPOWERMENT_TAB)
			{
				for (var i:Number=0; i < stateArray.length; i++)
				{
					var slotClip:MovieClip = m_ItemSlots[i + EMPOWER_SLOT_0].m_ItemSlot.GetSlotMC();
					if (stateArray[i] > 0)
					{
						var slotState:MovieClip = slotClip.attachMovie("BonusItem", "m_State", slotClip.getNextHighestDepth());
						slotState._x = -3;
						slotState._y = -3;
						slotState._xscale = slotState._yscale = 90;
						m_SlotStates.push(slotState);
					}
					else if (stateArray[i] < 0)
					{
						var slotState:MovieClip = slotClip.attachMovie("WrongItem", "m_State", slotClip.getNextHighestDepth());
						slotState._x = -3;
						slotState._y = -3;
						slotState._xscale = slotState._yscale = 90;
						m_SlotStates.push(slotState);
					}
				}
			}
		}
	}
	
	private function ClearSlotStates()
	{
		if (m_SlotStates != undefined)
		{
			for (var i:Number = 0; i < m_SlotStates.length; i++)
			{
				m_SlotStates[i].removeMovieClip();
			}
		}
		m_SlotStates = new Array();
	}
	
	private function SetCraftingCost(craftingButton:MovieClip, buttonLabel:String, cost:Number)
	{
		craftingButton.label = buttonLabel + ": " + Text.AddThousandsSeparator(cost);
		if (cost > 0)
		{
			craftingButton.m_Token._visible = true;
			craftingButton.m_Token._x = craftingButton.m_Frame._width / 2 + craftingButton.textField.textWidth / 2 + 5;
		}		
	}
	
	private function UpdateResult()
	{
		if (m_CurrentTab == FUSION_TAB)
		{
			if (m_CurrentResult != undefined)
			{
				m_ItemSlots[RESULT_SLOT].m_ItemSlot.SetData(m_CurrentResult);
				//m_FusionTab.m_ResultBG.gotoAndPlay("itemplaced");
				m_FusionTab.m_ResultName.text = m_CurrentResult.m_Name;
			}
			else
			{
				//m_FusionTab.m_ResultBG.gotoAndPlay("static");
				m_ItemSlots[RESULT_SLOT].m_ItemSlot.Clear();
				m_FusionTab.m_ResultName.text = "";
			}
		}
		UpdateStatsDisplay();
	}	
	
	private function UpdateAssembleButton()
	{
		if (m_CurrentResult != undefined)
		{
			var tokens = m_Character.GetTokens(_global.Enums.Token.e_Cash);
			if (m_CurrentTab == FUSION_TAB){ tokens = m_Character.GetTokens(_global.Enums.Token.e_Gold_Bullion_Token); }
			SetCraftingCost(m_EmpowermentTab.m_AssembleButton, LDB_ASSEMBLE, m_CurrentCost);
			SetCraftingCost(m_FusionTab.m_AssembleButton, LDB_FUSE, m_CurrentCost);
			if (tokens >= m_CurrentCost)
			{
				m_EmpowermentTab.m_AssembleButton.m_Token._alpha = 100;
				m_EmpowermentTab.m_AssembleButton.disabled = false;
				m_FusionTab.m_AssembleButton.m_Token._alpha = 100;
				m_FusionTab.m_AssembleButton.disabled = false;
				return;
			}
		}
		else
		{
			m_EmpowermentTab.m_AssembleButton.label = LDB_ASSEMBLE;
			m_EmpowermentTab.m_AssembleButton.m_Token._visible = false;
			m_FusionTab.m_AssembleButton.label = LDB_FUSE;
			m_FusionTab.m_AssembleButton.m_Token._visible = false;
		}
		m_EmpowermentTab.m_AssembleButton.m_Token._alpha = 60;
		m_EmpowermentTab.m_AssembleButton.disabled = true;
		m_FusionTab.m_AssembleButton.m_Token._alpha = 60;
		m_FusionTab.m_AssembleButton.disabled = true;
	}
	
	private function SwitchToEmpowerment()
	{
		
		if ((!Lore.IsLocked(FUSION_UNLOCK_TAG) && Lore.IsLocked(FUSION_TUTORIAL_COMPLETE_TAG)) ||
			(!Lore.IsLocked(GLYPH_UNLOCK_TAG) && Lore.IsLocked(GLYPH_TUTORIAL_COMPLETE_TAG)))
		{
			m_TutorialBlocker.m_SelectFusion._visible = true;
			m_TutorialBlocker.m_FuseItems._visible = false;
		}
		
		var clientCharID:ID32 = Character.GetClientCharID();
		var backpack:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, clientCharID.GetInstance()));
		//If the character sheet is open and this is the target, try to equip this
		if (GUIModuleIF.FindModuleIF("CharacterSheet").IsActive() && m_FromEquipped[FUSION_SLOT])
		{
			m_Inventory.UseItem(FUSION_SLOT);
		}
		else
		{
			backpack.AddItem(m_Inventory.m_InventoryID, FUSION_SLOT, backpack.GetFirstFreeItemSlot());
		}
		//This should never happen because the result item is ever real, but just in case...
		if (GUIModuleIF.FindModuleIF("CharacterSheet").IsActive() && m_FromEquipped[RESULT_SLOT])
		{
			m_Inventory.UseItem(RESULT_SLOT);
		}
		backpack.AddItem(m_Inventory.m_InventoryID, RESULT_SLOT, backpack.GetFirstFreeItemSlot());
		
		m_EmpowermentTab.m_HitArea._alpha = 0;
		m_EmpowermentTab.m_HitArea.onRollOver = m_EmpowermentTab.m_HitArea.onDragOver = function(){}
		m_EmpowermentTab.m_HitArea.onRollOut = m_EmpowermentTab.m_HitArea.onDragOut = function(){}
		if (!Lore.IsLocked(FUSION_UNLOCK_TAG))
		{
			m_FusionTab.m_HitArea.onRollOver = m_FusionTab.m_HitArea.onDragOver = function(){this._alpha = 10;}
			m_FusionTab.m_HitArea.onRollOut = m_FusionTab.m_HitArea.onDragOut = function(){this._alpha = 0;}
		}
		
		ShowTab(EMPOWERMENT_TAB);
	}
	
	private function SwitchToFusion()
	{
		if (Lore.IsLocked(FUSION_UNLOCK_TAG))
		{
			return;
		}
		
		if (Lore.IsLocked(FUSION_TUTORIAL_COMPLETE_TAG) ||
			(!Lore.IsLocked(GLYPH_UNLOCK_TAG) && Lore.IsLocked(GLYPH_TUTORIAL_COMPLETE_TAG)))
		{
			m_TutorialBlocker.m_SelectFusion._visible = false;
			m_TutorialBlocker.m_FuseItems._visible = true;
		}
		
		var clientCharID:ID32 = Character.GetClientCharID();
		var backpack:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, clientCharID.GetInstance()));
		for (var i:Number = EMPOWER_SLOT_0; i<= EMPOWER_SLOT_4; i++)
		{
			if (GUIModuleIF.FindModuleIF("CharacterSheet").IsActive() && m_FromEquipped[i])
			{
				m_Inventory.UseItem(i);
			}
			else
			{
				backpack.AddItem(m_Inventory.m_InventoryID, i, backpack.GetFirstFreeItemSlot());
			}
		}
		
		m_FusionTab.m_HitArea._alpha = 0;
		m_FusionTab.m_HitArea.onRollOver = m_FusionTab.m_HitArea.onDragOver = function(){}
		m_FusionTab.m_HitArea.onRollOut = m_FusionTab.m_HitArea.onDragOut = function(){}
		m_EmpowermentTab.m_HitArea.onRollOver = m_EmpowermentTab.m_HitArea.onDragOver = function(){this._alpha = 10;}
		m_EmpowermentTab.m_HitArea.onRollOut = m_EmpowermentTab.m_HitArea.onDragOut = function(){this._alpha = 0;}
		
		ShowTab(FUSION_TAB);
	}
	
	private function ShowTab(tabId:Number)
	{
		//Don't do anything if we are already on the right tab
		if (m_CurrentTab == tabId)
		{
			return;
		}
		
		m_CurrentTab = tabId;
		
		var showEmpowerment:Boolean = m_CurrentTab == EMPOWERMENT_TAB;
		var showFusion:Boolean = m_CurrentTab == FUSION_TAB;

		//Empowerment
		m_EmpowermentTab.m_BottomLine._visible = showEmpowerment;
		m_EmpowermentTab.m_TopLine._visible = showEmpowerment;
		m_EmpowermentTab.m_Lines._visible = showEmpowerment;
		for (var i:Number = 0; i < 5; i++)
		{
			m_EmpowermentTab["m_BG_" + i]._visible = showEmpowerment;
			m_EmpowermentTab["m_EmpowerSlot_" + i]._visible = showEmpowerment;
		}
		m_EmpowermentTab.m_AssembleButton._visible = showEmpowerment;
		//TODO: Flip this to true if we ever want to sell these
		m_EmpowermentTab.m_InstantBuy._visible = false;
		
		//Fusion
		m_FusionTab.m_BottomLine._visible = showFusion;
		m_FusionTab.m_TopLine._visible = showFusion;
		m_FusionTab.m_Lines._visible = showFusion;
		m_FusionTab.m_FusionBG._visible = showFusion;
		m_FusionTab.m_FusionSlot._visible = showFusion;
		m_FusionTab.m_ResultName._visible = showFusion;
		m_FusionTab.m_FusionEmptyText._visible = showFusion && (m_Inventory.GetItemAt(FUSION_SLOT) == undefined);
		m_FusionTab.m_AssembleButton._visible = showFusion;
		m_FusionTab.m_InstantBuy._visible = showFusion;
		
		if (m_CurrentTab == EMPOWERMENT_TAB && m_EmpowermentTab.getDepth() < m_FusionTab.getDepth())
		{
			m_EmpowermentTab.swapDepths(m_FusionTab);
		}
		if (m_CurrentTab == FUSION_TAB && m_FusionTab.getDepth() < m_EmpowermentTab.getDepth())
		{
			m_FusionTab.swapDepths(m_EmpowermentTab);
		}
		
		UpdateFeedback();
		ClearSlotStates();
		UpdateResult();
	}
	
	//TODO: Go back and make this function more readable. Right now I just don't have time.
	private function UpdateStatsDisplay()
	{
		trace("****** UPDATING STATS DISPLAY ******");
		var targetItem:InventoryItem = m_ItemSlots[TARGET_SLOT].m_ItemSlot.m_ItemData;
		var resultItem:InventoryItem = m_CurrentResult;
		//Clear if we have no item to display stats for
		if (targetItem == undefined)
		{
			trace("****** THERE IS NO TARGET. CLEARING DISPLAY. ******");
			ClearStatsDisplay();
			return;
		}
		
		//Display stats for the target item
		if (targetItem != undefined)
		{
			trace(" ");
			trace("__________TARGET ITEM__________");
			this._parent.SetTitle(targetItem.m_Name);
			m_StatsHeader._visible = true;
			m_LevelUpgrade._visible = true;
			m_GlyphLevelUpgrade._visible = true;
			m_SignetLevelUpgrade._visible = true;
			m_UpgradeProgress._visible = true;
			m_GlyphUpgradeProgress._visible = true;
			m_SignetUpgradeProgress._visible = true;
			
			//Base Item
			var xpToCurrentLevel = Inventory.GetItemXPForLevel(targetItem.m_RealType, targetItem.m_Rarity, targetItem.m_Rank);
			var xpToNextLevel = Inventory.GetItemXPForLevel(targetItem.m_RealType, targetItem.m_Rarity, targetItem.m_Rank + 1);
			var levelXP:Number = targetItem.m_XP - xpToCurrentLevel;
			var XPToLevel:Number = xpToNextLevel - xpToCurrentLevel;
			
			trace("RANK: " + targetItem.m_Rank);
			trace("XP TO CURRENT LEVEL: " + xpToCurrentLevel);
			trace("XP TO NEXT LEVEL: " + xpToNextLevel);
			trace("XP GAINED THIS LEVEL: " + levelXP);
			trace("XP NEEDED TO LEVEL: " + XPToLevel);
			
			var currentPercent:Number = xpToNextLevel > 0 ? (levelXP / XPToLevel) * 100 : 100;
			m_UpgradeProgress.m_CurrentXP._xscale = Math.max(0, Math.min(currentPercent, 100));
			m_UpgradeProgress.m_UpgradeXP._xscale = 0;
			m_UpgradeProgress.m_Text.text = "";
			if (xpToNextLevel == 0)
			{
				m_UpgradeProgress.m_Text.text = LDBFormat.LDBGetText("Crafting", "MaxLevel");
			}
			
			m_LevelUpgrade.m_Arrow._visible = false;
			m_LevelUpgrade.m_UpgradeLevel._visible = false;
			m_LevelUpgrade.m_CurrentLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + targetItem.m_Rank;
			m_LevelUpgrade.m_ItemTypeText.text = LDBFormat.LDBGetText("ItemTypeGUI", targetItem.m_ItemTypeGUI);
			m_LevelUpgrade.m_ItemTypeText._x = m_LevelUpgrade.m_CurrentLevel.textWidth + 5;
			
			//Glyph Stats			
			if (targetItem.m_ACGItem.m_TemplateID1 != 0 && targetItem.m_ACGItem.m_TemplateID1 != targetItem.m_ACGItem.m_TemplateID0)
			{
				trace(" ");
				trace("__________TARGET GLYPH__________");
				m_GlyphUpgradeProgress._alpha = 100;
				m_GlyphLevelUpgrade._alpha = 100;
				xpToCurrentLevel = Inventory.GetItemXPForLevel(_global.Enums.ItemType.e_Type_GC_Item_Generated_Prefix_NonWeapon, targetItem.m_GlyphRarity, targetItem.m_GlyphRank);
				xpToNextLevel = Inventory.GetItemXPForLevel(_global.Enums.ItemType.e_Type_GC_Item_Generated_Prefix_NonWeapon, targetItem.m_GlyphRarity, targetItem.m_GlyphRank + 1);
				levelXP = targetItem.m_GlyphXP - xpToCurrentLevel;
				XPToLevel = xpToNextLevel - xpToCurrentLevel;
				
				trace("GLYPH RANK: " + targetItem.m_GlyphRank);
				trace("GLYPH XP TO CURRENT LEVEL: " + xpToCurrentLevel);
				trace("GLYPH XP TO NEXT LEVEL: " + xpToNextLevel);
				trace("GLYPH XP GAINED THIS LEVEL: " + levelXP);
				trace("GLYPH XP NEEDED TO LEVEL: " + XPToLevel);
				
				currentPercent = xpToNextLevel > 0 ? (levelXP / XPToLevel) * 100 : 100;
				m_GlyphUpgradeProgress.m_CurrentXP._xscale = Math.max(0, Math.min(currentPercent, 100));
				m_GlyphUpgradeProgress.m_UpgradeXP._xscale = 0;
				m_GlyphUpgradeProgress.m_Text.text = "";
				if (xpToNextLevel == 0)
				{
					m_GlyphUpgradeProgress.m_Text.text = LDBFormat.LDBGetText("Crafting", "MaxLevel");
				}
				
				m_GlyphLevelUpgrade.m_Arrow._visible = false;
				m_GlyphLevelUpgrade.m_UpgradeLevel._visible = false;
				m_GlyphLevelUpgrade.m_CurrentLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + targetItem.m_GlyphRank;
				m_GlyphLevelUpgrade.m_ItemTypeText.text = LDBFormat.LDBGetText("ItemTypeGUI", "Glyph");
				m_GlyphLevelUpgrade.m_ItemTypeText._x = m_GlyphLevelUpgrade.m_CurrentLevel.textWidth + 5;
			}
			else
			{
				trace(" ");
				trace("__________TARGET HAS NO GLYPH__________");
				m_GlyphUpgradeProgress._alpha = 25;
				m_GlyphLevelUpgrade._alpha = 25;
				m_GlyphUpgradeProgress.m_CurrentXP._xscale = 0;
				m_GlyphUpgradeProgress.m_UpgradeXP._xscale = 0;
				m_GlyphUpgradeProgress.m_Text.text = "";
				m_GlyphLevelUpgrade.m_Arrow._visible = false;
				m_GlyphLevelUpgrade.m_UpgradeLevel._visible = false;
				m_GlyphLevelUpgrade.m_CurrentLevel.text = "";
				m_GlyphLevelUpgrade.m_ItemTypeText.text = LDBFormat.LDBGetText("ItemTypeGUI", "Glyph");
				m_GlyphLevelUpgrade.m_ItemTypeText._x = m_GlyphLevelUpgrade.m_CurrentLevel.textWidth + 5;
			}
			
			//Signet Stats
			if (targetItem.m_ACGItem.m_TemplateID2 != 0 && targetItem.m_ItemType != _global.Enums.ItemType.e_ItemType_Weapon)
			{
				trace(" ");
				trace("__________TARGET SIGNET__________");
				m_SignetUpgradeProgress._alpha = 100;
				m_SignetLevelUpgrade._alpha = 100;
				xpToCurrentLevel = Inventory.GetItemXPForLevel(_global.Enums.ItemType.e_Type_GC_Item_Generated_Suffix_NonWeapon, targetItem.m_SignetRarity, targetItem.m_SignetRank);
				xpToNextLevel = Inventory.GetItemXPForLevel(_global.Enums.ItemType.e_Type_GC_Item_Generated_Suffix_NonWeapon, targetItem.m_SignetRarity, targetItem.m_SignetRank + 1);
				levelXP = targetItem.m_SignetXP - xpToCurrentLevel;
				XPToLevel = xpToNextLevel - xpToCurrentLevel;
				
				trace("SIGNET RANK: " + targetItem.m_SignetRank);
				trace("SIGNET XP TO CURRENT LEVEL: " + xpToCurrentLevel);
				trace("SIGNET XP TO NEXT LEVEL: " + xpToNextLevel);
				trace("SIGNET XP GAINED THIS LEVEL: " + levelXP);
				trace("SIGNET XP NEEDED TO LEVEL: " + XPToLevel);
				
				currentPercent = xpToNextLevel > 0 ? (levelXP / XPToLevel) * 100 : 100;
				m_SignetUpgradeProgress.m_CurrentXP._xscale = Math.max(0, Math.min(currentPercent, 100));
				m_SignetUpgradeProgress.m_UpgradeXP._xscale = 0;
				m_SignetUpgradeProgress.m_Text.text = "";
				if (xpToNextLevel == 0)
				{
					m_SignetUpgradeProgress.m_Text.text = LDBFormat.LDBGetText("Crafting", "MaxLevel");
				}
				
				m_SignetLevelUpgrade.m_Arrow._visible = false;
				m_SignetLevelUpgrade.m_UpgradeLevel._visible = false;
				m_SignetLevelUpgrade.m_CurrentLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + targetItem.m_SignetRank;
				m_SignetLevelUpgrade.m_ItemTypeText.text = LDBFormat.LDBGetText("ItemTypeGUI", "Signet");
				m_SignetLevelUpgrade.m_ItemTypeText._x = m_SignetLevelUpgrade.m_CurrentLevel.textWidth + 5;
			}
			else
			{
				trace(" ");
				trace("__________TARGET HAS NO SIGNET__________");
				m_SignetUpgradeProgress._alpha = 25;
				m_SignetLevelUpgrade._alpha = 25;
				m_SignetUpgradeProgress.m_CurrentXP._xscale = 0;
				m_SignetUpgradeProgress.m_UpgradeXP._xscale = 0;
				m_SignetUpgradeProgress.m_Text.text = "";
				m_SignetLevelUpgrade.m_Arrow._visible = false;
				m_SignetLevelUpgrade.m_UpgradeLevel._visible = false;
				m_SignetLevelUpgrade.m_CurrentLevel.text = "";
				m_SignetLevelUpgrade.m_ItemTypeText.text = LDBFormat.LDBGetText("ItemTypeGUI", "Signet");
				m_SignetLevelUpgrade.m_ItemTypeText._x = m_SignetLevelUpgrade.m_CurrentLevel.textWidth + 5;
			}
		}
		
		//Display modifications on the result item
		if (resultItem != undefined)
		{	
			trace(" ");
			trace("__________RESULT ITEM__________");
			//Base Item
			if (resultItem.m_Rank != targetItem.m_Rank)
			{
				trace("ITEM LEVELED UP!");
				//Level upgrade display
				m_LevelUpgrade.m_Arrow._visible = true;
				m_LevelUpgrade.m_UpgradeLevel._visible = true;
				m_LevelUpgrade.m_UpgradeLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + resultItem.m_Rank;
				m_LevelUpgrade.m_ItemTypeText.text = LDBFormat.LDBGetText("ItemTypeGUI", resultItem.m_ItemTypeGUI);
				if (targetItem.m_Rarity != resultItem.m_Rarity)
				{
					m_LevelUpgrade.m_UpgradeLevel.textColor = Colors.GetItemRarityColor(resultItem.m_Rarity);
				}
				else
				{
					m_LevelUpgrade.m_UpgradeLevel.textColor = 0x6BB9FF;
				}
				m_LevelUpgrade.m_Arrow._x = m_LevelUpgrade.m_CurrentLevel.textWidth + 10;
				m_LevelUpgrade.m_UpgradeLevel._x = m_LevelUpgrade.m_Arrow._x + m_LevelUpgrade.m_Arrow._width;
				m_LevelUpgrade.m_ItemTypeText._x = m_LevelUpgrade.m_UpgradeLevel._x + m_LevelUpgrade.m_UpgradeLevel.textWidth + 5;
				
				//Override XP bar
				//We are on a new level, the XP on the target item doesn't count
				m_UpgradeProgress.m_CurrentXP._xscale = 0;
			}
			
			var xpToCurrentLevel = Inventory.GetItemXPForLevel(resultItem.m_RealType, resultItem.m_Rarity, resultItem.m_Rank);
			var xpToNextLevel = Inventory.GetItemXPForLevel(resultItem.m_RealType, resultItem.m_Rarity, resultItem.m_Rank + 1);
			var levelXP:Number = resultItem.m_XP - xpToCurrentLevel;
			var XPToLevel:Number = xpToNextLevel - xpToCurrentLevel;
			
			trace("RANK: " + resultItem.m_Rank);
			trace("XP TO CURRENT LEVEL: " + xpToCurrentLevel);
			trace("XP TO NEXT LEVEL: " + xpToNextLevel);
			trace("XP GAINED THIS LEVEL: " + levelXP);
			trace("XP NEEDED TO LEVEL: " + XPToLevel);
			
			var currentPercent:Number = xpToNextLevel > 0 ? (levelXP / XPToLevel) * 100 : 100;
			m_UpgradeProgress.m_UpgradeXP._xscale = Math.max(0, Math.min(currentPercent, 100));
			
			var xpDiff:Number = resultItem.m_XP - targetItem.m_XP;
			m_UpgradeProgress.m_Text.text = xpDiff > 0 ? "+ " + xpDiff + " " + LDBFormat.LDBGetText("Crafting", "XP") : "";
			
			//Glyph
			if (resultItem.m_ACGItem.m_TemplateID1 != 0 && resultItem.m_ACGItem.m_TemplateID1 != resultItem.m_ACGItem.m_TemplateID0)
			{
				trace(" ");
				trace("__________RESULT GLYPH__________");
				if (resultItem.m_GlyphRank != targetItem.m_GlyphRank)
				{
					trace("GLYPH LEVELED UP!");
					//Level upgrade display
					m_GlyphLevelUpgrade.m_Arrow._visible = true;
					m_GlyphLevelUpgrade.m_UpgradeLevel._visible = true;
					m_GlyphLevelUpgrade.m_UpgradeLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + resultItem.m_GlyphRank;
					m_GlyphLevelUpgrade.m_ItemTypeText.text = LDBFormat.LDBGetText("ItemTypeGUI", "Glyph");
					if (targetItem.m_GlyphRarity != resultItem.m_GlyphRarity)
					{
						m_GlyphLevelUpgrade.m_UpgradeLevel.textColor = Colors.GetItemRarityColor(resultItem.m_GlyphRarity);
					}
					else
					{
						m_GlyphLevelUpgrade.m_UpgradeLevel.textColor = 0x6BB9FF;
					}
					m_GlyphLevelUpgrade.m_Arrow._x = m_GlyphLevelUpgrade.m_CurrentLevel.textWidth + 10;
					m_GlyphLevelUpgrade.m_UpgradeLevel._x = m_GlyphLevelUpgrade.m_Arrow._x + m_LevelUpgrade.m_Arrow._width;
					m_GlyphLevelUpgrade.m_ItemTypeText._x = m_GlyphLevelUpgrade.m_UpgradeLevel._x + m_GlyphLevelUpgrade.m_UpgradeLevel.textWidth + 5;
					
					//There wasn't a glyph previously, we are adding one
					if (targetItem.m_ACGItem.m_TemplateID1 == 0 || targetItem.m_ACGItem.m_TemplateID1 == targetItem.m_ACGItem.m_TemplateID0)
					{
						trace("THIS IS A NEW GLYPH!");
						m_GlyphUpgradeProgress._alpha = 100;
						m_GlyphLevelUpgrade._alpha = 100;
						m_GlyphLevelUpgrade.m_Arrow._visible = false;
						m_GlyphLevelUpgrade.m_UpgradeLevel._x = 0;
						m_GlyphLevelUpgrade.m_ItemTypeText._x = m_GlyphLevelUpgrade.m_UpgradeLevel._x + m_GlyphLevelUpgrade.m_UpgradeLevel.textWidth + 5;
					}
					
					//Override XP bar
					//We are on a new level, the XP on the target item doesn't count
					m_GlyphUpgradeProgress.m_CurrentXP._xscale = 0;
				}
			
				xpToCurrentLevel = Inventory.GetItemXPForLevel(_global.Enums.ItemType.e_Type_GC_Item_Generated_Prefix_NonWeapon, resultItem.m_GlyphRarity, resultItem.m_GlyphRank);
				xpToNextLevel = Inventory.GetItemXPForLevel(_global.Enums.ItemType.e_Type_GC_Item_Generated_Prefix_NonWeapon, resultItem.m_GlyphRarity, resultItem.m_GlyphRank + 1);
				levelXP = resultItem.m_GlyphXP - xpToCurrentLevel;
				XPToLevel = xpToNextLevel - xpToCurrentLevel;
				
				trace("GLYPH RANK: " + resultItem.m_GlyphRank);
				trace("GLYPH XP TO CURRENT LEVEL: " + xpToCurrentLevel);
				trace("GLYPH XP TO NEXT LEVEL: " + xpToNextLevel);
				trace("GLYPH XP GAINED THIS LEVEL: " + levelXP);
				trace("GLYPH XP NEEDED TO LEVEL: " + XPToLevel);
				
				currentPercent = xpToNextLevel > 0 ? (levelXP / XPToLevel) * 100 : 100;
				m_GlyphUpgradeProgress.m_UpgradeXP._xscale = Math.max(0, Math.min(currentPercent, 100));
				
				xpDiff = resultItem.m_GlyphXP - targetItem.m_GlyphXP;
				m_GlyphUpgradeProgress.m_Text.text = xpDiff > 0 ? "+ " + xpDiff + " " + LDBFormat.LDBGetText("Crafting", "XP") : "";
			}
			else
			{
				trace(" ");
				trace("__________RESULT HAS NO GLYPH__________");
			}
			
			//Signet
			if (resultItem.m_ACGItem.m_TemplateID2 != 0 && resultItem.m_ItemType != _global.Enums.ItemType.e_ItemType_Weapon)
			{
				trace(" ");
				trace("__________RESULT SIGNET__________");
				if (resultItem.m_SignetRank != targetItem.m_SignetRank)
				{
					trace("SIGNET LEVELED UP!");
					//Level upgrade display
					m_SignetLevelUpgrade.m_Arrow._visible = true;
					m_SignetLevelUpgrade.m_UpgradeLevel._visible = true;
					m_SignetLevelUpgrade.m_UpgradeLevel.text = LDBFormat.LDBGetText("Crafting", "QL") + " " + resultItem.m_SignetRank;
					m_SignetLevelUpgrade.m_ItemTypeText.text = LDBFormat.LDBGetText("ItemTypeGUI", "Signet");
					if (targetItem.m_SignetRarity != resultItem.m_SignetRarity)
					{
						m_SignetLevelUpgrade.m_UpgradeLevel.textColor = Colors.GetItemRarityColor(resultItem.m_SignetRarity);
					}
					else
					{
						m_SignetLevelUpgrade.m_UpgradeLevel.textColor = 0x6BB9FF;
					}
					m_SignetLevelUpgrade.m_Arrow._x = m_SignetLevelUpgrade.m_CurrentLevel.textWidth + 10;
					m_SignetLevelUpgrade.m_UpgradeLevel._x = m_SignetLevelUpgrade.m_Arrow._x + m_SignetLevelUpgrade.m_Arrow._width;
					m_SignetLevelUpgrade.m_ItemTypeText._x = m_SignetLevelUpgrade.m_UpgradeLevel._x + m_SignetLevelUpgrade.m_UpgradeLevel.textWidth + 5;
					
					//There wasn't a signet previously, we are adding one
					if (targetItem.m_ACGItem.m_TemplateID2 == 0)
					{
						trace("THIS IS A NEW SIGNET!");
						m_SignetUpgradeProgress._alpha = 100;
						m_SignetLevelUpgrade._alpha = 100;
						m_SignetLevelUpgrade.m_Arrow._visible = false;
						m_SignetLevelUpgrade.m_UpgradeLevel._x = 0;
						m_SignetLevelUpgrade.m_ItemTypeText._x = m_SignetLevelUpgrade.m_UpgradeLevel._x + m_SignetLevelUpgrade.m_UpgradeLevel.textWidth + 5;
					}
					
					//Override XP bar
					//We are on a new level, the XP on the target item doesn't count
					m_SignetUpgradeProgress.m_CurrentXP._xscale = 0;
				}
				
				xpToCurrentLevel = Inventory.GetItemXPForLevel(_global.Enums.ItemType.e_Type_GC_Item_Generated_Suffix_NonWeapon, resultItem.m_SignetRarity, resultItem.m_SignetRank);
				xpToNextLevel = Inventory.GetItemXPForLevel(_global.Enums.ItemType.e_Type_GC_Item_Generated_Suffix_NonWeapon, resultItem.m_SignetRarity, resultItem.m_SignetRank + 1);
				levelXP = resultItem.m_SignetXP - xpToCurrentLevel;
				XPToLevel = xpToNextLevel - xpToCurrentLevel;
				
				trace("SIGNET RANK: " + resultItem.m_SignetRank);
				trace("SIGNET XP TO CURRENT LEVEL: " + xpToCurrentLevel);
				trace("SIGNET XP TO NEXT LEVEL: " + xpToNextLevel);
				trace("SIGNET XP GAINED THIS LEVEL: " + levelXP);
				trace("SIGNET XP NEEDED TO LEVEL: " + XPToLevel);
				
				currentPercent = xpToNextLevel > 0 ? (levelXP / XPToLevel) * 100 : 100;
				m_SignetUpgradeProgress.m_UpgradeXP._xscale = Math.max(0, Math.min(currentPercent, 100));
				
				xpDiff = resultItem.m_SignetXP - targetItem.m_SignetXP;
				m_SignetUpgradeProgress.m_Text.text = xpDiff > 0 ? "+ " + xpDiff + " " + LDBFormat.LDBGetText("Crafting", "XP") : "";
			}
			else
			{
				trace(" ");
				trace("__________RESULT HAS NO SIGNET__________");
			}
			
			//Stat Comparison
			if (m_CurrentTab == EMPOWERMENT_TAB)
			{
				//Make sure the ACGItem is not undefined, or you will crash and it will hurt the whole time you are crashing.
				var showStats:Boolean = false;
				if (resultItem.m_ACGItem != undefined)
				{
					var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltipCompareACGItem(m_Inventory.m_InventoryID, TARGET_SLOT, resultItem.m_ACGItem);
					//If signet is upgraded, show signet description
					trace(" ");
					trace("____________SHOW STAT CHANGES____________");
					if (resultItem.m_SignetRank != targetItem.m_SignetRank && tooltipData.m_SuffixData != undefined)
					{
						trace("SHOWING SIGNET BECAUSE SIGNET RANK HAS CHANGED");
						trace("RESULT SIGNET RANK: " + resultItem.m_SignetRank);
						trace("TARGET SIGNET RANK: " + targetItem.m_SignetRank);
						m_EmpowermentTab.m_CompareSlot_0.htmlText = "";
						m_EmpowermentTab.m_CompareSlot_1.htmlText = "";
						m_EmpowermentTab.m_CompareSlot_2.htmlText = "";
						m_EmpowermentTab.m_CompareSlot_Signet.htmlText = tooltipData.m_SuffixData.m_Descriptions[0];
						showStats = true;
					}
					//Otherwise show stat comparison
					else
					{
						trace("SHOWING STATS BECAUSE SIGENT RANK HAS NOT CHANGED");
						m_EmpowermentTab.m_CompareSlot_0.htmlText = "";
						m_EmpowermentTab.m_CompareSlot_1.htmlText = "";
						m_EmpowermentTab.m_CompareSlot_2.htmlText = "";
						m_EmpowermentTab.m_CompareSlot_Signet.htmlText = "";
						var compareSlot:Number = 0;
						for (var i:Number = 0; i < tooltipData.m_CompareAttributes.length; i++)
						{
							if (tooltipData.m_CompareAttributes[i] != "<hr>")
							{
								trace("STAT CHANGE: " + tooltipData.m_CompareAttributes[i]);
								m_EmpowermentTab["m_CompareSlot_" + compareSlot].htmlText = tooltipData.m_CompareAttributes[i];
								showStats = true;
								compareSlot++;
							}
						}
					}
				}
				if (showStats)
				{
					m_StatChangeIcon._visible = false;
				}
				else 
				{
					m_StatChangeIcon._visible = true;
				}
			}
			else if (m_CurrentTab == FUSION_TAB)
			{
				m_StatChangeIcon._visible = false;
				m_FusionTab.m_ResultSlot._visible = true;
				m_FusionTab.m_ResultBG._visible = true;
			}
		}
		else
		{
			trace(" ");
			trace("__________ NO RESULT__________");
			m_EmpowermentTab.m_CompareSlot_0.htmlText = "";
			m_EmpowermentTab.m_CompareSlot_1.htmlText = "";
			m_EmpowermentTab.m_CompareSlot_2.htmlText = "";
			m_EmpowermentTab.m_CompareSlot_Signet.htmlText = "";
			m_FusionTab.m_ResultSlot._visible = false;
			m_FusionTab.m_ResultBG._visible = false;
			m_StatChangeIcon._visible = true;
		}
	}
	
	private function ClearStatsDisplay()
	{
		this._parent.SetTitle(LDBFormat.LDBGetText("MiscGUI", "ItemUpgradeTitle"))
		m_StatsHeader._visible = false;
		m_LevelUpgrade._visible = false;
		m_GlyphLevelUpgrade._visible = false;
		m_SignetLevelUpgrade._visible = false;
		m_UpgradeProgress._visible = false;
		m_GlyphUpgradeProgress._visible = false;
		m_SignetUpgradeProgress._visible = false;
		
		m_EmpowermentTab.m_CompareSlot_0.htmlText = "";
		m_EmpowermentTab.m_CompareSlot_1.htmlText = "";
		m_EmpowermentTab.m_CompareSlot_2.htmlText = "";
		m_EmpowermentTab.m_CompareSlot_Signet.htmlText = "";
		m_FusionTab.m_ResultSlot._visible = false;
		m_FusionTab.m_ResultBG._visible = false;
		m_StatChangeIcon._visible = true;
	}
	
	public function SlotStartEmpowerment()
	{
		if (ConfirmEmpowerment())
		{
			CraftingInterface.StartEmpowerment(m_Inventory.m_InventoryID.GetType());
		}
	}
	
	public function ConfirmEmpowerment():Boolean
	{
		var errorMessage:String = "";
		var empowerItems = new Array();
		for (var i:Number = EMPOWER_SLOT_0; i<= EMPOWER_SLOT_4; i++)
		{
			if (m_ItemSlots[i].m_ItemSlot.m_ItemData != undefined)
			{
				empowerItems.push(m_ItemSlots[i].m_ItemSlot.m_ItemData);
			}
		}
		
		for (var i:Number = 0; i < empowerItems.length; i++)
		{
			var item:InventoryItem = empowerItems[i];
			if (item.m_XP > 1 && item.m_ItemType != _global.Enums.ItemType.e_ItemType_CraftingItem)
			{
				errorMessage = LDBFormat.LDBGetText("Crafting", "EmpowerError_HasXP");
			}
			else if (item.m_Rarity > _global.Enums.ItemPowerLevel.e_Enchanted && item.m_ItemType != _global.Enums.ItemType.e_ItemType_CraftingItem)
			{
				errorMessage = LDBFormat.LDBGetText("Crafting", "EmpowerError_HasRank");
			}
			else if (item.m_HasRemovablePrefix)
			{
				errorMessage = LDBFormat.LDBGetText("Crafting", "EmpowerError_HasGlyph");
			}
			else if (item.m_HasRemovableSuffix)
			{
				errorMessage = LDBFormat.LDBGetText("Crafting", "EmpowerError_HasSignet");
			}
		}
		
		if (errorMessage != "")
		{
			var dialogIF = new com.GameInterface.DialogIF( errorMessage, _global.Enums.StandardButtons.e_ButtonsYesNo, "EmpowerWarning" );
			dialogIF.SignalSelectedAS.Connect( SlotEmpowerConfirmed, this );
			dialogIF.Go( );
			return false;
		}		
		return true;
	}
	
	private function SlotEmpowerConfirmed(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			CraftingInterface.StartEmpowerment(m_Inventory.m_InventoryID.GetType());
		}
	}
	
	//TODO: NOT USED. THESE ANIMATIONS ARE CAUSING CRASHES
	private function AttachBreakAnim(targetClip:MovieClip)
	{
		var breakAnim:MovieClip = targetClip.attachMovie("EmpowerBreakAnim", "m_BreakAnim", targetClip.getNextHighestDepth());
		breakAnim._x = 30;
		breakAnim._y = 15;
		breakAnim._xscale = breakAnim._yscale = 130;
	}
	
	//TODO: NOT USED. THESE ANIMATIONS ARE CAUSING CRASHES
	private function AttachEmpoweredAnim(targetClip:MovieClip)
	{
		var empowerAnim:MovieClip = targetClip.attachMovie("TargetEmpoweredAnim", "m_EmpowerAnim", targetClip.getNextHighestDepth());
		empowerAnim._x = -2;
		empowerAnim._y = -2;
		empowerAnim._xscale = empowerAnim._yscale = 35;
	}
	
	public function SlotStartFusion()
	{
		if (ConfirmFusion())
		{
			CraftingInterface.StartFusion(m_Inventory.m_InventoryID.GetType());
		}
	}
	
	public function ConfirmFusion():Boolean
	{
		/* Don't do this right now
		var errorMessage:String = "";
		var targetItem:InventoryItem = m_ItemSlots[TARGET_SLOT].m_ItemSlot.m_ItemData;
		var fusionItem:InventoryItem = m_ItemSlots[FUSION_SLOT].m_ItemSlot.m_ItemData;
		if (targetItem.m_Pips < fusionItem.m_Pips)
		{
			errorMessage = LDBFormat.LDBGetText("Crafting", "FuseError_3Pips");
		}
		if (errorMessage != "")
		{
			var dialogIF = new com.GameInterface.DialogIF( errorMessage, _global.Enums.StandardButtons.e_ButtonsYesNo, "FuseWarning" );
			dialogIF.SignalSelectedAS.Connect( SlotFusionConfirmed, this );
			dialogIF.Go( );
			return false;
		}
		*/
		return true;
	}
	
	public function SlotFusionConfirmed(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			CraftingInterface.StartFusion(m_Inventory.m_InventoryID.GetType());
		}
	}
	
	public function SlotDestroyGlyph()
	{
		CraftingInterface.DestroyGlyph(m_Inventory.m_InventoryID.GetType());
	}
	
	public function SlotRecoverGlyph()
	{
		CraftingInterface.RecoverGlyph(m_Inventory.m_InventoryID.GetType());
	}
	
	public function SlotDestroySignet()
	{
		CraftingInterface.DestroySignet(m_Inventory.m_InventoryID.GetType());
	}
	
	public function SlotRecoverSignet()
	{
		CraftingInterface.RecoverSignet(m_Inventory.m_InventoryID.GetType());
	}
	
	public function SlotReceiveItem(srcInventory:ID32, srcSlot:Number)
	{
		//Make sure we're set up to receive items
		if (m_Inventory != undefined)
		{
			var firstFree:Number = m_Inventory.GetFirstFreeItemSlot();
			if (m_CurrentTab == EMPOWERMENT_TAB)
			{
				if ((!Lore.IsLocked(FUSION_UNLOCK_TAG) && Lore.IsLocked(FUSION_TUTORIAL_COMPLETE_TAG)) ||
					(!Lore.IsLocked(GLYPH_UNLOCK_TAG) && Lore.IsLocked(GLYPH_TUTORIAL_COMPLETE_TAG)))
				{
					//Don't let players move anything into empowerment while fusion tutorial is active
					return;
				}
				while(firstFree == FUSION_SLOT || firstFree == RESULT_SLOT || m_Inventory.GetItemAt(firstFree) != undefined)
				{
					firstFree ++;
					if (firstFree > EMPOWER_SLOT_4)
					{
						return;
					}
				}
			}
			else if (m_CurrentTab == FUSION_TAB)
			{
				if (firstFree >= RESULT_SLOT)
				{
					return;
				}
			}
			m_Inventory.AddItem(srcInventory, srcSlot, firstFree);
			if (srcInventory.GetType() == _global.Enums.InvType.e_Type_GC_WeaponContainer)
			{
				m_FromEquipped[firstFree] = true;
			}
			else
			{
				m_FromEquipped[firstFree] = false;
			}
		}
	}
	
	function SlotItemAdded( inventoryID:com.Utils.ID32, itemPos:Number )
	{
		m_ItemSlots[itemPos].m_ItemSlot.SetData(m_Inventory.GetItemAt(itemPos));
		m_ItemSlots[itemPos].m_IsPreview = false;
		m_ItemSlots[itemPos].m_ItemSlot.SetCanDrag(true);
		
		switch(itemPos)
		{
			case TARGET_SLOT:		var item:InventoryItem = m_Inventory.GetItemAt(itemPos);
									m_DestroyGlyphButton._visible = item.m_HasRemovablePrefix;
									m_RecoverGlyphButton._visible = item.m_HasRemovablePrefix;
									m_DestroySignetButton._visible = item.m_HasRemovableSuffix;
									m_RecoverSignetButton._visible = item.m_HasRemovableSuffix;
									m_GlyphHeader._visible = item.m_HasRemovablePrefix;
									m_GlyphHeaderBG._visible = item.m_HasRemovablePrefix;
									m_SignetHeader._visible = item.m_HasRemovableSuffix;
									m_SignetHeaderBG._visible = item.m_HasRemovableSuffix;
									UpdateStatsDisplay()
									break;
			
			case FUSION_SLOT:   	//m_FusionTab.m_FusionBG.gotoAndPlay("itemplaced");
									m_FusionTab.m_FusionEmptyText._visible = false;
									break;
			
			case RESULT_SLOT:	   	//m_FusionTab.m_ResultBG.gotoAndPlay("itemplaced");
									var item:InventoryItem = m_Inventory.GetItemAt(itemPos);
									m_FusionTab.m_ResultName.text = item.m_Name;
									break;
									
			case EMPOWER_SLOT_0:
			case EMPOWER_SLOT_1:
			case EMPOWER_SLOT_2:
			case EMPOWER_SLOT_3:
			case EMPOWER_SLOT_4:	var bgIndex:Number = itemPos - EMPOWER_SLOT_0;
									//m_EmpowermentTab["m_BG_" + bgIndex].gotoAndPlay("itemplaced");
									break;
		}
		//Bring this window to the top whenever anything is added to it.
		GUIFramework.SFClipLoader.MoveToFront(GUIFramework.SFClipLoader.GetClipIndex(this._parent._parent));
	}
	
	function SlotItemMoved( inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number )
	{
		
	}

	function SlotItemRemoved( inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
	{
		m_ItemSlots[itemPos].m_ItemSlot.Clear();
		
		switch(itemPos)
		{
			case TARGET_SLOT: 		m_DestroyGlyphButton._visible = false;
									m_RecoverGlyphButton._visible = false;
									m_DestroySignetButton._visible = false;
									m_RecoverSignetButton._visible = false;
									m_GlyphHeader._visible = false;
									m_GlyphHeaderBG._visible = false;
									m_SignetHeader._visible = false;
									m_SignetHeaderBG._visible = false;
									ClearStatsDisplay();
									break;
			
			case FUSION_SLOT:   	//m_FusionTab.m_FusionBG.gotoAndPlay("static");
									m_FusionTab.m_FusionEmptyText._visible = m_CurrentTab == FUSION_TAB;
									break;
			
			case RESULT_SLOT:	   	m_FusionTab.m_ResultBG.gotoAndPlay("static");
									m_FusionTab.m_ResultName.text = "";
									break;
									
			case EMPOWER_SLOT_0:
			case EMPOWER_SLOT_1:
			case EMPOWER_SLOT_2:
			case EMPOWER_SLOT_3:
			case EMPOWER_SLOT_4:	var bgIndex:Number = itemPos - EMPOWER_SLOT_0;
									//m_EmpowermentTab["m_BG_" + bgIndex].gotoAndPlay("static");
									break;
		}
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
	
	function SlotTagAdded(tagId:Number, characterId:ID32)
	{
		if (tagId == FUSION_UNLOCK_TAG)
		{
			m_FusionTab.m_LockIcon._visible = false;
			m_FusionTab.m_HitArea.onRollOver = m_FusionTab.m_HitArea.onDragOver = function(){this._alpha = 10;}
			m_FusionTab.m_HitArea.onRollOut = m_FusionTab.m_HitArea.onDragOut = function(){this._alpha = 0;}
			m_FusionTab._alpha = 75;
			
			if (Lore.IsLocked(FUSION_TUTORIAL_COMPLETE_TAG))
			{
				m_TutorialBlocker = this.attachMovie("FusionTutorialBlocker", "m_TutorialBlocker", this.getNextHighestDepth());
				m_TutorialBlocker.m_FuseItems.onRelease = function(){};
				m_TutorialBlocker.m_FuseItems._visible = false;
				
				m_TutorialBlocker.m_SelectFusion.m_FusionTutorialStep1.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep1");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep2.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep2");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep3.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep3");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep4.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep4");
				m_StatsHeader.swapDepths(this.getNextHighestDepth());
				m_LevelUpgrade.swapDepths(this.getNextHighestDepth());
				m_UpgradeProgress.swapDepths(this.getNextHighestDepth());
			}
		}
		
		if (tagId == GLYPH_UNLOCK_TAG)
		{
			if (Lore.IsLocked(GLYPH_TUTORIAL_COMPLETE_TAG))
			{
				SwitchToEmpowerment();
				m_TutorialBlocker = this.attachMovie("FusionTutorialBlocker", "m_TutorialBlocker", this.getNextHighestDepth());
				m_TutorialBlocker.m_FuseItems.onRelease = function(){};
				m_TutorialBlocker.m_FuseItems._visible = false;
				
				m_TutorialBlocker.m_SelectFusion.m_FusionTutorialStep1.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep1");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep2.htmlText = LDBFormat.LDBGetText("Crafting", "GlyphTutorialStep2");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep3.htmlText = LDBFormat.LDBGetText("Crafting", "GlyphTutorialStep3");
				m_TutorialBlocker.m_FuseItems.m_FusionTutorialStep4.htmlText = LDBFormat.LDBGetText("Crafting", "FusionTutorialStep4");
				m_StatsHeader.swapDepths(this.getNextHighestDepth());
				m_LevelUpgrade.swapDepths(this.getNextHighestDepth());
				m_UpgradeProgress.swapDepths(this.getNextHighestDepth());
			}
		}
		
		if (tagId == TUTORIAL_COMPLETE_TAG || tagId == FUSION_TUTORIAL_COMPLETE_TAG || tagId == GLYPH_TUTORIAL_COMPLETE_TAG)
		{
			if (m_TutorialBlocker != undefined)
			{
				m_TutorialBlocker.removeMovieClip();
				m_TutorialBlocker = undefined;
			}
		}
	}
	
	function SlotTokenChanged(tokenID:Number, newAmount:Number, oldAmount:Number)
	{
		if ((tokenID == _global.Enums.Token.e_Cash || tokenID == _global.Enums.Token.e_Gold_Bullion_Token) && m_CurrentCost != undefined)
		{
			UpdateAssembleButton();
		}
	}
	
	function onDragEnd( event:Object ) : Void
	{
		if ( Mouse["IsMouseOver"](this) )
		{
			var succeded:Boolean = false;
			if ( event.data.type == "item")
			{
				var dstID = GetMouseSlotID();
				if ( dstID >= 0 && dstID != RESULT_SLOT )
				{
					if (event.data.split)
					{
						m_Inventory.SplitItem(event.data.inventory_id, event.data.inventory_slot, dstID, event.data.stack_size);
					}
					else
					{
						m_Inventory.AddItem(event.data.inventory_id, event.data.inventory_slot, dstID);
					}
					if (event.data.inventory_id.GetType() == _global.Enums.InvType.e_Type_GC_WeaponContainer)
					{
						m_FromEquipped[dstID] = true;
					}
					else
					{
						m_FromEquipped[dstID] = false;
					}
			   
					succeded = true;
				}
			}
			event.data.DragHandled();
			m_Character.AddEffectPackage((succeded) ? "sound_fxpackage_GUI_item_slot.xml" : "sound_fxpackage_GUI_item_slot_fail.xml");
		}
	}
	
	function GetMouseSlotID() : Number
	{
		for ( var i in m_ItemSlots )
		{
			var mc:MovieClip = m_ItemSlots[i].m_ItemSlot.GetSlotMC().i_Background;
			if (mc._parent._visible && mc._xmouse >= -m_SlotPadding && mc._xmouse <= mc._width + m_SlotPadding && mc._ymouse >= -m_SlotPadding && mc._ymouse <= mc._height + m_SlotPadding)
			{
				return m_ItemSlots[i].m_ItemSlot.GetSlotID();
			}
		}
		return -1;
	}
	
	function SlotMouseUpEmptySlot(itemSlot:ItemSlot, buttonIdx:Number)
	{
		//If you release right button with a drag item, deposit one
		if (buttonIdx == 2)
		{
			var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
			if (currentDragObject != undefined && currentDragObject.type == "item")
			{
				if (currentDragObject.stack_size > 1)
				{
					if (m_Inventory.SplitItem( currentDragObject.inventory_id, currentDragObject.inventory_slot, itemSlot.GetSlotID(), 1 ))
					{
						currentDragObject.stack_size = currentDragObject.stack_size - 1;
						currentDragObject.GetDragClip().SetStackSize(currentDragObject.stack_size);            
					}
				}
				else
				{
					gfx.managers.DragManager.instance.stopDrag();
				}
			}
		}
	}
	
	function SlotMouseUpItem(itemSlot:ItemSlot, buttonIndex:Number)
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
		if (buttonIndex == 2)
		{
			if (currentDragObject != undefined && currentDragObject.type == "item")
			{
				if (currentDragObject.stack_size > 1)
				{
					if (m_Inventory.SplitItem( currentDragObject.inventory_id, currentDragObject.inventory_slot, itemSlot.GetSlotID(), 1))
					{
						currentDragObject.stack_size = currentDragObject.stack_size - 1;
						currentDragObject.GetDragClip().SetStackSize(currentDragObject.stack_size);   
					}
				}
				else
				{
					gfx.managers.DragManager.instance.stopDrag();
				}
			}
			//If the character sheet is open and this is the target, try to equip this
			else if (GUIModuleIF.FindModuleIF("CharacterSheet").IsActive() && m_FromEquipped[itemSlot.GetSlotID()])
			{
				m_Inventory.UseItem(itemSlot.GetSlotID());
				return;
			}
			//Otherwise drop it in the inventory
			else
			{
				var clientCharID:ID32 = Character.GetClientCharID();
				var backpack:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, clientCharID.GetInstance()));
				backpack.AddItem(m_Inventory.m_InventoryID, itemSlot.GetSlotID(), backpack.GetFirstFreeItemSlot());
			}
		}
	}
	
	function SlotStartDragItem(itemSlot:ItemSlot, stackSize:Number)
	{
		var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSize);
		dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
		dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
	}

	function SlotDragHandled()
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
		
		var slot:ItemSlot = m_ItemSlots[currentDragObject.inventory_slot].m_ItemSlot;
		
		if (slot != undefined && slot.HasItem() )
		{
			slot.SetAlpha(100);
		}
	}

	function SlotItemDroppedOnDesktop()
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();

		if (currentDragObject.type == "item")
		{
			SlotDeleteItem(m_ItemSlots[currentDragObject.inventory_slot].m_ItemSlot);
		}
	}
	
	function SlotDeleteItem()
	{
		//This is disabled due to a bug. 
	}
	
	function BuyEmpowerBoosters()
	{
		//Spot reserved for any empower boosters
		//ShopInterface.SignalOpenInstantBuy.Emit([9302408, 9302406, 9302407, 9280143, 9280144, 9280145, 9280146]);
	}
	
	function BuyFusionBoosters()
	{
		ShopInterface.SignalOpenInstantBuy.Emit([9302408, 9302406, 9302407, 9280143, 9280144, 9280145, 9280146]);
	}
	
	private function RemoveFocus()
	{
		Selection.setFocus(null);
	}
	
	private function onUnload()
	{
		var clientCharID:ID32 = Character.GetClientCharID();
		var backpack:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, clientCharID.GetInstance()));
		for (var i:Number = 0; i < m_ItemSlots.length; i++)
		{
			if (m_FromEquipped[m_ItemSlots[i].m_ItemSlot.GetSlotID()])
			{
				m_Inventory.UseItem(m_ItemSlots[i].m_ItemSlot.GetSlotID());
			}
			else
			{
				backpack.AddItem(m_Inventory.m_InventoryID, m_ItemSlots[i].m_ItemSlot.GetSlotID(), backpack.GetFirstFreeItemSlot());
			}
		}
		gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "onDragEnd" );
		if (m_ForcedInventory)
		{
			DistributedValue.SetDValue("inventory_visible", false);
		}
	}
}