import gfx.core.UIComponent;

import com.Utils.LDBFormat;

import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Skills;

class GUI.CharacterSheet.SkillEntry extends UIComponent
{  
    private var m_SkillName:TextField;
	private var m_SkillValue:TextField;
    
    private var m_Skill:Number;
    
    public function SkillEntry()
    {
        super();
    }
    
    public function SetSkill(skill:Number)
    {
        if (m_Skill)
        {
            ClearSignals();
        }
        
        m_Skill = skill;
        m_SkillName.text = LDBFormat.LDBGetText("SkillTypeNames", m_Skill);
        Skills.SignalSkillUpdated.Connect( SlotSkillUpdated, this );
        Skills.SignalUpdateAllSkills.Connect( SlotForceSkillUpdate, this);
        
        UpdateSkill();
    }
    
    public function ClearSignals():Void
    {
        Skills.SignalSkillUpdated.Disconnect( SlotSkillUpdated, this );
        Skills.SignalUpdateAllSkills.Disconnect( SlotForceSkillUpdate, this);
    }
    
    public function SlotSkillUpdated(skill:Number)
    {
        if (skill == m_Skill)
        {
            UpdateSkill();
        }
    }
    
    private function SlotForceSkillUpdate():Void
    {
        UpdateSkill();
    }
    
    private function UpdateSkill()
    {
        var tooltipText:String = "";
        switch(m_Skill)
        {
            case _global.Enums.SkillType.e_Skill_PhysicalMitigation:
                tooltipText = LDBFormat.Printf(LDBFormat.LDBGetText("SkillTypeDescriptions", m_Skill), Skills.GetSkill(_global.Enums.SkillType.e_Skill_PhysicalNormalMitigation, 0));
                break;
            default:
                tooltipText = LDBFormat.LDBGetText("SkillTypeDescriptions", m_Skill)
                break;
        }
        TooltipUtils.AddTextTooltip(this, tooltipText, 200, TooltipInterface.e_OrientationHorizontal, true);
        m_SkillValue.text = Skills.GetSkill(m_Skill, 0);

    }
}
