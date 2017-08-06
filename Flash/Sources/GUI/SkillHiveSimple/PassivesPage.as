import GUI.SkillHiveSimple.AbilityPageBase;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.ProjectFeatInterface;
import com.GameInterface.Lore;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.*;
import com.GameInterface.Game.Character;
import com.GameInterface.Spell;
import com.GameInterface.ShopInterface;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.Utils.Text;
import gfx.controls.Button;
import GUI.SkillHiveSimple.AbilityClip;
import GUI.SkillHiveSimple.BoostClip;

class GUI.SkillHiveSimple.PassivesPage extends AbilityPageBase
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
	
	//This is my life now...
	private var m_Cell0_Ability0:MovieClip;
	private var m_Cell1_Ability0:MovieClip;
	private var m_Cell1_Ability1:MovieClip;
	private var m_Cell1_Ability2:MovieClip;
	private var m_Cell1_Ability3:MovieClip;
	private var m_Cell1_Ability4:MovieClip;
	private var m_Cell1_Ability5:MovieClip;
	private var m_Cell1_Ability6:MovieClip;
	private var m_Cell1_Ability7:MovieClip;
	private var m_Cell1_Ability8:MovieClip;
	private var m_Cell1_Ability9:MovieClip;
	private var m_Cell2_Ability0:MovieClip;
	private var m_Cell2_Ability1:MovieClip;
	private var m_Cell2_Ability2:MovieClip;
	private var m_Cell2_Ability3:MovieClip;
	private var m_Cell2_Ability4:MovieClip;
	private var m_Cell2_Ability5:MovieClip;
	private var m_Cell2_Ability6:MovieClip;
	private var m_Cell2_Ability7:MovieClip;
	private var m_Cell2_Ability8:MovieClip;
	private var m_Cell2_Ability9:MovieClip;
	private var m_Cell3_Ability0:MovieClip;
	private var m_Cell3_Ability1:MovieClip;
	private var m_Cell3_Ability2:MovieClip;
	private var m_Cell3_Ability3:MovieClip;
	private var m_Cell3_Ability4:MovieClip;
	private var m_Cell3_Ability5:MovieClip;
	private var m_Cell3_Ability6:MovieClip;
	private var m_Cell3_Ability7:MovieClip;
	private var m_Cell3_Ability8:MovieClip;
	private var m_Cell3_Ability9:MovieClip;
	private var m_Cell4_Ability0:MovieClip;
	private var m_Cell4_Ability1:MovieClip;
	private var m_Cell4_Ability2:MovieClip;
	private var m_Cell4_Ability3:MovieClip;
	private var m_Cell4_Ability4:MovieClip;
	private var m_Cell4_Ability5:MovieClip;
	private var m_Cell4_Ability6:MovieClip;
	private var m_Cell4_Ability7:MovieClip;
	private var m_Cell4_Ability8:MovieClip;
	private var m_Cell4_Ability9:MovieClip;
	private var m_Cell5_Ability0:MovieClip;
	private var m_Cell5_Ability1:MovieClip;
	private var m_Cell5_Ability2:MovieClip;
	private var m_Cell5_Ability3:MovieClip;
	private var m_Cell5_Ability4:MovieClip;
	private var m_Cell5_Ability5:MovieClip;
	private var m_Cell5_Ability6:MovieClip;
	private var m_Cell5_Ability7:MovieClip;
	private var m_Cell5_Ability8:MovieClip;
	private var m_Cell5_Ability9:MovieClip;
	
	private var m_DetailNoSelected:TextField;
	private var m_DetailName:TextField;
	private var m_DetailDivider:MovieClip;
	private var m_DetailAbilityType:TextField;
	private var m_DetailIcon:AbilityClip;
	private var m_DetailBoostIcon:BoostClip;
	private var m_DetailIconBG:MovieClip;
	private var m_DetailDescription:TextField;
	private var m_DetailCost:MovieClip;
	private var m_DetailEquipAnchor:MovieClip;
	private var m_DetailBG:MovieClip;
	
	private var m_EquippedPassivesText:TextField;
	
	//Variables
	//Check AbilityPageBase.as
	
	//Statics
	private static var UNLOCK_CELL:Number = 0;
	private static var PASSIVES_PER_CELL:Number = 10;
	private static var NUM_CELLS:Number = 6;
	private static var ABILITY_NAME_HEIGHT = 20;

	public function PassivesPage()
	{
		super();
		m_CurrentClusterOffset = PASSIVE_CLUSTER_OFFSET;
		m_EquippedPassivesText.text = LDBFormat.LDBGetText("SkillhiveGUI", "EquippedPassives");
	}

	private function configUI()
	{
		super.configUI();

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
		UpdateTutorialBlocker();
		m_TDB_ConfirmUnlockPage = "ConfirmPurchaseWeaponPagePassive";
	}
	
	private function UpdateTutorialBlocker()
	{
		super.UpdateTutorialBlocker();
		if (Lore.IsLocked(PASSIVES_TUTORIAL_COMPLETE_TAG) && !Lore.IsLocked(PASSIVES_UNLOCKED_TAG))
		{
			m_TutorialBlocker.m_PassivesLockedText._visible = false;
			m_TutorialBlocker.m_PassivesTabText._visible = m_TutorialBlocker.m_PassivesTabArrow._visible = false;
			
			var weaponName:String = "";
			for (var i:Number = 0; i < _global.Enums.WeaponTypeFlag.e_WeaponType_Count; i++)
			{
				var flagValue = 1 << i;
				if (GetClassWeapon(0) & flagValue)
				{
					weaponName = LDBFormat.LDBGetText("WeaponTypeGUI", flagValue);
				}
			}
			if (m_TabGroup.selectedButton.data.m_Icon == TooltipUtils.GetWeaponRequirementIconName(GetClassWeapon(0)))
			{
				m_TutorialBlocker.m_AbilitySelectText.text = LDBFormat.LDBGetText("SkillhiveGUI", "Tutorial_SkillSelect");
				m_TutorialBlocker.m_AbilitySelectText._visible = m_TutorialBlocker.m_AbilitySelectArrow._visible = true;
				m_TutorialBlocker.m_AbilityBuyText.text = LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", "Tutorial_SkillBuy"), weaponName);
				m_TutorialBlocker.m_AbilityBuyText._visible = m_TutorialBlocker.m_AbilityBuyArrow._visible = true;
				m_TutorialBlocker.m_Small._visible = false;
			}
			else
			{
				m_TutorialBlocker.m_WeaponSelectText.text = LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", "Tutorial_WeaponSelectSkill"), weaponName, weaponName);
				m_TutorialBlocker.m_WeaponSelectText._visible = m_TutorialBlocker.m_WeaponSelectArrow._visible = true;
				m_TutorialBlocker.m_Small._visible = true;
			}
		}
		else
		{
			m_TutorialBlocker.m_PassivesLockedText.text = LDBFormat.LDBGetText("SkillhiveGUI", "Tutorial_PassivesDisabled");
			m_TutorialBlocker.m_PassivesLockedText._visible = true;
		}
	}
	
	private function UpdateCells(clusterId:Number):Void
	{
		//passive clusters are under the weapon cluster + 20
		clusterId = clusterId + m_CurrentClusterOffset;
		var allFeats:Array = new Array();
		var cell0Feats:Array = new Array();
		var cell1Feats:Array = new Array();
		var cell2Feats:Array = new Array();
		var cell3Feats:Array = new Array();
		var cell4Feats:Array = new Array();
		var cell5Feats:Array = new Array();
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
					else if (featData.m_CellIndex == 3){ cell3Feats[featData.m_AbilityIndex] = featData;}
					else if (featData.m_CellIndex == 4){ cell4Feats[featData.m_AbilityIndex] = featData;}
					else if (featData.m_CellIndex == 5){ cell5Feats[featData.m_AbilityIndex] = featData;}
				}
			}
		}
		allFeats.push(cell0Feats);
		allFeats.push(cell1Feats);
		allFeats.push(cell2Feats);
		allFeats.push(cell3Feats);
		allFeats.push(cell4Feats);
		allFeats.push(cell5Feats);
		
		for (var i:Number = 0; i < NUM_CELLS; i++)
		{
			var cellFeats:Array = allFeats[i];
			var numPassives = i == UNLOCK_CELL ? 1 : PASSIVES_PER_CELL;
			for (var j:Number = 0; j < numPassives; j++)
			{
				if (cellFeats[j] != undefined)
				{
					var ability:MovieClip = this["m_Cell" + i + "_Ability" + j];
					
					//Ability Name - we don't show a name for bonuses
					if (ability.m_Name != undefined)
					{
						ability.m_Name.text = cellFeats[j].m_Name;
						if (cellFeats[j].m_SpellType == _global.Enums.SpellItemType.ePassiveAbility)
						{
							ability.m_Name.textColor = 0xE99DE5;
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
					//Icon Data
					ability.m_Icon.SetData(cellFeats[j]);
					ability.m_Icon.m_SignalAbilityFocus.Connect(FocusAbility, this);
					ability.m_EquipFrame._visible = (Spell.IsPassiveEquipped(cellFeats[j].m_Spell))
					if (m_FocusedFeat == undefined && cellFeats[j].m_CanTrain)
					{
						FocusAbility(cellFeats[j]);
					}
				}
			}
		}
		if (m_FocusedFeat == undefined)
		{
			FocusAbility(cell0Feats[0]);
		}
	}
	
	//This updates the ability display without updating the icon
	//This should be called when things are equipped or unequipped because it is faster,
	//but not on the initial setup, where we need to load actual icons
	private function UpdateAbilities(clusterId:Number):Void
	{
		//passive clusters are under the weapon cluster + 20
		clusterId = clusterId + m_CurrentClusterOffset;
		var allFeats:Array = new Array();
		var cell0Feats:Array = new Array();
		var cell1Feats:Array = new Array();
		var cell2Feats:Array = new Array();
		var cell3Feats:Array = new Array();
		var cell4Feats:Array = new Array();
		var cell5Feats:Array = new Array();
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
					else if (featData.m_CellIndex == 3){ cell3Feats[featData.m_AbilityIndex] = featData;}
					else if (featData.m_CellIndex == 4){ cell4Feats[featData.m_AbilityIndex] = featData;}
					else if (featData.m_CellIndex == 5){ cell5Feats[featData.m_AbilityIndex] = featData;}
				}
			}
		}
		allFeats.push(cell0Feats);
		allFeats.push(cell1Feats);
		allFeats.push(cell2Feats);
		allFeats.push(cell3Feats);
		allFeats.push(cell4Feats);
		allFeats.push(cell5Feats);
		
		for (var i:Number = 0; i < NUM_CELLS; i++)
		{
			var cellFeats:Array = allFeats[i];
			var numPassives = i == UNLOCK_CELL ? 1 : PASSIVES_PER_CELL;
			for (var j:Number = 0; j < numPassives; j++)
			{
				if (cellFeats[j] != undefined)
				{
					var ability:MovieClip = this["m_Cell" + i + "_Ability" + j];
					
					//Icon Data
					ability.m_EquipFrame._visible = (Spell.IsPassiveEquipped(cellFeats[j].m_Spell))
					ability.m_Icon.UpdateFilter();
				}
			}
		}
	}
	
	private function FocusAbility(feat:FeatData)
	{
		m_FocusedFeat = feat;
		if (feat == undefined)
		{
			HideDetails(true);
		}
		else
		{
			HideDetails(false);
			switch(feat.m_SpellType)
			{
				case _global.Enums.SpellItemType.ePassiveAbility:
					m_DetailBG.m_ColorLayer.gotoAndPlay("EquippedPassive");
					break;
				default:
					m_DetailBG.m_ColorLayer.gotoAndPlay("PassivePassive");					
			}
			m_DetailName.text = feat.m_Name;
			if (m_FocusedFeat.m_SpellType == _global.Enums.SpellItemType.ePassiveAbility)
			{
				m_DetailIcon.SetData(feat);
				m_DetailIcon._visible = true;
				m_DetailIconBG._visible = true;
				m_DetailBoostIcon._visible = false;
			}
			else
			{
				m_DetailBoostIcon.SetData(feat);
				m_DetailIcon._visible = false;
				m_DetailIconBG._visible = false;
				m_DetailBoostIcon._visible = true;
			}
			
			//Get the tooltip for all the interesting data
			var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( feat.m_Spell, 0 );
			m_DetailDescription.htmlText = "";
			if (m_FocusedFeat.m_SpellType == _global.Enums.SpellItemType.ePassiveAbility)
			{
				for (var i:Number = 0; i < tooltipData.m_Descriptions.length; i++)
				{
					if (tooltipData.m_Descriptions[i] == "<hr>")
					{
						m_DetailDescription.htmlText += "<br>";
					}
					else
					{
						m_DetailDescription.htmlText += tooltipData.m_Descriptions[i];
					}
				}
			}
			else
			{
				m_DetailDescription.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "StatBoostDescription") + "<br>" + feat.m_Name;
			}
			
			if (m_FocusedFeat.m_SpellType == _global.Enums.SpellItemType.ePassiveAbility)
			{
				m_DetailAbilityType.text = TooltipUtils.GetSpellTypeName(tooltipData.m_SpellType, tooltipData.m_WeaponTypeRequirement, tooltipData.m_ResourceGenerator);
			}
			else
			{
				m_DetailAbilityType.text = LDBFormat.LDBGetText("SkillhiveGUI", "PassiveBonusType");
			}
			UpdateCost(m_DetailCost, feat);
			UpdateDetailButton();
		}
	}
	
	private function UpdateCost(costClip:MovieClip, feat:FeatData)
	{
		if (!feat.m_Trained)
		{
			costClip.m_SkillPointsText.text = feat.m_Cost;
			costClip.m_SkillPointsLabel.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillPointsAbbreviation");
			if (m_Character.GetTokens(_global.Enums.Token.e_Skill_Point) >= feat.m_Cost)
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
		if (m_FocusedFeat.m_SpellType != _global.Enums.SpellItemType.ePassiveAbility &&
			m_FocusedFeat.m_Trained)
		{
			m_DetailButton._visible = false;
		}
		else
		{
			if(!m_FocusedFeat.m_Trained)
			{
				m_DetailButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "BuyAbility");
			}
			else
			{
				if (Spell.IsPassiveEquipped(m_FocusedFeat.m_Spell))
				{
					m_DetailButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "UnEquipAbility");
				}
				else
				{
					m_DetailButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "EquipAbility");
				}
				m_DetailButton.disabled = false;
				m_DetailButton._visible = true;
				return;
			}
			
			
			m_DetailButton._visible = true;
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
		if(!m_FocusedFeat.m_Trained)
		{
			BuyAbility(m_FocusedFeat.m_Id);
		}
		else
		{
			if (Spell.IsPassiveEquipped(m_FocusedFeat.m_Spell))
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
		m_DetailAbilityType._visible = !hideDetails;
		m_DetailBoostIcon._visible = !hideDetails;
		m_DetailIcon._visible = !hideDetails;
		m_DetailDescription._visible = !hideDetails;
		m_DetailCost._visible = !hideDetails;
		m_DetailButton._visible = !hideDetails;
		m_DetailEquipAnchor._visible = !hideDetails;
		
		m_DetailNoSelected._visible = hideDetails;
	}
	
	private function UpdateFooter()
	{
		var language = m_LanguageMonitor.GetValue();
		m_Footer.m_AP._visible = false;
		m_Footer.m_SP.m_EN._visible = (language == "en");
        m_Footer.m_SP.m_FR._visible = (language == "fr");
        m_Footer.m_SP.m_DE._visible = (language == "de");
		m_Footer.m_PointsText.text = m_Character.GetTokens(_global.Enums.Token.e_Skill_Point) + "/" + (com.GameInterface.Utils.GetGameTweak("SkillTokensCap") + m_Character.GetStat(_global.Enums.Stat.e_PersonalSkillTokenCap, 2 /* full */));
		m_Footer.m_Next.text = LDBFormat.LDBGetText("MiscGUI", "NextPP") + ": " + Text.AddThousandsSeparator(GetNextSP() - GetXP()) + LDBFormat.LDBGetText("SkillhiveGUI", "XP");
	}
	
	private function BuyPoints()
	{
		ShopInterface.SignalOpenInstantBuy.Emit([9301724, 9301725, 9301726]);
	}
}