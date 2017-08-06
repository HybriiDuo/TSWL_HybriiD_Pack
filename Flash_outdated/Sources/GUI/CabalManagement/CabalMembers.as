import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.DropdownMenu;
import gfx.controls.ScrollingList;
import gfx.controls.TextArea;
import gfx.controls.Label;
import gfx.controls.TextInput;
import gfx.controls.ButtonGroup;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import com.GameInterface.Friends;

import com.Components.SearchBox;
import com.Components.MultiColumnList.HeaderButton;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import com.GameInterface.Guild.*;
import com.Components.FCButton;

class GUI.CabalManagement.CabalMembers extends UIComponent
{
	private var m_EditRoleNameWindow:MovieClip;
	private var m_PopupOverlay:MovieClip;

	private var m_MembersInfoHeader:Label;
	private var m_YourRoleLabel:Label;
	private var m_YourRole:Label;
	private var m_GovernmentTypeLabel:Label;
	private var m_GovernmentTypeDropdown:DropdownMenu;
	private var m_TotalMembersLabel:Label;
	private var m_TotalMembers:MovieClip;

	private var m_RolePermissionsHeader:Label;
	private var m_PermissionsScrollingList:ScrollingList;
	private var m_RoleButton:FCButton;
	private var m_PermissionsButton:FCButton;
	private var m_RolePermissionsNameButton:FCButton;
	private var m_RoleDropdown:MovieClip;
	private var m_PermissionsDropdown:MovieClip;
	private var m_RolePermissionButtonGroup:ButtonGroup;
	private var m_RolePermissionNameText:TextInput;

	private var m_MembersListHeader:Label;
	private var m_Header1:HeaderButton;
	private var m_Header2:HeaderButton;
	private var m_Header3:HeaderButton;
	private var m_Header4:HeaderButton;
	private var m_MembersScrollingList:ScrollingList;
	private var m_MembersSearchBox:SearchBox;

	private var m_ResetButton:Button;
	private var m_ApplyButton:Button;

	private var m_KickButtton:Button;
	private var m_DemoteButton:Button;
	private var m_PromoteButton:Button;

	private var m_RoleHeader:Array;
	private var m_PermissionHeader:Array;
	private var m_Permissions:Array;
	private var m_Roles:Array;

	private var m_MembersQuickList:Array;
	private var m_FullMemberList:Array;
	private var m_Members:Array;
	private var m_Guild:Guild;
	
	private var m_fieldArray:Array;
	private var m_headerArray:Array;
	
	private var m_GuildLeader:Number;
	private var m_CurrGovernmentType:Number;
	
	private var CUSTOM_GOVERNMENT:Number = 255;
	//TODO: Localize this
	private var CUSTOM:String = "Custom";
	
	private var PERMISSION_BITS:Array;

	private function CabalMembers()
	{
		Guild.GetInstance().GetGuildMembers();
		m_Guild = Guild.GetInstance();

		m_Guild.SignalMembersUpdate.Connect(SlotMemberUpdated,this);
		m_Guild.SignalRankUpdated.Connect(SlotRankUpdated,this);
		m_Guild.SignalGoverningformUpdated.Connect(SlotGoverningformUpdated,this);
	}

	private function configUI()
	{
		PERMISSION_BITS = new Array();
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "CanDisbandGuild")] = 1;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanInviteOthers")] = 1 << 1;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanKickOthers")] = 1 << 2;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanPromote")] = 1 << 3;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanDemote")] = 1 << 4;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanWithdrawMoney")] = 1 << 6;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanChangeGoverningForm")] = 1 << 7;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanChangeMotd")] = 1 << 8;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanChangeName")] = 1 << 9;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanChangeRecruitmentMode")] = 1 << 10;
		PERMISSION_BITS[LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_CanWithdrawItems")] = 1 << 15;
		_parent._parent._parent.m_LeaveButton._visible = true;
		m_GovernmentTypeDropdown.disableFocus = true;
		m_RoleDropdown.disableFocus = true;
		m_PermissionsDropdown.disableFocus = true;
		m_GovernmentTypeDropdown.addEventListener("change",this,"GovernmentTypeDisplayChanged");
		m_RoleDropdown.addEventListener("change",this,"RemoveFocus");
		m_PermissionsDropdown.addEventListener("change",this,"RemoveFocus");

		m_MembersSearchBox.SetSearchOnInput(true);
		m_MembersSearchBox.SetDefaultText(LDBFormat.LDBGetText("GenericGUI", "SearchText"));
		m_MembersSearchBox.addEventListener("search",this,"SearchTextChanged");

		m_RolePermissionButtonGroup = new ButtonGroup();

		m_RoleButton.group = m_RolePermissionButtonGroup;
		m_RoleButton.SetTooltipText(LDBFormat.LDBGetText("GenericGUI", "PermissionButtonTooltip"));

		m_PermissionsButton.group = m_RolePermissionButtonGroup;
		m_PermissionsButton.SetTooltipText(LDBFormat.LDBGetText("GuildGUI", "RankButtonTooltip"));

		m_RolePermissionsNameButton.group = m_RolePermissionButtonGroup;
		m_RolePermissionsNameButton.SetTooltipText(LDBFormat.LDBGetText("GuildGUI", "NameButtonTooltip"));

		SetLabels();

		FillMembersInfo();
		FillRolePermissions();
		FillMemberList();

		m_ResetButton.addEventListener("click",this,"ResetChanges");
		m_ApplyButton.addEventListener("click",this,"ApplyChanges");

		m_KickButtton.addEventListener("click",this,"KickMembers");
		m_DemoteButton.addEventListener("click",this,"DemoteMembers");
		m_PromoteButton.addEventListener("click",this,"PromoteMembers");

		m_ResetButton.disableFocus = true;
		m_ApplyButton.disableFocus = true;

		m_KickButtton.disableFocus = true;
		m_DemoteButton.disableFocus = true;
		m_PromoteButton.disableFocus = true;

		m_MembersScrollingList.addEventListener("itemClick",this,"SelectMember");
		m_PermissionsScrollingList.addEventListener("itemClick",this,"SelectPermission");
		
		m_fieldArray = new Array("nickName", "guildRank", "playfield", "lastOnline");
		m_headerArray = new Array(m_Header1, m_Header2, m_Header3, m_Header4);
		
		m_Header1.SetId(0);
		m_Header2.SetId(1);
		m_Header3.SetId(2);
		m_Header4.SetId(3);

		m_Header1.addEventListener("sort",this,"SlotSortMembers");
		m_Header2.addEventListener("sort",this,"SlotSortMembers");
		m_Header3.addEventListener("sort",this,"SlotSortMembers");
		m_Header4.addEventListener("sort",this,"SlotSortMembers");
		
		m_CurrGovernmentType = Guild.GetInstance().m_GoverningformID;
	}

	function SlotSortMembers(event:Object)
	{
		var field:String = m_fieldArray[event.id];
		m_MembersQuickList.sortOn(field,event.direction);
		m_MembersScrollingList.dataProvider = m_MembersQuickList;
		m_MembersScrollingList.invalidateData();
		for(var i:Number = 0; i<m_headerArray.length; i++)
		{
			m_headerArray[i].SetShowArrow(false);
		}
		m_headerArray[event.id].SetShowArrow(true);
	}

	function SelectMember(event:Object)
	{
		var isSelected = !m_MembersScrollingList.dataProvider[event.index].selected;
		m_MembersScrollingList.dataProvider[event.index].selected = isSelected;
		m_MembersScrollingList.invalidateData();
		Guild.GetInstance().SetMemberSelected(m_MembersScrollingList.dataProvider[event.index].id,isSelected);
	}

	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}
	
	private function GovernmentTypeDisplayChanged():Void
	{
		var disable:Boolean = false;
		if (m_GovernmentTypeDropdown.selectedIndex != Guild.GetInstance().m_GoverningformID && 
			m_GovernmentTypeDropdown.dataProvider[m_GovernmentTypeDropdown.selectedIndex] != CUSTOM){ disable = true; }
		m_RolePermissionsNameButton.disabled = disable;
		m_RoleDropdown.disabled = disable;
		m_PermissionsButton.disabled = disable;
		m_RoleButton.disabled = disable;
		m_PermissionsScrollingList.disabled = disable;
		
		//Reset if we changed 
		if (m_GovernmentTypeDropdown.dataProvider[m_GovernmentTypeDropdown.selectedIndex] != CUSTOM)
		{
			FillRolePermissions();
		}
		else
		{
			//If it was a 4 rank type, make a 5th rank
			if (m_RoleHeader.length < 5)
			{
				for (var i:Number = 0; i<m_RoleHeader.length; i++)
				{
					m_RoleHeader[i] = m_RoleHeader[i].substr(0, m_RoleHeader[i].length-2) + "5)";
				}
				m_RoleHeader = m_RoleHeader.concat("5 (5/5)");
				var tempIndex:Number = m_RoleDropdown.selectedIndex;
				m_RoleDropdown.dataProvider = m_RoleHeader;
				m_RoleDropdown.rowCount = m_RoleDropdown.dataProvider.length;
				m_RoleDropdown.selectedIndex = tempIndex;
				
				m_Permissions.push(CreatePermissionsForRank(m_Guild.GetRankArray()[m_Guild.GetRankArray().length-1]));
				for (var i=0; i<m_Permissions[m_Permissions.length-1].length; i++)
				{
					m_Permissions[m_Permissions.length - 1][i].category = "5";
				}
			}
		}
		
		Selection.setFocus(null);
	}

	private function GetSelectedMembers():Array
	{
		var memberArray:Array = new Array();
		for (var i = 0; i < m_MembersScrollingList.dataProvider.length; i++)
		{
			if (m_MembersScrollingList.dataProvider[i].selected)
			{
				memberArray.push(m_MembersScrollingList.dataProvider[i].id);
			}
		}
		return memberArray;
	}

	private function ResetChanges()
	{
		//TODO: Re-load the permissions from the server's last saved version
		FillRolePermissions();
		if (Guild.GetInstance().m_GoverningformID == CUSTOM_GOVERNMENT)
		{
			m_GovernmentTypeDropdown.selectedIndex = m_GovernmentTypeDropdown.dataProvider.length - 1;
		}
		else
		{
			m_GovernmentTypeDropdown.selectedIndex = Guild.GetInstance().m_GoverningformID;
		}
	}

	private function ApplyChanges()
	{
		//Change to non-custom cabal types
		if (m_GovernmentTypeDropdown.dataProvider[m_GovernmentTypeDropdown.selectedIndex] != CUSTOM)
		{
			Guild.GetInstance().UpdateGuildInfoData(Guild.GetInstance().m_GuildName,
													Guild.GetInstance().m_MessageOfTheDay,
													0,
													m_GovernmentTypeDropdown.selectedIndex,
													false,
													"", 0, "", 0, "", 0, "", 0, "", 0); //Not a custom government
		}
		//TODO: Change to custom cabal
		else
		{
			var rankPermissions:Array = new Array()
			for (var i=0; i < m_Permissions.length; i++)
			{
				var permissionsNum:Number = 0;
				for (var j = 0; j < m_Permissions[i].length; j++)
				{
					if (m_Permissions[i][j].hasAccess1)
					{
						permissionsNum = permissionsNum | PERMISSION_BITS[m_Permissions[i][j].name1];
					}
					if (m_Permissions[i][j].hasAccess2)
					{
						permissionsNum = permissionsNum | PERMISSION_BITS[m_Permissions[i][j].name2];
					}
				}
				rankPermissions.push(permissionsNum);
			}
			Guild.GetInstance().UpdateGuildInfoData(Guild.GetInstance().m_GuildName,
													Guild.GetInstance().m_MessageOfTheDay,
													0,
													CUSTOM_GOVERNMENT,
													true,
													m_Permissions[0][0].category, rankPermissions[0], 
													m_Permissions[1][0].category, rankPermissions[1], 
													m_Permissions[2][0].category, rankPermissions[2], 
													m_Permissions[3][0].category, rankPermissions[3],
													m_Permissions[4][0].category, rankPermissions[4]);
		}
	}

	private function KickMembers()
	{
		var memberArray:Array = GetSelectedMembers();
		Guild.GetInstance().KickMembers(memberArray);
	}

	private function DemoteMembers()
	{
		var memberArray:Array = GetSelectedMembers();
		Guild.GetInstance().DemoteMembers(memberArray);
	}

	private function PromoteMembers()
	{
		var memberArray:Array = GetSelectedMembers();
		Guild.GetInstance().PromoteMembers(memberArray);
	}
	
	private function SlotChangeRoleName(newName:String, oldName:String, rankNumber:String)
	{
		//Check to make sure this name doesn't already exist in the edited set
		for (var i=0; i < m_RoleDropdown.dataProvider.length; i++)
		{
			var tempIndex:Number = m_RoleDropdown.dataProvider[i].lastIndexOf(" ");
			var unrankedRole:String = m_RoleDropdown.dataProvider[i].substr(0, tempIndex);
			if (unrankedRole == newName)
			{
				var errString:String = LDBFormat.LDBGetText("GuildGUI", "RoleNameAlreadyExists");
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit(errString, 0);
				return;
			}
		}
		UpdateRoleName(oldName, newName, rankNumber);
		//Set the government type to custom (always last on the list)
		m_GovernmentTypeDropdown.selectedIndex = m_GovernmentTypeDropdown.dataProvider.length - 1;
		CloseEditRoleNameWindow();
	}

	private function UpdateRoleName(currName, newName, rank)
	{
		for (var i = 0; i < m_RoleDropdown.dataProvider.length; i++)
		{
			if (m_RoleDropdown.dataProvider[i] == currName + rank)
			{
				m_RoleDropdown.dataProvider[i] = newName + rank;
			}
		}
		for (var i = 0; i < m_Roles.length; i++)
		{
			for (var j = 0; j < m_Roles[i].length; j++)
			{
				if (m_Roles[i][j].name1 == currName + rank)
				{
					m_Roles[i][j].name1 = newName + rank;
				}
				if (m_Roles[i][j].name2 == currName + rank)
				{
					m_Roles[i][j].name2 == newName + rank;
				}
			}
		}
		for (var i = 0; i < m_Permissions.length; i++)
		{
			for (var j = 0; j < m_Permissions[i].length; j++)
			{
				if (m_Permissions[i][j].category == currName)
				{
					m_Permissions[i][j].category = newName;
				}
			}
		}
		//TODO: This will probably be taken care of later when saving to the server works
		//Server also needs to take care of changing rank names in member's list.
		if (m_YourRole.text == currName)
		{
			m_YourRole.text = newName;
		}
	}

	private function SetLabels()
	{
		m_MembersInfoHeader.text = LDBFormat.LDBGetText("GuildGUI", "MembersInfo");
		m_YourRoleLabel.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_YourRole");
		m_GovernmentTypeLabel.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_GovernmentType");
		m_TotalMembersLabel.text = LDBFormat.LDBGetText("GuildGUI", "TotalMembers");

		m_RolePermissionsHeader.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_GuildMembershipRights");

		m_MembersListHeader.text = LDBFormat.LDBGetText("GuildGUI", "MembersList");
		m_Header1.label = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_Name");
		m_Header2.label = LDBFormat.LDBGetText("GuildGUI", "GuildRank");
		m_Header3.label = LDBFormat.LDBGetText("GuildGUI", "CurrentPlayfield");
		m_Header4.label = LDBFormat.LDBGetText("GuildLog", "Log_Activity");

		m_ResetButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
		m_ApplyButton.label = LDBFormat.LDBGetText("GenericGUI", "Save");

		m_KickButtton.label = LDBFormat.LDBGetText("GuildGUI", "Kick");
		m_DemoteButton.label = LDBFormat.LDBGetText("GuildGUI", "DemoteMember");
		m_PromoteButton.label = LDBFormat.LDBGetText("GuildGUI", "PromoteMember");

	}

	private function SlotMemberUpdated()
	{
		FillMemberList();
		SearchTextChanged();
		m_MembersScrollingList.invalidateData();
	}

	function SlotGoverningformUpdated(newGoverningForm:Number)
	{
		//Only update all of this if the governing form was actually changed
		//This signal is also sent when only permissions are changed.
		if (m_CurrGovernmentType != newGoverningForm)
		{
			m_CurrGovernmentType = newGoverningForm;
			FillMembersInfo();
			FillRolePermissions();
			m_PermissionsScrollingList.invalidateData();
			//Fake the ranks in the member list
			//TODO: Not this.
			FakeMemberList();
		}
	}

	private function SlotRankUpdated()
	{
		FillMembersInfo();
		FillRolePermissions();
		m_PermissionsScrollingList.invalidateData();
		m_MembersScrollingList.invalidateData();
	}
	
	//Fake the ranks in the member list
	//We have to do this because the server does not tell us when the ranks have been properly updated
	//The Governing form is changed, then the ranks are updated, but we get the governing form change signal
	//before the ranks are updated, and the rank update signals are never sent.
	//This data will be out of sync with the server, but not for very long.
	private function FakeMemberList()
	{
		for (var i:Number = 0; i< m_MembersScrollingList.dataProvider.length; i++)
		{
			if (m_MembersScrollingList.dataProvider[i].id == m_GuildLeader)
			{
				if (m_Guild.GetRankArray()[m_Guild.GetMaxRank()].GetName() != undefined)
				{
					m_MembersScrollingList.dataProvider[i].guildRank = m_Guild.GetMaxRank() + 1;
				}
				else if (m_Guild.GetRankArray()[m_Guild.GetMaxRank() - 1].GetName() != undefined)
				{
					m_MembersScrollingList.dataProvider[i].guildRank = m_Guild.GetMaxRank();
				}
				else
				{
					m_MembersScrollingList.dataProvider[i].guildRank = m_Guild.GetMaxRank() - 1;
				}
			}
			else
			{
				m_MembersScrollingList.dataProvider[i].guildRank = 1;
			}
		}
		m_MembersScrollingList.invalidateData();
	}

	private function FillMemberList()
	{
		m_Members = m_Guild.GetMembers();

		m_MembersQuickList = new Array();
		m_FullMemberList = new Array();

		for (var i:Number = 0; i < m_Members.length; i++)
		{
			AddGuildMemberToArray(m_Members[i],m_FullMemberList);
		}
		m_MembersQuickList = m_FullMemberList;
		m_MembersScrollingList.dataProvider = m_MembersQuickList;
		m_TotalMembers.text = m_FullMemberList.length;
		m_Header1.label = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_Name");
	}

	///Helper function to add a guild member to a given array (To be dataprovider for the members list)
	private function AddGuildMemberToArray(guildMember:GuildMember, addArray:Array)
	{
		//This is inefficient. Would be nice to be able to get online status straight from the guild's list
		//rather than comparing it with the friends list.
		for (var key in Friends.m_GuildFriends)
		{
			if (Friends.m_GuildFriends[key].m_Name == guildMember.m_Name)
			{
				var onlineNow:Boolean = Friends.m_GuildFriends[key].m_Online;
				var onlineTime:Number = Friends.m_GuildFriends[key].m_OnlineTime*1000;
				var memberObject:Object = {id:guildMember.m_Instance, nickName:guildMember.m_Name, playfield:guildMember.m_Playfield, guildRank:guildMember.m_Role + 1, selected:guildMember.m_IsSelected, online:onlineNow, lastOnline:onlineTime};
				if (memberObject.guildRank == m_Guild.GetMaxRank()){ m_GuildLeader = memberObject.id; }
				addArray.push(memberObject);
			}
		}
	}

	private function SearchTextChanged()
	{
		var searchText:String = m_MembersSearchBox.GetSearchText().toLowerCase();
		if (searchText == "")
		{
			m_MembersQuickList = m_FullMemberList;
		}
		else
		{
			var guild:Guild = Guild.GetInstance();
			var members:Array = guild.GetMembers();
			var searchMemberList:Array = new Array();

			var searchForLevel:Boolean = false;
			var levelToSearchFrom:Number = 0;
			var levelToSearchTo:Number = 0;
			var searchForLevelRange:Boolean = false;

			if (Number(searchText) != NaN)
			{
				searchForLevel = true;
				levelToSearchFrom = Number(searchText);
			}
			var splitString:Array = searchText.split('-');
			if (splitString.length == 2 && Number(splitString[0]) != NaN && Number(splitString[1]) != NaN)
			{
				searchForLevelRange = true;
				levelToSearchFrom = Number(splitString[0]);
				levelToSearchTo = Number(splitString[1]);
			}

			for (var i:Number = 0; i < members.length; i++)
			{
				if (searchForLevel)
				{
					if (levelToSearchFrom == members[i].m_Level)
					{
						AddGuildMemberToArray(members[i],searchMemberList);
					}
				}
				else if (searchForLevelRange)
				{
					if (levelToSearchFrom <= members[i].m_Level && levelToSearchTo >= members[i].m_Level)
					{
						AddGuildMemberToArray(members[i],searchMemberList);
					}
				}
				else
				{
					var gmName:String = members[i].m_Name.toLowerCase();
					if (gmName.indexOf(searchText) >= 0)
					{
						AddGuildMemberToArray(members[i],searchMemberList);
					}
				}
			}
			m_MembersQuickList = searchMemberList;
		}
		m_Header1.label = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_Name") + " (" + m_MembersQuickList.length + ")";
		m_MembersScrollingList.dataProvider = m_MembersQuickList;
	}

	private function FillMembersInfo()
	{
		var governmentTypes:Array = Guild.GetInstance().m_GoverningFormArray.slice(0);
		governmentTypes.push(CUSTOM);
		m_GovernmentTypeDropdown.dataProvider = governmentTypes;
		if (Guild.GetInstance().m_GoverningformID == CUSTOM_GOVERNMENT)
		{
			m_GovernmentTypeDropdown.selectedIndex = m_GovernmentTypeDropdown.dataProvider.length - 1;
		}
		else
		{
			m_GovernmentTypeDropdown.selectedIndex = Guild.GetInstance().m_GoverningformID;
		}
		m_GovernmentTypeDropdown.rowCount = m_GovernmentTypeDropdown.dataProvider.length;

		m_YourRole.text = m_Guild.GetRankName();
		m_TotalMembers.text = m_Guild.m_NumMembers;
		
		if (Guild.GetInstance().CanChangeGoverningform())
		{
			m_GovernmentTypeDropdown.disabled = false;
			m_RolePermissionsNameButton._visible = true;
			m_ApplyButton._visible = true;
			m_ResetButton._visible = true;
		}
	}

	private function FillRolePermissions()
	{
		m_RoleHeader = new Array();
		m_Permissions = new Array();
		m_PermissionHeader = new Array();
		m_Roles = new Array();

		var maxRank = m_Guild.GetMaxRank();

		var rankArray = m_Guild.GetRankArray();

		for (var i = 0; i < rankArray.length; ++i)
		{
			m_RoleHeader.push(rankArray[i].GetName() + " (" + rankArray[i].GetRankNr() + "/" + maxRank + ")");
			m_Permissions.push(CreatePermissionsForRank(rankArray[i]));
		}

		m_RoleDropdown.dataProvider = m_RoleHeader;
		m_RoleDropdown.rowCount = m_RoleDropdown.dataProvider.length;
		m_RoleDropdown.addEventListener("select",this,"RoleClicked");

		var permissionArray:Array = m_Guild.GetGuildPermissions();
		for (var i = 0; i < permissionArray.length; ++i)
		{
			if(permissionArray[i].GetPermissionID() != 128 &&	//Can change governing form
			   permissionArray[i].GetPermissionID() != 1024)	//Can change recruitment mode
			{
				m_PermissionHeader.push(permissionArray[i].GetPermissionText());
				m_Roles.push(CreateRanksForPermission(permissionArray[i]));
			}
		}

		m_PermissionsDropdown.dataProvider = m_PermissionHeader;

		m_PermissionsDropdown.selectedIndex = 0;
		m_PermissionsDropdown.addEventListener("select",this,"PermissionClicked");
		m_PermissionsDropdown.label = m_PermissionHeader[0];

		m_RoleButton.selected = true;
		ShowRoleMenu();

		m_RolePermissionButtonGroup.addEventListener("change",this,"RolePermissionViewSwitch");
	}

	private function RolePermissionViewSwitch(event:Object)
	{
		if (event.item == m_RoleButton)
		{
			ShowRoleMenu();
		}
		else if (event.item == m_PermissionsButton)
		{
			ShowPermissionsMenu();
		}
		else if (event.item == m_RolePermissionsNameButton)
		{
			ShowNameEditor();
		}
	}

	private function CreatePermissionsForRank(rank:GuildRank):Array
	{
		var rankPermissions:Array = new Array();
		var permissionsUnsorted = m_Guild.GetGuildPermissions();
		var permissions:Array = new Array();
		for (var i = 0; i < permissionsUnsorted.length; i++)
		{
			if (rank.HasAccess(permissionsUnsorted[i].GetPermissionID()))
			{
				if(permissionsUnsorted[i].GetPermissionID() != 128 && 	//Can change governing form
				   permissionsUnsorted[i].GetPermissionID() != 1024)	//Can change recruitment mode
				{
					permissions.push(permissionsUnsorted[i]);
				}
			}
		}
		for (var i = 0; i < permissionsUnsorted.length; i++)
		{
			if (!rank.HasAccess(permissionsUnsorted[i].GetPermissionID()))
			{
				if(permissionsUnsorted[i].GetPermissionID() != 128 &&	//Can change governing form
				   permissionsUnsorted[i].GetPermissionID() != 1024)	//Can change recruitment mode
				{
					permissions.push(permissionsUnsorted[i]);
				}
			}
		}

		for (var i = 0; i < permissions.length; i = i + 2)
		{
			var perm1:String = undefined;
			var has1:Boolean = undefined;
			var perm2:String = undefined;
			var has2:Boolean = undefined;

			if (permissions[i] != undefined)
			{
				var perm1:String = permissions[i].GetPermissionText();
				var has1:Boolean = rank.HasAccess(permissions[i].GetPermissionID());
			}
			if (permissions[i + 1] != undefined)
			{
				var perm2:String = permissions[i + 1].GetPermissionText();
				var has2:Boolean = rank.HasAccess(permissions[i + 1].GetPermissionID());
			}

			var permissionObject:Object = {category:rank.GetName(), name1:perm1, hasAccess1:has1, name2:perm2, hasAccess2:has2};
			rankPermissions.push(permissionObject);
		}

		return rankPermissions;
	}

	function CreateRanksForPermission(permission:GuildPermission):Array
	{
		var permissionRanks:Array = new Array();
		var ranksUnsorted = m_Guild.GetRankArray();
		var ranks:Array = new Array();

		for (var i = 0; i < ranksUnsorted.length; i++)
		{
			if (ranksUnsorted[i].HasAccess(permission.GetPermissionID()))
			{
				if(permission.GetPermissionID() != 128 &&	//Can change governing form
				   permission.GetPermissionID() != 1024)	//Can change recruitment mode
				{
					ranks.push(ranksUnsorted[i]);
				}
			}
		}
		for (var i = 0; i < ranksUnsorted.length; i++)
		{
			if (!ranksUnsorted[i].HasAccess(permission.GetPermissionID()))
			{
				if(permission.GetPermissionID() != 128 &&	//Can change governing form
				   permission.GetPermissionID() != 1024)	//Can change recruitment mode
				{
					ranks.push(ranksUnsorted[i]);
				}
			}
		}

		var maxRank = m_Guild.GetMaxRank();

		for (var i = 0; i < ranks.length; i = i + 2)
		{
			var rank1:String = undefined;
			var has1:Boolean = undefined;
			var rank2:String = undefined;
			var has2:Boolean = undefined;

			if (ranks[i] != undefined)
			{
				var rank1:String = ranks[i].GetName() + " (" + ranks[i].GetRankNr() + "/" + maxRank + ")";
				var has1:Boolean = ranks[i].HasAccess(permission.GetPermissionID());
			}
			if (ranks[i + 1] != undefined)
			{
				var rank2:String = ranks[i + 1].GetName() + " (" + ranks[i + 1].GetRankNr() + "/" + maxRank + ")";
				var has2:Boolean = ranks[i + 1].HasAccess(permission.GetPermissionID());
			}

			var rankObject:Object = {category:permission.GetPermissionText(), name1:rank1, hasAccess1:has1, name2:rank2, hasAccess2:has2};
			permissionRanks.push(rankObject);
		}

		return permissionRanks;
	}

	function SelectPermission(event:Object):Void
	{
		if (Guild.GetInstance().CanChangeGoverningform())
		{
			if (m_GovernmentTypeDropdown.selectedIndex != m_GovernmentTypeDropdown.dataProvider.length - 1)
			{
				//Set the government type to custom (always last on the list)
				m_GovernmentTypeDropdown.selectedIndex = m_GovernmentTypeDropdown.dataProvider.length - 1;
			}
			if (_xmouse < 200)
			{
				var isSelected = !m_PermissionsScrollingList.dataProvider[event.index].hasAccess1;
				m_PermissionsScrollingList.dataProvider[event.index].hasAccess1 = isSelected;
				m_PermissionsScrollingList.invalidateData();
				if (m_RoleDropdown._visible)
				{
					for (var i = 0; i < m_Roles.length; i++)
					{
						for (var j = 0; j < m_Roles[i].length; j++)
						{
							if (m_Roles[i][j].category == m_PermissionsScrollingList.dataProvider[event.index].name1)
							{
								if (m_Roles[i][j].name1 == m_RoleDropdown.dataProvider[m_RoleDropdown.selectedIndex])
								{
									m_Roles[i][j].hasAccess1 = isSelected;
									break;
								}
								if (m_Roles[i][j].name2 == m_RoleDropdown.dataProvider[m_RoleDropdown.selectedIndex])
								{
									m_Roles[i][j].hasAccess2 = isSelected;
									break;
								}
							}
						}
					}
				}
				if (m_PermissionsDropdown._visible)
				{
					for (var i = 0; i < m_Permissions.length; i++)
					{
						for (var j = 0; j < m_Permissions[i].length; j++)
						{
							var tempString:String = m_PermissionsScrollingList.dataProvider[event.index].name1;
							var tempIndex:Number = tempString.lastIndexOf(" ");
							tempString = tempString.substr(0, tempIndex);

							if (tempString == m_Permissions[i][j].category)
							{
								if (m_Permissions[i][j].name1 == m_PermissionsDropdown.dataProvider[m_PermissionsDropdown.selectedIndex])
								{
									m_Permissions[i][j].hasAccess1 = isSelected;
									break;
								}
								if (m_Permissions[i][j].name2 == m_PermissionsDropdown.dataProvider[m_PermissionsDropdown.selectedIndex])
								{
									m_Permissions[i][j].hasAccess2 = isSelected;
									break;
								}
							}
						}
					}
				}
			}
			else
			{
				var isSelected = !m_PermissionsScrollingList.dataProvider[event.index].hasAccess2;
				m_PermissionsScrollingList.dataProvider[event.index].hasAccess2 = isSelected;
				m_PermissionsScrollingList.invalidateData();
				if (m_RoleDropdown._visible)
				{
					for (var i = 0; i < m_Roles.length; i++)
					{
						for (var j = 0; j < m_Roles[i].length; j++)
						{
							if (m_Roles[i][j].category == m_PermissionsScrollingList.dataProvider[event.index].name2)
							{
								if (m_Roles[i][j].name1 == m_RoleDropdown.dataProvider[m_RoleDropdown.selectedIndex])
								{
									m_Roles[i][j].hasAccess1 = isSelected;
									break;
								}
								if (m_Roles[i][j].name2 == m_RoleDropdown.dataProvider[m_RoleDropdown.selectedIndex])
								{
									m_Roles[i][j].hasAccess2 = isSelected;
									break;
								}
							}
						}
					}
				}
				if (m_PermissionsDropdown._visible)
				{
					for (var i = 0; i < m_Permissions.length; i++)
					{
						for (var j = 0; j < m_Permissions[i].length; j++)
						{
							var tempString:String = m_PermissionsScrollingList.dataProvider[event.index].name2;
							var tempIndex:Number = tempString.lastIndexOf(" ");
							tempString = tempString.substr(0, tempIndex);

							if (tempString == m_Permissions[i][j].category)
							{
								if (m_Permissions[i][j].name1 == m_PermissionsDropdown.dataProvider[m_PermissionsDropdown.selectedIndex])
								{
									m_Permissions[i][j].hasAccess1 = isSelected;
									break;
								}
								if (m_Permissions[i][j].name2 == m_PermissionsDropdown.dataProvider[m_PermissionsDropdown.selectedIndex])
								{
									m_Permissions[i][j].hasAccess2 = isSelected;
									break;
								}
							}
						}
					}
				}
			}
		}
	}

	private function ShowRoleMenu()
	{
		m_RoleButton.selected = true;
		m_PermissionsDropdown._visible = false;
		if (Guild.GetInstance().CanChangeGoverningform())
		{
			m_RolePermissionsNameButton._visible = true;
		}
		m_RoleDropdown._visible = true;
		m_RoleDropdown.selectedIndex = (Guild.GetInstance().GetRankID() - 1);
		m_PermissionsScrollingList.dataProvider = m_Permissions[m_RoleDropdown.selectedIndex];
	}

	private function ShowPermissionsMenu()
	{
		m_PermissionsButton.selected = true;
		m_PermissionsDropdown._visible = true;
		m_RolePermissionsNameButton._visible = false;
		m_PermissionsDropdown.selectedIndex = 0;
		m_RoleDropdown._visible = false;
		m_PermissionsScrollingList.dataProvider = m_Roles[m_PermissionsDropdown.selectedIndex];
	}

	private function ShowNameEditor()
	{
		m_RolePermissionsNameButton.selected = true;
		m_RoleDropdown._visible = true;
		OpenEditRoleNameWindow();
	}

	private function OpenEditRoleNameWindow()
	{
		DisableAllComponents(true);

		m_PopupOverlay = attachMovie("WindowBackground", "m_PopupOverlay", getNextHighestDepth());
		m_PopupOverlay._x = -10;
		m_PopupOverlay._y = -90;
		m_PopupOverlay._alpha = 0;
		m_PopupOverlay.tweenTo(1,{_alpha:80},Strong.easeOut);

		m_EditRoleNameWindow = attachMovie("EditRoleNamePopup", "m_EditRoleNameWindow", getNextHighestDepth());
		m_EditRoleNameWindow._visible = true;
		m_EditRoleNameWindow._alpha = 0;
		m_EditRoleNameWindow._x = 35;
		m_EditRoleNameWindow._y = 100;
		m_EditRoleNameWindow.tweenTo(1.2,{_alpha:100, _y:90},Strong.easeOut);

		m_EditRoleNameWindow.SignalCancel.Connect(CloseEditRoleNameWindow, this);
		m_EditRoleNameWindow.SignalEditName.Connect(SlotChangeRoleName, this);
		
		m_RolePermissionsNameButton.CloseTooltip();
	}

	private function CloseEditRoleNameWindow()
	{
		DisableAllComponents(false);
		//Keep this component disabled until the window has faded out completely!
		m_RolePermissionsNameButton.disabled = true;
		
		var tempIndex:Number = m_RoleDropdown.selectedIndex;
		m_RoleButton.selected = true;
		m_RoleDropdown.selectedIndex = tempIndex;
		m_PermissionsScrollingList.dataProvider = m_Permissions[m_RoleDropdown.selectedIndex];
		m_PopupOverlay.tweenTo(1.2,{_alpha:0},Strong.easeOut);
		m_EditRoleNameWindow.tweenTo(1,{_alpha:0, _y:100},Strong.easeOut);

		m_EditRoleNameWindow.onTweenComplete = Delegate.create(this, SlotRemoveEditRoleNameWindow);
	}

	private function SlotRemoveEditRoleNameWindow()
	{
		m_RolePermissionsNameButton.disabled = false;
		m_EditRoleNameWindow.removeMovieClip();
		m_PopupOverlay.removeMovieClip();
	}

	private function DisableAllComponents(disable:Boolean)
	{
		var alphaVal:Number = 100;
		if (disable)
		{
			alphaVal = 50;
		}
		_parent._parent._parent.m_LeaveButton.disabled = disable;
		_parent._parent._parent.m_LeaveButton._alpha = alphaVal;
		m_KickButtton.disabled = disable;
		m_KickButtton._alpha = alphaVal;
		m_DemoteButton.disabled = disable;
		m_DemoteButton._alpha = alphaVal;
		m_PromoteButton.disabled = disable;
		m_PromoteButton._alpha = alphaVal;
		m_GovernmentTypeDropdown.disabled = disable;
		m_GovernmentTypeDropdown._alpha = alphaVal;
		m_PermissionsButton.disabled = disable;
		m_PermissionsButton._alpha = alphaVal;
		m_RoleButton.disabled = disable;
		m_RoleButton._alpha = alphaVal;
		m_RolePermissionsNameButton.disabled = disable;
		m_RolePermissionsNameButton._alpha = alphaVal;
		m_RoleDropdown.disabled = disable;
		m_RoleDropdown._alpha = alphaVal;
		m_PermissionsDropdown.disabled = disable;
		m_PermissionsDropdown._alpha = alphaVal;
		m_ResetButton.disabled = disable;
		m_ResetButton._alpha = alphaVal;
		m_ApplyButton.disabled = disable;
		m_ApplyButton._alpha = alphaVal;
		m_PermissionsScrollingList.disabled = disable;
		m_PermissionsScrollingList._alpha = alphaVal;
		m_MembersScrollingList.disabled = disable;
		m_MembersScrollingList._alpha = alphaVal;
		m_Header1.disabled = disable;
		m_Header1._alpha = alphaVal;
		m_Header2.disabled = disable;
		m_Header2._alpha = alphaVal;
		m_Header3.disabled = disable;
		m_Header3._alpha = alphaVal;
		m_Header4.disabled = disable;
		m_Header4._alpha = alphaVal;
		m_MembersSearchBox.disabled = disable;
		m_MembersSearchBox._alpha = alphaVal;
		_parent._parent._parent.m_ButtonBar.disabled = disable;
	}

	function PermissionClicked(event:Object)
	{
		m_PermissionsScrollingList.dataProvider = m_Roles[m_PermissionsDropdown.selectedIndex];
	}

	function RoleClicked(event:Object)
	{
		m_PermissionsScrollingList.dataProvider = m_Permissions[m_RoleDropdown.selectedIndex];
	}
}