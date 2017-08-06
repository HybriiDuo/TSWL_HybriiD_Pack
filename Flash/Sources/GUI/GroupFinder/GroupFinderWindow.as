import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;

var m_Window:MovieClip;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "GroupFinderTitle");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("GroupFinderContent");
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}
function OnModuleActivated(archive:Archive)
{
    var visibleRect = Stage["visibleRect"];
	var defaultX = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	var defaultY = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
    var x:Number = archive.FindEntry("WindowX", defaultX);
    var y:Number = archive.FindEntry("WindowY", defaultY);
    
    if (x > visibleRect.width || x < -m_Window._width)
    {
        x = defaultX;
    }
    if (y > visibleRect.height || y < -m_Window._height)
    {
        y = defaultY;
    }
    m_Window._x = x;
    m_Window._y = y;
	
	var roles:Array = archive.FindEntryArray("SelectedRoles");
	if (roles == undefined)
	{
		roles = new Array();
	}
	m_Window.m_Content.SetRoles(roles);
}

function OnModuleDeactivated()
{
    var archive:Archive = m_Window.m_Content.BuildArchive();    
    archive.AddEntry("WindowX", m_Window._x);
    archive.AddEntry("WindowY", m_Window._y);

    return archive;
}

function CloseWindowHandler():Void
{
	DistributedValue.SetDValue("groupFinder_window", false);
}