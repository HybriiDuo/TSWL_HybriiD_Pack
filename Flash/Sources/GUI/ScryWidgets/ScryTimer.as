//Imports
import com.GameInterface.Utils;
import com.GameInterface.Game.Character;
import com.GameInterface.WaypointInterface;
import com.Utils.Colors;
import com.GameInterface.ScryWidgets;
import com.Utils.LDBFormat;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.DistributedValue;
import mx.utils.Delegate;

var m_Timer:TextField;
var m_Text:TextField;
var m_TimeStarted:Number;
var m_Duration:Number;
var m_CountDown:Boolean;
var m_TimerID:Number;
var m_SoundID:Number;
var m_FlashColor:Number;
var m_PlayfieldID:Number;

var FLASH_FAILURE = 1;
var FLASH_SUCCESS = 2;

var m_FlashOn:Boolean;
var m_ResolutionScaleMonitor:DistributedValue;
var m_ScaleMonitor:DistributedValue;
var m_VisibilityMonitor:DistributedValue;

var m_EditModeMask:MovieClip;

function onLoad()
{
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	com.Utils.GlobalSignal.SignalInterfaceOptionsReset.Connect(SlotUpdateLayout, this);
	SlotUpdateLayout();
	
	m_playfieldID = Character.GetClientCharacter().GetPlayfieldID();
	WaypointInterface.SignalPlayfieldChanged.Connect(SlotPlayfieldChanged, this);
	ScryWidgets.SignalScryMessage.Connect(SlotScryMessage, this);
	
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
    moduleIF.SignalStatusChanged.Connect( HideModuleChanged, this );
    
    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
	m_ScaleMonitor = DistributedValue.Create("ScryTimerScale");
	m_ScaleMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
	m_VisibilityMonitor = DistributedValue.Create( "ScryTimerEnabled" );
	m_VisibilityMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
	
	m_Text.text = "";
	m_TimeStarted = Utils.GetServerUpTime();
	
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
	com.Utils.GlobalSignal.SignalScryTimerLoaded.Emit(true);
}

function onUnload()
{
	com.Utils.GlobalSignal.SignalScryTimerLoaded.Emit(false);
	clearInterval( m_TimerID );
	clearInterval( m_SoundID );
	clearInterval( m_ColorID );
}

function LoadArgumentsReceived ( args:Array ) : Void
{
	if (args != undefined)
	{
		m_Text.text = LDBFormat.LDBGetText("MiscGUI", args[0]);
		var timerFlash:Number = args[1];
		m_TimeStarted = args[2];
		m_Duration = args[3];
		m_CountDown = false;
		if (m_Duration != undefined)
		{
			m_CountDown = true;
		}
		if (timerFlash == FLASH_FAILURE){ m_FlashColor = Colors.e_ColorTimeoutFail; }
		if (timerFlash == FLASH_SUCCESS){ m_FlashColor = Colors.e_ColorTimeoutSuccess; }
		
		m_TimerID = setInterval(OnUpdateTimer, 100);
		
		if (m_Text.text != "")
		{
			m_Timer._y += 5;
		}
	}
	
    OnUpdateTimer();
}

function SlotUpdateLayout()
{
	this._visible = DistributedValue.GetDValue("ScryTimerEnabled", true);
	this._xscale = this._yscale = DistributedValue.GetDValue("ScryTimerScale", 100);
	
	var visibleRect = Stage["visibleRect"];
	
	var xPos:DistributedValue = DistributedValue.Create("ScryTimerX");
	var yPos:DistributedValue = DistributedValue.Create("ScryTimerY");
	
	if (xPos.GetValue() == "undefined") { xPos.SetValue(visibleRect.width - m_PanelBackground._width - 215); }
	if (yPos.GetValue() == "undefined") { yPos.SetValue(70); }
	this._x = xPos.GetValue();
    this._y = yPos.GetValue();
	m_Timer._x = m_PanelBackground._x;
	m_Timer._y = (m_PanelBackground._y + (m_PanelBackground._height / 2) - (m_Timer._height / 2));
	m_Text._x = m_PanelBackground._x;
	m_Text._y = m_PanelBackground._y;
}

function SlotPlayfieldChanged(newPlayfield:Number)
{
	if (m_playfieldID != newPlayfield)
	{
		CloseWindowHandler();
	}
}

function HideModuleChanged(module:GUIModuleIF, isActive:Boolean)
{
	if(isActive) { this._alpha = 100; }
	else { this._alpha = 0; }
}

function CloseWindowHandler()
{
	this.UnloadClip();
}

function SlotScryMessage(messageArray:Object)
{
	var messageType = messageArray.messageType;
	switch( messageType )
	{
		case "FormatScryTimer":
			clearInterval( m_TimerID );
			clearInterval( m_SoundID );
			clearInterval( m_ColorID );
			m_TimerID = undefined;
			m_SoundID = undefined;
			m_ColorID = undefined;
			Colors.ApplyColor(m_PanelBackground.m_Background, 0x000000);
			m_PanelBackground.m_Background._alpha = 50;
			m_Timer._y = (m_PanelBackground._y + (m_PanelBackground._height / 2) - (m_Timer._height / 2));
			var reloadArray = [messageArray.text, Number(messageArray.timerFlash), Number(messageArray.startTime), Number(messageArray.duration)];
			LoadArgumentsReceived(reloadArray);
			break;
		case "ChangeScryTimerText":
			m_Text.text = LDBFormat.LDBGetText("MiscGUI", messageArray.text);
			break;
		default:
	}
}

function OnUpdateTimer() : Void
{
	if (m_CountDown)
	{
		var timeLeft:Number = (m_TimeStarted + m_Duration - Utils.GetServerUpTime());
		if ( timeLeft >= 0 )
		{
			m_Timer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", Math.floor(timeLeft / 60), Math.floor(timeLeft % 60) );
			if (timeLeft <= 10)
			{
				if (m_SoundID == undefined)
				{
					m_SoundID = setInterval(OnSoundTick, 1000);
					if (m_FlashColor != undefined && m_ColorID == undefined)
					{
						m_FlashOn = false;
						Colors.ApplyColor(m_PanelBackground.m_Background, m_FlashColor)
						m_ColorID = setInterval(ToggleFlash, 500);
					}
				}
			}
		}
		else
		{
			m_Timer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", 0, 0 );
			clearInterval( m_TimerID );
			clearInterval( m_SoundID );
			clearInterval( m_ColorID );
			m_TimerID = undefined;
			m_SoundID = undefined;
			m_ColorID = undefined;
			if (m_FlashColor != undefined)
			{
				m_PanelBackground.m_Background._alpha = 100;
			}
		}
	}
	else
	{
		var currTime:Number = (Utils.GetServerUpTime() - m_TimeStarted);
		m_Timer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", Math.floor(currTime / 60), Math.floor(currTime % 60) );
	}
}

function OnSoundTick() : Void
{
	if (m_FlashColor == Colors.e_ColorTimeoutFail)
	{
		Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_beep_single.xml");
	}
	else
	{
		Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_click_tiny.xml");
	}
}

function ToggleFlash()
{
	if (m_FlashOn){ m_PanelBackground.m_Background.tweenTo(0.3, { _alpha:100 }, Strong.easeOut); }
	else { m_PanelBackground.m_Background.tweenTo(0.3, { _alpha:20 }, Strong.easeOut); }
	m_FlashOn = !m_FlashOn;
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if (edit)
	{
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("ScryTimerScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = m_ScaleMonitor.GetValue() / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "ScryTimerX" );
	var newY:DistributedValue = DistributedValue.Create( "ScryTimerY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);	
}

function LayoutEditModeMask()
{
	m_EditModeMask._x = m_PanelBackground._x - 5;
	m_EditModeMask._y = m_PanelBackground._y - 5;
	m_EditModeMask._width = m_PanelBackground._width + 10;
	m_EditModeMask._height = m_PanelBackground._height + 13;
}