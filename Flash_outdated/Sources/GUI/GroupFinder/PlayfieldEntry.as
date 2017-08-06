import gfx.core.UIComponent;
import gfx.controls.CheckBox;
import com.Utils.Signal;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.DistributedValue;
import com.GameInterface.GroupFinder;
import com.GameInterface.LookingForGroup;
import com.GameInterface.Game.Character;
import com.GameInterface.PvPMinigame.PvPMinigame;

class GUI.GroupFinder.PlayfieldEntry extends UIComponent
{
	//Components created in .fla
	private var m_Background:MovieClip;
	private var m_Frame:MovieClip;
	private var m_HitArea:MovieClip;
	private var m_Name:TextField;
	private var m_TriangleButton:MovieClip;
	private var m_BonusSymbol:MovieClip;
	private var m_SelectCheckbox:CheckBox;
	
	//Variables
	private var m_Disabled:Boolean;
	private var m_IsExpanded:Boolean;
	private var m_IsFocused:Boolean;
	private var m_PlaySounds:Boolean;
	private var m_PrivateTeam:Boolean;
	
	private var m_Id;
	private var m_Difficulty;
	private var m_Image;
	private var m_SubEntries:Array;
	private var m_Depth:Number;
	private var m_Random:Boolean;
	private var m_BonusReward:String;
	
	private var m_TooltipText:String;
    private var m_Tooltip:TooltipInterface;
	private var m_TooltipTimeout:Number;
	
	public var SignalEntrySizeChanged:Signal;
	public var SignalEntryToggled:Signal;
	public var SignalEntryFocused:Signal;
	
	//Statics
	private static var CONTRACT_HEIGHT = 30;
	private static var ENTRY_PADDING:Number = 1;
	private static var ENTRY_INDENT:Number = 30;
	private static var DISABLED_ALPHA = 40;
	private static var ENABLED_ALPHA = 100;
	private static var TOOLTIP_WIDTH = 250;
	private static var TINT_INTENSITY = 25;
	private static var HEADER_ENTRY = -1;	
	
	//SETUP
	//****************************************************************************
	public function PlayfieldEntry() 
	{
		super();
		m_PrivateTeam = false;
		m_IsExpanded = false;
		m_IsFocused = false;
		m_Disabled = false;
		m_PlaySounds = true;
		
		m_Random = false;
		m_BonusSymbol._visible = false;
		
		m_HitArea.onPress = Delegate.create(this, HitAreaPressHandler);
		m_HitArea.onRelease = Delegate.create(this, HitAreaReleaseHandler);
		m_HitArea.onRollOver = m_HitArea.onDragOver = Delegate.create(this, HitAreaRollOverHandler);
		m_HitArea.onRollOut = m_HitArea.onDragOut = Delegate.create(this, HitAreaRollOutHandler);
		SignalEntrySizeChanged = new Signal();
		SignalEntryToggled = new Signal();
		SignalEntryFocused = new Signal();
	}
	
	private function configUI():Void
	{
		super.configUI();
		m_SelectCheckbox.addEventListener("click", this, "CheckboxClickHandler");
		m_SelectCheckbox.disableFocus = true;
		GroupFinder.SignalClientJoinedGroupFinder.Connect(SlotClientJoinedGroupFinder, this);
		if (GroupFinder.IsClientSignedUp())
		{
			SlotClientJoinedGroupFinder();
		}
		//Someone may have set the disabled state before checkboxes are set up, reset it here!
		m_SelectCheckbox.disabled = m_Disabled;

		//Check if the Queue should be disabled
		if (m_Id == HEADER_ENTRY)
		{
			if (m_Difficulty == _global.Enums.LFGDifficulty.e_Mode_Elite && !LookingForGroup.CanCharacterJoinEliteDungeons())
			{
				var errorStr:String = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorEliteLocked");
				SetDisabled(true, errorStr, true);
			}
			else if (m_Difficulty == _global.Enums.LFGDifficulty.e_Mode_Nightmare && !LookingForGroup.CanCharacterJoinNightmareDungeons())
			{
				var errorStr:String = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorNightmareLocked");
				SetDisabled(true, errorStr, true);
			}
		}
		else
		{
			//We can't have Group Finder Queues higher than 128 right now
			//If the id is > 1000, it must be a PvP Playfield ID
			if (m_Id < 1000)
			{
				var missingReqs:String = GroupFinder.CheckQueueRequirements(m_Id, m_PrivateTeam);
				if (missingReqs != "")
				{
					SetDisabled(true, missingReqs, true);
				}
			}
			else
			{
				if (!PvPMinigame.CanSignUpForMinigame(m_Id))
				{
					SetDisabled(true, LDBFormat.LDBGetText("GroupSearchGUI", "PvPLocked"));
				}
			}
		}
	}
	
	public function SetData(playfieldName:String, queueId:Number, playfieldDifficulty:Number, image:Number, subEntries:Array, depth:Number, isRandom:Boolean):Void
	{
		m_Id = queueId;
		m_Difficulty = playfieldDifficulty;
		m_Image = image;
		m_Name.text = playfieldName;
		m_SubEntries = subEntries;
		m_Depth = depth;
		m_Random = isRandom;
		m_BonusReward = isRandom ? LDBFormat.LDBGetText("GroupSearchGUI", "QueueReward_" + m_Id) : undefined;
		m_TooltipText = m_BonusReward;
		if (subEntries.length == 0)
		{
			m_TriangleButton._visible = false;
			m_BonusSymbol._visible = m_Random;
		}
		CreateSubEntries();
	}
	
	public function SetPrivateTeam(privateTeam:Boolean):Void
	{
		if (m_Id != HEADER_ENTRY)
		{
			m_PrivateTeam = privateTeam;
		}
		else
		{
			for (var i:Number = 0; i<m_SubEntries.length; i++)
			{
				this["PlayfieldEntry_" + i].SetPrivateTeam(privateTeam);
			}
		}
	}
	
	private function CreateSubEntries():Void
	{
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			var subEntry:PlayfieldEntry = PlayfieldEntry(attachMovie("PlayfieldEntry", "PlayfieldEntry_" + i, this.getNextHighestDepth()));
			subEntry.SetData(m_SubEntries[i].playfieldName, m_SubEntries[i].queueId, m_SubEntries[i].difficulty, m_SubEntries[i].image, m_SubEntries[i].subEntries, m_Depth + 1, m_SubEntries[i].isRandom);
			if (subEntry.m_SubEntries.length == 0)
			{
				subEntry.m_TriangleButton._visible = false;
				subEntry.m_BonusSymbol._visible = m_SubEntries[i].isRandom;
			}

			subEntry._x = ENTRY_INDENT;
			subEntry.m_HitArea._width -= (m_Depth + 1) * ENTRY_INDENT;
			subEntry.m_TriangleButton._x -= (m_Depth + 1) * ENTRY_INDENT;
			subEntry.m_BonusSymbol._x -= (m_Depth + 1) * ENTRY_INDENT;
			subEntry.m_Name._width -= (m_Depth + 1) * ENTRY_INDENT;
			subEntry.m_Frame._width -= (m_Depth + 1) * ENTRY_INDENT;
			subEntry.m_Background._width -= (m_Depth + 1) * ENTRY_INDENT;
			subEntry._visible = false;
			subEntry.SignalEntrySizeChanged.Connect(SlotSubEntrySizeChanged, this);
			subEntry.SignalEntryToggled.Connect(SlotSubEntryToggled, this);
			subEntry.SignalEntryFocused.Connect(SlotSubEntryFocused, this);
		}
	}
	
	//DATA HANDLING AND MINUPULATION
	//****************************************************************************
	public function LayoutSubEntries():Void
	{
		if (m_IsExpanded)
		{
			var entryY:Number = CONTRACT_HEIGHT + ENTRY_PADDING;
			for (var i:Number = 0; i<m_SubEntries.length; i++)
			{
				var entry:PlayfieldEntry = this["PlayfieldEntry_" + i];
				entry._y = entryY;
				entry._visible = true;
				entry.LayoutSubEntries();
				entryY += entry.GetFullHeight() + ENTRY_PADDING;
			}
		}
	}
	
	public function SetDisabled(disable:Boolean, disabledTooltip:String, clearSelection:Boolean):Void
	{
		//Check queue requirements if re-enabling
		if (disable == false)
		{
			if (m_Id == HEADER_ENTRY)
			{
				if (m_Difficulty == _global.Enums.LFGDifficulty.e_Mode_Elite && !LookingForGroup.CanCharacterJoinEliteDungeons())
				{
					var errorStr:String = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorEliteLocked");
					disable = true;
					disabledTooltip = errorStr;
					clearSelection = true;
				}
				else if (m_Difficulty == _global.Enums.LFGDifficulty.e_Mode_Nightmare && !LookingForGroup.CanCharacterJoinNightmareDungeons())
				{
					var errorStr:String = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorNightmareLocked");
					disable = true;
					disabledTooltip = errorStr;
					clearSelection = true;
				}
			}
			else
			{
				var missingReqs:String = GroupFinder.CheckQueueRequirements(m_Id, m_PrivateTeam);
				if (missingReqs != "")
				{
					disable = true;
					disabledTooltip = missingReqs;
					clearSelection = true;
				}
			}
		}
		m_Disabled = disable;
		//TODO: I don't really like this, but it works
		//We need to know if the parent's alpha is set, because the child inherits it via flash
		var newAlpha:Number = disable ? DISABLED_ALPHA : ENABLED_ALPHA;
		if (this._parent.m_Disabled)
		{
			newAlpha = ENABLED_ALPHA;
		}
		this._alpha = newAlpha;
		var enabledTooltip:String = m_BonusReward;
		m_TooltipText = disable ? disabledTooltip : enabledTooltip;
		//We have to check if disabled is defined here, in case someone sets the disabled
		//state before ConfigUI is called
		if (m_SelectCheckbox.disabled != undefined)
		{
			m_SelectCheckbox.disabled = disable;
			if (disable && clearSelection)
			{
				SetSelected(false, true);
			}	
		}
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			this["PlayfieldEntry_" + i].SetDisabled(disable, disabledTooltip, clearSelection);
		}
	}
	
	public function GetFullHeight():Number
	{
		return this._height;
	}
	
	public function IsLeaf():Boolean
	{
		return m_SubEntries.length == 0;		
	}
	
	public function FillSelectedEntriesArray(selectedEntries:Array):Void
	{
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			selectedEntries.concat(this["PlayfieldEntry_" + i].FillSelectedEntriesArray(selectedEntries));
		}
		if (m_SelectCheckbox.selected && !m_Disabled && m_Id >= 0) //m_Id is -1 for headers
		{
			selectedEntries.push(this);
		}
	}
	
	private function SelectEntries(entriesToSelect:Array):Void
	{
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			var entry:PlayfieldEntry = this["PlayfieldEntry_" + i];
			entry.SelectEntries(entriesToSelect);
		}
		for (var i:Number = 0; i<entriesToSelect.length; i++)
		{
			if (m_Id == entriesToSelect[i])
			{
				SetSelected(true, true);
			}
		}
	}
	
	public function SetSelected(select:Boolean, forceSelected:Boolean):Void
	{
		if (!m_Disabled || forceSelected)
		{
			m_SelectCheckbox.selected = select;
			m_PlaySounds = false;
			CheckboxClickHandler();
			m_PlaySounds = true;
		}
	}
	
	public function GetSelected():Boolean
	{
		return m_SelectCheckbox.selected;
	}
	
	private function CheckboxClickHandler():Void
	{
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			var entry:PlayfieldEntry = this["PlayfieldEntry_" + i];
			//We don't need to hear about this toggle since we triggered it.
			entry.SignalEntryToggled.Disconnect(SlotSubEntryToggled, this);
			entry.SetSelected(m_SelectCheckbox.selected, false);
			entry.SignalEntryToggled.Connect(SlotSubEntryToggled, this);
		}
		SignalEntryToggled.Emit(m_SelectCheckbox.selected);
		if (m_PlaySounds)
		{
			Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_click_tiny.xml");
		}
	}
	
	private function SlotSubEntryToggled(select:Boolean)
	{
		if (select)
		{
			m_SelectCheckbox.selected = true;
			SignalEntryToggled.Emit(m_SelectCheckbox.selected);
		}
		else
		{
			if (NoSubEntriesChecked() == true)
			{
				m_SelectCheckbox.selected = false;
				SignalEntryToggled.Emit(m_SelectCheckbox.selected);
			}
		}
	}	
	
	private function AllSubEntriesChecked():Boolean
	{
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			if (this["PlayfieldEntry_" + i].GetSelected() == false)
			{
				return false;
			}
		}
		return true;
	}
	
	private function NoSubEntriesChecked():Boolean
	{
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			if (this["PlayfieldEntry_" + i].GetSelected() == true)
			{
				return false;
			}
		}
		return true;
	}
	
	private function SlotClientJoinedGroupFinder():Void
	{
		SetSelected(false, true);
		SelectEntries(GroupFinder.GetQueuesSignedUp());
	}
	
	
	//Expanding, Contracting, Focusing
	//********************************************************************************
	
	private function HitAreaReleaseHandler():Void
	{
		if (IsLeaf())
		{
			if (!m_IsFocused)
			{
				SignalEntryFocused.Emit(m_Id, m_Image, m_Random);
			}
		}
		else
		{
			if (m_IsExpanded)
			{
				Contract();
			}
			else
			{
				Expand();
			}
		}
	}
	
	public function SetFocusById(id:Number):Void
	{
		SetFocused(id == m_Id);
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			this["PlayfieldEntry_" + i].SetFocusById(id);
		}
	}
	
	public function SetFocused(focus:Boolean):Void
	{
		if (m_IsFocused != focus)
		{
			m_IsFocused = focus;
			var tintPercent:Number = focus ? TINT_INTENSITY : 0;
			Colors.Tint(this.m_Background, Colors.e_ColorWhite, tintPercent);
		}
	}
	
	private function SlotSubEntryFocused(id:Number, image:Number, isRandom:Boolean):Void
	{
		SignalEntryFocused.Emit(id, image, isRandom);
	}
	
	public function Expand():Void
	{
		if (!m_IsExpanded)
		{
			m_IsExpanded = true;
			m_TriangleButton._rotation = 180;
			LayoutSubEntries();
		}
		SignalEntrySizeChanged.Emit();
	}
	
	public function Contract():Void
	{
		if (m_IsExpanded)
		{
			m_IsExpanded = false;
			m_TriangleButton._rotation = 0;
			for (var i:Number = 0; i<m_SubEntries.length; i++)
			{
				var entry:PlayfieldEntry = this["PlayfieldEntry_" + i];
				entry._y = 0;
				entry._visible = false;
				entry.Contract();
			}
		}
		SignalEntrySizeChanged.Emit();
	}
	
	private function SlotSubEntrySizeChanged():Void
	{
		LayoutSubEntries();
		SignalEntrySizeChanged.Emit();
	}
	
	//TOOLTIP STUFF
	//******************************************************************	
	private function HitAreaPressHandler():Void
	{
		CloseTooltip();
	}
	
	private function HitAreaRollOverHandler():Void
	{
		if (!m_IsFocused)
		{
			Colors.Tint(this.m_Background, Colors.e_ColorWhite, TINT_INTENSITY - 10);
		}
		if (m_TooltipText != undefined && m_TooltipText != "")
		{
			StartTooltipTimeout();
		}
	}
	
	private function HitAreaRollOutHandler():Void
	{
		if (!m_IsFocused)
		{
			Colors.Tint(this.m_Background, Colors.e_ColorWhite, 0);
		}
		CloseTooltip();
	}
	
	private function StartTooltipTimeout()
	{
		if (m_TooltipTimeout != undefined)
		{
			return;
		}
		var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelay");
		if (delay == 0)
		{
			OpenTooltip();
			return;
		}
		m_TooltipTimeout = _global.setTimeout( Delegate.create( this, OpenTooltip ), delay*1000 );
	}
	
	private function StopTooltipTimout()
	{
		if (m_TooltipTimeout != undefined)
		{
			_global.clearTimeout(m_TooltipTimeout);
			m_TooltipTimeout = undefined;
		}
	}
	
	private function OpenTooltip()
    {
		StopTooltipTimout();
        if (this._visible && this._alpha > 0 && m_Tooltip == undefined && m_TooltipText != undefined && m_TooltipText != "")
        {
            var tooltipData:TooltipData = new TooltipData();            
            tooltipData.m_Descriptions.push(m_TooltipText);
            tooltipData.m_Padding = 4;
            tooltipData.m_MaxWidth = TOOLTIP_WIDTH;
			m_Tooltip = TooltipManager.GetInstance().ShowTooltip( undefined, TooltipInterface.e_OrientationHorizontal, 0, tooltipData );
        }
    }
    
    public function CloseTooltip()
    {
		StopTooltipTimout();
        if (m_Tooltip != undefined)
        {
            m_Tooltip.Close();
            m_Tooltip = undefined;
        }
    }
}