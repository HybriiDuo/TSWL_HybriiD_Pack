//Imports
import com.GameInterface.DialogIF;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.Raid;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Game.TargetingInterface;
import com.GameInterface.Game.Team;
import com.GameInterface.ProjectUtils;
import com.Utils.Archive;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import flash.geom.Point;
import flash.geom.Rectangle;
import GUI.Team.TeamClip;
import GUI.Team.RaidClip;
import GUI.Team.TeamMember;

//Constants
var PVP_PLAYFIELD_ID_GAMETWEAK:String = "PvP_FactionVSFactionVSFactionPlayfieldID";

var PVP_WINDOW_FRAME_LOCKED:String = "PVPWindowFrameLocked";
var PVP_SHOW_WINDOW_FRAME:String = "PVPShowWindowFrame";
var PVP_SHOW_GROUP_NAMES:String = "PVPShowGroupNames";
var PVP_SHOW_WINDOW:String = "PVPShowWindow";
var PVP_WINDOW_SIZE:String = "PVPWindowSize";
var PVP_WINDOW_ALIGNMENT:String = "PVPWindowAlignment";
var PVP_SHOW_HP_NUMBERS:String = "PVPShowHPNumbers";
var PVP_SHOW_HEALTH_BAR:String = "PVPShowHealthBar";
var PVP_SHOW_NAMETAG_ICONS:String = "PVPShowNametagIcons";
var PVP_IS_GROUP_DETACHED:String = "PVPIsGroupDetatched";
var PVP_NUMBER_OF_COLUMNS:String = "PVPNumberOfColumns";

var WINDOW_FRAME_LOCKED:String = "WindowFrameLocked";
var SHOW_WINDOW_FRAME:String = "ShowWindowFrame";
var SHOW_GROUP_NAMES:String = "ShowGroupNames";
var SHOW_WINDOW:String = "ShowWindow";
var WINDOW_SIZE:String = "WindowSize";
var WINDOW_ALIGNMENT:String = "WindowAlignment";
var SHOW_HP_NUMBERS:String = "ShowHPNumbers";
var SHOW_HEALTH_BAR:String = "ShowHealthBar";
var SHOW_NAMETAG_ICONS:String = "ShowNametagIcons";
var IS_GROUP_DETACHED:String = "IsGroupDetatched";
var NUMBER_OF_COLUMNS:String = "NumberOfColumns";

//Properties
var SizeChanged:Signal;
var m_ResolutionScaleMonitor:DistributedValue;
var m_TeamScaleMonitor:DistributedValue;
var m_RaidScaleMonitor:DistributedValue;
var m_DefensiveTargetScaleMonitor:DistributedValue;
var m_MouseOverTargeting:DistributedValue;

var m_EnableTeamWindowMonitor:DistributedValue;
var m_EnableDefensiveTargetWindowMonitor:DistributedValue;

var m_ClientCharacter:Character;
var m_DefensiveTargetClip:MovieClip;

var m_DefensiveTargetPosition:Point;
var m_DefensiveTargetLocked:Boolean;
var m_DefensiveTargetDocked:Boolean;
var m_TeamWindowPosition:Point;
var m_TeamWindowLocked:Boolean;

var m_CurrentRaid:RaidClip;
var m_CurrentTeam:TeamClip;

var m_InviteDialogIF:DialogIF;
var m_VoteKickPrompt:MovieClip;

var m_RaidArchive:Archive;
var m_RaidPosition:Point;

var m_Team:Team;
var m_FocusTarget:ID32;
var m_DoNotFocus:Boolean;

//On Load
function onLoad():Void
{
    SizeChanged = new Signal();
    
    m_ResolutionScaleMonitor = DistributedValue.Create("GUIResolutionScale");
    m_ResolutionScaleMonitor.SignalChanged.Connect(Resize, this);
	m_TeamScaleMonitor = DistributedValue.Create("TeamGUIScale");
	m_TeamScaleMonitor.SignalChanged.Connect(Resize, this);
	m_RaidScaleMonitor = DistributedValue.Create("RaidGUIScale");
	m_RaidScaleMonitor.SignalChanged.Connect(Resize, this);
	m_DefensiveTargetScaleMonitor = DistributedValue.Create("DefensiveTargetScale");
	m_DefensiveTargetScaleMonitor.SignalChanged.Connect(Resize, this);
	
	m_EnableTeamWindowMonitor = DistributedValue.Create("team_window");
	m_EnableTeamWindowMonitor.SignalChanged.Connect(SlotTeamMonitorChanged, this);
	
	m_MouseOverTargeting = DistributedValue.Create("MouseOverTargeting");
	
	m_EnableDefensiveTargetWindowMonitor = DistributedValue.Create("defensive_target_window");
	m_EnableDefensiveTargetWindowMonitor.SignalChanged.Connect(SlotDefensiveTargetMonitorChanged, this);
    
    TeamInterface.SignalClientJoinedTeam.Connect(SlotClientJoinedTeam, this);
    TeamInterface.SignalClientLeftTeam.Connect(SlotClientLeftTeam, this);
    
    TeamInterface.SignalClientJoinedRaid.Connect(SlotClientJoinedRaid, this);
    TeamInterface.SignalClientLeftRaid.Connect(SlotClientLeftRaid, this);
        
    CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
    
    m_ClientCharacter = Character.GetClientCharacter();
    
    if (m_ClientCharacter != undefined)
    {
        m_ClientCharacter.SignalDefensiveTargetChanged.Connect(SlotDefensiveTargetChanged, this);
        m_ClientCharacter.SignalCharacterDied.Connect(UpdateRaidArchive, this);
    }
    
    TeamInterface.SignalTeamInvite.Connect(SlotTeamInvite, this);
	TeamInterface.SignalPromptJoinRequest.Connect(SlotPromptJoinRequest, this);
    TeamInterface.SignalTeamInviteTimedOut.Connect(SlotInviteTimedOut, this);
    
    TeamInterface.SignalRaidInvite.Connect(SlotRaidInvite, this);
    TeamInterface.SignalRaidInviteTimedOut.Connect(SlotInviteTimedOut, this);
	
	TeamInterface.SignalShowVoteKickReasonPrompt.Connect(SlotShowVoteKickReasonPrompt, this);
	m_DoNotFocus = false;
}

//On Module Activated
function OnModuleActivated(config:Archive):Void
{
    if ( config != undefined )
    {
		m_DefensiveTargetPosition = config.FindEntry("DefensiveTargetPosition");
		m_TeamWindowPosition = config.FindEntry("TeamWindowPosition");
		m_DefensiveTargetLocked = config.FindEntry("DefensiveTargetLocked");
		m_DefensiveTargetDocked = config.FindEntry("DefensiveTargetDocked");
		m_TeamWindowLocked = config.FindEntry("TeamWindowLocked");
		
		m_RaidArchive = config.FindEntry("RaidWindowConfig");
		if (m_RaidArchive != undefined && m_CurrentRaid != undefined)
		{
			SlotClientJoinedRaid(m_CurrentRaid.GetRaid());
		}
    }

    if (m_ClientCharacter != undefined)
    {
        SlotDefensiveTargetChanged(m_ClientCharacter.GetDefensiveTarget());
    }
    
    TeamInterface.RequestTeamInformation();   

    Resize();
}

//On Module Deactivated
function OnModuleDeactivated():Archive
{
    var archive:Archive = new Archive();
	
	if (m_DefensiveTargetClip != undefined)
	{
		if (m_DefensiveTargetPosition == undefined){ m_DefensiveTargetPosition = new Point(); }
		m_DefensiveTargetPosition.x = m_DefensiveTargetClip._x;
		m_DefensiveTargetPosition.y = m_DefensiveTargetClip._y;
	}
	
	if (m_DefensiveTargetPosition != undefined)
	{
		archive.AddEntry("DefensiveTargetPosition", m_DefensiveTargetPosition);
	}
	
	if (m_DefensiveTargetLocked != undefined)
	{
		archive.AddEntry("DefensiveTargetLocked", m_DefensiveTargetLocked);
	}
	
	if (m_DefensiveTargetDocked != undefined)
	{
		archive.AddEntry("DefensiveTargetDocked", m_DefensiveTargetDocked);
	}
	
	if (m_CurrentTeam != undefined)
	{
		if (m_TeamWindowPosition == undefined){ m_TeamWindowPosition = new Point(); }
		m_TeamWindowPosition.x = m_CurrentTeam._x;
		m_TeamWindowPosition.y = m_CurrentTeam._y;
	}
	
	if (m_TeamWindowPosition != undefined)
	{
		archive.AddEntry("TeamWindowPosition", m_TeamWindowPosition);
	}
	
	if (m_TeamWindowLocked != undefined)
	{
		archive.AddEntry("TeamWindowLocked", m_TeamWindowLocked);
	}
	
	if (m_RaidArchive != undefined)
	{
    	archive.AddEntry("RaidWindowConfig", m_RaidArchive); 
	}
    
    SlotClientLeftTeam();
	
	if (m_CurrentRaid != undefined)
    {        
        ClearRaid();
    }

    return archive;
}

//Slot Client Character Alive
function SlotClientCharacterAlive():Void
{
    m_ClientCharacter = Character.GetClientCharacter();
    m_ClientCharacter.SignalDefensiveTargetChanged.Connect(SlotDefensiveTargetChanged, this);
    
    SlotDefensiveTargetChanged(m_ClientCharacter.GetDefensiveTarget());
}

function SlotTeamMonitorChanged():Void
{
	if (m_Team != undefined)
	{
		SlotClientJoinedTeam(m_Team);
	}
}

//Slot Client Joined Team
function SlotClientJoinedTeam(team:Team):Void
{
    SlotClientLeftTeam();
	m_Team = team;
	
	if (Boolean(m_EnableTeamWindowMonitor.GetValue()))
	{
		m_CurrentTeam = attachMovie("TeamClip", "team", getNextHighestDepth());
		m_CurrentTeam._xscale = m_CurrentTeam._yscale = m_TeamScaleMonitor.GetValue();
		if(m_DefensiveTargetLocked == undefined){ m_DefensiveTargetLocked = true; }
		m_CurrentTeam.SetIsDefensiveLocked(m_DefensiveTargetLocked);
		if(m_DefensiveTargetDocked == undefined){ m_DefensiveTargetDocked = true; }
		m_CurrentTeam.SetIsDefensiveDocked(m_DefensiveTargetDocked);
		if(m_TeamWindowLocked == undefined){ m_TeamWindowLocked = true; }
		m_CurrentTeam.SetIsLocked(m_TeamWindowLocked);
		m_CurrentTeam.SetShowGroupNames(false);
		m_CurrentTeam.SetTeam(team);
		m_CurrentTeam.SlotDefensiveTargetChanged(m_ClientCharacter.GetDefensiveTarget());
		
		m_CurrentTeam.SignalDefensiveTargetLocked.Connect(SlotDefensiveTargetLocked, this);
		m_CurrentTeam.SignalDefensiveTargetDocked.Connect(SlotDefensiveTargetDocked, this);
		m_CurrentTeam.SignalTeamWindowLocked.Connect(SlotTeamWindowLocked, this);
		m_CurrentTeam.SignalSizeChanged.Connect(SlotTeamSizeChanged, this);
		m_CurrentTeam.SignalTeamMoved.Connect(SlotTeamMoved, this);
		m_CurrentTeam.SignalFocusTargetSet.Connect(SlotFocusTargetSet, this);
		m_CurrentTeam.SignalTargetRollOut.Connect(SlotTargetRollOut, this);
		m_CurrentTeam.SignalMemberRollOver.Connect(SlotMemberRollOver, this);
		
		if (m_TeamWindowPosition == undefined){ m_TeamWindowPosition = new Point(0, Stage.height * 0.30); }
		m_CurrentTeam._x = m_TeamWindowPosition.x;
		m_CurrentTeam._y = m_TeamWindowPosition.y;
				
		if (m_RaidArchive != undefined)
		{
			m_CurrentTeam.SetIsMinimized(m_RaidArchive.FindEntry("TeamWindowMinimized", false), true);
		}
		
		if(m_DefensiveTargetClip != undefined)
		{
			m_DefensiveTargetClip.ShowTeamMenuButton(false);
			m_DefensiveTargetClip.SetIsLocked(m_DefensiveTargetLocked);
			SlotTeamSizeChanged();
		}
	}
}

//Slot Client Left Team
function SlotClientLeftTeam():Void
{
    UpdateRaidArchive();
    
    if (m_CurrentTeam != undefined)
    {
		m_TeamWindowPosition.x = m_CurrentTeam._x;
		m_TeamWindowPosition.y = m_CurrentTeam._y;
		m_CurrentTeam.SignalDefensiveTargetLocked.Disconnect(SlotDefensiveTargetLocked, this);
		m_CurrentTeam.SignalDefensiveTargetDocked.Disconnect(SlotDefensiveTargetDocked, this);
		m_CurrentTeam.SignalTeamWindowLocked.Disconnect(SlotTeamWindowLocked, this);
        m_CurrentTeam.Remove();
        m_CurrentTeam.removeMovieClip();
        m_CurrentTeam = undefined;
		if (m_DefensiveTargetClip != undefined)
		{
			m_DefensiveTargetClip.ShowTeamMenuButton(true);
		}		
    }
	if (m_Team != undefined)
	{
		m_Team = undefined;
	}
	SlotTeamSizeChanged();
}

//Slot Client Joined Raid
function SlotClientJoinedRaid(raid:Raid):Void
{
    ClearRaid();
    
    m_CurrentRaid = attachMovie("RaidClip", "raid", getNextHighestDepth());
	m_CurrentRaid._xscale = m_CurrentRaid._yscale = m_RaidScaleMonitor.GetValue();
    m_CurrentRaid.SetRaid(raid);
    
    if (m_RaidArchive != undefined)
    {
		m_RaidPosition = m_RaidArchive.FindEntry("RaidPosition");
		m_CurrentRaid.SetShowWindow(m_RaidArchive.FindEntry("ShowRaidWindow", true));
        if (m_ClientCharacter.GetPlayfieldID() == ProjectUtils.GetUint32TweakValue(PVP_PLAYFIELD_ID_GAMETWEAK))
        {
            m_CurrentRaid.SetWindowFrameLocked(m_RaidArchive.FindEntry(PVP_WINDOW_FRAME_LOCKED, true), false);
            m_CurrentRaid.SetShowWindowFrame(m_RaidArchive.FindEntry(PVP_SHOW_WINDOW_FRAME, true), false);
            m_CurrentRaid.SetShowGroupNames(m_RaidArchive.FindEntry(PVP_SHOW_GROUP_NAMES, true));
            m_CurrentRaid.SetWindowSize(m_RaidArchive.FindEntry(PVP_WINDOW_SIZE, RaidClip.SIZE_AUTO));
            m_CurrentRaid.SetMenuAlignment(m_RaidArchive.FindEntry(PVP_WINDOW_ALIGNMENT, RaidClip.MENU_ALIGNMENT_RIGHT));
            m_CurrentRaid.SetShowHPNumbers(m_RaidArchive.FindEntry(PVP_SHOW_HP_NUMBERS, true),false);
            m_CurrentRaid.SetShowHealthBar(m_RaidArchive.FindEntry(PVP_SHOW_HEALTH_BAR, true), false);
            m_CurrentRaid.SetShowNametagIcons(m_RaidArchive.FindEntry(PVP_SHOW_NAMETAG_ICONS, false), false);
            m_CurrentRaid.SetIsGroupDetached(m_RaidArchive.FindEntry(PVP_IS_GROUP_DETACHED, false), false);
			m_CurrentRaid.SetNumberOfColumns(m_RaidArchive.FindEntry(PVP_NUMBER_OF_COLUMNS, 5), false);
        }
        else
        {
            m_CurrentRaid.SetWindowFrameLocked(m_RaidArchive.FindEntry(WINDOW_FRAME_LOCKED, true), false);
            m_CurrentRaid.SetShowWindowFrame(m_RaidArchive.FindEntry(SHOW_WINDOW_FRAME, true), false);
            m_CurrentRaid.SetShowGroupNames(m_RaidArchive.FindEntry(SHOW_GROUP_NAMES, true));
            m_CurrentRaid.SetWindowSize(m_RaidArchive.FindEntry(WINDOW_SIZE, RaidClip.SIZE_AUTO));
            m_CurrentRaid.SetMenuAlignment(m_RaidArchive.FindEntry(WINDOW_ALIGNMENT, RaidClip.MENU_ALIGNMENT_RIGHT));
            m_CurrentRaid.SetShowHPNumbers(m_RaidArchive.FindEntry(SHOW_HP_NUMBERS, true),false);
            m_CurrentRaid.SetShowHealthBar(m_RaidArchive.FindEntry(SHOW_HEALTH_BAR, true), false);
            m_CurrentRaid.SetShowNametagIcons(m_RaidArchive.FindEntry(SHOW_NAMETAG_ICONS, false), false);
            m_CurrentRaid.SetIsGroupDetached(m_RaidArchive.FindEntry(IS_GROUP_DETACHED, false), false);
            m_CurrentRaid.SetNumberOfColumns(m_RaidArchive.FindEntry(NUMBER_OF_COLUMNS, 5), false);
        }
		m_CurrentRaid.SlotDefensiveTargetChanged(m_ClientCharacter.GetDefensiveTarget());
    }
    
    if (m_RaidPosition == undefined)
    {
        var startPosition:Point = new Point();
        startPosition.x = Stage["visibleRect"].x + Stage["visibleRect"].width - 300;
        startPosition.y = 45;
        m_RaidPosition = startPosition;
    }
    	
    m_CurrentRaid._x = m_RaidPosition.x;
    m_CurrentRaid._y = m_RaidPosition.y;
	
	m_CurrentRaid.SignalFocusTargetSet.Connect(SlotFocusTargetSet, this);
	m_CurrentRaid.SignalTargetRollOut.Connect(SlotTargetRollOut, this);
	m_CurrentRaid.SignalMemberRollOver.Connect(SlotMemberRollOver, this);
    
    CapRaidPosition();
}

function SlotDefensiveTargetLocked(lock:Boolean):Void
{
	m_DefensiveTargetLocked = lock;
	m_DefensiveTargetClip.SetIsLocked(m_DefensiveTargetLocked);
	m_CurrentTeam.SetIsDefensiveLocked(m_DefensiveTargetLocked);
	if (!m_DefensiveTargetLocked)
	{
		SlotDefensiveTargetDocked(false);
	}
}

function SlotDefensiveTargetDocked(dock:Boolean):Void
{
	m_DefensiveTargetDocked = dock;
	m_CurrentTeam.SetIsDefensiveDocked(m_DefensiveTargetDocked);
	if (m_DefensiveTargetDocked)
	{
		SlotDefensiveTargetLocked(true);
	}
	SlotTeamSizeChanged();
}

function SlotTeamWindowLocked(lock:Boolean):Void
{
	m_TeamWindowLocked = lock;
	m_CurrentTeam.SetIsLocked(m_TeamWindowLocked);
}

//Update Raid Archive
function UpdateRaidArchive():Void
{
	if (m_RaidArchive == undefined)
    {
        m_RaidArchive = new Archive();
    }

    if (m_CurrentTeam != undefined)
    {
        m_RaidArchive.ReplaceEntry("TeamWindowMinimized", m_CurrentTeam.GetIsMinimized());
    }
    
    if (m_CurrentRaid != undefined)
    {
		m_RaidPosition.x = m_CurrentRaid._x;
        m_RaidPosition.y = m_CurrentRaid._y;
		m_RaidArchive.ReplaceEntry("RaidPosition", m_RaidPosition);
		
		m_RaidArchive.ReplaceEntry("ShowRaidWindow", m_CurrentRaid.GetShowWindow());
		
        if (m_ClientCharacter.GetPlayfieldID() == ProjectUtils.GetUint32TweakValue(PVP_PLAYFIELD_ID_GAMETWEAK))
        {
            m_RaidArchive.ReplaceEntry(PVP_WINDOW_FRAME_LOCKED, m_CurrentRaid.GetWindowFrameLocked());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_WINDOW_FRAME, m_CurrentRaid.GetShowWindowFrame());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_GROUP_NAMES, m_CurrentRaid.GetShowGroupNames());
            m_RaidArchive.ReplaceEntry(PVP_WINDOW_SIZE, m_CurrentRaid.GetWindowSize());
            m_RaidArchive.ReplaceEntry(PVP_WINDOW_ALIGNMENT, m_CurrentRaid.GetMenuAlignment());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_HP_NUMBERS, m_CurrentRaid.GetShowHPNumbers());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_HEALTH_BAR, m_CurrentRaid.GetShowHealthBar());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_NAMETAG_ICONS, m_CurrentRaid.GetShowNametagIcons());
            m_RaidArchive.ReplaceEntry(PVP_IS_GROUP_DETACHED, m_CurrentRaid.GetIsGroupDetached());
            m_RaidArchive.ReplaceEntry(PVP_NUMBER_OF_COLUMNS, m_CurrentRaid.GetNumberOfColumns());
        }
        else
        {
            m_RaidArchive.ReplaceEntry(WINDOW_FRAME_LOCKED, m_CurrentRaid.GetWindowFrameLocked());
            m_RaidArchive.ReplaceEntry(SHOW_WINDOW_FRAME, m_CurrentRaid.GetShowWindowFrame());
            m_RaidArchive.ReplaceEntry(SHOW_GROUP_NAMES, m_CurrentRaid.GetShowGroupNames());
            m_RaidArchive.ReplaceEntry(WINDOW_SIZE, m_CurrentRaid.GetWindowSize());
            m_RaidArchive.ReplaceEntry(WINDOW_ALIGNMENT, m_CurrentRaid.GetMenuAlignment());
            m_RaidArchive.ReplaceEntry(SHOW_HP_NUMBERS, m_CurrentRaid.GetShowHPNumbers());
            m_RaidArchive.ReplaceEntry(SHOW_HEALTH_BAR, m_CurrentRaid.GetShowHealthBar());
            m_RaidArchive.ReplaceEntry(SHOW_NAMETAG_ICONS, m_CurrentRaid.GetShowNametagIcons());
            m_RaidArchive.ReplaceEntry(IS_GROUP_DETACHED, m_CurrentRaid.GetIsGroupDetached());
            m_RaidArchive.ReplaceEntry(NUMBER_OF_COLUMNS, m_CurrentRaid.GetNumberOfColumns());
        }
    }
}

//Slot Client Left Raid
function SlotClientLeftRaid():Void
{    
	UpdateRaidArchive();
    ClearRaid();
}

function ClearRaid():Void
{
    if (m_CurrentRaid != undefined)
    {        
        m_CurrentRaid.Remove();
        m_CurrentRaid.removeMovieClip();
        m_CurrentRaid = undefined;
    }    
}

function SlotDefensiveTargetMonitorChanged():Void
{
	SlotDefensiveTargetChanged(m_ClientCharacter.GetDefensiveTarget());
}

//Slot Defensive Target Changed
function SlotDefensiveTargetChanged(targetID:ID32):Void
{
    var currentTarget:ID32 = undefined;
    var teamIndex = -1;
    if (m_MouseOverTargeting.GetValue() == 2)
	{
		if (!m_DoNotFocus)
		{
			m_FocusTarget = targetID;
			if (m_CurrentRaid != undefined)
			{
				m_CurrentRaid.SetFocusTarget(targetID);
			}
			if (m_CurrentTeam != undefined)
			{
				m_CurrentTeam.SetFocusTarget(targetID);
			}
		}
		m_DoNotFocus = false;
	}
	
    if (m_DefensiveTargetClip != undefined)
    {
        currentTarget = m_DefensiveTargetClip.GetID()
		if (currentTarget.Equal(targetID))
		{
			//No need to switch to the target we already have
			return;
		}
		if (m_DefensiveTargetPosition == undefined)
		{ 
			if(m_CurrentTeam != undefined)
			{
				m_DefensiveTargetPosition = new Point(0, m_CurrentTeam._y + m_CurrentTeam._height);
			}
			else
			{
				m_DefensiveTargetPosition = new Point(0, Stage.height * 0.30);
			}
		}
		m_DefensiveTargetPosition.x = m_DefensiveTargetClip._x;
		m_DefensiveTargetPosition.y = m_DefensiveTargetClip._y;
        
		m_DefensiveTargetClip.removeMovieClip();
		m_DefensiveTargetClip = undefined;
    }

    if (!targetID.IsNull() && Boolean(m_EnableDefensiveTargetWindowMonitor.GetValue()))
    {
        var character:Character = Character.GetCharacter(targetID);
        m_DefensiveTargetClip = attachMovie("TeamMember", "m_DefensiveTarget" , getNextHighestDepth());
		m_DefensiveTargetClip._xscale = m_DefensiveTargetClip._yscale = m_DefensiveTargetScaleMonitor.GetValue();
        m_DefensiveTargetClip.SetCharacter(character);
        m_DefensiveTargetClip.SetLayoutState(TeamMember.STATE_LARGE);
        m_DefensiveTargetClip.SetIsDefensiveTarget(true);
		if(m_CurrentTeam == undefined)
		{
			m_DefensiveTargetClip.ShowTeamMenuButton(true);
		}
		if (m_DefensiveTargetDocked && m_CurrentTeam != undefined) //Dock defensive target
		{
			var position:Point = new Point(m_CurrentTeam._x, m_CurrentTeam._y + m_CurrentTeam._height);
			m_DefensiveTargetClip._x = position.x;
			m_DefensiveTargetClip._y = position.y;
			m_DefensiveTargetClip.SetIsLocked(true);
		}
		else
		{
			if (m_DefensiveTargetPosition == undefined)
			{ 
				if(m_CurrentTeam != undefined)
				{
					m_DefensiveTargetPosition = new Point(m_CurrentTeam._x, m_CurrentTeam._y + m_CurrentTeam._height);
				}
				else
				{
					m_DefensiveTargetPosition = new Point(0, Stage.height * 0.30);
				}
			}
			m_DefensiveTargetClip._x = m_DefensiveTargetPosition.x;
			m_DefensiveTargetClip._y = m_DefensiveTargetPosition.y;
			if(m_DefensiveTargetLocked == undefined){ m_DefensiveTargetLocked = true; }
			m_DefensiveTargetClip.SetIsLocked(m_DefensiveTargetLocked);
		}
		m_DefensiveTargetClip.SignalDefensiveTargetLocked.Connect(this, SlotDefensiveTargetLocked);
    }
	if (m_CurrentTeam != undefined)
	{
		m_CurrentTeam.SlotDefensiveTargetChanged(targetID);
	}
	if (m_CurrentRaid != undefined)
	{
		m_CurrentRaid.SlotDefensiveTargetChanged(targetID);
	}
}

function SlotTeamSizeChanged():Void
{
	if (m_DefensiveTargetDocked && m_DefensiveTargetClip != undefined)
	{
		var position:Point = new Point(m_CurrentTeam._x, m_CurrentTeam._y + m_CurrentTeam._height);
		m_DefensiveTargetClip._x = position.x;
		m_DefensiveTargetClip._y = position.y;
	}
}

function SlotTeamMoved():Void
{
	SlotTeamSizeChanged();
}

function SlotFocusTargetSet(targetID:ID32):Void
{
	if (m_MouseOverTargeting.GetValue() == 2)
	{
		m_FocusTarget = targetID;
		if (m_CurrentRaid != undefined)
		{
			m_CurrentRaid.SetFocusTarget(targetID);
		}
		if (m_CurrentTeam != undefined)
		{
			m_CurrentTeam.SetFocusTarget(targetID);
		}
	}
}

function SlotTargetRollOut():Void
{
	if (m_MouseOverTargeting.GetValue() == 2)
	{
		if (m_FocusTarget != undefined && !m_FocusTarget.IsNull())
		{
			TargetingInterface.SetTarget(m_FocusTarget);
		}
	}
}

function SlotMemberRollOver(memberID:ID32):Void
{
	if (m_MouseOverTargeting.GetValue() != 0)
	{
		if (m_MouseOverTargeting.GetValue() == 2)
		{
			m_DoNotFocus = true;
		}
		TargetingInterface.SetTarget(memberID);
	}
}

//Resize
function Resize():Void
{
    _x = Stage["visibleRect"].x;
    _y = Stage["visibleRect"].y;
    
    var scale:Number = m_ResolutionScaleMonitor.GetValue();
    _xscale = Math.round(scale * 100);
    _yscale = Math.round(scale * 100);
	
	m_CurrentTeam._xscale = m_CurrentTeam._yscale = m_TeamScaleMonitor.GetValue();
	m_CurrentRaid._xscale = m_CurrentRaid._yscale = m_RaidScaleMonitor.GetValue();
	m_DefensiveTargetClip._xscale = m_DefensiveTargetClip._yscale = m_DefensiveTargetScaleMonitor.GetValue();

    CapRaidPosition();
}

//Cap Raid Position
function CapRaidPosition():Void
{
    if (m_CurrentRaid != undefined)
    {
        if (m_CurrentRaid._x < 0)
        {
            m_CurrentRaid._x = 0;
        }
        
        var maxPosX:Number = Stage.width * 100 / _xscale - m_CurrentRaid._width;
        if (m_CurrentRaid._x > maxPosX)
        {
            m_CurrentRaid._x = maxPosX;
        } 
        
        if (m_CurrentRaid._y < 40)
        {
            m_CurrentRaid._y = 40;
        }
        
        var maxPosY:Number = Stage.height * 100 / _yscale - m_CurrentRaid._height;
        if (m_CurrentRaid._y > maxPosY)
        {
            m_CurrentRaid._y = maxPosY;
        }
    }
    
    m_CurrentRaid._x = Math.round(m_CurrentRaid._x);
    m_CurrentRaid._y = Math.round(m_CurrentRaid._y);
}

//Slot Team Invite
function SlotTeamInvite(inviterID:ID32, inviterName:String):Void
{
	if (m_Team != undefined)
	{
		m_InviteDialogIF = new com.GameInterface.DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "AllowJoinGroup"), inviterName), Enums.StandardButtons.e_ButtonsYesNo, "JoinTeam");
	}
	else
	{
    	m_InviteDialogIF = new com.GameInterface.DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "JoinTeamWith"), inviterName), Enums.StandardButtons.e_ButtonsYesNo, "JoinTeam");
	}
    m_InviteDialogIF.SignalSelectedAS.Connect(SlotTeamInviteSelected, this)
    m_InviteDialogIF.Go(inviterID);
    m_InviteDialogIF.SignalSelectedAS.Connect(SlotTeamInviteSelected, this)
}

//Slot Team Invite
function SlotPromptJoinRequest(inviterID:ID32, inviterName:String):Void
{
    m_InviteDialogIF = new com.GameInterface.DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "PromptJoinRequest"), inviterName), Enums.StandardButtons.e_ButtonsYesNo, "JoinTeam");
    m_InviteDialogIF.SignalSelectedAS.Connect(SlotJoinRequestSelected, this)
    m_InviteDialogIF.Go(inviterID);
    m_InviteDialogIF.SignalSelectedAS.Connect(SlotJoinRequestSelected, this)
}

//Slot Invite Time Out
function SlotInviteTimedOut():Void
{
    if (m_InviteDialogIF != undefined)
    {
        m_InviteDialogIF.Close();
        m_InviteDialogIF = null;
    }
}

//Slot Team Invite Selected
function SlotTeamInviteSelected(buttonID:Number, inviterID:ID32):Void
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        TeamInterface.AcceptTeamInvite(inviterID);
    }
    else
    {
        TeamInterface.DeclineTeamInvite(inviterID);
    }
}

//Slot Team Invite Selected
function SlotJoinRequestSelected(buttonID:Number, inviterID:ID32):Void
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        TeamInterface.SendJoinRequest(inviterID);
    }
}

//Slot Raid Invite
function SlotRaidInvite(inviterID:ID32, inviterName:String):Void
{
    m_InviteDialogIF = new com.GameInterface.DialogIF("Join raid with " + inviterName, Enums.StandardButtons.e_ButtonsYesNo, "JoinTeam");
    m_InviteDialogIF.SignalSelectedAS.Connect(SlotRaidInviteSelected, this)
    m_InviteDialogIF.Go(inviterID);
}

//Slot Raid Invite Selected
function SlotRaidInviteSelected(buttonID:Number, inviterID:ID32):Void
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        TeamInterface.AcceptRaidInvite(inviterID);
    }
    else
    {
        TeamInterface.DeclineRaidInvite(inviterID);
    }
}

//Slot Show Vote Kick Reason Prompt
function SlotShowVoteKickReasonPrompt(targetID:ID32, targetName:String):Void
{
	if (m_VoteKickPrompt != undefined)
	{
		m_VoteKickPrompt.removeMovieClip();
		m_VoteKickPrompt = undefined;
	}
	m_VoteKickPrompt = attachMovie("VoteKickPromptWindow", "m_VoteKickPrompt", this.getNextHighestDepth());
	m_VoteKickPrompt.SetTarget(targetID, targetName);
}
