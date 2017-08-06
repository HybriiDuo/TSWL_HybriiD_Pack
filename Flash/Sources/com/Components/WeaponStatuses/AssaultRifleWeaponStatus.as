import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import gfx.core.UIComponent;
import mx.utils.Delegate;
import com.Utils.Colors;

class com.Components.WeaponStatuses.AssaultRifleWeaponStatus extends UIComponent
{	
	private var m_GrenadeLoader:MovieClip;
	private var m_Alert:MovieClip;
	private var m_Timer:TextField;

	private var m_Character:Character;
	private var m_IntervalId:Number;
	private var m_Stage:Number;
	private var m_PlaySound:Boolean;
	
	private static var ACTIVE_BUFF:Number = 9255809;
	private static var COOKED_BUFF:Number = 9255818;
	private static var STAGE_SAFE:Number = 0;
	private static var STAGE_ARMED:Number = 1;
	private static var STAGE_COOKED:Number = 2;
	private static var ACTIVE_ALPHA:Number = 100;
	private static var INACTIVE_ALPHA:Number = 50;
	private static var ACTIVE_TINT:Number = 0;
	private static var INACTIVE_TINT:Number = 25;
	
	public function AssaultRifleWeaponStatus()
	{
		super();
	}
	
	private function configUI()
	{
		m_PlaySound = false;
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff, this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff, this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff, this);
		
		m_GrenadeLoader.gotoAndStop(1);
		m_Alert.gotoAndStop(1);
		m_Alert._visible = false;
		m_Alert.onEnterFrame = function()
		{
			if (this._currentframe == this.totalframes)
			{
				this.gotoAndPlay(1);
			}
		}
		
		UpdateBuff(ACTIVE_BUFF);
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
		if (m_IntervalId != undefined)
		{
			clearInterval(m_IntervalId);
			m_IntervalId = undefined;
		}
	}
	
	private function UpdateBuff(buffId:Number)
	{		
		if (buffId != ACTIVE_BUFF && buffId != COOKED_BUFF)
		{
			return;
		}
		if (m_Character.m_InvisibleBuffList[ACTIVE_BUFF] != undefined)
		{
			if (m_Stage == STAGE_SAFE)
			{
				m_Stage = STAGE_ARMED;
				this._alpha = ACTIVE_ALPHA;
				Colors.Tint(this, 0x000000, ACTIVE_TINT);
				m_GrenadeLoader.gotoAndPlay(1);
				if (m_PlaySound)
				{
					m_Character.AddEffectPackage( "sound_fxpackage_GUI_ar_grenade_ready.xml" );
				}
				if (m_IntervalId == undefined)
				{
					setInterval( Delegate.create(this, UpdateTimer), 100, this );
				}
			}			
		}
		else if (m_Stage != STAGE_SAFE)
		{
			this._alpha = INACTIVE_ALPHA;
			Colors.Tint(this, 0x000000, INACTIVE_TINT);
			m_Timer.text = "00:00";
			m_GrenadeLoader.gotoAndStop(1);
			m_Alert.gotoAndStop(1);
			m_Alert._visible = false;
			m_Stage = STAGE_SAFE;
			if (m_IntervalId != undefined)
			{
				clearInterval(m_IntervalId);
				m_IntervalId = undefined;
			}
		}
		
		if (m_Character.m_InvisibleBuffList[COOKED_BUFF] != undefined)
		{
			if (m_Stage != STAGE_COOKED)
			{
				m_Stage = STAGE_COOKED;
				m_Alert._visible = true;
				m_Alert.gotoAndPlay(1);
			}
		}
	}
	
	private function UpdateTimer()
	{
		var time = com.GameInterface.Utils.GetNormalTime() * 1000;
        var grenadeTime:Number = m_Character.m_InvisibleBuffList[ACTIVE_BUFF].m_TotalTime - time;
		
		if (grenadeTime <= 0)
		{
			m_Timer.text = "00:00";
		}
		else
		{		
			var totalHundredthsOfSeconds:Number = Math.ceil(grenadeTime / 10);
			var seconds:Number = Math.floor(totalHundredthsOfSeconds / 100);
			var hundredths:Number = totalHundredthsOfSeconds % 100;
			m_Timer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", seconds, hundredths );
		}
	}
}