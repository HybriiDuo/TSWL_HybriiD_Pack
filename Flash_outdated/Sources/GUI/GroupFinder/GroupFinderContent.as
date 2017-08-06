import com.Components.WindowComponentContent;
import com.Components.FCButton;
import com.GameInterface.GroupFinder;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Game.Team;
import com.GameInterface.Game.Raid;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Playfield;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.GUIModuleIF;
import com.Utils.LDBFormat;
import com.Utils.Archive;
import gfx.controls.Button;
import gfx.controls.CheckBox;
import mx.utils.Delegate;
import GUI.GroupFinder.GroupFinderScrollPanel;

class GUI.GroupFinder.GroupFinderContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_Header:MovieClip;
	private var m_AvailableQueuesLabel:TextField;
	private var m_SelectRolesLabel:TextField;
	private var m_TankRole:FCButton;
	private var m_DPSRole:FCButton;
	private var m_HealRole:FCButton;
	private var m_SignUpLeaveButton:Button;
	private var m_ScrollPanel:GroupFinderScrollPanel;
	private var m_SelectPanelBG:MovieClip;
	private var m_SelectedDescription:TextField;
	private var m_SelectedTitle:TextField;
	private var m_BonusSymbol:MovieClip;
	private var m_SkipQueueLabel:TextField;
	private var m_SkipQueueCheckBox:CheckBox;

	//Variables
	private var m_RoleButtonArray:Array;
	private var m_SelectedMedia:MovieClip;
	private var m_Team:Team;
	private var m_Raid:Raid;
	private var m_ReadyPromptMonitor:DistributedValue;
	private var m_TooltipText:String;
	private var m_Tooltip:TooltipInterface;
	private var m_TooltipTimeout:Number;
	private var m_IsQueuedForPvP:Boolean;

	//Statics
	private static var TDB_AVAILABLE_QUEUES:String = LDBFormat.LDBGetText("GroupSearchGUI", "AvailableQueues");
	private static var TDB_QUEUE_STATUS:String = LDBFormat.LDBGetText("GroupSearchGUI", "QueueStatus");
	private static var TDB_NOT_QUEUED:String = LDBFormat.LDBGetText("GroupSearchGUI", "NotQueued");	
	private static var TDB_JOINING_QUEUE:String = LDBFormat.LDBGetText("GroupSearchGUI", "JoiningQueue");	
	private static var TDB_QUEUED:String = LDBFormat.LDBGetText("GroupSearchGUI", "Queued");
	private static var TDB_ACTIVE:String = LDBFormat.LDBGetText("GroupSearchGUI", "Active");	
	private static var TDB_ERROR_ALREADY_QUEUED:String = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorAlreadyQueued");
	private static var TDB_ERROR_PENDING_QUEUE:String = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorPendingQueue");
	private static var TDB_ERROR_NOT_LEADER:String = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorNotLeader");
	private static var TDB_PREFERRED_ROLES:String = LDBFormat.LDBGetText("GroupSearchGUI", "ViewRoleMessage");
	private static var TDB_SKIP_QUEUE:String = LDBFormat.LDBGetText("GroupSearchGUI", "SkipQueue");
    private static var TANK_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonTooltip");
    private static var DPS_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonTooltip");
    private static var HEALER_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonTooltip");
	private static var SIGN_UP:String = LDBFormat.LDBGetText("GroupSearchGUI", "signUp");
	private static var LEAVE:String = LDBFormat.LDBGetText("GroupSearchGUI", "leave");
	
	private static var ROLE_PADDING = 5;
	private static var SELECT_PANEL_PADDING = 10;
	
	private static var SHAMBALA_ID = 5830;
	
	public function GroupFinderContent()
	{
		super();
	}
	
	private function configUI():Void
	{
		m_SkipQueueCheckBox.disableFocus = true;
		m_SkipQueueCheckBox.addEventListener("click", this, "SkipQueueCheckboxClicked");
		m_RoleButtonArray = new Array(m_TankRole, m_DPSRole, m_HealRole);
		for (var i:Number = 0; i < m_RoleButtonArray.length; i++)
        {
            m_RoleButtonArray[i].toggle = true;
            m_RoleButtonArray[i].disableFocus = true;
            m_RoleButtonArray[i].selected = false;
            m_RoleButtonArray[i].addEventListener("click", this, "RoleButtonClickHandler");
        }
		
		if (GroupFinder.IsClientSignedUp())
		{
			var rolesSignedUp:Array = GroupFinder.GetRolesSignedUp();
			for (var i:Number = 0; i < rolesSignedUp.length; i++)
			{
				if (rolesSignedUp[i] == _global.Enums.LFGRoles.e_RoleTank){ m_TankRole.selected = true; }
				if (rolesSignedUp[i] == _global.Enums.LFGRoles.e_RoleDamage){ m_DPSRole.selected = true; }
				if (rolesSignedUp[i] == _global.Enums.LFGRoles.e_RoleHeal){ m_HealRole.selected = true; }
			}
			m_TankRole.disabled = true;
			m_DPSRole.disabled = true;
			m_HealRole.disabled = true;
		}
		
		m_BonusSymbol.onRollOver = m_BonusSymbol.onDragOver = Delegate.create(this, BonusSymbolRollOverHandler);
		m_BonusSymbol.onRollOut = m_BonusSymbol.onDragOut = Delegate.create(this, BonusSymbolRollOutHandler);
		
        m_SignUpLeaveButton.disableFocus = true;
		m_SignUpLeaveButton.addEventListener("click", this, "SignUpLeaveClickHandler");
		
		m_ReadyPromptMonitor = DistributedValue.Create("groupFinder_readyPrompt");
		m_ReadyPromptMonitor.SignalChanged.Connect(SlotReadyPromptStatusChanged, this);
		
		//PvP Playfields - these are special
		//Use the PvP Queue system, not the group finder
		var shambalaPlayfield:Playfield = new Playfield();
		shambalaPlayfield.m_Name = LDBFormat.LDBGetText("Playfieldnames", SHAMBALA_ID);
		shambalaPlayfield.m_InstanceId = 5830;
		shambalaPlayfield.m_Difficulty = [_global.Enums.LFGDifficulty.e_Mode_Normal];
		shambalaPlayfield.m_Image = 9300216;
		shambalaPlayfield.m_Queues = [0];
		var pvpPlayfields:Array = [shambalaPlayfield];

		m_ScrollPanel.SetData(GroupFinder.m_DungeonPlayfields, GroupFinder.m_RaidPlayfields, GroupFinder.m_ScenarioPlayfields, pvpPlayfields);
		m_ScrollPanel.SignalEntryToggled.Connect(SlotEntryToggled, this);
		m_ScrollPanel.SignalEntryFocused.Connect(SlotEntryFocused, this);
		
		GroupFinder.SignalClientJoinedGroupFinder.Connect(SlotClientJoinedGroupFinder, this);
		GroupFinder.SignalClientLeftGroupFinder.Connect(SlotClientLeftGroupFinder, this);	
		GroupFinder.SignalClientStartedGroupFinderActivity.Connect(SlotClientStartedGroupFinderActivity, this);
		if (GroupFinder.IsClientSignedUp())
		{
			SlotClientJoinedGroupFinder();
		}
		
		m_IsQueuedForPvP = false;
		PvPMinigame.SignalYouAreInMatchMaking.Connect(SlotYouAreInMatchMaking, this);
        PvPMinigame.SignalNoLongerInMatchMaking.Connect(SlotNoLongerInMatchMaking, this);
        PvPMinigame.RequestIsInMatchMaking();
		
		TeamInterface.SignalClientJoinedTeam.Connect(SlotClientJoinedTeam, this);
    	TeamInterface.SignalClientLeftTeam.Connect(SlotClientLeftTeam, this);		
		TeamInterface.SignalClientJoinedRaid.Connect(SlotClientJoinedRaid, this);
		TeamInterface.SignalClientLeftRaid.Connect(SlotClientLeftRaid, this);
		m_Team = TeamInterface.GetClientTeamInfo();
		m_Raid = TeamInterface.GetClientRaidInfo();		
		if (m_Team != undefined)
		{
			m_Team.SignalNewTeamLeader.Connect(SlotLeaderChanged, this);
		}
		ir (m_Raid != undefined)
		{
			m_Raid.SignalNewRaidLeader.Connect(SlotLeaderChanged, this);
			m_ScrollPanel.DisableNonRaidContent(true);
		}
		
		SlotLeaderChanged(); //Even if we aren't in a team, this will update the signup state
		SetLabels();
		Layout();
	}
	
	private function SetLabels():Void
	{
		UpdateHeaderText();
		m_AvailableQueuesLabel.text = TDB_AVAILABLE_QUEUES;
		m_SelectRolesLabel.text = TDB_PREFERRED_ROLES + ":";
		m_SelectRolesLabel.autoSize = "left";
		
		m_SkipQueueLabel.text = TDB_SKIP_QUEUE;
		m_SkipQueueLabel.autoSize = "right";
		
		m_TankRole.SetTooltipMaxWidth(250);
		m_DPSRole.SetTooltipMaxWidth(250);
		m_HealRole.SetTooltipMaxWidth(250);
		m_TankRole.SetTooltipText(TANK_BUTTON_TOOLTIP);
        m_DPSRole.SetTooltipText(DPS_BUTTON_TOOLTIP);
        m_HealRole.SetTooltipText(HEALER_BUTTON_TOOLTIP);
		
		UpdateSignUpLeaveButtonText();
		//TODO: Some default image and text?
		UpdateFocusedEntry(-1, 9136880, false);
	}
	
	private function Layout():Void
	{
		m_TankRole._x = m_SelectRolesLabel._x + m_SelectRolesLabel._width + ROLE_PADDING;
		m_DPSRole._x = m_TankRole._x + m_TankRole._width + ROLE_PADDING;
		m_HealRole._x = m_DPSRole._x + m_DPSRole._width + ROLE_PADDING;
	}
	
	private function UpdateHeaderText():Void
	{
		var queueStatus:String = (m_IsQueuedForPvP || GroupFinder.IsClientSignedUp()) ? TDB_QUEUED : TDB_NOT_QUEUED;
		queueStatus = (PvPMinigame.InPvPPlayfield() || GroupFinder.IsClientActive()) ? TDB_ACTIVE : queueStatus;
		m_Header.m_Text.htmlText = TDB_QUEUE_STATUS + " " + queueStatus;
	}
	
	private function UpdateSignUpLeaveButtonText():Void
	{
		var playfieldID:Number = Character.GetClientCharacter().GetPlayfieldID();
		var signUpLeaveLabel:String = (GroupFinder.IsClientSignedUp() || GroupFinder.IsClientActive() || m_IsQueuedForPvP || playfieldID == SHAMBALA_ID) ? LEAVE : SIGN_UP;
		m_SignUpLeaveButton.label = signUpLeaveLabel;
	}
	
	private function UpdateSignUpLeaveButton():Void
	{
		//Do not let players do anything if the ready prompt is open.
		if (m_ReadyPromptMonitor.GetValue())
		{
			m_SignUpLeaveButton.disabled = true;
			return;
		}
		//Always let players leave if they are signed up or active
		var playfieldID:Number = Character.GetClientCharacter().GetPlayfieldID();
		if (GroupFinder.IsClientSignedUp() || GroupFinder.IsClientActive() || m_IsQueuedForPvP || playfieldID == SHAMBALA_ID)
		{
			m_SignUpLeaveButton.disabled = false;
			return;
		}
		
		//If not signed up, only the raid or group leader can sign up!
		if (m_Raid != undefined)
		{
			if (!TeamInterface.IsClientRaidLeader())
			{
				m_SignUpLeaveButton.disabled = true;
				return;
			}
		}
		if (m_Team != undefined)
		{
			if (!TeamInterface.IsClientTeamLeader())
			{
				m_SignUpLeaveButton.disabled = true;
				return;
			}
		}

		//Check entries to see if they are valid
		var selectedEntries:Array = m_ScrollPanel.GetSelectedEntries();
		if (selectedEntries.length > 0)
		{
			m_SignUpLeaveButton.disabled = false;
			return;
		}
			
		m_SignUpLeaveButton.disabled = true;
	}
	
	private function UpdateFocusedEntry(id:Number, image:Number, isRandom):Void
	{
		CloseTooltip();
		m_SelectedTitle.text = LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_" + id);
		m_SelectedDescription.htmlText = LDBFormat.LDBGetText("GroupSearchGUI", "QueueDescription_" + id);
		if (m_SelectedMedia != undefined)
		{
			m_SelectedMedia.removeMovieClip();
		}
		m_SelectedMedia = this.createEmptyMovieClip("m_SelectedMedia", this.getNextHighestDepth());
        LoadImage(m_SelectedMedia, image);
		m_BonusSymbol._visible = isRandom;
		m_TooltipText = isRandom ? LDBFormat.LDBGetText("GroupSearchGUI", "QueueReward_" + id) : undefined;
		m_SelectedMedia.swapDepths(m_BonusSymbol);
	}
	
	private function LoadImage(container:MovieClip, mediaId:Number)
    {
		var imageLoader:MovieClipLoader = new MovieClipLoader();
        
        var path = com.Utils.Format.Printf( "rdb:%.0f:%.0f", _global.Enums.RDBID. e_RDB_GUI_Image, mediaId );
	
		imageLoader.addListener( this );
		imageLoader.loadClip( path, container );
    }
	
	private function onLoadInit( target:MovieClip )
    {
        target._y = m_SelectedTitle._y + m_SelectedTitle._height + SELECT_PANEL_PADDING;
        
        var imagePadding:Number = 4
        var h:Number = target._height;
        var w:Number = target._width;
        
        target.lineStyle(2, 0xFFFFFF);
        target.moveTo( -imagePadding, -imagePadding);
        target.lineTo( w + imagePadding, -imagePadding);
        target.lineTo( w + imagePadding, h + imagePadding);
        target.lineTo( -imagePadding, h + imagePadding);
        target.lineTo( -imagePadding, -imagePadding);
        
        target._x = m_SelectedTitle._x + m_SelectedTitle._width/2 - target._width/2;
		
		m_BonusSymbol._x = target._x + target._width - m_BonusSymbol._width - 10;
		m_BonusSymbol._y = target._y + target._height - m_BonusSymbol._height - 15;
		
		m_SelectedDescription._y = target._y + target._height + SELECT_PANEL_PADDING;
		m_SelectedDescription._height = m_SelectPanelBG._y + m_SelectPanelBG._height - m_SelectedDescription._y + SELECT_PANEL_PADDING;
    }
	
	private function SlotEntryFocused(id:Number, image:Number, isRandom):Void
	{
		UpdateFocusedEntry(id, image, isRandom);
	}
	
	private function SlotEntryToggled():Void
	{
		UpdateSignUpLeaveButton();
	}
	
	private function SlotClientJoinedTeam(team:Team):Void
	{
		m_Team = team;
		m_Team.SignalNewTeamLeader.Connect(SlotLeaderChanged, this);
		SlotLeaderChanged();
	}
	
	private function SlotClientLeftTeam():Void
	{
		m_Team.SignalNewTeamLeader.Disconnect(SlotLeaderChanged, this);
		m_Team = undefined;
		SlotLeaderChanged();
	}
	
	private function SlotClientJoinedRaid(raid:Raid):Void
	{
		m_Raid = raid;
		m_Raid.SignalNewRaidLeader.Connect(SlotLeaderChanged, this);
		m_ScrollPanel.DisableNonRaidContent(true);
		SlotLeaderChanged();
	}
	
	private function SlotClientLeftRaid():Void
	{
		m_Raid.SignalNewRaidLeader.Disconnect(SlotLeaderChanged, this);
		m_Raid = undefined;
		m_ScrollPanel.DisableNonRaidContent(false);
		SlotLeaderChanged();
	}
	
	private function SlotLeaderChanged():Void
	{
		//Don't care who the leader is if we are already signed up.
		if (GroupFinder.IsClientSignedUp())
		{			
			return;
		}
		var isLeader:Boolean = true;
		if (m_Raid != undefined)
		{
			isLeader = TeamInterface.IsClientRaidLeader();
		}
		else if (m_Team != undefined)
		{
			isLeader = TeamInterface.IsClientTeamLeader();
		}
		if(isLeader)
		{
			m_ScrollPanel.DisableAllEntries(false, TDB_ERROR_NOT_LEADER);
			m_TankRole.disabled = false;
			m_DPSRole.disabled = false;
			m_HealRole.disabled = false;
		}
		else
		{			
			m_ScrollPanel.DisableAllEntries(true, TDB_ERROR_NOT_LEADER);
		}
		UpdateSignUpLeaveButton();
	}
	
	private function SkipQueueCheckboxClicked():Void
	{
		m_ScrollPanel.SetPrivateTeam(m_SkipQueueCheckBox.selected);
		SlotLeaderChanged();
	}
	
	private function SlotYouAreInMatchMaking(mapID:Number, joinAsGroup:Boolean)
	{
		m_IsQueuedForPvP = true;
		UpdateSignUpLeaveButtonText();
		UpdateSignUpLeaveButton();
		UpdateHeaderText()
	}
	
	private function SlotNoLongerInMatchMaking(playfieldId:Number)
	{
		m_IsQueuedForPvP = false;
		UpdateSignUpLeaveButtonText();
		UpdateSignUpLeaveButton();
		UpdateHeaderText()
	}
	
	private function SlotClientJoinedGroupFinder():Void
	{
		UpdateSignUpLeaveButtonText();
		UpdateSignUpLeaveButton();
		UpdateHeaderText();
		SetRoles(GroupFinder.GetRolesSignedUp());
		m_ScrollPanel.DisableAllEntries(true, TDB_ERROR_ALREADY_QUEUED);
		m_TankRole.disabled = true;
		m_HealRole.disabled = true;
		m_DPSRole.disabled = true;
	}
	
	private function SlotClientLeftGroupFinder():Void
	{
		UpdateSignUpLeaveButtonText();
		UpdateHeaderText();
		SlotLeaderChanged();
		m_TankRole.disabled = false;
		m_HealRole.disabled = false;
		m_DPSRole.disabled = false;
	}
	
	private function SlotClientStartedGroupFinderActivity():Void
	{
		Close();
	}
	
	private function SlotReadyPromptStatusChanged():Void
	{
		UpdateSignUpLeaveButton();
	}
	
	private function RoleButtonClickHandler():Void
	{
		UpdateSignUpLeaveButton();
	}
	
	private function SignUpLeaveClickHandler():Void
	{
		var playfieldID:Number = Character.GetClientCharacter().GetPlayfieldID();
		if (GroupFinder.IsClientSignedUp() || GroupFinder.IsClientActive() || m_IsQueuedForPvP || playfieldID == SHAMBALA_ID)
		{
			GroupFinder.ClearSignUp();
			PvPMinigame.LeaveMatch();
			PvPMinigame.RemoveFromMatchMaking(SHAMBALA_ID);
		}
		else
		{
			var selectedActivities = new Array();
			var selectedPvP = new Array();
			var selectedEntries:Array = m_ScrollPanel.GetSelectedEntries();
			for (var i:Number=0; i<selectedEntries.length; i++)
			{
				if (selectedEntries[i].m_Id == SHAMBALA_ID)
				{
					selectedPvP.push(selectedEntries[i].m_Id);
				}
				else
				{
					selectedActivities.push(selectedEntries[i].m_Id);
				}
			}
			
			if (selectedPvP.length > 0)
			{
				for (var i:Number = 0; i < selectedPvP.length; i++)
				{
					var allRoles:Number = _global.Enums.Class.e_Damage + _global.Enums.Class.e_Tank + _global.Enums.Class.e_Heal;
					PvPMinigame.SignUpForMinigame(selectedPvP[i], allRoles, false, true); //3rd parameter is join as group, this may change in the future
				}
            	Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_PvP_sign_in.xml");
			}
			
			if (selectedActivities.length > 0)
			{
				//This saves the current role selection for the prompt
				var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GroupFinder" );
				moduleIF.StoreConfig(BuildArchive());
				
				//Sign Up
				var skipQueue:Boolean = m_SkipQueueCheckBox.selected;
				GroupFinder.SignUp(selectedActivities, skipQueue);			
			
				//Disable the GUI until this comes back with a success or failure!
				m_ScrollPanel.DisableAllEntries(true, TDB_ERROR_PENDING_QUEUE);
				m_SignUpLeaveButton.disabled = true;
				m_Header.m_Text.htmlText = TDB_QUEUE_STATUS + " " + TDB_JOINING_QUEUE;
			}
		}
	}
	
	public function SetRoles(rolesArray:Array):Void
	{
		for (var i:Number = 0; i < rolesArray.length; i++)
		{
			if (rolesArray[i] == _global.Enums.LFGRoles.e_RoleTank){m_TankRole.selected = true;}
			if (rolesArray[i] == _global.Enums.LFGRoles.e_RoleDamage){m_DPSRole.selected = true;}
			if (rolesArray[i] == _global.Enums.LFGRoles.e_RoleHeal){m_HealRole.selected = true;}
		}
	}
	
	public function BuildArchive():Archive
	{
		var archive:Archive = new Archive();
		var selectedRoles:Array = new Array();
		if (m_TankRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleTank);}
		if (m_DPSRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleDamage);}
		if (m_HealRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleHeal);}
		for (var i:Number = 0; i < selectedRoles.length; i++)
        {
            archive.AddEntry("SelectedRoles", selectedRoles[i]);
        }
		return archive;
	}
	
	public function Close():Void
	{
		CloseTooltip();
		_parent._parent.CloseWindowHandler();
	}
	
	//TOOLTIP STUFF
	//******************************************************************		
	private function BonusSymbolRollOverHandler():Void
	{
		if (m_TooltipText != undefined && m_TooltipText != "")
		{
			StartTooltipTimeout();
		}
	}
	
	private function BonusSymbolRollOutHandler():Void
	{
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