import gfx.core.UIComponent;
import gfx.controls.ButtonGroup;
import gfx.controls.Button;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.SkillWheel.SkillWheel;
import com.GameInterface.SkillWheel.SkillTemplate;
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.ProjectSpell;
import com.GameInterface.CharacterCreation.CharacterCreation;
import com.GameInterface.CharacterCreation.ClassData;

dynamic class GUI.CharacterCreation.ClassSelectBox extends UIComponent
{  
	//PROPERTIES
	private var m_Header:TextField;
	private var m_ClassButton_0:Button;
	private var m_ClassButton_1:Button;
	private var m_ClassButton_2:Button;
	private var m_ClassButton_3:Button;
	private var m_ClassButton_4:Button;
	private var m_ClassButton_5:Button;
	private var m_ClassButton_6:Button;
	private var m_ClassButton_7:Button;
	private var m_ClassButton_8:Button;
	
	//VARIABLES
	private var m_TemplateData:Array;
	private var m_SelectedClass:Number;
	private var SignalClassSelected:Signal;
	private var m_CharacterCreationIF:CharacterCreation;
	private var m_Initialized:Boolean;
	private var m_ClassButtonGroup:ButtonGroup;
	
	//STATICS
	private var NUM_CLASSES:Number = 9;
	private var NO_CLASS:Number = -1;
	
	public function ClassSelectBox()
    {
		SignalClassSelected = new Signal();
	}
	
	private function configUI()
	{
		//We have to combine the class data with the deck templates since both contain info we need
		var classList = CharacterCreation.GetStartingClassData();
		var templates:Array = SkillWheel.m_FactionSkillTemplates["1"];
		
		//m_TemplateData will hold the combined info
		m_TemplateData = new Array();
		for (var i:Number = 0; i < classList.length; i++)
        {
			var templateListItem:Object = new Object();
            templateListItem.label = LDBFormat.LDBGetText("SkillhiveGUI", classList[i].m_DeckId);
			templateListItem.m_Id = classList[i].m_Id;
			templateListItem.m_PrimaryRole = classList[i].m_PrimaryRole;
			templateListItem.m_SecondaryRole = classList[i].m_SecondaryRole;
			templateListItem.m_Difficulty = classList[i].m_Difficulty;
			for (var j:Number = 0; j < templates.length; j++)
			{
				//Check if this template matches the deck ID for the class
				if (templates[j].m_Id == classList[i].m_DeckId)
				{
					templateListItem.m_Template = templates[j];
					break;
				}
			}
            m_TemplateData.push(templateListItem);
        }
		
		FillClassButtons();
		SetLabels();
		
		m_ClassButtonGroup = new ButtonGroup("classButtons");
		for (var i:Number = 0; i < NUM_CLASSES; i++)
		{
			var classButton:Button = this["m_ClassButton_"+i];
			classButton.toggle = true;
			classButton.group = m_ClassButtonGroup;
			classButton.disableFocus = true;
		}
		
		m_ClassButtonGroup.addEventListener("change", this, "SelectedClassChanged");		
		
		m_Initialized = true;
		if (m_CharacterCreationIF != undefined)
		{
			//0 is no class selected
			if (m_CharacterCreationIF.GetStartingClass() != NO_CLASS)
			{
				m_ClassButtonGroup.setSelectedButton(this["m_ClassButton_" + m_CharacterCreationIF.GetStartingClass()]);
			}
		}
	}
	
	private function SelectedClassChanged(event:Object)
	{
		for (var i:Number = 0; i < NUM_CLASSES; i++)
		{
			if (event.item == this["m_ClassButton_" + i])
			{
				m_SelectedClass = i;
				SignalClassSelected.Emit(m_TemplateData[m_SelectedClass].m_Id, m_TemplateData[m_SelectedClass].m_Template, m_TemplateData[m_SelectedClass].m_PrimaryRole, m_TemplateData[m_SelectedClass].m_SecondaryRole, m_TemplateData[m_SelectedClass].m_Difficulty);
			}
		}
	}
	
	private function FillClassButtons()
	{
		for (var i:Number = 0; i < NUM_CLASSES; i++)
		{
			var classButton:MovieClip = this["m_ClassButton_" + i];
			var template:SkillTemplate = m_TemplateData[i].m_Template;
			
			classButton.m_Label.text = m_TemplateData[i].label;
			var weaponRequirements:Array = GetWeaponRequirements(template);
			for (var j:Number = 0; j < 2; j++)
            {
				var weaponClip:MovieClip = classButton["m_Weapon_" + j];
				if (weaponRequirements[j] > 0 && TooltipUtils.CreateWeaponRequirementsIcon(weaponClip, weaponRequirements[j], {_xscale:23,_yscale:23,_x:1,_y:1}))
                {
                    TooltipUtils.AddTextTooltip(weaponClip, LDBFormat.LDBGetText("WeaponTypeGUI", weaponRequirements[j]), 0, TooltipInterface.e_OrientationVertical, false);
                    weaponClip._visible = true;
                }
				else
                {
                    weaponClip._visible = false;
                }
			}
		}
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
		m_Header.text = LDBFormat.LDBGetText("CharCreationGUI", "ClassSelector_BoxHeader");
	}
	
	public function SetCharacterCreationIF(characterCreationIF:CharacterCreation)
	{
		m_CharacterCreationIF = characterCreationIF;
		if (m_Initialized)
		{
			//0 is no class selected
			if (m_CharacterCreationIF.GetStartingClass() != NO_CLASS)
			{
				m_ClassButtonGroup.setSelectedButton(this["m_ClassButton_" + m_CharacterCreationIF.GetStartingClass()]);
			}
		}
	}
}