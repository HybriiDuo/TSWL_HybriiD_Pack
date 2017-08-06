import gfx.controls.ListItemRenderer;
import com.Utils.LDBFormat;
import com.GameInterface.SkillWheel.SkillTemplate;
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.ProjectSpell;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipUtils;

class GUI.SkillHiveSimple.DeckSelectorButton extends ListItemRenderer
{
    private var m_Background:MovieClip;
	private var m_Frame:MovieClip;
	private var m_ClassName:TextField;
	private var m_Weapon_0:MovieClip;
	private var m_Weapon_1:MovieClip;
	
	private var m_IsConfigured:Boolean;
    
	public function DeckSelectorButton()
    {
        super();
        m_IsConfigured = false;
    }
	
	private function configUI()
	{
		super.configUI();
        m_IsConfigured = true;
        UpdateVisuals();
	}
		
	public function setData(deckData:Object)
	{
        super.setData(deckData);
        if ( m_IsConfigured )
        {
            UpdateVisuals();
        }
    }

    private function UpdateVisuals()
    {
        if (data == undefined)
		{
			_visible = false;
			return;
		}
        
		_visible = true;
		
		var template:SkillTemplate = data.m_Template;
			
		m_ClassName.text = data.label;
		var weaponRequirements:Array = GetWeaponRequirements(template);
		for (var i:Number = 0; i < 2; i++)
		{
			var weaponClip:MovieClip = this["m_Weapon_" + i];
			if (weaponClip["i_WeaponRequirement"] != undefined)
			{
				weaponClip["i_WeaponRequirement"].removeMovieClip();
			}
			if (weaponRequirements[i] > 0 && TooltipUtils.CreateWeaponRequirementsIcon(weaponClip, weaponRequirements[i], {_xscale:23,_yscale:23,_x:1,_y:1}))
			{
				TooltipUtils.AddTextTooltip(weaponClip, LDBFormat.LDBGetText("WeaponTypeGUI", weaponRequirements[i]), 0, TooltipInterface.e_OrientationVertical, false);
				weaponClip._visible = true;
			}
			else
			{
				weaponClip._visible = false;
			}
		}
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
}