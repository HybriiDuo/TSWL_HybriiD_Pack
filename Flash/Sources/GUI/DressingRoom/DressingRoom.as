import com.GameInterface.MathLib.Vector3;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Camera;
import com.GameInterface.DressingRoomNode;
import com.Utils.Archive;

//Componenets from FLA
var m_RightPanel:MovieClip;

//Variables
var m_CharacterPosition:Vector3;
var m_CharacterRotation:Number;
var m_Archive:Archive;

//Statics


function onLoad():Void
{
	m_RightPanel.SignalCloseDressingRoom.Connect(this, CloseDressingRoom);
	m_LeftPanel.SignalEquipSlotSelected.Connect(this, SlotEquipSlotSelected);
	m_LeftPanel.SignalCategorySelected.Connect(this, SlotCategorySelected);
	Layout();
	Character.ToggleVanityMode(true);
}

function onUnload():Void
{
}

function ResizeHandler( h, w, x, y ):Void
{
	Layout();
}

function Layout()
{
	m_LeftPanel._x = 100;
	m_LeftPanel._y = Stage.height/2 - m_LeftPanel._height/2;
	m_RightPanel._x = Stage.width - m_RightPanel._width - 100;
	m_RightPanel._y = Stage.height/2 - m_LeftPanel._height/2;
	
	//Adjust for very low screen widths
	if (Math.abs((m_LeftPanel._x + m_LeftPanel._width) - m_RightPanel._x) < 400)
	{
		m_LeftPanel._x = 0;
		m_RightPanel._x = Stage.width - m_RightPanel._width;
	}
}

function SlotEquipSlotSelected():Void
{
	m_RightPanel.ClearStickyPreview();
}

function SlotCategorySelected(node:DressingRoomNode):Void
{
	m_RightPanel.SetData(node);
}

function CloseDressingRoom():Void
{
	DistributedValue.SetDValue("dressingRoom_window", false);
}

function OnModuleActivated(config:Archive):Void
{
	m_Archive = config;
	m_LeftPanel.OnModuleActivated(m_Archive);
}

function OnModuleDeactivated()
{
	m_Archive = new Archive();
	m_Archive = m_LeftPanel.OnModuleDeactivated();
	return m_Archive;
}