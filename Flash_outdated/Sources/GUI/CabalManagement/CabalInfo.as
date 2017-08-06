import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;

import gfx.controls.Button;
import gfx.controls.TextInput;
import gfx.controls.DropdownMenu;
import gfx.controls.TextArea;
import gfx.controls.Label;

import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import com.GameInterface.Guild.*;

class GUI.CabalManagement.CabalInfo extends UIComponent
{
	private var m_PopupOverlay:MovieClip;
	
	private var m_GeneralInfoHeader:Label;
	private var m_TotalMembersLabel:Label;
	private var m_TotalMembers:MovieClip;
	private var m_GuildNameLabel:Label;
	private var m_GuildNameTextInput:TextInput;
	private var m_GovernmentTypeLabel:Label;
	private var m_GovernmentType:MovieClip;
	
	private var m_GuildMessageHeader:Label;
	private var m_GuildMessageTextBox:TextArea;
	
	private var m_ApplyButton:Button;
	
	private var CUSTOM_GOVERNMENT:Number = 255;
	//TODO: Localize this
	private var CUSTOM:String = "Custom";
	
	private function configUI()
	{
		_parent._parent._parent.m_LeaveButton._visible = true;
		
		SetLabels();
		SetData();
		
		m_ApplyButton.disableFocus = true;
		m_ApplyButton.addEventListener("click", this, "UpdateChanges");
	}
	
	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}
	
	private function SetLabels()
	{
		m_GeneralInfoHeader.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildInfoView_GeneralInformation");
		m_TotalMembersLabel.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildInfoView_TotalMembers");
		m_GuildNameLabel.text = LDBFormat.LDBGetText("GuildGUI", "GuildName");
		m_GovernmentTypeLabel.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_GovernmentType");
		
		m_GuildMessageHeader.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildInfoView_MessageOfTheDay");
				
		m_ApplyButton.label = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_Change");
	}
	
	private function SetData()
	{
		Guild.GetInstance().GetGeneralGuildInfo();
		
		m_TotalMembers.text = Guild.GetInstance().m_NumMembers;
		
		if (Guild.GetInstance().m_GoverningformID == CUSTOM_GOVERNMENT)
		{
			m_GovernmentType.text = CUSTOM;
		}
		else
		{
			m_GovernmentType.text = Guild.GetInstance().m_GoverningFormArray[Guild.GetInstance().m_GoverningformID];	
		}
		
		Guild.GetInstance().SignalGuildNameUpdated.Connect( SlotGuildNameUpdated, this );
		Guild.GetInstance().SignalMessageOfTheDayUpdated.Connect( SlotGuildMessageUpdated, this );
		Guild.GetInstance().SignalGoverningformUpdated.Connect( SlotGoverningformUpdated, this );
		
		SlotGuildNameUpdated();
		SlotGuildMessageUpdated();
		SlotGoverningformUpdated();
		
		m_GuildNameTextInput.maxChars = 40;
		
		if(!Guild.GetInstance().CanChangeName())
		{
			m_GuildNameTextInput.editable = false;
			m_GuildNameTextInput.disabled = true;
		}
		if(!Guild.GetInstance().CanChangeMessageOfTheDay())
		{
			m_GuildMessageTextBox.editable = false;
		}
	}
	
	private function SlotGuildNameUpdated()
	{
		m_GuildNameTextInput.text  = Guild.GetInstance().m_GuildName;
	}
	
	private function SlotGoverningformUpdated()
	{
		if (Guild.GetInstance().m_GoverningformID == CUSTOM_GOVERNMENT)
		{
			m_GovernmentType.text = CUSTOM;
		}
		else
		{
			m_GovernmentType.text = Guild.GetInstance().m_GoverningFormArray[Guild.GetInstance().m_GoverningformID];	
		}
	}
	
	private function SlotGuildMessageUpdated()
	{
		m_GuildMessageTextBox.text = Guild.GetInstance().m_MessageOfTheDay;
		
	}
	
	public function UpdateChanges()
	{
		Guild.GetInstance().UpdateGuildInfoData(	m_GuildNameTextInput.text, 
													m_GuildMessageTextBox.text,
													0, 
													Guild.GetInstance().m_GoverningformID,
													false,
													"", 0, "", 0, "", 0, "", 0, "", 0);
	}	
}