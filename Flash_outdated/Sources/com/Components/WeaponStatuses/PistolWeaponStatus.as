import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;

class com.Components.WeaponStatuses.PistolWeaponStatus extends UIComponent
{	
	private var m_LeftBullets:MovieClip;
	private var m_RightBullets:MovieClip;
	private var m_GrayMatch:MovieClip;
	private var m_BlueMatch:MovieClip;
	private var m_RedMatch:MovieClip;
	private var m_Timer:TextField;

	private var m_Character:Character;
	private var m_IntervalId:Number;
	
	private static var COUNTER_BUFF_LEFT:Number = 9262328;
	private static var COUNTER_BUFF_RIGHT:Number = 9262330;
	private static var LOCKED_BUFF:Number = 9266708;
	
	public function PistolWeaponStatus()
	{
		super();
	}
	
	private function configUI()
	{
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff, this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff, this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff, this);
		
		ClearLock();
		
		UpdateBuff(COUNTER_BUFF_LEFT);
		UpdateBuff(COUNTER_BUFF_RIGHT);
		UpdateBuff(LOCKED_BUFF);
	}
	
	private function onUnload()
	{
		if (m_Character != undefined)
		{
			m_Character.SignalInvisibleBuffAdded.Disconnect(UpdateBuff, this);
			m_Character.SignalBuffRemoved.Disconnect(UpdateBuff, this);
			m_Character.SignalInvisibleBuffUpdated.Disconnect(UpdateBuff, this);
		}
		if (m_IntervalId != undefined)
		{
			clearInterval(m_IntervalId);
			m_IntervalId = undefined;
		}
	}
	
	private function UpdateBuff(buffId:Number)
	{		
		if (buffId != COUNTER_BUFF_LEFT && buffId != COUNTER_BUFF_RIGHT && buffId != LOCKED_BUFF)
		{
			return;
		}
		if (buffId == COUNTER_BUFF_LEFT && m_Character.m_InvisibleBuffList[COUNTER_BUFF_LEFT] != undefined)
		{
			var buff1Count:Number = m_Character.m_InvisibleBuffList[COUNTER_BUFF_LEFT].m_Count;
			var leftRotation:Number = 60 * Math.max(0, (buff1Count - 1));
			if (leftRotation == 0){leftRotation = 360};
			m_LeftBullets.tweenEnd(false);
			m_LeftBullets.onTweenComplete = undefined
			if (m_LeftBullets._rotation != leftRotation)
			{
				m_LeftBullets.tweenTo(0.3, {_rotation:leftRotation}, None.easeNone);
			}
			else
			{
				var firstRotation:Number = leftRotation/2;
				m_LeftBullets.tweenTo(0.15, {_rotation:firstRotation}, None.easeNone);
				m_LeftBullets.onTweenComplete = function ()
				{
					var secondRotation:Number = this._rotation * 2;
					this.tweenTo(0.15, {_rotation:secondRotation}, None.easeNone);
					this.onTweenComplete = undefined;
				}
			}
		}
		else if (buffId == COUNTER_BUFF_RIGHT && m_Character.m_InvisibleBuffList[COUNTER_BUFF_RIGHT] != undefined)
		{
			var buff2Count:Number = m_Character.m_InvisibleBuffList[COUNTER_BUFF_RIGHT].m_Count;
			var rightRotation:Number = 60 * Math.max(0, (buff2Count - 1));
			if (rightRotation == 0){rightRotation = 360};
			m_RightBullets.tweenEnd(false);
			m_RightBullets.onTweenComplete = undefined
			
			var firstRotation:Number = rightRotation/2;
			m_RightBullets.tweenTo(0.15, {_rotation:firstRotation}, None.easeNone);
			m_RightBullets.onTweenComplete = function ()
			{
				var secondRotation:Number = this._rotation * 2;
				this.tweenTo(0.15, {_rotation:secondRotation}, None.easeNone);
				this.onTweenComplete = undefined;
			}
		}
		if (buffId == LOCKED_BUFF)
		{
			if (m_Character.m_InvisibleBuffList[LOCKED_BUFF] != undefined)
			{
				//We know there is a lock, so get the color of the first chamber and play the lock anim
				var count:Number = m_Character.m_InvisibleBuffList[COUNTER_BUFF_LEFT].m_Count;
				if (count == 6 && !m_RedMatch._visible)
				{
					m_RedMatch._visible = true;
					m_RedMatch.gotoAndPlay(0);
				}
				else if (count > 3 && !m_BlueMatch._visible)
				{
					m_BlueMatch._visible = true;
					m_BlueMatch.gotoAndPlay(0);
				}
				else if (!m_GrayMatch._visible)
				{
					m_GrayMatch._visible = true;
					m_GrayMatch.gotoAndPlay(0);
				}
				if (m_IntervalId == undefined)
				{
					m_Timer._alpha = 100;
					setInterval( Delegate.create(this, UpdateTimer), 100, this );
				}
			}
			else
			{
				ClearLock();
			}
		}
	}
	
	private function ClearLock()
	{
		if (m_IntervalId != undefined)
		{
			clearInterval(m_IntervalId);
			m_IntervalId = undefined;
		}
		m_Timer.text = "00:00";
		m_Timer._alpha = 30;
		m_GrayMatch.gotoAndStop(0);
		m_BlueMatch.gotoAndStop(0);
		m_RedMatch.gotoAndStop(0);
		m_GrayMatch._visible = m_BlueMatch._visible = m_RedMatch._visible = false;
	}
	
	private function UpdateTimer()
	{
		var time = com.GameInterface.Utils.GetNormalTime() * 1000;
        var lockTime:Number = m_Character.m_InvisibleBuffList[LOCKED_BUFF].m_TotalTime - time;
		
		if (lockTime <= 0)
		{
			m_Timer.text = "00:00";
		}
		else
		{		
			var totalHundredthsOfSeconds:Number = Math.ceil(lockTime / 10);
			var seconds:Number = Math.floor(totalHundredthsOfSeconds / 100);
			var hundredths:Number = totalHundredthsOfSeconds % 100;
			m_Timer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", seconds, hundredths );
		}
	}
}