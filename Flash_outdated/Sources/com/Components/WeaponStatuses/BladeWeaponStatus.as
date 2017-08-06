import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.utils.Delegate;
import mx.transitions.easing.*;

class com.Components.WeaponStatuses.BladeWeaponStatus extends UIComponent
{
	private var m_Hilt:MovieClip;
	private var m_ReadyGlow:MovieClip;
	private var m_HealAnim:MovieClip;
	private var m_Blade:MovieClip;
	private var m_Mask1:MovieClip;
	private var m_Progress1:MovieClip;
	private var m_Mask2:MovieClip;
	private var m_Progress2:MovieClip;
	
	private var m_Character:Character;
	private var m_MaxDuration:Number;
	private var m_CurrentCount:Number;
	private var m_CurrentlyActive:Boolean;
	private var m_IntervalId:Number;
	private var m_PlaySound:Boolean;
	
	private static var ACTIVE_BUFF:Number = 7631134;
	private static var COUNTER_BUFF:Number = 9253321;
	private static var HEAL_BUFF:Number = 9255856;
	private static var MAX_COUNT = 5;
	
	public function BladeWeaponStatus()
	{
		super();
		m_Progress1.setMask(m_Mask1);
		m_Progress2.setMask(m_Mask2);
		m_ReadyGlow._visible = false;
		m_ReadyGlow.stop();
		m_HealAnim._visible = false;
		m_HealAnim.stop();
		for (var i:Number = 0; i < MAX_COUNT; i++)
		{
			this["Pip_" + i]._visible = false;			
		}
		m_Progress1._width = 0;
		m_Progress2._width = 0;
		m_CurrentlyActive = false;
		m_CurrentCount = 0;
	}
	
	private function configUI()
	{
		m_PlaySound = false;
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff, this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff, this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff, this);
		m_Character.SignalBuffAdded.Connect(UpdateVisibleBuff, this);
		UpdateBuff(COUNTER_BUFF);
		m_PlaySound = true;
	}
	
	private function onUnload()
	{
		if (m_Character != undefined)
		{
			m_Character.SignalInvisibleBuffAdded.Disconnect(UpdateBuff, this);
			m_Character.SignalBuffRemoved.Disconnect(UpdateBuff, this);
			m_Character.SignalInvisibleBuffUpdated.Disconnect(UpdateBuff, this);
			m_Character.SignalBuffAdded.Connect(UpdateVisibleBuff, this);
		}
		if (m_IntervalId != undefined)
		{
			clearInterval( m_IntervalId );
			m_IntervalId = undefined;
		}
	}
	
	private function UpdateBuff(buffId:Number)
	{
		if (buffId != COUNTER_BUFF && buffId != ACTIVE_BUFF && buffId != HEAL_BUFF)
		{
			return;
		}
		var counterBuff:BuffData = m_Character.m_InvisibleBuffList[COUNTER_BUFF];
		var activeBuff:BuffData = m_Character.m_InvisibleBuffList[ACTIVE_BUFF];
		var healBuff:BuffData = m_Character.m_BuffList[HEAL_BUFF];
		
		if (healBuff == undefined)
		{
			m_HealAnim._visible = false;
			m_HealAnim.stop();
		}
		
		if(counterBuff != undefined)
		{
			var updateCount:Number = counterBuff.m_Count;
			//increasing
			if (updateCount > m_CurrentCount)
			{
				for (var i:Number = m_CurrentCount; i < updateCount; i++)
				{
					this["Pip_" + i]._visible = true;
					this["Pip_" + i].gotoAndPlay("Activate");
				}
			}
			//decreasing
			else if (updateCount < m_CurrentCount)
			{
				for (var i:Number = updateCount; i < m_CurrentCount; i++)
				{
					this["Pip_" + i]._visible = false;			
				}
			}
			if (updateCount == MAX_COUNT && !m_CurrentlyActive)
			{
				var hiltReady:MovieClip = this.attachMovie("HiltFull", "m_HiltFill", this.getNextHighestDepth());
				hiltReady._y = m_Hilt._y;
				m_ReadyGlow._visible = true;
				m_ReadyGlow.gotoAndPlay(1);
				m_Blade.gotoAndPlay("Ready");
				if (m_PlaySound)
				{
					m_Character.AddEffectPackage( "sound_fxpackage_GUI_soul_blade_ready.xml" );
				}
			}
			else
			{
				m_ReadyGlow._visible = false;
				m_ReadyGlow.stop();
				if (!m_CurrentlyActive)
				{
					m_Blade.gotoAndStop("Broken");
				}
			}
			m_CurrentCount = updateCount;
		}
		else
		{
			for (var i:Number = 0; i < MAX_COUNT; i++)
			{
				this["Pip_" + i]._visible = false;		
			}
			m_ReadyGlow._visible = false;
			m_ReadyGlow.stop();
			if (!m_CurrentlyActive)
			{
				m_Blade.gotoAndStop("Broken");
			}
			m_CurrentCount = 0;
		}
		
		if (activeBuff != undefined)
		{
			if (!m_CurrentlyActive)
			{
				SetActive(true);
			}
		}
		else
		{
			if (m_CurrentlyActive)
			{
				SetActive(false);
			}
		}
	}
	
	private function UpdateVisibleBuff(buffId:Number)
	{
		if (buffId == HEAL_BUFF)
		{
			m_HealAnim._visible = true;
			m_HealAnim.gotoAndPlay(1);
		}
	}
	
	private function SetActive(active:Boolean)
	{
		m_CurrentlyActive = active;
		if (active)
		{
			m_ReadyGlow._visible = false;
			m_ReadyGlow.stop();
			m_Blade.gotoAndPlay("Repair");
			
			var time:Number = com.GameInterface.Utils.GetNormalTime() * 1000;
			m_MaxDuration = m_Character.m_InvisibleBuffList[ACTIVE_BUFF].m_TotalTime - time;
			m_IntervalId = setInterval( Delegate.create(this, UpdateTimer), 50);
			
		}
		else
		{
			if (m_CurrentCount == MAX_COUNT)
			{
				m_ReadyGlow._visible = true;
				m_ReadyGlow.gotoAndPlay(1);
			}
			m_Blade.gotoAndPlay("Break");
			
			m_Progress1._width = 0;
			m_Progress2._width = 0;
			if (m_IntervalId != undefined)
			{
				clearInterval(m_IntervalId);
				m_IntervalId = undefined;
			}
		}
	}
	
	private function UpdateTimer()
	{
		var time:Number = com.GameInterface.Utils.GetNormalTime() * 1000;
		var timeLeft:Number = m_Character.m_InvisibleBuffList[ACTIVE_BUFF].m_TotalTime - time;
		var lowPercent:Number = (timeLeft / m_MaxDuration) * 100;
		var highPercent:Number = 0;
		if (lowPercent > 100)
		{
			highPercent = Math.min(100, lowPercent - 100);
			lowPercent = 100;
		}
		m_Progress1._width = m_Mask1._width * (lowPercent/100);
		m_Progress2._width = m_Mask2._width * (highPercent/100);
		
		if (timeLeft <= 0)
		{
			clearInterval(m_IntervalId);
			m_IntervalId = undefined;
		}
	}
}