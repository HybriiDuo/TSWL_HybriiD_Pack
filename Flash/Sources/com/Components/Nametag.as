import com.Utils.GlobalSignal;
import flash.filters.GlowFilter;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import flash.geom.Point;
import flash.geom.Matrix;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Nametags;
import com.GameInterface.DistributedValue;
import com.Components.StatBar;
import com.Components.CastBar;
import com.Utils.ID32;
import gfx.core.UIComponent;
import gfx.controls.Label;
import com.Utils.Signal;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;

class com.Components.Nametag extends UIComponent
{
    //private var m_Name:Label;
    private var m_Name:TextField;
    private var m_NameBarArt:MovieClip;
    private var m_Title:MovieClip;
    private var m_Guild:MovieClip;
    private var m_Level:MovieClip;
    private var m_DistanceToNPC:MovieClip;
    private var m_FactionRankIcon:MovieClip;
    private var m_HealthBar:MovieClip;
    private var m_CastBar:MovieClip;
    private var m_MonsterBand:MovieClip;
	private var m_ConLoading:MovieClip;
	private var m_LockedIcon:MovieClip;
	private var m_CinematicIcon:MovieClip;
	private var m_MemberIcon:MovieClip;
    private var m_NpcIcon:MovieClip;
    
    private var m_IsNPC:Boolean;
    private var m_IsSimpleDynel:Boolean;
    private var m_CheckDistance:Boolean;
    private var m_LeftAlignXCollapsed:Number; //X of aligned text/clips
    private var m_LeftAlignXExpanded:Number; //X of aligned text/clips
    private var m_MonsterBandPush:Number;
    private var m_IconTextPadding:Number;
    private var m_Distance:Number;
    private var m_IsTarget:Boolean;
    private var m_AggroStanding:Number;
    private var m_ForceAlive:Boolean;
    private var m_DetailedComponents:Array;
	private var m_IsLocked:Boolean;
    private var m_IsHostileTarget:Boolean;
    private var m_HateListCreated:Boolean; // Used to track if a nametag is added by hatelist add
    
    private var m_ComponentsLoaded:Boolean;
    private var m_ShowHealthBarCollapsed:Boolean;
    private var m_ForceHealthBar:Boolean;
    
    private var m_MaxScale:Number;
    private var m_MinScale:Number;
    private var m_TweenTime:Number;
	
	private var m_DistanceY:Number;

    private var GRADE_NORMAL:Number = 0;
    private var GRADE_SWARM:Number = 1;
    private var GRADE_ELITE:Number = 2;
	
	private var m_HealthBarWidth:Number
    
    private var m_Character:Character;
    private var m_Dynel:Dynel;
    private var m_DynelID:ID32;
    private var m_NametagCategory:Number;
    private var m_NametagColor:Number;
    private var m_NametagIconColor:Number;
	private var m_ClientCharacter:Character;
    private var m_RemoveOnDeselect;
    private var m_TextColor:Number;
    
    public var SignalRemoveNametag:Signal;
    
    public static var SHOW_HEALTHBAR_NONE = 0;
    public static var SHOW_HEALTHBAR_FRIENDS = 1;
    public static var SHOW_HEALTHBAR_ENEMIES = 2;
    public static var SHOW_HEALTHBAR_ALL = 3;

    public static var SHOW_HOSTILE_NAMETAG_NONE = 0;
    public static var SHOW_HOSTILE_NAMETAG_PARTIAL = 1;
    public static var SHOW_HOSTILE_NAMETAG_FULL = 2;

    public function Nametag()
    {
		
        super();
		m_IsLocked = false;
        m_IsNPC = true;
        m_IsSimpleDynel = false;
        m_CheckDistance = true;
        m_DetailedComponents = new Array();
        m_LeftAlignXCollapsed = 0;
        m_LeftAlignXExpanded = 0;
        m_IconTextPadding = 10;
        m_RemoveOnDeselect = false;
        SignalRemoveNametag = new Signal();
        m_NametagCategory = 0;
        m_NametagColor = 0;
        m_Distance = 0;
        m_IsTarget = false;
        m_AggroStanding = -1;
        m_ComponentsLoaded = false;
        m_ShowHealthBarCollapsed = false;
        m_TweenTime = 0.5;
        m_MonsterBandPush = 0;
        m_ForceHealthBar = false;
        m_IsHostileTarget = false;
        m_HateListCreated = false;
		
		m_HealthBarWidth = 121;

        m_ClientCharacter = Character.GetClientCharacter();
        
        m_MaxScale = 140;
        m_MinScale = 60;
                
        m_ClientCharacter.SignalStatChanged.Connect(SlotClientCharacterStatChanged, this);
		_visible = false;
		_alpha = 0;
    }
    
    public function SetDynelID(dynelID:ID32)
    {
        //Connect to the character
        m_DynelID = dynelID;
        m_Dynel = Dynel.GetDynel(dynelID);
            
        if (m_Dynel != undefined)
        {
            m_Dynel.SignalStatChanged.Connect(SlotDynelStatChanged, this);
			m_Dynel.SignalLockedToTarget.Connect(SlotLockedToTarget, this);
            
            m_IsSimpleDynel = dynelID.GetType() != _global.Enums.TypeID.e_Type_GC_Character;
            
            if (!m_IsSimpleDynel)
            {
                m_Character = Character.GetCharacter(dynelID);
                var aggroStanding = com.GameInterface.Nametags.GetAggroStanding(dynelID);
                m_AggroStanding = aggroStanding;
                m_ForceHealthBar = (m_Character.GetStat(_global.Enums.Stat.e_NPCFlags, 2) & 524288) != 0; // e_NPCFlag_ForceFullNametag      = 1<<19,
            }
            
            UpdateNametagCategory();
            
            m_IsNPC = !m_IsSimpleDynel && m_Character.IsNPC();
                        
            m_CheckDistance = m_IsNPC || m_IsSimpleDynel;
            if (!m_IsSimpleDynel)
            {
                m_Character.SignalCharacterDied.Connect(SlotCharacterDied, this);
                m_Character.SignalCharacterAlive.Connect(SlotCharacterAlive, this);
				m_Character.SignalMemberStatusUpdated.Connect(SlotMemberStatusUpdated, this);
            }
            
            //Add healthbar if it should be shown
            var showDefaultHealthBar:Number = DistributedValue.GetDValue("ShowNametagHealthBarDefault", 0)
            m_ShowHealthBarCollapsed = (showDefaultHealthBar == SHOW_HEALTHBAR_FRIENDS && m_Dynel.IsFriend() && !m_Dynel.IsEnemy()) || (showDefaultHealthBar == SHOW_HEALTHBAR_ENEMIES && m_Dynel.IsEnemy()) || (showDefaultHealthBar == SHOW_HEALTHBAR_ALL);

            if (m_ShowHealthBarCollapsed || m_ForceHealthBar)
            {
                if (!m_IsSimpleDynel || m_Dynel.GetStat(_global.Enums.Stat.e_Life) > 0)
                {
                    //Health
                    if (m_HealthBar == undefined)
                    {
                        AddHealthBar();
                    }
                    
                    m_HealthBar._y = m_Name._y + 20;
                    m_HealthBar._x = m_LeftAlignXCollapsed;
                    m_HealthBar._alpha = 100;
                }
            }
            
            UpdateName();
			
			if (m_IsNPC || m_IsSimpleDynel)
			{
				SlotLockedToTarget(m_Dynel.GetLockedTo());
			}
        }
		Update();
    }
	
	public function UpdateCinematicIcon()
	{
		if (m_Character.IsInCinematic() && m_CinematicIcon == undefined)
		{
			m_CinematicIcon = attachMovie("CinematicIcon", "m_CinematicIcon", getNextHighestDepth());
			m_CinematicIcon._xscale = m_CinematicIcon._yscale = 50;
			m_CinematicIcon._y = m_Name._y - m_CinematicIcon._height;
			if(!IsTarget())
			{
				m_CinematicIcon._x = m_LeftAlignXCollapsed + m_Name._width/2 - m_CinematicIcon._width/2;
			}
			else
			{
				m_CinematicIcon._x = m_LeftAlignXExpanded + m_Name._width/2 - m_CinematicIcon._width/2;
			}
		}
		else if (!m_Character.IsInCinematic() && m_CinematicIcon != undefined)
		{
			m_CinematicIcon.removeMovieClip();
			m_CinematicIcon = undefined;
		}
	}
	
	public function UpdateFactionRankIcon()
	{
        return; // Fix me, but we don't plan on displaying faction icons any more

		if (!m_IsSimpleDynel)
		{
			if (m_Character.GetStat(_global.Enums.Stat.e_GmLevel) & _global.Enums.GMFlags.e_ShowGMTag || m_Character.GetStat( _global.Enums.Stat.e_RankTag ) == 0)
			{
				if (m_FactionRankIcon != undefined)
				{
					m_FactionRankIcon.removeMovieClip();
					m_FactionRankIcon = undefined;	
				}
			}
			else
			{
				m_FactionRankIcon = this.createEmptyMovieClip("icon", this.getNextHighestDepth() );
				var factionRankContent:MovieClip = m_FactionRankIcon.createEmptyMovieClip("icon", m_FactionRankIcon.getNextHighestDepth() );
				var currentTag:LoreNode = Lore.GetDataNodeById(m_Character.GetStat( _global.Enums.Stat.e_RankTag ));
				var iconSource = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + currentTag.m_Icon;
				var imageLoaderListener:Object = new Object;
				imageLoaderListener.onLoadInit = function(target:MovieClip)
				{
					target._height = 25;
					target._width = 25;
					target._parent._xscale = 100;
					target._parent._yscale = 100;
				}
				
				var iconLoader:MovieClipLoader = new MovieClipLoader();
				iconLoader.addListener(imageLoaderListener);
				iconLoader.loadClip(iconSource, factionRankContent);
				m_FactionRankIcon._y = 0;
			}
		}
		
		if (m_FactionRankIcon != undefined)
		{
			m_LeftAlignXExpanded = 35 + m_IconTextPadding;
			m_LeftAlignXCollapsed = 15 + m_IconTextPadding;
			
			m_Name._x = m_LeftAlignXCollapsed;
		}
	}
	
	public function UpdateNametagGroupSize(encounterType:Number)
	{
        return; // We don't use this any more. Clean up!
		m_MonsterBand.m_GroupSize.m_Top._visible = false;
		m_MonsterBand.m_GroupSize.m_Bottom._visible = false;
		
		switch(encounterType)
		{
			case _global.Enums.EncounterType.e_EncounterType_SmallGroup:
				m_MonsterBand.m_GroupSize.m_Top._visible = true;
				break;
			case _global.Enums.EncounterType.e_EncounterType_Group:
				m_MonsterBand.m_GroupSize.m_Bottom._visible = true;
				break;
			case _global.Enums.EncounterType.e_EncounterType_Raid:
				m_MonsterBand.m_GroupSize.m_Top._visible = true;
				m_MonsterBand.m_GroupSize.m_Bottom._visible = true;
				break;
		}
	}
    
    public function UpdateNametagMonsterbandColor(isNightmare:Boolean)
    {
        return; // We will probably not use this any more. Clean up
        if (m_MonsterBand != undefined && m_IsNPC)
		{
			var bandColor:Number = 0xFFFFFF;
			if (m_NametagCategory == _global.Enums.NametagCategory.e_NameTagCategory_FriendlyNPC || m_NametagCategory == _global.Enums.NametagCategory.e_NameTagCategory_FriendlyPlayer)
			{
				bandColor = m_NametagColor;
			}
			else
			{
				var monsterBand:Number = m_Dynel.GetStat(_global.Enums.Stat.e_Band);
				var playerBand:Number = m_ClientCharacter.GetStat(_global.Enums.Stat.e_PowerRank);
				var monsterAegisBand:Number = m_Dynel.GetStat(_global.Enums.Stat.e_AegisPowerRank);
				var playerAegisBand:Number = m_ClientCharacter.GetStat(_global.Enums.Stat.e_AegisPowerRank);
				if (monsterAegisBand > 0 && playerAegisBand == 0)
				{
					bandColor = Colors.GetNametagIconColor(3); //Con Red for aegis mobs fighting players with no aegis
				}
				else if (monsterAegisBand > 0 && playerBand < 10)
				{
					bandColor = Colors.GetNametagIconColor(3); //Con Red for sub band 10 players vs aegis enemies
				}
				else if (playerAegisBand > 0 && monsterAegisBand > 0)
				{
					bandColor = Colors.GetNametagIconColor(monsterAegisBand - playerAegisBand); //Use AEGIS band to compare
				}
				else
				{
					bandColor = Colors.GetNametagIconColor(monsterBand - playerBand); //Use normal band to compare
				}
			}
			Colors.ApplyColor(m_MonsterBand.m_GroupSize.m_Top, bandColor);
			Colors.ApplyColor(m_MonsterBand.m_GroupSize.m_Bottom, bandColor);
			if (isNightmare)
			{
				m_MonsterBand.m_Outline._visible = true;
				Colors.ApplyColor(m_MonsterBand.m_Outline, bandColor);
				Colors.ApplyColor(m_MonsterBand.m_Foreground, 0x000000);
			}
			else
			{
				m_MonsterBand.m_Outline._visible = false;
				Colors.ApplyColor(m_MonsterBand.m_Foreground, bandColor);
			}
        }
    }
    
    public function GetDynelID()
    {
        return m_DynelID;
    }
    
    public function GetDistance():Number
    {
        return m_Distance;
    }
    
    public function IsTarget():Boolean
    {
        return  m_IsTarget;
    }
    
    public function configUI()
    {
        super.configUI();
        m_ComponentsLoaded = true;
    }
    
    public function Compare( otherTag:Nametag) : Number
    {
        return otherTag.GetDistance() - m_Distance;
    }
    
    function onEnterFrame()
    {
        Update();
    }
    
    function Update()
    {
		m_Distance = m_Dynel.GetCameraDistance();
		_z = m_Distance;
        if (m_Dynel != undefined && (!m_IsNPC || m_AggroStanding >= 0))
        {
            var shouldShow:Boolean = (!m_CheckDistance || m_Distance < 25 || m_IsTarget) && m_Dynel.IsRendered();


            if ( shouldShow )
            {
                var targetAlpha = m_IsLocked ? 50 : 100;
                if ( _alpha != targetAlpha )
                {
                    _alpha = Math.min(targetAlpha, _alpha + 5);
                }
				if (m_Distance < 20 || m_IsTarget)
				{
					if(m_MonsterBand._alpha == 0 && m_ConLoading._alpha == 0)
					{
						m_ConLoading._alpha = 100;
						m_ConLoading.gotoAndPlay(1);
						
						m_ConLoading.onEnterFrame = function()
						{
							if (this._currentframe == this._totalframes)
							{
								this.stop();
								//This is a hack to avoid this getting called multiple times!
								if(this._parent.m_MonsterBand._alpha <= 0)
								{
									this.tweenTo(0.1, {_alpha:0}, None.easeNone);
									this._parent.m_MonsterBand.tweenTo(0.25, {_xscale:50, _yscale:50, _alpha:100, _x:this._parent.m_MonsterBand._x -2, _y:this._parent.m_MonsterBand._y -2}, None.easeNone);
									this._parent.m_MonsterBand.onTweenComplete = function()
									{
										this._parent.m_MonsterBand.tweenTo(0.25, {_xscale:40, _yscale:40, _x:this._x + 2, _y:this._y + 2}, None.easeNone);
										this._parent.m_MonsterBand.onTweenComplete = undefined;
									}
								}
							}
						}
					}
				}
				else
				{
					if(m_MonsterBand._alpha > 0)
					{
						m_MonsterBand._alpha = 0;
						m_ConLoading.stop();
						m_ConLoading._alpha = 0;
						m_ConLoading.onEnterFrame = function(){ };
					}
				}
            }
            else
            {
                if ( _alpha > 0 )
                {
                    _alpha = Math.max(0, _alpha - 5);
                }
                else
                {
                    return;
                }
            }
            
            var scale:Number = Math.max(m_MinScale, ((1 - (Math.max(m_Distance - 5, 0) / 35)) * m_MaxScale));
            
            _xscale = scale;
            _yscale = scale;
            
            var screenPos:Point = m_Dynel.GetNametagPosition();
            
            var correctWidth:Number = m_Name._width + m_IconTextPadding;
            var correctHeight:Number = m_Name._height + m_IconTextPadding;
            if (m_FactionRankIcon != undefined)
            {
                correctWidth += m_FactionRankIcon._width;
                correctHeight += m_FactionRankIcon._height;
            }
            
            correctWidth *= (scale / 100);
            correctHeight *= (scale / 100);
            
            var newX:Number = screenPos.x - (121/ 2);
            var newY:Number = screenPos.y - (correctHeight / 2);

            if (newX > 0 - correctWidth && newX < Stage.width + correctWidth && newY > 0 - correctHeight && newY < Stage.height + correctHeight)
            {
                _visible = true;
                _x = newX;
                _y = newY;
            }
            else
            {
                _visible = false;
            }
                       
            if ( m_DistanceToNPC != undefined )
            {
                var distance:String = com.Utils.Format.Printf( "%.1f", Math.round(m_Dynel.GetDistanceToPlayer()*10)/10 ) + " m";
                Label(m_DistanceToNPC).text = distance;
            } 
			UpdateCinematicIcon();
        }
    }
                
    function SlotClientCharacterStatChanged(statId:Number)
    {
        if (statId == _global.Enums.Stat.e_PowerRank || 
			statId == _global.Enums.Stat.e_AegisPowerRank ||
			statId == _global.Enums.Stat.e_IsANightmareMob ||
			statId == _global.Enums.Stat.e_GradeType ||
			statId == _global.Enums.Stat.e_EncounterType)
        {
			var isNightmare:Boolean = (m_Character.GetStat(_global.Enums.Stat.e_IsANightmareMob) != 0);
            UpdateNametagMonsterbandColor(isNightmare);
        }
    }
	
	function SlotLockedToTarget(targetID:ID32)
	{
		if (targetID == undefined || targetID.IsNull() || targetID.Equal(m_ClientCharacter.GetID()) || targetID.Equal(TeamInterface.GetClientTeamID()) || targetID.Equal(TeamInterface.GetClientRaidID()))
		{
			m_IsLocked = false;
			m_Name._alpha = 100;
			if (m_HealthBar != undefined)
			{
				m_HealthBar._alpha = 100;
			}
		}
		else
		{
			m_IsLocked = true;
			m_Name._alpha = 40;
			if (m_HealthBar != undefined)
			{
				m_HealthBar._alpha = 40;
			}
		}
	}
	
	function SlotMemberStatusUpdated(member:Boolean)
	{
		SlotDynelStatChanged(_global.Enums.Stat.e_VeteranMonths);
	}
    
    function SlotDynelStatChanged(statID:Number)
    {
        switch(statID)
        {
            case _global.Enums.Stat.e_GmLevel:
            case _global.Enums.Stat.e_PlayerFaction:
            case _global.Enums.Stat.e_Side:
            case _global.Enums.Stat.e_CarsGroup:
            case _global.Enums.Stat.e_RankTag:
			case _global.Enums.Stat.e_VeteranMonths:
                {
					UpdateFactionRankIcon();
                    UpdateNametagCategory();
                    UpdateName();
					SetAsTarget(m_IsTarget);
                }
                break;
            default:
                break;
        }
    }
    
    function SlotCharacterDied()
    {
        // Welcome to the land of hacks
        if (m_Name != undefined)
        {
            //m_HealthBar._alpha = 0;
            m_Name._alpha = 0;
        }
        if (m_HealthBar != undefined)
        {
            m_HealthBar._alpha = 0;
        }
        if (m_Title != undefined)
        {
            m_Title._alpha = 0;
        }
        if (m_Guild != undefined)
        {
            m_Guild._alpha = 0;
        }
        
        //trace("SlotCharacterDied");
        //UpdateNametagCategory();
        //UpdateName();
    }
    
    function SlotCharacterAlive()
    {
        UpdateNametagCategory();
        //Need to force alive as IsDead will still return false, as we are still in limbo state
        m_ForceAlive = true;
        UpdateName();
        m_ForceAlive = false;
    }
    
    function UpdateAggro(aggro:Number)
    {
        m_AggroStanding = aggro;
        UpdateNametagCategory();
    }
    
    function UpdateNametagCategory()
    {
        if (m_Dynel != undefined)
        {
            m_NametagCategory = m_Dynel.GetNametagCategory();
            m_NametagColor = Colors.GetNametagColor(m_NametagCategory, m_AggroStanding);
            
            if (m_Name != undefined)
            {
                m_Name.textColor = m_NametagColor;
            }
            
            if (m_FactionRankIcon != undefined && m_IsNPC)
            {
                Colors.ApplyColor(m_FactionRankIcon, m_NametagColor);
            }
        }
    }
    
    function UpdateName()
    {
        if (m_Dynel != undefined)
        {
            var name:String = "";
            var dynelName:String = LDBFormat.Translate(m_Dynel.GetName());
            
            if ( !m_IsNPC && DistributedValue.GetDValue("ShowNametagFullName", 0) )
            {
                dynelName = m_Character.GetFirstName() + " \"" + dynelName + "\" " + m_Character.GetLastName();
            }
            if (m_Dynel.IsDead() && !m_ForceAlive && m_IsNPC)
            {
                name = m_Dynel.GetStat(_global.Enums.Stat.e_Level) + " - " + LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "CorpseOfMonsterName"), dynelName);
            }
			else
			{
				name = dynelName;
			}
            //var extent:Object = m_Name.getTextFormat().getTextExtent(name);
            
            m_Name.text = name;
            m_Name.textColor = m_NametagColor;
            
            /*if (m_ComponentsLoaded)
            {
                m_Name.width = extent.width + 5;
            }
            else
            {
                m_Name._width = extent.width + 5;
            }*/
        }
    }
    
    public function SetRemoveOnDeselect(remove:Boolean)
    {
        m_RemoveOnDeselect = remove;
    }
    
    public function AddHealthBar()
    {
        if (m_HealthBar != undefined)
        {
            m_HealthBar.removeMovieClip();
        }
		m_HealthBar = attachMovie("HealthBar2", "health", getNextHighestDepth()); 
        m_HealthBar.SetShowText( false );
        m_HealthBar.Show();
        m_HealthBar.SetDynel(m_Character);
        m_HealthBar._alpha = 100;
        m_HealthBar.SetBarScale(40, 40, 40, 60);
		
		m_HealthBarWidth = m_HealthBar._width;
    }
    
    function SetAsTarget(target:Boolean)
    {

        var showHostileNPCNametags:Number = DistributedValue.GetDValue("ShowHostileNPCNametags", 0);
        m_IsTarget = target;
        
        if (target)
        {
            var maxX:Number = 0;
            
            if (m_FactionRankIcon != undefined)
            {
                m_FactionRankIcon.tweenTo(m_TweenTime, { _width:50, _height:50 }, Regular.easeOut);
            }
            
            MovieClip(m_Name).tweenTo(m_TweenTime, { _x:m_LeftAlignXExpanded + m_MonsterBandPush }, Regular.easeOut);
			if (m_CinematicIcon != undefined)
			{
				m_CinematicIcon.tweenTo(m_TweenTime, { _x:m_LeftAlignXExpanded + m_Name._width/2 - m_CinematicIcon._width/2 }, Regular.easeOut);
			}
            
            var y:Number = 16;

			var animateMemberIcon:Number = 0;
            if ( !m_IsSimpleDynel && DistributedValue.GetDValue("ShowNametagTitle", false) )
            {
                //Title
				animateMemberIcon += 10;
				var tag:Number = m_Character.GetStat(_global.Enums.Stat.e_SelectedTag);
                
				if (tag > 0 && tag != undefined)
				{
					var title:String = Lore.GetTagName(tag);
					if (title != undefined && title != "")
					{
						if (m_Title == undefined)
						{
							m_Title = attachMovie("NewTitleLabel", "title", getNextHighestDepth());
							m_Title._alpha = 0;
                            m_Title.m_TitleText.text = title;
                            m_Title.m_TitleText.textColor = 0xFFFFFF;
						}
                        
						m_Title._x = m_LeftAlignXCollapsed;
                        var titleY:Number = m_Name._y - 10;
                        m_Title.tweenTo( m_TweenTime, {_x:m_LeftAlignXExpanded, _alpha: 100, _y: titleY }, Regular.easeOut);
						m_Title.onTweenComplete = null;
						y += 11;
					}
				}
            }

            // Namebar art
            if (m_Title != undefined)
            {
                m_NameBarArt = attachMovie("NameBarArt", "namebarart", getNextHighestDepth());
                m_NameBarArt._x = m_Name._x;
                m_NameBarArt._y = (m_Name._y + m_Name._height / 2);
                m_NameBarArt._yscale = 1;
                m_NameBarArt._alpha = 0;
                m_NameBarArt._xscale = (m_Name._width / m_NameBarArt._width) * 100;
                m_NameBarArt.tweenTo(m_TweenTime, {_alpha: 100, _y: (m_Name._y + 2), _yscale: 100});
            }
            
            if ( !m_IsSimpleDynel && DistributedValue.GetDValue("ShowNametagGuild", false) )
            {
				animateMemberIcon += 10;
                //Guild name
                var guild:String = m_Character.GetGuildName();// .toUpperCase();
                if (guild != undefined && guild != "")
                {
                    guild = "<" + guild + ">";
                    
                    if (m_Guild == undefined)
                    {
                        m_Guild = attachMovie("NewGuildLabel", "guild", getNextHighestDepth());
                        m_Guild._alpha = 0;
                        m_Guild.m_GuildName.text = guild;
                        m_Guild.m_GuildName.textColor = 0xFFFFFF;
                    }
                    
                    m_Guild._x = m_LeftAlignXCollapsed;
                    var guildY:Number = m_Name._y + 18; 
                    m_Guild.tweenTo( m_TweenTime,  {_x:m_LeftAlignXExpanded, _y: guildY, _alpha: 100}, Regular.easeOut);
                    m_Guild.onTweenComplete = null;
                    y += 19;
                }
                else
                {
                    y += 8;
                }
            }
            else
            {
                y += 8;                
            }
            
            //Health Bar
            var showDefaultHealthBar:Number = DistributedValue.GetDValue("ShowNametagHealthBarDefault", 0)
            m_ShowHealthBarCollapsed = (showDefaultHealthBar == SHOW_HEALTHBAR_FRIENDS && m_Dynel.IsFriend() && !m_Dynel.IsEnemy()) || (showDefaultHealthBar == SHOW_HEALTHBAR_ENEMIES && m_Dynel.IsEnemy()) || (showDefaultHealthBar == SHOW_HEALTHBAR_ALL);
            
            if (!m_IsSimpleDynel && (DistributedValue.GetDValue("ShowNametagHealth", false) || m_ShowHealthBarCollapsed))
            {
				animateMemberIcon += 10;
                if (m_HealthBar == undefined)
                {
                    AddHealthBar();
                }
                
                var healthBarY:Number = m_Name._y + 30;
                if (m_Guild == undefined)
                {
                    healthBarY -= 7;
                }
                m_HealthBar.tweenTo( m_TweenTime,  {_x:m_LeftAlignXExpanded, _y: healthBarY, _alpha: 100, _yscale: 150, _xscale: 150}, Regular.easeOut);
                m_HealthBar._x = m_LeftAlignXCollapsed;
                m_HealthBar._alpha = 100;
            }

            // Level display. Attaches to health bar. Will display icon for certain professions
            if (m_HealthBar != undefined)
            {
                var npcIcon:String = "";
                if (m_IsNPC)
                {
                    if (m_Character.IsMerchant())
                    {
                        npcIcon = "VendorIcon";
                    }
                    else if (m_Character.IsBanker())
                    {
                        npcIcon = "TradepostIcon";
                    }
                }

                if (m_Dynel.IsEnemy())
                {
                    if (m_Level != undefined)
                    {
                        m_Level.removeMovieClip();
                    }
                    m_Level = m_HealthBar.attachMovie("LevelCircle_Enemy", "levelcircle", m_HealthBar.getNextHighestDepth());
                }
                else
                {
                    if (m_Level != undefined)
                    {
                        m_Level.removeMovieClip();
                    }
                    m_Level = m_HealthBar.attachMovie("LevelCircle", "levelcircle", m_HealthBar.getNextHighestDepth());
                }

                if (npcIcon != "")
                {
                    m_NpcIcon =  m_Level.attachMovie(npcIcon, "npcIcon", m_Level.getNextHighestDepth());
                    m_NpcIcon._x = 23;
                    m_NpcIcon._y = 16;
                    m_Level.LevelText.m_LevelText._alpha = 0;
                }
                else
                {
                    m_Level.LevelText.m_LevelText.text = m_Dynel.GetStat(_global.Enums.Stat.e_Level);
                    m_Level.LevelText.m_LevelText._alpha = 100;

                    if (m_Character != undefined && m_Character.IsNPC() && m_Dynel.IsEnemy())
                    {
                        var levelDifference:Number = m_Dynel.GetStat(_global.Enums.Stat.e_Level,2) - m_ClientCharacter.GetStat(_global.Enums.Stat.e_Level, 2);
                        var levelColor:Number = 0xFFFFFF;
                        if (levelDifference <= -10) // no attack
                        {
                            levelColor = 0xB88ECD;
                        }
                        else if (levelDifference <= -2) // easy
                        {
                            levelColor = 0x06F6FF;
                            //levelColor = 0x0051CA;
                        }
                        else if (levelDifference <= 0) // equal
                        {
                            levelColor = Colors.e_ColorWhite;
                        }
                        else if (levelDifference <= 2) // Challenging
                        {
                            levelColor = 0xFFF666;
                        }        
                        else // Hard
                        {
                            levelColor = Colors.e_ColorPureRed;
                        }
                        m_Level.LevelText.m_LevelText.textColor = levelColor;
                    }
                }
                m_Level._xscale = 40;
                m_Level._yscale = 40;
                // Positions relative to m_healthbar 0,0
                m_Level._x = -18;
                m_Level._y = -6.5;
                m_Level._alpha = 0;
                m_Level.tweenTo(m_TweenTime, {_alpha: 100}, Regular.easeOut);
                
                // Reusing conloading for fancy effects
                m_ConLoading = m_Level.attachMovie("NewLoadingClock", "NewLoadingClock", m_Level.getNextHighestDepth());
                m_ConLoading._xscale = 30;
                m_ConLoading._yscale = 30;
                // Positions relative to m_Level 0,0
                m_ConLoading._x = 2;
                m_ConLoading._y = 2;

                m_ConLoading.gotoAndPlay(1);
                m_ConLoading.onEnterFrame = function()
                {
                    if (this._currentframe == this._totalframes)
                    {
                        this.stop();
                        this._alpha = 0;
                    }
                }
            }
            
            //Distance
            if ( !m_IsSimpleDynel && DistributedValue.GetDValue("ShowNametagDistance", false) )
            {
				animateMemberIcon += 10;
                //Distance to NPC
                var distance:String = com.Utils.Format.Printf( "%.1f", Math.round(m_Dynel.GetDistanceToPlayer()*10)/10 ) + " m";
                if (distance != undefined && distance != "")
                {
                    y += 3;
                    
					//m_DistanceY = y;
                    m_DistanceY = m_Name._y + 36;
                    if (m_Guild == undefined)
                    {
                        m_DistanceY -= 7;
                    }
                    
					if (m_DistanceToNPC == undefined)
					{
                        m_DistanceToNPC = attachMovie("DistanceLabel", "distanceNPC", getNextHighestDepth());
						m_DistanceToNPC._alpha = 0;
                        m_DistanceToNPC._x = m_Name._x + m_HealthBarWidth;
						Label(m_DistanceToNPC).text = distance;
						//Label(m_DistanceToNPC).width = m_Name.width;
						m_DistanceToNPC.onEnterFrame = Delegate.create(this, StupidDistanceHack);
                    }
                    
                    y += 18;
                }
            }    
            else
            {
                y += 10;
            }
            
            if (!m_IsSimpleDynel)
            {                
                if (DistributedValue.GetDValue("ShowNametagCastbar", false))
                {
					animateMemberIcon += 10;
                    //CastBar
                    if (m_CastBar == undefined)
                    {
                        m_CastBar = attachMovie("CastBar", "castbar", getNextHighestDepth());
                        m_CastBar._alpha = 0;
                        m_CastBar._xscale = 0;
                        m_CastBar._yscale = 0;
                        m_CastBar.SetCharacter(m_Character);
                        m_CastBar.m_ForceVisible = true;
                    }
                    
                    m_CastBar._x = m_LeftAlignXCollapsed;
                    m_CastBar.tweenTo( m_TweenTime,  {_x:m_Name._x + 2, _y: m_Name._y + 42, _alpha: 100, _xscale:30, _yscale:50  }, Regular.easeOut);
                    m_CastBar.onTweenComplete = null;
                }
            }
        }
        else
        {
            if (m_RemoveOnDeselect)
            {
                SignalRemoveNametag.Emit(m_DynelID);
            }
            else if (!m_IsHostileTarget || (m_IsHostileTarget && showHostileNPCNametags != SHOW_HOSTILE_NAMETAG_FULL))
            {
                if (m_FactionRankIcon != undefined)
                {
                    m_FactionRankIcon.tweenTo(m_TweenTime/2, { _width:25, _height:25 }, Regular.easeOut);
                }
                MovieClip(m_Name).tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed + m_MonsterBandPush }, Regular.easeOut); 
				if (m_CinematicIcon != undefined)
				{
					m_CinematicIcon.tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed + m_Name._width/2 - m_CinematicIcon._width/2 }, Regular.easeOut);
				}

                if (m_NameBarArt != undefined)
                {
                    MovieClip(m_NameBarArt).tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, _alpha:0,_y: (m_Name._y + m_Name._height / 2), _yscale: 1}, Regular.easeOut);
                    MovieClip(m_NameBarArt).onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_NameBarArt = undefined;
                }
                
                if (m_Title != undefined)
                {
                    MovieClip(m_Title).tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, width:m_Name.width,_alpha:0,_y: 5 }, Regular.easeOut);
                    MovieClip(m_Title).onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_Title = undefined;
                }
                if (m_Guild != undefined)
                {
                    MovieClip(m_Guild).tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, width:m_Name.width,_alpha:0,_y: 5 }, Regular.easeOut);
                    MovieClip(m_Guild).onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_Guild = undefined;
                }
                if (m_DistanceToNPC != undefined)
                {
                    MovieClip(m_DistanceToNPC).tweenTo(m_TweenTime, {width:m_Name.width,_alpha:0,_y: 5 }, Regular.easeOut);
                    MovieClip(m_DistanceToNPC).onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_DistanceToNPC = undefined;
                }	
				
				if (m_CastBar != undefined)
                {
                    m_CastBar.tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, _xscale:0, _yscale:0, _alpha:0, _y: 5 }, Regular.easeOut);
                    m_CastBar.onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_CastBar = undefined;
                }

                if (m_NpcIcon != undefined)
                {
                    m_NpcIcon.tweenTo(m_TweenTime, {_alpha: 0}, Regular.easeOut);
                    m_NpcIcon.removeMovieClip();
                    m_NpcIcon = undefined;
                }

                if (m_Level != undefined)
                {

                    MovieClip(m_Level).tweenTo(m_TweenTime, {_alpha: 0}, Regular.easeOut);
                    MovieClip(m_Level).onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_Level = undefined;
                }
				
                if (m_HealthBar != undefined )
                {
                    if (!m_ShowHealthBarCollapsed && !m_ForceHealthBar && !m_IsHostileTarget)
                    {
                        m_HealthBar.removeMovieClip();
                        m_HealthBar = undefined;
                    }
                    else
                    {
                        m_HealthBar.tweenTo(m_TweenTime, { _x:0, _y: m_Name._y + 20, _xscale: 100, _yscale: 100 }, Regular.easeOut);
                    }
                }
				if (m_MemberIcon != undefined)
				{
					m_MemberIcon.removeMovieClip()
					m_MemberIcon = undefined;
				}
                for (var i:Number = 0; i < m_DetailedComponents.length; i++)
                {
                    if (m_DetailedComponents[i] != undefined)
                    {
                        m_DetailedComponents[i].tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, _y: 5, _alpha: 0, _xscale:0, _yscale:0 }, Regular.easeOut);
                        m_DetailedComponents[i].onTweenComplete = function()
                        {
                            this.removeMovieClip();
                        }
						m_DetailedComponents[i]	= undefined;
                    }
                }
                m_DetailedComponents = [];
            }
        }
    }

    function SetAsHostileTarget(hostileTarget:Boolean, hatelistCreated:Boolean)
    {
        m_HateListCreated = hatelistCreated;
        m_IsHostileTarget = hostileTarget;
        
        var displayHostileNametags:Number = DistributedValue.GetDValue("ShowHostileNPCNametags", 0);
        var showDefaultHealthBar:Number = DistributedValue.GetDValue("ShowNametagHealthBarDefault", 0)

        if (hostileTarget)
        {
            if (displayHostileNametags == SHOW_HOSTILE_NAMETAG_NONE)
            {
                return; // We should now have been here...
            }
            else if (displayHostileNametags == SHOW_HOSTILE_NAMETAG_PARTIAL)
            {
                if (m_HealthBar == undefined)
                {
                    AddHealthBar();
                    m_HealthBar._y = m_Name._y + 20;
                    m_HealthBar._x = m_LeftAlignXCollapsed;
                    m_HealthBar._alpha = 100;
                }
            }
            else if (displayHostileNametags == SHOW_HOSTILE_NAMETAG_FULL)
            {
                if (!m_IsTarget)
                {
                    SetAsTarget(true);
                }
            }
        }
        else // Not hostileTarget, so clear up things...
        {
            if (displayHostileNametags == SHOW_HOSTILE_NAMETAG_PARTIAL && !(showDefaultHealthBar == SHOW_HEALTHBAR_ENEMIES || showDefaultHealthBar == SHOW_HEALTHBAR_ALL))
            {
                m_HealthBar.removeMovieClip();
                m_HealthBar = undefined;
            }
            else if (displayHostileNametags == SHOW_HOSTILE_NAMETAG_FULL)
            {
                SetAsTarget(false);
            }
        }
    }
	
	function StupidDistanceHack()
	{
		if (m_DistanceToNPC != undefined && m_DistanceToNPC.initialized)
		{
			m_DistanceToNPC.onEnterFrame = null;
            var distance:String = com.Utils.Format.Printf( "%.1f", Math.round(m_Dynel.GetDistanceToPlayer()*10)/10 ) + " m";
            m_DistanceToNPC._x = m_Name._x + m_HealthBarWidth - 20;
			var extent:Object = m_DistanceToNPC.textField.getTextFormat().getTextExtent(distance);
            m_DistanceToNPC.tweenTo( m_TweenTime,  {_y: m_DistanceY, _alpha: 100, width:extent.width+10}, Regular.easeOut);
			m_DistanceToNPC.onTweenComplete = null;
		}
	}

    public function GetHatelistCreated():Boolean
    {
        return m_HateListCreated;
    }
    public function GetIsHostileTarget():Boolean
    {
        return m_IsHostileTarget;
    }
}