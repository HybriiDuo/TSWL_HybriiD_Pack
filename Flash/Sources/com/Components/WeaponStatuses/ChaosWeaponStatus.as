import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import com.Utils.Colors;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;

class com.Components.WeaponStatuses.ChaosWeaponStatus extends UIComponent
{
	private var m_Character:Character;
	
	private static var COUNTER_BUFF:Number = 9267821;
	private static var FRAMES:Array = [1, 2, 19, 35, 51, 67, 83, 99, 116];
	private var m_ForceFull:Boolean;
	
	public function ChaosWeaponStatus()
	{
		super();
		m_ForceFull = false;
		this.gotoAndStop(FRAMES[0]);
	}
	
	private function configUI()
	{
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff, this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff, this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff, this);
		m_Character.SignalCharacterDied.Connect(SlotCharacterDied, this);
		
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
		if (buffId != COUNTER_BUFF)
		{
			return;
		}
		if (m_ForceFull)
		{
			return;
		}
		var desiredFrame:Number = FRAMES[GetBuffCount()];
		if (desiredFrame == FRAMES[FRAMES.length-1])
		{
			m_ForceFull = true;
			_global.setTimeout(Delegate.create(this, ForceFullTimeout), 800);
		}
		this.gotoAndStop(desiredFrame);
	}
	
	private function ForceFullTimeout()
	{
		m_ForceFull = false;
		UpdateBuff(COUNTER_BUFF);
	}
	
	//Special case so that this doesn't wrap around when set to no counters due to death
	private function SlotCharacterDied()
	{
		this.gotoAndStop(FRAMES[0]);
	}
	
	private function GetBuffCount()
	{
		if (m_Character.m_InvisibleBuffList[COUNTER_BUFF] != undefined)
		{
			return m_Character.m_InvisibleBuffList[COUNTER_BUFF].m_Count;
		}
		return 0;
	}
}