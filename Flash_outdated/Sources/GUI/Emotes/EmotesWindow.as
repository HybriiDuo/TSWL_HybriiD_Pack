import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;

var m_Window:MovieClip;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = LDBFormat.LDBGetText("MiscGUI", "EmotesTitle");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("EmotesContent");
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}

function OnModuleDeactivated():Archive
{
	var archive:Archive = new Archive();
	archive.AddEntry("WindowX", m_Window._x);
	archive.AddEntry("WindowY", m_Window._y);
	return archive;       
}

function OnModuleActivated(config:Archive)
{
	if (config != undefined)
	{
		m_Window._x = config.FindEntry("WindowX", m_Window._x);
		m_Window._y = config.FindEntry("WindowY", m_Window._y);
	}
}

function CloseWindowHandler():Void
{
	DistributedValue.SetDValue("emotes_window", false);
}