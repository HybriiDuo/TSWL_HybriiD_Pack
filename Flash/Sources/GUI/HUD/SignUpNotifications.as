//Imports
import com.GameInterface.CharacterLFG;
import com.GameInterface.Game.Character;
import com.GameInterface.LookingForGroup;
import com.GameInterface.GroupFinder;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Utils;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import mx.utils.Delegate;

//Constants
var SOCIAL:Number = 0;
var TRADE:Number = 1;
var CABAL:Number = 2;
var DUNGEON:Number = 3;
var RAID:Number = 4;
var SCENARIO:Number = 5;
var LAIR:Number = 6;
var MISSION:Number = 7;

var ANY:Number = 0;
var NORMAL:Number = 1;
var ELITE:Number = 2;
var NIGHTMARE:Number = 3;

var TDB_SOCIAL:String = LDBFormat.LDBGetText("GroupSearchGUI", "Social");
var TDB_TRADE:String = LDBFormat.LDBGetText("GroupSearchGUI", "Trade");
var TDB_CABAL:String = LDBFormat.LDBGetText("GroupSearchGUI", "Cabal");
var TDB_DUNGEON:String = LDBFormat.LDBGetText("GroupSearchGUI", "Dungeon");
var TDB_RAID:String = LDBFormat.LDBGetText("GroupSearchGUI", "Raid");
var TDB_SCENARIO:String = LDBFormat.LDBGetText("GroupSearchGUI", "Scenario");
var TDB_LAIR:String = LDBFormat.LDBGetText("GroupSearchGUI", "Lair");
var TDB_MISSION:String = LDBFormat.LDBGetText("GroupSearchGUI", "Mission");

var TDB_ANY:String = LDBFormat.LDBGetText("GroupSearchGUI", "anyDifficulty");
var TDB_NORMAL:String = LDBFormat.LDBGetText("GroupSearchGUI", "normalDifficulty");
var TDB_ELITE:String = LDBFormat.LDBGetText("GroupSearchGUI", "eliteDifficulty");
var TDB_NIGHTMARE:String = LDBFormat.LDBGetText("GroupSearchGUI", "nightmareDifficulty");

var ICON_GAP:Number = 45;

//Properties
var m_PvPIcon:MovieClip;
var m_LFGIcon:MovieClip;
var m_GroupFinderIcon:MovieClip;
var m_EditModeMask:MovieClip;

//Variables
var m_Character:Character;
var m_VisibleNotificationsArray:Array;
var m_PvPQueue:Array;
var m_LFGQueue:Array;
var m_GroupFinderQueue:Array;
var m_IconWidth:Number;
var m_IconHeight:Number;
var m_DifficultyData:Array;
var m_LookingForGroup:LookingForGroup;

var m_LFGNotificationMonitor:DistributedValue;
var m_PvPNotificationMonitor:DistributedValue;
var m_GroupFinderNotificationMonitor:DistributedValue;

var m_MadeFakeIcon:Boolean;
var m_ReminderInterval:Number;

//On Load
function onLoad():Void
{
	m_LFGNotificationMonitor = DistributedValue.Create("lfg_queue_notifications");
	m_LFGNotificationMonitor.SignalChanged.Connect(UpdateLFGQueue, this);
	m_PvPNotificationMonitor = DistributedValue.Create("pvp_queue_notifications");
	m_PvPNotificationMonitor.SignalChanged.Connect(UpdatePvPQueue, this);
	m_GroupFinderNotificationMonitor = DistributedValue.Create("groupFinder_queue_notifications");
	m_GroupFinderNotificationMonitor.SignalChanged.Connect(UpdateGroupFinderQueue, this);
	
    PvPMinigame.SignalYouAreInMatchMaking.Connect(SlotSignUpPvP, this);
	PvPMinigame.SignalNoLongerInMatchMaking.Connect(SlotLeavePvP, this);
	
	m_LookingForGroup = new LookingForGroup();
    
    LookingForGroup.SignalClientJoinedLFG.Connect(SlotSignUpLFG, this);
    LookingForGroup.SignalClientLeftLFG.Connect(SlotLeaveLFG, this);
	
	GroupFinder.SignalClientJoinedGroupFinder.Connect(SlotSignUpGroupFinder, this);
	GroupFinder.SignalClientStartedGroupFinderActivity.Connect(SlotClientStartedGroupFinderActivity, this);
	GroupFinder.SignalClientLeftGroupFinder.Connect(SlotLeaveGroupFinder, this);
	
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
    
    m_VisibleNotificationsArray = new Array();
    m_PvPQueue = new Array();
    m_LFGQueue = new Array();
	m_GroupFinderQueue = new Array();
    m_DifficultyData = new Array();
    
    m_DifficultyData.push({label:DIFFICULTY_NORMAL, data:_global.Enums.LFGDifficulty.e_Mode_Normal});
    
    if (LookingForGroup.CanCharacterJoinEliteDungeons())
    {
        m_DifficultyData.push({label:DIFFICULTY_ELITE, data:_global.Enums.LFGDifficulty.e_Mode_Elite});
    }
    
    if (LookingForGroup.CanCharacterJoinNightmareDungeons())
    {
        m_DifficultyData.push({label:DIFFICULTY_NIGHTMARE, data:_global.Enums.LFGDifficulty.e_Mode_Nightmare});
    }
        
    m_IconWidth = m_PvPIcon._width;
    m_IconHeight = m_PvPIcon._height;
    
    SetVisible(m_PvPIcon, false);
    SetVisible(m_LFGIcon, false);
	SetVisible(m_GroupFinderIcon, false);
    
    AttatchBadge(m_PvPIcon);
    AttatchBadge(m_LFGIcon);
	AttatchBadge(m_GroupFinderIcon);
    
    Character.SignalClientCharacterAlive.Connect(SlotCharacterAlive, this);
    
    SlotCharacterAlive();
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
}

//Slot Character Alive
function SlotCharacterAlive():Void
{
    PvPMinigame.RequestIsInMatchMaking();
    
    if (LookingForGroup.HasCharacterSignedUp())
    {
        SlotSignUpLFG();        
    }
	if (GroupFinder.IsClientSignedUp())
	{
		SlotSignUpGroupFinder();
	}
	if (m_ReminderInterval != undefined)
	{
		clearInterval(m_ReminderInterval);
		m_ReminderInterval = undefined;
	}
	m_ReminderInterval = setInterval(Delegate.create(this, LFGReminderSearch), 900000); //15 minutes
}

//Slot Sign Up PvP
function SlotSignUpPvP(mapID:Number, asTeamMember:Number):Void
{
	var isQueued:Boolean = false;
    
	for (var i:Number = 0; i < m_PvPQueue.length; i++)
	{
		if (m_PvPQueue[i].mapID == mapID)
		{
			isQueued = true;
			break;
		}
	}
	
	if (!isQueued)
	{
		m_PvPQueue.push({mapID:mapID, asTeamMember:asTeamMember});
	}
    
	UpdatePvPQueue();
}

//Slot Leave PvP
function SlotLeavePvP(mapID:Number):Void
{
    var tempArray:Array = new Array();
	for (var i:Number = 0; i<m_PvPQueue.length; i++)
	{
		if(!(m_PvPQueue[i].mapID == mapID))
		{
			tempArray.push(m_PvPQueue[i]);
		}
	}
	m_PvPQueue = tempArray;
	UpdatePvPQueue();
}

//Update PvP Queue
function UpdatePvPQueue():Void
{
	var queuedItemsTotal:Number = m_PvPQueue.length;

	if (queuedItemsTotal > 0 && m_PvPNotificationMonitor.GetValue())
	{
		SetVisible(m_PvPIcon, true);

        var title:String = LDBFormat.LDBGetText("WorldDominationGUI", "secretWar");
		var message:String = LDBFormat.LDBGetText("GenericGUI", "You_are_queued");
		
		for (var i:Number = 0; i < queuedItemsTotal; i++)
		{
			message += "<br/>- " + LDBFormat.LDBGetText("Playfieldnames", m_PvPQueue[i].mapID);
		}

		CreateTooltip(m_PvPIcon, title, message);
        
		m_PvPIcon.m_Badge.SetCharge(queuedItemsTotal);
	}
	else
	{
		SetVisible(m_PvPIcon, false);
		if (m_EditModeMask._visible && m_VisibleNotificationsArray.length == 0)
		{
			m_MadeFakeIcon = true;
			m_LFGIcon.m_Badge.SetCharge(0);
			SetVisible(m_LFGIcon, true);
		}
	}
}

//Slot Sign Up LFG
function SlotSignUpLFG():Void
{
    var characterLFGData:CharacterLFG = LookingForGroup.GetPlayerSignedUpData(); 
    var activity:String = GetSignedActivityString(characterLFGData);
	var difficulty:String = GetSignedDifficultyString(characterLFGData);

    var isQueued:Boolean = false;
	for (var i:Number = 0; i < m_LFGQueue.length; i++)
	{
		if (m_LFGQueue[i].activity == activity)
		{
			isQueued = true;
			break;
		}
	}
	
	if (!isQueued)
	{
        m_LFGQueue.push({activity:activity, difficulty:difficulty});
	}
    
	UpdateLFGQueue();
}

//Slog Leave LFG
function SlotLeaveLFG():Void
{
    m_LFGQueue.pop();

	UpdateLFGQueue();
}

function GetSignedActivityString(characterLFG:CharacterLFG)
{
	var signedActivityNum:Number = characterLFG.m_Playfields[0];
	if (signedActivityNum == SOCIAL){ return TDB_SOCIAL; }
	if (signedActivityNum == DUNGEON){ return TDB_DUNGEON; }
	if (signedActivityNum == RAID){ return TDB_RAID; }
	if (signedActivityNum == SCENARIO){ return TDB_SCENARIO; }
	if (signedActivityNum == LAIR){ return TDB_LAIR; }
	if (signedActivityNum == MISSION){ return TDB_MISSION; }
	return TDB_SOCIAL; //Default to social if we don't find anything
}

function GetSignedDifficultyString(characterLFG:CharacterLFG)
{
	var signedDifficultyNum:Number = characterLFG.m_Mode;
	if (signedDifficultyNum == ANY){ return TDB_ANY; }
	if (signedDifficultyNum == NORMAL){ return TDB_NORMAL; }
	if (signedDifficultyNum == ELITE){ return TDB_ELITE; }
	if (signedDifficultyNum == NIGHTMARE){ return TDB_NIGHTMARE; }
	return TDB_ANY; //Default to social if we don't find anything
}

//Update LFG Queue
function UpdateLFGQueue():Void
{
	var queuedItemsTotal:Number = m_LFGQueue.length;

	if (queuedItemsTotal > 0 && m_LFGNotificationMonitor.GetValue())
	{
		SetVisible(m_LFGIcon, true);

        var title:String = LDBFormat.LDBGetText("GroupSearchGUI", "GroupSearch_WindowTitle");
		var message:String = LDBFormat.LDBGetText("GenericGUI", "You_are_queued");
		
		for (var i:Number = 0; i < queuedItemsTotal; i++)
		{
            message += "<br/>- " + m_LFGQueue[i].activity + " (" + m_LFGQueue[i].difficulty + ")";
		}

		CreateTooltip(m_LFGIcon, title, message);

		m_LFGIcon.m_Badge.SetCharge(queuedItemsTotal);
	}
	else
	{
		SetVisible(m_LFGIcon, false);
		if (m_EditModeMask._visible && m_VisibleNotificationsArray.length == 0)
		{
			m_MadeFakeIcon = true;
			m_LFGIcon.m_Badge.SetCharge(0);
			SetVisible(m_LFGIcon, true);
		}
	}
}

//Slot Sign Up Group Finder
function SlotSignUpGroupFinder():Void
{
	//Don't notify if we are already active
	if (!GroupFinder.IsClientActive())
	{
		//Since the group finder is one queuing operation, we can just rebuild the whole thing when it is changed
		m_GroupFinderQueue = new Array();
		var signedQueues:Array = GroupFinder.GetQueuesSignedUp();
		var signedRoles:Array = GroupFinder.GetRolesSignedUp();
		for (var i:Number = 0; i < signedQueues.length; i++)
		{
			m_GroupFinderQueue.push({queueId:signedQueues[i], roles:signedRoles});
		}
		UpdateGroupFinderQueue();
	}
}

//Slot Leave Group Finder
function SlotLeaveGroupFinder():Void
{
	//Since the group finder is one operation, just remove everything
    m_GroupFinderQueue = new Array();
	UpdateGroupFinderQueue();
}

//Slot Client Started Group Finder Activity
function SlotClientStartedGroupFinderActivity():Void
{
	//We don't want to show this during the activity
	SlotLeaveGroupFinder();
}

//Update Group Finder Queue
function UpdateGroupFinderQueue():Void
{
	var queuedItemsTotal:Number = m_GroupFinderQueue.length;

	if (queuedItemsTotal > 0 && m_GroupFinderNotificationMonitor.GetValue())
	{
		SetVisible(m_GroupFinderIcon, true);

        var title:String = LDBFormat.LDBGetText("GenericGUI", "GroupFinderTitle");
		var message:String = LDBFormat.LDBGetText("GenericGUI", "You_are_queued");
		
		message += "<br/>(";
		//Group Finder will have the same roles for every queue, so just look at the first one
		var rolesSignedUp:Array = m_GroupFinderQueue[0].roles;
		for (var i:Number = 0; i < rolesSignedUp.length; i++)
		{
			if (rolesSignedUp[i] == _global.Enums.LFGRoles.e_RoleTank){ message += LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonLabel") + ", "; }
			if (rolesSignedUp[i] == _global.Enums.LFGRoles.e_RoleDamage){ message += LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonLabel") + ", "; }
			if (rolesSignedUp[i] == _global.Enums.LFGRoles.e_RoleHeal){ message += LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonLabel") + ", "; }
		}
		//Cut off the last , 
		message = message.slice(0, -2);
		message += ")";
		
		for (var i:Number = 0; i < queuedItemsTotal; i++)
		{
			message += "<br/>- " + LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_" + m_GroupFinderQueue[i].queueId);
		}

		CreateTooltip(m_GroupFinderIcon, title, message);
        
		m_GroupFinderIcon.m_Badge.SetCharge(queuedItemsTotal);
	}
	else
	{
		SetVisible(m_GroupFinderIcon, false);
		if (m_EditModeMask._visible && m_VisibleNotificationsArray.length == 0)
		{
			m_MadeFakeIcon = true;
			m_LFGIcon.m_Badge.SetCharge(0);
			SetVisible(m_LFGIcon, true);
		}
	}
}

//Set Visible
function SetVisible(targetIcon:MovieClip, visible:Boolean):Void
{
    if (visible == targetIcon._visible)
    {
        return;
    }
    
    if (visible)
    {
        m_VisibleNotificationsArray.push(targetIcon);
    }
    else
    {
        
        for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++)
        {
            if (m_VisibleNotificationsArray[i] == targetIcon)
            {
                m_VisibleNotificationsArray.splice(i, 1);
            }
        }
    }

    targetIcon._visible = visible;
    
    m_VisibleNotificationsArray.sort(Array.DESCENDING);
    
    for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++)
    {
        m_VisibleNotificationsArray[i]._x = 0 + ICON_GAP * i;
    }
	if (m_EditModeMask._visible)
	{
		LayoutEditModeMask();
	}
}

//Attach Badge
function AttatchBadge(target:MovieClip):Void
{
    var badge:MovieClip = target.attachMovie("_Numbers", "m_Badge", target.getNextHighestDepth());
    badge.UseSingleDigits = true;
    badge.SetColor(0x666666);
    
    badge._x = target._x + m_IconWidth;
    badge._y = target._y + m_IconHeight + 2;
    badge._xscale = badge._yscale = 110;
}

//Create Tooltip
function CreateTooltip(target:MovieClip, title:String, message:String):Void
{
    var htmlText:String = "<b>" + Utils.CreateHTMLString(title, {face: "_StandardFont", color: "#FFFFFF", size: 12}) + "</b>";
    htmlText += "<br/>" + Utils.CreateHTMLString(message, {face: "_StandardFont", color: "#FFFFFF", size: 11});

    TooltipUtils.AddTextTooltip(target, htmlText, 210, TooltipInterface.e_OrientationVertical, false);
}

function LFGReminderSearch():Void
{
	//Do not need a reminder search if the LFG window is open
	if (!DistributedValue.GetDValue("group_search_window", true) && DistributedValue.GetDValue("lfg_reminder_notifications", true))
	{
		m_LookingForGroup.DoReminderSearch();
	}
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if (edit)
	{
		if (m_VisibleNotificationsArray.length == 0)
		{
			m_MadeFakeIcon = true;
			m_LFGIcon.m_Badge.SetCharge(0);
			SetVisible(m_LFGIcon, true);
		}
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("SignupNotificationsScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		if (m_MadeFakeIcon)
		{
			m_MadeFakeIcon = false;
			SetVisible(m_LFGIcon, false);
		}
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("SignupNotificationsScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "SignupNotificationsX" );
	var newY:DistributedValue = DistributedValue.Create( "SignupNotificationsY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);	
}

function LayoutEditModeMask()
{
	var lastNotification:MovieClip = m_VisibleNotificationsArray[m_VisibleNotificationsArray.length - 1];
	m_EditModeMask._x = -10;
	m_EditModeMask._y = -10;
	m_EditModeMask._width = ICON_GAP * m_VisibleNotificationsArray.length + 10;
	m_EditModeMask._height = lastNotification._height + 20;
}