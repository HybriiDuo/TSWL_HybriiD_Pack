import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.utils.Delegate;
import mx.transitions.easing.*;

class com.Components.WeaponStatuses.FistWeaponStatus extends UIComponent
{
	private var m_Background:MovieClip;
	private var m_Inactive:MovieClip;
	private var m_DPS:MovieClip;
	private var m_Heal:MovieClip;
	private var m_ActiveMask:MovieClip;
	private var m_InactiveMask:MovieClip;
	private var m_HealBar:MovieClip;
	private var m_DPSBar:MovieClip;
	private var m_InactiveBar:MovieClip;
	private var m_ReadyAnim:MovieClip;

	private var m_Character:Character;
	private var m_State:Number;
	private var m_Ready:Boolean;
	private var m_Full:Boolean;
	private var m_PlaySound:Boolean;

	private static var COUNTER_BUFF:Number = 9267149;
	private static var HEAL_BUFF:Number = 9267176;
	private static var DPS_BUFF:Number = 9267174;

	private static var STATE_INACTIVE:Number = 0;
	private static var STATE_HEAL:Number = 1;
	private static var STATE_DPS:Number = 2;

	private static var MAX_WIDTH:Number = 85;
	private static var STATIC_FRAME:Number = 1;
	private static var ACTIVATE_FRAME:Number = 41;
	private static var DEACTIVATE_FRAME:Number = 50;
	private static var TWEEN_TIME:Number = 0.2;

	public function FistWeaponStatus()
	{
		super();
	}

	private function configUI()
	{
		m_PlaySound = false;
		SetInactive();
		m_ReadyAnim.gotoAndStop(1);
		m_ReadyAnim._visible = false;
		m_Ready = false;
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff,this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff,this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff,this);
		UpdateBuff(COUNTER_BUFF);
		m_PlaySound = true;
	}

	private function onUnload()
	{
		if (m_Character != undefined)
		{
			m_Character.SignalInvisibleBuffAdded.Disconnect(UpdateBuff,this);
			m_Character.SignalBuffRemoved.Disconnect(UpdateBuff,this);
			m_Character.SignalInvisibleBuffUpdated.Disconnect(UpdateBuff,this);
		}
	}

	private function UpdateBuff(buffId:Number)
	{
		if (buffId != COUNTER_BUFF && buffId != HEAL_BUFF && buffId != DPS_BUFF)
		{
			return;
		}

		var healBuff:BuffData = m_Character.m_InvisibleBuffList[HEAL_BUFF];
		var dpsBuff:BuffData = m_Character.m_InvisibleBuffList[DPS_BUFF];
		var counterBuff:BuffData = m_Character.m_InvisibleBuffList[COUNTER_BUFF];

		if (healBuff != undefined && m_State != STATE_HEAL)
		{
			m_State = STATE_HEAL;
			HideBars();
			m_Inactive.gotoAndPlay("activate");
			m_Inactive.onEnterFrame = Delegate.create(this, HealPending);
		}
		else if (dpsBuff != undefined && m_State != STATE_DPS)
		{
			m_State = STATE_DPS;
			HideBars();
			m_Inactive.gotoAndPlay("activate");
			m_Inactive.onEnterFrame = Delegate.create(this, DPSPending);
		}
		else if (healBuff == undefined && dpsBuff == undefined && m_State != STATE_INACTIVE)
		{
			m_State = STATE_INACTIVE;
			HideBars();
			m_DPS._visible = false;
			m_Heal._visible = false;
			m_Inactive._visible = true;
			m_Inactive.gotoAndPlay("deactivate");
			m_Inactive.onEnterFrame = Delegate.create(this, InactivePending);
		}

		if (counterBuff != undefined)
		{
			var decimalCharge:Number = counterBuff.m_Count / counterBuff.m_MaxCounters;
			var newWidth:Number = MAX_WIDTH * decimalCharge;
			var newX:Number = m_Background._width - MAX_WIDTH * decimalCharge
			m_InactiveBar.m_Left.tweenEnd(false)
			m_InactiveBar.m_Left.tweenTo(TWEEN_TIME, {_width:newWidth}, None.easeNone);
			m_InactiveBar.m_Right.tweenTo(TWEEN_TIME, {_width:newWidth, _x:newX}, None.easeNone);
			
			m_HealBar.m_Left.tweenEnd(false)
			m_HealBar.m_Left.tweenTo(TWEEN_TIME, {_width:newWidth}, None.easeNone);
			m_HealBar.m_Right.tweenTo(TWEEN_TIME, {_width:newWidth, _x:newX}, None.easeNone);
			
			m_DPSBar.m_Left.tweenEnd(false)
			m_DPSBar.m_Left.tweenTo(TWEEN_TIME, {_width:newWidth}, None.easeNone);
			m_DPSBar.m_Right.tweenTo(TWEEN_TIME, {_width:newWidth, _x:newX}, None.easeNone);
			
			//Can activate if charge is above this level;
			if (m_State == STATE_INACTIVE)
			{
				if (decimalCharge >= 1)
				{
					if (!m_Full)
					{
						m_Full = true;
						if (m_Inactive._currentframe != ACTIVATE_FRAME)
						{
							HideBars();
							m_ReadyAnim._visible = false;
							m_ReadyAnim.gotoAndStop(1);
							m_Ready = false;
							m_Inactive.gotoAndPlay("activate");
							if (m_PlaySound)
							{
								m_Character.AddEffectPackage( "sound_fxpackage_GUI_fist_general_activate.xml" );
							}
						}
					}
				}
				else
				{
					m_Full = false;
					m_Inactive.gotoAndPlay("deactivate");
				}
				if (decimalCharge >= .6)
				{
					if (!m_Ready)
					{
						m_Ready = true;
						m_ReadyAnim._visible = true;
						m_ReadyAnim.gotoAndPlay(1);
						if (m_PlaySound)
						{
							m_Character.AddEffectPackage( "sound_fxpackage_GUI_fist_general_activate.xml" );
						}
					}
				}
				else
				{
					m_ReadyAnim._visible = false;
					m_ReadyAnim.gotoAndStop(1);
					m_Ready = false;
				}
			}
		}
		else
		{
			m_HealBar.m_Left._width = m_HealBar.m_Right._width = m_DPSBar.m_Left._width = m_DPSBar.m_Right._width = m_InactiveBar.m_Left._width = m_InactiveBar.m_Right._width = 0;
			m_HealBar.m_Right._x = m_DPSBar.m_Right._x = m_InactiveBar.m_Right._x = m_Background._width;
		}
	}

	private function HealPending()
	{
		if (m_Inactive._currentframe == ACTIVATE_FRAME)
		{
			SetHeal();
			m_Inactive.onEnterFrame = function(){};
		}
	}

	private function DPSPending()
	{
		if (m_Inactive._currentframe == ACTIVATE_FRAME)
		{
			SetDPS();
			m_Inactive.onEnterFrame = function(){};
		}
	}

	private function InactivePending()
	{
		if (m_Inactive._currentframe == DEACTIVATE_FRAME)
		{
			SetInactive();
			m_Inactive.onEnterFrame = function(){};
		}
	}

	private function HideBars()
	{
		m_InactiveBar._visible = false;
		m_HealBar._visible = false;
		m_DPSBar._visible = false;
	}

	private function SetInactive()
	{
		m_Inactive._visible = true;
		m_DPS._visible = false;
		m_Heal._visible = false;
		m_HealBar._visible = false;
		m_DPSBar._visible = false;
		m_InactiveBar._visible = true;
		m_InactiveMask._visible = true;
		m_ActiveMask._visible = false;
		m_InactiveBar.setMask(m_InactiveMask);
	}

	private function SetHeal()
	{
		m_Inactive._visible = false;
		m_DPS._visible = false;
		m_Heal._visible = true;
		m_HealBar._visible = true;
		m_DPSBar._visible = false;
		m_InactiveBar._visible = false;
		m_InactiveMask._visible = false;
		m_ActiveMask._visible = true;
		m_Heal.gotoAndPlay(1);
		m_HealBar.setMask(m_ActiveMask);
		m_ReadyAnim._visible = false;
		m_ReadyAnim.gotoAndStop(1);
		m_Ready = false;
	}

	private function SetDPS()
	{
		m_Inactive._visible = false;
		m_DPS._visible = true;
		m_Heal._visible = false;
		m_HealBar._visible = false;
		m_DPSBar._visible = true;
		m_InactiveBar._visible = false;
		m_InactiveMask._visible = false;
		m_ActiveMask._visible = true;
		m_DPS.gotoAndPlay(1);
		m_DPSBar.setMask(m_ActiveMask);
		m_ReadyAnim._visible = false;
		m_ReadyAnim.gotoAndStop(1);
		m_Ready = false;
	}
}