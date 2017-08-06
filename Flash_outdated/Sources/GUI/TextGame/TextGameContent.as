import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
import com.GameInterface.TextGame;
import com.GameInterface.TextGameRoom;
import com.GameInterface.TextGameEvent;
import com.GameInterface.TextGameLoader;
import com.GameInterface.Game.Character;

class GUI.TextGame.TextGameContent extends WindowComponentContent
{
	//Components created in .fla
	public var m_TextInput:TextField;
	public var m_DisplayText:TextField;
	public var m_TopText:TextField;
	public var m_Background:MovieClip;
	
	//Variables
	private var m_CurrentGame:TextGame;
	private var m_CurrentRoom:TextGameRoom;
	private var m_Error:Boolean;
	private var m_UseTranslation:Boolean;
	private var m_Inventory:Array;
	private var m_Character:Character;
	private var m_Keywords:Array;
	private var m_QuitCommand:String;
	private var m_InventoryCommand:String;
	private var m_HelpCommand:String;
	private var m_ErrorMsg:String;
	
	public function TextGameContent()
	{
		super();
		
		m_QuitCommand = LDBFormat.LDBGetText("MiscGUI", "TextGame_Quit");
		m_InventoryCommand = LDBFormat.LDBGetText("MiscGUI", "TextGame_Inventory");
		m_HelpCommand = LDBFormat.LDBGetText("MiscGUI", "TextGame_HelpCommand");
	}
	
	private function configUI()
	{
		TextGameLoader.SignalTextGameLoaded.Connect(SlotGameLoaded, this);
		
		m_TopText.background = true;
		m_TopText.backgroundColor = 0xFFFFFF;
		SetInputFocus();
		
        var keyListener:Object = new Object();
        keyListener.onKeyDown = Delegate.create(this, KeyDownEventHandler);
        Key.addListener(keyListener);
		
		m_Background.onPress = Delegate.create(this, SetInputFocus);
		
		m_UseTranslation = true;
		
		m_Character = Character.GetClientCharacter();
    	if (m_Character != undefined) { m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_activated.xml" ); }
	}
	
	private function SubmitInput()
	{
		var inputString:String = m_TextInput.text;
		//replace apostraphes with whitespace to facilitate French translations
		inputString = inputString.split("'").join(" ");
		//Break the input up into single words
		var inputArray:Array = inputString.split(" ");
		if (inputArray[0] == "")
		{
			return;
		}
		
		CheckDefaultCommands(inputArray);
		inputArray = RemoveNonKeywords(inputArray);
		
		var matchingEvent:TextGameEvent = null;
		var defaultEvent:TextGameEvent = null;
		//read the list of events and try to find a match
		for(var i=0; i<m_CurrentRoom.m_Events.length; i++)
		{
			//Default event has no action, target, or item. If we have an event like this it will trigger
			//instead of the error text if no other event is matched.
			if (currentEvent.m_Action != "" || currentEvent.m_Target != "" || currentEvent.m_InventoryItem != "")
			{
				var currentEvent = m_CurrentRoom.m_Events[i];
				var foundAction:Boolean = false;
				var foundTarget:Boolean = false;
				var foundInventoryItem:Boolean = false;
				var foundExtraKeyword:Boolean = false;
				
				var actionTranslate:String = GetText(currentEvent.m_Action);
				var targetTranslate:String = GetText(currentEvent.m_Target);
				var inventoryItemTranslate:String = GetText(currentEvent.m_InventoryItem);
				
				for(var j=0; j<inputArray.length; j++)
				{
					if(inputArray[j].toLowerCase() == actionTranslate.toLowerCase()){ foundAction = true; }
					else if(inputArray[j].toLowerCase() == targetTranslate.toLowerCase()){ foundTarget = true; }
					else if(inputArray[j].toLowerCase() == inventoryItemTranslate.toLowerCase() && CheckInventory(currentEvent.m_InventoryItem)){ foundInventoryItem = true; }
					else { foundExtraKeyword = true; }
				}
				if ((foundAction || currentEvent.m_Action == "") &&
					(foundTarget || currentEvent.m_Target == "") &&
					(foundInventoryItem || currentEvent.m_InventoryItem == "") &&
					(!foundExtraKeyword))
				{
					matchingEvent = m_CurrentRoom.m_Events[i];
				}
			}
			else
			{
				defaultEvent = m_CurrentRoom.m_Events[i];
			}
		}
		if (matchingEvent == null)
		{
			matchingEvent = defaultEvent;
		}
		if(matchingEvent != null)
		{
			//Add appropriate items to the inventory
			if(matchingEvent.m_ItemGet != "")
			{ 
				var getItem:Boolean = true;
				//Don't add the item if we already have one
				for (var i=0; i<m_Inventory.length; i++)
				{
					if (matchingEvent.m_ItemGet == m_Inventory[i])
					{
						getItem = false;
					}
				}
				if(getItem) { m_Inventory.push(matchingEvent.m_ItemGet); }
			}
			//Remove appropriate items from the inventory
			if(matchingEvent.m_ItemTake != "")
			{
				// * Is a wildcard that means take everything
				if(matchingEvent.m_ItemTake == "*")
				{
					m_Inventory = new Array();
				}
				else
				{
					var removeIndex = null;
					for(var i=0; i<m_Inventory.length; i++)
					{
						if(m_Inventory[i] == matchingEvent.m_ItemTake) { removeIndex = i; }
					}
					if (removeIndex != null) { m_Inventory.splice(removeIndex, 1); }
				}
			}
			//Go to the next room
			GoToRoom(matchingEvent.m_OutputId);
		}
		else
		{
			ShowErrorScreen(m_ErrorMsg);
		}
	}
	
	private function CheckDefaultCommands(inputArray:Array):Void
	{
		//Only accept default commands if they are the only word in the input
		if(inputArray.length == 1)
		{
			if(inputArray[0].toLowerCase() == m_QuitCommand.toLowerCase())
			{
				_parent._parent.CloseWindowHandler();
			}
			if(inputArray[0].toLowerCase() == m_InventoryCommand.toLowerCase())
			{
				var displayString:String = LDBFormat.LDBGetText("MiscGUI", "TextGame_CheckInventory") + " ";
				for (var i=0; i<m_Inventory.length; i++)
				{
					displayString += (GetText(m_Inventory[i]) + ", ");
				}
				if (m_Inventory.length != 0)
				{
					displayString = displayString.substr(0, displayString.length - 2);
				}
				ShowErrorScreen(displayString);
			}
			if(inputArray[0].toLowerCase() == m_HelpCommand.toLowerCase())
			{
				var helpText:String = LDBFormat.LDBGetText("MiscGUI", "TextGame_Help");
				helpText = helpText.split("\\n").join("\n");
				ShowErrorScreen(helpText);
			}
		}
	}
	
	private function CheckInventory(inventoryItem:String):Boolean
	{
		for (var i=0; i<m_Inventory.length; i++)
		{
			if(m_Inventory[i] == inventoryItem){ return true; }
		}
		ShowErrorScreen(LDBFormat.LDBGetText("MiscGUI", "TextGame_ItemNotFound") + " " + GetText(inventoryItem) + ".");
		return false;
	}
	
	private function RemoveNonKeywords(inputArray:Array):Array
	{
		outputArray = new Array();
		for (var i=0; i<m_Keywords.length; i++)
		{
			for (var j=0; j<inputArray.length; j++)
			{
				if(GetText(m_Keywords[i]).toLowerCase() == inputArray[j].toLowerCase())
				{
					outputArray.push(inputArray[j]);
				}
			}
		}
		return outputArray;
	}
	
	private function GoToRoom(roomId:Number)
	{
		m_Error = false;
		for(var i=0; i<m_CurrentGame.m_Rooms.length; i++)
		{
			if(m_CurrentGame.m_Rooms[i].m_Id == roomId)
			{
				//Set the room display
				m_CurrentRoom = m_CurrentGame.m_Rooms[i];
				m_TopText.text = GetText(m_CurrentRoom.m_Name);
				m_DisplayText.text = GetText(m_CurrentRoom.m_Description);
				if(m_CurrentRoom.m_Error != ""){ m_ErrorMsg = GetText(m_CurrentRoom.m_Error); }
				else{ m_ErrorMsg = LDBFormat.LDBGetText("MiscGUI", "TextGame_UnknownCommand"); }
				m_TextInput.text = "";
				
				//Find all keywords for this room
				m_Keywords = new Array();		
				for(var j=0; j<m_CurrentRoom.m_Events.length; j++)
				{
					var roomEvent:TextGameEvent = m_CurrentRoom.m_Events[j];
					var addAction:Boolean = true;
					var addTarget:Boolean = true;
					var addInventoryItem:Boolean = true;
					for(var k=0; k<m_Keywords.length; k++)
					{
						if(m_Keywords[k] == roomEvent.m_Action) { addAction = false; }
						if(m_Keywords[k] == roomEvent.m_Target) { addTarget = false; }
						if(m_Keywords[k] == roomEvent.m_InventoryItem) { addInventoryItem = false; }
					}
					if(addAction && roomEvent.m_Action != ""){ m_Keywords.push(roomEvent.m_Action); }
					if(addTarget && roomEvent.m_Target != ""){ m_Keywords.push(roomEvent.m_Target); }
					if(addInventoryItem && roomEvent.m_InventoryItem != ""){ m_Keywords.push(roomEvent.m_InventoryItem); }
				}
			}
		}
		if (m_Character != undefined)
		{
			m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_entry_success.xml" );
		}
	}
	
	private function ShowErrorScreen(errorString:String)
	{
		if (!m_Error)
		{
			m_Error = true;
			m_TopText.text = GetText(m_CurrentRoom.m_Name);
			m_DisplayText.text = errorString;
			
			if (m_Character != undefined)
			{
				m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_entry_fail.xml" );
			}
		}
	}
	
	private function GetText(input:String):String
	{
		if(m_UseTranslation)
		{
			if(isNaN(Number(input)))
			{
				
				input = LDBFormat.LDBGetText("MiscGUI", input);
			}
			else
			{
				input = LDBFormat.LDBGetText("MiscGUI", Number(input));
			}
		}
		//We have to replace all newlines with newlines because flash doesn't understand newlines from outside sources
		input = input.split("\\n").join("\n");
		return input;
	}
	
	private function KeyDownEventHandler()
	{
		if (Key.getCode() == Key.ENTER)
		{
			if(!m_Error)
			{
				SubmitInput();
				m_TextInput.text = "";
			}
			else
			{
				GoToRoom(m_CurrentRoom.m_Id);
			}
		}
	}
	
	private function SetInputFocus()
	{
		Selection.setFocus(m_TextInput);
	}
	
	private function SlotGameLoaded()
	{
		m_CurrentGame = TextGameLoader.m_CurrentGame;
		if(m_CurrentGame.m_Translation == 0) {m_UseTranslation = false;}
		_parent.SetTitle(GetText(m_CurrentGame.m_Name), "left");
		m_Inventory = new Array();
		
		GoToRoom(0);
	}

}