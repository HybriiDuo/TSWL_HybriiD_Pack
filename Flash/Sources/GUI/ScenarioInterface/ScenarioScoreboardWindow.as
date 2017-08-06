import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.GameInterface.GUIModuleIF;
import gfx.controls.Button;

var m_Window:MovieClip;
var m_MinimizeButton:Button;
var m_ExitButton:Button;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "ScenarioScoreboard");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("ScenarioScoreboardContent");
	
	m_Window.ShowCloseButton(false);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	m_Window.SetDraggable(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_MinimizeButton._x = m_Window._x + m_Window.m_Content._width -3;
	m_MinimizeButton._y = m_Window._y + 10;
	m_MinimizeButton.addEventListener("click", this, "MinimizeWindowHandler");
	m_MinimizeButton.disableFocus = true;
	
	m_ExitButton.addEventListener("click", this, "MaximizeWindowHandler");
	m_ExitButton._visible = false;
	m_ExitButton.disableFocus = true;
	
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
    moduleIF.SignalStatusChanged.Connect( CloseWindowHandler, this );
}

function CloseWindowHandler():Void
{
	this.UnloadClip();
}

function MinimizeWindowHandler():Void
{
	m_Window._visible = false;
	m_MinimizeButton._visible = false;
	
	var exitIcon:MovieClip = attachMovie("ExitIcon", "exitIcon", getNextHighestDepth());	
	exitIcon._x = m_Window._x + (m_Window.m_Content._width/2) - (exitIcon._width/2);
	exitIcon._y = m_Window._y + (m_Window.m_Content._height/2) - (exitIcon._height/2);
	
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	var gotoX = visibleRect.width - m_ExitButton._width - 215;
	var gotoY = 130;
	
	exitIcon.tweenTo(0.3, { _x:gotoX, _y:gotoY }, Strong.easeIn);
	exitIcon.onTweenComplete = function()
	{
		m_ExitButton._visible = true;
		exitIcon.removeMovieClip();
	}
	
	m_ExitButton._x = gotoX;
	m_ExitButton._y = gotoY;
}

function MaximizeWindowHandler():Void
{
	m_Window._visible = true;
	m_MinimizeButton._visible = true;
	m_ExitButton._visible = false;
}