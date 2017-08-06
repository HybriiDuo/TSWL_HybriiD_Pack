import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;

var m_Window:MovieClip;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = "";
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("GroupFinderReadyPromptContent");
	
	m_Window.ShowCloseButton(false);
	m_Window.ShowStroke(true);
	m_Window.ShowResizeButton(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}

function CloseWindowHandler():Void
{
	DistributedValue.SetDValue("groupFinder_readyPrompt", false);
}