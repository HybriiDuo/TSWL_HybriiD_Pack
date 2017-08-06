import com.Utils.LDBFormat;
import com.GameInterface.ScenarioInterface;
import com.GameInterface.Game.Character;

var m_Window:MovieClip;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "ScenarioInterfaceTitle");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("ScenarioContent");
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseButtonClicked");
}

function CloseButtonClicked():Void
{
	Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_click_tiny.xml");
	CloseWindowHandler();
}

function CloseWindowHandler():Void
{
	ScenarioInterface.CloseSetupInterface();
}