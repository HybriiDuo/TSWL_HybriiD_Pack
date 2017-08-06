import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;

class com.Components.WeaponStatuses.ElementalWeaponStatus extends UIComponent
{	
	private var m_Slider:MovieClip;
	private var m_Bar:MovieClip;
	private var m_OverheatAnim:MovieClip;
	private var m_CooldownAnim:MovieClip;
	private var m_OverheatTriAnim:MovieClip;
	private var m_CooldownTriAnim:MovieClip;
	
	private var m_Character:Character;
	private var m_CurrentCount:Number;
	private var m_FlashInterval:Number;
	private var m_CooldownTimeout:Number;
	private var m_Overheated:Boolean;
	
	private static var COUNTER_BUFF:Number = 9258485;
	private static var OVERHEAT_BUFF:Number = 9260877;
	private static var MAX_COUNT:Number = 100;
	private static var WARNING_PERCENT:Number = 0.85;
	
	public function ElementalWeaponStatus()
	{
		super();
		m_CurrentCount = 0;
	}
	
	private function configUI()
	{
		m_OverheatAnim._visible = false;
		m_OverheatAnim.gotoAndStop(0);
		m_CooldownAnim._visible = false;
		m_CooldownAnim.gotoAndStop(0);
		m_OverheatTriAnim._visible = false;
		m_OverheatTriAnim.gotoAndStop(0);
		m_CooldownTriAnim._visible = false;
		m_CooldownTriAnim.gotoAndStop(0);
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff, this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff, this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff, this);
		
		UpdateBuff(COUNTER_BUFF);
	}
	
	private function onUnload()
	{
		if (m_Character != undefined)
		{
			m_Character.SignalInvisibleBuffAdded.Disconnect(UpdateBuff, this);
			m_Character.SignalBuffRemoved.Disconnect(UpdateBuff, this);
			m_Character.SignalInvisibleBuffUpdated.Disconnect(UpdateBuff, this);
		}
		if (m_FlashInterval != undefined)
		{
			clearInterval(m_FlashInterval);
			m_FlashInterval = undefined;
		}
		if (m_CooldownTimeout != undefined)
		{
			_global.clearTimeout(m_CooldownTimeout);
			m_CooldownTimeout = undefined;
		}
	}
	
	private function UpdateBuff(buffId:Number)
	{
		if (buffId != COUNTER_BUFF && buffId != OVERHEAT_BUFF)
		{
			return;
		}
		
		//Overheating
		if (m_Character.m_InvisibleBuffList[OVERHEAT_BUFF] != undefined)
		{
			if (!m_Overheated)
			{
				m_Overheated = true;
				m_OverheatAnim._visible = true;
				m_OverheatAnim.gotoAndPlay(1);
				m_OverheatTriAnim._visible = true;
				m_OverheatTriAnim.gotoAndPlay(1);
				m_CooldownTimeout = _global.setTimeout( Delegate.create(this, AttachCooldown), 1000);
			}
		}
		else
		{
			//We are finished overheating, remove the cooldown and set the color back to white
			if (m_Overheated)
			{
				m_Overheated = false;
				m_OverheatAnim._visible = false;
				m_OverheatAnim.gotoAndStop(1);
				m_OverheatTriAnim._visible = false;
				m_OverheatTriAnim.gotoAndStop(1);
				m_CooldownTriAnim._visible = false;
				m_CooldownTriAnim.gotoAndStop(1);
				m_CooldownAnim._visible = true;
				m_CooldownAnim.gotoAndPlay(1);
			}
		}
		
		//Count
		if (m_Character.m_InvisibleBuffList[COUNTER_BUFF] != undefined)
		{
			if (m_Character.m_InvisibleBuffList[COUNTER_BUFF].m_Count == m_CurrentCount)
			{
				return;
			}
			else
			{
				m_CurrentCount = m_Character.m_InvisibleBuffList[COUNTER_BUFF].m_Count;
			}
		}
		else 
		{
			m_CurrentCount = 0;
		}
		
		//Set the slider's position
		m_Slider.m_CountText.text = m_CurrentCount;
		var decimalPercent:Number = m_CurrentCount / MAX_COUNT;
		var sliderPos:Number = (m_Bar._width - m_Slider.m_Background._width) * decimalPercent;
		m_Slider.tweenEnd(false);
		m_Slider.tweenTo(0.3, {_x:sliderPos}, None.easeNone);
		
		//If the slider's position is above the warning threshold, trigger the warnings
		if (decimalPercent >= WARNING_PERCENT)
		{
			if (m_FlashInterval == undefined)
			{
				Colors.ApplyColor(m_Slider.m_Background.m_Fill, 0x000000);
				m_Slider.m_CountText._visible = false;
				m_FlashInterval = setInterval(Delegate.create(this, FlashWarning), 100);				
			}
		}
		//Stop any running warnings if we are below the warning threshold. 
		else
		{
			if (m_FlashInterval != undefined)
			{
				Colors.ApplyColor(m_Slider.m_Background.m_Fill, 0xFFFFFF);
				clearInterval(m_FlashInterval);
				m_FlashInterval = undefined;
				m_Slider.m_CountText._visible = true;
			}
		}
	}
	
	private function AttachCooldown()
	{	
		if (m_Overheated)
		{
			m_OverheatTriAnim._visible = false;
			m_OverheatTriAnim.gotoAndStop(1);
			m_CooldownTriAnim._visible = true;
			m_CooldownTriAnim.gotoAndPlay(1);
		}
		_global.clearTimeout(m_CooldownTimeout);
		m_CooldownTimeout = undefined;
	}
	
	private function FlashWarning()
	{
		m_Slider.m_Background.m_Warning._visible = !m_Slider.m_Background.m_Warning._visible;
	}
}