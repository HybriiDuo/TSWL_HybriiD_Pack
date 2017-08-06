import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import gfx.controls.ButtonBar;

var m_Window:MovieClip;
var m_Archive:Archive;
var m_ContentLoaded:Boolean;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	m_Window.SignalContentLoaded.Connect(SlotContentLoaded, this);

	m_Window.SetPadding(10);
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
	
	m_Window.m_ButtonBar.addEventListener("focusIn", this, "RemoveFocus");
	m_Window.m_ButtonBar.addEventListener("change", this, "TabSelected");
}

function TabSelected(event:Object)
{
	var tabIndex = (event != undefined && event.index != undefined) ? event.index : 0;
	if (m_ContentLoaded)
	{
		m_Archive = m_Window.m_Content.OnModuleDeactivated();
		m_ContentLoaded = false;
	}
	switch(tabIndex)
	{
		case 0:
			m_Window.SetContent("MountInventoryContent");
			break;
		case 1:
			m_Window.SetContent("PetInventoryContent");
			break;
		default:
			m_Window.SetContent("MountInventoryContent");
	}
}

function SlotContentLoaded() : Void
{
	m_Window.m_Content.OnModuleActivated(m_Archive);
	m_ContentLoaded = true;
}

function OnModuleActivated(config:Archive):Void
{
	m_Archive = config;
	m_Window._x = config.FindEntry("WindowX", m_Window._x);
	m_Window._y = config.FindEntry("WindowY", m_Window._y);
	
	m_Window.m_ButtonBar.dataProvider = [ { label: LDBFormat.LDBGetText("GenericGUI", "MountInventory"), data:"MountInventoryContent" },
										  { label: LDBFormat.LDBGetText("GenericGUI", "PetInventory"), data:"PetInventoryContent" }
										];
	m_Window.m_ButtonBar.selectedIndex = config.FindEntry("CurrentTab", 0);
}

function OnModuleDeactivated()
{
	m_Archive = new Archive();
	if (m_ContentLoaded)
	{
		m_Archive = m_Window.m_Content.OnModuleDeactivated();
	}
	m_Archive.AddEntry("WindowX", m_Window._x);
	m_Archive.AddEntry("WindowY", m_Window._y);
	m_Archive.AddEntry("CurrentTab", m_Window.m_ButtonBar.selectedIndex);
	return m_Archive;
}

function CloseWindowHandler():Void
{
	DistributedValue.SetDValue("petInventory_window", false);
}
function RemoveFocus():Void
{
	Selection.setFocus(null);
}