import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;

class com.Components.WeaponStatuses.BloodWeaponStatus extends UIComponent
{	
	private var m_Slider:MovieClip;
	private var m_Bar:MovieClip;
	private var m_NegativePing1:MovieClip;
	private var m_NegativePing2:MovieClip;
	private var m_NegativePing3:MovieClip;
	private var m_PositivePing1:MovieClip;
	private var m_PositivePing2:MovieClip;
	private var m_PositivePing3:MovieClip;
	
	private var m_Character:Character;
	private var m_CurrentCount:Number;
	private var m_LastPercent:Number;
	private var m_CurrentDirection:Number;
	private var m_PlaySound:Boolean;
	
	private static var POSITIVE_COUNTER_BUFF:Number = 9257968;
	private static var NEGATIVE_COUNTER_BUFF:Number = 9257969;
	private static var POSITIVE:Number = 1;
	private static var NEUTRAL:Number = 0;
	private static var NEGATIVE:Number = -1;
	private static var MAX_COUNT = 100;
	private static var LEFT_COLOR = 0x005DF0;
	private static var RIGHT_COLOR = 0xFF2E09;
	
	public function BloodWeaponStatus()
	{
		super();
		m_CurrentCount = 0;
	}
	
	private function configUI()
	{		
		m_PlaySound = false;
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff, this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff, this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff, this);		
		UpdateBuff(POSITIVE_COUNTER_BUFF);
		m_PlaySound = true;
	}
	
	private function onUnload()
	{
		if (m_Character != undefined)
		{
			m_Character.SignalInvisibleBuffAdded.Disconnect(UpdateBuff, this);
			m_Character.SignalBuffRemoved.Disconnect(UpdateBuff, this);
			m_Character.SignalInvisibleBuffUpdated.Disconnect(UpdateBuff, this);	
		}
	}
	
	private function UpdateBuff(buffId:Number)
	{
		if (buffId != POSITIVE_COUNTER_BUFF && buffId != NEGATIVE_COUNTER_BUFF)
		{
			return;
		}
		if (m_Character.m_InvisibleBuffList[POSITIVE_COUNTER_BUFF] != undefined)
		{
			if (m_CurrentDirection == POSITIVE && m_Character.m_InvisibleBuffList[POSITIVE_COUNTER_BUFF].m_Count == m_CurrentCount)
			{
				return;
			}
			else
			{
				m_CurrentCount = m_Character.m_InvisibleBuffList[POSITIVE_COUNTER_BUFF].m_Count;
				m_CurrentDirection = POSITIVE;
			}
		}
		else if (m_Character.m_InvisibleBuffList[NEGATIVE_COUNTER_BUFF] != undefined)
		{
			if (m_CurrentDirection == NEGATIVE && m_Character.m_InvisibleBuffList[NEGATIVE_COUNTER_BUFF].m_Count == m_CurrentCount)
			{
				return;
			}
			else
			{
				m_CurrentCount = m_Character.m_InvisibleBuffList[NEGATIVE_COUNTER_BUFF].m_Count;
				m_CurrentDirection = NEGATIVE;
			}
		}
		else 
		{
			m_CurrentCount = 0;
			m_CurrentDirection = NEUTRAL;
		}
		var decimalPercent:Number = 0.5;
		if (m_CurrentDirection == POSITIVE)
		{
			//buff counter / max count to get percentage, / 2 because it's half the bar
			//add 0.5 to offset by the first half the bar
			decimalPercent = ((m_CurrentCount / MAX_COUNT) / 2) + 0.5;
		}
		else if (m_CurrentDirection == NEGATIVE)
		{
			//0.5 to invert the direction - buff counter / max count to get percentage, / 2 because it's half the bar
			decimalPercent = 0.5 - (m_CurrentCount / MAX_COUNT) / 2;
		}
		m_Slider.gotoAndStop(Math.floor(decimalPercent * 100));
		var sliderPos:Number = m_Bar._x + (m_Bar._width * decimalPercent);
		m_Slider.tweenEnd(false);
		m_Slider.tweenTo(0.3, {_x:sliderPos}, None.easeNone);
		UpdatePings(decimalPercent);
	}
	
	private function UpdatePings(decimalPercent:Number)
	{			
		var splatIcon:String = "";		
		if (decimalPercent <= 0.42)
		{
			if (m_LastPercent > 0.42)
			{
				splatIcon = "-10_Splat";
			}
			if (!m_NegativePing1._visible)
			{
				if (m_PlaySound)
				{
					m_Character.AddEffectPackage( "sound_fxpackage_GUI_blood_threshold_corrupt.xml" );
				}
				m_NegativePing1._visible = true;
				m_NegativePing1.gotoAndPlay(1);
			}
		}
		else
		{
			m_NegativePing1._visible = false;
		}
		if (decimalPercent <= 0.175)
		{
			if (m_LastPercent > 0.175)
			{
				splatIcon = "-60_Splat";
			}
			if (!m_NegativePing2._visible)
			{
				if (m_PlaySound)
				{
					m_Character.AddEffectPackage( "sound_fxpackage_GUI_blood_threshold_corrupt.xml" );
				}
				m_NegativePing2._visible = true;
				m_NegativePing2.gotoAndPlay(1);
			}
		}
		else
		{
			m_NegativePing2._visible = false;
		}
		if (decimalPercent <= 0.02)
		{
			if (m_LastPercent > 0.02)
			{
				splatIcon = "-100_Splat";
			}				
			if (!m_NegativePing3._visible)
			{
				if (m_PlaySound)
				{
					m_Character.AddEffectPackage( "sound_fxpackage_GUI_blood_threshold_corrupt.xml" );
				}
				m_NegativePing3._visible = true;
				m_NegativePing3.gotoAndPlay(1);
			}
		}
		else
		{
			m_NegativePing3._visible = false;
		}
		if (decimalPercent >= 0.58)
		{
			if (m_LastPercent < 0.58)
			{
				splatIcon = "10_Splat";
			}
			if (!m_PositivePing1._visible)
			{
				if (m_PlaySound)
				{
					m_Character.AddEffectPackage( "sound_fxpackage_GUI_blood_threshold_purity.xml" );
				}
				m_PositivePing1._visible = true;
				m_PositivePing1.gotoAndPlay(1);
			}
		}
		else
		{
			m_PositivePing1._visible = false;
		}
		if (decimalPercent >= 0.825)
		{
			if (m_LastPercent < 0.825)
			{
				splatIcon = "60_Splat";
			}
			if (!m_PositivePing2._visible)
			{
				if (m_PlaySound)
				{
					m_Character.AddEffectPackage( "sound_fxpackage_GUI_blood_threshold_purity.xml" );
				}
				m_PositivePing2._visible = true;
				m_PositivePing2.gotoAndPlay(1);
			}
		}
		else
		{
			m_PositivePing2._visible = false;
		}
		if (decimalPercent >= 0.98)
		{
			if (m_LastPercent < 0.98)
			{
				splatIcon = "100_Splat";
			}				
			if (!m_PositivePing3._visible)
			{
				if (m_PlaySound)
				{
					m_Character.AddEffectPackage( "sound_fxpackage_GUI_blood_threshold_purity.xml" );
				}
				m_PositivePing3._visible = true;
				m_PositivePing3.gotoAndPlay(1);
			}
		}
		else
		{
			m_PositivePing3._visible = false;
		}
		if (splatIcon != "")
		{
			var splat:MovieClip = m_Slider.attachMovie(splatIcon, "m_Splat", m_Slider.getNextHighestDepth());
			splat.tweenTo(0.3, {_alpha: 0}, None.easeNone);
			splat.onTweenComplete = function()
			{
				this.removeMovieClip();
				this = undefined;
			}
		}
		m_LastPercent = decimalPercent;
	}
}