import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import GUI.LootBox.LootBoxContent;
import com.Utils.Archive;
import com.GameInterface.Game.Character;

var m_Window:MovieClip;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "LootBoxTitle");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("LootBoxContent");
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(true);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}

function OnModuleActivated(archive:Archive)
{

}

function OnModuleDeactivated()
{
	Character.SendLootBoxReply(false);
}

function CloseWindowHandler():Void
{
	DistributedValue.SetDValue("lootBox_window", false);
}