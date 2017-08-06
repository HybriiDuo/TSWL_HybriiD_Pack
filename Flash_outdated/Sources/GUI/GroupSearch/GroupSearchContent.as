//Imports
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;
import com.Components.MultiColumnListView;
import com.Components.WindowComponentContent;
import com.Components.RightClickItem;
import com.GameInterface.CharacterLFG;
import com.GameInterface.Friends;
import com.GameInterface.LookingForGroup;
import com.GameInterface.Playfield;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Game.Team;
import com.GameInterface.Game.Raid;
import com.GameInterface.Utils;
import com.Utils.Archive;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.GroupSearch.GroupSearchPromptWindow;
import GUI.GroupSearch.GroupSearchFiltersWindow;
import gfx.controls.Button;
import gfx.controls.ScrollBar;

//Class
class GUI.GroupSearch.GroupSearchContent extends WindowComponentContent
{
    //Constants
	private static var ARCHIVE_CONTENT_WIDTH:String = "archiveContentWidth";
	private static var ARCHIVE_CONTENT_HEIGHT:String = "archiveContentHeight";
	private static var ARCHIVE_COLUMN_PLAYER_WIDTH:String = "archiveLFGColumnPlayerWidth";
	private static var ARCHIVE_COLUMN_ROLE_WIDTH:String = "archiveLFGColumnRoleWidth";
	private static var ARCHIVE_COLUMN_ACTIVITY_WIDTH:String = "archiveLFGColumnActivityWidth";
	private static var ARCHIVE_COLUMN_LOCATION_WIDTH:String = "archiveLFGColumnLocationWidth";
	private static var ARCHIVE_COLUMN_DIFFICULTY_WIDTH:String = "archiveLFGColumnDifficultyWidth";
	private static var ARCHIVE_COLUMN_COMMENT_WIDTH:String = "archiveLFGColumnCommentWidth";
    private static var ARCHIVE_SELECTED_ROLES:String = "archiveLFGSelectedRoles";    
	private static var ARCHIVE_SELECTED_ACTIVITY:String = "archiveLFGSelectedActivity";
	private static var ARCHIVE_SELECTED_LOCATION:String = "archiveLFGSelectedLocation";
	private static var ARCHIVE_SELECTED_DIFFICULTY:String = "archiveLFGSelectedDifficulty";
	private static var ARCHIVE_COMMENT:String = "archiveLFGComment";
	private static var ARCHIVE_SELECTED_FILTERS:String = "archiveLFGSelectedFilters"; 
	private static var ARCHIVE_SELECTED_DIFFICULTY_FILTERS:String = "archiveLFGSelectedDifficultyFilters";  
    
    private static var VIEW:String = LDBFormat.LDBGetText("GroupSearchGUI", "view");
    private static var SIGN_UP:String = LDBFormat.LDBGetText("GroupSearchGUI", "signUp");
    private static var LEAVE:String = LDBFormat.LDBGetText("GroupSearchGUI", "leave");
	private static var FILTERS:String = LDBFormat.LDBGetText("GroupSearchGUI", "Filters");
	private static var REFRESH:String = LDBFormat.LDBGetText("GroupSearchGUI", "refresh");
    private static var GM_FIFO_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "gmFifoMessage");
    
	private static var SELECTED_FILTERS:String = LDBFormat.LDBGetText("GroupSearchGUI", "SelectedFilters");
	private static var NO_FILTERS:String = LDBFormat.LDBGetText("GroupSearchGUI", "FiltersNone");
    private static var COLUMN_PLAYER_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "columnPlayerTitle");
	private static var COLUMN_ROLE_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ColumnRoleTitle");
	private static var COLUMN_ACTIVITY_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ColumnActivityTitle");	
	private static var COLUMN_LOCATION_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ColumnLocationTitle");
	private static var COLUMN_DIFFICULTY_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ColumnDifficultyTitle");	
	private static var COLUMN_COMMENT_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ColumnCommentTitle");	
    
    private static var QUEUE_INFORMATION:String = LDBFormat.LDBGetText("GroupSearchGUI", "queueInfo");
    
    private static var INVITE_TO_GROUP:String = LDBFormat.LDBGetText("GroupSearchGUI", "inviteToGroup");
    private static var SEND_A_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "sendAMessage");
	private static var VIEW_ENTRY:String = LDBFormat.LDBGetText("GroupSearchGUI", "ViewEntry");
	private static var MEET_UP:String = LDBFormat.LDBGetText("FriendsGUI", "meetUpMenuItem");
    
    private static var COLUMN_NAME_ID:Number = 0;
    private static var COLUMN_ROLE_ID:Number = 1;
	private static var COLUMN_ACTIVITY_ID:Number = 2;
	private static var COLUMN_LOCATION_ID:Number = 3;
	private static var COLUMN_DIFFICULTY_ID:Number = 4;
	private static var COLUMN_COMMENT_ID:Number = 5;
    private static var LEFT_CLICK_INDEX:Number = 1;
    private static var RIGHT_CLICK_INDEX:Number = 2;
    private static var RIGHT_CLICK_MOUSE_OFFSET:Number = 5;
	    
    //Properties    
    private var m_LFGInterface:LookingForGroup;
    
    private var m_RefreshEnableInterval:Number;
    
	private var m_TopDivider:MovieClip;
    private var m_ListTitleHeader:MovieClip;
    private var m_List:MultiColumnListView;
    private var m_ListScrollBar:ScrollBar;
    private var m_GroupArray:Array;
    
    private var m_QueueInfo:MovieClip;
    private var m_SignUpLeaveButton:Button;
	private var m_FiltersButton:Button;
	private var m_RefreshButton:Button;
    private var m_PromptWindow:MovieClip;
	private var m_FiltersWindow:MovieClip;
    private var m_RightClickMenu:MovieClip;
    
    private var m_Character:Character;
    private var m_SelectedCharacterName:String;
    private var m_SelectedCharacterID:ID32;
	private var m_SelectedIndex:Number;
    
    private var m_MessageWindow:MovieClip;
    
    private var m_PersistentSelectedRoles:Array;
	private var m_PersistentFilters:Array;
	private var m_PersistentDifficultyFilters:Array;
	private var m_PersistentActivity:Number;
	private var m_PersistentLocation:Number;
	private var m_PersistentDifficulty:Number;
	private var m_PersistentComment:String;
	private var m_PersistentWidth:Number;
	private var m_PersistentHeight:Number;
	
	private var m_Team:Team;
	private var m_Raid:Raid;
    
    //Constructor
    public function GroupSearchContent()
    {
        super();
        
        m_LFGInterface = new LookingForGroup();
        m_Character = Character.GetClientCharacter();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();        
        m_LFGInterface.SignalSearchResult.Connect(SlotUpdateList, this);
		LookingForGroup.SignalClientLeftLFG.Connect(SlotClientLeftLFG, this);
		LookingForGroup.SignalClientJoinedLFG.Connect(SlotClientJoinedLFG, this);
        
        TeamInterface.SignalClientJoinedTeam.Connect(SlotJoinTeam, this);
        TeamInterface.SignalClientLeftTeam.Connect(SlotLeftTeam, this);
		TeamInterface.SignalClientJoinedRaid.Connect(SlotJoinRaid, this);
    	TeamInterface.SignalClientLeftRaid.Connect(SlotLeftRaid, this);
		TeamInterface.RequestTeamInformation();
        
        m_List.SetItemRenderer("ItemRenderer");
        m_List.SetHeaderSpacing(3);
        m_List.SetShowBottomLine(true);
        m_List.SetScrollBar(m_ListScrollBar);
        m_List.AddColumn(COLUMN_NAME_ID, COLUMN_PLAYER_TITLE, 100, 0);
        m_List.AddColumn(COLUMN_ROLE_ID, COLUMN_ROLE_TITLE, 100, 0);
		m_List.AddColumn(COLUMN_ACTIVITY_ID, COLUMN_ACTIVITY_TITLE, 100, 0);
		m_List.AddColumn(COLUMN_LOCATION_ID, COLUMN_LOCATION_TITLE, 100, 0);
		m_List.AddColumn(COLUMN_DIFFICULTY_ID, COLUMN_DIFFICULTY_TITLE, 100, 0);
		m_List.AddColumn(COLUMN_COMMENT_ID, COLUMN_COMMENT_TITLE, 188, 0);
        m_List.SetSize(688, 400);
        m_List.SignalItemClicked.Connect(SlotItemClicked, this);
        m_List.SignalMovieClipAdded.Connect(SlotMovieClipAdded, this);
        m_List.SetSecondarySortColumn(COLUMN_NAME_ID);
                
        m_PromptWindow = attachMovie("GroupSearchPromptWindow", "m_PromptWindow", getNextHighestDepth());
        m_PromptWindow.SignalPromptResponse.Connect(SlotPromptResponse, this);
		
		m_FiltersWindow = attachMovie("GroupSearchFiltersWindow", "m_FiltersWindow", getNextHighestDepth());
        m_FiltersWindow.SignalFiltersChanged.Connect(SlotFiltersChanged, this);
        
        m_QueueInfo.m_Title.textColor = 0x00FF00;
                
        m_MessageWindow = attachMovie("MessageWindow", "m_MessageWindow", getNextHighestDepth());
        
        var signUpLeaveButtonLabel:String = (LookingForGroup.HasCharacterSignedUp()) ? LEAVE : SIGN_UP;
        var signUpLeaveButtonSelected:Boolean = (LookingForGroup.HasCharacterSignedUp()) ? true : false;
        
        UpdateQueueInformation();
        
        SetupButton(m_SignUpLeaveButton, true, signUpLeaveButtonLabel, signUpLeaveButtonSelected);
		SetupButton(m_FiltersButton, false, FILTERS, false);
		SetupButton(m_RefreshButton, false, REFRESH, false);
        
        CreateRightClickMenu();
        
        ToggleDisableControls(false);
        Selection.setFocus(null);
    }
	
	public function SetSize(newWidth:Number, newHeight:Number)
	{
		m_TopDivider._width = newWidth;
		m_ListTitleHeader.m_Background._width = newWidth;
		m_ListTitleHeader.m_Title._width = newWidth - (m_ListeTitleHeader.m_Title._x * 2);
		
		m_QueueInfo.m_Background._width = newWidth;
		m_QueueInfo.m_Title._width = newWidth - (m_QueueInfo.m_Title._x * 2);
		m_QueueInfo._y = newHeight - m_QueueInfo._height - m_SignUpLeaveButton._height - 20;
		m_SignUpLeaveButton._x = newWidth - m_SignUpLeaveButton._width;
		m_SignUpLeaveButton._y = m_FiltersButton._y = m_RefreshButton._y = newHeight - m_SignUpLeaveButton._height;
		
		m_ListScrollBar._x = newWidth - m_ListScrollBar._width - 4;
		m_List.SetSize(newWidth - m_ListScrollBar._width, newHeight - m_List._y - (newHeight - m_QueueInfo._y));
		
		m_PersistentWidth = newWidth;
		m_PersistentHeight = newHeight;
	}
	
	//Slot Filters Changed
	private function SlotFiltersChanged(changed:Boolean, filter:Array, difficultyFilter:Array)
	{
		if (changed)
		{
			m_PersistentFilters = filter;
			m_PersistentDifficultyFilters = difficultyFilter;
		}
		ToggleDisableControls(false);
		UpdateListHeaderTitleAndSearch();
	}
    
    //Slot Prompt Response
    private function SlotPromptResponse(mode:String, selectedRolesArray:Array, selectedActivity:Number, selectedLocation:Number, selectedDifficulty:Number, comment:String, maxTeamSize:Number, signOut:Boolean):Void
    {
        switch (mode)
        {
            case GroupSearchPromptWindow.MODE_SELECT_ROLE:      if (signOut)
                                                                {
                                                                    m_SignUpLeaveButton.label = SIGN_UP;
                                                                    m_SignUpLeaveButton.selected = false;
                                                                }
                                                                else
                                                                {
																	if (maxTeamSize == 0 || maxTeamSize > GetTeamMemberCount())
																	{
																		var isEdit = LookingForGroup.HasCharacterSignedUp();
																		m_LFGInterface.SignUp(selectedDifficulty, [selectedActivity], selectedLocation, selectedRolesArray, comment, maxTeamSize);
																																			
																		if (m_Character.GetStat(_global.Enums.Stat.e_GmLevel) != 0)
																		{
																			com.GameInterface.Chat.SignalShowFIFOMessage.Emit(GM_FIFO_MESSAGE, 0);
																		}
																		if (isEdit)
																		{
																			//Since we didn't actually join, we wont get an update
																			//we need to trigger one ourselves!
																			SlotClientJoinedLFG();
																		}
																	}
																	else
																	{
																		var fifo:String = LDBFormat.Printf(LDBFormat.LDBGetText("GroupSearchGUI", "maxTeamFifoMessage"), GetActivityString(selectedActivity))
																		com.GameInterface.Chat.SignalShowFIFOMessage.Emit(fifo, 0);
																	}
                                                                }
																m_PersistentActivity = selectedActivity;
																m_PersistentLocation = selectedLocation;
																m_PersistentDifficulty = selectedDifficulty;
                                                                m_PersistentSelectedRoles = selectedRolesArray;  
																m_PersistentComment = comment;
                                                                break;
                                                                
            case GroupSearchPromptWindow.MODE_CONFIRM_LEAVE:    if (signOut)
                                                                {     
                                                                    SignOut();                                                                 
                                                                    UpdateQueueInformation();
                                                                }
                                                                else
                                                                {
                                                                    m_SignUpLeaveButton.label = LEAVE;
                                                                    m_SignUpLeaveButton.selected = true;
                                                                }
                                                                
        }

        ToggleDisableControls(false);
    }

    //Setup Button
    private function SetupButton(target:Button, toggle:Boolean, label:String, selected:Boolean):Void
    {
        target.addEventListener((toggle) ? "select" : "click", this, "ButtonSelectHandler");
        target.disableFocus = true;
        target.toggle = toggle;
        target.label = label;
        target.selected = selected;
    }
    
    //Button Select Handler
    private function ButtonSelectHandler(event:Object):Void
    {
        if (!event.target.disabled)
        {
            switch (event.target)
            {                                            
                case m_SignUpLeaveButton:   if (LookingForGroup.HasCharacterSignedUp())
                                            {
                                                var characterSignedData:CharacterLFG = LookingForGroup.GetPlayerSignedUpData();
                                                m_PromptWindow.ShowPrompt   (
                                                                            GroupSearchPromptWindow.MODE_CONFIRM_LEAVE,
                                                                            characterSignedData.m_Playfields[0],
																			characterSignedData.m_Location,
                                                                            characterSignedData.m_Mode,
																			characterSignedData.m_Comment,
																			characterSignedData.HasRole(_global.Enums.Class.e_Tank),
																			characterSignedData.HasRole(_global.Enums.Class.e_Damage),
																			characterSignedData.HasRole(_global.Enums.Class.e_Heal)
                                                                            );
                                                                            
                                                ToggleDisableControls(true);
                                            }
                                            else
                                            {
												var setTank:Boolean = false;
												var setDamage:Boolean = false;
												var setHeal:Boolean = false;
												for (var i:Number=0; i<m_PersistentSelectedRoles.length; i++)
												{
													if (m_PersistentSelectedRoles[i] == _global.Enums.Class.e_Tank) { setTank = true; }
													if (m_PersistentSelectedRoles[i] == _global.Enums.Class.e_Damage) { setDamage = true; }
													if (m_PersistentSelectedRoles[i] == _global.Enums.Class.e_Heal) { setHeal = true; }
												}
                                                m_PromptWindow.ShowPrompt(
																		  GroupSearchPromptWindow.MODE_SELECT_ROLE,
																		  m_PersistentActivity,
																		  m_PersistentLocation,
																		  m_PersistentDifficulty,
																		  m_PersistentComment,
																		  setTank,
																		  setDamage,
																		  setHeal
																		  );
                                                ToggleDisableControls(true);
                                            }
											break;
											
				case m_FiltersButton:		m_FiltersWindow.ShowPrompt(m_PersistentFilters, m_PersistentDifficultyFilters);
											ToggleDisableControls(true);
											break;
											
				case m_RefreshButton:
											UpdateListHeaderTitleAndSearch();
											m_RefreshButton.disabled = true;
											trace("DISABLE REFRESH");
											m_RefreshEnableInterval = setInterval(this, "EnableRefresh", 3000);
            }
        }
    }
	
	private function EnableRefresh():Void
	{
		trace("ENABLE REFRESH");
		m_RefreshButton.disabled = false;
		clearInterval(m_RefreshEnableInterval);
		m_RefreshEnableInterval = undefined;
	}
	
	private function SlotClientLeftLFG():Void
	{
		//We have to disable the sign up button to prevent it from triggering a prompt on state change
		m_SignUpLeaveButton.disabled = true;
		m_SignUpLeaveButton.selected = false;
        m_SignUpLeaveButton.label = SIGN_UP;
		UpdateQueueInformation();
		UpdateListHeaderTitleAndSearch();
		m_SignUpLeaveButton.disabled = false;
	}
	
	private function SlotClientJoinedLFG():Void
	{
		m_SignUpLeaveButton.disabled = true;
		m_SignUpLeaveButton.selected = true;
		m_SignUpLeaveButton.label = LEAVE;
		m_SignUpLeaveButton.disabled = false;
		UpdateQueueInformation();	
		UpdateListHeaderTitleAndSearch();
	}
    
    //Sign Out
    private function SignOut():Void
    {
        m_SignUpLeaveButton.selected = false;
        m_SignUpLeaveButton.label = SIGN_UP;

        m_LFGInterface.SignOff();        
    }
    
    //Update List Header Title And Search
    private function UpdateListHeaderTitleAndSearch():Void
    {        
        m_ListTitleHeader.m_Title.text = SELECTED_FILTERS + " " + GetFilterString();
        
        m_LFGInterface.DoSearch( m_PersistentDifficultyFilters, 
                                 m_PersistentFilters, 
                                 [_global.Enums.Class.e_Tank, _global.Enums.Class.e_Damage, _global.Enums.Class.e_Heal], 
                                 true, 0);
    }
	
	private function GetFilterString():String
	{
		if ((m_PersistentFilters.length == 0 && m_PersistentDifficultyFilters.length == 0) || 
			(m_PersistentFilters.length == GroupSearchFiltersWindow.PVP + 1 && m_PersistentDifficultyFilters.length == GroupSearchFiltersWindow.NIGHTMARE))
		{
			return NO_FILTERS;
		}
		
		var filterString:String = "";
		for (var i:Number=0; i<m_PersistentFilters.length; i++)
		{
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.SOCIAL){ filterString += GroupSearchFiltersWindow.TDB_SOCIAL; }
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.TRADE){ filterString += GroupSearchFiltersWindow.TDB_TRADE; }
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.CABAL){ filterString += GroupSearchFiltersWindow.TDB_CABAL; }
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.MISSION){ filterString += GroupSearchFiltersWindow.TDB_MISSION; }
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.DUNGEON){ filterString += GroupSearchFiltersWindow.TDB_DUNGEON; }
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.RAID){ filterString += GroupSearchFiltersWindow.TDB_RAID; }
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.SCENARIO){ filterString += GroupSearchFiltersWindow.TDB_SCENARIO; }
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.LAIR){ filterString += GroupSearchFiltersWindow.TDB_LAIR; }
			if (m_PersistentFilters[i] == GroupSearchFiltersWindow.PVP){ filterString += GroupSearchFiltersWindow.TDB_PVP; }
			if (i != m_PersistentFilters.length - 1 || m_PersistentDifficultyFilters.length > 0)
			{
				filterString += ", ";
			}
		}
		for (var i:Number=0; i<m_PersistentDifficultyFilters.length; i++)
		{
			if (m_PersistentDifficultyFilters[i] == GroupSearchFiltersWindow.NORMAL){ filterString += GroupSearchFiltersWindow.TDB_NORMAL; }
			if (m_PersistentDifficultyFilters[i] == GroupSearchFiltersWindow.ELITE){ filterString += GroupSearchFiltersWindow.TDB_ELITE; }
			if (m_PersistentDifficultyFilters[i] == GroupSearchFiltersWindow.NIGHTMARE){ filterString += GroupSearchFiltersWindow.TDB_NIGHTMARE; }
			if (i != m_PersistentDifficultyFilters.length - 1)
			{
				filterString += ", ";
			}
		}
		return filterString;
	}
    
    //Update Queue Information
    private function UpdateQueueInformation():Void
    {
		if ( LookingForGroup.HasCharacterSignedUp() )
        {
			var characterSignedData:CharacterLFG = LookingForGroup.GetPlayerSignedUpData();
			var signedActivity:String = GetCharacterActivityString(characterSignedData);
			var signedDifficulty:String = GetCharacterDifficultyString(characterSignedData);
			m_QueueInfo.m_Title.text = LDBFormat.Printf(QUEUE_INFORMATION, signedActivity, signedDifficulty);
		}
		else
		{
			m_QueueInfo.m_Title.text = "";
		}
    }
	
	private function GetCharacterActivityString(characterLFG:CharacterLFG)
	{
		var signedActivityNum:Number = characterLFG.m_Playfields[0];
		return GetActivityString(signedActivityNum);
	}
	
	private function GetActivityString(signedActivityNum:Number)
	{
		if (signedActivityNum == GroupSearchFiltersWindow.SOCIAL){ return GroupSearchFiltersWindow.TDB_SOCIAL; }
		if (signedActivityNum == GroupSearchFiltersWindow.TRADE){ return GroupSearchFiltersWindow.TDB_TRADE; }
		if (signedActivityNum == GroupSearchFiltersWindow.CABAL){ return GroupSearchFiltersWindow.TDB_CABAL; }
		if (signedActivityNum == GroupSearchFiltersWindow.MISSION){ return GroupSearchFiltersWindow.TDB_MISSION; }
		if (signedActivityNum == GroupSearchFiltersWindow.DUNGEON){ return GroupSearchFiltersWindow.TDB_DUNGEON; }
		if (signedActivityNum == GroupSearchFiltersWindow.RAID){ return GroupSearchFiltersWindow.TDB_RAID; }
		if (signedActivityNum == GroupSearchFiltersWindow.SCENARIO){ return GroupSearchFiltersWindow.TDB_SCENARIO; }
		if (signedActivityNum == GroupSearchFiltersWindow.LAIR){ return GroupSearchFiltersWindow.TDB_LAIR; }
		if (signedActivityNum == GroupSearchFiltersWindow.PVP){ return GroupSearchFiltersWindow.TDB_PVP; }
		return GroupSearchFiltersWindow.TDB_SOCIAL; //Default to social if we don't find anything
	}
	
	private function GetCharacterDifficultyString(characterLFG:CharacterLFG)
	{
		var signedDifficultyNum:Number = characterLFG.m_Mode;
		return GetDifficultyString(signedDifficultyNum);
	}
	
	private function GetDifficultyString(signedDifficultyNum:Number)
	{
		if (signedDifficultyNum == GroupSearchFiltersWindow.ANY){ return GroupSearchFiltersWindow.TDB_ANY; }
		if (signedDifficultyNum == GroupSearchFiltersWindow.NORMAL){ return GroupSearchFiltersWindow.TDB_NORMAL; }
		if (signedDifficultyNum == GroupSearchFiltersWindow.ELITE){ return GroupSearchFiltersWindow.TDB_ELITE; }
		if (signedDifficultyNum == GroupSearchFiltersWindow.NIGHTMARE){ return GroupSearchFiltersWindow.TDB_NIGHTMARE; }
		return GroupSearchFiltersWindow.TDB_ANY; //Default to Any if we don't find anything
	}
    
    private function SlotJoinTeam(team:Team):Void
    {
        m_Team = team;
    }
    
    private function SlotLeftTeam():Void
    {
        m_Team = undefined;
    }
	
	private function SlotJoinRaid(raid:Raid):Void
	{
		m_Raid = raid;
	}
	
	private function SlotLeftRaid():Void
	{
		m_Raid = undefined;
	}
	
	private function GetTeamMemberCount():Number
	{
		if (m_Team == undefined)
		{
			return 0;
		}
		var numMembers:Number = 0;
		if (m_Raid == undefined)
		{
			for (teamMember in m_Team.m_TeamMembers)
			{
				numMembers++;
			}
			return numMembers;
		}
		for (team in m_Raid.m_Teams)
		{
			for (teamMember in m_Raid.m_Teams[team].m_TeamMembers)
			{
				numMembers++;
			}
		}
		return numMembers;
	}
    
    //Slot Update List
    private function SlotUpdateList():Void
    {       
        m_GroupArray = new Array();
        
        m_List.RemoveAllItems();

		//TODO: This is probably way more complicated than it needs to be
        var characterSignedData:CharacterLFG = LookingForGroup.GetPlayerSignedUpData();
        if (LookingForGroup.HasCharacterSignedUp())
        {
            var shouldIncludePlayer:Boolean = false;
            if (m_PersistentFilters.length == 0 && m_PersistentDifficultyFilters.length == 0)
			{
				shouldIncludePlayer = true;
			}
			else
			{
				if (m_PersistentFilters.length == 0)
				{
					for (var i:Number=0; i < m_PersistentDifficultyFilters.length; ++i)
					{
						if (m_PersistentDifficultyFilters[i] == characterSignedData.m_Mode ||
							characterSignedData.m_Mode == GroupSearchFiltersWindow.ANY)
						{
							shouldIncludePlayer = true;
							break;
						}
					}
				}
				else
				{
					//Check all playfields the player is signed up for
					for (var i:Number = 0; i < characterSignedData.m_Playfields.length && !shouldIncludePlayer; ++i)
					{
						//Against all filters
						for ( var j:Number = 0; j < m_PersistentFilters.length; ++j )
						{
							//If the player is signed up and the filter is on
							if (characterSignedData.m_Playfields[i] == m_PersistentFilters[j])
							{
								//Check the difficulties
								if (m_PersistentDifficultyFilters.length == 0 ||
									characterSignedData.m_Mode == GroupSearchFiltersWindow.ANY)
								{
									shouldIncludePlayer = true;
								}
								else
								{
									for (var k:Number=0; k < m_PersistentDifficultyFilters.length; ++k)
									{
										if (m_PersistentDifficultyFilters[k] == characterSignedData.m_Mode)
										{
											shouldIncludePlayer = true;
											break;
										}
									}
								}
								break;
							}
						}
					}
				}
			}
            
            //Add player's character to the list
            if (shouldIncludePlayer)
            {
                var characterLFG:CharacterLFG = new CharacterLFG();

                characterLFG.m_Name = m_Character.GetName();
                characterLFG.m_FirstName = m_Character.GetFirstName();
                characterLFG.m_LastName =  m_Character.GetLastName();
                characterLFG.m_FactionRank = m_Character.GetStat( _global.Enums.Stat.e_RankTag );
                characterLFG.m_Id = m_Character.GetID();
                characterLFG.m_Role = characterSignedData.m_Role;
                characterLFG.m_Playfields = characterSignedData.m_Playfields;
				characterLFG.m_Location = characterSignedData.m_Location;
                characterLFG.m_Mode = characterSignedData.m_Mode;
				characterLFG.m_Comment = characterSignedData.m_Comment;
                
                AddCharacterToList(characterLFG);
            }
        }
        
		
        for (var i:Number = 0; i < m_LFGInterface.m_CharactersLookingForGroup.length; ++i) 
        {
            AddCharacterToList(m_LFGInterface.m_CharactersLookingForGroup[i]);
        }
        
        m_List.AddItems(m_GroupArray); 
		EnableRefresh();
    }
    
    //Add Character To List
    private function AddCharacterToList(characterLFG:CharacterLFG):Void
    {
        var charItem:MCLItemDefault = new MCLItemDefault(characterLFG);
        
        var nameValueData:MCLItemValueData = new MCLItemValueData();
        nameValueData.m_Text = characterLFG.m_Name;
        if ( !characterLFG.m_Id.Equal(m_Character.GetID()) )
        {
            nameValueData.m_MovieClipName = "RightClickButton";
        }
        else
        {
            nameValueData.m_MovieClipName = "EmptyClickButton";
        }
        charItem.SetValue(COLUMN_NAME_ID, nameValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
        
        var untieIconSortValue:Number = 0; //For icon sorting
        var roleValueData:MCLItemValueData = new MCLItemValueData();
		var roleClips:Array = new Array();
		if (characterLFG.HasRole(_global.Enums.Class.e_Tank))
        {
			roleClips.push("TankIconEnabled");
			untieIconSortValue += 25;
		}
		if (characterLFG.HasRole(_global.Enums.Class.e_Heal))
        {
			roleClips.push("HealerIconEnabled");
			untieIconSortValue += 25;
		}
		if (characterLFG.HasRole(_global.Enums.Class.e_Damage))
        {
			roleClips.push("DPSIconEnabled");
			untieIconSortValue += 25;
		}
		roleValueData.m_MovieClips = roleClips;
		roleValueData.m_Number = untieIconSortValue;
		charItem.SetValue(COLUMN_ROLE_ID, roleValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_SYMBOL);
		
		var activityValueData:MCLItemValueData = new MCLItemValueData();
		activityValueData.m_Text = GetCharacterActivityString(characterLFG);
		activityValueData.m_TextAlignment = "left";
		charItem.SetValue(COLUMN_ACTIVITY_ID, activityValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
		
		var locationValueData:MCLItemValueData = new MCLItemValueData();
		var locationFetch:String = "Activity_"+characterLFG.m_Playfields[0]+"_Location_"+characterLFG.m_Location;
		locationValueData.m_Text = LDBFormat.LDBGetText("GroupSearchGUI", locationFetch);
		locationValueData.m_TextAlignment = "left";
		charItem.SetValue(COLUMN_LOCATION_ID, locationValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
		
		var difficultyValueData:MCLItemValueData = new MCLItemValueData();
		difficultyValueData.m_Text = GetCharacterDifficultyString(characterLFG);
		difficultyValueData.m_TextAlignment = "left";
		charItem.SetValue(COLUMN_DIFFICULTY_ID, difficultyValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
		
		var commentValueData:MCLItemValueData = new MCLItemValueData();
		commentValueData.m_Text = characterLFG.m_Comment;
		commentValueData.m_TextAlignment = "left";
		charItem.SetValue(COLUMN_COMMENT_ID, commentValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
		
		m_GroupArray.push(charItem);
    }
    
    //Toggle Disable Controls
    private function ToggleDisableControls(disable:Boolean):Void
    {
        var clientId:ID32 = Character.GetClientCharID();
        m_SignUpLeaveButton.disabled = /*TeamInterface.IsInTeam(clientId) ||*/ disable;
		m_FiltersButton.disabled = disable;
		m_RefreshButton.disabled = disable;
    }
    
    //Create Right Click Menu
    private function CreateRightClickMenu():Void
    {
        m_RightClickMenu = attachMovie("RightClickMenu", "m_RightClickMenu", getNextHighestDepth());
        m_RightClickMenu.width = 250;
        m_RightClickMenu.SetHandleClose(false);
        m_RightClickMenu.SignalWantToClose.Connect(HideRightClickMenu, this);
    }
    
    //Hide Right Click Menu
    private function HideRightClickMenu():Void
    {
        if (m_RightClickMenu)
        {
            m_RightClickMenu.Hide();
        }
    }
    
    //Slot Item Clicked
    private function SlotItemClicked(index:Number, buttonIndex:Number):Void
    {
        var characterLFG:CharacterLFG = m_List.GetItems()[index].GetId();
		m_SelectedIndex = index;

        var fullName:String = characterLFG.m_FirstName + " '"+ characterLFG.m_Name +"' " + characterLFG.m_LastName;
        RowSelected (
                    buttonIndex,
                    fullName,
                    characterLFG.m_Name,
                    characterLFG.m_Id
                    );
    }
    
    //Slot Movie Clip Added
    private function SlotMovieClipAdded(itemIndex:Number, columnId:Number, movieClip:MovieClip):Void
    {        
        if (columnId == COLUMN_NAME_ID)
        {
            movieClip.hitTestDisable = false;
            movieClip.m_Index = itemIndex;
            movieClip.m_Ref = this;
            movieClip.onPress = function() { this.m_Ref.SlotItemClicked(this.m_Index, 2); }
        }
    }
    
    //Row Selected
    private function RowSelected(buttonIndex:Number, characterFullName:String, characterName:String, characterID:ID32):Void
    {
        if (!Character.GetClientCharID().Equal(characterID))
        {            
            if (buttonIndex == RIGHT_CLICK_INDEX)
            {
				var dataProvider:Array = new Array();
            
				dataProvider.push(new RightClickItem(characterFullName, true, RightClickItem.LEFT_ALIGN));
				dataProvider.push(RightClickItem.MakeSeparator());
				
				var viewEntryItem = new RightClickItem(VIEW_ENTRY, false, RightClickItem.LEFT_ALIGN);
				viewEntryItem.SignalItemClicked.Connect(ViewEntryEventHandler, this);
				dataProvider.push(viewEntryItem);
				
				var inviteToGroupItem = new RightClickItem(INVITE_TO_GROUP, false, RightClickItem.LEFT_ALIGN);
				inviteToGroupItem.SignalItemClicked.Connect(InviteToGroupEventHandler, this);
				dataProvider.push(inviteToGroupItem);
					
				var sendMessageItem = new RightClickItem(SEND_A_MESSAGE, false, RightClickItem.LEFT_ALIGN);
				sendMessageItem.SignalItemClicked.Connect(SendMessageEventHandler, this);
				dataProvider.push(sendMessageItem);
				
				var meetUpItem = new RightClickItem(MEET_UP, false, RightClickItem.LEFT_ALIGN);
				meetUpItem.SignalItemClicked.Connect(MeetUpEventHandler, this);
				dataProvider.push(meetUpItem);
	
				m_RightClickMenu.dataProvider = dataProvider;
	
				m_SelectedCharacterName = characterName;
				m_SelectedCharacterID = characterID;
				
                if (!m_RightClickMenu._visible)
                {
                    PositionRightClickMenu();
                    m_RightClickMenu.Show();
                }
                else 
                {
                    if (m_RightClickMenu.hitTest(_root._xmouse, _root._ymouse))
                    {
                        m_RightClickMenu.Hide();
                    }
                    else
                    {
                        PositionRightClickMenu();
                    }
                }
            }
        }
    }
    
    //Position Right Click Menu
    private function PositionRightClickMenu():Void
    {
        var visibleRect = Stage["visibleRect"];
        
        m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._xmouse + m_RightClickMenu._width - visibleRect.width);
        m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._ymouse + m_RightClickMenu._height - visibleRect.height);
    }
    
    //On Mouse Press
    private function onMousePress(buttonIndex:Number, clickCount:Number):Void
    {
        HideRightClickMenu();
    }

    //Invite To Group Event Handler
    private function InviteToGroupEventHandler():Void
    {
        Friends.InviteToGroup(m_SelectedCharacterID);
    }
    
    //Send Message Event Handler
    private function SendMessageEventHandler():Void
    {
        m_MessageWindow.ShowMessageWindow(m_SelectedCharacterName);
        Selection.setFocus(m_MessageWindow.m_InputText.textField);
    }
	
	//Send Message Event Handler
    private function MeetUpEventHandler():Void
    {
        Friends.MeetUp(m_SelectedCharacterID);
    }
	
	private function ViewEntryEventHandler():Void
	{
		var characterLFG:CharacterLFG = m_List.GetItems()[m_SelectedIndex].GetId();
		m_PromptWindow.ShowPrompt   (
									GroupSearchPromptWindow.MODE_VIEW,
									characterLFG.m_Playfields[0],
									characterLFG.m_Location,
									characterLFG.m_Mode,
									characterLFG.m_Comment,
									characterLFG.HasRole(_global.Enums.Class.e_Tank),
									characterLFG.HasRole(_global.Enums.Class.e_Damage),
									characterLFG.HasRole(_global.Enums.Class.e_Heal)
									);
	}
    
    //Set Content Persistence
    public function SetContentPersistence(persistence:Archive):Void
    {
        if (persistence == undefined)
        {
			//No persistence found! Need to set these default values
			m_PersistentWidth = this._width;
			m_PersistentHeight = this._height;
			m_PersistentSelectedRoles = new Array();
			m_PersistentActivity = 0;
			m_PersistentDifficulty = 0;
			m_PersistentLocation = 0;
			m_PersistentComment = "";
			m_PersistentFilters = [GroupSearchFiltersWindow.SOCIAL, GroupSearchFiltersWindow.TRADE,
								   GroupSearchFiltersWindow.CABAL, GroupSearchFiltersWindow.DUNGEON, 
								   GroupSearchFiltersWindow.RAID, GroupSearchFiltersWindow.SCENARIO, 
								   GroupSearchFiltersWindow.LAIR, GroupSearchFiltersWindow.MISSION,
								   GroupSearchFiltersWindow.PVP];
			m_PersistentDifficultyFilters = [GroupSearchFiltersWindow.NORMAL,GroupSearchFiltersWindow.ELITE, 
											 GroupSearchFiltersWindow.NIGHTMARE];
			
			UpdateListHeaderTitleAndSearch();
            return;
        }
		
		var contentWidth = persistence.FindEntry(ARCHIVE_CONTENT_WIDTH, 700);
		var contentHeight = persistence.FindEntry(ARCHIVE_CONTENT_HEIGHT, 525);
		SetSize(contentWidth, contentHeight);
        
        var playerWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_PLAYER_WIDTH, undefined);
        var roleWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_ROLE_WIDTH, undefined);
		var activityWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_ACTIVITY_WIDTH, undefined);
		var locationWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_LOCATION_WIDTH, undefined);
		var difficultyWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_DIFFICULTY_WIDTH, undefined);
        var commentWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_COMMENT_WIDTH, undefined);
        
        if(playerWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_NAME_ID, playerWidth);
        }
        if (roleWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_ROLE_ID, roleWidth);
        }
		if (activityWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_ACTIVITY_ID, activityWidth);
        }
		if (locationWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_LOCATION_ID, locationWidth);
        }
		if (locationWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_DIFFICULTY_ID, difficultyWidth);
        }
        if(commentWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_COMMENT_ID, commentWidth);
        }
        
        m_PersistentSelectedRoles = persistence.FindEntryArray(ARCHIVE_SELECTED_ROLES);
		if (m_PersistentSelectedRoles == undefined)
		{
			m_PersistentSelectedRoles = new Array();
		}
		m_PersistentActivity = persistence.FindEntry(ARCHIVE_SELECTED_ACTIVITY);
		if (m_PersistentActivity == undefined)
		{
			m_PersistentActivity = 0;
		}
		m_PersistentLocation = persistence.FindEntry(ARCHIVE_SELECTED_LOCATION);
		if (m_PersistentLocation == undefined)
		{
			m_PersistentLocation = 0;
		}
		m_PersistentDifficulty = persistence.FindEntry(ARCHIVE_SELECTED_DIFFICULTY);
		if (m_PersistentDifficulty == undefined)
		{
			m_PersistentDifficulty = 0;
		}
		m_PersistentComment = persistence.FindEntry(ARCHIVE_COMMENT);
		if (m_PersistentComment == undefined)
		{
			m_PersistentComment = "";
		}
		m_PersistentFilters = persistence.FindEntryArray(ARCHIVE_SELECTED_FILTERS);
		if (m_PersistentFilters == undefined)
		{
			m_PersistentFilters = [GroupSearchFiltersWindow.SOCIAL, GroupSearchFiltersWindow.TRADE,
								   GroupSearchFiltersWindow.CABAL, GroupSearchFiltersWindow.DUNGEON, 
								   GroupSearchFiltersWindow.RAID, GroupSearchFiltersWindow.SCENARIO, 
								   GroupSearchFiltersWindow.LAIR, GroupSearchFiltersWindow.MISSION,
								   GroupSearchFiltersWindow.PVP];
		}
		m_PersistentDifficultyFilters = persistence.FindEntryArray(ARCHIVE_SELECTED_DIFFICULTY_FILTERS);
		if (m_PersistentDifficultyFilters == undefined)
		{
			m_PersistentDifficultyFilters = [GroupSearchFiltersWindow.NORMAL, GroupSearchFiltersWindow.ELITE, 
											 GroupSearchFiltersWindow.NIGHTMARE];
		}		
		
		UpdateListHeaderTitleAndSearch();
    }
    
    //Get Content Persistence
    public function GetContentPersistence():Archive
    {
        var archive:Archive = new Archive();
		
		archive.AddEntry(ARCHIVE_CONTENT_WIDTH, m_PersistentWidth);
		archive.AddEntry(ARCHIVE_CONTENT_HEIGHT, m_PersistentHeight);
        
        archive.AddEntry(ARCHIVE_COLUMN_PLAYER_WIDTH, m_List.GetColumnWidth(COLUMN_NAME_ID));
        archive.AddEntry(ARCHIVE_COLUMN_ROLE_WIDTH, m_List.GetColumnWidth(COLUMN_ROLE_ID));
		archive.AddEntry(ARCHIVE_COLUMN_ACTIVITY_WIDTH, m_List.GetColumnWidth(COLUMN_ACTIVITY_ID));
		archive.AddEntry(ARCHIVE_COLUMN_LOCATION_WIDTH, m_List.GetColumnWidth(COLUMN_LOCATION_ID));
		archive.AddEntry(ARCHIVE_COLUMN_DIFFICULTY_WIDTH, m_List.GetColumnWidth(COLUMN_DIFFICULTY_ID));
        archive.AddEntry(ARCHIVE_COLUMN_COMMENT_WIDTH, m_List.GetColumnWidth(COLUMN_COMMENT_ID));
        
        for (var i:Number = 0; i < m_PersistentSelectedRoles.length; i++)
        {
            archive.AddEntry(ARCHIVE_SELECTED_ROLES, m_PersistentSelectedRoles[i]);
        }
		archive.AddEntry(ARCHIVE_SELECTED_ACTIVITY, m_PersistentActivity);
		archive.AddEntry(ARCHIVE_SELECTED_LOCATION, m_PersistentLocation);
		archive.AddEntry(ARCHIVE_SELECTED_DIFFICULTY, m_PersistentDifficulty);
		archive.AddEntry(ARCHIVE_COMMENT, m_PersistentComment);
		
		for (var i:Number = 0; i < m_PersistentFilters.length; i++)
		{
			archive.AddEntry(ARCHIVE_SELECTED_FILTERS, m_PersistentFilters[i]);
		}
		for (var i:Number = 0; i < m_PersistentDifficultyFilters.length; i++)
		{
			archive.AddEntry(ARCHIVE_SELECTED_DIFFICULTY_FILTERS, m_PersistentDifficultyFilters[i]);
		}
        
        return archive;
    }
} 
