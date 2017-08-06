import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;

var m_Window:MovieClip;

var m_GroupFinderX:Number;
var m_GroupFinderY:Number;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = "";
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("GroupFinderRoleSelectionContent");
	
	m_Window.ShowCloseButton(false);
	m_Window.ShowStroke(true);
	m_Window.ShowResizeButton(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}
function OnModuleActivated(archive:Archive)
{
	m_GroupFinderX = archive.FindEntry("WindowX");
    m_GroupFinderY = archive.FindEntry("WindowY");
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
	if (m_GroupFinderX != undefined)
	{
    	archive.AddEntry("WindowX", m_GroupFinderX);
	}
	if (m_GroupFinderY != undefined)
	{
    	archive.AddEntry("WindowY", m_GroupFinderY);
	}

    return archive;
}

function CloseWindowHandler():Void
{
	DistributedValue.SetDValue("groupFinder_roleSelect", false);
}