//Imports
import com.GameInterface.ScryWidgets;
import com.GameInterface.WaypointInterface;
import com.GameInterface.Game.Character;
import com.Utils.LDBFormat;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.DistributedValue;

//Elements created in flash
var m_Window:MovieClip;

//Variables
var m_PlayfieldID:Number;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "MuseumDisplayTitle");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("MuseumDisplayContent");
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseButtonClicked");
	
	ScryWidgets.SignalScryMessage.Connect(SlotScryMessage, this);
	WaypointInterface.SignalPlayfieldChanged.Connect(SlotPlayfieldChanged, this);
	m_playfieldID = Character.GetClientCharacter().GetPlayfieldID();
	
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
    moduleIF.SignalStatusChanged.Connect( HideModuleChanged, this );
	
	var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
	escapeNode.SignalEscapePressed.Connect( CloseWindowHandler, this );
	com.GameInterface.EscapeStack.Push( escapeNode );

	Character.SignalCharacterEnteredReticuleMode.Connect(SlotCharacterEnteredReticuleMode, this);
	Character.ExitReticuleMode();
}

//Called when initial arguments are received
function LoadArgumentsReceived ( args:Array ) : Void
{
	if (args != undefined)
	{
		m_Window.m_Content.SetData(args);
	}
}

//Called when we get a new message from Scry
function SlotScryMessage(messageArray:Array)
{
	var messageType = messageArray.messageType;
	switch( messageType )
	{
		case "MuseumDisplayUpdate":
			var dataArray = [messageArray.header, messageArray.description,
							 messagearray.upgradeProgress1, messageArray.upgradeRequirement1,
							 messagearray.upgradeProgress2, messageArray.upgradeRequirement2,
							 messagearray.upgradeProgress3, messageArray.upgradeRequirement3,
							 messagearray.upgradeProgress4, messageArray.upgradeRequirement4,
							 messagearray.upgradeProgress5, messageArray.upgradeRequirement5,
							 messagearray.upgradeProgress6, messageArray.upgradeRequirement6,
							 messagearray.upgradeProgress7, messageArray.upgradeRequirement7,
							 messageArray.upgradeInstructions, messageArray.completeText];
			LoadArgumentsReceived(dataArray);
			break;
	}
}

function HideModuleChanged(module:GUIModuleIF, isActive:Boolean)
{
	if(isActive) { this._alpha = 100; }
	else { this._alpha = 0; }
}

function SlotPlayfieldChanged(newPlayfield:Number)
{
	if (m_playfieldID != newPlayfield)
	{
		CloseWindowHandler();
	}
}

function CloseButtonClicked():Void
{
	CloseWindowHandler();
}

function CloseWindowHandler():Void
{
	this.UnloadClip();
	Character.SetReticuleMode();
}

function SlotCharacterEnteredReticuleMode():Void
{
	CloseWindowHandler();
}