import gfx.core.UIComponent;
import gfx.controls.Button;
import com.Utils.Signal;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.Utils.Text;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.DistributedValue;
import com.GameInterface.Utils;
import com.GameInterface.ShopInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import mx.utils.Delegate;

class GUI.RegionTeleport.PlayfieldEntry extends UIComponent
{
	//Components created in .fla
	private var m_Background:MovieClip;
	private var m_Frame:MovieClip;
	private var m_HitArea:MovieClip;
	private var m_Name:TextField;
	private var m_TriangleButton:MovieClip;
	private var m_CooldownTimer:MovieClip;
	private var m_Price:MovieClip;
	
	//Variables
	private var m_Disabled:Boolean;
	private var m_IsExpanded:Boolean;
	private var m_IsFocused:Boolean;
	private var m_Time:Number;
	private var m_TimerID:Number;
	
	private var m_LoreNode;
	private var m_Id;
	private var m_Image;
	private var m_SubEntries:Array;
	private var m_Depth:Number;
	
	public var SignalEntrySizeChanged:Signal;
	public var SignalEntryFocused:Signal;
	public var SignalEntryEnabled:Signal;
	public var SignalEntryActivated:Signal;
	
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
		m_IsExpanded = false;
		m_IsFocused = false;
		m_Disabled = false;
		
		m_HitArea.onMousePress = Delegate.create(this, HitAreaPressHandler);
		m_HitArea.onRollOver = m_HitArea.onDragOver = Delegate.create(this, HitAreaRollOverHandler);
		m_HitArea.onRollOut = m_HitArea.onDragOut = Delegate.create(this, HitAreaRollOutHandler);
		SignalEntrySizeChanged = new Signal();
		SignalEntryFocused = new Signal();
		SignalEntryEnabled = new Signal();
		SignalEntryActivated = new Signal();
	}
	
	private function configUI():Void
	{
		super.configUI();
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
	}
	
	private function onUnload():Void
	{
		if (m_TimerID != undefined)
		{
			clearInterval(m_TimerID);
			m_TimerID = undefined;
		}
	}
	
	public function SetData(loreNode:LoreNode, depth:Number):Void
	{
		m_LoreNode = loreNode;
		m_Id = loreNode.m_Id;
		m_Image = loreNode.m_Icon;
		m_Name.text = loreNode.m_Name;
		if (Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0)
		{
			m_Name.text += " ["+m_Id+"]";
		}
		m_SubEntries = loreNode.m_Children;
		m_Depth = depth;
		SetLockoutTime();
		SetPrice();
		SetDisabled(loreNode.m_Locked && !loreNode.m_IsInProgress);
		if (m_SubEntries == undefined || m_SubEntries.length == 0)
		{
			m_TriangleButton._visible = false;
		}
		else
		{
			m_Price._visible = false;
			CreateSubEntries();
		}
	}
	
	private function SetPrice():Void
	{
		var price:Object = ShopInterface.GetTagPriceInfo(m_Id);
		m_Price.m_Text.autoSize = "right";
		m_Price._visible = (price[1] != 0 && !Character.GetClientCharacter().IsMember());
		m_Price.m_Text.text = Text.AddThousandsSeparator(price[1]);
		m_Price.m_Token._x = m_Price._width - m_Price.m_Text.textWidth - m_Price.m_Token._width - 5;
	}
	
	private function SetLockoutTime():Void
	{
		var lockoutBuff:BuffData = Character.GetClientCharacter().m_InvisibleBuffList[Lore.GetTagTeleportLockout(m_Id)];
		if (lockoutBuff != undefined)
		{
			m_Time = lockoutBuff.m_TotalTime;
			m_Name.textColor = Colors.e_ColorLightRed;
			m_CooldownTimer.text = CalculateTimeString(m_Time);
			m_CooldownTimer.textColor = Colors.e_ColorLightRed;
			m_TimerID = setInterval(this, "UpdateTimer", 1000);
			Character.GetClientCharacter().SignalBuffRemoved.Connect(SlotBuffRemoved, this);
		}
		else
		{
			m_CooldownTimer._visible = false;
		}
	}
	
	private function CreateSubEntries():Void
	{
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			if (Utils.GetGameTweak("HideTeleport_" + m_SubEntries[i].m_Id) == 0)
			{
				var subEntry:PlayfieldEntry = PlayfieldEntry(attachMovie("PlayfieldEntry", "PlayfieldEntry_" + i, this.getNextHighestDepth()));
				subEntry.SetData(m_SubEntries[i], m_Depth + 1);
				if (subEntry.m_SubEntries.length == 0)
				{
					subEntry.m_TriangleButton._visible = false;
				}
	
				subEntry._x = ENTRY_INDENT;
				subEntry.m_HitArea._width -= (m_Depth + 1) * ENTRY_INDENT;
				subEntry.m_TriangleButton._x -= (m_Depth + 1) * ENTRY_INDENT;
				subEntry.m_CooldownTimer._x -= (m_Depth + 1) * ENTRY_INDENT;
				subEntry.m_Price._x -= (m_Depth + 1) * ENTRY_INDENT;
				subEntry.m_Name._width -= (m_Depth + 1) * ENTRY_INDENT;
				subEntry.m_Frame._width -= (m_Depth + 1) * ENTRY_INDENT;
				subEntry.m_Background._width -= (m_Depth + 1) * ENTRY_INDENT;
				subEntry._visible = false;
				subEntry.SignalEntrySizeChanged.Connect(SlotSubEntrySizeChanged, this);
				subEntry.SignalEntryFocused.Connect(SlotSubEntryFocused, this);
				subEntry.SignalEntryEnabled.Connect(SlotSubEntryEnabled, this);
				subEntry.SignalEntryActivated.Connect(SlotSubEntryActivated, this);
			}
		}
	}
	
	private function SlotSubEntryEnabled():Void
	{
		SetDisabled(false);
	}
	
	private function SlotSubEntryActivated(nodeId:Number):Void
	{
		SignalEntryActivated.Emit(nodeId);
	}
	
	private function SlotTagAdded(tagId:Number):Void
	{
		if (tagId == m_Id)
		{
			SetDisabled(false);
			if (m_IsFocused)
			{
				//This will update the teleport button to allow teleport
				SignalEntryFocused.Emit(m_LoreNode);
			}
		}
	}
	
	private function SlotBuffRemoved(buffId:Number):Void
	{
		if (buffId == Lore.GetTagTeleportLockout(m_Id))
		{
			ClearTimer();
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
	
	public function SetDisabled(disable:Boolean):Void
	{
		var changed:Boolean = m_Disabled != disable;
		m_Disabled = disable;
		//TODO: I don't really like this, but it works
		//We need to know if the parent's alpha is set, because the child inherits it via flash
		var newAlpha:Number = disable ? DISABLED_ALPHA : ENABLED_ALPHA;
		if (this._parent.m_Disabled)
		{
			newAlpha = ENABLED_ALPHA;
		}
		this._alpha = newAlpha;
		
		if (!disable && changed)
		{
			SignalEntryEnabled.Emit();
		}
		
		//We need to iterate over all the sub entries and set their alpha here
		//based on disabled state, since their alpha may not have been set before
		for (var i:Number = 0; i<m_SubEntries.length; i++)
		{
			var entry:PlayfieldEntry = this["PlayfieldEntry_" + i];
			entry.SetDisabled(entry.m_Disabled);
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
	
	//Expanding, Contracting, Focusing
	//********************************************************************************
	
	private function HitAreaPressHandler(buttonIdx:Number, clickCount:Number):Void
	{
		if (IsLeaf())
		{
			if ((buttonIdx == 2 || clickCount == 2) && m_Id != undefined && m_TimerID == undefined)
			{
				SignalEntryActivated.Emit(m_Id);
			}
			else if (!m_IsFocused)
			{
				SignalEntryFocused.Emit(m_LoreNode);
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
	
	private function SlotSubEntryFocused(loreNode:LoreNode):Void
	{
		SignalEntryFocused.Emit(loreNode);
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
	
	//HIT AREA RESPONSES
	//******************************************************************	
	
	private function HitAreaRollOverHandler():Void
	{
		if (!m_IsFocused)
		{
			Colors.Tint(this.m_Background, Colors.e_ColorWhite, TINT_INTENSITY - 10);
		}
	}
	
	private function HitAreaRollOutHandler():Void
	{
		if (!m_IsFocused)
		{
			Colors.Tint(this.m_Background, Colors.e_ColorWhite, 0);
		}
	}
	
	//TIMERS
	///******************************************************************
	private function CalculateTimeString(totalSeconds):String
	{
		var timeLeft = totalSeconds;
		var time = com.GameInterface.Utils.GetNormalTime() * 1000;
		timeLeft = (totalSeconds - time)/1000;
		
		var totalMinutes = timeLeft/60;
		var seconds = timeLeft%60;
		var secondsString = String(Math.floor(seconds));
		if (secondsString.length == 1) { secondsString = "0" + secondsString; }
		var minutes = totalMinutes;
		var minutesString = String(Math.floor(minutes));
		if (minutesString.length == 1) { minutesString = "0" + minutesString; }
		return minutesString + ":" + secondsString;
	}
	
	private function UpdateTimer():Void
	{
		var timeLeft = m_Time;
		var time = com.GameInterface.Utils.GetNormalTime() * 1000;
		timeLeft = (m_Time - time)/1000;

		if (timeLeft > 0)
		{
			m_CooldownTimer.text = CalculateTimeString(m_Time);
		}
		else
		{
			ClearTimer();
		}
	}
	
	private function ClearTimer():Void
	{
		m_Name.textColor = Colors.e_ColorWhite;
		m_CooldownTimer.text = "00:00";
		m_CooldownTimer.textColor = Colors.e_ColorWhite;
		m_CooldownTimer._visible = false;
		clearInterval( m_TimerID );
		m_TimerID = undefined;
		
		if (m_IsFocused)
		{
			//This will update the teleport button to allow teleport
			SignalEntryFocused.Emit(m_LoreNode);
		}
	}
}