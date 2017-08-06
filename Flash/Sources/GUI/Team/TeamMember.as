//Imports
import com.Components.Buffs;
import com.Components.NameBox;
import com.Components.StatBar;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.TargetingInterface;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.ProjectUtils;
import com.GameInterface.NeedGreed;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Utils.ID32;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import flash.geom.Point;
import mx.utils.Delegate;
import GUI.Team.DefensiveMenu;

//Class
class GUI.Team.TeamMember extends MovieClip
{
    //Constants
    public static var STATE_SMALL:Number = 0;
    public static var STATE_MEDIUM:Number = 1;
    public static var STATE_LARGE:Number = 2;
    
	public static var MEMBER_COLOR:Number = 0xD3A308;
	public static var STANDARD_COLOR:Number = 0xCCCCCC;
	public static var MEMBER_UNTARGET_ALPHA:Number = 25;
	public static var STANDARD_UNTARGET_ALPHA:Number = 25;
    
    public var ROLE_NONE:Number = -2;
    public var ROLE_TANK:Number;
    public var ROLE_HEALER:Number;
    public var ROLE_DPS:Number;
    public var ROLE_SUPPORT:Number;
	public var DEATH_BUFF:Number = 9212298;

    private static var LARGE_SIZE:Number = 235;
    private static var MEDIUM_SIZE:Number = 201;
    private static var SMALL_SIZE:Number = 120;

    //Properties
    public var SignalSizeChanged:Signal;
	public var SignalFocusTargetSet:Signal;
	public var SignalTargetRollOut:Signal;
	public var SignalMemberRollOver:Signal;
	public var SignalDefensiveTargetLocked:Signal;
	public var SignalDefensiveTargetMoved:Signal;
	public var SignalTeamMoved:Signal;
    
    private var m_TeamMemberWidth:Number;    
    
    private var m_Background:MovieClip;
	private var m_InvisibleButton:MovieClip;
	private var m_MenuButton:MovieClip;
    private var m_SelectedForMoveBackground:MovieClip;
    private var m_Name:MovieClip;
    private var m_HealthBar:MovieClip;
    private var m_Buffs:MovieClip;
    private var m_RoleIcon:MovieClip;
    private var m_LeaderIcon:MovieClip;
    private var m_RaidLeaderIcon:MovieClip;
    private var m_MasterLooterIcon:MovieClip;
	private var m_DeathOverlay:MovieClip;
	private var m_FocusIcon:MovieClip;
    
    private var m_HasBuffs:Boolean;
    
    private var m_PaddingSmall:Number;

    private var m_LastReportedSize:Point 
    private var m_TeamRoleIconPos:Point;
    private var m_TeamRoleIconScale:Number;
    
    private var m_GroupElement:GroupElement;
    private var m_Character:Character;
    private var m_Interval:Number;
    private var m_IsLastMember:Boolean;
    private var m_BackgroundVisible:Boolean;
    private var m_IsTarget:Boolean;
    private var m_IsInRaid:Boolean;
    private var m_IsTeamLeader:Boolean;
    private var m_IsRaidLeader:Boolean;
	private var m_IsLocked:Boolean;
	private var m_IsMember:Boolean;

    private var m_IsDefensiveTarget:Boolean;
    private var m_ShowHealthBar:Boolean;
    private var m_ShowHPNumbers:Boolean;
    private var m_LayoutState:Number
    private var m_TeamMemberRole:Number;
	
	private var m_IsMenuOpen:Boolean;
	private var m_DefensiveMenu:DefensiveMenu;
	
	private var m_ShowBuffsOnTeam:DistributedValue;
	private var m_ShowBuffsOnDefensiveTarget:DistributedValue;
	private var m_MouseOverTargeting:DistributedValue;

    //Constructor
    public function TeamMember()
    {
		m_ShowBuffsOnTeam = DistributedValue.Create("ShowBuffsOnTeam");
		m_ShowBuffsOnDefensiveTarget = DistributedValue.Create("ShowBuffsOnDefensiveTarget");
		m_MouseOverTargeting = DistributedValue.Create("MouseOverTargeting");
		
        SignalSizeChanged = new Signal();
		SignalFocusTargetSet = new Signal();
		SignalTargetRollOut = new Signal();
		SignalMemberRollOver = new Signal();
		SignalDefensiveTargetLocked = new Signal();
		SignalDefensiveTargetMoved = new Signal();
		SignalTeamMoved = new Signal();
		
        m_TeamRoleIconPos = new Point(0,0);
        m_TeamRoleIconScale = 100;
        m_TeamMemberWidth = LARGE_SIZE;
        
        m_LastReportedSize = new Point();
        
        ROLE_TANK = ProjectUtils.GetUint32TweakValue("GroupFinder_Tank_Buff");
        ROLE_HEALER = ProjectUtils.GetUint32TweakValue("GroupFinder_Healer_Buff");
        ROLE_DPS = ProjectUtils.GetUint32TweakValue("GroupFinder_DamageDealer_Buff");
        ROLE_SUPPORT = ProjectUtils.GetUint32TweakValue("PvP_Armor_Support_Buff");
        
        m_IsTarget = false;
        m_LayoutState = STATE_LARGE
        m_IsLastMember = false;
        m_IsInRaid = false;
        m_IsTeamLeader = false;
        m_IsRaidLeader = false;
        m_TeamMemberRole = ROLE_NONE;
		m_IsMenuOpen = false;
        
        var y:Number = 0;
        var x:Number = 12;

        m_Name = attachMovie("NameBox", "name", getNextHighestDepth());
		m_Name.SetShowLevel(true);
        m_Name.UseUpperCase(false);
        m_Name.Init();
        m_Name._x = x;
        m_Name._y = y;
        
        y += m_Name._height + 5;
        
        m_ShowHealthBar = true;
        m_ShowHPNumbers = true;
		
		var nonTargetAlpha = m_IsMember ? MEMBER_UNTARGET_ALPHA : STANDARD_UNTARGET_ALPHA;
		m_Background.m_Fill._alpha = 0;
		m_Background.m_Stroke._alpha = nonTargetAlpha;
        m_Background.onPress = function(){}
        
        y += 15;
        
        m_SelectedForMoveBackground._visible = false;
        
        AddBuffs(x, y);
        
        NeedGreed.SignalLootModeChanged.Connect(SlotLootModeChanged,this);
    }

    private function SlotLootModeChanged(groupLootMode:Number):Void
    {
        Layout();
    }
    
    //Add Health Bar
    public function AddHealthBar(x:Number, y:Number):Void
    {
        if (m_HealthBar == undefined)
        {
            m_HealthBar = attachMovie("HealthBar2", "health", getNextHighestDepth());
            m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_NUMBER);
			
			m_HealthBar.swapDepths(m_InvisibleButton);
            
            if (m_Character != undefined)
            {
                m_HealthBar.SetDynel(m_Character);
            }
            else if (m_GroupElement != undefined)
            {
                m_HealthBar.SetGroupElement(m_GroupElement);
            }
        }
        
        m_HealthBar._x = x;
        m_HealthBar._y = y;
    }
    
    //Add Buffs
    public function AddBuffs(x:Number, y:Number, scale:Number):Void
    {
		var showBuffs:Boolean = Boolean(m_ShowBuffsOnTeam.GetValue());
		if (m_IsDefensiveTarget)
		{
			showBuffs = Boolean(m_ShowBuffsOnDefensiveTarget.GetValue());
		}
		if (showBuffs)
		{
			if (!m_HasBuffs)
			{
				m_HasBuffs = true;
				m_Buffs = attachMovie("Buffs", "buffs", getNextHighestDepth());
				m_Buffs.SetDirectionDown();
				m_Buffs.SetMaxPerLine(4);
				
				m_Buffs.ShowCharges(true);
				m_Buffs.ShowTimers(true);
				m_Buffs.SetMultiline(false);
	
				m_Buffs.SizeChanged.Connect(SlotBuffSizeChanged, this);
				//m_Buffs.SignalBuffAdded.Connect(SlotBuffCountUpdated, this);
				//m_Buffs.SignalBuffRemoved.Connect(SlotBuffCountUpdated, this);
				
				if (m_Character != undefined)
				{
					m_Buffs.SetCharacter(m_Character);
				}
				else if (m_GroupElement != undefined)
				{
					m_Buffs.SetGroupElement(m_GroupElement);
				}
			}
			
			m_Buffs._x = x;
			m_Buffs._y = y;
			
			if (!isNaN(scale))
			{
				m_Buffs._xscale = scale;
				m_Buffs._yscale = scale;
			}        
			
			m_Buffs.swapDepths(this.getNextHighestDepth());
		}
    }
    
    //Remove Buffs
    public function RemoveBuffs():Void
    {
        m_HasBuffs = false;
        
        if (m_Buffs != undefined)
        {
            m_Buffs.SetCharacter(undefined);
            m_Buffs.SetGroupElement(undefined);
            m_Buffs.removeMovieClip();
            m_Buffs = undefined;
        }

    }
    
    //Slot Buff Count Updated
    private function SlotBuffSizeChanged():Void
    {
		var X:Number = this._width;
		var Y:Number = this._height;
		Layout();
		if (this._width != X || this._height != Y)
        {
            SignalSizeChanged.Emit();
        }
    }
    
    private function SlotMarkForTeamMove(id:ID32):Void
    {
        if (m_IsInRaid && !id.IsNull() && GetID().Equal(id) )
        {
            m_SelectedForMoveBackground._visible = true;
        }
    }
    
    private function SlotUnmarkForTeamMove(id:ID32):Void
    {
        if (m_GroupElement && !id.IsNull() && m_GroupElement.m_CharacterId.Equal(id))
        {
            m_SelectedForMoveBackground._visible = false;
        }
    }
	
	private function AddTeamLeaderIcon():Void
	{
		if (m_IsTeamLeader && !m_IsRaidLeader)
        {
            if (m_LeaderIcon == undefined )
            {
                m_LeaderIcon = attachMovie("TeamLeaderIcon", "leaderIcon", getNextHighestDepth());
            }
            
            var xpos:Number = (m_HealthBar != undefined) ? m_HealthBar._x : 5;
            
            m_LeaderIcon._xscale = m_TeamRoleIconScale;
            m_LeaderIcon._yscale = m_TeamRoleIconScale;
            m_LeaderIcon._x = xpos;
            m_LeaderIcon._y = 3;

            m_Name._x = xpos + m_LeaderIcon._width + 2;
        }
        else
        {
            if (m_LeaderIcon != undefined )
            {
                m_Name._x = m_LeaderIcon._x;
                m_LeaderIcon.removeMovieClip();
                m_LeaderIcon = undefined;
            }
        }
        
        if (m_IsRaidLeader)
        {
            if (m_RaidLeaderIcon == undefined )
            {
                m_RaidLeaderIcon = attachMovie("RaidLeaderIcon", "raidLeaderIcon", getNextHighestDepth());
            }
            var xpos:Number = (m_HealthBar != undefined) ? m_HealthBar._x : 5;
           
            m_RaidLeaderIcon._xscale = m_TeamRoleIconScale;
            m_RaidLeaderIcon._yscale = m_TeamRoleIconScale;
            m_RaidLeaderIcon._x = xpos;
            m_RaidLeaderIcon._y = 3;

            m_Name._x = xpos + m_RaidLeaderIcon._width + 2;
        }
        else
        {
            if (m_RaidLeaderIcon != undefined )
            {
				m_Name._x = m_RaidLeaderIcon._x;
                m_RaidLeaderIcon.removeMovieClip();
                m_RaidLeaderIcon = undefined;
            }
        }
        
        if (!m_RaidLeaderIcon && !m_LeaderIcon)
        {
            m_Name._x = xpos;
        }
	}
	
	private function AddMasterLooterIcon():Void
	{
		var charId:ID32 = (m_Character)?m_Character.GetID():m_GroupElement.m_CharacterId;
        var isMasterLooter:Boolean = NeedGreed.IsMasterLooter(charId);
        if ( isMasterLooter )
        {
            if (m_MasterLooterIcon == undefined)
            {
                m_MasterLooterIcon = attachMovie("MasterLooterIcon", "masterLooterIcon", getNextHighestDepth());
                //Master Looter tooltip
                TooltipUtils.AddTextTooltip( m_MasterLooterIcon, LDBFormat.LDBGetText("MiscGUI", "GroupLootMode_2"), 20, TooltipInterface.e_OrientationHorizontal,  true);
            }
            
            m_MasterLooterIcon._xscale = m_TeamRoleIconScale;
            m_MasterLooterIcon._yscale = m_TeamRoleIconScale;
            m_MasterLooterIcon._x = m_Background._width - m_MasterLooterIcon._width;
            m_MasterLooterIcon._y = 3;
        }
        else
        {
            if (m_MasterLooterIcon != undefined )
            {
                m_MasterLooterIcon.removeMovieClip();
                m_MasterLooterIcon = undefined;
            }
        }
	}
    
    //Add Team Member Roll Icon
    private function AddTeamMemberRoleIcon() : Boolean
    {        
        UpdateRoleBuff();
        if (m_RoleIcon.type != m_TeamMemberRole || m_TeamMemberRole == undefined)
        {
            if (m_RoleIcon != undefined)
            {
                m_RoleIcon.removeMovieClip();
                m_RoleIcon = undefined;
            }
            
            if (m_TeamMemberRole == ROLE_TANK)
            {
                m_RoleIcon = attachMovie("RoleIconTank", "m_RoleIconTank", getNextHighestDepth());
            }
            else if (m_TeamMemberRole == ROLE_DPS)
            {
                m_RoleIcon = attachMovie("RoleIconDPS", "m_RoleIconDPS", getNextHighestDepth());
            }
            else if (m_TeamMemberRole == ROLE_HEALER)
            {
                m_RoleIcon = attachMovie("RoleIconHeal", "m_RoleIconHeal", getNextHighestDepth());
            }
            else if (m_TeamMemberRole == ROLE_SUPPORT)
            {
                m_RoleIcon = attachMovie("RoleIconSupport", "m_RoleIconSupport", getNextHighestDepth());
            }
        }

        if (m_RoleIcon != undefined)
        {
            m_RoleIcon.type = m_TeamMemberRole;
            m_RoleIcon._xscale = m_TeamRoleIconScale;
            m_RoleIcon._yscale = m_TeamRoleIconScale;
            m_RoleIcon._x = m_TeamMemberWidth - m_RoleIcon._width - 5;
            
            if (m_Name != undefined)
            {                
                m_Name.SetMaxWidth( m_RoleIcon._x - m_Name._x); 
            }
            m_RoleIcon._y = 5;
            
            return true;
        }
        
        return false;
    }
	
	private function UpdateDeathDisplay():Void
	{
		//Reset the state to default
		if (this.m_Name != undefined)
		{
			this.m_Name._alpha = 100;
		}
		if (this.m_HealthBar != undefined)
		{
			this.m_HealthBar._alpha = 100;
		}
		if (this.m_Buffs != undefined)
		{
			this.m_Buffs._alpha = 100;
		}
		if (m_DeathOverlay != undefined)
		{
			m_DeathOverlay.removeMovieClip();
		}
		//Apply the death overlay if needed
		if (!m_IsDefensiveTarget)
		{
			var character:Character = m_Character;
			if (character == undefined)
			{
				character = Dynel.GetDynel(m_GroupElement.m_CharacterId);
			}
			if (character.m_BuffList[DEATH_BUFF] != undefined || character.m_InvisibleBuffList[DEATH_BUFF] != undefined)
			{
				if (this.m_Name != undefined)
				{
					this.m_Name._alpha = 25;
				}
				if (this.m_HealthBar != undefined)
				{
					this.m_HealthBar._alpha = 25;
				}
				if (this.m_Buffs != undefined)
				{
					this.m_Buffs._alpha = 25;
				}
				m_DeathOverlay = this.attachMovie("DeathOverlay", "m_DeathOverlay", this.getNextHighestDepth());
				m_DeathOverlay._x = m_Background._x + 1;
				m_DeathOverlay._y = m_Background._y + 1;
				m_DeathOverlay.m_Background._width = this.m_Background._width - 4;
				m_DeathOverlay.m_Background._height = this.m_Background._height - 4;
				switch(m_LayoutState)
				{
					case STATE_LARGE:	m_DeathOverlay.m_Icon._xscale = m_DeathOverlay.m_Icon._yscale = 100;
										break;
										
					case STATE_MEDIUM:	m_DeathOverlay.m_Icon._xscale = m_DeathOverlay.m_Icon._yscale = 75;
										break;
										
					case STATE_SMALL:	m_DeathOverlay.m_Icon._xscale = m_DeathOverlay.m_Icon._yscale = 50;
										break;
				}
				m_DeathOverlay.m_Icon._x = m_DeathOverlay.m_Background._width/2 - m_DeathOverlay.m_Icon._width/2;
				m_DeathOverlay.m_Icon._y = 10;
				
				//For movement of menu
				m_DeathOverlay.onPress = function() { };
				m_DeathOverlay.onRollOver = Delegate.create(this, OnRollOver);
				m_DeathOverlay.onRollOut = Delegate.create(this, OnRollOut);
				m_DeathOverlay.onMousePress = Delegate.create(this, SlotMousePress);
				m_DeathOverlay.onMouseUp = Delegate.create(this, SlotMouseRelease);
			}
		}
	}

    
    //Toggle Background Visibility
    private function ToggleBackgroundVisibility():Void
    {
        m_BackgroundVisible = !m_BackgroundVisible;
        m_Background._alpha = (m_BackgroundVisible ? 100 : 0);
    }
    
    //Layout
    public function Layout():Void
    {
        var ypos:Number;
        
        clear();
        
        if (m_LayoutState == STATE_SMALL)
        {
            ypos = 25;
            
            m_Name.SetMaxWidth(110);
            m_Name._y = 4
            m_Name._xscale = 85;
            m_Name._yscale = 85;
            
            m_TeamRoleIconScale = 85;
            
			AddTeamLeaderIcon();
			AddMasterLooterIcon();
            var hasIcon:Boolean = AddTeamMemberRoleIcon();

            if (m_ShowHealthBar)
            {
                AddHealthBar(8, ypos);
                
                m_HealthBar.SetBarScale(36, 50, 50, 100);
                m_HealthBar.SetShowText(m_ShowHPNumbers);
                m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_PERCENT);
				m_HealthBar.SetShieldsOnTop(true);
                
                ypos += 12;
            }
            else
            {
                m_HealthBar.Hide();
            }

            if (m_HasBuffs)
            {
                RemoveBuffs();
            }
            
            ypos += 5
        }

        else if (m_LayoutState == STATE_MEDIUM)
        {
            ypos = 25
            
            m_Name.SetMaxWidth(180);
            m_Name._y = 2;
            
            m_TeamRoleIconScale = 90;
            
			AddTeamLeaderIcon();
			AddMasterLooterIcon();
            var hasIcon:Boolean = AddTeamMemberRoleIcon();

            if (m_ShowHealthBar)
            {
                
                AddHealthBar(15, ypos);
                
                m_HealthBar.SetBarScale(58, 58, 60, 100);
                m_HealthBar.SetShowText(m_ShowHPNumbers);
                m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_NUMBER);
				m_HealthBar.SetShieldsOnTop(true);
                
                ypos += 15
            }
            else
            {
                m_HealthBar.Hide();
            }

            if (m_HasBuffs)
            {
                RemoveBuffs();
            }
            
            ypos += 17

        }
        
        else if (m_LayoutState == STATE_LARGE)
        {
            ypos = 23
            m_Name.SetMaxWidth(220);
            m_TeamRoleIconScale = 100;
			
			AddTeamLeaderIcon();
			AddMasterLooterIcon();
            var hasIcon:Boolean = AddTeamMemberRoleIcon();

            if (m_ShowHealthBar)
            {
                AddHealthBar(15, ypos);
                
                m_HealthBar.SetBarScale(70, 70, 70, 100);
                m_HealthBar.SetShowText(m_ShowHPNumbers);
                m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_NUMBER);
				m_HealthBar.SetShieldsOnTop(true);
                
                ypos += 14;
            }
            else
            {
                m_HealthBar.Hide();
            }

            AddBuffs(10, ypos, 60);
            
			if (m_HasBuffs)
			{
				var buffSize:Number = m_Buffs._height + 1;
				
				ypos += (m_Buffs.GetBuffCount() > 0) ? buffSize : 15;
			}
			else
			{
				ypos += 15;
			}

            break;
        }
        
        m_Background._height = ypos;
        m_Background._width = m_TeamMemberWidth;
		
		UpdateDeathDisplay();
        
        m_SelectedForMoveBackground._height = ypos
        m_SelectedForMoveBackground._width = m_TeamMemberWidth;

        if (m_Buffs != undefined)
        {
            m_Buffs.SetWidth((m_TeamMemberWidth-20) * 100 / 50);
        }
		
		m_InvisibleButton._x = m_Background._x;
		m_InvisibleButton._y = m_Background._y;
		m_InvisibleButton._width = m_Background._width;
		m_InvisibleButton._height = m_Background._height;
		m_InvisibleButton.onPress = function() { };
		m_InvisibleButton.onRollOver = Delegate.create(this, OnRollOver);
		m_InvisibleButton.onRollOut = Delegate.create(this, OnRollOut);
		m_InvisibleButton.onMousePress = Delegate.create(this, SlotMousePress);
		m_InvisibleButton.onMouseUp = Delegate.create(this, SlotMouseRelease);
        
        m_LastReportedSize.x = this._width;
        m_LastReportedSize.y = this._height;
    }
	
	public function UpdateFocusTarget(targetID:ID32):Void
	{
		if (!m_IsDefensiveTarget)
		{
			if (m_FocusIcon != undefined)
			{
				m_FocusIcon.removeMovieClip();
			}
			if (m_GroupElement != undefined && m_GroupElement.m_CharacterId.Equal(targetID))
			{
				m_FocusIcon = attachMovie("FocusIndicator", "m_FocusIcon", this.getNextHighestDepth());
				m_FocusIcon._x = m_Background._x;
				m_FocusIcon._y = m_Background._y;
				if (m_IsMember)
				{
					com.Utils.Colors.ApplyColor(m_FocusIcon, MEMBER_COLOR);
				}
			}
			else if (m_Character != undefined && m_Character.GetID().Equal(targetID))
			{
				m_FocusIcon = attachMovie("FocusIndicator", "m_FocusIcon", this.getNextHighestDepth());
				m_FocusIcon._x = m_Background._x;
				m_FocusIcon._y = m_Background._y;
				if (m_IsMember)
				{
					com.Utils.Colors.ApplyColor(m_FocusIcon, MEMBER_COLOR);
				}
			}
		}
	}
	
	public function OnRollOver():Void
	{
		if (m_MouseOverTargeting.GetValue() != 0)
		{
			if (!m_IsDefensiveTarget && !m_IsTarget)
			{
				if (m_GroupElement != undefined)
				{
					if (m_GroupElement.m_OnClient)
					{
						SignalMemberRollOver.Emit(m_GroupElement.m_CharacterId);
					}
				}
				else if (m_Character != undefined)
				{
					SignalMemberRollOver.Emit(m_Character.GetID());
				}
			}
		}
	}
	
	public function OnRollOut():Void
	{
		if (m_MouseOverTargeting.GetValue() != 0)
		{
			if (!m_IsDefensiveTarget && m_IsTarget)
			{
				SignalTargetRollOut.Emit();
			}
		}
	}
    
    //On Mouse Release
    public function onMouseRelease(buttonIdx:Number):Void
    {
        if (buttonIdx == 1)
        {
            if (m_GroupElement != undefined)
            {
				if (m_GroupElement.m_OnClient)
				{
                	TargetingInterface.SetTarget(m_GroupElement.m_CharacterId);
					if (m_MouseOverTargeting.GetValue() == 2)
					{
						SignalFocusTargetSet.Emit(m_GroupElement.m_CharacterId);
					}
				}
            }
            else if (m_Character != undefined)
            {
                TargetingInterface.SetTarget(m_Character.GetID());
				if (m_MouseOverTargeting.GetValue == 2)
				{
					SignalFocusTargetSet.Emit(m_Character.GetID());
				}
            }
        }
        else if (buttonIdx == 2)
        {
            var characterId:ID32;
            var name:String = "";

            if (m_GroupElement != undefined)
            {
                characterId = m_GroupElement.m_CharacterId;
                name = m_GroupElement.m_Name;
            }
            else if (m_Character != undefined)
            {
                characterId = m_Character.GetID();
                name = m_Character.GetName();
            }

            if (characterId != undefined)
            {
                com.Utils.GlobalSignal.SignalShowFriendlyMenu.Emit(characterId, name, true);
            }           
        }   
    }
	
	private function SlotCharacterEntered():Void
	{
		if (m_Character != undefined)
		{
			m_Character.SignalBuffAdded.Disconnect(SlotBuffAdded, this);
			m_Character.SignalInvisibleBuffAdded.Disconnect(SlotBuffAdded, this);
			m_Character.SignalBuffRemoved.Disconnect(SlotBuffRemoved, this);
			m_Character.SignalBuffUpdated.Disconnect(SlotBuffAdded, this);
		}
		m_Character = Character.GetCharacter(m_GroupElement.m_CharacterId);
		
		m_Character.SignalBuffAdded.Disconnect(SlotBuffAdded, this);
		m_Character.SignalInvisibleBuffAdded.Disconnect(SlotBuffAdded, this);
		m_Character.SignalBuffRemoved.Disconnect(SlotBuffRemoved, this);
		m_Character.SignalBuffUpdated.Disconnect(SlotBuffAdded, this);
		
		m_Character.SignalBuffAdded.Connect(SlotBuffAdded, this);
		m_Character.SignalInvisibleBuffAdded.Connect(SlotBuffAdded, this);
		m_Character.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
		m_Character.SignalBuffUpdated.Connect(SlotBuffAdded, this);
        AddTeamMemberRoleIcon();
		UpdateDeathDisplay();
		
		m_Character.SignalMemberStatusUpdated.Connect(SlotMemberStatusUpdated, this);
		if (m_Character != undefined)
		{
			m_IsMember = m_Character.IsNPC() ? false : m_Character.IsMember();
		}
		else
		{
			m_IsMember = m_GroupElement.m_IsMember;
		}
		UpdateMembershipStatus();
	}
	
	private function SlotMemberStatusUpdated(member:Boolean):Void
	{
		m_IsMember = member;
		UpdateMembershipStatus();
	}
	
	private function UpdateMembershipStatus():Void
	{
		if (m_IsMember)
		{
			com.Utils.Colors.ApplyColor(m_Background.m_Stroke, MEMBER_COLOR);
			if (!m_IsTarget){ m_Background.m_Stroke._alpha = MEMBER_UNTARGET_ALPHA; }
			if (m_FocusIcon != undefined)
			{
				com.Utils.Colors.ApplyColor(m_FocusIcon, MEMBER_COLOR);
			}
		}
		else
		{
			com.Utils.Colors.ApplyColor(m_Background.m_Stroke, STANDARD_COLOR);
			if (!m_IsTarget){ m_Background.m_Stroke._alpha = STANDARD_UNTARGET_ALPHA; }
			if (m_FocusIcon != undefined)
			{
				com.Utils.Colors.ApplyColor(m_FocusIcon, STANDARD_COLOR);
			}
		}
	}
	
	private function SlotBuffAdded(buffId:Number):Void
	{
		if (buffId == ROLE_DPS || buffId == ROLE_HEALER || buffId == ROLE_TANK || buffId == ROLE_SUPPORT)
		{
			AddTeamMemberRoleIcon();
		}
		else if (buffId == DEATH_BUFF)
		{
			UpdateDeathDisplay();
		}
	}
	
	private function SlotBuffRemoved(buffId:Number):Void
	{
		if (buffId == ROLE_DPS || buffId == ROLE_HEALER || buffId == ROLE_TANK || buffId == ROLE_SUPPORT)
		{
			AddTeamMemberRoleIcon();
		}
		else if (buffId == DEATH_BUFF)
		{
			UpdateDeathDisplay();
		}
	}
    
    //Filter Roll Buff
    private function UpdateRoleBuff():Void
    {		
		var character:Character = m_Character;
		if (character == undefined)
		{
			character = Dynel.GetDynel(m_GroupElement.m_CharacterId);
		}
		if (character.m_BuffList[ROLE_DPS] != undefined || character.m_InvisibleBuffList[ROLE_DPS] != undefined)
		{
			m_TeamMemberRole = ROLE_DPS;
		}
		else if (character.m_BuffList[ROLE_HEALER] != undefined || character.m_InvisibleBuffList[ROLE_HEALER] != undefined)
		{
			m_TeamMemberRole = ROLE_HEALER;
		}
		else if (character.m_BuffList[ROLE_TANK] != undefined || character.m_InvisibleBuffList[ROLE_TANK] != undefined)
		{
			m_TeamMemberRole = ROLE_TANK;
		}
		else if (character.m_BuffList[ROLE_SUPPORT] != undefined || character.m_InvisibleBuffList[ROLE_SUPPORT] != undefined)
		{
			m_TeamMemberRole = ROLE_SUPPORT;
		}
		else
		{
			m_TeamMemberRole = ROLE_NONE;
		}      
    }
    
    //Is Target
    public function IsTarget():Boolean
    {
        return m_IsTarget;
    }
    
    //Set Is Target
    public function SetIsTarget(isTarget:Boolean):Void
    {
        m_IsTarget = isTarget;
        SetTargetBackground();
    }
    
    //Set Is Defensive Target
    public function SetIsDefensiveTarget(isTarget:Boolean):Void
    {
        m_IsDefensiveTarget = isTarget;
        SetDefensiveTargetBackground();
		if (Boolean(m_ShowBuffsOnDefensiveTarget.GetValue()))
		{
			AddBuffs(12, 55, 60);
		}
		else
		{
			RemoveBuffs();
		}
		if (m_HasBuffs)
		{
			m_Buffs.SetMultiline(true);
		}
    }
    
    //Set Target Background
    private function SetTargetBackground():Void
    {
		var nonTargetAlpha = m_IsMember ? MEMBER_UNTARGET_ALPHA : STANDARD_UNTARGET_ALPHA;
        m_Background._width = m_TeamMemberWidth;
        m_Background.m_Fill._alpha = (m_IsTarget) ? 100 : 0;
		m_Background.m_Stroke._alpha = (m_IsTarget) ? 100 : nonTargetAlpha;
    }

    //Set Pos
    public function SetPos(pos:Number, maxPos:Number):Void
    {
        m_IsLastMember = (pos == maxPos);
    }
    
    //Set Defensive Target background
    private function SetDefensiveTargetBackground():Void
    {
        if (m_IsDefensiveTarget)
        {
            m_Background.m_Fill._alpha = 100;
			m_Background.m_Stroke._alpha = 100;
            m_Background._width = (m_LayoutState == STATE_LARGE) ? m_TeamMemberWidth + 3 : m_TeamMemberWidth;
        }
        else
        {
            SetTargetBackground();
        }
    }
	
	private function SlotMousePress(buttonIndex:Number):Void
	{
		if (buttonIndex == 1 && !m_IsLocked && !m_IsInRaid)
		{
			var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
			var width:Number = getBounds(_root).xMax - getBounds(_root).xMin - 3;
			var height:Number = getBounds(_root).yMax - getBounds(_root).yMin - 10;
			if (m_IsDefensiveTarget)
			{				
				this.startDrag(false, 0, 50, (Stage.width - width) / scale, (Stage.height - height) / scale);
			}
			else
			{
				_parent._parent.startDrag(false, 0, 50, (Stage.width - width) / scale, (Stage.height - height) / scale);
			}
		}
	}
	
	private function SlotMouseRelease():Void
	{
		if (m_IsDefensiveTarget)
		{
			this.stopDrag();
			SignalDefensiveTargetMoved.Emit();
		}
		else
		{
			_parent._parent.stopDrag();
			SignalTeamMoved.Emit();
		}
	}
    
    //Set Layout State
    public function SetLayoutState(state:Number):Void
    {
        m_LayoutState = state;
        
        switch(m_LayoutState)
        {
            case STATE_LARGE:   m_TeamMemberWidth = LARGE_SIZE;
                                break;

            case STATE_MEDIUM:  m_TeamMemberWidth = MEDIUM_SIZE;
                                break;
                                
            case STATE_SMALL:   m_TeamMemberWidth = SMALL_SIZE;
        }
        
        Layout();
    }
    
    //Set Group Element
    public function SetGroupElement(groupElement:GroupElement):Void
    {
        m_GroupElement = groupElement; 
        m_TeamMemberRole = m_GroupElement.m_Role;
        m_Name.SetGroupElement(m_GroupElement);
        
        if (m_Buffs != undefined)
        {
            m_Buffs.SetGroupElement(m_GroupElement);
        }
        
        if (m_HealthBar != undefined)
        {
            m_HealthBar.SetGroupElement(m_GroupElement);
        }
        else
        {
            AddHealthBar(0, 0);
            
            Layout();
        }
		
		m_GroupElement.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
        
        var character:Character = Dynel.GetDynel(m_GroupElement.m_CharacterId)
		character.SignalBuffAdded.Disconnect(SlotBuffAdded, this);
		character.SignalInvisibleBuffAdded.Disconnect(SlotBuffAdded, this);
		character.SignalBuffRemoved.Disconnect(SlotBuffRemoved, this);
		character.SignalBuffUpdated.Disconnect(SlotBuffAdded, this);
		
        character.SignalBuffAdded.Connect(SlotBuffAdded, this);
		character.SignalInvisibleBuffAdded.Connect(SlotBuffAdded, this);
		character.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
		character.SignalBuffUpdated.Connect(SlotBuffAdded, this);
        AddTeamMemberRoleIcon();
		UpdateDeathDisplay();
		
		character.SignalMemberStatusUpdated.Connect(SlotMemberStatusUpdated, this);
		
		if (m_GroupElement.m_OnClient)
		{
			m_IsMember = character.IsNPC() ? false : character.IsMember();
		}
		else
		{
			m_IsMember = m_GroupElement.m_IsMember;
		}
		UpdateMembershipStatus();
        
        TeamInterface.SignalMarkForTeamMove.Connect(SlotMarkForTeamMove,this);
        TeamInterface.SignalUnmarkForTeamMove.Connect(SlotUnmarkForTeamMove, this);
        var characterMarked:ID32 = TeamInterface.GetCharacterMarkedForTeamMove();
        if (!characterMarked.IsNull() && characterMarked.Equal(m_GroupElement.m_CharacterId))
        {
            SlotMarkForTeamMove(TeamInterface.GetCharacterMarkedForTeamMove());
        }
    }
    
    public function DisconnectSignals():Void
    {
        NeedGreed.SignalLootModeChanged.Disconnect(Layout,this);
        TeamInterface.SignalMarkForTeamMove.Disconnect(SlotMarkForTeamMove, this);
        TeamInterface.SignalUnmarkForTeamMove.Disconnect(SlotUnmarkForTeamMove, this);
    }
	
	public function ShowTeamMenuButton(showButton:Boolean):Void
	{
		if(m_MenuButton != undefined)
		{
			m_MenuButton.removeMovieClip();
		}
		if (showButton)
		{
			m_MenuButton = attachMovie("TeamMenuButton", "m_MenuButton", getNextHighestDepth());
			m_MenuButton._x = m_Background._x;
			m_MenuButton._y = m_Background._y - m_MenuButton._height;
			m_MenuButton.onRelease = Delegate.create(this, ToggleGroupMenu);
		}
	}
    
    public function SetIsInRaid(val:Boolean):Void
    {
        m_IsInRaid = val;
    }
    
    //Set Team Leader
    public function SetTeamLeader(value:Boolean):Void
    {
        m_IsTeamLeader = value;
        AddTeamLeaderIcon();
    }
    
    public function SetRaidLeader(value:Boolean):Void
    {
        m_IsRaidLeader = value;
        if (value)
        {
            AddTeamLeaderIcon();
        }
    }
    
    //Get Is Team Leader
    public function GetIsTeamLeader():Boolean
    {
        return m_IsTeamLeader;
    }

    public function GetIsRaidLeader():Boolean
    {
        return m_IsRaidLeader;
    }
    
    //Get Width
    public function GetWidth():Number
    {
        return m_TeamMemberWidth;
    }
    
    //Set Character
    public function SetCharacter(character:Character, forceLayout:Boolean):Void
    {
        m_Character = character;
        
        m_HealthBar.SetDynel(character);
        m_Name.SetDynel(character);
        
        if (m_Buffs != undefined)
        {
            m_Buffs.SetCharacter(character);
        }
        
        if (m_HealthBar != undefined)
        {
            m_HealthBar.SetCharacter(character);
        }
        else
        {
            AddHealthBar(0, 0)
            forceLayout = true;
        }

        if (forceLayout == true)
        {
            Layout();
        }
		m_Character.SignalMemberStatusUpdated.Connect(SlotMemberStatusUpdated, this);
		if (m_Character != undefined)
		{
			m_IsMember = m_Character.IsNPC() ? false : m_Character.IsMember();
		}
		else
		{
			m_IsMember = m_GroupElement.m_IsMember;
		}
		UpdateMembershipStatus();
    }
    
    //Set Show Health Bar
    public function SetShowHealthBar(value:Boolean):Void
    {
        m_ShowHealthBar = value;
    }
    
    //Set Show HP Numbers
    public function SetShowHPNumbers(value:Boolean):Void
    {
        m_ShowHPNumbers = value;
    }
	
	public function SetIsLocked(lock:Boolean):Void
	{
		m_IsLocked = lock;
	}
    
    //Get ID
    public function GetID():ID32
    {
        if (m_GroupElement != undefined)
        {
            return m_GroupElement.m_CharacterId;
        }
        else
        {
            return m_Character.GetID();
        }
    }
	
	//Toggle Group Menu
    private function ToggleGroupMenu():Void
    {
        if (m_IsMenuOpen)
        {
            m_DefensiveMenu.RemoveMenu();
        }
        else
        {
            m_DefensiveMenu = DefensiveMenu(this.attachMovie("DefensiveMenu", "m_DefensiveMenu", this.getNextHighestDepth(), { m_TeamMember: this }));
			m_DefensiveMenu._xscale = 80;
			m_DefensiveMenu._yscale = 80;
			m_DefensiveMenu.SetLockDefensiveWindow(m_IsLocked);
            m_DefensiveMenu.Initialize();
            
            m_DefensiveMenu._y = m_MenuButton._y + m_MenuButton._height;
			m_IsMenuOpen = !m_IsMenuOpen;
        }
    }
	
	public function DefensiveMenuClosed():Void
	{
		m_IsMenuOpen = false;
	}
	
    public function MissedButton():Boolean
    {
        return !m_MenuButton.hitTest(_root._xmouse, _root._ymouse);
    }
	
	public function LockDefensiveWindow(lock:Boolean)
	{
		SignalDefensiveTargetLocked.Emit(lock);
	}	
}