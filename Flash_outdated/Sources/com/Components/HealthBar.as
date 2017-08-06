import flash.geom.Rectangle;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.Character;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;

class com.Components.HealthBar extends MovieClip
{
    public static var STATTEXT_PERCENT:Number = 0;
    public static var STATTEXT_NUMBER:Number = 1;
	
	private static var AEGIS_PSYCHIC = LDBFormat.LDBGetText("DamageType", "Aegis_Psychic");
	private static var AEGIS_TECH = LDBFormat.LDBGetText("DamageType", "Aegis_Tech");
	private static var AEGIS_DEMONIC = LDBFormat.LDBGetText("DamageType", "Aegis_Demonic");
    
    private var m_Dynel:Dynel;
    private var m_GroupElement:GroupElement;
    private var m_Character:Character;
    
    private var m_CurrentStatID:Number;
    private var m_MaxStatID:Number;
    private var m_BoostStatID:Number;
	
	//Monster shields
	private var m_PinkShieldStatID:Number;
	private var m_BlueShieldStatID:Number;
	private var m_RedShieldStatID:Number;
	private var m_PinkShieldAbsoluteStatID:Number;
	private var m_BlueShieldAbsoluteStatID:Number;
	private var m_RedShieldAbsoluteStatID:Number;
	private var m_PinkShieldPercentStatID:Number;
	private var m_BlueShieldPercentStatID:Number;
	private var m_RedShieldPercentStatID:Number;
	
	//player shields
	private var m_PlayerShieldTypeStatID:Number;
	private var m_PlayerShieldCurrentStatID:Number;
	private var m_PlayerShieldMaxStatID:Number;
	
	//AEGIS damage type
	private var m_AegisDamageTypeStatID:Number;
	
	private var m_ShieldsOnTop:Boolean;
    
    private var m_Max:Number;
    private var m_Current:Number;
    private var m_Boost:Number;
    private var m_BoostMask:MovieClip;
    
    private var m_Text:TextField;
    private var m_Bar:MovieClip;
	
	private var m_ShieldBar:MovieClip;
	private var m_SecondShield:MovieClip;
	private var m_ThirdShield:MovieClip;
	private var m_AegisDamageType:MovieClip;
    
    private var m_AlwaysVisible:Boolean;
	private var m_IsPlayer:Boolean;
    private var m_ShowText:Boolean;
    private var m_TextType:Number;
    
    private var m_TweenTime:Number;
    private var m_TweenLimitPercent:Number;
	
	private var m_ShowHPUnderAegis:DistributedValue;
	private var m_ShowAegisValues:DistributedValue;

    public function HealthBar()
    {
       /// trace("healthbar initiated")
        m_ShowText = true;
        m_TextType = STATTEXT_NUMBER;
        m_BoostStatID = _global.Enums.Stat.e_BarrierHealthPool;
        m_CurrentStatID = _global.Enums.Stat.e_Health;
        m_MaxStatID = _global.Enums.Stat.e_Life;
        m_AlwaysVisible = true;
		
		m_PinkShieldStatID = _global.Enums.Stat.e_CurrentPinkShield;
		m_BlueShieldStatID = _global.Enums.Stat.e_CurrentBlueShield;
		m_RedShieldStatID = _global.Enums.Stat.e_CurrentRedShield;
		m_PinkShieldAbsoluteStatID = _global.Enums.Stat.e_AbsolutePinkShield;
		m_BlueShieldAbsoluteStatID = _global.Enums.Stat.e_AbsoluteBlueShield;
		m_RedShieldAbsoluteStatID = _global.Enums.Stat.e_AbsoluteRedShield;
		m_PinkShieldPercentStatID = _global.Enums.Stat.e_PercentPinkShield;
		m_BlueShieldPercentStatID = _global.Enums.Stat.e_PercentBlueShield;
		m_RedShieldPercentStatID = _global.Enums.Stat.e_PercentRedShield;
		
		m_PlayerShieldTypeStatID = _global.Enums.Stat.e_PlayerAegisShieldType;
		m_PlayerShieldCurrentStatID = _global.Enums.Stat.e_PlayerAegisShieldStrength;
		m_PlayerShieldMaxStatID = _global.Enums.Stat.e_PlayerAegisShieldStrengthMax;
		
		m_AegisDamageTypeStatID = _global.Enums.Stat.e_ColorCodedDamageType;
		
		m_ShieldsOnTop = false;
        
        m_TweenTime = 0.05;
        m_TweenLimitPercent = 10;
        
		// Just leaving it here in case, but this is no longer used as it caused issues when it was outside of the screen.
        //m_BoostMask = com.GameInterface.ProjectUtils.SetMovieClipMask(m_Bar.m_Boost, null, m_Bar.m_Boost._height, m_Bar.m_Boost._width/2, false);
        
        m_Text.autoSize = "center";
		
		m_Bar.m_Red._alpha = 0;
		m_Bar.m_Orange._alpha = 0;
		m_Bar.m_Yellow._alpha = 0;
		m_Bar.m_Green._alpha = 0;
		m_Bar.m_Background._alpha = 0;
    }
    
    public function SetDynel( dynel:Dynel )
    {
        //trace("SetDynel "+dynel)
        //Disconnect from old signal
        if (m_Dynel != undefined)
        {
            m_Dynel.SignalStatChanged.Disconnect(SlotStatChanged, this);
        }        
        ClearBar();
		
        if (dynel == undefined)
        {
            return;
        }
		
		m_Dynel = dynel;
		m_IsPlayer = m_Dynel.GetID().IsPlayer();
		
		if (m_Dynel.IsEnemy())
		{
			//m_Bar.m_Red._alpha = 100;
			//m_Bar.m_Red._alpha = 0;
			
			m_Bar.m_MeterEnemy._alpha = 100;
			m_Bar.m_ArtworkEnemy._alpha = 100;
			m_Bar.m_OverlayEnemy._alpha = 100;
			
			m_Bar.m_MeterFriend._alpha = 0;
			m_Bar.m_ArtworkFriend._alpha = 0;
			m_Bar.m_OverlayFriend._alpha = 0;
		}
		else
		{
			m_Bar.m_MeterEnemy._alpha = 0;
			m_Bar.m_ArtworkEnemy._alpha = 0;
			m_Bar.m_OverlayEnemy._alpha = 0;
			
			m_Bar.m_MeterFriend._alpha = 100;
			m_Bar.m_ArtworkFriend._alpha = 100;
			m_Bar.m_OverlayFriend._alpha = 100;
		}
		
        var currentValue = m_Dynel.GetStat( m_CurrentStatID, 2 /* full */ );
        var boostValue = m_Dynel.GetStat( m_BoostStatID, 2 /* full */ );
        
		SetCurrent( currentValue, boostValue, true );
        
		var maxValue = m_Dynel.GetStat( m_MaxStatID, 2 /* full */ );
        
		SetMax( maxValue, true );
		
		if (m_IsPlayer)
		{
			m_ShowHPUnderAegis = DistributedValue.Create( "ShowHPUnderAegis_Player" );
			m_ShowAegisValues = DistributedValue.Create( "ShowAegisValues_Player" );
			m_AegisDamageType._visible = false;
			UpdatePlayerShields();
		}
		else
		{
			m_ShowHPUnderAegis = DistributedValue.Create( "ShowHPUnderAegis_Mob" );
			m_ShowAegisValues = DistributedValue.Create( "ShowAegisValues_Mob" );
			m_AegisDamageType._visible = true;
			UpdateEnemyShields();
		}		
		m_ShowHPUnderAegis.SignalChanged.Connect(UpdateStatText, this);
		m_ShowAegisValues.SignalChanged.Connect(UpdateStatText, this);
		
		UpdateAegisDamageType();
        
        //Connect to stat updated
        m_Dynel.SignalStatChanged.Connect(SlotStatChanged, this);
    }
    
    function SlotCharacterEntered()
    {
        SetDynel(Dynel.GetDynel(m_GroupElement.m_CharacterId));
    }
    
    function SlotCharacterExited()
    {
        ClearBar();
    }
    
    /// sets the scaling of the bar and repositions the textfield, this will also scale the textfield (uniformly) based on the input
    /// @param xscale:Number - The xscale
    /// @param yscale:Number - the yscale
    /// @param scaleText:Number [opt] -the scale of text, if omitted no scaling will occur
    public function SetBarScale( xscale:Number, yscale:Number, textScale:Number, dotScale:Number)
    {
        m_Bar._xscale = xscale;
        m_Bar._yscale = yscale;
        
        if (!isNaN( textScale ))
        {
            m_Text._xscale = textScale;
            m_Text._yscale = textScale;
        }
        
        m_Text._x = (m_Bar._width - m_Text._width) * 0.5;
        if (m_Text.htmlText.length == 0)
        {
           // because of autosizing, it needs to have text in order to be measured
           m_Text.htmlText = "0";
           m_Text._y = (m_Bar._height - m_Text._height) * 0.5 - 1;
           m_Text.htmlText = "";
        }
        else
        {
            m_Text._y = (m_Bar._height - m_Text._height) * 0.5 - 1;
        }
		
		//Scale and place shields
		m_ShieldBar._xscale = xscale;
		m_ShieldBar._yscale = yscale;
		
		m_ShieldBar._x = m_Bar._x;
		m_ShieldBar._y = m_Bar._y;
		
		//Scale these both by x so that it remains a circle
		m_SecondShield._xscale = dotScale;
		m_SecondShield._yscale = dotScale;
		m_ThirdShield._xscale = dotScale;
		m_ThirdShield._yscale = dotScale;
		
		PositionUpcomingShields(m_ShieldsOnTop);
		
		//Scale and place Damage Type
		m_AegisDamageType._xscale = m_AegisDamageType._yscale = dotScale;
		m_AegisDamageType._x = m_ShieldBar._x - m_AegisDamageType._width - 5;
		m_AegisDamageType._y = m_Bar._y + (m_Bar._height/2) - (m_AegisDamageType._height/2);
    }
    
    public function SetGroupElement(groupElement:GroupElement)
    {
        //trace("SetGroupElement "+groupElement)
        if (m_GroupElement != undefined)
        {
            m_GroupElement.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
            m_GroupElement.SignalCharacterExitedClient.Disconnect(SlotCharacterExited, this);
        }
        m_GroupElement = groupElement;
        if (m_GroupElement.m_OnClient)
        {
            SetDynel(Dynel.GetDynel(groupElement.m_CharacterId));
        }
        else
        {
            SetDynel(undefined);
        }
        if (groupElement != undefined)
        {
            m_GroupElement.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
            m_GroupElement.SignalCharacterExitedClient.Connect(SlotCharacterExited, this);
        }
        
    }

    public function SetCharacter(character:Character)
    {
        /// trace("SetCharacter "+character)
        if (m_Character != undefined)
        {
           // m_Character.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
           // m_Character.SignalCharacterExitedClient.Disconnect(SlotCharacterExited, this);
        }
        m_Character = character;

        if (m_Character)
        {
            SetDynel(m_Character);
        }
        else
        {
            SetDynel(undefined);
        }
        if (m_Character != undefined)
        {
            //m_Character.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
            //m_Character.SignalCharacterExitedClient.Connect(SlotCharacterExited, this);
        }
        
    }
    
    private function ClearBar( )
    {
        // Note: We now know that the next max and current updates will be because of a change of the slot and so we should not have any effect on the bar.

        // This will make the bar update only when both max and current has been set, and then without any effect.
        m_Current = undefined;
        m_Max = undefined;
        
		UpdateEnemyShields();
		UpdatePlayerShields();
        UpdateStatText();
        UpdateStatBar(true);        
    }
    
    /// listens to a change in stats.
    /// @param p_stat:Number  -  The type of stat, defined in the Stat  Enum
    /// @param p_value:Number -  The value of the stat
    private function SlotStatChanged( stat:Number, value:Number )
    {
        //trace("SlotStatChanged( "+stat+", "+value+" )")
        switch( stat )
        {
			//Fallthroughs intended
            case m_CurrentStatID:
            case m_BoostStatID:
              SetCurrent(  m_Dynel.GetStat( m_CurrentStatID, 2 ), m_Dynel.GetStat( m_BoostStatID, 2 ), false);
			  break;
            case m_MaxStatID:
              SetMax( m_Dynel.GetStat( stat, 2  ), true);
			  break;
			case m_PinkShieldStatID:
			case m_BlueShieldStatID:
			case m_RedShieldStatID:
			case m_PinkShieldAbsoluteStatID:
			case m_BlueShieldAbsoluteStatID:
			case m_RedShieldAbsoluteStatID:
			case m_PinkShieldPercentStatID:
			case m_BlueShieldPercentStatID:
			case m_RedShieldPercentStatID:
				UpdateEnemyShields();
				break;
			case m_PlayerShieldTypeStatID:
			case m_PlayerShieldCurrentStatID:
			case m_PlayerShieldMaxStatID:
				UpdatePlayerShields();
				break;
			case m_AegisDamageTypeStatID:
				UpdateAegisDamageType();
				break;
        }
    }
    
    /// gets tha max and sets this as a member used to calculate the percent of health left (0 - 100, used for the _xscale)
    /// @param maxStat:String - the max stat as a string
    /// @return void
    private function SetMax( maxStat:Number, snap:Boolean) : Void
    {
		//trace('CommonLib.StatBar:SetMax(' + maxStat + ')')
		if( maxStat <= 0)
		{
			Hide();
			return;
		}
		else
		{
		   Show();
		}

		m_Max = maxStat;

		UpdateStatText();
		UpdateStatBar(snap);
    }
    
    /// Updates the stat text and bar
    /// @param stat:String - the health as a string
    /// @return void
    private function SetCurrent(currentValue:Number, boostValue:Number, snap:Boolean) : Void
    {
      //trace('CommonLib.StatBar:SetCurrent(' + stat + ')')
      if (currentValue == undefined || boostValue == undefined || m_Current == undefined || m_Boost == undefined ||
          Math.abs(currentValue + boostValue - m_Current - m_Boost) > m_Max / m_TweenLimitPercent)
      {
          snap = true;
      }
      m_Current = currentValue;
      m_Boost = boostValue;
      
      UpdateStatText();
      UpdateStatBar(snap);
    }
	
	private function UpdateEnemyShields()
	{
		if (!m_IsPlayer);
		{
			//Not a player, hide the backing
			m_ShieldBar.m_Backing.tweenEnd(false);
			m_ShieldBar.m_Backing._width = 0;
			
			var currentShield:Number = undefined;
			var currentAbsolute:Number = undefined;
			var currentPercent:Number = undefined;
			//Get shield values
			var pinkValue:Number = m_Dynel.GetStat(m_PinkShieldStatID, 2);
			var blueValue:Number = m_Dynel.GetStat(m_BlueShieldStatID, 2);
			var redValue:Number = m_Dynel.GetStat(m_RedShieldStatID, 2);
			//Set the currently displayed shield
			if (pinkValue > 0) 
			{
				currentShield = m_PinkShieldStatID;
				currentAbsolute = m_PinkShieldAbsoluteStatID;
				currentPercent = m_PinkShieldPercentStatID;
				m_ShieldBar.m_PinkShield._alpha = 100;
				m_ShieldBar.m_BlueShield._alpha = 0;
				m_ShieldBar.m_RedShield._alpha = 0;
			}
			else if (blueValue > 0) 
			{
				currentShield = m_BlueShieldStatID;
				currentAbsolute = m_BlueShieldAbsoluteStatID;
				currentPercent = m_BlueShieldPercentStatID;
				m_ShieldBar.m_PinkShield._alpha = 0;
				m_ShieldBar.m_BlueShield._alpha = 100;
				m_ShieldBar.m_RedShield._alpha = 0;
			}
			else if (redValue > 0) 
			{
				currentShield = m_RedShieldStatID;
				currentAbsolute = m_RedShieldAbsoluteStatID;
				currentPercent = m_RedShieldPercentStatID;
				m_ShieldBar.m_PinkShield._alpha = 0;
				m_ShieldBar.m_BlueShield._alpha = 0;
				m_ShieldBar.m_RedShield._alpha = 100;
			}
			else 
			{
				m_ShieldBar.m_PinkShield._alpha = 0;
				m_ShieldBar.m_BlueShield._alpha = 0;
				m_ShieldBar.m_RedShield._alpha = 0;
			}
			
			//Display the upcoming shields
			//NOTE: There are some assumptions being made here due to the design of the Aegis system
			// 		Shields are always in the same order, Psychic, Tech, Demonic. This means Psychic
			//		shields cannot be second or third, and tech shields cannot be third.
			//      If this isn't the case, go talk to gamecode or a designer and ask why.
			m_SecondShield.m_Demonic._visible = m_SecondShield.m_Tech._visible = m_SecondShield.m_Psychic._visible = false;
			m_ThirdShield.m_Demonic._visible = m_ThirdShield.m_Tech._visible = m_ThirdShield.m_Psychic._visible = false;
			switch(currentShield)
			{
				case m_PinkShieldStatID:
					if (blueValue > 0) 
					{ 
						m_SecondShield.m_Tech._visible = true;
						m_ShieldBar.m_BlueShield._alpha = 100;
						m_ShieldBar.m_BlueShield._x = 5;
						m_ShieldBar.m_BlueShield._y = -1;
						m_ShieldBar.m_BlueShield._height = 14;
						if (redValue > 0)
						{
							m_ThirdShield.m_Demonic._visible = true; 
							m_ShieldBar.m_RedShield._alpha = 100;
							m_ShieldBar.m_RedShield._x = 5
							m_ShieldBar.m_RedShield._y = -1;
							m_ShieldBar.m_RedShield._height = 14;
						}
					}
					else if (redValue > 0) 
					{ 
						m_SecondShield.m_Demonic._visible = true; 
						m_ShieldBar.m_RedShield._alpha = 100;
						m_ShieldBar.m_RedShield._x = 5
						m_ShieldBar.m_RedShield._y = -1;
						m_ShieldBar.m_RedShield._height = 14;
					}
					break;
					
				case m_BlueShieldStatID:
					if (redValue > 0) 
					{ 
						m_SecondShield.m_Demonic._visible = true; 
						m_ShieldBar.m_RedShield._alpha = 100;
						m_ShieldBar.m_RedShield._x = 5
						m_ShieldBar.m_RedShield._y = -1;
						m_ShieldBar.m_RedShield._height = 14;
					}
					break;
				case m_RedShieldStatID: //No shields are after the red shield, so this is placeholder
					break;
			}
			
			UpdateCurrentEnemyShield(currentShield, currentAbsolute, currentPercent);
			PositionUpcomingShields(m_ShieldsOnTop);
			
			if (m_Bar.getDepth() > m_ShieldBar.getDepth())
			{
				m_Bar.swapDepths(m_ShieldBar);
			}			
		}
	}
	
	private function UpdateCurrentEnemyShield(currentShield:Number, currentAbsolute:Number, currentPercent:Number)
	{
		if (!m_IsPlayer && currentShield != undefined && currentAbsolute != undefined && currentPercent != undefined)
		{			
			//Update Shieldbar sizes
			var pinkCurrent:Number = m_Dynel.GetStat(m_PinkShieldStatID, 2);
			var pinkMax:Number = Math.floor(m_Dynel.GetStat(m_PinkShieldAbsoluteStatID, 2) + m_Dynel.GetStat(m_MaxStatID, 2) * m_Dynel.GetStat(m_PinkShieldPercentStatID, 2) + 0.5);
			var pinkScale:Number = Math.min((pinkCurrent/pinkMax), 1);
			var pinkPercent:Number = Math.abs(pinkScale * m_ShieldBar.m_ShieldBG._width - m_ShieldBar.m_PinkShield._width) / m_ShieldBar.m_ShieldBG._width;
			var pinkModifier = 0;
			if (currentShield != m_PinkShieldStatID)
			{
				pinkModifier = -10;
			}
			var snapPink:Boolean = false;
			if (pinkPercent * 100 > m_TweenLimitPercent)
			{
				snapPink = true;
			}
			
			var blueCurrent:Number = m_Dynel.GetStat(m_BlueShieldStatID, 2);
			var blueMax:Number = Math.floor(m_Dynel.GetStat(m_BlueShieldAbsoluteStatID, 2) + m_Dynel.GetStat(m_MaxStatID, 2) * m_Dynel.GetStat(m_BlueShieldPercentStatID, 2) + 0.5);
			var blueScale:Number = Math.min((blueCurrent/blueMax), 1);
			var bluePercent:Number = Math.abs(blueScale * m_ShieldBar.m_ShieldBG._width - m_ShieldBar.m_BlueShield._width) / m_ShieldBar.m_ShieldBG._width;
			var blueModifier = 0;
			if (currentShield != m_BlueShieldStatID)
			{
				blueModifier = -10;
			}
			var snapBlue:Boolean = false;
			if (bluePercent * 100 > m_TweenLimitPercent)
			{
				snapBlue = true;
			}
			
			var redCurrent:Number = m_Dynel.GetStat(m_RedShieldStatID, 2);
			var redMax:Number = Math.floor(m_Dynel.GetStat(m_RedShieldAbsoluteStatID, 2) + m_Dynel.GetStat(m_MaxStatID, 2) * m_Dynel.GetStat(m_RedShieldPercentStatID, 2) + 0.5);
			var redScale:Number = Math.min((redCurrent/redMax), 1);
			var redPercent:Number = Math.abs(redScale * m_ShieldBar.m_ShieldBG._width - m_ShieldBar.m_RedShield._width) / m_ShieldBar.m_ShieldBG._width;
			var redModifier = 0;
			if (currentShield != m_RedShieldStatID)
			{
				redModifier = -10;
			}
			var snapRed:Boolean = false;
			if (redPercent * 100 > m_TweenLimitPercent)
			{
				snapRed = true;
			}
						
			m_ShieldBar.m_PinkShield.tweenEnd(false);
			if (snapPink) {	m_ShieldBar.m_PinkShield._width = Math.max((m_ShieldBar.m_ShieldBG._width + pinkModifier) * pinkScale, 10);}
			else {m_ShieldBar.m_PinkShield.tweenTo(m_TweenTime, {_width:Math.max((m_ShieldBar.m_ShieldBG._width + pinkModifier) * pinkScale, 10)}, None.easeNone);}
			
			m_ShieldBar.m_BlueShield.tweenEnd(false);
			if (snapBlue) {	m_ShieldBar.m_BlueShield._width = Math.max((m_ShieldBar.m_ShieldBG._width + blueModifier) * blueScale, 10);}
			else {m_ShieldBar.m_BlueShield.tweenTo(m_TweenTime, {_width:Math.max((m_ShieldBar.m_ShieldBG._width + blueModifier) * blueScale, 10)}, None.easeNone);}			
			
			m_ShieldBar.m_RedShield.tweenEnd(false);
			if (snapRed) {m_ShieldBar.m_RedShield._width = Math.max((m_ShieldBar.m_ShieldBG._width + redModifier) * redScale, 10);}
			else {m_ShieldBar.m_RedShield.tweenTo(m_TweenTime, {_width:Math.max((m_ShieldBar.m_ShieldBG._width + redModifier) * redScale, 10)}, None.easeNone);}	
			
			var shieldString:String = "";
			switch(currentShield)
			{
				case m_PinkShieldStatID:
					m_ShieldBar.m_PinkShield._x = 0;
					m_ShieldBar.m_PinkShield._y = -4;
					m_ShieldBar.m_PinkShield._height = 20;
					break;
				case m_BlueShieldStatID:
					m_ShieldBar.m_BlueShield._x = 0;
					m_ShieldBar.m_BlueShield._y = -4;
					m_ShieldBar.m_BlueShield._height = 20;
					break;
				case m_RedShieldStatID:
					m_ShieldBar.m_RedShield._x = 0;
					m_ShieldBar.m_RedShield._y = -4;
					m_ShieldBar.m_RedShield._height = 20;
					break;
			}
		}
		UpdateStatText();
	}
	
	private function UpdatePlayerShields()
	{
		if (m_IsPlayer)
		{
			//ASSUMPTION: Players only have one shield type. If this isn't true, we have bigger problems.
			m_SecondShield.m_Demonic._visible = m_SecondShield.m_Tech._visible = m_SecondShield.m_Psychic._visible = false;
			m_ThirdShield.m_Demonic._visible = m_ThirdShield.m_Tech._visible = m_ThirdShield.m_Psychic._visible = false;
			m_ShieldBar.m_PinkShield._alpha = 0;
			m_ShieldBar.m_BlueShield._alpha = 0;
			m_ShieldBar.m_RedShield._alpha = 0;
			
			var shieldType:Number =  m_Dynel.GetStat(m_PlayerShieldTypeStatID, 2);
			var shieldCurrent:Number = m_Dynel.GetStat(m_PlayerShieldCurrentStatID, 2);
			var shieldMax:Number = m_Dynel.GetStat(m_PlayerShieldMaxStatID, 2);
			var shieldScale:Number = Math.min(shieldCurrent/shieldMax, 1);
					
			if (shieldCurrent > 0 && shieldType != _global.Enums.AegisTypes.e_AegisNONE)
			{
				var shield:MovieClip = undefined;
				switch(shieldType)
				{
					case _global.Enums.AegisTypes.e_AegisPink:
						Colors.ApplyColor(m_ShieldBar.m_Backing, 0xFFFFFF);
						shield = m_ShieldBar.m_PinkShield;
						break;
					case _global.Enums.AegisTypes.e_AegisBlue:
						Colors.ApplyColor(m_ShieldBar.m_Backing, 0x27FEFF);
						shield = m_ShieldBar.m_BlueShield;
						break;
					case _global.Enums.AegisTypes.e_AegisRed:
						Colors.ApplyColor(m_ShieldBar.m_Backing, 0xF40000);
						shield = m_ShieldBar.m_RedShield;
						break;
				}
				var snap:Boolean = false;
				var shieldPercent = Math.abs(shieldScale * m_ShieldBar.m_ShieldBG._width - shield._width) / m_ShieldBar.m_ShieldBG._width;
				if (shieldPercent * 100 > m_TweenLimitPercent) { snap = true; }
				
				//Don't update if there is no change
				if (shieldPercent > 0)
				{
					shield.tweenEnd(false);
					m_ShieldBar.m_Backing.tweenEnd(false);
					if (snap) 
					{
						shield._width = Math.max(m_ShieldBar.m_ShieldBG._width * shieldScale, 10);
						m_ShieldBar.m_Backing._width = Math.max(m_ShieldBar.m_ShieldBG._width * shieldScale, 10);
					}
					else 
					{
						shield.tweenTo(m_TweenTime, {_width:Math.max(m_ShieldBar.m_ShieldBG._width * shieldScale, 10)}, None.easeNone);
						m_ShieldBar.m_Backing.tweenTo(m_TweenTime, {_width:Math.max(m_ShieldBar.m_ShieldBG._width * shieldScale, 10)}, None.easeNone);
					}
				}
				
				if (m_Bar.getDepth() < m_ShieldBar.getDepth())
				{
					m_Bar.swapDepths(m_ShieldBar);
				}
				shield._alpha = 100;
			}
			else
			{
				m_ShieldBar.m_Backing.tweenEnd(false);
				m_ShieldBar.m_Backing._width = 0;
			}
			UpdateStatText();
		}
	}
    
    /// Updates the text that overlays the healthbar updates it as percent or real numbers
    private function UpdateStatText()
    {
        //trace('CommonLib.StatBar:UpdateStatText()')
        
        if ( m_ShowText )
        {
			var shieldsActive:Boolean = false;
			if (Boolean(m_ShowAegisValues.GetValue()))
			{
				if (m_IsPlayer)
				{
					var shieldCurrent:Number = m_Dynel.GetStat(m_PlayerShieldCurrentStatID, 2);
					var shieldType:Number = m_Dynel.GetStat(m_PlayerShieldTypeStatID, 2);
					var shieldMax:Number = m_Dynel.GetStat(m_PlayerShieldMaxStatID, 2);
					if (shieldCurrent > 0 && shieldType > 0)
					{
						shieldsActive = true;
						var shieldString:String = "";
						switch(shieldType)
						{
							case _global.Enums.AegisTypes.e_AegisPink:
								shieldString = AEGIS_PSYCHIC.toUpperCase().slice(0,3);
								break;
							case _global.Enums.AegisTypes.e_AegisBlue:
								shieldString = AEGIS_TECH.toUpperCase().slice(0,3);
								break;
							case _global.Enums.AegisTypes.e_AegisRed:
								shieldString = AEGIS_DEMONIC.toUpperCase().slice(0,3);
								break;
						}
						if (m_TextType == STATTEXT_PERCENT)
						{
							m_Text.htmlText = "";
							if(Boolean(m_ShowHPUnderAegis.GetValue()))
							{
								m_Text.htmlText += Math.round(100 * m_Current / m_Max) + "%" + "          ";
							}
							m_Text.htmlText += Math.round(100 * shieldCurrent / shieldMax) + "%" + "  " + shieldString;
						}
						else if (m_TextType == STATTEXT_NUMBER)
						{
							m_Text.htmlText = "";
							if(Boolean(m_ShowHPUnderAegis.GetValue()))
							{
								m_Text.htmlText += m_Text.htmlText = Math.floor(m_Current + 0.5) + " / " + Math.floor(m_Max + 0.5) + "          ";
							}
							m_Text.htmlText += Math.floor(shieldCurrent + 0.5) + " / " + Math.floor(shieldMax + 0.5) + "  " + shieldString;
						}
					}
				}
				else
				{
					var current:Number = undefined;
					var max:Number = undefined;
					var shieldString:String = "";
					//Set the currently displayed shield
					if (m_Dynel.GetStat(m_PinkShieldStatID, 2) > 0)
					{
						shieldString = AEGIS_PSYCHIC.toUpperCase().slice(0,3);
						var current:Number = m_Dynel.GetStat(m_PinkShieldStatID, 2);
						var max:Number = m_Dynel.GetStat(m_PinkShieldAbsoluteStatID, 2) + m_Dynel.GetStat(m_MaxStatID, 2) * m_Dynel.GetStat(m_PinkShieldPercentStatID, 2);
					}
					else if (m_Dynel.GetStat(m_BlueShieldStatID, 2) > 0) 
					{
						shieldString = AEGIS_TECH.toUpperCase().slice(0,3);
						var current:Number = m_Dynel.GetStat(m_BlueShieldStatID, 2);
						var max:Number = m_Dynel.GetStat(m_BlueShieldAbsoluteStatID, 2) + m_Dynel.GetStat(m_MaxStatID, 2) * m_Dynel.GetStat(m_BlueShieldPercentStatID, 2);
					}
					else if (m_Dynel.GetStat(m_RedShieldStatID, 2) > 0) 
					{
						shieldString = AEGIS_DEMONIC.toUpperCase().slice(0,3);
						var current:Number = m_Dynel.GetStat(m_RedShieldStatID, 2);
						var max:Number = m_Dynel.GetStat(m_RedShieldAbsoluteStatID, 2) + m_Dynel.GetStat(m_MaxStatID, 2) * m_Dynel.GetStat(m_RedShieldPercentStatID, 2);				}
					if (current != undefined)
					{
						shieldsActive = true;
						if (m_TextType == STATTEXT_PERCENT)
						{
							m_Text.htmlText = "";
							if(Boolean(m_ShowHPUnderAegis.GetValue()))
							{
								m_Text.htmlText += Math.round(100 * m_Current / m_Max) + "%" + "          ";
							}
							m_Text.htmlText += Math.round(100 * current / max) + "%" + "  " + shieldString;
						}
						else if (m_TextType == STATTEXT_NUMBER)
						{
							m_Text.htmlText = "";
							if(Boolean(m_ShowHPUnderAegis.GetValue()))
							{
								m_Text.htmlText += Math.floor(m_Current + 0.5) + " / " + Math.floor(m_Max + 0.5) + "          ";
							}
							m_Text.htmlText += Math.floor(current + 0.5) + " / " + Math.floor(max + 0.5) + "  " + shieldString;
						}
					}
				}
			}
            if ( !shieldsActive && m_Current != undefined && m_Max != undefined)
            {
                if (m_TextType == STATTEXT_PERCENT)
                {
                    m_Text.htmlText = Math.round(100 * m_Current / m_Max) + "%";
                }
                else if(m_TextType == STATTEXT_NUMBER)
                {
                    m_Text.htmlText = Math.floor(m_Current + 0.5) + " / " + Math.floor(m_Max + 0.5);
                }
            }
        }
    }
    
        
    private function UpdateStatBar(snap:Boolean)
    {
        //trace('CommonLib.StatBar:UpdateStatBar()')
        if ( m_Current == undefined || m_Max == undefined )
        {
            Hide(); // FIXME: HACK TO AVIOD SOME VISUAL ARTIFACTS WHEN CHANGING _visible FROM false TO true IN SCALEFORM 4.0.13. SHOULD SET _visible INSTEAD.
        }
        else
        {
            Show(); // FIXME: HACK TO AVIOD SOME VISUAL ARTIFACTS WHEN CHANGING _visible FROM false TO true IN SCALEFORM 4.0.13. SHOULD SET _visible INSTEAD.
            
			if (m_Dynel.IsEnemy())
			{
				// scale of the gray overlay
				var scale:Number = Math.max(0, Math.min(100, 100 - (100 * (m_Current + m_Boost) / (m_Max + m_Boost))));

				// find left side of gray overlay (set scale to 1 temporarily, because we can't do this if the scale is 0
				var oldScale = m_Bar.m_OverlayEnemy._xscale;
				m_Bar.m_OverlayEnemy._xscale = 1;
				
				var grayLeft = m_Bar.m_OverlayEnemy._x - (m_Bar.m_OverlayEnemy._width * scale);

				m_Bar.m_OverlayEnemy._xscale = oldScale;

				// percent factor of the visible health bar that should be covered by boost
				var boostFactor:Number = m_Boost > 0 ? Math.max(0, Math.min(100, m_Boost / (m_Boost + m_Current))) : 0;
				
				// find width and position of the boost bar
				var boostWidth:Number = (grayLeft - m_Bar._x) * boostFactor;
				var boostBarX:Number = grayLeft - boostWidth;
				
				m_Bar.m_OverlayEnemy.tweenEnd( false );
				m_Bar.m_Boost.tweenEnd( false );
				if (snap)
				{
					m_Bar.m_OverlayEnemy._xscale = scale;
					m_Bar.m_Boost._x = boostBarX
					m_Bar.m_Boost._width = boostWidth;

				}
				else
				{
					m_Bar.m_OverlayEnemy.tweenTo(m_TweenTime, { _xscale: scale }, None.easeNone);
					m_Bar.m_Boost.tweenTo(m_TweenTime, {_x: boostBarX, _width: boostWidth}, None.easeNone);
				}
			}
			else
			{
				// scale of the gray overlay
				var scale:Number = Math.max(0, Math.min(100, 100 - (100 * (m_Current + m_Boost) / (m_Max + m_Boost))));

				// find left side of gray overlay (set scale to 1 temporarily, because we can't do this if the scale is 0
				var oldScale = m_Bar.m_OverlayFriend._xscale;
				m_Bar.m_OverlayFriend._xscale = 1;
				var grayLeft = m_Bar.m_OverlayFriend._x - (m_Bar.m_OverlayFriend._width * scale);
				m_Bar.m_OverlayFriend._xscale = oldScale;
			   
				// percent factor of the visible health bar that should be covered by boost
				var boostFactor:Number = m_Boost > 0 ? Math.max(0, Math.min(100, m_Boost / (m_Boost + m_Current))) : 0;
				
				// find width and position of the boost bar
				var boostWidth:Number = (grayLeft - m_Bar._x) * boostFactor;
				var boostBarX:Number = grayLeft - boostWidth;
				
				m_Bar.m_OverlayFriend.tweenEnd( false );
				m_Bar.m_Boost.tweenEnd( false );
				if (snap)
				{
					m_Bar.m_OverlayFriend._xscale = scale;
					m_Bar.m_Boost._x = boostBarX
					m_Bar.m_Boost._width = boostWidth;
				}
				else
				{
					m_Bar.m_OverlayFriend.tweenTo(m_TweenTime, { _xscale: scale }, None.easeNone);
					m_Bar.m_Boost.tweenTo(m_TweenTime, {_x: boostBarX, _width: boostWidth}, None.easeNone);
				}
			}
        }
    }
	
	private function UpdateAegisDamageType()
	{
		if (!m_IsPlayer)
		{
			switch(m_Dynel.GetStat(m_AegisDamageTypeStatID, 2))
			{
				case _global.Enums.AegisTypes.e_AegisNONE:
					m_AegisDamageType._visible = false;
					break;
				case _global.Enums.AegisTypes.e_AegisPink:
					m_AegisDamageType._visible = true;
					m_AegisDamageType.m_Psychic._visible = true;
					m_AegisDamageType.m_Tech._visible = false;
					m_AegisDamageType.m_Demonic._visible = false;
					break;
				case _global.Enums.AegisTypes.e_AegisBlue:
					m_AegisDamageType._visible = true;
					m_AegisDamageType.m_Psychic._visible = false;
					m_AegisDamageType.m_Tech._visible = true;
					m_AegisDamageType.m_Demonic._visible = false;
					break;
				case _global.Enums.AegisTypes.e_AegisRed:
					m_AegisDamageType._visible = true;
					m_AegisDamageType.m_Psychic._visible = false;
					m_AegisDamageType.m_Tech._visible = false;
					m_AegisDamageType.m_Demonic._visible = true;
					break;
			}
		}
	}

    public function Hide()
    {
        _visible = false;
    }
    public function Show()
    {
        _visible =  ( m_Current == m_Max) ? m_AlwaysVisible : true;
    }
    
    /// show the text
    /// @param showText:Boolean - Show the text or not
    public function SetShowText(showText:Boolean)
    {
        m_ShowText = showText;
        m_Text._visible = m_ShowText;
        UpdateStatText();
    }
    
    /// How to display the text, as numbers or percent
    /// @param textType:Number - How is the text displayed, using the static HealtBar.STATTEXT_...
    public function SetTextType(textType:Number)
    {
        if (textType == STATTEXT_PERCENT || textType == STATTEXT_NUMBER)
        {
            m_TextType = textType;
            UpdateStatText();
        }
    }
	
	private function PositionUpcomingShields(top:Boolean)
	{
		if (top)
		{
			m_ThirdShield._x = m_ShieldBar._x + m_ShieldBar._width - (m_SecondShield._width + 5);
			if (m_ThirdShield._visible){ m_SecondShield._x = m_ShieldBar._x + m_ShieldBar._width - (m_SecondShield._width + 5) - (m_ThirdShield._width + 5); }
			else{ m_SecondShield._x = m_ThirdShield._x; }
			m_SecondShield._y = m_ThirdShield._y = m_Bar._y - (m_SecondShield._height + 5);
		}
		else
		{
			m_SecondShield._x = m_ShieldBar._x + m_ShieldBar._width + 5;
			m_ThirdShield._x = m_SecondShield._x + m_SecondShield._width + 5;
			m_SecondShield._y = m_ThirdShield._y = m_Bar._y + (m_Bar._height/2) - (m_SecondShield._height/2);
		}
	}
	
	public function SetShieldsOnTop(top:Boolean)
	{
		if(top){ m_ShieldsOnTop = true; }
		else{ m_ShieldsOnTop = false; }
	}
}