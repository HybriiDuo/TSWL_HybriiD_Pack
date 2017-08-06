//Imports
import com.GameInterface.Tooltip.*;
import com.GameInterface.Game.Character;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Utils;
import com.Utils.ID32;
import mx.utils.Delegate;
import gfx.motion.Tween; 
import mx.transitions.easing.*;

//Class
class com.Components.AnimaPotion extends MovieClip
{
	//Components in .fla
	private var m_PotionHitArea:MovieClip;
	private var m_Content:MovieClip;
	private var m_Gloss:MovieClip;
	private var m_GlossMask:MovieClip;
	private var m_CooldownLine:MovieClip;
	private var m_CooldownMask:MovieClip;
	private var m_BGMask:MovieClip;
	private var m_UseBG:MovieClip;
	private var m_NoUseBG:MovieClip;
	private var m_HotkeyText:TextField;
	private var m_CooldownTimer:MovieClip;
	private var m_Remaining:MovieClip;
	private var m_BuyButton:MovieClip;
	
    //Properties
    private var m_Character:Character;
	
	//Variables
	private var m_CooldownIntervalID:Number;
	private var m_TotalCooldownDuration:Number;
	private var m_CooldownExpireTime:Number;	
	private var m_Tooltip:TooltipInterface;
	private var m_TooltipTimeout:Number;
	private var m_MaxPotions:Number;
	
	//Statics
	private var POTION_SPELL:Number = 9269472;
    
    //Constructor
    public function AnimaPotion()
    {
		m_Gloss.setMask(m_GlossMask);
		m_CooldownLine.setMask(m_CooldownMask);
		m_UseBG.setMask(m_BGMask);
		
		m_MaxPotions = Utils.GetGameTweak("MaxPotions");
		
		Shortcut.SignalHotkeyChanged.Connect( SlotHotkeyChanged, this );
		SlotHotkeyChanged();
		
		m_CooldownTimer._visible = false;
		var currentCooldown:Number = Character.GetPotionCooldown();
		if (currentCooldown > 0)
		{
			var cooldownStart:Number = com.GameInterface.Utils.GetGameTime();
			var cooldownEnd:Number = cooldownEnd = cooldownStart + currentCooldown;
			SetCooldown(cooldownEnd, cooldownStart);
		}
		else
		{
			RemoveCooldown();
		}		
		
		m_PotionHitArea.onRollOver = Delegate.create(this, StartTooltipTimeout);
		m_PotionHitArea.onMousePress = m_PotionHitArea.onRollOut = m_PotionHitArea.onDragOut = Delegate.create(this, StopTooltipTimeout);
		m_PotionHitArea.onMouseRelease = Delegate.create(this, UsePotion);
		
		m_BuyButton.onMouseRelease = Delegate.create(this, BuyRefill);
    }
	
	public function SetCharacter(character:Character)
	{
		if (m_Character != undefined)
		{
			m_Character.SignalPotionCooldown.Disconnect(SlotPotionCooldown, this);
			m_Character.SignalEndPotionCooldown.Disconnect(SlotEndPotionCooldown, this);
			m_Character.SignalStatChanged.Disconnect(SlotStatChanged, this);
			m_Character.SignalMemberStatusUpdated.Disconnect(UpdateCount, this);
		}
		m_Character = character;
		m_Character.SignalPotionCooldown.Connect(SlotPotionCooldown, this);
		m_Character.SignalEndPotionCooldown.Connect(SlotEndPotionCooldown, this);
		m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
		m_Character.SignalMemberStatusUpdated.Connect(UpdateCount, this);
		UpdateCount();
	}
	
	private function UpdateCount()
	{
		var currentCount:Number = m_Character.GetStat(_global.Enums.Stat.e_PotionCount);
		m_Remaining.m_Text.text = currentCount;	
		var maxCount:Number = m_MaxPotions;
		if (m_Character.IsMember())
		{
			maxCount = maxCount * 2;
		}
		if (currentCount == maxCount)
		{
			m_BuyButton._visible = false;
		}
		else
		{
			m_BuyButton._visible = true;
		}
	}
	
	private function SlotStatChanged(stat:Number)
	{
		if (stat == _global.Enums.Stat.e_PotionCount)
		{
			UpdateCount();
		}
	}
	
	private function SlotPotionCooldown(seconds:Number)
	{
		if (seconds > 0)
		{
			var cooldownStart:Number = com.GameInterface.Utils.GetGameTime();
			var cooldownEnd:Number = cooldownEnd = cooldownStart + seconds;
			SetCooldown(cooldownEnd, cooldownStart);
		}
	}
	
	private function SlotEndPotionCooldown()
	{
		RemoveCooldown();
	}
	
	private function SetCooldown( cooldownEnd:Number, cooldownStart:Number)
	{
		m_Gloss._visible = false;
		m_CooldownLine._visible = true;
		m_Content._alpha = 75;
        m_TotalCooldownDuration = cooldownEnd - cooldownStart;
        m_CooldownExpireTime = cooldownEnd;

		m_CooldownTimer._visible = true;
		m_CooldownIntervalID = setInterval(this,  "UpdateTimer", 20);
	}
	
	private function RemoveCooldown()
    {
		m_Gloss._visible = true;
		m_CooldownLine._visible = false;
		m_Content._alpha = 100;

		m_CooldownTimer._visible = false;
        if (m_CooldownIntervalID != undefined)
		{
			clearInterval(m_CooldownIntervalID)
			m_CooldownIntervalID = undefined;
		}
    }
	
	private function UpdateTimer() : Void
	{
		var timeLeft:Number = m_CooldownExpireTime - com.GameInterface.Utils.GetGameTime();

        if ( timeLeft > 0 )
        {
			if (m_TotalCooldownDuration > 0)
			{
				var percentage:Number = timeLeft / m_TotalCooldownDuration;
				m_BGMask._y = m_NoUseBG._y + (m_UseBG._height * percentage);
				m_CooldownLine._y = m_BGMask._y;
			}
			m_CooldownTimer.ms_txt.text = com.Utils.Format.Printf( "%02.0f:%02.0f:%02.0f", Math.floor(timeLeft / 60), Math.floor(timeLeft) % 60, Math.floor(timeLeft * 100) % 100 );
        }
        else
		{
			RemoveCooldown();				
		}
	}
	
	private function SlotHotkeyChanged()
	{
		m_HotkeyText.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
    	m_HotkeyText.text = "<variable name='hotkey_short:" + "Use_Potion" + "'/ >";
	}
	
	private function UsePotion()
	{
		Character.UsePotion();
	}
	
	private function BuyRefill()
	{
		Character.BuyPotionRefill();
	}
	
	private function StartTooltipTimeout()
	{
		if (m_TooltipTimeout != undefined || m_Tooltip != undefined)
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
		if (m_Tooltip != undefined)
		{
			CloseTooltip();
		}
	}

    public function OpenTooltip() : Void
    {
		StopTooltipTimeout();
        if (m_Tooltip == undefined)
        {
            var tooltipData:TooltipData = TooltipDataProvider.GetBuffTooltip( POTION_SPELL, m_Character.GetID() );
            m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_PotionHitArea, TooltipInterface.e_OrientationHorizontal, 0, tooltipData );
		}
    }
    
    public function CloseTooltip() : Void
    {
        if ( m_Tooltip != undefined && !m_Tooltip.IsFloating() )
        {
            m_Tooltip.Close();
        }
        m_Tooltip = undefined;
		StopTooltipTimeout();
    }
	
	private function onUnload()
	{
		CloseTooltip();
		RemoveCooldown();
	}
}