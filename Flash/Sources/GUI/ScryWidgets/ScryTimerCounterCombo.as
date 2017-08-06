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
var m_LeftMax:Number;
var m_LeftCurrent:Number;
var m_LeftColor:Number;
var m_RightMax:Number;
var m_RightCurrent:Number;
var m_RightColor:Number;
var m_PlayfieldID:Number;
var m_IsPaused:Boolean;
var m_PauseTimestamp:Number;
var m_PausedTime:Number;

var m_LeftIcons:Array;
var m_RightIcons:Array;

var FLASH_FAILURE = 1;
var FLASH_SUCCESS = 2;

var ICON_PADDING = 5;
var ICON_WIDTH = 18.3;
var ICON_HEIGHT = 18;

var m_FlashOn:Boolean;
var m_ResolutionScaleMonitor:DistributedValue;
var m_ScaleMonitor:DistributedValue;
var m_VisibilityMonitor:DistributedValue;

var m_EditModeMask:MovieClip;

function onLoad()
{
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	com.Utils.GlobalSignal.SignalInterfaceOptionsReset.Connect(SlotUpdateLayout, this);
	
	m_playfieldID = Character.GetClientCharacter().GetPlayfieldID();
	WaypointInterface.SignalPlayfieldChanged.Connect(SlotPlayfieldChanged, this);
	ScryWidgets.SignalScryMessage.Connect(SlotScryMessage, this);
	
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
    moduleIF.SignalStatusChanged.Connect( HideModuleChanged, this );
    
    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
	m_ScaleMonitor = DistributedValue.Create("ScryTimerCounterComboScale");
	m_ScaleMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
	m_VisibilityMonitor = DistributedValue.Create( "ScryTimerCounterComboEnabled" );
	m_VisibilityMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
	
	m_Text.text = "";
	m_TimeStarted = Utils.GetServerUpTime();
	m_IsPaused = true;
	
	m_LeftMax = m_LeftCurrent = 10;
	m_RightMax = m_RightCurrent = 10;
	m_LeftColor = 0xE7821F;
	m_RightColor = 0x231548;
	UpdateCounter();
	SlotUpdateLayout();
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
	com.Utils.GlobalSignal.SignalScryTimerCounterComboLoaded.Emit(true);
}

function onUnload()
{
	com.Utils.GlobalSignal.SignalScryTimerCounterComboLoaded.Emit(false);
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
		m_LeftMax = args[4];
		m_LeftCurrent = args[5];
		m_LeftColor = args[6];
		m_RightMax = args[7];
		m_RightCurrent = args[8];
		m_RightColor = args[9];
		m_CountDown = false;
		if (m_Duration != 0)
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
	
	m_PausedTime = 0;
	m_IsPaused = false;
		
    OnUpdateTimer();
	UpdateCounter();
}

function SlotUpdateLayout()
{
	this._visible = DistributedValue.GetDValue("ScryTimerCounterComboEnabled", true);
	this._xscale = this._yscale = DistributedValue.GetDValue("ScryTimerCounterComboScale", 100);
	
	var visibleRect = Stage["visibleRect"];
	
	var xPos:DistributedValue = DistributedValue.Create("ScryTimerCounterComboX");
	var yPos:DistributedValue = DistributedValue.Create("ScryTimerCounterComboY");
	
	if (xPos.GetValue() == "undefined") { xPos.SetValue(visibleRect.width/2 - m_PanelBackground._width/2); }
	if (yPos.GetValue() == "undefined") { yPos.SetValue(35); }
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
		case "FormatScryTimerCounterCombo":
			clearInterval( m_TimerID );
			clearInterval( m_SoundID );
			clearInterval( m_ColorID );
			m_TimerID = undefined;
			m_SoundID = undefined;
			m_ColorID = undefined;
			Colors.ApplyColor(m_PanelBackground.m_Background, 0x000000);
			m_PanelBackground.m_Background._alpha = 50;
			m_Timer._y = (m_PanelBackground._y + (m_PanelBackground._height / 2) - (m_Timer._height / 2));
			var reloadArray = [messageArray.text, Number(messageArray.timerFlash), Number(messageArray.startTime), Number(messageArray.duration), 
							   Number(messageArray.leftMax), Number(messageArray.leftCurrent), Number(messageArray.leftColor),
							   Number(messageArray.rightMax), Number(messageArray.rightCurrent), Number(messageArray.rightColor)];
			LoadArgumentsReceived(reloadArray);
			break;
		case "ChangeScryTimerCounterComboText":
			m_Text.text = LDBFormat.LDBGetText("MiscGUI", messageArray.text);
			break;
		case "ChangeScryTimerCounterComboCount":
			m_LeftMax = Number(messageArray.leftMax);
			m_LeftCurrent = Number(messageArray.leftCurrent);
			m_LeftColor = Number(messageArray.leftColor);
			m_RightMax = Number(messageArray.rightMax);
			m_RightCurrent = Number(messageArray.rightCurrent);
			m_RightColor = Number(messageArray.rightColor);
			UpdateCounter();
			break;
		case "PauseScryTimerCounterCombo":
			m_IsPaused = true;
			m_PauseTimestamp = Utils.GetServerUpTime();
			m_Timer.text = "--:--";
			break;
		case "UnpauseScryTimerCounterCombo":
			m_PausedTime += Utils.GetServerUpTime() - m_PauseTimestamp;
			m_IsPaused = false;
			OnUpdateTimer();
			break;
		default:
	}
}

function UpdateCounter()
{
	ClearCounter();
	m_LeftIcons = new Array();
	var xPos:Number = m_PanelBackground._x - ICON_PADDING;
	var yPos:Number = m_PanelBackground._y + m_PanelBackground._height/2 - ICON_HEIGHT/2 + ICON_PADDING;
	if (m_RightMax <= 0)
	{
		xPos = (m_PanelBackground._x + m_PanelBackground._width/2) + (((ICON_WIDTH + (ICON_PADDING*1.5)) * m_LeftMax)/2) + ICON_PADDING/2;
		yPos = m_PanelBackground._y + m_PanelBackground._height + ICON_PADDING * 4;
	}
	var totalWidth:Number = 0 - ICON_PADDING;
	for (var i:Number = 0; i<m_LeftMax; i++)
	{
		var newIcon:MovieClip = this.attachMovie("Character", "LeftIcon_"+i, this.getNextHighestDepth());
		xPos = xPos - newIcon._width - ICON_PADDING;
		newIcon._x = xPos;
		newIcon._y = yPos;
		Colors.ApplyColor(newIcon.m_Icon, m_LeftColor);
		if (i >= m_LeftCurrent)
		{
			newIcon.m_Icon._alpha = 50;
		}
		else
		{
			newIcon.m_Slash._visible = false;
		}
		totalWidth += newIcon._width + ICON_PADDING;
		m_LeftIcons.push(newIcon);									
	}
	m_LeftBG._x = xPos - ICON_PADDING;
	m_LeftBG._y = yPos - ICON_PADDING * 2;
	m_LeftBG._width = totalWidth + ICON_PADDING * 2;
	
	m_RightIcons = new Array();
	if (m_RightMax <=0)
	{
		m_RightBG._visible = false;
	}
	xPos = m_PanelBackground._x + m_PanelBackground._width + ICON_PADDING * 2;
	totalWidth = 0;
	for (var i:Number = 0; i<m_RightMax; i++)
	{
		var newIcon:MovieClip = this.attachMovie("Character", "RightIcon_"+i, this.getNextHighestDepth());
		newIcon._x = xPos;
		newIcon._y = m_PanelBackground._y + m_PanelBackground._height/2 - newIcon._height/2 + ICON_PADDING;
		xPos += newIcon._width + ICON_PADDING;
		Colors.ApplyColor(newIcon.m_Icon, m_RightColor);
		if (i >= m_RightCurrent)
		{
			newIcon.m_Icon._alpha = 50;
		}
		else
		{
			newIcon.m_Slash._visible = false;
		}
		totalWidth += newIcon._width + ICON_PADDING
		m_RightIcons.push(newIcon);											
	}
	m_RightBG._x = m_PanelBackground._x + m_PanelBackground._width + ICON_PADDING;
	m_RightBG._y = m_PanelBackground._y + m_PanelBackground._height/2 - newIcon._height/2 - ICON_PADDING;
	m_RightBG._width = totalWidth + ICON_PADDING;
}

function ClearCounter()
{
	for (var i:Number = 0; i<m_LeftIcons.length; i++)
	{
		m_LeftIcons[i].removeMovieClip();
	}
	for (var i:Number = 0; i<m_RightIcons.length; i++)
	{
		m_RightIcons[i].removeMovieClip()
	}
	m_LeftBG._x = m_LeftBG._y = m_RightBG._x = m_RightBG._y = 0;
}

function OnUpdateTimer()
{
	if (!m_IsPaused)
	{
		if (m_CountDown)
		{
			var timeLeft:Number = (m_TimeStarted + m_Duration + m_PausedTime - Utils.GetServerUpTime());
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
			var currTime:Number = (Utils.GetServerUpTime() - m_TimeStarted - m_PausedTime);
			m_Timer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", Math.floor(currTime / 60), Math.floor(currTime % 60) );
		}
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
			var scaleDV:DistributedValue = DistributedValue.Create("ScryTimerCounterComboScale");
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
	
	var newX:DistributedValue = DistributedValue.Create( "ScryTimerCounterComboX" );
	var newY:DistributedValue = DistributedValue.Create( "ScryTimerCounterComboY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);	
}

function LayoutEditModeMask()
{
	m_EditModeMask.swapDepths(this.getNextHighestDepth());
	m_EditModeMask._x = Math.min(m_PanelBackground._x - 5, m_LeftBG._x - 5);
	m_EditModeMask._y = m_PanelBackground._y - 5;
	if (m_RightMax <= 0)
	{
		m_EditModeMask._width = Math.max(m_PanelBackground._width + 10, m_LeftBG._width + 10);
	}
	else
	{
		m_EditModeMask._width = m_LeftBG._width + ICON_PADDING * 2 + m_PanelBackground._width + ICON_PADDING + m_RightBG._width + ICON_PADDING * 2;
	}
	m_EditModeMask._height = Math.max(m_PanelBackground._height + 13, m_LeftBG._y + m_LeftBG._height + 10);
}