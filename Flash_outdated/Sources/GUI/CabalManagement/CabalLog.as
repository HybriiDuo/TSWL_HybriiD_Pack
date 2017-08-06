import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.ScrollingList;
import gfx.controls.Label;
import gfx.controls.CheckBox;

import com.Utils.LDBFormat;
import com.Utils.Colors;

import com.GameInterface.GuildLog;

class GUI.CabalManagement.CabalLog extends UIComponent
{
	//Components from .fla
	private var m_LogHeader:Label;
	
	private var m_AllCheckBox:CheckBox;
	private var m_BankCheckBox:CheckBox;
	private var m_MembershipCheckBox:CheckBox;
	private var m_GovernmentCheckBox:CheckBox;
	
	private var m_AllTextField:TextField;
	private var m_BankTextField:TextField;
	private var m_MembershipTextField:TextField;
	private var m_GovernmentTextField:TextField;
	
	private var m_TimeHeader:TextField;
	private var m_TypeHeader:TextField;
	private var m_ActivityHeader:TextField;
	
	private var m_LogScrollingList:ScrollingList;
	
	private var m_PageButton1:Button;
	private var m_PageButton2:Button;
	private var m_PageButton3:Button;
	private var m_PageButton4:Button;
	private var m_PageButton5:Button;
	private var m_PageButton6:Button;
	
	private var m_PrevPageButton:Button;
	private var m_NextPageButton:Button;
	
	//Globals
	private var m_LogQuickList:Array;
	private var m_fieldArray:Array;
	private var m_PageButtonArray:Array;
	private var m_Pages:Array;
	private var m_NumPages:Number;
	private var m_CurrPage:Number;
	
	//Statics
	static private var ENTRIES_PER_PAGE:Number = 25;
	static private var PAGE_BUTTON_GAP:Number = 5.5;
	
	private function CabalLog(){	}

	private function configUI()
	{		
		_parent._parent._parent.m_LeaveButton._visible = false;		
		SetLabels();
		
		//Pages
		m_NumPages = 0;
		m_CurrPage = 0;
		
		//Set up guild log stuff from C++
		GuildLog.SignalGuildLogUpdated.Connect(SlotGuildLogUpdated, this);
		GuildLog.RequestGuildLog(true, true, true, true, 0, 100);
		
		//Listeners for checkboxes
		m_AllCheckBox.addEventListener("click", this, "AllBoxChanged");
		m_BankCheckBox.addEventListener("click", this, "TypeFilterChanged");
		m_MembershipCheckBox.addEventListener("click", this, "TypeFilterChanged");
		m_GovernmentCheckBox.addEventListener("click", this, "TypeFilterChanged");
		
		//Page buttons
		m_PrevPageButton.addEventListener("click", this, "PageBackward");
		m_NextPageButton.addEventListener("click", this, "PageForward");
		
		m_PageButtonArray = new Array(m_PageButton1, m_PageButton2, m_PageButton3, m_PageButton4, m_PageButton5, m_PageButton6);
		for (var i:Number = 0; i<m_PageButtonArray.length; i++)
		{
			m_PageButtonArray[i].addEventListener("click", this, "PageButtonClicked");
			m_PageButtonArray[i].visible = false;
		}
	}

	//Set all the text display for labels
	private function SetLabels()
	{
		//Heading
		m_LogHeader.text = LDBFormat.LDBGetText("GuildLog", "ActionType_Cabal").toUpperCase() + " " + LDBFormat.LDBGetText("GuildLog", "Log").toUpperCase();
		
		//Checkboxes
		m_AllTextField.text = LDBFormat.LDBGetText("GuildLog", "ActionType_All");
		m_BankTextField.text = LDBFormat.LDBGetText("GuildLog", "ActionType_Bank");
		m_MembershipTextField.text = LDBFormat.LDBGetText("GuildLog", "ActionType_Membership");
		m_GovernmentTextField.text = LDBFormat.LDBGetText("GuildLog", "ActionType_Government");
		m_AllTextField.textColor = Colors.e_ColorWhite;
		m_BankTextField.textColor = Colors.e_ColorGreen;
		m_MembershipTextField.textColor = Colors.e_ColorYellow;
		m_GovernmentTextField.textColor = Colors.e_ColorCyan;
		
		//Column Headers
		m_TimeHeader.text = LDBFormat.LDBGetText("GuildLog", "Log_Time");
		m_TypeHeader.text = LDBFormat.LDBGetText("GuildLog", "Log_Type");
		m_ActivityHeader.text = LDBFormat.LDBGetText("GuildLog", "Log_Activity");
		
		//Page Buttons
		m_PageButton1.label = "1";
		m_PageButton2.label = "2";
		m_PageButton3.label = "3";
		m_PageButton4.label = "4";
		m_PageButton5.label = "5";
		m_PageButton6.label = "6";
		
		//Pagniation
		m_PrevPageButton.label = LDBFormat.LDBGetText("GuildLog", "Log_PrevPage");
		m_NextPageButton.label = LDBFormat.LDBGetText("GuildLog", "Log_NextPage");
	}
	
	// Called when the client gets new log entries from the server
	private function SlotGuildLogUpdated():Void
	{
		m_LogQuickList = new Array();
		// We have to check if a box is selected because RequestGuildLog returns all records if
		// all filters are false. If no box is selected, we should show nothing instead of what
		// is returned.
		// TODO: Because currently Loot is not supported by RequestGuildLog, we have to remove it from this check.
		// Add it back in when it is supported.
		if (m_BankCheckBox.selected || m_MembershipCheckBox.selected || m_GovernmentCheckBox.selected)
		{
			for (var i:Number = 0; i<GuildLog.m_LogRecords.length; i++)
			{
				var logObject:Object = {recordTime:GuildLog.m_LogRecords[i].m_RecordTime, actionType:GuildLog.m_LogRecords[i].m_ActionType, logText:GuildLog.m_LogRecords[i].m_Text};
				m_LogQuickList.push(logObject);
			}
		}
		InsertPageBreaks(m_LogQuickList);
		GoToPage(0);
	}
	
	// Called when one of the page buttons is clicked
	private function PageButtonClicked(pageButton:Object):Void
	{
		// In case we don't find what page was clicked, set it to the current page
		var pageIndex:Number = m_CurrPage;
		// Find which button was clicked
		for (var i:Number = 0; i<m_PageButtonArray.length; i++)
		{
			var pageButton:Button = m_PageButtonArray[i];
			if (pageButton.hitTest( _root._xmouse, _root._ymouse, true))
			{
				pageIndex = i;
			}
		}
		GoToPage(pageIndex);
		Selection.setFocus(null);
	}
	
	//Called when the previous page button is clicked
	private function PageBackward():Void
	{
		GoToPage(m_CurrPage - 1);
	}
	
	// Called when the next page button is clicked
	private function PageForward():Void
	{
		GoToPage(m_CurrPage + 1);
	}
	
	// Called when one of the checkboxes (other than "All") is clicked
	private function TypeFilterChanged(checkBox:Object):Void
	{
		// Get the new list of log entries with the new filters
		GuildLog.RequestGuildLog(m_BankCheckBox.selected, m_MembershipCheckBox.selected, m_GovernmentCheckBox.selected, true, 0, 100);
		
		// Update the "All" checkbox
		if (m_BankCheckBox.selected == false || m_MembershipCheckBox.selected == false || m_GovernmentCheckBox.selected == false){ m_AllCheckBox.selected = false; }
		else{ m_AllCheckBox.selected = true; }
		Selection.setFocus(null);
	}
	
	//Called when the "All" checkbox is clicked
	private function AllBoxChanged()
	{
		// Update other checkboxes
		m_BankCheckBox.selected = m_AllCheckBox.selected;
		m_MembershipCheckBox.selected = m_AllCheckBox.selected;
		m_GovernmentCheckBox.selected = m_AllCheckBox.selected;
		
		// Get the new list of log entries with the new filters
		GuildLog.RequestGuildLog(m_BankCheckBox.selected, m_MembershipCheckBox.selected, m_GovernmentCheckBox.selected, true, 0, 100);
		Selection.setFocus(null);
	}
	
	// Break the entries into pages
	private function InsertPageBreaks(totalEntries:Array)
	{
		m_Pages = new Array();
		var numPages = Math.ceil(totalEntries.length/ENTRIES_PER_PAGE);
		// Create an array for each page
		for(var i:Number = 0; i<numPages; i++)
		{
			var newPage:Array;
			if (i+1 == numPages)
			{
				m_Pages.push(totalEntries.slice(i*ENTRIES_PER_PAGE, totalEntries.length));
			}
			else
			{
				m_Pages.push(totalEntries.slice(i*ENTRIES_PER_PAGE, (i+1)*ENTRIES_PER_PAGE-1));
			}
		}
		m_NumPages = numPages;
		// Create an empty page if there are no entries we need it to be an array, not undefined.
		if (m_NumPages == 0) { m_Pages.push(totalEntries); }
		UpdatePagination();
	}
	
	// Goes to a given page
	private function GoToPage(pageIndex:Number)
	{
		m_CurrPage = pageIndex
		m_LogScrollingList.dataProvider = m_Pages[m_CurrPage];
		m_LogScrollingList.invalidateData();
		UpdatePagination();
	}
	
	// Updates the display of the page buttons
	private function UpdatePagination()
	{
		// Previous and Next buttons
		if (m_CurrPage == 0){ m_PrevPageButton._visible = false; }
		else{ m_PrevPageButton._visible = true; }
		if (m_CurrPage == m_NumPages-1 || m_NumPages == 0){ m_NextPageButton._visible = false; }
		else{ m_NextPageButton._visible = true; }
		
		for (var i:Number = 0; i<m_PageButtonArray.length; i++)
		{
			//Hide buttons for pages that don't exist
			if (i+1 > m_NumPages) 
			{ 
				m_PageButtonArray[i].enabled = false; 
				m_PageButtonArray[i].visible = false;
			}
			//Set alpha for pages that aren't selected
			else 
			{ 
				m_PageButtonArray[i].enabled = true;
				m_PageButtonArray[i].visible = true;
				m_PageButtonArray[i]._alpha = 25;
			}
		}
		//Set the selected page
		m_PageButtonArray[m_CurrPage]._alpha = 100;
		
		//Center the page buttons
		var center:Number = _parent._width/2;
		var singleButtonWidth = m_PageButton1._width;
		var buttonsWidth = (singleButtonWidth * m_NumPages) + (PAGE_BUTTON_GAP * (m_NumPages - 1));
		for (var i:Number = 0; i<m_PageButtonArray.length; i++)
		{
			m_PageButtonArray[i]._x = (center - buttonsWidth/2) + i*(singleButtonWidth + PAGE_BUTTON_GAP);
		}
	}
}