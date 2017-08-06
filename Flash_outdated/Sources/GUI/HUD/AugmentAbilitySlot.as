import GUI.HUD.AbilitySlot;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.*;
import com.GameInterface.Game.Shortcut;
import GUI.HUD.ActiveAbility;

class GUI.HUD.AugmentAbilitySlot extends GUI.HUD.AbilitySlot 
{
	
	private var m_Ability:ActiveAbility;
    
	public function AugmentAbilitySlot(p_mc:MovieClip, p_id:Number)
	{
		super(p_mc, p_id);
        m_DragType = "shortcutbar/augmentability";
	}
        
    private function OnMouseUp() : Void
    {
        m_WasHit = false;
    }
    
    function GetTooltipData():TooltipData
    {
        var tooltipData:TooltipData = TooltipDataProvider.GetShortcutbarTooltip( m_SlotId );
        return tooltipData;
    }
	
	public function SlotItemDroppedOnDesktop()
    {   
		if (Boolean(DistributedValue.GetDValue( "skillhive_window" )))
        {
            Shortcut.RemoveAugment( m_SlotId );
        }  
    }
	
    public function UpdateAbilityFlags( enabled:Boolean, flag:Number)
    {
        if (enabled)
        {
            m_Ability.MergeFlags( flag );
        }
        else
        {
            m_Ability.ClearFlags( flag );
        }
    }
}