import com.Components.WindowComponentContent;
import GUI.SkillHive.SkillhiveEquipPopup;
import com.Utils.LDBFormat;
import com.Utils.Archive;
import com.Utils.Colors;
import com.Utils.Text;
import com.GameInterface.CharacterCreation.CharacterCreation;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.Utils;
import com.GameInterface.Spell;
import com.GameInterface.ProjectSpell;
import com.GameInterface.SpellData;
import com.GameInterface.ShopInterface;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.SkillWheel.SkillWheel;
import com.GameInterface.SkillWheel.SkillTemplate;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Lore;
import com.GameInterface.LoreBase;
import com.GameInterface.DistributedValue;
import gfx.controls.Button;
import gfx.controls.ButtonGroup;
import mx.utils.Delegate;

class GUI.SkillHiveSimple.AbilityPageBase extends WindowComponentContent
{
	//Components created in .fla
	private var m_Header:MovieClip;
	private var m_Footer:MovieClip;
	private var m_TutorialBlocker:MovieClip;
	private var m_HelpButton:Button;
	private var m_VideoButton:Button;
	private var m_DetailButton:Button;
	private var m_DetailNoSelected:TextField;
	private var m_UnlockButton:Button;
	private var m_AurumUnlockButton:MovieClip;
	private var m_UnlockBG:MovieClip;
	
	//Variables
	private var m_Character:Character;
	private var m_TabGroup:ButtonGroup;
	private var m_TabArray:Array;
	private var m_ActiveDialog:MovieClip;
	private var m_CurrentEquipPopupHolder:MovieClip;
	private var m_CurrentEquipPopupMenu:MovieClip;
	private var m_PurchaseBlocker:MovieClip;
	private var m_HelpDisplay:MovieClip;
	private var m_SelectedFeat:FeatData;
	private var m_CurrentCluster:Number;
	private var m_CurrentClusterOffset:Number;
	private var m_SetupHelpInterval:Number;
	private var m_LanguageMonitor:DistributedValue;
	private var m_FocusedFeat:FeatData;
	private var m_TDB_ConfirmUnlockPage:String;
	
	//Statics
	private static var BLADE_DATA:Object = {m_Id:0, m_Cluster:4200, m_Icon:"BladesIcon", m_LeftColor:0xDD8A2B, m_RightColor:0xE29B4B};
	private static var HAMMER_DATA:Object = {m_Id:1, m_Cluster:4700, m_Icon:"HammersIcon", m_LeftColor:0xDD8A2B, m_RightColor:0xE29B4B};
	private static var FIST_DATA:Object = {m_Id:2, m_Cluster:4600, m_Icon:"FistsIcon", m_LeftColor:0xDD8A2B, m_RightColor:0xE29B4B};
	private static var BLOOD_DATA:Object = {m_Id:3, m_Cluster:4300, m_Icon:"BloodIcon", m_LeftColor:0x31AFFF, m_RightColor:0x50BBFF};
	private static var CHAOS_DATA:Object = {m_Id:4, m_Cluster:4400, m_Icon:"ChaosIcon", m_LeftColor:0x31AFFF, m_RightColor:0x50BBFF};
	private static var ELEMENTAL_DATA:Object = {m_Id:5, m_Cluster:4500, m_Icon:"ElementalsIcon", m_LeftColor:0x31AFFF, m_RightColor:0x50BBFF};
	private static var SHOTGUN_DATA:Object = {m_Id:6, m_Cluster:4900, m_Icon:"ShotgunsIcon", m_LeftColor:0xFF5A5A, m_RightColor:0xFF7373};
	private static var PISTOL_DATA:Object = {m_Id:7, m_Cluster:4800, m_Icon:"PistolsIcon", m_LeftColor:0xFF5A5A, m_RightColor:0xFF7373};
	private static var RIFLE_DATA:Object = {m_Id:8, m_Cluster:4100, m_Icon:"AssaultRiflesIcon", m_LeftColor:0xFF5A5A, m_RightColor:0xFF7373};
	
	private static var LAUNCHER_DATA:Object = {m_Id:0, m_Cluster:2101, m_Icon:"RocketLauncherIcon", m_LeftColor:0x1A6673, m_RightColor:0x7EECED};
	private static var CHAINSAW_DATA:Object = {m_Id:1, m_Cluster:2301, m_Icon:"ChainSawIcon", m_LeftColor:0x1A6673, m_RightColor:0x7EECED};
	private static var QUANTUM_DATA:Object = {m_Id:2, m_Cluster:2201, m_Icon:"QuantumIcon", m_LeftColor:0x1A6673, m_RightColor:0x7EECED};
	private static var WHIP_DATA:Object = {m_Id:3, m_Cluster:2311, m_Icon:"WhipIcon", m_LeftColor:0x1A6673, m_RightColor:0x7EECED};
	private static var FLAMETHROWER_DATA:Object = {m_Id:4, m_Cluster:2111, m_Icon:"FlameThrowerIcon", m_LeftColor:0x1A6673, m_RightColor:0x7EECED};
	
	private static var AUX_ACTIVE_SLOT:Number = 6;
	
	private static var TUTORIAL_COMPLETE_TAG:Number = 9448;
	private static var PASSIVES_UNLOCKED_TAG:Number = 9569;
	private static var PASSIVES_TUTORIAL_COMPLETE_TAG:Number = 9570;
	
	private static var ACTIVE_CLUSTER_OFFSET = 11;
	private static var PASSIVE_CLUSTER_OFFSET = 21;	
	
	public function AbilityPageBase()
	{
		super();
	}
	
	private function configUI():Void
	{
		super.configUI();		
		UnlockVisible(false);
		m_UnlockButton["m_Price"].m_T202._visible = false;
		m_UnlockButton["m_Price"].textField.autoSize = "left";
		m_AurumUnlockButton.m_Price.m_T201._visible = false;
		m_AurumUnlockButton["m_Price"].textField.autoSize = "left";
		m_TabGroup = new ButtonGroup();
		m_TabArray = new Array();
		m_PurchaseBlocker._visible = false;
		m_TutorialBlocker.onRelease = function(){}; //To block mouse events
		
		m_LanguageMonitor = DistributedValue.Create("Language");
   		m_LanguageMonitor.SignalChanged.Connect(SlotSetLanguage, this);
		
		m_HelpButton.addEventListener("click", this, "OnClickHelp");
		m_HelpButton.disableFocus = true;
		m_VideoButton.addEventListener("click", this, "OnClickVideo");
		m_VideoButton.disableFocus = true;
		
		HideDetails(true);
		m_DetailButton.addEventListener("click", this, "SlotDetailButtonClicked");
		m_DetailNoSelected.text = LDBFormat.LDBGetText( "SkillhiveGUI", "NoAbilitySelected");
		
		m_Footer.m_BuyPointsButton.onMouseRelease = Delegate.create(this, BuyPoints);
	}
	
	private function SetupTabs():Void
	{
		for (var i:Number = 0; i < m_TabArray.length; i++)
		{
			var tab:MovieClip = m_TabArray[i];
			tab.group = m_TabGroup;
			var tabIcon:MovieClip = tab.m_Content.attachMovie( tab.data.m_Icon, "m_Icon", tab.m_Content.getNextHighestDepth() );
			tabIcon._width = tabIcon._height = 35;
		}
		
		m_TabGroup.addEventListener("change",this,"TabChanged");
		for (var i:Number = 0; i < m_TabArray.length; i++)
		{
			if (m_TabArray[i].data.m_Cluster == m_CurrentCluster)
			{
				m_TabGroup.setSelectedButton(m_TabArray[i]);
			}
		}
		if (m_TabGroup.selectedButton == undefined)
		{
			var tabSet:Boolean = false;
			if (Lore.IsLocked(TUTORIAL_COMPLETE_TAG))
			{
				for (var i:Number = 0; i < m_TabArray.length; i++)
				{
					if (m_TabArray[i].data.m_Icon == TooltipUtils.GetWeaponRequirementIconName(GetClassWeapon(0)))
					{
						m_TabGroup.setSelectedButton(m_TabArray[i]);
						return;
					}
				}
			}
			
			//Fallback for if none of the available tabs are the class weapon or selected tab
			m_TabGroup.setSelectedButton(m_TabArray[0]);
		}
	}
	
	private function TabChanged(button:Button):Void
	{
		var buttonData:Object = button.data;
		m_CurrentCluster = buttonData.m_Cluster;
		m_SelectedFeat = undefined;
		FocusAbility(undefined);
		RemoveHelp();
		UpdatePurchaseBlocker(buttonData.m_Cluster);
		UpdateHeader(buttonData);
		UpdateCells(buttonData.m_Cluster);
		UpdateFooter();
		UpdateTutorialBlocker();
		Selection.setFocus(null);
	}
	
	private function UpdateTutorialBlocker()
	{
		if (m_TutorialBlocker._visible)
		{
			var isPassiveTutorial:Boolean = Lore.IsLocked(PASSIVES_TUTORIAL_COMPLETE_TAG) && !Lore.IsLocked(PASSIVES_UNLOCKED_TAG);
			if (!Lore.IsLocked(TUTORIAL_COMPLETE_TAG) && (!Lore.IsLocked(PASSIVES_TUTORIAL_COMPLETE_TAG) || Lore.IsLocked(PASSIVES_UNLOCKED_TAG)))
			{
				m_TutorialBlocker._visible = false;
				
				for (var i:Number = 0; i < m_TabArray.length; i++)
				{
					m_TabArray[i].disabled = false;
					m_TabArray[i]._alpha = 100;
				}
			}
			else
			{
				var desiredWeaponIndex:Number = isPassiveTutorial ? 1 : 0;
				for (var i:Number = 0; i < m_TabArray.length; i++)
				{
					if (m_TabArray[i].data.m_Icon != TooltipUtils.GetWeaponRequirementIconName(GetClassWeapon(0)) && 
						m_TabArray[i].data.m_Icon != TooltipUtils.GetWeaponRequirementIconName(GetClassWeapon(1)))
					{
						m_TabArray[i].disabled = true;
						m_TabArray[i]._alpha = 20;
					}
					else if (m_TabArray[i].data.m_Icon != TooltipUtils.GetWeaponRequirementIconName(GetClassWeapon(desiredWeaponIndex)))
					{
						m_TutorialBlocker.m_WeaponSelectText._y = m_TabArray[i]._y - 20;
						m_TutorialBlocker.m_WeaponSelectArrow._y = m_TutorialBlocker.m_WeaponSelectText._y + m_TutorialBlocker.m_WeaponSelectText._height/2 - m_TutorialBlocker.m_WeaponSelectArrow._height/2 - 15;
					}
				}
				m_TutorialBlocker.m_WeaponSelectText._visible = m_TutorialBlocker.m_WeaponSelectArrow._visible = false;
				m_TutorialBlocker.m_AbilityBuyText._visible = m_TutorialBlocker.m_AbilityBuyArrow._visible = false;
				m_TutorialBlocker.m_AbilitySelectText._visible = m_TutorialBlocker.m_AbilitySelectArrow._visible = false;
				FocusAbility(undefined);
			}
		}
	}
	
	private function GetClassWeapon(weaponSlot:Number):Number
	{
		var playerClass:Number = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_CharacterClass, 2);
		var classList:Array = CharacterCreation.GetStartingClassData();
		var deckId:Number = 0;
		var templates:Array = SkillWheel.m_FactionSkillTemplates["1"];
		
		for (var i:Number = 0; i < classList.length; i++)
		{
			if (classList[i].m_Id == playerClass)
			{
				deckId = classList[i].m_DeckId;
				break;
			}
		}
		
		if (deckId == 0) { return 0; }
		
		for (var i:Number = 0; i < templates.length; i++)
		{
			if (templates[i].m_Id == deckId)
			{
				var featData:FeatData = FeatInterface.m_FeatList[templates[i].m_ActiveAbilities[weaponSlot]];
				return ProjectSpell.GetWeaponRequirement(featData.m_Spell);
			}
		}
		return 0;
	}
	
	private function UpdateHeader():Void
	{
		m_Header.m_WeaponTypeName.text = LDBFormat.LDBGetText("SkillhiveGUI", "Cluster" + m_CurrentCluster);
		if (m_Character != undefined && m_PurchaseBlocker == undefined)
		{
			m_Header.m_Progress._visible = true;
			
			var currentXP:Number = 0;
			var currentLevel:Number = 0;
			switch(m_CurrentCluster)
			{
				case BLADE_DATA.m_Cluster:			currentXP = m_Character.GetStat( _global.Enums.Stat.e_BladesXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_BladeWeapon);
													break;
				case HAMMER_DATA.m_Cluster:			currentXP = m_Character.GetStat( _global.Enums.Stat.e_HammersXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_HammerWeapon);
													break;
				case FIST_DATA.m_Cluster:			currentXP = m_Character.GetStat( _global.Enums.Stat.e_FistsXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_FistWeapon);
													break;
				case BLOOD_DATA.m_Cluster:			currentXP = m_Character.GetStat( _global.Enums.Stat.e_BloodMagicXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_FocusItem_Death);
													break;
				case CHAOS_DATA.m_Cluster:			currentXP = m_Character.GetStat( _global.Enums.Stat.e_ChaosXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_FocusItem_Jinx);
													break;
				case ELEMENTAL_DATA.m_Cluster:		currentXP = m_Character.GetStat( _global.Enums.Stat.e_ElementalismXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_FocusItem_Fire);
													break;
				case SHOTGUN_DATA.m_Cluster:		currentXP = m_Character.GetStat( _global.Enums.Stat.e_ShotgunsXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_ShotgunWeapon);
													break;
				case PISTOL_DATA.m_Cluster:			currentXP = m_Character.GetStat( _global.Enums.Stat.e_PistolsXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_HandgunWeapon);
													break;
				case RIFLE_DATA.m_Cluster:			currentXP = m_Character.GetStat( _global.Enums.Stat.e_AssaultRiflesXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_AssaultRifleWeapon);
													break;
				case LAUNCHER_DATA.m_Cluster:		currentXP = m_Character.GetStat( _global.Enums.Stat.e_RocketLauncherXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_RocketLauncher);
													break;
				case CHAINSAW_DATA.m_Cluster:		currentXP = m_Character.GetStat( _global.Enums.Stat.e_ChainsawXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_Chainsaw);
													break;
				case QUANTUM_DATA.m_Cluster:		currentXP = m_Character.GetStat( _global.Enums.Stat.e_QuantumXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_Quantum);
													break;
				case WHIP_DATA.m_Cluster:			currentXP = m_Character.GetStat( _global.Enums.Stat.e_WhipXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_Whip);
													break;
				case FLAMETHROWER_DATA.m_Cluster:	currentXP = m_Character.GetStat( _global.Enums.Stat.e_FlamethrowerXP, 2 /*full*/);
													currentLevel = Character.GetLevelForWeapon(_global.Enums.ItemType.e_Type_GC_Item_TSW_Flamethrower);
													break;
			}
			
			var currentLevelXP:Number = Character.GetXPForWeaponLevel(currentLevel);
			var nextLevelXP:Number = Character.GetXPForWeaponLevel(currentLevel + 1);
			var xpIntoCurrentLevel:Number = currentXP - currentLevelXP;
			var xpNeededThisLevel:Number = nextLevelXP - currentLevelXP;
			var percentage:Number = nextLevelXP > 0 ? xpIntoCurrentLevel / xpNeededThisLevel : 1;
			
			m_Header.m_Progress.m_Text.text = nextLevelXP > 0 ? "" + xpIntoCurrentLevel + "/" + xpNeededThisLevel : "";
			m_Header.m_Progress.m_Bar._xscale = percentage * 100;
			
			m_Header.m_LevelText._visible = true;
			m_Header.m_LevelText.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "Level") + " " + currentLevel;
			m_Header.m_LevelText._x = m_Header.m_WeaponTypeName._x + m_Header.m_WeaponTypeName.textWidth + 10;
			
			var critBonusTip:String = CalculateCritBonusTip(currentLevel);
			m_Header.m_CritBonus._visible = true;
			m_Header.m_CritBonus._x = m_Header.m_LevelText._x + m_Header.m_LevelText.textWidth + 10;
			m_Header.m_CritBonus.autoSize = 'left';
			m_Header.m_CritBonus.htmlText = critBonusTip;
			
			var powerBonusTip:String = CalculatePowerBonusTip(currentLevel);
			m_Header.m_PowerBonus._visible = true;
			m_Header.m_PowerBonus._x = m_Header.m_CritBonus._x;
			m_Header.m_PowerBonus.autoSize = 'left';
			m_Header.m_PowerBonus.htmlText = powerBonusTip;
		}
		else
		{
			m_Header.m_CritBonus._visible = false;
			m_Header.m_PowerBonus._visible = false;
			m_Header.m_LevelText._visible = false;
			m_Header.m_Progress._visible = false;
		}
		/*
		//No colors for now
		Colors.ApplyColor(m_Header.m_WeaponTypeBG, headerData.m_LeftColor);
		*/
	}
	
	private function CalculateCritBonusTip(weaponLevel:Number):String
	{
		var critChanceBonus:Number = (Math.ceil(weaponLevel/2) * 0.003) * 100;
		return LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", "CritBonusTip"), String(critChanceBonus));
	}
	
	private function CalculatePowerBonusTip(weaponLevel:Number):String
	{
		var critDamageBonus:Number = (Math.floor(weaponLevel/2) * 0.012) * 100;
		return LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", "PowerBonusTip"), String(critDamageBonus));
	}
	
	private function UpdateCells(clusterId:Number):Void
	{
		//Override this!
	}
	
	private function FocusAbility(feat:FeatData):Void
	{
		//Override this!
	}
	
	private function HideDetails(hideDetails:Boolean):Void
	{
		//Override this!
	}
	
	private function UpdateAbilities(clusterId:Number):Void
	{
		//Override this!
	}
	
	private function BuyPoints():Void
	{
		//Override this!
	}
	
	private function UpdatePurchaseBlocker(clusterId:Number)
	{
		clusterId = clusterId + ACTIVE_CLUSTER_OFFSET - 1;
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				if (featData.m_ClusterIndex == clusterId)
				{
					//The only feat in this cluster should be the unlock feat
					if (!featData.m_Trained)
					{
						UnlockVisible(false);
						if (m_PurchaseBlocker == undefined)
						{
							m_PurchaseBlocker = this.attachMovie("PurchaseBlocker", "m_PurchaseBlocker", this.getNextHighestDepth());
							m_PurchaseBlocker._x = m_Header._x - 7;
							m_PurchaseBlocker._y = m_Header._y + m_Header._height;
						}
						m_UnlockButton["m_Price"].textField.text = Text.AddThousandsSeparator(featData.m_Cost);
						m_UnlockButton["m_Price"]._x = m_UnlockButton._width/2 - m_UnlockButton["m_Price"]._width/2 - 10;
						m_UnlockButton.addEventListener("click", this, "OnClickUnlock");
						m_AurumUnlockButton["m_Price"].textField.text = Text.AddThousandsSeparator(GetUnlockItemPrice());
						m_AurumUnlockButton["m_Price"]._x = m_AurumUnlockButton._width/2 - m_AurumUnlockButton["m_Price"]._width/2 - 10;
						m_AurumUnlockButton.addEventListener("click", this, "OnClickAurumUnlock");
						//This is horrible, but until scaleform gives us an even that says components created
						//at runtime are ready to be used, we have to do it.
						m_SelectedFeat = featData;
						
						//Show the help screen for locked weapons
						OnClickHelp();
						return;
					}
				}
			}
		}
		if (m_PurchaseBlocker != undefined)
		{
			m_PurchaseBlocker.removeMovieClip();
			m_PurchaseBlocker = undefined;
			UnlockVisible(false);
			RemoveHelp();
		}
	}
	
	private function SetupHelpButtons(scope:Object):Void
	{
		scope.m_HelpDisplay.m_MoreButton.label = LDBFormat.LDBGetText("SkillhiveGUI", "More");
		scope.m_HelpDisplay.m_MoreButton.addEventListener("click", scope, "OnClickHelp");
		clearInterval(scope.m_SetupHelpInterval);
	}
	
	private function UpdateFooter():Void
	{
		//Override this
	}
	
	private function GetXP() : Number
	{
		if(m_Character != null)
		{
			var XP:Number = m_Character.GetStat( Enums.Stat.e_XP, 2 );
			if (XP < 0)
			{
				XP = XP + 4294967296;
			}
			else
			{
				XP = XP + 1000000000 * m_Character.GetStat( Enums.Stat.e_XP_Billions);
			}
			return XP;
		}
		return 0;
	}
	
	private function GetLastLevelXP() : Number
	{
		if(m_Character != null)
		{
			return m_Character.GetStat( Enums.Stat.e_LastXP, 2 );
		}
		return 0;
	}
	
	private function GetNextAP():Number
	{
		if (m_Character != null)
		{
			var xp:Number = GetXP();
			return xp + Character.GetXPToNextAP();
		}
		return 0;
	}
	
	private function GetNextSP():Number
	{
		if (m_Character != null)
		{
			var xp:Number = GetXP();
			return xp + Character.GetXPToNextSP();
		}
		return 0;
	}
	
	private function BuyAbility(featId:Number)
	{		
		if (FeatInterface.TrainFeat(featId))
		{
			//m_Character.AddEffectPackage( "sound_fxpackage_GUI_purchase_power.xml" );
			//UpdateCells(m_CurrentCluster);
		}
		else
		{
			BuyPoints();
		}
	}
	
	private function UnEquipAbility(featId:Number)
	{
		var featData:FeatData = FeatInterface.m_FeatList[featId];
		if (IsPassiveAbility(featData.m_SpellType))
		{
			for (var i:Number = 0; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
			{
				if (Spell.GetPassiveAbility(i) == featData.m_Spell)
				{
					Spell.UnequipPassiveAbility(i);
				}
			}
		}
		else
		{
			for (var i:Number = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot +_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
			{
				if (Shortcut.m_ShortcutList[i].m_SpellId == featData.m_Spell)
				{
					Shortcut.RemoveFromShortcutBar(i);
				}
			}
		}
	}
	
	private function EquipAbility(featId:Number, abilityClip:MovieClip)
	{
		var featData:FeatData = FeatInterface.m_FeatList[featId];
		if (m_CurrentEquipPopupHolder != undefined)
		{
			RemoveEquipPopup();
		}
		
		m_SelectedFeat = featData;
		if (featData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
		{
			Shortcut.AddSpell(AUX_ACTIVE_SLOT + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, featData.m_Spell);
		}
		else
		{
			m_CurrentEquipPopupHolder = abilityClip.createEmptyMovieClip( "m_CurrentEquipPopupMenu", abilityClip.getNextHighestDepth() );
			if (IsActiveAbility(featData.m_SpellType))
			{
				m_CurrentEquipPopupMenu = SkillhiveEquipPopup(m_CurrentEquipPopupHolder.attachMovie("ActiveEquipPopup", "m_Popup", m_CurrentEquipPopupHolder.getNextHighestDepth()));
				m_CurrentEquipPopupMenu.SetNumButtons(6);
			}
			else if (IsPassiveAbility(featData.m_SpellType))
			{
				m_CurrentEquipPopupMenu = SkillhiveEquipPopup(m_CurrentEquipPopupHolder.attachMovie("PassiveEquipPopup", "m_Popup", m_CurrentEquipPopupHolder.getNextHighestDepth()));
				m_CurrentEquipPopupMenu.SetNumButtons(5);
			}
			
			m_CurrentEquipPopupHolder._xscale = 70;
            m_CurrentEquipPopupHolder._yscale = 70;
			m_CurrentEquipPopupHolder._x = abilityClip._width/2 - m_CurrentEquipPopupHolder._width/2;
			m_CurrentEquipPopupHolder._y = abilityClip.m_EquipPanel._y - m_CurrentEquipPopupHolder._height;
			
			this.onMouseUp = function()
			{
				if (!m_CurrentEquipPopupMenu.hitTest(_root._xmouse, _root._ymouse))
				{
					this.RemoveEquipPopup();
				}
			}

			m_CurrentEquipPopupMenu.SignalEquipButtonPressed.Connect( SlotEquipButtonPressed, this);
		}
	}
	
	private function SlotEquipButtonPressed(buttonId:Number)
	{
		var spellId = m_SelectedFeat.m_Spell;
		if (IsPassiveAbility(m_SelectedFeat.m_SpellType))
		{
			if (CanAddPassive(buttonId, spellId))
			{
				if (Spell.IsPassiveEquipped(spellId))
				{
					for (var i:Number = 0; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
					{
						if (Spell.GetPassiveAbility(i) == spellId)
						{
							Spell.MovePassiveAbility( i, buttonId );
							RemoveEquipPopup();
							return;
						}
					}
				}
				Spell.EquipPassiveAbility(buttonId, spellId);
			}
		}
		else if (IsActiveAbility(m_SelectedFeat.m_SpellType))
		{
			if (CanAddShortcut(buttonId, spellId))
			{
				if (Shortcut.IsSpellEquipped(spellId))
				{
					for (var i:Number = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot +_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
					{
						if (Shortcut.m_ShortcutList[i].m_SpellId == spellId)
						{
							Shortcut.MoveShortcut( i, buttonId + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot );
							RemoveEquipPopup();
							return;
						}
					}
				}
				Shortcut.AddSpell(buttonId + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, spellId);
			}
		}
		RemoveEquipPopup();
	}
	
	private function RemoveEquipPopup()
	{
		if (m_CurrentEquipPopupHolder != undefined)
		{
			m_CurrentEquipPopupHolder.removeMovieClip();
		}
		this.onMouseUp = function(){}
		m_CurrentEquipPopupHolder = undefined;
		m_CurrentEquipPopupMenu = undefined;
		m_SelectedFeat = undefined;
	}
	
	private function SlotFeatTrained()
	{
		m_Character.AddEffectPackage( "sound_fxpackage_GUI_purchase_power.xml" );
		UpdatePurchaseBlocker(m_CurrentCluster);
		UpdateAbilities(m_CurrentCluster);
		FocusAbility(m_FocusedFeat);
	}
	
	private function SlotFeatUntrained()
	{
		UpdateAbilities(m_CurrentCluster);
		FocusAbility(m_FocusedFeat);
	}
	
	private function SlotShortcutAdded()
	{
		UpdateAbilities(m_CurrentCluster);
		FocusAbility(m_FocusedFeat);
	}
	
	private function SlotShortcutRemoved()
	{
		UpdateAbilities(m_CurrentCluster);
		FocusAbility(m_FocusedFeat);
	}
	
	private function SlotPassiveAdded()
	{
		UpdateAbilities(m_CurrentCluster);
		FocusAbility(m_FocusedFeat);
	}
	
	private function SlotPassiveRemoved()
	{
		UpdateAbilities(m_CurrentCluster);
		FocusAbility(m_FocusedFeat);
	}
	
	private function SlotTokenChanged(tokenID:Number, newAmount:Number, oldAmount:Number)
	{
		if (tokenID == 1 || tokenID == 2)
		{
			FocusAbility(m_FocusedFeat);
			UpdateFooter();
		}
	}
	
	private function SlotStatChanged(stat:Number)
	{
		if (stat == _global.Enums.Stat.e_XP || stat == _global.Enums.Stat.e_XP_Billions || stat == _global.Enums.Stat.e_Level ||
			stat == _global.Enums.Stat.e_BladesXP || stat == _global.Enums.Stat.e_HammersXP || _global.Enums.Stat.stat == e_FistsXP || 
			stat == _global.Enums.Stat.e_BloodMagicXP || stat == _global.Enums.Stat.e_ChaosXP || stat == _global.Enums.Stat.e_ElementalismXP ||
			stat == _global.Enums.Stat.e_ShotgunsXP || stat == _global.Enums.Stat.e_PistolsXP || stat == _global.Enums.Stat.e_AssaultRiflesXP ||
			stat == _global.Enums.Stat.e_RocketLauncherXP || stat == _global.Enums.Stat.e_ChainsawXP || stat == _global.Enums.Stat.e_QuantumXP || 
			stat == _global.Enums.Stat.e_WhipXP || stat == _global.Enums.Stat.e_FlamethrowerXP)
		{
			UpdateHeader();
			UpdateFooter();
		}
	}
	
	private function IsPassiveAbility(spellType:Number)
	{
		return      spellType == _global.Enums.SpellItemType.eElitePassiveAbility || 
					spellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility ||
					spellType == _global.Enums.SpellItemType.ePassiveAbility;
	}
	
	private function IsActiveAbility(spellType:Number)
	{
		return      spellType == _global.Enums.SpellItemType.eMagicSpell || 
					spellType == _global.Enums.SpellItemType.eBuilderAbility || 
					spellType == _global.Enums.SpellItemType.eConsumerAbility || 
					spellType == _global.Enums.SpellItemType.eEliteActiveAbility ||
					spellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility;    
	}
	
	private function CanAddShortcut(pos:Number, spellId:Number) : Boolean
	{
		var spellData:SpellData = Spell.GetSpellData(spellId);
		if (spellData != undefined)
		{
			if (pos != 7 && spellData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
			{
				return false;
			}
			else if (pos == 7 && spellData.m_SpellType != _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
			{
				return false;
			}
		}
		return true;
	}
	
	private function CanAddPassive(pos:Number, spellId:Number) : Boolean
	{
		var spellData:SpellData = Spell.GetSpellData(spellId);
		if (spellData != undefined)
		{
			if (pos != 7 && spellData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
			{
				return false;
			}
			else if (pos == 7 && spellData.m_SpellType != _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
			{
				return false;
			}
		}
		return true;
	}
	
	private function OnClickUnlock()
	{
		Selection.setFocus(null);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", m_TDB_ConfirmUnlockPage), Text.AddThousandsSeparator(m_SelectedFeat.m_Cost), LDBFormat.LDBGetText("Tokens", "Token201_Plural")), _global.Enums.StandardButtons.e_ButtonsYesNo, "UnlockPage" );
		dialogIF.SignalSelectedAS.Connect(SlotConfirmUnlockPage, this);
		dialogIF.Go();
	}
	
	private function SlotConfirmUnlockPage(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			if (!FeatInterface.TrainFeat(m_SelectedFeat.m_Id))
			{
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("GenericGUI", "NotEnoughMoFs"), 0)
			}
		}
	}
	
	private function OnClickAurumUnlock()
	{
		Selection.setFocus(null);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", m_TDB_ConfirmUnlockPage), Text.AddThousandsSeparator(GetUnlockItemPrice()), LDBFormat.LDBGetText("Tokens", "Token202")), _global.Enums.StandardButtons.e_ButtonsYesNo, "UnlockPage" );
		dialogIF.SignalSelectedAS.Connect(SlotConfirmAurumUnlockPage, this);
		dialogIF.Go();
	}
	
	private function SlotConfirmAurumUnlockPage(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			if (m_Character.GetTokens(_global.Enums.Token.e_Premium_Token) < GetUnlockItemPrice())
			{
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("GenericGUI", "NotEnoughAurum"), 0)
				ShopInterface.RequestAurumPurchase();
			}
			else
			{
				ShopInterface.BuyItemTemplate(GetUnlockItem(), 202, GetUnlockItemPrice());
			}
		}
	}
	
	private function GetUnlockItem():Number
	{
		var itemTemplate:Number = undefined;
		switch(m_CurrentCluster)
		{
			case BLADE_DATA.m_Cluster:		itemTemplate = 9306777;
											break;
			case BLOOD_DATA.m_Cluster:		itemTemplate = 9306783;
											break;
			case CHAOS_DATA.m_Cluster:		itemTemplate = 9306787;
											break;
			case ELEMENTAL_DATA.m_Cluster:	itemTemplate = 9306784;
											break;
			case FIST_DATA.m_Cluster:		itemTemplate = 9306780;
											break;
			case HAMMER_DATA.m_Cluster:		itemTemplate = 9306774;
											break;
			case PISTOL_DATA.m_Cluster:		itemTemplate = 9306790;
											break;
			case RIFLE_DATA.m_Cluster:		itemTemplate = 9306789;
											break;
			case SHOTGUN_DATA.m_Cluster:	itemTemplate = 9306792;
											break;
		}
		return itemTemplate;
	}
	
	private function GetUnlockItemPrice():Number
	{
		var itemTemplate:Number = GetUnlockItem();
		var inventoryItem:InventoryItem = Inventory.CreateACGItemFromTemplate(itemTemplate, 0, 0, 1);
		return inventoryItem.m_TokenCurrencyPrice1;
	}
	
	private function RemoveHelp()
	{
		if (m_HelpDisplay != undefined)
		{
			m_HelpDisplay.removeMovieClip();
			m_HelpDisplay = undefined;
		}
		if (m_SetupHelpInterval != undefined)
		{
			clearInterval(m_SetupHelpInterval);
			m_SetupHelpInterval = undefined;
		}
	}
	
	private function OnClickHelp()
	{
		if (m_HelpDisplay != undefined)
		{
			RemoveHelp();
			return;
		}
		else
		{
			m_HelpDisplay = this.attachMovie("HelpBase", "m_HelpDisplay", this.getNextHighestDepth());
			m_HelpDisplay.m_Background.onRollOver = function(){}; //Block Mouse Events
			m_HelpDisplay._x = m_Header._x - 7;
			m_HelpDisplay._y = m_Header._y + m_Header._height;
			
			//The only time the selected feat would not be trained is if the weapon is locked
			if (m_SelectedFeat != undefined && !m_SelectedFeat.m_Trained)
			{
				m_HelpDisplay.m_Text.htmlText = "";
				var tutorial:MovieClip = undefined;
				switch(m_CurrentCluster)
				{
					case BLADE_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_blade", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
					case BLOOD_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_blood", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
					case CHAOS_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_chaos", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
					case ELEMENTAL_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_elementalism", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
					case FIST_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_fists", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
					case HAMMER_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_hammer", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
					case PISTOL_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_pistols", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
					case RIFLE_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_rifle", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
					case SHOTGUN_DATA.m_Cluster:	tutorial = m_HelpDisplay.attachMovie("tutorial_shotgun", "tutorial", m_HelpDisplay.getNextHighestDepth());
												break;
				}
				if (tutorial != undefined)
				{
					tutorial._x = 0;
					tutorial._y = m_HelpDisplay._height / 2 - tutorial._height / 2;
					var languageCode:String = LDBFormat.GetCurrentLanguageCode();
					switch(languageCode)
					{
						case "en":	tutorial["fr"]._visible = tutorial["de"]._visible = false;
									break;
						case "fr":	tutorial["en"]._visible = tutorial["de"]._visible = false;
									break;
						case "de":	tutorial["fr"]._visible = tutorial["en"]._visible = false;
									break;
					}
				}
				m_UnlockButton["m_Price"].textField.text = Text.AddThousandsSeparator(m_SelectedFeat.m_Cost);
				m_UnlockButton["m_Price"]._x = m_UnlockButton._width/2 - m_UnlockButton["m_Price"]._width/2 - 10;
				
				
				m_AurumUnlockButton["m_Price"].textField.text = Text.AddThousandsSeparator(GetUnlockItemPrice());
				m_AurumUnlockButton["m_Price"]._x = m_AurumUnlockButton._width/2 - m_AurumUnlockButton["m_Price"]._width/2 - 10;
				UnlockVisible(true);
			}
			else
			{
				switch(m_CurrentCluster)
				{
					case BLADE_DATA.m_Cluster:		m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicBlade");
													break;
					case BLOOD_DATA.m_Cluster:		m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicBlood1") + "<br>" + 
																					LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicBlood2");
													break;
					case CHAOS_DATA.m_Cluster:		m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicChaos1") + "<br>" + 
																					LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicChaos2");
													break;
					case ELEMENTAL_DATA.m_Cluster:	m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicElemental1") + "<br>" + 
																					LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicElemental2");
													break;
					case FIST_DATA.m_Cluster:		m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicFist1") + "<br>" + 
																					LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicFist2");
													break;
					case HAMMER_DATA.m_Cluster:		m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicHammer");
													break;
					case PISTOL_DATA.m_Cluster:		m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicPistol");
													break;
					case RIFLE_DATA.m_Cluster:		m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicAssaultRifle");
													break;
					case SHOTGUN_DATA.m_Cluster:	m_HelpDisplay.m_Text.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicShotgun1") + "<br>" + 
																					LDBFormat.LDBGetText("SkillhiveGUI", "WeaponMechanicShotgun2");
													break;
				}
				UnlockVisible(false);
			}
		}
		//Move the help button to the top depth
		//m_HelpButton.swapDepths(this.getNextHighestDepth());
		m_SetupHelpInterval = setInterval(SetupHelpButtons, 20, this);
	}
	
	private function OnClickVideo()
	{
		var helpId_en:Number = 0;
		var helpId_fr:Number = 0;
		var helpId_de:Number = 0;
		switch(m_CurrentCluster)
		{
			case BLADE_DATA.m_Cluster:		helpId_en = 10158;
											helpId_fr = 10170;
											helpId_de = 10179;
											break;
			case BLOOD_DATA.m_Cluster:		helpId_en = 10159;
											helpId_fr = 10171;
											helpId_de = 10180;
											break;
			case CHAOS_DATA.m_Cluster:		helpId_en = 10160;
											helpId_fr = 10172;
											helpId_de = 10181;
											break;
			case ELEMENTAL_DATA.m_Cluster:	helpId_en = 10161;
											helpId_fr = 10173;
											helpId_de = 10182;
											break;
			case FIST_DATA.m_Cluster:		helpId_en = 10162;
											helpId_fr = 10174;
											helpId_de = 10183;
											break;
			case HAMMER_DATA.m_Cluster:		helpId_en = 10163;
											helpId_fr = 10175;
											helpId_de = 10184;
											break;
			case PISTOL_DATA.m_Cluster:		helpId_en = 10164;
											helpId_fr = 10176;
											helpId_de = 10185;
											break;
			case RIFLE_DATA.m_Cluster:		helpId_en = 10157;
											helpId_fr = 10169;
											helpId_de = 10177;
											break;
			case SHOTGUN_DATA.m_Cluster:	helpId_en = 10165;
											helpId_fr = 10177;
											helpId_de = 10186;
											break;
		}
		
		var languageCode:String = LDBFormat.GetCurrentLanguageCode();
		var helpTag:Number = 0;
		switch(languageCode)
		{
			case "en":	helpTag = helpId_en;
						break;
			case "fr":	helpTag = helpId_fr;
						break;
			case "de":	helpTag = helpId_de;
						break;
		}
		
		if (helpTag != 0)
		{
			trace(helpTag);
			LoreBase.OpenTag(helpTag);
		}
	}
	
	private function UnlockVisible(unlock:Boolean)
	{
		m_UnlockButton._visible = unlock;
		m_AurumUnlockButton._visible = unlock;
		m_UnlockBG._visible = unlock;
	}
	
	private function SlotTagAdded(tagId:Number)
	{
		if (tagId == TUTORIAL_COMPLETE_TAG || PASSIVES_TUTORIAL_COMPLETE_TAG || PASSIVES_UNLOCKED_TAG)
		{
			UpdateTutorialBlocker();
		}
	}
	
	private function SlotSetLanguage()
	{
		UpdateFooter();
	}
	
	public function OnModuleActivated(config:Archive):Void
	{
		m_CurrentCluster = config.FindEntry("CurrentCluster", 0);
		Shortcut.SignalShortcutAdded.Connect( SlotShortcutAdded, this  );
		Shortcut.SignalShortcutRemoved.Connect( SlotShortcutRemoved, this );
		Spell.SignalPassiveAdded.Connect( SlotPassiveAdded, this  );
		Spell.SignalPassiveRemoved.Connect( SlotPassiveRemoved, this );
		FeatInterface.SignalFeatTrained.Connect(SlotFeatTrained, this);
    	FeatInterface.SignalFeatsUntrained.Connect(SlotFeatUntrained, this);
		m_Character = Character.GetClientCharacter();
		m_Character.SignalTokenAmountChanged.Connect(SlotTokenChanged, this);
		m_Character.SignalStatChanged.Connect( SlotStatChanged, this );
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
	}

	public function OnModuleDeactivated()
	{
		Shortcut.SignalShortcutAdded.Disconnect( SlotShortcutAdded, this  );
		Shortcut.SignalShortcutRemoved.Disconnect( SlotShortcutRemoved, this );
		Spell.SignalPassiveAdded.Disconnect( SlotPassiveAdded, this  );
		Spell.SignalPassiveRemoved.Disconnect( SlotPassiveRemoved, this );
		FeatInterface.SignalFeatTrained.Disconnect(SlotFeatTrained, this);
    	FeatInterface.SignalFeatsUntrained.Disconnect(SlotFeatUntrained, this);
		m_Character = Character.GetClientCharacter();
		m_Character.SignalTokenAmountChanged.Disconnect(SlotTokenChanged, this);
		m_Character.SignalStatChanged.Disconnect( SlotStatChanged, this );
		Lore.SignalTagAdded.Disconnect(SlotTagAdded, this);
		var archive:Archive = new Archive();
		if (m_CurrentCluster != undefined)
		{
			archive.AddEntry("CurrentCluster", m_CurrentCluster);
		}
		return archive;
	}
	
	public function onUnload()
	{
		if (m_SetupHelpInterval != undefined)
		{
			clearInterval(m_SetupHelpInterval);
			m_SetupHelpInterval = undefined;
		}
	}
}