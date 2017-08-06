import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.GameInterface.Lore;
import com.Utils.Archive;
import com.Utils.GlobalSignal;
import gfx.controls.ButtonBar;

var m_Window:MovieClip;
var m_Archive:Archive;
var m_ContentLoaded:Boolean;
var m_Initialized:Boolean;

function onLoad()
{	
	m_Window.SignalContentLoaded.Connect(SlotContentLoaded, this);
	m_Window.SetPadding(10);
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	m_Window._visible = false;
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
	
	m_Window.m_ButtonBar._x = 50;
	m_Window.m_ButtonBar.addEventListener("focusIn", this, "RemoveFocus");
	m_Window.m_ButtonBar.addEventListener("change", this, "TabSelected");
	GlobalSignal.SignalShowPassivesBar.Emit(true);
}

function onUnload()
{
	GlobalSignal.SignalShowPassivesBar.Emit(false);
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
			m_Window.SetContent("ActivesPage");
			break;
		case 1:
			m_Window.SetContent("PassivesPage");
			break;
		/*
		case 2:
			m_Window.SetContent("AuxPage");
			break;
		*/
		default:
			m_Window.SetContent("ActivesPage");
	}
}

function SlotContentLoaded() : Void
{
	m_Window.m_Content.OnModuleActivated(m_Archive);
	m_ContentLoaded = true;
	if (!m_Initialized)
	{
		var visibleRect = Stage["visibleRect"];
		var initialWidth = m_Window._width;
		var screenWidth = visibleRect.width;
		if (initialWidth > screenWidth)
		{
			this._xscale = this._yscale = (screenWidth/initialWidth)* 100;
		}
		
		m_Window._x = m_Archive.FindEntry("WindowX", Math.round((visibleRect.width / 2) - (m_Window._width / 2)));
		m_Window._y = m_Archive.FindEntry("WindowY", Math.round((visibleRect.height / 2) - (m_Window._height / 2)));
		m_Window._visible = true;
		m_Initialized = true;
	}
}

function OnModuleActivated(config:Archive):Void
{
	m_Archive = config;	
	m_Window.m_ButtonBar.dataProvider = [ { label: LDBFormat.LDBGetText("SkillhiveGUI", "ActiveAbilities"), data:"ActivesPage" },
										  { label: LDBFormat.LDBGetText("SkillhiveGUI", "PassiveAbilities"), data:"PassivesPage" }/*,
										  { label: LDBFormat.LDBGetText("SkillhiveGUI", "AuxilliaryAbilities"), data:"AuxPage" }*/
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
	DistributedValue.SetDValue("skillhive_window", false);
}
function RemoveFocus():Void
{
	Selection.setFocus(null);
}