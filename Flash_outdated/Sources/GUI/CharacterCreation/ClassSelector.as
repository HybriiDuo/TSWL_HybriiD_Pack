import mx.utils.Delegate;
import gfx.core.UIComponent;
import gfx.controls.ButtonGroup;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.CharacterCreation.CameraController;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.*;
import com.GameInterface.SkillWheel.SkillTemplate;
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.ProjectSpell;
import com.GameInterface.DistributedValue;

dynamic class GUI.CharacterCreation.ClassSelector extends UIComponent
{
	//PROPERTIES created in flash editor
	private var m_Title:MovieClip;
	private var m_BackButton:MovieClip;
	private var m_ForwardButton:MovieClip;
	private var m_NavigationBar:MovieClip;
	private var m_ClassSelectBox:MovieClip;
	private var m_ClassDescBox:MovieClip;
	private var m_HelpIcon:MovieClip;
	
	//VARIABLES
	public var SignalBack:com.Utils.Signal;
    public var SignalForward:com.Utils.Signal;    
    private var m_CameraController:CameraController;
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
	private var m_SelectedClassId;
	
	//STATICS
	private static var MAX_DIFFICULTY:Number = 5;
	
	public function ClassSelector()
    {
        SignalBack = new com.Utils.Signal;
        SignalForward = new com.Utils.Signal;
    }

	private function configUI()
    {		
		m_BackButton.m_BackwardArrow._alpha = 100;
		m_ForwardButton.m_ForwardArrow._alpha = 100;
		m_BackButton.SignalButtonSelected.Connect(BackToOutfitSelector, this);
		m_ForwardButton.SignalButtonSelected.Connect(GoForward, this);
		
		m_ClassSelectBox.SignalClassSelected.Connect(ClassSelected, this);
		m_ClassSelectBox.SetCharacterCreationIF(m_CharacterCreationIF);
		
		m_ClassDescBox._alpha = 0;
		m_ForwardButton.disabled = true;
        m_ForwardButton.m_ForwardArrow._alpha = 50;
		
		SetLabels();
		LayoutHandler();
    }
	
	private function ClassSelected(classId:Number, skillTemplate:SkillTemplate, primaryRole:Number, secondaryRole:Number, difficulty:Number)
	{
		m_SelectedClassId = classId;
		m_ClassDescBox.m_ClassHeader.text = LDBFormat.LDBGetText("SkillhiveGUI", skillTemplate.m_Id);
		m_ClassDescBox.m_ClassDesc.text = LDBFormat.LDBGetText("SkillhiveGUI", skillTemplate.m_Description);
		var weaponRequirements:Array = GetWeaponRequirements(skillTemplate);
		
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
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleHealer");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleHealerDesc");
				roleIcon = "HealerIcon";
				break;
			default:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamage");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamageDesc");
				roleIcon = "DPSIcon";				
		}
		m_ClassDescBox.m_RoleName_0.text = roleName;
		m_ClassDescBox.m_RoleDesc_0.text = roleDesc;
		if (m_ClassDescBox.m_RoleIcon_0 != undefined)
		{
			m_ClassDescBox.m_RoleIcon_0.removeMovieClip();
		}
		m_ClassDescBox.attachMovie(roleIcon, "m_RoleIcon_0", m_ClassDescBox.getNextHighestDepth());
		m_ClassDescBox.m_RoleIcon_0._x = m_ClassDescBox.m_RoleName_0._x - m_ClassDescBox.m_RoleIcon_0._width - 5;
		m_ClassDescBox.m_RoleIcon_0._y = m_ClassDescBox.m_RoleName_0._y
		
		//We don't have secondary roles anymore.
		/*
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
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleHealer");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleHealerDesc");
				roleIcon = "HealerIcon";
				break;
			default:
				roleName = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamage");
				roleDesc = LDBFormat.LDBGetText("CharCreationGUI", "RoleDamageDesc");
				roleIcon = "DPSIcon";				
		}
		m_ClassDescBox.m_RoleName_1.text = roleName;
		m_ClassDescBox.m_RoleDesc_1.text = roleDesc;
		if (m_ClassDescBox.m_RoleIcon_1 != undefined)
		{
			m_ClassDescBox.m_RoleIcon_1.removeMovieClip();
		}
		m_ClassDescBox.attachMovie(roleIcon, "m_RoleIcon_1", m_ClassDescBox.getNextHighestDepth());
		m_ClassDescBox.m_RoleIcon_1._x = m_ClassDescBox.m_RoleName_1._x - m_ClassDescBox.m_RoleIcon_1._width - 5;
		m_ClassDescBox.m_RoleIcon_1._y = m_ClassDescBox.m_RoleName_1._y
		
		m_ClassDescBox.m_RoleName_1._visible = secondaryRole != primaryRole;
		m_ClassDescBox.m_RoleDesc_1._visible = secondaryRole != primaryRole;
		m_ClassDescBox.m_RoleIcon_1._visible = secondaryRole != primaryRole;
		*/
		
		m_ClassDescBox.m_WeaponName_0.text = LDBFormat.LDBGetText( "CharCreationGUI", "PrimaryWeapon" );
		m_ClassDescBox.m_WeaponName_1.text = LDBFormat.LDBGetText( "CharCreationGUI", "SecondaryWeapon" );
		
		for (var i:Number = 0; i < MAX_DIFFICULTY; i++)
		{
			if (i < difficulty)
			{
				m_ClassDescBox["m_Skull_"+i]._alpha = 100;
			}
			else
			{
				m_ClassDescBox["m_Skull_"+i]._alpha = 30;
			}
		}
		
		for (var i:Number = 0; i < 2; i++)
		{
			m_ClassDescBox["m_WeaponName_" + i].text += " - " + LDBFormat.LDBGetText("WeaponTypeGUI", weaponRequirements[i]);
			m_ClassDescBox["m_WeaponDesc_" + i].text = LDBFormat.LDBGetText("CharCreationGUI", "WeaponDesc_" + weaponRequirements[i]);
			var weaponClip:MovieClip = m_ClassDescBox["m_Weapon_" + i];
			if (weaponClip.i_WeaponRequirement != undefined)
			{
				weaponClip.i_WeaponRequirement.removeMovieClip();
			}
			TooltipUtils.CreateWeaponRequirementsIcon(weaponClip, weaponRequirements[i], {_xscale:23,_yscale:23,_x:1,_y:1});
			
			var featData:FeatData = FeatInterface.m_FeatList[skillTemplate.m_ActiveAbilities[i]]; 
			m_ClassDescBox["m_PreviewAbility_" + i].SetFeatData(featData);
			m_ClassDescBox["m_PreviewAbilityName_" + i].text = featData.m_Name;
			//Force advanced tooltips off, even if it is on
			var advanced:Boolean = DistributedValue.GetDValue("ShowAdvancedTooltips"); 
			if (advanced)
			{
				DistributedValue.SetDValue("ShowAdvancedTooltips", false);
			}
			var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( featData.m_Spell, 0 );
			//Turn advanced tooltips back on if it was on before
			if (advanced)
			{
				DistributedValue.SetDValue("ShowAdvancedTooltips", true);
			}
			m_ClassDescBox["m_PreviewAbilityDesc_" + i].text = tooltipData.m_Descriptions[0];	
		}
		if (m_ClassDescBox._alpha < 1)
		{
			m_ClassDescBox.tweenTo(0.3, {_alpha:100}, None.easeNone);
		}
		m_CharacterCreationIF.SetStartingClass(classId);
		m_ForwardButton.disabled = false;
        m_ForwardButton.m_ForwardArrow._alpha = 100;
	}
	
	private function GetWeaponRequirements(template:SkillTemplate)
	{
		var weaponRequirements = new Array();
		if (template.m_ActiveAbilities != undefined)
		{
			for (var j:Number = 0; j < 7; j++)
			{
				var featData:FeatData = FeatInterface.m_FeatList[template.m_ActiveAbilities[j]];                    
				if (featData != undefined)
				{                        
					var weaponRequirement:Number = ProjectSpell.GetWeaponRequirement(featData.m_Spell);
					var addRequirement = true;                        
					for (var k = 0; k < weaponRequirements.length; k++)
					{
						if (weaponRequirements[k] == weaponRequirement)
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
	
	private function SetLabels()
	{
		m_Title.text = LDBFormat.LDBGetText( "CharCreationGUI", "ClassSelector_ScreenTitle" );
		m_BackButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "SelectClothing" );
		m_ForwardButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "CreateName" );
		m_ClassDescBox.m_WeaponHeader.text = LDBFormat.LDBGetText( "CharCreationGUI", "WeaponsHeader" );
		m_ClassDescBox.m_RoleHeader.text = LDBFormat.LDBGetText( "CharCreationGUI", "RoleHeader" );
		m_ClassDescBox.m_AbilitiesHeader.text = LDBFormat.LDBGetText( "CharCreationGUI", "AbilitiesHeader" );
		m_ClassDescBox.m_DifficultyHeader.text = LDBFormat.LDBGetText( "CharCreationGUI", "DifficultyHeader" );
		TooltipUtils.AddTextTooltip( m_HelpIcon, LDBFormat.LDBGetText( "CharCreationGUI", "MouseNavigationInfo" ), 250, TooltipInterface.e_OrientationHorizontal,  true, false);
	}
	
	public function LayoutHandler()
	{
		w = Stage.width;
		h = Stage.height;
		
		m_Title._x = (w / 2) - (m_Title._width / 2);
		m_Title._y = 20;
		
		m_HelpIcon._x = Stage.width - m_HelpIcon._width - 20;
        m_HelpIcon._y = 20;
		
		m_ClassSelectBox._x = Stage.width/2 - Stage.width/4 - m_ClassSelectBox._width/2 - 50;
		m_ClassSelectBox._y = Stage.height/2 - m_ClassSelectBox._height/2;
		m_ClassDescBox._x = Stage.width/2 + Stage.width/4 - m_ClassDescBox._width/2 + 50;
		m_ClassDescBox._y = Stage.height/2 - m_ClassDescBox._height/2;
		
		m_NavigationBar._x  = 0;
		m_NavigationBar._y = h - m_NavigationBar._height;
		m_NavigationBar._width = w;
		m_BackButton._x = 10;
		m_BackButton._y = h - (m_NavigationBar._height / 2) - (m_BackButton._height/2) + 5;
		m_ForwardButton._y = m_BackButton._y;
		m_ForwardButton._x = w - m_ForwardButton._width - 10;
	}
	
	private function BackToOutfitSelector()
	{
		m_CharacterCreationIF.UnWearClassGear(m_CharacterCreationIF.GetStartingClass());
		this.SignalBack.Emit();
	}
	
	private function GoForward()
	{
		this.SignalForward.Emit();
	}
}