import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.ButtonGroup;
import gfx.controls.ScrollingList;
import gfx.controls.CheckBox;
import gfx.controls.DropdownMenu;
import com.Components.SearchBox;
import com.Utils.LDBFormat;
import com.Utils.Archive;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.GameInterface.DressingRoom;
import com.GameInterface.DressingRoomNode;
import com.GameInterface.Game.Character;

class GUI.DressingRoom.LeftPanel extends UIComponent
{
	//Components in FLA
	private var m_Tab_0:Button;
	private var m_Tab_1:Button;
	private var m_Tab_2:Button;
	private var m_Tab_3:Button;
	private var m_Tab_4:Button;
	private var m_Tab_5:Button;
	private var m_Tab_6:Button;
	private var m_Tab_7:Button;
	private var m_Tab_8:Button;
	private var m_Tab_9:Button;
	private var m_Tab_10:Button;
	private var m_Tab_11:Button;
	
	private var m_Background:MovieClip;
	private var m_HeaderText:TextField;
	private var m_CategoryText:TextField;
	private var m_UnownedFilterText:TextField;
	private var m_CategoryList:ScrollingList;	
	private var m_SearchBox:SearchBox;
	private var m_UnownedCheckBox:CheckBox;
	//private var m_FilterTypeDropdown:DropdownMenu;
	
	//Variables
	private var m_TabArray:Array;
	private var m_TabGroup:ButtonGroup;
	private var m_CategoryArray:Array;
	private var m_SearchText:String;
	
	private var SignalEquipSlotSelected:Signal;
	private var SignalCategorySelected:Signal;
	
	public function LeftPanel()
	{
		//Block mouse events from continuing to game client
		m_Background.onPress = function(){};
		SignalEquipSlotSelected = new Signal();
		SignalCategorySelected = new Signal();
	}
	
	private function configUI():Void
	{
		super.configUI();		
		m_TabGroup = new ButtonGroup();
		m_TabArray = new Array();
		m_SearchText = "";
		SetLabels();
		SetupTabs();
		
		m_UnownedCheckBox.addEventListener("click",this,"OnUnownedChanged");
		m_SearchBox.SetDefaultText(LDBFormat.LDBGetText("GenericGUI", "SearchText"));
		m_SearchBox.SetSearchOnInput(true, 0);
		m_SearchBox.addEventListener("search", this, "OnSearchText");
		//m_FilterTypeDropdown.disableFocus = true;
	}
	
	private function SetLabels():Void
	{
		m_HeaderText.text = LDBFormat.LDBGetText("GenericGUI", "DressingRoom");
		m_UnownedFilterText.text = LDBFormat.LDBGetText("GenericGUI", "Unowned") + ":";
	}
	
	private function SetupTabs():Void
	{
		var tabNodes:Array = DressingRoom.GetChildren(DressingRoom.GetRootNodeId());
		for (var i:Number = 0; i < tabNodes.length; i++)
		{
			var tab:MovieClip = this["m_Tab_" + i];
			if (tab != undefined)
			{
				tab.m_Content.attachMovie("Slot_"+i, "m_Icon", tab.m_Content.getNextHighestDepth());
				m_TabArray.push(tab);
				tab.group = m_TabGroup;
				tab.data = tabNodes[i];
				tab.disableFocus = true;
			}
		}
		m_TabGroup.addEventListener("change",this,"TabChanged");
	}
	
	private function TabChanged(tab:Button):Void
	{
		//Set header to selected tab name
		//Add children to category listbox
		m_CategoryArray = DressingRoom.GetChildren(tab.data.m_NodeId);
		m_CategoryText.text = tab.data.m_Name.toUpperCase();
		if (Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0)
		{
			m_CategoryText.text += " [" + tab.data.m_NodeId + "]";
		}
		
		//Update the filter types
		/*
		m_FilterTypeDropdown.removeEventListener("change", this, "OnFilterTypeChanged");
		PopulateFilterTypeDropdown();
		m_FilterTypeDropdown.selectedIndex = 0;
		m_FilterTypeDropdown.addEventListener("change", this, "OnFilterTypeChanged");
		*/
		
		//Populate the list
		PopulateCategoryList();
		SignalEquipSlotSelected.Emit();
		RemoveFocus();
	}
	
	private function PopulateFilterTypeDropdown():Void
	{
		//TODO: Base this on selected tab
		/*
		var filterTypeList:Array = new Array();
		var filterObject:Object = {label:"All", index:0};
		var filterObject2:Object = {label:"Some", index:1};
		filterTypeList.push(filterObject);
		filterTypeList.push(filterObject2);
		
		m_FilterTypeDropdown.dataProvider = filterTypeList;
		m_FilterTypeDropdown.rowCount = m_FilterTypeDropdown.dataProvider.length;
		m_FilterTypeDropdown.invalidateData();
		*/
	}
	
	private function PopulateCategoryList():Void
	{
		m_CategoryList.removeEventListener("change", this, "OnItemSelected");
		var filteredArray:Array = FilterCategoryArray(m_CategoryArray);
		filteredArray.sortOn("m_Name", Array.CASEINSENSITIVE);
		m_CategoryList.dataProvider = filteredArray;
		m_CategoryList.invalidateData();
		m_CategoryList.addEventListener("change", this, "OnCategorySelected");
		m_CategoryList.selectedIndex = 0;
		OnCategorySelected();
	}
	
	private function FilterCategoryArray(categoryArray:Array):Array
	{
		var filteredArray:Array = new Array();
		var showUnowned:Boolean = m_UnownedCheckBox.selected;
		var filterType:Number = 0; //m_FilterTypeDropdown.selectedIndex;
		for (var i:Number = 0; i < categoryArray.length; i++)
		{
			var compareItem:DressingRoomNode = categoryArray[i];
			if (DressingRoom.GetChildren(compareItem.m_NodeId).length > 0)
			{
				if (DressingRoom.NodeOwned(compareItem.m_NodeId) || showUnowned)
				{
					if (filterType == 0 || filterType == compareItem.m_FilterType)
					{
						if (m_SearchText == "" || compareItem.m_Name.toLowerCase().indexOf(m_SearchText.toLowerCase()) != -1)
						{
							filteredArray.push(compareItem);
						}
					}
				}
			}
		}
		return filteredArray;
	}
	
	private function OnSearchText(event:Object):Void
	{
		m_SearchText = event.searchText;
		PopulateCategoryList();
	}
	
	private function OnUnownedChanged():Void
	{
		PopulateCategoryList();
		RemoveFocus();
	}
	
	private function OnFilterTypeChanged():Void
	{
		PopulateCategoryList();
		RemoveFocus();
	}
	
	private function OnCategorySelected():Void
	{
		SignalCategorySelected.Emit(m_CategoryList.dataProvider[m_CategoryList.selectedIndex]);
	}
	
	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}
	
	function OnModuleActivated(config:Archive):Void
	{
		m_UnownedCheckBox.selected = config.FindEntry("Unowned", true);
		m_TabGroup.setSelectedButton(m_TabArray[config.FindEntry("SelectedTab", 0)]);
	}
	
	function OnModuleDeactivated()
	{
		var archive:Archive = new Archive();
		archive.AddEntry("Unowned", m_UnownedCheckBox.selected);
		for (var i:Number = 0; i < m_TabArray.length; i++)
		{
			if (m_TabGroup.selectedButton == m_TabArray[i])
			{
				archive.AddEntry("SelectedTab", i);
				break;
			}
		}
		return archive;
	}
}