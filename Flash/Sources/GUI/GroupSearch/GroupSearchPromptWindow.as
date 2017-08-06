//Imports
import com.Components.FCButton;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.LookingForGroup;
import gfx.controls.Button;
import gfx.controls.TextArea;
import gfx.controls.DropdownMenu;
import gfx.core.UIComponent;
import mx.utils.Delegate;
import GUI.GroupSearch.GroupSearchFiltersWindow;

//Class
class GUI.GroupSearch.GroupSearchPromptWindow extends UIComponent
{
    //Constants
    public static var MODE_SELECT_ROLE:String = "modeSelectRole";
    public static var MODE_CONFIRM_LEAVE:String = "modeConfirmLeave";
	public static var MODE_VIEW:String = "modeView";    
    private static var CONTENT_PERSISTENCE:String = "contentPersistence";
    
    private static var SELECT_ROLE_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "selectRoleMessage");
	private static var VIEW_ROLE_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ViewRoleMessage");
	private static var SELECT_ACTIVITY_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "SelectActivityMessage");
	private static var VIEW_ACTIVITY_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ViewActivity");
	private static var SELECT_LOCATION_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "SelectLocationMessage");
	private static var VIEW_LOCATION_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ViewLocation");
	private static var SELECT_DIFFICULTY_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "SelectDifficultyMessage");
	private static var VIEW_DIFFICULTY_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ViewDifficultyMessage");
	private static var INPUT_TEXT_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "InputTextMessage");
    private static var TANK_BUTTON_LABEL:String = LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonLabel");
    private static var TANK_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonTooltip");
    private static var DPS_BUTTON_LABEL:String = LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonLabel");
    private static var DPS_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonTooltip");
    private static var HEALER_BUTTON_LABEL:String = LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonLabel");
    private static var HEALER_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonTooltip");
    private static var OK_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Ok");
	private static var LEAVE_LABEL:String = LDBFormat.LDBGetText("GroupSearchGUI", "leave");
    private static var CANCEL_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
	private static var UPDATE_LABEL:String = LDBFormat.LDBGetText("GroupSearchGUI", "Update");
	
	private static var MAX_DUNGEON_TEAM:Number = 5;
	private static var MAX_RAID_TEAM:Number = 10;
    
    //Properties
    public var SignalPromptResponse:Signal;
    
    private var m_Background:MovieClip;
    private var m_SelectRoleMessage:TextField;
	private var m_SelectActivityMessage:TextField;
	private var m_SelectLocationMessage:TextField;
	private var m_SelectDifficultyMessage:TextField;
    private var m_ToggleButtonArray:Array;
    private var m_TankButton:FCButton;
    private var m_TankLabel:TextField;
    private var m_DPSButton:FCButton;
    private var m_DPSLabel:TextField;
    private var m_HealerButton:FCButton;
    private var m_HealerLabel:TextField;
	private var m_CommentMessage:TextField;
	private var m_InputText:TextArea;
	private var m_ActivityDropdown:DropdownMenu;
	private var m_LocationDropdown:DropdownMenu;
	private var m_DifficultyDropdown:DropdownMenu;    
    private var m_OKButton:Button;
    private var m_CancelButton:Button;
	private var m_UpdateButton:Button;
	
    private var m_Mode:String;
	private var m_UpdateEnabled:Boolean;
    
    //Constructor
    public function GroupSearchPromptWindow()
    {
        super();
        SignalPromptResponse = new Signal;
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        _visible = false;
        
		m_CommentMessage.text = INPUT_TEXT_PROMPT_MESSAGE;
		
		m_ActivityDropdown.dataProvider = [GroupSearchFiltersWindow.TDB_SOCIAL, GroupSearchFiltersWindow.TDB_TRADE,
										   GroupSearchFiltersWindow.TDB_CABAL, GroupSearchFiltersWindow.TDB_DUNGEON, 
										   GroupSearchFiltersWindow.TDB_RAID, GroupSearchFiltersWindow.TDB_SCENARIO, 
										   GroupSearchFiltersWindow.TDB_LAIR, GroupSearchFiltersWindow.TDB_MISSION,
										   GroupSearchFiltersWindow.TDB_PVP];
		m_ActivityDropdown.rowCount = m_ActivityDropdown.dataProvider.length;
		m_ActivityDropdown.addEventListener("change",this,"ActivityDropdownChanged");
		m_ActivityDropdown.disableFocus = true;
		
		//Difficulty Dropdown is populated in ShowPrompt
		m_DifficultyDropdown.addEventListener("change",this,"EnableUpdate");
		m_DifficultyDropdown.disableFocus = true;
		
		//LocationDropdown is populated in ActivityDropdownChanged
		m_LocationDropdown.addEventListener("change",this,"EnableUpdate");
		m_LocationDropdown.disableFocus = true;
        
        m_ToggleButtonArray = new Array(m_TankButton, m_DPSButton, m_HealerButton);
        
        for (var i:Number = 0; i < m_ToggleButtonArray.length; i++)
        {
            m_ToggleButtonArray[i].toggle = true;
            m_ToggleButtonArray[i].disableFocus = true;
            m_ToggleButtonArray[i].selected = false;
            m_ToggleButtonArray[i].addEventListener("click", this, "ToggleRoleButtonClickEventHandler");
        }
		
		m_InputText.addEventListener("textChange", this, "TextChangeEventHandler");
        
        m_TankButton.SetTooltipText(TANK_BUTTON_TOOLTIP);
        m_DPSButton.SetTooltipText(DPS_BUTTON_TOOLTIP);
        m_HealerButton.SetTooltipText(HEALER_BUTTON_TOOLTIP);
        
        m_TankLabel.text = TANK_BUTTON_LABEL;
        m_DPSLabel.text = DPS_BUTTON_LABEL;
        m_HealerLabel.text = HEALER_BUTTON_LABEL;
        
        m_OKButton.label = OK_LABEL;
        m_OKButton.disableFocus = true;
        m_OKButton.disabled = true;
        m_OKButton.addEventListener("click", this, "ResponseButtonEventHandler");
		
		m_UpdateButton.label = UPDATE_LABEL;
        m_UpdateButton.disableFocus = true;
        m_UpdateButton.disabled = true;
        m_UpdateButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_CancelButton.label = CANCEL_LABEL;
        m_CancelButton.disableFocus = true;
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        _x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;        
    }
    
    //Show Prompt
    public function ShowPrompt(mode:String, playField:Number, location:Number, difficulty:Number, comment:String, tank:Boolean, damage:Boolean, heal:Boolean):Void
    {  
        if (_visible && m_Mode == mode)
        {
            return;
        }
        
		//Set mode and component state
        m_Mode = mode;     
		
		m_DifficultyDropdown.dataProvider = [GroupSearchFiltersWindow.TDB_ANY, GroupSearchFiltersWindow.TDB_NORMAL];
		if (m_Mode == MODE_VIEW || LookingForGroup.CanCharacterJoinEliteDungeons()) { m_DifficultyDropdown.dataProvider.push(GroupSearchFiltersWindow.TDB_ELITE); }
		if (m_Mode == MODE_VIEW || LookingForGroup.CanCharacterJoinNightmareDungeons()) { m_DifficultyDropdown.dataProvider.push(GroupSearchFiltersWindow.TDB_NIGHTMARE); }
		m_DifficultyDropdown.rowCount = m_DifficultyDropdown.dataProvider.length;
		
		m_ActivityDropdown.disabled =       (m_Mode == MODE_VIEW) ? true : false;
		m_LocationDropdown.disabled =       (m_Mode == MODE_VIEW) ? true : false;
		m_DifficultyDropdown.disabled =     (m_Mode == MODE_VIEW) ? true : false;
		m_InputText.editable =              (m_Mode == MODE_VIEW) ? false : true;
        		
		m_TankButton.disabled = 			(m_Mode == MODE_VIEW) ? true : false;
		m_DPSButton.disabled = 				(m_Mode == MODE_VIEW) ? true : false;
		m_HealerButton.disabled = 			(m_Mode == MODE_VIEW) ? true : false;
		
		m_SelectRoleMessage.text =			(m_Mode == MODE_VIEW) ? VIEW_ROLE_PROMPT_MESSAGE : SELECT_ROLE_PROMPT_MESSAGE;
		m_SelectActivityMessage.text =		(m_Mode == MODE_VIEW) ? VIEW_ACTIVITY_PROMPT_MESSAGE : SELECT_ACTIVITY_PROMPT_MESSAGE;
		m_SelectLocationMessage.text =		(m_Mode == MODE_VIEW) ? VIEW_LOCATION_PROMPT_MESSAGE : SELECT_LOCATION_PROMPT_MESSAGE;
		m_SelectDifficultyMessage.text =	(m_Mode == MODE_VIEW) ? VIEW_DIFFICULTY_PROMPT_MESSAGE : SELECT_DIFFICULTY_PROMPT_MESSAGE;
		m_OKButton.label =					(m_Mode == MODE_CONFIRM_LEAVE) ? LEAVE_LABEL : OK_LABEL;  
		m_UpdateButton._visible =			(m_Mode == MODE_CONFIRM_LEAVE) ? true : false;
		
		//Set display values
		if (playField != undefined)
		{
			m_ActivityDropdown.selectedIndex = playField;
			ActivityDropdownChanged();
		}
		if (location != undefined)
		{
			m_LocationDropdown.selectedIndex = location;
		}
		if (difficulty != undefined)
		{
			m_DifficultyDropdown.selectedIndex = difficulty;
		}
		if (comment!= undefined)
		{
			m_InputText.text = comment;
		}
		if (tank != undefined)
		{
			m_TankButton.selected = tank;
		}
		if (damage != undefined)
		{
			m_DPSButton.selected = damage;
		}
		if (heal != undefined)
		{
			m_HealerButton.selected = heal;
		}
		
		//Update and show prompt
		UpdateOKState();
		m_UpdateEnabled = false;
		UpdateUpdateState();
        swapDepths(_parent.getNextHighestDepth()); 
		_x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;
        _visible = true;
    }
    
    //Toggle Role Button Click Event Handler
    private function ToggleRoleButtonClickEventHandler(event:Object):Void
    {        
        UpdateOKState();
		EnableUpdate();
    }
	
	//Text Change Event Handler
    private function TextChangeEventHandler():Void
    {
        UpdateOKState();
		EnableUpdate();
    }
	
	private function EnableUpdate():Void
	{
		m_UpdateEnabled = true;
		UpdateUpdateState();
	}
	
	private function UpdateUpdateState():Void
	{
		if (m_UpdateEnabled)
		{
			if (m_InputText.text == "")
			{
				m_UpdateButton.disabled = true;                
				return;
			}
			
			//Require a role for these activities
			if (m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.RAID ||
				m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.DUNGEON ||
				m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.LAIR ||
				m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.SCENARIO ||
				m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.PVP)
			{
				for (var i:Number = 0; i < m_ToggleButtonArray.length; i++)
				{
					if (m_ToggleButtonArray[i].selected)
					{
						m_UpdateButton.disabled = false;                
						return;
					}
				}
				m_UpdateButton.disabled = true;
				return;
			}        
			m_UpdateButton.disabled = false;
		}
		else
		{
			m_UpdateButton.disabled = true;
		}
	}
	
	private function UpdateOKState():Void
	{
		if (m_Mode == MODE_CONFIRM_LEAVE)
		{
			m_OKButton.disabled = false;
			return;
		}
		
		if (m_InputText.text == "")
		{
			m_OKButton.disabled = true;                
			return;
		}
		
		//Require a role for these activities
		if (m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.RAID ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.DUNGEON ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.LAIR ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.SCENARIO ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.PVP)
		{
			for (var i:Number = 0; i < m_ToggleButtonArray.length; i++)
			{
				if (m_ToggleButtonArray[i].selected)
				{
					m_OKButton.disabled = false;                
					return;
				}
			}
			m_OKButton.disabled = true;
			return;
		}        
        m_OKButton.disabled = false;
	}
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
		var selectedRolesArray:Array = new Array();            
		if (m_TankButton.selected) selectedRolesArray.push(_global.Enums.Class.e_Tank);
		if (m_DPSButton.selected) selectedRolesArray.push(_global.Enums.Class.e_Damage);
		if (m_HealerButton.selected) selectedRolesArray.push(_global.Enums.Class.e_Heal);
		
		//maxTeamSize 0 means NO MAXIMUM!
		var maxTeamSize:Number = 0;
		if (m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.DUNGEON)
		{
			maxTeamSize = MAX_DUNGEON_TEAM;
		}
		if (m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.RAID)
		{
			maxTeamSize = MAX_RAID_TEAM;
		}
		
        if (m_Mode == MODE_SELECT_ROLE)
        {            
            if (event.target == m_OKButton)
            {                
                SignalPromptResponse.Emit(m_Mode, selectedRolesArray, m_ActivityDropdown.selectedIndex, m_LocationDropdown.selectedIndex, m_DifficultyDropdown.selectedIndex, m_InputText.text, maxTeamSize, false);
            }
            else if (event.target == m_CancelButton)
            {
                SignalPromptResponse.Emit(m_Mode, selectedRolesArray, m_ActivityDropdown.selectedIndex, m_LocationDropdown.selectedIndex, m_DifficultyDropdown.selectedIndex, m_InputText.text, maxTeamSize, true)
            }
        }
        
        else if (m_Mode == MODE_CONFIRM_LEAVE)
        {
            if (event.target == m_OKButton)
            {
                SignalPromptResponse.Emit(m_Mode, undefined, undefined, undefined, undefined, undefined, undefined, true);
            }
            else if (event.target == m_CancelButton)
            {
                SignalPromptResponse.Emit(m_Mode, undefined, undefined, undefined, undefined, undefined, undefined, false);
            }
			else if (event.target == m_UpdateButton)
			{
				SignalPromptResponse.Emit(MODE_SELECT_ROLE, selectedRolesArray, m_ActivityDropdown.selectedIndex, m_LocationDropdown.selectedIndex, m_DifficultyDropdown.selectedIndex, m_InputText.text, maxTeamSize, false);
			}
        }
        
        m_OKButton.disabled = true;
        _visible = false;
        Selection.setFocus(null);
    }
	
	private function ActivityDropdownChanged():Void
	{
		//Set appropriate options in the location dropdown
		var baseLocString:String = "Activity_"+m_ActivityDropdown.selectedIndex+"_Location_";
		switch (m_ActivityDropdown.selectedIndex)
		{
			case GroupSearchFiltersWindow.SOCIAL:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"1"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"2"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"3"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"4"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"5"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"6"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"7")];
				break;
			case GroupSearchFiltersWindow.TRADE:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0")];
				break;
			case GroupSearchFiltersWindow.CABAL:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0")];
				break;
			case GroupSearchFiltersWindow.DUNGEON:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"1"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"2"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"3"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"4"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"5"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"6"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"7"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"8"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"9"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"10"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"11")];
				break;
			case GroupSearchFiltersWindow.RAID:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"1"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"2"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"3")];
				break;
			case GroupSearchFiltersWindow.SCENARIO:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"1"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"2"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"3")];
				break;
			case GroupSearchFiltersWindow.LAIR:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"1"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"2"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"3"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"4"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"5"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"6"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"7"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"8")];
				break;
			case GroupSearchFiltersWindow.MISSION:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"1"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"2"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"3"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"4"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"5"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"6"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"7"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"8"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"9")];
				break;
			case GroupSearchFiltersWindow.PVP:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"1"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"2"),
												   LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"3")]
				break;
			default:
				m_LocationDropdown.dataProvider = [LDBFormat.LDBGetText("GroupSearchGUI", baseLocString+"0")];
		}
		m_LocationDropdown.rowCount = m_LocationDropdown.dataProvider.length;
		//Set appropriate options in the difficulty dropdown
		if (m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.SOCIAL ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.TRADE ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.CABAL ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.LAIR ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.MISSION ||
			m_ActivityDropdown.selectedIndex == GroupSearchFiltersWindow.PVP)
			{
				m_DifficultyDropdown.selectedIndex = GroupSearchFiltersWindow.ANY;
				m_DifficultyDropdown.disabled = true;
			}
		else if (m_Mode != MODE_VIEW)
		{
			m_DifficultyDropdown.disabled = false;
		}
		EnableUpdate();
		UpdateOKState()
	}
}