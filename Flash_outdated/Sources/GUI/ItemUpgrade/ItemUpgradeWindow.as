import flash.geom.Point;
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.GameInterface.CraftingInterface;
import com.GameInterface.GUIModuleIF;

var m_Window:MovieClip;

var m_ConfigName:String;

function onLoad()
{
	m_ConfigName = "ItemUpgradeConfig";
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
	moduleIF.SignalStatusChanged.Connect( SlotModuleStatusChanged, this );
	SlotModuleStatusChanged( moduleIF, moduleIF.IsActive() );
	
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = LDBFormat.LDBGetText("MiscGUI", "ItemUpgradeTitle");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("ItemUpgradeContent");
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	
	//Default this to lean to the left so that the character sheet is visible
	m_Window._x = Math.max(0, Math.round((visibleRect.width / 2) - (m_Window.m_Background._width + 100)));
	m_Window._y = (visibleRect.height / 2) - (m_Window.m_Background._height / 2);
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}

function LoadArgumentsReceived ( args:Array ) : Void
{
	LoadConfig();
}

function LoadConfig()
{
    var config:Archive = DistributedValue.GetDValue(m_ConfigName, undefined)
    if (config != undefined)
    {
        var position:Point = config.FindEntry("Position", undefined);
        if (position != undefined && m_Window != undefined)
        {
            m_Window._x = position.x;
            m_Window._y = position.y;
        }
    }
}

function SaveConfig()
{
    var config:Archive = new Archive();
    config.AddEntry("Position", new Point(m_Window._x, m_Window._y));
    DistributedValue.SetDValue(m_ConfigName, config);
}

function SlotModuleStatusChanged( module:GUIModuleIF, isActive:Boolean )
{
    if (!isActive)
	{
		CloseWindowHandler();
	}
}

function CloseWindowHandler():Void
{
	CraftingInterface.EndCrafting();
	DistributedValue.SetDValue("ItemUpgradeWindow", false);
}

function onUnload()
{
	SaveConfig();
	CloseWindowHandler();
}