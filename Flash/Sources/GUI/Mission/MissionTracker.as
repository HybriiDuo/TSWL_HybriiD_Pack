import com.GameInterface.Quests;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.GameInterface.Quest;
import com.GameInterface.QuestsBase;
import com.Utils.Colors;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import mx.utils.Delegate;
import GUI.Mission.MissionTrackerItem;
import com.Utils.LDBFormat;
import com.GameInterface.Utils;
import com.GameInterface.Log;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.DragObject;
import com.Utils.ID32;
import flash.filters.GlowFilter;

var m_GuiModeMonitor:DistributedValue;
var m_IsMissionJournalActive:DistributedValue;
var m_VisibilityMonitor:DistributedValue;
var m_ActiveMission:Number;
var m_MissionTrackerItem:MissionTrackerItem;
var m_BonusTrackerItem:MissionTrackerItem;
var m_HitArea:MovieClip;
var m_MissionBar:MovieClip;
var m_IsBarActive:Boolean;
var m_LastCompletedMission:Number;

var m_IsDragIconHighlighted:Boolean;
var m_IsDraggingIcon:Boolean;
var m_AlignRight:Boolean;

var m_ForceShowMissionTrackerValue:DistributedValue;
var m_ForceShowMissionTracker:Boolean;

var m_ActiveQuestIDValue:DistributedValue;

var m_ForceReportsButton:Boolean;
var m_ReportsButton:MovieClip;
var m_EditModeMask:MovieClip;

var m_MissionTypeTextFormat:TextFormat;

var SLOT_STORY:Number = 0;
var SLOT_DUNGEON:Number = 1;
var SLOT_MAIN:Number = 2;
var SLOT_INVESTIGATION:Number = 3;
var SLOT_SIDE_1:Number = 4;
var SLOT_SIDE_2:Number = 5;
var SLOT_SIDE_3:Number = 6;
var SLOT_COUNT:Number = 7;

var FUSANG_PROJECTS_ID:Number = 34171;
var PROGRESS_PING_TIME:Number = 1500; //in milliseconds.

var m_MissionTrackerItemArray:Array;
var m_MissionTypeArray:Array;
var m_MissionOutline:MovieClip;
var m_ProgressPingTimer:Number;

gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "SlotDragEnd" );

function onLoad()
{
    m_IsBarActive = false;
	m_MissionTypeTextFormat = new TextFormat();
	m_MissionTypeTextFormat.font = "_StandardFont";
	m_MissionTypeTextFormat.size = 15;
	m_MissionTypeTextFormat.color = 0xCCCCCC;
	
	m_MissionTrackerItemArray = new Array();
	m_MissionTypeArray = new Array();

    Quests.SignalTaskAdded.Connect( SlotTaskAdded, this );
    Quests.SignalMissionCompleted.Connect( SlotMissionCompleted, this );
	Quests.SignalGoalProgress.Connect( SlotGoalProgress, this );   
	Quests.SignalMissionRemoved.Connect(SlotMissionRemoved, this);
	Quests.SignalMissionFailed.Connect(SlotMissionRemoved, this);
    Quests.SignalQuestChanged.Connect( SlotQuestChanged, this );
    Quests.SignalQuestRewardMakeChoice.Connect(SlotQuestRewardMakeChoice, this);
    GUI.Mission.MissionSignals.SignalMissionReportWindowClosed.Connect( SlotMissionReportWindowClosed, this );
    GUI.Mission.MissionSignals.SignalMissionRewardsAnimationDone.Connect( SlotMissionRewardsAnimationDone, this );
	GUI.Mission.MissionSignals.SignalHighlightMissionType.Connect( SlotHighlightSlot, this );
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	
    m_GuiModeMonitor = DistributedValue.Create( "guimode" );
	m_GuiModeMonitor.SignalChanged.Connect( SlotGuiModeChanged, this );
    
    m_IsMissionJournalActive = DistributedValue.Create( "mission_journal_window" );
	
    m_VisibilityMonitor = DistributedValue.Create("mission_tracker_visibility");
	m_VisibilityMonitor.SignalChanged.Connect(SlotVisibilityChanged, this);
	
	m_ActiveQuestIDValue = DistributedValue.Create("ActiveQuestID");
	m_ActiveQuestIDValue.SignalChanged.Connect(SlotActiveQuestChanged, this);
    
    m_MissionBar._visible = m_VisibilityMonitor.GetValue();
	m_MissionBar._alpha = 0;
    
	m_ForceShowMissionTrackerValue = DistributedValue.Create( "ForceShowMissionTracker" );
	m_ForceShowMissionTrackerValue.SignalChanged.Connect(SlotForceShowMissionTracker, this);
	m_ForceShowMissionTrackerValue.SetValue(false);
	m_ForceReportsButton = false;
   
	com.GameInterface.Utils.SignalObjectUnderMouseChanged.Connect(SlotObjectUnderMouseChanged, this);
	m_IsDragIconHighlighted = false;
	m_IsDraggingIcon = false;
	m_AlignRight = false;
    
    CreateSlotTooltips();
	CreateSlotAnimations();

    m_ActiveMission = 0
    
    DrawReportButton();
	
	m_ProgressPingTimer = undefined;
	
    m_HitArea.onMouseMove = Delegate.create(this, MissionBarFocus);
	CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
	Character.SignalCharacterEnteredReticuleMode.Connect(SlotCharacterEnteredReticuleMode, this);
	Character.SignalCharacterExitedReticuleMode.Connect(SlotCharacterExitedReticuleMode, this);
	SlotClientCharacterAlive();
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;	
}

function onUnload()
{
	ClearProgressPingTimer();
}

function SlotClientCharacterAlive()
{
	ShowNextMission();
	CheckBonusMission();
}

function CreateSlotTooltips()
{
    for (var i:Number = 0; i < SLOT_COUNT; i++ )
    {
        AddSingleTooltip( i, m_MissionBar["Slot" + i].m_Background );

    }
}

function CreateSlotAnimations()
{
	for (var i:Number = 0; i < SLOT_COUNT; i++ )
	{
		var animation = m_MissionBar["Slot" + i].attachMovie("MissionIconAnimation", "m_Animation", m_MissionBar["Slot" + i].getNextHighestDepth());
		animation._xscale = 80;
		animation._yscale = 80;
	}
}

function AddSingleTooltip( slotId:Number, clip:MovieClip )
{
    var headline:String = "";
    var bodyText:String = "";
    var descriptionText:String = "";
    var htmlText:String = "";
    
    switch( slotId )
    {
        case SLOT_STORY:
            headline = LDBFormat.LDBGetText( "Quests", "StoryMissionAllCaps" );
            bodyText = LDBFormat.LDBGetText( "Quests", "TooltipStoryMission" );
        break;
        case SLOT_DUNGEON:
            headline = LDBFormat.LDBGetText( "Quests", "DungeonMissionAllCaps" );
            bodyText = LDBFormat.LDBGetText( "Quests", "TooltipDungeonMission" );
        break;
        case SLOT_MAIN:
            headline = LDBFormat.LDBGetText( "Quests", "MainMissionAllCaps" );
            bodyText = LDBFormat.LDBGetText( "Quests", "TooltipMainMission" );
            descriptionText = LDBFormat.LDBGetText( "Quests", "TooltipMainMissionDescription" );
        break;
		case SLOT_INVESTIGATION:
            headline = LDBFormat.LDBGetText( "Quests", "InvestigationMissionAllCaps" );
            bodyText = LDBFormat.LDBGetText( "Quests", "TooltipInvestigationMission" );
        break;
        case SLOT_SIDE_1:
        case SLOT_SIDE_2:
        case SLOT_SIDE_3:
			var playfieldID:Number = Character.GetClientCharacter().GetPlayfieldID();
			if (playfieldID != FUSANG_PROJECTS_ID)
			{
				headline = LDBFormat.LDBGetText( "Quests", "SideMissionAllCaps" );
				bodyText = LDBFormat.LDBGetText( "Quests", "TooltipSideMission" );
			}
			else
			{
				headline = LDBFormat.LDBGetText( "Quests", "PvPMissionAllCaps" );
				bodyText = LDBFormat.LDBGetText( "Quests", "TooltipPvPMission" );
			}
    }
    
    htmlText = "<b>" + com.GameInterface.Utils.CreateHTMLString( headline, { face:"_StandardFont", color: "#FFFFFF", size: 14 } )+"</b>";
    if (descriptionText != "")
    {
        htmlText += "<br/>" + com.GameInterface.Utils.CreateHTMLString( descriptionText, { face:"_StandardFont", color: "#AAAAAA", size: 10 } );
    }
    
    htmlText += "<br/> <br/>" + com.GameInterface.Utils.CreateHTMLString( bodyText,{ face:"_StandardFont", color: "#FFFFFF", size: 12 }  );
    
    com.GameInterface.Tooltip.TooltipUtils.AddTextTooltip( clip, htmlText, 210,  com.GameInterface.Tooltip.TooltipInterface.e_OrientationHorizontal, true );
}

function FocusBarIn()
{
    if (!m_IsBarActive)
    {

    }
}

function SlotForceShowMissionTracker()
{
	m_ForceShowMissionTracker = Boolean(m_ForceShowMissionTrackerValue.GetValue());
	if (m_ForceShowMissionTracker && !m_IsBarActive)
	{
		ShowMissionTracker(true);
	}
	else if (!m_ForceShowMissionTracker && m_IsBarActive)
	{
		ShowMissionTracker(false);
	}
}

function SlotHighlightSlot(missionType:Number, highlight:Boolean)
{
	if (!highlight)
	{
		var slotID:Number = GetMissionSlot(missionType);
		
		if (slotID == undefined)
		{
			return;
		}

		if (slotID != -1)
		{
			if (slotID == SLOT_SIDE_1 || slotID == SLOT_SIDE_2 || slotID == SLOT_SIDE_3)
			{
				for (var i:Number = SLOT_SIDE_1; i <= SLOT_SIDE_3; i++)
				{
					m_MissionBar["Slot" + i].m_Animation.gotoAndStop("normal");
				}
			}
			else
			{
				m_MissionBar["Slot" + slotID].m_Animation.gotoAndStop("normal");
			}
		}
	}
	else
	{
		var slotID:Number = GetMissionSlot(missionType);
		if (slotID != -1 && highlight)
		{
			m_MissionBar["Slot" + slotID].m_Animation.gotoAndPlay("throttle");
		}
	}	
}

function HighlightMission(missionId:Number, highlight:Boolean)
{
	for (var i:Number = 0; i < m_MissionTrackerItemArray.length; i++)
	{
		if (missionId == m_MissionTrackerItemArray[i].GetMissionId())
		{
			if (highlight)
			{
				m_MissionTrackerItemArray[i]._parent.m_Animation.gotoAndPlay("throttle");
			}
			else
			{
				m_MissionTrackerItemArray[i]._parent.m_Animation.gotoAndStop("normal");
			}
		}
	}
}

function SlotCharacterEnteredReticuleMode()
{
	MissionBarFocus();
}

function SlotCharacterExitedReticuleMode()
{
	MissionBarFocus();
}

function MissionBarFocus()
{
    var isOutside:Boolean = ((_xmouse < 0 || _xmouse > m_HitArea._width) || (_ymouse <= 0 || _ymouse > m_HitArea._height+50));
    
    if ((isOutside || Character.IsInReticuleMode()) && m_IsBarActive && !m_ForceShowMissionTracker)
    {
        ShowMissionTracker(false);
    }
    else if(!isOutside && !m_IsBarActive)
    {
        ShowMissionTracker(true);
    }
}

function ShowMissionTracker(show:Boolean)
{
	if (show)
	{
		if (!m_IsBarActive)
		{
			if (m_MissionBar._visible)
			{
				m_IsBarActive = true;
				m_MissionBar.tweenEnd(false);
				
				ShowAllMissions();
				
				m_MissionBar.tweenTo(0.3, { _alpha:100 }, None.easeNone);
				m_MissionBar.onTweenComplete = undefined; // Delegate.create(this,  );
				if (m_MissionTrackerItem)
				{
					m_MissionTrackerItem.SetGoalVisibility(false);
				}
			}
		}
	}
	else
	{
		if (m_IsBarActive)
		{
			m_IsBarActive = false;
			m_MissionBar.tweenEnd(false);
			
			RemoveAllMissions();
	
			m_MissionBar.tweenTo(0.3, { _alpha:0 }, None.easeNone);
			if (m_MissionTrackerItem)
			{
				m_MissionTrackerItem.SetGoalVisibility(true);
			}	
		}
	}
	AlignMissionItems();
	AlignMissionTypes();
}

function ShowNextMission()
{
    Log.Info2("MissionTracker", "MissionTracker:ShowNextMission()");
	
    var currentActiveTier:Number = DistributedValue.GetDValue("ActiveQuestID")
    if (currentActiveTier == m_LastCompletedMission)
    {
        currentActiveTier = 0;
    }
    var nextTier = 0;
    var fetch = true;

    var quests:Array = Quests.GetAllActiveQuests();
	quests.sort(SortByMissionType, Array.DESCENDING);
    for ( var i = 0; i < quests.length; ++i )
    {
        var quest:com.GameInterface.Quest = quests[i];
        var missionId:Number = quest.m_ID;

        // Get the first.
        if( fetch )
        {
            nextTier = missionId;
            fetch = false;
        }

        if( missionId == currentActiveTier )
        {
            nextTier = currentActiveTier;
            break;

        } 
        else
        {
            // Get the next one, unless we are at the end.
            fetch = true;
            nextTier = missionId;      
        }
    }
	
	//Remove last one if exists
	if (m_MissionTrackerItem != undefined)
	{
		m_MissionTrackerItem.removeMovieClip();
		m_MissionTrackerItem = undefined;
	}
	
	if (nextTier != 0 && nextTier != undefined)
	{
		var quest:Quest = GetMission(nextTier);
		ShowMission(nextTier, 0);
	}
    
    Quests.SignalQuestChanged.Emit(nextTier);

}

function CheckBonusMission()
{
    var quests:Array = Quests.GetAllActiveQuests();
	var bonusId:Number = 0;
    for ( var i = 0; i < quests.length; ++i )
    {
        var quest:com.GameInterface.Quest = quests[i];
        if (quest.m_MissionType == _global.Enums.MainQuestType.e_AreaMission)
		{
			bonusId = quest.m_ID;
		}
    }
		
	if (bonusId != 0)
	{
		//Remove last one if exists
		if (m_BonusTrackerItem != undefined)
		{
			m_BonusTrackerItem.removeMovieClip();
			m_BonusTrackerItem = undefined;
		}
		ShowBonusMission(bonusId, 0);
	}  
}

//I hate this function
//Order is Main -> Investigation -> Side -> Dungeon -> Story
function SortByMissionType(a:Quest, b:Quest):Number
{
	aSlot = GetMissionSlot(a.m_MissionType);
	bSlot = GetMissionSlot(b.m_MissionType);
	//Main missions are always first!
	if (aSlot == SLOT_MAIN)
	{
		return -1;
	}
	if (bSlot == SLOT_MAIN)
	{
		return 1;
	}
	//Area missions are always last!
	if (aSlot == -1)
	{
		return 1;
	}
	if (bSlot == -1)
	{
		return -1;
	}
	
	//Already checked main missions, so investigation missions are next
	if (aSlot == SLOT_INVESTIGATION)
	{
		return -1;
	}
	if (bSlot == SLOT_INVESTIGATION)
	{
		return 1;
	}	
	//Already checked for main and investigation missions, so now side missions
	if (aSlot == SLOT_SIDE_1)
	{
		return -1;
	}
	if (bSlot == SLOT_SIDE_1)
	{
		return 1;
	}
	if (aSlot == SLOT_SIDE_2)
	{
		return -1;
	}
	if (bSlot == SLOT_SIDE_2)
	{
		return 1;
	}
	if (aSlot == SLOT_SIDE_3)
	{
		return -1;
	}
	if (bSlot == SLOT_SIDE_3)
	{
		return 1;
	}	
	//Already checked for main, investigation, and side missions, so dungeon missions are next
	if (aSlot == SLOT_DUNGEON)
	{
		return -1;
	}
	if (bSlot == SLOT_DUNGEON)
	{
		return 1;
	}
	//Already checked for main, investigation, side, and dungeon missions so story missions are next
	if (aSlot == SLOT_STORY)
	{
		return -1;
	}
	if (bSlot == SLOT_STORY)
	{
		return 1;
	}
	return 0; //This should never happen, but just in case.
}

function ShowAllMissions( )
{
    var quests:Array = Quests.GetAllActiveQuests();
    for ( var i = 0; i < quests.length; ++i )
    {
        var quest:Quest = quests[i];
        var missionId:Number = quest.m_ID;
        var slotID:Number = GetMissionSlot(quest.m_MissionType);
		if (slotID != -1)
		{
			var targetClip:MovieClip = m_MissionBar["Slot" + slotID];
			
			if (targetClip["m_MissionTrackerItem"] != undefined)
			{
				targetClip["m_MissionTrackerItem"].removeMovieClip();
				targetClip["m_MissionTrackerItem"] = undefined;
			}
			var targetWidth:Number = targetClip.m_Background._width;
			
			var tracker:MissionTrackerItem = MissionTrackerItem( targetClip.attachMovie("MissionTrackerItem", "m_MissionTrackerItem", targetClip.getNextHighestDepth()));
			tracker.ShowProgress( false )
			tracker.SetData(quest)
			tracker.Draw();
			tracker.SignalSetAsMainMission.Connect(ShowMission, this);
	  //    tracker.SignalDoubleClicked.Connect(IconDoubleClickHandler, this);
			tracker._x = targetWidth;
			
			AddSingleTooltip( slotID, tracker );
	   
			tracker.onRelease = function()
			{
				this.SignalSetAsMainMission.Emit( this.GetMissionId() );
			}
			
			if (missionId == m_ActiveMission)
			{
				m_MissionOutline = targetClip.attachMovie("MissionSlotOutline", "m_Outline", targetClip.getNextHighestDepth());
				m_MissionOutline._xscale = m_MissionOutline._yscale = 80;
			}
			m_MissionTrackerItemArray.push(tracker);
		}
    }
	
	//Add mission types for empty slots
	for (var i:Number = 0; i < SLOT_COUNT; i++ )
    {
        if (m_MissionBar["Slot" + i].m_MissionTrackerItem == undefined)
        {
            var missionTypeTextField:TextField = m_MissionBar["Slot" + i].createTextField("m_MissionType", m_MissionBar["Slot" + i].getNextHighestDepth(), 0, 0, 0, 0);
			missionTypeTextField.setNewTextFormat(m_MissionTypeTextFormat);
			var missionType:String = "";
			switch( i )
			{
				case SLOT_STORY:
					missionType = LDBFormat.LDBGetText( "Quests", "StoryMissionMixedCase" );
				break;
				case SLOT_DUNGEON:
					missionType = LDBFormat.LDBGetText( "Quests", "DungeonMissionMixedCase" );
				break;
				case SLOT_MAIN:
					missionType = LDBFormat.LDBGetText( "Quests", "MainMissionMixedCase" );
				break;
				case SLOT_INVESTIGATION:
					missionType = LDBFormat.LDBGetText( "Quests", "InvestigationMissionMixedCase" );
				break;
				case SLOT_SIDE_1:
				case SLOT_SIDE_2:
				case SLOT_SIDE_3:
					var playfieldID:Number = Character.GetClientCharacter().GetPlayfieldID();
					if (playfieldID != FUSANG_PROJECTS_ID)
					{
						missionType = LDBFormat.LDBGetText( "Quests", "SideMissionMixedCase" );
					}
					else
					{
						missionType = LDBFormat.LDBGetText( "Quests", "PvPMissionMixedCase" );
					}
			}
			
			missionTypeTextField.text = missionType;
			missionTypeTextField._alpha = 70;
			missionTypeTextField.selectable = false;
			missionTypeTextField._width = missionTypeTextField.textWidth + 4;
			missionTypeTextField._height = missionTypeTextField.textHeight + 3;
			
			missionTypeTextField._x = -missionTypeTextField.textWidth - 25;
			missionTypeTextField._y = 7;
			m_MissionTypeArray.push(missionTypeTextField);
			
			AddSingleTooltip( i, m_MissionBar["Slot" + i].m_Background );
        }
    }
}

function RemoveAllMissions()
{
	for (var i:Number = 0; i < m_MissionTrackerItemArray.length; i++)
	{
		m_MissionTrackerItemArray[i].removeMovieClip();
	}
	for (var i:Number = 0; i < m_MissionTypeArray.length; i++)
	{
		m_MissionTypeArray[i].removeTextField();
	}
	
    if (m_MissionOutline != undefined)
    {
        m_MissionOutline.removeMovieClip();
        m_MissionOutline = undefined;
    }
	
	m_MissionTrackerItemArray = [];
	m_MissionTypeArray = [];	
}


//Returns false if it doesnt actually update anything
function ShowMission(tierId:Number, goalId:Number, isActive:Boolean) :Boolean
{
    Log.Info2("MissionTracker", "MissionTracker:ShowMission(" + tierId + ", "+goalId+", "+isActive+")");
	var shownMissionId:Number = m_MissionTrackerItem.GetMissionId();
	if (tierId == 0 || tierId == shownMissionId)
	{
		return;
	}
	var mission:Quest = GetMission(tierId);
	
	//don't show area missions here. They have their own display
	if (mission.m_MissionType == _global.Enums.MainQuestType.e_AreaMission)
	{
		return;
	}
	
    if ( mission != undefined)
    {
        if (m_MissionTrackerItem != undefined)
        {
            m_MissionTrackerItem.removeMovieClip();
            m_MissionTrackerItem = undefined;
        }
		
		if (m_MissionOutline != undefined)
		{
			m_MissionOutline.removeMovieClip();
			
			for (var i:Number = 0; i < SLOT_COUNT; i++ )
			{
				if (m_MissionBar["Slot" + i].m_MissionTrackerItem != undefined && m_MissionBar["Slot" + i].m_MissionTrackerItem.GetMissionId() == tierId)
				{
					m_MissionOutline = m_MissionBar["Slot" + i].attachMovie("MissionSlotOutline", "m_Outline", m_MissionBar["Slot" + i].getNextHighestDepth());
					m_MissionOutline._xscale = m_MissionOutline._yscale = 80;
				}
			}
		}
        
		if (m_VisibilityMonitor.GetValue())
		{
			m_MissionTrackerItem = MissionTrackerItem( attachMovie("MissionTrackerItem", "m_MissionTrackerItem " + UID(), getNextHighestDepth()) );
			m_MissionTrackerItem.SetData( mission )
			m_MissionTrackerItem.Draw();
			m_MissionTrackerItem.SetGoalVisibility(!m_IsBarActive, true)
			m_MissionTrackerItem._x = 50;
			m_MissionTrackerItem._xscale = 90;
			m_MissionTrackerItem._yscale = 90;
		}

        // FIXME: icon is not defined here, figure out where it went and connect the event handler again.
//        icon.addEventListener("dragOut", this, "IconMouseDragHandler");
        m_MissionTrackerItem.onRelease = Delegate.create( this, OpenMissionJournal);

		Quests.SignalMissionRequestFocus.Emit( tierId );
        DistributedValue.SetDValue("ActiveQuestID", tierId);
		DistributedValue.SetDValue("OpenJournalQuest", tierId );
		m_ActiveMission = tierId;
		HighlightMission(mission.m_ID, false);
		AlignText();
		return true;
    }
	return false;
}

//Returns false if it doesnt actually update anything
function ShowBonusMission(tierId:Number, goalId:Number, isActive:Boolean) :Boolean
{
	if (tierId == 0)
	{
		return;
	}
	var mission:Quest = GetMission(tierId);
	
    if ( mission != undefined)
    {
        if (m_BonusTrackerItem != undefined)
        {
            m_BonusTrackerItem.removeMovieClip();
            m_BonusTrackerItem = undefined;
        }
        
		if (m_VisibilityMonitor.GetValue())
		{
			m_BonusTrackerItem = MissionTrackerItem( attachMovie("MissionTrackerItem", "m_BonusTrackerItem " + UID(), getNextHighestDepth()) );
			m_BonusTrackerItem.SetData( mission )
			m_BonusTrackerItem.Draw();
			m_BonusTrackerItem.SetGoalVisibility(!m_IsBarActive, true)
			m_BonusTrackerItem._y = -50;
			m_BonusTrackerItem._x = 50;
			m_BonusTrackerItem._xscale = 90;
			m_BonusTrackerItem._yscale = 90;
		}
		AlignText();
		return true;
    }
	return false;
}

function OpenMissionJournal()
{
    
    m_IsMissionJournalActive.SetValue( true );
}

function GetMissionSlot(missionType:Number)
{
	var slotId:Number = -1;
	var playfieldID:Number = Character.GetClientCharacter().GetPlayfieldID();
    
	switch( missionType )
	{
		case    _global.Enums.MainQuestType.e_Action:
		case    _global.Enums.MainQuestType.e_Sabotage:
		case    _global.Enums.MainQuestType.e_Challenge:
		case	_global.Enums.MainQuestType.e_StoryRepeat:
			slotId = SLOT_MAIN;
		break;
		case    _global.Enums.MainQuestType.e_Investigation:
			slotId = SLOT_INVESTIGATION;
		break;
		case    _global.Enums.MainQuestType.e_Lair:
		case    _global.Enums.MainQuestType.e_Group:
        case    _global.Enums.MainQuestType.e_Raid:
		case	_global.Enums.MainQuestType.e_Scenario:
			slotId = SLOT_DUNGEON;
		break;
		case    _global.Enums.MainQuestType.e_Story:
			slotId = SLOT_STORY;
		break;
		case    _global.Enums.MainQuestType.e_Item:
		case    _global.Enums.MainQuestType.e_Massacre:
		case	_global.Enums.MainQuestType.e_InvestigationSide:
			if (playfieldID != FUSANG_PROJECTS_ID)
			{
				if (m_MissionBar["Slot" + SLOT_SIDE_1].m_MissionTrackerItem == undefined)
				{
					slotId = SLOT_SIDE_1
				}
				else if (m_MissionBar["Slot" + SLOT_SIDE_2].m_MissionTrackerItem == undefined)
				{
					slotId = SLOT_SIDE_2
				}
				else
				{
					slotId = SLOT_SIDE_3
				}
			}
		break;
		case    _global.Enums.MainQuestType.e_PvP:
			if (playfieldID == FUSANG_PROJECTS_ID)
			{
				if (m_MissionBar["Slot" + SLOT_SIDE_1].m_MissionTrackerItem == undefined)
				{
					slotId = SLOT_SIDE_1
				}
				else if (m_MissionBar["Slot" + SLOT_SIDE_2].m_MissionTrackerItem == undefined)
				{
					slotId = SLOT_SIDE_2
				}
				else
				{
					slotId = SLOT_SIDE_3
				}
			}
		break;
	}
    
    
    return slotId;
}

function GetMission(missionID) : Quest
{
   var quests:Array = Quests.GetAllActiveQuests();
    for ( var i = 0; i < quests.length; ++i )
    {
        if (quests[i].m_ID == missionID)
        {
            return quests[i];
        }
    }
    
    return null;
}


function IconDoubleClickHandler(missionId)
{
    if (m_IsMissionJournalActive.GetValue())
    {
       Quests.SignalMissionRequestFocus.Emit( missionId );   
    }
    else
    {
        DistributedValue.SetDValue("OpenJournalQuest", missionId );
        m_IsMissionJournalActive.SetValue( true );
    }
}



/// When a new mission has been spawned, shift focus to this
function SlotTaskAdded( missionID:Number) :Void
{
    Log.Info2("MissionTracker", "MissionTracker:SlotTaskAdded(" + missionID + ")");
	
	var quest:Quest = GetMission(missionID);
	
	//if it's an area mission do special things
	if (quest.m_MissionType == _global.Enums.MainQuestType.e_AreaMission)
	{
		if (missionID == m_BonusTrackerItem.GetMissionId())
		{
			m_BonusTrackerItem.TaskAdded( missionID );
		}
		else
		{
			ShowBonusMission(missionID, 0);
		}
		AlignText();
		return;
	}

	var activeMission:Number = DistributedValue.GetDValue("ActiveQuestID", 0);
	//If the mission is the active mission, update the active mission
	if (activeMission == missionID)
	{
		m_MissionTrackerItem.TaskAdded( missionID );
		AlignText();
		return;
	}
	//Otherwise, if we have no missions, make this the active mission
	else if (activeMission == 0)
	{
		ShowMission(missionID, 0);
		AlignText();
		return;
	}
	//Otherwise, if we auto select quests
	else if (DistributedValue.GetDValue("AutoSelectQuests"))
	{
		// If this is the first tier (new quest) or NOT a side mission, show it
		if (quest.m_CurrentTask.m_Tier == 1 || 
			(quest.m_MissionType != _global.Enums.MainQuestType.e_Item && quest.m_MissionType != _global.Enums.MainQuestType.e_InvestigationSide))
		{
			ShowMission(missionID, 0);
			AlignText();
			return;
		}
	}
	
	//Update the rest of the tracker
	for (var i:Number = 0; i < m_MissionTrackerItemArray; i++)
	{
		m_MissionTrackerItemArray[i].TaskAdded(missionID);
	}
	AlignText();
}

function SlotGoalProgress(tierId:Number, goalId:Number, solvedTimes:Number, repeatCount:Number)
{
	var quests:Array = Quests.GetAllActiveQuests();
	var quest:Quest = undefined;
    for ( var i = 0; i < quests.length; ++i )
    {
		if (quests[i].m_ID == tierId)
		{
			quest = quests[i];
			break;
		}
	}
	if (quest != undefined)
	{
		if (quest.m_ID != m_MissionTrackerItem.GetMissionId() && quest.m_MissionType != _global.Enums.MainQuestType.e_AreaMission)
		{
			m_ForceShowMissionTracker = true;
			ShowMissionTracker(true);
			HighlightMission(quest.m_ID, true);
			
			ClearProgressPingTimer();
			m_ProgressPingTimer = setInterval(Delegate.create(this, ProgressPingTimeout), PROGRESS_PING_TIME);
		}
	}
}

function ProgressPingTimeout()
{
	ClearProgressPingTimer();
	m_ForceShowMissionTracker = false;
	if (Character.IsInReticuleMode())
	{
		MissionBarFocus();
	}
}

function ClearProgressPingTimer()
{
	if (m_ProgressPingTimer != undefined)
	{
		clearInterval(m_ProgressPingTimer);
		m_ProgressPingTimer = undefined;
	}
}

function SlotQuestChanged()
{
    Log.Info2("MissionTracker", "MissionTracker:SlotQuestChanged()");
}

function SlotMissionCompleted( missionId:Number )
{
    Log.Info2("MissionTracker", "MissionTracker:SlotMissionCompleted()");
	if (!QuestsBase.IsChallengeMission(missionId))
	{
		if (missionId != undefined)
		{
			m_LastCompletedMission = missionId;
		}
		if (m_MissionTrackerItem.GetMissionId() == missionId)
		{
			if (m_MissionTrackerItem.IsAnimationPending(true))
			{
				m_MissionTrackerItem.SignalAnimationsDone.Connect(SlotMissionCompleted, this);
			}
			else
			{
				m_MissionTrackerItem.SignalAnimationsDone.Disconnect(SlotMissionCompleted);
				var newY:Number = m_MissionTrackerItem._y + m_MissionTrackerItem._height;
				m_MissionTrackerItem["tweenTo"](0.2, { _alpha:0, _xscale:200, _yscale:200, _y:newY  }, None.easeNone);
				m_MissionTrackerItem["onTweenComplete"] = Delegate.create(this, RemoveMainMission);
			}
		}		
		if (m_BonusTrackerItem.GetMissionId() == missionId)
		{
			var newY:Number = m_BonusTrackerItem._y + m_BonusTrackerItem._height;
			m_BonusTrackerItem["tweenTo"](2, { _alpha:0 }, None.easeNone);
			m_BonusTrackerItem["onTweenComplete"] = Delegate.create(this, RemoveBonusMission);
		}
	}
}

function SlotMissionRemoved(missionId:Number)
{
	if (m_MissionTrackerItem.GetMissionId() == missionId)
	{
		var newY:Number = m_MissionTrackerItem._y + m_MissionTrackerItem._height;
		m_MissionTrackerItem["tweenTo"](0.2, { _alpha:0, _xscale:200, _yscale:200, _y:newY  }, None.easeNone);
		m_MissionTrackerItem["onTweenComplete"] = Delegate.create(this, RemoveMainMission);
	}
	if (m_BonusTrackerItem.GetMissionId() == missionId)
	{
		var newY:Number = m_BonusTrackerItem._y + m_BonusTrackerItem._height;
		m_BonusTrackerItem["tweenTo"](2, { _alpha:0 }, None.easeNone);
		m_BonusTrackerItem["onTweenComplete"] = Delegate.create(this, RemoveBonusMission);
	}
}

function RemoveBonusMission()
{
	if (m_BonusTrackerItem != undefined)
    {
        m_BonusTrackerItem.removeMovieClip();
        m_BonusTrackerItem = undefined;
    }
	CheckBonusMission();
}


function RemoveMainMission()
{
    if (m_MissionTrackerItem != undefined)
    {
        m_MissionTrackerItem.removeMovieClip();
        m_MissionTrackerItem = undefined;
    }

	DistributedValue.SetDValue("ActiveQuestID", 0);
	m_ActiveMission = 0;
    ShowNextMission();
}

function SlotMissionRewardsAnimationDone()
{
    DrawReportButton(true);
}
/*
function SlotQuestRewardMakeChoice()
{
    Log.Info2("MissionTracker", "MissionTracker:SlotQuestRewardMakeChoice()");
    DrawReportButton();
}
*/
/// checks if there are any unsent reports and draws the report button if not
function DrawReportButton(animate:Boolean)
{
   Log.Info2("MissionTracker", "MissionTracker:DrawReportButton()");
   if (!Quests.AnyUnsentReports() && !m_ForceReportsButton)
    {
        Log.Info2("MissionTracker", "MissionTracker:No unsent reports, aborting!"); 
		RemoveMissionReportButton();
        return;
    }
    
    /// if there is a button present
    if (m_ReportsButton != undefined)
    {
        m_ReportsButton.SetText();
    }
    else
    {
        m_ReportsButton = this.attachMovie("MissionReportButton", "m_ReportsButton", this.getNextHighestDepth());
        m_ReportsButton._y = -75 
		m_ReportsButton._x = -156;
		m_ReportsButton.AlignRight(m_AlignRight);
        GUI.Mission.MissionSignals.SignalMissionReportSent.Connect(RemoveMissionReportButton, this);
    }
    
    SlotGuiModeChanged();
}

function RemoveMissionReportButton()
{
    if (m_ReportsButton != undefined)
    {
        m_ReportsButton.removeMovieClip();
        m_ReportsButton = undefined;
    }
}

function SlotGuiModeChanged()
{
    var guimode:Number = m_GuiModeMonitor.GetValue();
    if (m_ReportsButton != undefined)
    {
        m_ReportsButton._visible = (guimode & (_global.Enums.GuiModeFlags.e_GUIModeFlags_PlayerGhosting | _global.Enums.GuiModeFlags.e_GUIModeFlags_PlayerDead)) == 0;
    }
}

function SlotActiveQuestChanged()
{
	ShowMission(m_ActiveQuestIDValue.GetValue(), 0);
}

function SlotVisibilityChanged():Void
{
    m_MissionBar._visible = m_VisibilityMonitor.GetValue();
	ShowNextMission();
	CheckBonusMission();
}

/// when all MissionRewardWindows has been closed, dispatch this to see if we need to redraw the windows
function SlotMissionReportWindowClosed()
{
    
    setTimeout( Delegate.create(this, DrawReportButton), 3000);
   // DrawReportButton();
}

function IconMouseDragHandler(event:Object)
{
    var dragData:DragObject = new DragObject();
    dragData.type = "mission";
    
    var quest:com.GameInterface.Quest = Quests.GetQuest( Quests.m_CurrentMissionId, true );
    var missionType:String = GUI.Mission.MissionUtils.MissionTypeToString( quest.m_MissionType );
    
    var dragClip:MovieClip = createEmptyMovieClip("m_DragClip", getNextHighestDepth());
    var icon:MovieClip = dragClip.attachMovie("_Icon_Mission_" + missionType, "dragClip", dragClip.getNextHighestDepth(), { _xscale:80, _yscale:80, _alpha:50 } );
    var frame:MovieClip = dragClip.attachMovie("DragDecal", "frame", dragClip.getNextHighestDepth());
    var modifier:MovieClip = dragClip.attachMovie("ShareSymbol", "share", dragClip.getNextHighestDepth(),{_xscale:25, _yscale:25, _x:27, _y:27});
    
    gfx.managers.DragManager.instance.startDrag( event.target, dragClip, dragData, dragData, null, true );
    gfx.managers.DragManager.instance.removeTarget = true;
	m_IsDraggingIcon = true;
}


function IconMouseOverCharacter()
{
	m_IsDragIconHighlighted = true;
    this["m_DragClip"].frame.gotoAndStop("enabled");
}


function IconMouseOutCharacter()
{
	m_IsDragIconHighlighted = false;
    this["m_DragClip"].frame.gotoAndStop("disabled");
}

function SlotObjectUnderMouseChanged(targetID:ID32)
{
	if (m_IsDraggingIcon)
	{
		if (com.GameInterface.Game.TeamInterface.IsInTeam(targetID) && !targetID.Equal(com.GameInterface.Game.Character.GetClientCharID()))
		{
			IconMouseOverCharacter();
		}
		else if (m_IsDragIconHighlighted)
		{
			IconMouseOutCharacter();
		}
	}
}


function SlotDragEnd( event:Object )
{
    if ( event.data.type == "mission" )
    {
        Quests.ShareQuestUnderMouse(Quests.m_CurrentMissionId);   
    }
	m_IsDraggingIcon = false;
   
}

function AlignMissionTypes()
{
	var alignRight:Boolean = this._x < Stage.width/2
	m_AlignRight = alignRight;
	if (alignRight)
	{
		for (var i=0; i<m_MissionTypeArray.length; i++)
		{
			m_MissionTypeArray[i]._x = 55;
		}
	}
	else
	{
		for (var i=0; i<m_MissionTypeArray.length; i++)
		{
			m_MissionTypeArray[i]._x = -m_MissionTypeArray[i].textWidth - 25
		}
	}
}

function AlignMissionItems()
{
	var alignRight:Boolean = this._x < Stage.width/2
	m_AlignRight = alignRight;
	for (var i=0; i<m_MissionTrackerItemArray.length; i++)
	{
		m_MissionTrackerItemArray[i].AlignText(alignRight);
	}
}

function AlignText()
{
	var alignRight:Boolean = this._x < Stage.width/2
	m_AlignRight = alignRight;
	if (m_ReportsButton != undefined)
	{
		m_ReportsButton.AlignRight(alignRight);
	}
	if (m_MissionTrackerItem != undefined)
	{
		m_MissionTrackerItem.AlignText(alignRight);
	}
	if (m_BonusTrackerItem != undefined)
	{
		m_BonusTrackerItem.AlignText(alignRight);
	}
	AlignMissionItems();
	AlignMissionTypes();
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	m_EditModeMask.swapDepths(getNextHighestDepth());
	if (edit)
	{
		LayoutEditModeMask();
		m_ForceShowMissionTracker = true;
		m_ForceReportsButton = true;
		if (!m_IsBarActive)
		{
			ShowMissionTracker(true);
		}
		DrawReportButton(false);
		m_ReportsButton.DisableReportButton(true);
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("MissionTrackerScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		m_ForceShowMissionTracker = false;
		m_ForceReportsButton = false;
		DrawReportButton(false);
		if (m_ReportsButton != undefined)
		{
			m_ReportsButton.DisableReportButton(false);
		}
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("MissionTrackerScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
	this.onMouseMove = function()
	{
		AlignText();
	}
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "MissionTrackerX" );
	var newY:DistributedValue = DistributedValue.Create( "MissionTrackerY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);
	this.onMouseMove = function(){}
}

function LayoutEditModeMask()
{
	m_EditModeMask._x = m_HitArea._x;
	m_EditModeMask._y = -45;
	m_EditModeMask._width = m_HitArea._width;
	m_EditModeMask._height = m_HitArea._height + 45;
}
