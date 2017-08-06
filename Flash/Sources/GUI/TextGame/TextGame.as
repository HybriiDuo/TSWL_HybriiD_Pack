import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.GameInterface.DistributedValue;
import com.GameInterface.TextGameLoader;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.Game.Character;
import gfx.controls.UILoader;

var m_Window:MovieClip;
var m_CharacterID:ID32;

function onLoad()
{
	Character.ExitReticuleMode();
	var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
    escapeNode.SignalEscapePressed.Connect( CloseWindowHandler, this );
    com.GameInterface.EscapeStack.Push( escapeNode );
	
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
	moduleIF.SignalStatusChanged.Connect( SlotModuleStatusChanged, this );
	m_CharacterID = Character.GetClientCharID();
	
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "TextGameTitle");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("TextGameContent");
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}

function LoadArgumentsReceived ( args:Array ) : Void
{
	TextGameLoader.LoadTextGame(args[0]);
}

function SlotModuleStatusChanged(module:GUIModuleIF, isActive:Boolean)
{
	//It's possible that this is called because a player logged off and logged in a different character!
	if (m_CharacterID.Equal(Character.GetClientCharID()))
	{
		_visible = isActive;
	}
	else
	{
		CloseWindowHandler();
	}
}

function CloseWindowHandler():Void
{
    this.UnloadClip();
}
