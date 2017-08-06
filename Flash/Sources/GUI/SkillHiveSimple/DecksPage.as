import com.Components.WindowComponentContent;
import com.Utils.Archive;
import com.Utils.LDBFormat;
import com.GameInterface.Game.Character;
import gfx.controls.ScrollingList;
import com.GameInterface.CharacterCreation.CharacterCreation;
import com.GameInterface.SkillWheel.SkillWheel;
import com.GameInterface.SkillWheel.SkillTemplate;
import GUI.SkillHive.SkillHiveFeatHelper;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.ProjectSpell;
import com.GameInterface.Spell;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Lore;
import com.GameInterface.Game.Shortcut;

class GUI.SkillHiveSimple.DecksPage extends WindowComponentContent
{
	//Properties created in .fla
	private var m_ClassHeader:TextField;
	private var m_ClassDesc:TextField;
	private var m_WeaponHeader:TextField;
	private var m_PrimaryText:TextField;
	private var m_SecondaryText:TextField;
	private var m_WeaponName_0:TextField;
	private var m_WeaponName_1:TextField;
	private var m_Weapon_0:MovieClip;
	private var m_Weapon_1:MovieClip;
	private var m_RoleHeader:TextField;
	private var m_RoleName_0:TextField;
	private var m_RoleName_1:TextField;
	private var m_RoleDesc_0:TextField;
	private var m_RoleDesc_1:TextField;
	private var m_AbilitiesHeader:TextField;
	private var m_Active_0:MovieClip;
	private var m_Active_1:MovieClip;
	private var m_Active_2:MovieClip;
	private var m_Active_3:MovieClip;
	private var m_Active_4:MovieClip;
	private var m_Active_5:MovieClip;
	private var m_Passive_0:MovieClip;
	private var m_Passive_1:MovieClip;
	private var m_Passive_2:MovieClip;
	private var m_Passive_3:MovieClip;
	private var m_Passive_4:MovieClip;
	private var m_ListHeader:TextField;
	private var m_DeckScrollingList:ScrollingList;
	private var m_ClaimButton:MovieClip;
    private var m_EquipButton:MovieClip;
	
	//Variables
	private var m_Character:Character;
	private var m_TemplateData:Array;
	private var m_CharacterCreationIF:CharacterCreation;
	
	//Statics	
	
	public function DecksPage()
	{
		super();		
		m_Character = Character.GetClientCharacter()
	}
	
	private function configUI():Void
	{
		super.configUI();
		
		SetLabels();
		
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
		FeatInterface.SignalFeatTrained.Connect(SlotFeatTrained, this);
		
		m_DeckScrollingList.addEventListener("change", this, "SlotSelectDeck");
		m_EquipButton.addEventListener("click", this, "OnClickEquip");
        m_ClaimButton.addEventListener("click", this, "OnClickClaim");
		
		PopulateDecks();
		m_DeckScrollingList.selectedIndex = 0;
	}
	
	private function SetLabels():Void
	{
		m_WeaponHeader.text = LDBFormat.LDBGetText( "CharCreationGUI", "WeaponsHeader" );
		m_PrimaryText.text = LDBFormat.LDBGetText( "CharCreationGUI", "PrimaryWeapon" );
		m_SecondaryText.text = LDBFormat.LDBGetText( "CharCreationGUI", "SecondaryWeapon" );
		m_RoleHeader.text = LDBFormat.LDBGetText( "CharCreationGUI", "RoleHeader" );
		m_AbilitiesHeader.text = LDBFormat.LDBGetText( "CharCreationGUI", "AbilitiesHeader" );
		m_ClaimButton.label = LDBFormat.LDBGetText("SkillhiveGUI", "ClaimDeck")
        m_EquipButton.label = LDBFormat.LDBGetText("SkillhiveGUI", "EquipDeck")
	}
	
	private function PopulateDecks()
	{
		var templates:Array = SkillWheel.m_FactionSkillTemplates[m_Character.GetStat(_global.Enums.Stat.e_PlayerFaction)];
		m_TemplateData = new Array();
		
		for (var i:Number = 0; i < templates.length; i++)
        {
            var templateListItem:Object = new Object();
            templateListItem.label = LDBFormat.LDBGetText("SkillhiveGUI", templates[i].m_Id);
            templateListItem.m_Template = templates[i];
            
            m_TemplateData.push(templateListItem);
        }
            
        m_TemplateData.sortOn("label", [Array.CASEINSENSITIVE]);
        
        for (var i:Number = 0; i < m_TemplateData.length; i++)
        {
            if (m_TemplateData[i].m_Template.m_Achievement == PANOPTIC_CORE_ACHIEVEMENT_ID_GAMETWEAK)
            {
                m_TemplateData.splice(m_TemplateData.length, 0, m_TemplateData.splice(i, 1)[0]);
                break;
            }
        }
        
        m_DeckScrollingList.dataProvider = m_TemplateData;
        m_DeckScrollingList.invalidateData();
	}
	
	private function UpdateSelectedDeck(deckIndex:Number):Void
	{
		var skillTemplate:SkillTemplate = m_TemplateData[deckIndex].m_Template;
		
		m_ClassHeader.text = LDBFormat.LDBGetText("SkillhiveGUI", skillTemplate.m_Id);
		m_ClassDesc.text = LDBFormat.LDBGetText("SkillhiveGUI", skillTemplate.m_Description);
		var weaponRequirements:Array = GetWeaponRequirements(skillTemplate);
		
		/*
		//TODO: Get the favored roles		
		var roleName:String = "";
		var roleDesc:String = "";
		var roleIcon:String = "";
		switch(primaryRole)
		{
			case _global.Enums.LFGRoles.e_RoleTank:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleTank");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleTankDesc");
				roleIcon = "TankIcon";
				break;
			case _global.Enums.LFGRoles.e_RoleDamage:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamage");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamageDesc");
				roleIcon = "DPSIcon";
				break;
			case _global.Enums.LFGRoles.e_RoleHeal:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleHeal");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleHealDesc");
				roleIcon = "HealerIcon";
				break;
			default:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamage");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamageDesc");
				roleIcon = "DPSIcon";				
		}
		m_RoleName_0.text = roleName;
		m_RoleDesc_0.text = roleDesc;
		if (m_RoleIcon_0 != undefined)
		{
			m_RoleIcon_0.removeMovieClip();
		}
		attachMovie(roleIcon, "m_RoleIcon_0", getNextHighestDepth());
		m_RoleIcon_0._x = m_RoleName_0._x - m_RoleIcon_0._width - 5;
		m_RoleIcon_0._y = m_RoleName_0._y
		
		switch(secondaryRole)
		{
			case _global.Enums.LFGRoles.e_RoleTank:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleTank");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleTankDesc");
				roleIcon = "TankIcon";
				break;
			case _global.Enums.LFGRoles.e_RoleDamage:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamage");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamageDesc");
				roleIcon = "DPSIcon";
				break;
			case _global.Enums.LFGRoles.e_RoleHeal:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleHeal");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleHealDesc");
				roleIcon = "HealerIcon";
				break;
			default:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamage");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamageDesc");
				roleIcon = "DPSIcon";				
		}
		m_RoleName_1.text = roleName;
		m_RoleDesc_1.text = roleDesc;
		if (m_RoleIcon_1 != undefined)
		{
			m_RoleIcon_1.removeMovieClip();
		}
		attachMovie(roleIcon, "m_RoleIcon_1", getNextHighestDepth());
		m_RoleIcon_1._x = m_RoleName_1._x - m_RoleIcon_1._width - 5;
		m_RoleIcon_1._y = m_RoleName_1._y
		
		*/
		for (var i:Number = 0; i < 2; i++)
		{
			this["m_WeaponName_" + i].text = LDBFormat.LDBGetText("WeaponTypeGUI", weaponRequirements[i]);
			var weaponClip:MovieClip = this["m_Weapon_" + i];
			if (weaponClip.i_WeaponRequirement != undefined)
			{
				weaponClip.i_WeaponRequirement.removeMovieClip();
			}
			TooltipUtils.CreateWeaponRequirementsIcon(weaponClip, weaponRequirements[i], {_xscale:23,_yscale:23,_x:1,_y:1});
		}
		
		var canEquip:Boolean = false;
		for (var i:Number = 0; i < 6; i++)
		{
			var featData:FeatData = FeatInterface.m_FeatList[skillTemplate.m_ActiveAbilities[i]];
			this["m_Active_" + i].SetData(featData);
			if (featData.m_Trained)
			{
				canEquip = true;
			}
		}
		
		for (var i:Number = 0; i < 5; i++)
		{
			var featData:FeatData = FeatInterface.m_FeatList[skillTemplate.m_PassiveAbilities[i]]; 
			this["m_Passive_" + i].SetData(featData);
			if (featData.m_Trained)
			{
				canEquip = true;
			}
		}
		
		if (Lore.IsLocked(skillTemplate.m_Achievement))
		{			
			var deckClaimable:String = LDBFormat.LDBGetText("SkillhiveGUI", "DeckClaimableTooltip");
			var tooltipText:String = LDBFormat.Printf(deckClaimable, selectedDeckName);
			
			TooltipUtils.AddTextTooltip(m_ClaimButton, tooltipText, 130, TooltipInterface.e_OrientationHorizontal,  true);
			m_ClaimButton._visible = true;
		}
		else
		{
			m_ClaimButton._visible = false;
		}
		
		m_EquipButton.disabled = !canEquip;
        m_ClaimButton.disabled = !SkillHiveFeatHelper.DeckIsComplete(skillTemplate);
	}
	
	private function SlotSelectDeck(event:Object):Void
	{
		UpdateSelectedDeck(event.index);
	}
	
	//On Click Claim
    private function OnClickClaim():Void
    {
        var template:SkillTemplate = m_TemplateData[m_DeckScrollingList.selectedIndex].m_Template;
        
        if (template != undefined)
        {
            SkillWheel.ClaimDeck(template.m_Id);
        }
		Selection.setFocus(null);
    }
    
    //On Click Equip
    private function OnClickEquip():Void
    {
        var template:SkillTemplate = m_TemplateData[m_DeckScrollingList.selectedIndex].m_Template;
        
        if (template != undefined)
        {
            if (template.m_PassiveAbilities != undefined)
            {
                for (var i:Number = 0; i < template.m_PassiveAbilities.length; i++)
                {
                    var featData:FeatData = FeatInterface.m_FeatList[template.m_PassiveAbilities[i]];
                    if (featData != undefined)
                    {
                        if (featData.m_Trained)
                        {
                            Spell.EquipPassiveAbility(i, featData.m_Spell);
                        }
                    }
                }
            }
            
            if (template.m_ActiveAbilities != undefined)
            {
                for (var i:Number = 0; i < template.m_ActiveAbilities.length; i++)
                {
                    var featData:FeatData = FeatInterface.m_FeatList[template.m_ActiveAbilities[i]];
                    
                    if (featData != undefined)
                    {
                        if (featData.m_Trained)
                        {
                            Shortcut.AddSpell(_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + i, featData.m_Spell);
                        }
                    }                    
                }
            }
        }
		Selection.setFocus(null);
    }
	
	private function GetWeaponRequirements(template:SkillTemplate)
	{
		var weaponRequirements = new Array();
		if (template.m_ActiveAbilities != undefined)
		{
			for (var i:Number = 0; i < 7; i++)
			{
				var featData:FeatData = FeatInterface.m_FeatList[template.m_ActiveAbilities[i]];                    
				if (featData != undefined)
				{                      
					var weaponRequirement:Number = ProjectSpell.GetWeaponRequirement(featData.m_Spell);
					var addRequirement = true;                        
					for (var j = 0; j < weaponRequirements.length; j++)
					{
						if (weaponRequirements[j] == weaponRequirement)
						{
							addRequirement = false;
						}
					}
					
					if (addRequirement)
					{
						weaponRequirements.push(weaponRequirement);
					}                        
				}
			}
		}
		return weaponRequirements;
	}
	
	private function SlotFeatTrained()
	{
		UpdateSelectedDeck(m_DeckScrollingList.selectedIndex);
	}
	
	//Slot Tag Added
	function SlotTagAdded(tagId:Number):Void
	{
		var currTemplate:SkillTemplate = m_TemplateData[m_DeckScrollingList.selectedIndex].m_Template;
		if (currTemplate.m_Achievement == tagId)
		{
			m_ClaimButton._visible = false;
		}
	}
	
	public function OnModuleActivated(config:Archive):Void
	{
		//Intentionally left empty. SkillHiveSimpleWindow will attempt to call this, but we have nothing to do here.
	}

	public function OnModuleDeactivated()
	{
		var archive:Archive = new Archive();
		return archive;
	}
}