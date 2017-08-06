import GUI.SkillHiveSimple.AbilityPageBase;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.ProjectFeatInterface;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Game.Character;
import com.GameInterface.Lore;
import com.GameInterface.Tooltip.*;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Utils;
import com.GameInterface.ShopInterface;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.Utils.Text;
import gfx.controls.Button;
import GUI.SkillHiveSimple.AbilityClip;
import GUI.SkillHiveSimple.CapstoneClip;

class GUI.SkillHiveSimple.ActivesPage extends AbilityPageBase
{
	//Components created in .fla
	private var m_TabBlade:Button;
	private var m_TabHammer:Button;
	private var m_TabFist:Button;
	private var m_TabBlood:Button;
	private var m_TabChaos:Button;
	private var m_TabElemental:Button;
	private var m_TabShotgun:Button;
	private var m_TabPistol:Button;
	private var m_TabRifle:Button;
	
	private var m_CapstoneReady:MovieClip;
	
	private var m_Cell0_Ability0:MovieClip;
	private var m_Cell0_Ability1:MovieClip;
	private var m_Cell0_Ability2:MovieClip;
	private var m_Cell0_Ability3:MovieClip;
	private var m_Cell0_Ability4:MovieClip;
	private var m_Cell1_Ability0:MovieClip;
	private var m_Cell1_Ability1:MovieClip;
	private var m_Cell1_Ability2:MovieClip;
	private var m_Cell1_Ability3:MovieClip;
	private var m_Cell1_Ability4:MovieClip;
	private var m_Cell2_Ability0:MovieClip;
	private var m_Cell2_Ability1:MovieClip;
	private var m_Cell2_Ability2:MovieClip;
	private var m_Cell2_Ability3:MovieClip;
	private var m_Cell2_Ability4:MovieClip;
	private var m_Capstone:MovieClip;

	private var m_Cell0Name:TextField;
	private var m_Cell1Name:TextField;
	private var m_Cell2Name:TextField;
	
	private var m_DetailName:TextField;
	private var m_DetailDivider:MovieClip;
	private var m_DetailCastIcon:MovieClip;
	private var m_DetailRecastIcon:MovieClip;
	private var m_DetailRecastTime:TextField;
	private var m_DetailCastTime:TextField;
	private var m_DetailAbilityType:TextField;
	private var m_DetailAbilityType_Capstone:TextField;
	private var m_DetailIcon:AbilityClip;
	private var m_DetailCapstoneIcon:CapstoneClip;
	private var m_DetailDescription:TextField;
	private var m_DetailCost:MovieClip;
	private var m_DetailEquipAnchor:MovieClip;
	private var m_DetailBG:MovieClip;
	private var m_CapstoneProgress:MovieClip;
	
	//Variables
	//Check AbilityPageBase.as
	private var m_NumTrainedCapstones:Number;
	
	//Statics
	private static var ACTIVES_PER_CELL:Number = 5;
	private static var NUM_CELLS:Number = 3;
	private static var ABILITY_NAME_HEIGHT = 20;

	public function ActivesPage()
	{
		super();
		m_CurrentClusterOffset = ACTIVE_CLUSTER_OFFSET;
	}

	private function configUI()
	{
		super.configUI();
		
		m_CapstoneReady.gotoAndStop(1);
		m_CapstoneReady._visible = false;
		
		m_TabBlade.data = BLADE_DATA;
		m_TabArray.push(m_TabBlade);
		m_TabHammer.data = HAMMER_DATA;
		m_TabArray.push(m_TabHammer);
		m_TabFist.data = FIST_DATA;
		m_TabArray.push(m_TabFist);
		m_TabBlood.data = BLOOD_DATA;
		m_TabArray.push(m_TabBlood);
		m_TabChaos.data = CHAOS_DATA;
		m_TabArray.push(m_TabChaos);
		m_TabElemental.data = ELEMENTAL_DATA;
		m_TabArray.push(m_TabElemental);
		m_TabShotgun.data = SHOTGUN_DATA;
		m_TabArray.push(m_TabShotgun);
		m_TabPistol.data = PISTOL_DATA;
		m_TabArray.push(m_TabPistol);
		m_TabRifle.data = RIFLE_DATA;
		m_TabArray.push(m_TabRifle);
		
		SetupTabs();
		m_CapstoneProgress.m_ProgressText.text = LDBFormat.LDBGetText("SkillhiveGUI", "CapstoneProgress");
		m_CapstoneProgress.m_HeaderText.text = LDBFormat.LDBGetText("SkillhiveGUI", "CurrentCapstoneHeader");
		m_CapstoneProgress.m_Description.text = LDBFormat.LDBGetText("SkillhiveGUI", "CapstoneMaxDescription");
		m_TDB_ConfirmUnlockPage = "ConfirmPurchaseWeaponPage";
	}
	
	private function UpdateTutorialBlocker()
	{
		super.UpdateTutorialBlocker();
		if (m_TutorialBlocker._visible)
		{
			if (Lore.IsLocked(PASSIVES_TUTORIAL_COMPLETE_TAG) && !Lore.IsLocked(PASSIVES_UNLOCKED_TAG))
			{
				m_TutorialBlocker.m_PassivesTabText.text = LDBFormat.LDBGetText("SkillhiveGUI", "Tutorial_PassiveTab");
				m_TutorialBlocker.m_PassivesTabText._visible = m_TutorialBlocker.m_PassivesTabArrow._visible = true;
			}
			else
			{
				m_TutorialBlocker.m_PassivesTabText._visible = m_TutorialBlocker.m_PassivesTabArrow._visible = false;
				var weaponName:String = "";
				for (var i:Number = 0; i < _global.Enums.WeaponTypeFlag.e_WeaponType_Count; i++)
				{
					var flagValue = 1 << i;
					if (GetClassWeapon(1) & flagValue)
					{
						weaponName = LDBFormat.LDBGetText("WeaponTypeGUI", flagValue);
					}
				}
				if (m_TabGroup.selectedButton.data.m_Icon == TooltipUtils.GetWeaponRequirementIconName(GetClassWeapon(1)))
				{
					m_TutorialBlocker.m_AbilitySelectText.text = LDBFormat.LDBGetText("SkillhiveGUI", "Tutorial_AbilitySelect");
					m_TutorialBlocker.m_AbilitySelectText._visible = m_TutorialBlocker.m_AbilitySelectArrow._visible = true;
					m_TutorialBlocker.m_AbilityBuyText.text = LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", "Tutorial_AbilityBuy"), weaponName);
					m_TutorialBlocker.m_AbilityBuyText._visible = m_TutorialBlocker.m_AbilityBuyArrow._visible = true;
					m_TutorialBlocker.m_Small._visible = false;
				}
				else
				{
					m_TutorialBlocker.m_WeaponSelectText.text = LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", "Tutorial_WeaponSelect"), weaponName, weaponName);
					m_TutorialBlocker.m_WeaponSelectText._visible = m_TutorialBlocker.m_WeaponSelectArrow._visible = true;
					m_TutorialBlocker.m_Small._visible = true;
				}
			}
		}
	}
	
	private function UpdateCells(clusterId:Number):Void
	{
		m_Cell0Name.text = LDBFormat.LDBGetText("SkillhiveGUI", "Cluster" + clusterId + "_Cell0");
		m_Cell1Name.text = LDBFormat.LDBGetText("SkillhiveGUI", "Cluster" + clusterId + "_Cell1");
		m_Cell2Name.text = LDBFormat.LDBGetText("SkillhiveGUI", "Cluster" + clusterId + "_Cell2");
		
		clusterId = clusterId + m_CurrentClusterOffset;
		
		var allFeats:Array = new Array();
		var cell0Feats:Array = new Array();
		var cell1Feats:Array = new Array();
		var cell2Feats:Array = new Array();
		var capstoneFeats:Array = new Array();
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				if (featData.m_ClusterIndex == clusterId)
				{
					if (featData.m_CellIndex == 0){ cell0Feats[featData.m_AbilityIndex] = featData;}
					else if (featData.m_CellIndex == 1){ cell1Feats[featData.m_AbilityIndex] = featData;}
					else if (featData.m_CellIndex == 2){ cell2Feats[featData.m_AbilityIndex] = featData;}
				}
			}
		}
		allFeats.push(cell0Feats);
		allFeats.push(cell1Feats);
		allFeats.push(cell2Feats);
		
		for (var i:Number = 0; i < NUM_CELLS; i++)
		{
			var cellFeats:Array = allFeats[i];
			for (var j:Number = 0; j < ACTIVES_PER_CELL; j++)
			{
				if (cellFeats[j] != undefined)
				{
					var ability:MovieClip = this["m_Cell" + i + "_Ability" + j];
					
					//Ability Name
					SetAbilityNameDisplay(ability, cellFeats[j]);
					//Icon Data
					ability.m_Icon.SetData(cellFeats[j]);
					//Focus Signal
					ability.m_Icon.m_SignalAbilityFocus.Connect(FocusAbility, this);
					ability.m_EquipFrame._visible = (Shortcut.IsSpellEquipped(cellFeats[j].m_Spell))
					if (m_FocusedFeat == undefined && cellFeats[j].m_CanTrain)
					{
						FocusAbility(cellFeats[j]);
					}
				}
			}
		}

		var capstoneFeat = GetNextCapstone();
		if (capstoneFeat == undefined)
		{
			capstoneFeat = GetCurrentCapstone();
		}
		m_Capstone.m_Icon.SetData(capstoneFeat);
		m_Capstone.m_Icon.m_SignalAbilityFocus.Connect(FocusAbility, this);
		
		if (m_FocusedFeat == undefined)
		{
			FocusAbility(cell0Feats[0]);
		}
		m_NumTrainedCapstones = GetNumTrainedCapstones();
		UpdateCapstoneBonus();
		m_CapstoneProgress.gotoAndStop("have_"+m_NumTrainedCapstones);
	}
	
	//This updates the ability display without updating the icon
	//This should be called when things are equipped or unequipped because it is faster,
	//but not on the initial setup, where we need to load actual icons
	private function UpdateAbilities(clusterId:Number):Void
	{
		m_Cell0Name.text = LDBFormat.LDBGetText("SkillhiveGUI", "Cluster" + clusterId + "_Cell0");
		m_Cell1Name.text = LDBFormat.LDBGetText("SkillhiveGUI", "Cluster" + clusterId + "_Cell1");
		m_Cell2Name.text = LDBFormat.LDBGetText("SkillhiveGUI", "Cluster" + clusterId + "_Cell2");
		
		clusterId = clusterId + m_CurrentClusterOffset;
		
		var allFeats:Array = new Array();
		var cell0Feats:Array = new Array();
		var cell1Feats:Array = new Array();
		var cell2Feats:Array = new Array();
		var capstoneFeats:Array = new Array();
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				if (featData.m_ClusterIndex == clusterId)
				{
					if (featData.m_CellIndex == 0){ cell0Feats[featData.m_AbilityIndex] = featData;}
					else if (featData.m_CellIndex == 1){ cell1Feats[featData.m_AbilityIndex] = featData;}
					else if (featData.m_CellIndex == 2){ cell2Feats[featData.m_AbilityIndex] = featData;}
				}
			}
		}
		allFeats.push(cell0Feats);
		allFeats.push(cell1Feats);
		allFeats.push(cell2Feats);
		
		for (var i:Number = 0; i < NUM_CELLS; i++)
		{
			var cellFeats:Array = allFeats[i];
			for (var j:Number = 0; j < ACTIVES_PER_CELL; j++)
			{
				if (cellFeats[j] != undefined)
				{
					var ability:MovieClip = this["m_Cell" + i + "_Ability" + j];
					
					ability.m_Icon.UpdateFilter();
					ability.m_EquipFrame._visible = (Shortcut.IsSpellEquipped(cellFeats[j].m_Spell))
				}
			}
		}

		m_Capstone.m_Icon.UpdateFilter();
	}
	
	private function SetAbilityNameDisplay(ability:MovieClip, feat:FeatData)
	{
		var abilityName = feat.m_Name;
		ability.m_Name.text = abilityName;
		switch(feat.m_SpellType)
		{
			case _global.Enums.SpellItemType.eBuilderAbility:
				ability.m_Name.textColor = Colors.e_ColorWhite;
				break;
			case _global.Enums.SpellItemType.eConsumerAbility:
				ability.m_Name.textColor = 0xDD6666;
				break;
			case _global.Enums.SpellItemType.eMagicSpell:
				ability.m_Name.textColor = 0x9393E7;
				break;
			case _global.Enums.SpellItemType.eEliteActiveAbility:
				ability.m_Name.textColor = 0xF7E770;
				break;
			default:
				ability.m_Name.textColor = Colors.e_ColorWhite;
		}
		if (ability == m_Capstone)
		{
			ability.m_Name.textColor = Colors.e_ColorWhite;
		}
		//Shift the text field in the ability clip depending on how many lines of text there are
		if (ability.m_Name.textHeight < ABILITY_NAME_HEIGHT)
		{
			ability.m_Name._y = ABILITY_NAME_HEIGHT/2;
		}
		else
		{
			ability.m_Name._y = 0;
		}
	}
	
	private function FocusAbility(feat:FeatData)
	{
		m_FocusedFeat = feat;
		if (feat == undefined)
		{
			HideDetails(true);
			m_DetailBG.m_ColorLayer.gotoAndPlay("Basic");
		}
		else
		{
			switch(feat.m_SpellType)
			{
				case _global.Enums.SpellItemType.eBuilderAbility:
					m_DetailBG.m_ColorLayer.gotoAndPlay("Basic");
					break;
				case _global.Enums.SpellItemType.eConsumerAbility:
					m_DetailBG.m_ColorLayer.gotoAndPlay("consumer");
					break;
				case _global.Enums.SpellItemType.eMagicSpell:
					m_DetailBG.m_ColorLayer.gotoAndPlay("Cooldown");
					break;
				case _global.Enums.SpellItemType.eEliteActiveAbility:
					m_DetailBG.m_ColorLayer.gotoAndPlay("Elite");
					break;
				default:
					m_DetailBG.m_ColorLayer.gotoAndPlay("Basic");					
			}
			var isCapstone:Boolean = false;
			if (feat.m_Id == m_Capstone.m_Icon.m_FeatData.m_Id)
			{
				isCapstone = true;
				m_DetailBG.m_ColorLayer.gotoAndPlay("PassivePassive");
			}
			HideDetails(false);
			m_DetailName.text = feat.m_Name;
			m_DetailDescription.htmlText = "";
			if (isCapstone)
			{
				m_DetailCapstoneIcon._visible = true;
				m_DetailIcon._visible = false;
				m_CapstoneProgress._visible = true;
				m_DetailAbilityType._visible = false;
				m_DetailCastTime._visible = false;
				m_DetailRecastTime._visible = false;
				m_DetailCastIcon._visible = false;
				m_DetailRecastIcon._visible = false;
				m_DetailAbilityType_Capstone._visible = true;
				
				m_DetailCapstoneIcon.SetData(feat);
				m_DetailAbilityType_Capstone.text = LDBFormat.LDBGetText("SkillhiveGUI", "CapstoneType");
				//Get the tooltip for all the interesting data
				var tooltipData:TooltipData = TooltipDataProvider.GetFeatTooltip( feat.m_Id, false );
				m_DetailDescription.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "StatBoostDescription") + "<br>"
				for (var i:Number = 0; i < tooltipData.m_Attributes.length; i++)
				{
					var attribute:Object = tooltipData.m_Attributes[i];
					switch(attribute.m_Mode)
					{
						case TooltipData.e_ModeNormal:
							m_DetailDescription.htmlText += attribute.m_Right + "<br>";
							break;
						case TooltipData.e_ModeSplitter:
							break;
					}
				}
			}
			else
			{
				m_DetailCapstoneIcon._visible = false;
				m_DetailIcon._visible = true;
				m_CapstoneProgress._visible = false;
				m_DetailAbilityType._visible = true;
				m_DetailCastTime._visible = true;
				m_DetailRecastTime._visible = true;
				m_DetailCastIcon._visible = true;
				m_DetailRecastIcon._visible = true;
				m_DetailAbilityType_Capstone._visible = false;
				
				m_DetailIcon.SetData(feat);
				//Get the tooltip for all the interesting data
				var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( feat.m_Spell, 0 );
				m_DetailAbilityType.text = TooltipUtils.GetSpellTypeName(tooltipData.m_SpellType, tooltipData.m_WeaponTypeRequirement, tooltipData.m_ResourceGenerator);
				if (m_DetailAbilityType.textHeight < 20)
				{
					m_DetailAbilityType._y = 92;
					m_DetailIcon._y = 93;
				}
				else
				{
					m_DetailAbilityType._y = 78;
					m_DetailIcon._y = 83;
				}
				if (tooltipData.m_CastTime > 0)
				{
					m_DetailCastTime.text = com.Utils.Format.Printf( "%.1f", tooltipData.m_CastTime);
				}
				else
				{
					m_DetailCastTime.text = LDBFormat.LDBGetText("ItemInfoGUI", "Instant");
				}
				if (tooltipData.m_RecastTime > 0)
				{
					m_DetailRecastTime.text = com.Utils.Format.Printf( "%.1f", tooltipData.m_RecastTime);
				}
				else
				{
					m_DetailRecastTime.text = LDBFormat.LDBGetText("ItemInfoGUI", "Instant");
				}
				for (var i:Number = 0; i < tooltipData.m_Descriptions.length; i++)
				{
					if (tooltipData.m_Descriptions[i] == "<hr>")
					{
						m_DetailDescription.htmlText += "<br>";
					}
					else
					{
						m_DetailDescription.htmlText += Utils.SetupHtmlHyperLinks(tooltipData.m_Descriptions[i], "_global.com.GameInterface.Tooltip.Tooltip.SlotHyperLinkClicked", true);
					}
				}
			}
			UpdateCost(m_DetailCost, feat);
			UpdateDetailButton();
		}
	}
	
	//Warning: This will always focus the capstone feat
	//This should only be called when a new capstone is trained
	//which means the player is focused on the previous capstone anyway
	private function UpdateCapstoneProgress()
	{
		if (m_NumTrainedCapstones != GetNumTrainedCapstones())
		{
			if (GetNextCapstone() != undefined)
			{
				m_Capstone.m_Icon.SetData(GetNextCapstone());
				FocusAbility(GetNextCapstone());
			}
			else
			{
				m_Capstone.m_Icon.SetData(GetCurrentCapstone());
				FocusAbility(GetCurrentCapstone());
			}
			m_NumTrainedCapstones = GetNumTrainedCapstones();
			m_CapstoneProgress.gotoAndPlay("buy_"+m_NumTrainedCapstones);
			
			UpdateCapstoneBonus();
		}
	}
	
	private function UpdateCapstoneBonus()
	{
		var tooltipData:TooltipData = TooltipDataProvider.GetFeatTooltip( GetCurrentCapstone().m_Id, false );
		m_CapstoneProgress.m_Bonus.htmlText = "";
		for (var i:Number = 0; i < tooltipData.m_Attributes.length; i++)
		{
			var attribute:Object = tooltipData.m_Attributes[i];
			switch(attribute.m_Mode)
			{
				case TooltipData.e_ModeNormal:
					var numPos:Number = attribute.m_Right.indexOf("+");
					var num:Number = m_NumTrainedCapstones * parseInt(attribute.m_Right.substr(numPos+1, 2));
					var strStart:String = attribute.m_Right.substring(0, numPos+1);
					var strEnd:String = attribute.m_Right.substring(numPos+3, attribute.m_Right.length);
					var strCombine = strStart + num + strEnd;					
					m_CapstoneProgress.m_Bonus.htmlText += strCombine + "<br>";
					break;
				case TooltipData.e_ModeSplitter:
					break;
			}
		}
	}
	
	private function UpdateCost(costClip:MovieClip, feat:FeatData)
	{
		//If this is the capstone, get the next available capstone
		if (feat.m_Id == m_Capstone.m_Icon.m_FeatData.m_Id && GetNextCapstone() != undefined)
		{
			feat = GetNextCapstone();
		}
		if (!feat.m_Trained)
		{
			costClip.m_SkillPointsText.text = feat.m_Cost;
			costClip.m_SkillPointsLabel.text = LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsAbbreviation");
			if (m_Character.GetTokens(_global.Enums.Token.e_Anima_Point) >= feat.m_Cost)
			{
				costClip.m_SkillPointsText.textColor =  Colors.e_ColorPureGreen;
				costClip.m_SkillPointsLabel.textColor = Colors.e_ColorPureGreen;
			}
			else
			{
				costClip.m_SkillPointsText.textColor = Colors.e_ColorPureRed;
				costClip.m_SkillPointsLabel.textColor = Colors.e_ColorPureRed;
			}
			costClip._visible = true;
		}
		else
		{
			costClip._visible = false;
		}
	}
	
	private function UpdateDetailButton()
	{
		if (m_FocusedFeat.m_Id == m_Capstone.m_Icon.m_FeatData.m_Id)
		{
			var nextCapstone:FeatData = GetNextCapstone();
			if (nextCapstone == undefined)
			{
				//This will be true for the final capstone
				nextCapstone = m_FocusedFeat;
			}
			m_DetailButton._visible = true;
			m_DetailButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "UpgradeCapstone");
			if (!nextCapstone.m_Trained && nextCapstone.m_CanTrain)
			{
				m_DetailButton.disabled = false;
			}
			else
			{
				m_DetailButton.disabled = true;
			}
		}
		else
		{
			m_DetailButton._visible = true;
			if(!m_FocusedFeat.m_Trained)
			{
				m_DetailButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "BuyAbility");
			}
			else
			{
				if (Shortcut.IsSpellEquipped(m_FocusedFeat.m_Spell))
				{
					m_DetailButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "UnEquipAbility");
				}
				else
				{
					m_DetailButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "EquipAbility");
				}
				m_DetailButton.disabled = false;
				return;
			}
			if ((m_FocusedFeat.m_Trained || m_FocusedFeat.m_CanTrain))
			{
				m_DetailButton.disabled = false;
			}
			else
			{
				m_DetailButton.disabled = true;
			}
		}
	}
	
	private function SlotDetailButtonClicked()
	{
		//Capstones look for the next capstone and buy
		if (m_FocusedFeat.m_Id == m_Capstone.m_Icon.m_FeatData.m_Id && GetNextCapstone() != undefined)
		{
			BuyAbility(GetNextCapstone().m_Id);
		}
		else if(!m_FocusedFeat.m_Trained)
		{
			BuyAbility(m_FocusedFeat.m_Id);
		}
		else
		{
			if (Shortcut.IsSpellEquipped(m_FocusedFeat.m_Spell))
			{
				UnEquipAbility(m_FocusedFeat.m_Id);
			}
			else
			{
				EquipAbility(m_FocusedFeat.m_Id, MovieClip(m_DetailEquipAnchor));
			}
		}
		Selection.setFocus(null)
	}
	
	private function HideDetails(hideDetails:Boolean)
	{
		m_DetailName._visible = !hideDetails;
		m_DetailDivider._visible = !hideDetails;
		m_DetailCastIcon._visible = !hideDetails;
		m_DetailRecastIcon._visible = !hideDetails;
		m_DetailRecastTime._visible = !hideDetails;
		m_DetailCastTime._visible = !hideDetails;
		m_DetailAbilityType._visible = !hideDetails;
		m_DetailIcon._visible = !hideDetails;
		m_DetailCapstoneIcon._visible = !hideDetails;
		m_DetailDescription._visible = !hideDetails;
		m_DetailCost._visible = !hideDetails;
		m_DetailButton._visible = !hideDetails;
		m_DetailEquipAnchor._visible = !hideDetails;
		m_CapstoneProgress._visible = !hideDetails;
		
		m_DetailNoSelected._visible = hideDetails;
	}
	
	private function SlotFeatTrained()
	{
		super.SlotFeatTrained();
		UpdateCapstoneProgress();
	}
	
	private function GetNextCapstone():FeatData
	{
		var clusterId = m_CurrentCluster + m_CurrentClusterOffset;
		var orderedFeats = new Array();
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				//Capstone cluster is off by one
				if (featData.m_ClusterIndex == clusterId + 1)
				{
					orderedFeats[featData.m_AbilityIndex] = featData;
				}
			}
		}
		for (var i:Number = 0; i < orderedFeats.length; i++)
		{
			var featData:FeatData = orderedFeats[i];
			if (!featData.m_Trained)
			{
				return featData;
			}
		}
	}
	
	private function GetCurrentCapstone()
	{
		var clusterId = m_CurrentCluster + m_CurrentClusterOffset;
		var currentCapstone:FeatData = undefined;
		var orderedFeats = new Array();
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				//Capstone cluster is off by one
				if (featData.m_ClusterIndex == clusterId + 1)
				{
					orderedFeats[featData.m_AbilityIndex] = featData;
				}
			}
		}
		for (var i:Number = 0; i < orderedFeats.length; i++)
		{
			var featData:FeatData = orderedFeats[i];
			if (i == 0 || featData.m_Trained)
			{
				currentCapstone = featData;
			}
			else
			{
				break;
			}
		}
		return currentCapstone;
	}
	
	private function GetNumTrainedCapstones():Number
	{
		var clusterId = m_CurrentCluster + m_CurrentClusterOffset;
		var trainedCapstones:Number = 0;
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				//Capstone cluster is off by one
				if (featData.m_ClusterIndex == clusterId + 1)
				{
					if (featData.m_Trained)
					{
						trainedCapstones++;
					}
				}
			}
		}
		return trainedCapstones;
	}
	
	private function UpdateFooter()
	{
		var language = m_LanguageMonitor.GetValue();
		m_Footer.m_SP._visible = false;
		m_Footer.m_AP.m_EN._visible = (language == "en");
        m_Footer.m_AP.m_FR._visible = (language == "fr");
        m_Footer.m_AP.m_DE._visible = (language == "de");
		m_Footer.m_PointsText.text = m_Character.GetTokens(_global.Enums.Token.e_Anima_Point) + "/" + (com.GameInterface.Utils.GetGameTweak("LevelTokensCap") + m_Character.GetStat(_global.Enums.Stat.e_PersonalAnimaTokenCap, 2 /* full */));		
		m_Footer.m_Next.text = LDBFormat.LDBGetText("MiscGUI", "NextAP") + ": " + Text.AddThousandsSeparator(GetNextAP() - GetXP()) + LDBFormat.LDBGetText("SkillhiveGUI", "XP");
	}
	
	private function BuyPoints()
	{
		ShopInterface.SignalOpenInstantBuy.Emit([9301708, 9301715, 9301722]);
	}
}