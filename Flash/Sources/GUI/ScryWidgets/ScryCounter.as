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

var m_Display:TextField;
var m_MaxCount:Number;
var m_CurrentCount:Number;
var m_Text:String;
var m_Color:Number;
var m_ResolutionScaleMonitor:DistributedValue;
var m_ScaleMonitor:DistributedValue;
var m_VisibilityMonitor:DistributedValue;

var COLOR_WHITE = 0;
var COLOR_GREEN = 1;
var COLOR_YELLOW = 2;
var COLOR_RED = 3;

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
	m_ScaleMonitor = DistributedValue.Create("ScryCounterScale");
	m_ScaleMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
	m_VisibilityMonitor = DistributedValue.Create( "ScryCounterEnabled" );
	m_VisibilityMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
	
	m_Text = "";
	m_MaxCount = 0;
	m_CurrentCount = 0;
	m_Color = 0;	
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
	
	com.Utils.GlobalSignal.SignalScryCounterLoaded.Emit(true);
}

function onUnload()
{
	com.Utils.GlobalSignal.SignalScryCounterLoaded.Emit(false);
}

function SlotUpdateLayout()
{
	this._visible = DistributedValue.GetDValue("ScryCounterEnabled", true);
	this._xscale = this._yscale = DistributedValue.GetDValue("ScryCounterScale", 100);
	
	var visibleRect = Stage["visibleRect"];
	
	var xPos:DistributedValue = DistributedValue.Create("ScryCounterX");
	var yPos:DistributedValue = DistributedValue.Create("ScryCounterY");
	
	if (xPos.GetValue() == "undefined") { xPos.SetValue(visibleRect.width - m_PanelBackground._width - 215); }
	if (yPos.GetValue() == "undefined") { yPos.SetValue(30); }
	this._x = xPos.GetValue();
    this._y = yPos.GetValue();
	m_Display._x = m_PanelBackground._x;
	m_Display._y = (m_PanelBackground._y + (m_PanelBackground._height / 2) - (m_Display._height / 2));
}

function LoadArgumentsReceived ( args:Array ) : Void
{
	if (args != undefined)
	{
		m_Text = LDBFormat.LDBGetText("MiscGUI", args[0]);
		m_MaxCount = args[1];
		m_CurrentCount = args[2];
		m_Color = args[3];
	}
	
	UpdateCount();
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

function UpdateCount():Void
{
	var countString:String = m_CurrentCount + "/" + m_MaxCount;
	if (m_Text != "" && m_Text != undefined){ countString = countString + " " + m_Text; }
	m_Display.text = countString;
	switch(m_Color)
	{
		case COLOR_WHITE:
			m_Display.textColor = Colors.e_ColorWhite;
			break;
		case COLOR_GREEN:
			m_Display.textColor = Colors.e_ColorTimeoutSuccess;
			break;
		case COLOR_YELLOW:
			m_Display.textColor = Colors.e_ColorYellow;
			break;
		case COLOR_RED:
			m_Display.textColor = Colors.e_ColorTimeoutFail;
			break;
		default:
			m_Display.textColor = Colors.e_ColorWhite;
	}
	Colors.ApplyColor(m_PanelBackground.m_Background, 0xCCCCCC);
	m_PanelBackground.m_Background.tweenTo(0.2, {_alpha:0}, None.easeNone);
	m_PanelBackground.m_Background.onTweenComplete = function()
	{
		Colors.ApplyColor(m_PanelBackground.m_Background, 0x000000);
		this.tweenTo(0.2, {_alpha:50}, None.easeNone);
		this.onTweenComplete = undefined;
	}
}

function SlotPlayfieldChanged(newPlayfield:Number)
{
	if (m_playfieldID != newPlayfield)
	{
		CloseWindowHandler();
	}
}

function SlotScryMessage(messageArray:Array)
{
	var messageType = messageArray.messageType;
	switch( messageType )
	{
		case "FormatScryCounter":
			var reloadArray = [messageArray.text, Number(messageArray.maxCount), Number(messageArray.currentCount), Number(messageArray.color)];
			LoadArgumentsReceived(reloadArray);
			break;
		case "UpdateScryCounterMaxCount":
			m_MaxCount = Number(messageArray.maxCount);
			UpdateCount();
			break;
		case "UpdateScryCounterCurrentCount":
			m_CurrentCount = Number(messageArray.currentCount);
			UpdateCount();
			break;
		case "UpdateScryCounterText":
			m_Text = LDBFormat.LDBGetText("GenericGUI", messageArray.text);
			UpdateCount();
			break;
		case "UpdateScryCounterColor":
			m_Color = Number(messageArray.color);
			UpdateCount();
			break;
		default:
	}
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if (edit)
	{
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("ScryCounterScale");
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
	
	var newX:DistributedValue = DistributedValue.Create( "ScryCounterX" );
	var newY:DistributedValue = DistributedValue.Create( "ScryCounterY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);	
}

function LayoutEditModeMask()
{
	m_EditModeMask._x = m_PanelBackground._x - 5;
	m_EditModeMask._y = m_PanelBackground._y - 5;
	m_EditModeMask._width = m_PanelBackground._width + 10;
	m_EditModeMask._height = m_PanelBackground._height + 10;
}