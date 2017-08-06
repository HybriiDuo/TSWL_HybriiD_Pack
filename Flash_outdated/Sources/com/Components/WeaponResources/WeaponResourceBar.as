import com.Components.ResourceBase;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;


class com.Components.WeaponResources.WeaponResourceBar extends ResourceBase
{
    private var m_ResourceNumbers:MovieClip;
    private var m_ProgressAnimation:MovieClip;
	private var m_LowEnergyWarning:MovieClip;
    private var m_Bar:MovieClip;
    
    public function WeaponResourceBar()
    {
        super();
        m_ResourceDisplayType = DISPLAY_BAR;
    }
    
    
    public function configUI()
    {
        m_ProgressAnimation._visible = false;
		m_LowEnergyWarning._visible = false;
        m_Bar._xscale = 1;
        m_Bar.onTweenComplete = undefined;        
    }
    
    private function Layout(snap:Boolean)
    {
        m_ResourceNumbers.m_Text.htmlText = "<b>"+m_Amount+"</b>";
        var percentFill:Number = (m_Amount / m_MaxAmount) * 100;
        if (snap)
        {
            m_Bar._xscale = percentFill;
        }
        else
        {
            
            if (m_Amount > m_PreviousAmount)
            {
                if (m_Amount == m_PreviousAmount + 1) // if its a large increase, skip the white flash
                {
                    m_ProgressAnimation._visible = true;
                    m_ProgressAnimation._x = m_Bar._x + m_Bar._width;
                    m_ProgressAnimation.gotoAndPlay(1);
                }
                m_Bar.tweenTo(0.3, { _xscale:percentFill }, None.easeNone );
                m_Bar.onTweenComplete = Delegate.create( this, CleanupAfterAnimation);
            }
            else
            {
                m_Bar.tweenTo(0.3, { _xscale:percentFill }, None.easeNone );
            }
			
			if (m_Amount <= m_MaxAmount/3)
			{
				m_Icon._visible = false;
				m_LowEnergyWarning._visible = true;
				m_LowEnergyWarning.gotoAndPlay(1);
			}
			else
			{
				m_Icon._visible = true;
				m_LowEnergyWarning.stop();
				m_LowEnergyWarning._visible = false;
			}
            
            m_ResourceNumbers._alpha = 0;
            m_ResourceNumbers.tweenTo( 0.3, { _alpha:100 }, None.easeNone);
        }
        m_PreviousAmount = m_Amount;
    }
    
    private function CleanupAfterAnimation()
    {
        m_ProgressAnimation._visible = false;
    }
}