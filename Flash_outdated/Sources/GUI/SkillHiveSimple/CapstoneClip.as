import gfx.core.UIComponent;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.*;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.Utils.DragObject;
import com.Utils.Signal;
import flash.geom.Point;
import mx.utils.Delegate;
import GUI.HUD.AbilityBase;

class GUI.SkillHiveSimple.CapstoneClip extends UIComponent
{
	//Elements created in flash editor
	private var m_Ability:MovieClip;
	
	//Variables
	public var m_FeatData:FeatData;
	private var m_ResourceIconMonitor:DistributedValue; 
	private var m_Tooltip:TooltipInterface;
	private var m_TooltipTimeout:Number;
	public var m_SignalAbilityFocus:Signal;
	
	public function CapstoneClip()
	{
		super();
		m_SignalAbilityFocus = new Signal();
	}

	private function configUI()
	{
		super.configUI();
		m_Ability.m_Frame._visible = false;
		m_Ability.m_EliteFrame._visible = false;
		m_Ability.m_BuilderIcon._visible = false;
		m_Ability.m_ConsumerIcon._visible = false;
		m_Ability.m_Gloss._visible = false;
		m_Ability.m_Background._alpha = 0;
	}
	
	public function SetData(featData:FeatData)
	{
		m_FeatData = featData;
		UpdateAbilityIcon();
	}
	
	private function UpdateAbilityIcon():Void
	{         
        var moviecliploader:MovieClipLoader = new MovieClipLoader();        
        var iconString:String = Utils.CreateResourceString(m_FeatData.m_IconID);
        moviecliploader.loadClip( iconString, m_Ability.m_Content);
        
		//Size the icons
        m_Ability.m_Content._x = 2;
        m_Ability.m_Content._y = 2;
        m_Ability.m_Content._xscale = m_Ability.m_Background._width - 4;
        m_Ability.m_Content._yscale = m_Ability.m_Background._height - 4;
        
		//Background colors
        var iconColor = Colors.GetColorlineColors( m_FeatData.m_ColorLine );
        Colors.ApplyColor( m_Ability.m_Background.highlight, iconColor.highlight);
        Colors.ApplyColor( m_Ability.m_Background.background, iconColor.background);
		
		UpdateFilter();
	}
	
	private function UpdateFilter()
	{
		if (m_FeatData.m_CanTrain || m_FeatData.m_Trained)
		{
			m_Ability._alpha = 100;
		}
		else
		{
			m_Ability._alpha = 33;
		}
	}
	
	private function onRelease() :Void
    {
		m_SignalAbilityFocus.Emit(m_FeatData);
    }
    
    private function onPress() : Void
    {
        if ( m_Tooltip != undefined && Key.isDown( Key.SHIFT ) )
        {
            m_Tooltip.MakeFloating();
        }
    }    
	
	private function StartTooltipTimeout()
	{
		if (m_TooltipTimeout != undefined)
		{
			return;
		}
		var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelay");
		if (delay == 0)
		{
			OpenTooltip();
			return;
		}
		m_TooltipTimeout = _global.setTimeout( Delegate.create( this, OpenTooltip ), delay*1000 );
	}

	private function StopTooltipTimeout()
	{
		if (m_TooltipTimeout != undefined)
		{
			_global.clearTimeout(m_TooltipTimeout);
			m_TooltipTimeout = undefined;
		}
	}
   
    public function CloseTooltip() : Void
    {
		StopTooltipTimeout();
        if ( m_Tooltip != undefined )
        {
            if ( !m_Tooltip.IsFloating() )
            {
                m_Tooltip.Close();
            }
            m_Tooltip = undefined;
        }
    }
	
	public function OpenTooltip() : Void
	{
		StopTooltipTimeout();
		if ( m_Tooltip == undefined )
		{
			var tooltipData:TooltipData = TooltipDataProvider.GetFeatTooltip( m_FeatData.m_Id, false )
			m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_Ability, TooltipInterface.e_OrientationVertical, 0, tooltipData);
		}
	}
	
	private function onRollOver() : Void
	{
		if (!DragObject.GetCurrentDragObject())
		{
			StartTooltipTimeout();
		}
	}
	
	private function onRollOut() : Void
	{
		StopTooltipTimeout();
		if (m_Tooltip != undefined)
		{
			CloseTooltip();
		}
	}
	
	private function onDragOut() : Void
	{
		onRollOut();
	}
	
	private function onUnload() : Void
	{
		CloseTooltip();
	}
	
	private function onMouseMove():Void
	{
		if (m_Tooltip != undefined && !m_Ability.hitTest(_root._xmouse, _root._ymouse))
		{
			onRollOut();
		}
    }
}