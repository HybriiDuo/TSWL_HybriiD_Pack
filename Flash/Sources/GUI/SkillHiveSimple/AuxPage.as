import GUI.SkillHiveSimple.AbilityPageBase;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.ProjectFeatInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Lore;
import com.Utils.LDBFormat;
import gfx.controls.Button;

class GUI.SkillHiveSimple.AuxPage extends AbilityPageBase
{
	//Components created in .fla
	private var m_TabLauncher:Button;
	private var m_TabChainsaw:Button;
	private var m_TabQuantum:Button;
	private var m_TabWhip:Button;
	private var m_TabFlamethrower:Button;
	
	private var m_Cell0_Ability0:MovieClip;
	private var m_Cell0_Ability1:MovieClip;
	private var m_Cell0_Ability2:MovieClip;
	private var m_Cell0_Ability3:MovieClip;
	
	private var m_WeaponTypeBG:MovieClip;
	private var m_WeaponTypeColor:MovieClip;
	private var m_WeaponTypeName:TextField;
	private var m_BGContent:MovieClip;
	
	private var m_Footer:MovieClip;
	
	//Variables
	//Check AbilityPageBase.as
	private var m_BackgroundIcon:MovieClip;
	
	//Statics
	private static var ACTIVES_PER_CELL:Number = 4;
	private static var NUM_CELLS:Number = 1;
	private static var ABILITY_NAME_HEIGHT = 20;
	private static var AUX_UNLOCK_TAG:Number = 5437;

	public function AuxPage()
	{
		super();
	}

	private function configUI()
	{
		super.configUI();

		m_TabLauncher.data = LAUNCHER_DATA;
		m_TabArray.push(m_TabLauncher);
		m_TabChainsaw.data = CHAINSAW_DATA;
		m_TabArray.push(m_TabChainsaw);
		m_TabQuantum.data = QUANTUM_DATA;
		m_TabArray.push(m_TabQuantum);
		m_TabWhip.data = WHIP_DATA;
		m_TabArray.push(m_TabWhip);
		m_TabFlamethrower.data = FLAMETHROWER_DATA;
		m_TabArray.push(m_TabFlamethrower);
		
		SetupTabs();
	}
	
	private function UpdateHeader(headerData:Object):Void
	{
		super.UpdateHeader(headerData);
		UpdateBackground(headerData.m_Icon);
	}
	
	private function UpdateTutorialBlocker()
	{
		//Intentionally do not call superclass. Aux weapons care about aux tag, not tutorial
		if (m_TutorialBlocker._visible)
		{
			if (!Lore.IsLocked(AUX_UNLOCK_TAG))
			{
				m_TutorialBlocker._visible = false;
			}
			m_TutorialBlocker.m_AuxLockedText.text = LDBFormat.LDBGetText("SkillhiveGUI", "AuxDisabled");
		}
	}
	
	private function UpdateBackground(iconName:String)
	{
		if (m_BackgroundIcon != undefined)
		{
			m_BackgroundIcon.removeMovieClip();
			m_BackgroundIcon = undefined;
		}
		m_BackgroundIcon = m_BGContent.attachMovie(iconName, "m_BackgroundIcon", m_BGContent.getNextHighestDepth());
		m_BackgroundIcon._width = m_BGContent._width;
		m_BackgroundIcon._height = m_BGContent._height;
	}
	
	//OVERRIDDEN
	private function UpdatePurchaseBlocker(clusterId:Number)
	{
		//Intentionally blank. Aux weapons have no unlocker
	}
	
	private function SlotTagAdded(tagId:Number)
	{
		//Intentionally do not call super class. Aux weapons care about the aux tag, not tutorial
		if (tagId == AUX_UNLOCK_TAG)
		{
			UpdateTutorialBlocker();
		}
	}
	
	private function UpdateCells(clusterId:Number):Void
	{		
		var cellFeats:Array = new Array();
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				if (featData.m_ClusterIndex == clusterId && 
					featData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
				{
					cellFeats.push(featData);
				}
			}
		}		
		for (var i:Number = 0; i < ACTIVES_PER_CELL; i++)
		{
			var ability:MovieClip = this["m_Cell0_Ability" + i];
			
			//Ability Name
			ability.m_Name.text = cellFeats[i].m_Name;
			//Shift the text field in the ability clip depending on how many lines of text there are
			if (ability.m_Name.textHeight < ABILITY_NAME_HEIGHT)
			{
				ability.m_Name._y = ABILITY_NAME_HEIGHT/2;
			}
			else
			{
				ability.m_Name._y = 0;
			}
			//Icon Data
			ability.m_Icon.SetData(cellFeats[i]);
			
			//Equip Panel
			ability.m_EquipPanel.SetData(m_Character, cellFeats[i].m_Cost, _global.Enums.Token.e_Anima_Point, cellFeats[i].m_Id, cellFeats[i].m_CanTrain);            
			ability.m_EquipPanel.SetShouldUnequip(cellFeats[i].m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility || cellFeats[i].m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility);
			ability.m_EquipPanel.SignalBuyPressed.Connect(BuyAbility, this);
			ability.m_EquipPanel.SignalRefundPressed.Connect(RefundAbility, this);
			ability.m_EquipPanel.SignalEquipPressed.Connect(EquipAbility, this);
			ability.m_EquipPanel.SignalUnEquipPressed.Connect(UnEquipAbility, this);
			ability.m_EquipPanel.Update(cellFeats[i].m_Trained, (cellFeats[i].m_Refundable && ProiectFeatInterface.CanRefund()), cellFeats[i].m_Spell, cellFeats[i].m_CanTrain);
		}
	}
	
	//NOTE: This should not be done to setup the equip panels. They are updated within Update Cells
	//This fundtion is intended to be a less resource intensive method of updating the equip state
	//of abilities without updating the ability icons and names
	private function UpdateEquipPanels(clusterId:Number)
	{
		var cellFeats:Array = new Array();
		for (var featID in FeatInterface.m_FeatList)
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{
				if (featData.m_ClusterIndex == clusterId && 
					featData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
				{
					cellFeats.push(featData);
				}
			}
		}		
		for (var i:Number = 0; i < ACTIVES_PER_CELL; i++)
		{
			var ability:MovieClip = this["m_Cell0_Ability" + i];
			ability.m_EquipPanel.Update(cellFeats[i].m_Trained, (cellFeats[i].m_Refundable && ProiectFeatInterface.CanRefund()), cellFeats[i].m_Spell, cellFeats[i].m_CanTrain);
		}
	}
	
	private function UpdateFooter()
	{
		var language = m_LanguageMonitor.GetValue();
		m_Footer.m_SP._visible = false;
		m_Footer.m_AP.m_EN._visible = (language == "en");
        m_Footer.m_AP.m_FR._visible = (language == "fr");
        m_Footer.m_AP.m_DE._visible = (language == "de");
		m_Footer.m_PointsText.text = "" + m_Character.GetTokens(_global.Enums.Token.e_Anima_Point) + "/" + (com.GameInterface.Utils.GetGameTweak("LevelTokensCap") + m_Character.GetStat(_global.Enums.Stat.e_PersonalAnimaTokenCap, 2 /* full */));
	}
}