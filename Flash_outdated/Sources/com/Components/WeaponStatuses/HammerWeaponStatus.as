import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.utils.Delegate;
import mx.transitions.easing.*;

class com.Components.WeaponStatuses.HammerWeaponStatus extends UIComponent
{
	private var m_HalfAnim:MovieClip;
	private var m_FullAnim:MovieClip;
	private var m_Mask1:MovieClip;
	private var m_Mask2:MovieClip;
	private var m_Fill1:MovieClip;
	private var m_Fill2:MovieClip;
	private var m_FillBG:MovieClip;
	private var m_Progress:MovieClip;
	private var m_ProgressMask:MovieClip;
	
	private var m_Character:Character;
	private var m_IntervalId:Number;
	
	private static var COUNTER_BUFF:Number = 9255775;
	
	public function HammerWeaponStatus()
	{
		super();
		m_FullAnim._visible = false;
		m_HalfAnim._visible = false;
	}
	
	private function configUI()
	{
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff, this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff, this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff, this);
		m_Fill1.setMask(m_Mask1);
		m_Fill2.setMask(m_Mask2);
		m_Progress.setMask(m_ProgressMask);
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
	}
	
	private function UpdateBuff(buffId:Number)
	{
		if (buffId == undefined)
		{
			//This allows us to call update from onTweenComplete
			buffId = COUNTER_BUFF;
			if (m_Mask1.onTweenComplete != undefined)
			{
				m_Mask1.onTweenComplete = undefined;
			}
		}
		
		if (buffId != COUNTER_BUFF)
		{
			return;
		}
		var counterBuff:BuffData = m_Character.m_InvisibleBuffList[COUNTER_BUFF];
		var halfMax:Number = counterBuff.m_MaxCounters/2
		
		if(counterBuff != undefined)
		{
			var maxProgress:Number = 0;
			var decimalCharge1:Number = Math.min(counterBuff.m_Count, halfMax) / halfMax;
			var chargeWidth1:Number = m_Fill1._width * decimalCharge1;
			if (Math.ceil(m_Mask1._width) != Math.ceil(chargeWidth1))
			{
				m_Mask1.tweenEnd(false);
				m_Mask1.tweenTo(0.3, {_width:chargeWidth1}, None.easeNone);
				
				//We will have a 2nd bar to update after this is finished
				if (counterBuff.m_Count > halfMax)
				{
					m_Progress.tweenEnd(false);
					m_Progress.tweenTo(0.3, {_x:chargeWidth1}, None.easeNone);
					m_Mask1.onTweenComplete = Delegate.create(this, UpdateBuff);
					return;
				}
			}
			maxProgress = chargeWidth1;
			
			var decimalCharge2:Number = Math.max(counterBuff.m_Count-halfMax, 0) / halfMax;
			var chargeWidth2:Number = m_Fill2._width * decimalCharge2;
			if (m_Mask2._width != chargeWidth2)
			{
				if (m_Progress._x != m_Mask2._width)
				{
					m_Progress._x = m_Mask2._width;
				}
				m_Mask2.tweenEnd(false);
				m_Mask2.tweenTo(0.3, {_width:chargeWidth2}, None.easeNone); 
			}
			if (chargeWidth2 > 0)
			{
				maxProgress = chargeWidth2;
			}
			
			if (m_Progress._x != maxProgress)
			{
				m_Progress.tweenEnd(false);
				m_Progress.tweenTo(0.3, {_x:maxProgress}, None.easeNone);
			}
		}
		else
		{
			m_Mask1._width = 0;
			m_Mask2._width = 0;
			m_Progress._x = 0;
		}

		if (counterBuff != undefined)
		{
			if (counterBuff.m_Count >= halfMax)
			{
				if (m_HalfAnim._visible == false)
				{
					m_HalfAnim._visible = true;
					m_HalfAnim.gotoAndPlay(0);
				}
			}
			else
			{
				if (m_HalfAnim._visible)
				{
					m_HalfAnim._visible = false;
				}
			}
			if (counterBuff.m_Count >= counterBuff.m_MaxCounters)
			{
				if (m_FullAnim._visible == false)
				{
					m_FullAnim._visible = true;
					m_FullAnim.gotoAndPlay(0);
				}
			}
			else
			{
				if (m_FullAnim._visible)
				{
					m_FullAnim._visible = false;
				}
			}
		}
		else
		{
			m_FullAnim._visible = false;
			m_HalfAnim._visible = false;
		}
	}
}