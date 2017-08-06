//Imports
import com.Utils.LDBFormat;
import com.Utils.Archive;
import com.GameInterface.ProjectUtils;
import com.GameInterface.DistributedValue;

//On Load
function onLoad()
{
    m_Window.SetTitle(LDBFormat.LDBGetText("GenericGUI", "PvPSpoils_WindowTitle"), "left");
    m_Window.SetPadding(10);
	m_Window.SetContent("Content");
    
    m_Window.ShowCloseButton(true);
    m_Window.ShowStroke(false);
    m_Window.ShowResizeButton(false);  
    
    var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
    
    m_Window._x = visibleRect.width / 2 - m_Window._width / 2;
    m_Window._y = visibleRect.height / 2 - m_Window._height / 2;
    
    m_Window.SignalClose.Connect(CloseWindowHandler, this);
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

//Close Window Handler
function CloseWindowHandler():Void
{
    DistributedValue.SetDValue("pvp_spoils_window", false);
}