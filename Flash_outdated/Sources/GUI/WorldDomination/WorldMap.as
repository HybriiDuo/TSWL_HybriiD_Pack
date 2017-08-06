//Imports
import com.GameInterface.Game.BuffData;
import com.GameInterface.Game.Character;
import com.GameInterface.Spell;
import com.GameInterface.ProjectUtils;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Utils;
import com.GameInterface.PendingReward;
import com.GameInterface.DistributedValue;
import com.Utils.Colors;
import com.Utils.Format;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
import flash.geom.Rectangle;
import GUI.WorldDomination.Marker;
import GUI.WorldDomination.MarkerInfo;
import GUI.WorldDomination.SidePanel;
import GUI.WorldDomination.MiniMapReward;

//Class
class GUI.WorldDomination.WorldMap extends MovieClip
{
    //Constants
    private static var EL_DORADO_INSTRUCTIONS:String = LDBFormat.LDBGetText("WorldDominationGUI", "elDoradoInstructions");
    private static var STONEHENGE_INSTRUCTIONS:String = LDBFormat.LDBGetText("WorldDominationGUI", "stonehengeInstructions");
    private static var FUSANG_PROJECTS_INSTRUCTIONS:String = LDBFormat.LDBGetText("WorldDominationGUI", "forbiddenCityInstructions");
	private static var SHAMBALA_INSTRUCTIONS:String = LDBFormat.LDBGetText("WorldDominationGUI", "shambalaInstructions");
    private static var ACTIVE_BUFFS_LABEL:String = LDBFormat.LDBGetText("WorldDominationGUI", "activeBuffsLabel");
    private static var BATTLE_RANK_TITLE:String = LDBFormat.LDBGetText("GenericGUI", "BattleRankTitleAllCaps");
    private static var BATTLE_XP_TITLE:String = LDBFormat.LDBGetText("GenericGUI", "BattleXPTitleAllCaps");
    private static var BATTLE_RANK_TOOLTIP_TITLE:String = LDBFormat.LDBGetText("GenericGUI", "BattleRankTitle");
    private static var BATTLE_RANK_TOOLTIP_TEXT:String = LDBFormat.LDBGetText("GenericGUI", "BattleRankTooltipText");
    
    private static var BUFF_SUPPORT_DRAGON:String = "PvPFusangUnderDogBotActivatedDragon";
    private static var BUFF_SUPPORT_TEMPLARS:String = "PvPFusangUnderDogBotActivatedTemplar";
    private static var BUFF_SUPPORT_ILLUMINATI:String = "PvPFusangUnderDogBotActivatedIlluminati";
    
    private static var MARKER_INFO_SCALE:Number = 21;
    private static var LINE_THICKNESS:Number = 2;
    private static var LINE_COLOR:Number = 0xFFFFFF;
    private static var LINE_ALPHA:Number = 10;
    private static var MAP_HEIGHT_PERCENTAGE:Number = 0.955;
    private static var MAP_HEIGHT_ADDITIONAL_PERCENTAGE:Number = 0.107;
    private static var BATTLE_RANK_BAR_TOTAL_SECTIONS:Number = ProjectUtils.GetUint32TweakValue("PvPXPChunksPerRank");
    private static var BATTLE_XP_PER_SECTION:Number = ProjectUtils.GetUint32TweakValue("PvPXPPerChunk");
    private static var BATTLE_RANK_ICON_INSTANCE:Number = 8141020;
    private static var BATTLE_RANK_FULL_SECTION_COLOR:Number = 0x4BD4FE;
    private static var BATTLE_RANK_PARTIAL_SECTION_COLOR:Number = 0x5092AA
    
    //Properties
    public var m_SidePanelWidth:Number;
    
    public var m_MarkerArray:Array;
    public var m_ElDoradoMarker:Marker;
    public var m_StonehengeMarker:Marker;
    public var m_FusangProjectsMarker:Marker;
	public var m_ShambalaMarker:Marker;
    
    private var m_MarkerInfoArray:Array;
    private var m_ElDoradoMarkerInfo:MovieClip;
    private var m_StonehengeMarkerInfo:MovieClip;
    private var m_FusangProjectsMarkerInfo:MovieClip;
	private var m_ShambalaMarkerInfo:MovieClip;
    
    private var m_Character:Character;
    
    private var m_MapBackground:MovieClip;
    private var m_Map:MovieClip;
    private var m_Grid:MovieClip;
    private var m_SineWave1:MovieClip;
    private var m_SineWave2:MovieClip;
    private var m_Instructions:MovieClip;
    private var m_CouncilLogo:MovieClip;
    private var m_BackgroundCouncilLogo:MovieClip;
    private var m_BorderShadow:MovieClip;
    private var m_BattleRankIconContainer:MovieClip;
    private var m_BattleRankIconTooltipContainer:MovieClip;
    private var m_BattleRankProgressBarContainer:MovieClip;
    private var m_BattleRankLabel:TextField;
    
    private var m_ActiveBuffsLabel:TextField;
    private var m_WorldDominationBuff:MovieClip;
    private var m_CouncilSupportBuff:MovieClip;
    private var m_CustodianBuff:MovieClip;
	
	private var m_PvPSpoilsIcon:MovieClip;
	var m_NotificationThrottleIntervalId:Number;
	var m_NotificationThrottleInterval:Number// ms between the throttleeffect
    
    private var m_ElDoradoInQueue:Boolean;
    private var m_ElDoradoInZone:Boolean;
    private var m_StonehengeInQueue:Boolean;
    private var m_StonehengeInZone:Boolean;
    private var m_FusangProjectsInQueue:Boolean;
    private var m_FusangProjectsInZone:Boolean;
    
    private var m_InstructionsAreVisible:Boolean;
    
    private var m_BuffSupport:String;
    
    //Constructor
    public function WorldMap()
    {
        super();
    }
    
    //On Load
    private function onLoad():Void
    {
        Init();
        Layout();
    }

    //Initialize
    private function Init():Void
    {
        m_ElDoradoMarker.m_Name = _parent.EL_DORADO;
        m_ElDoradoMarkerInfo = attachMovie("MarkerInfo", "m_ElDoradoMarkerInfo", getNextHighestDepth());
        m_ElDoradoMarkerInfo.SetupInfo(MarkerInfo.RIGHT, _parent.EL_DORADO, SidePanel.CAPTURE_THE_RELICS, "MarkerInfoButton");
        
        m_StonehengeMarker.m_Name = _parent.STONEHENGE;
        m_StonehengeMarkerInfo = attachMovie("MarkerInfo", "m_StonehengeMarkerInfo", getNextHighestDepth());
        m_StonehengeMarkerInfo.SetupInfo(MarkerInfo.RIGHT, _parent.STONEHENGE, SidePanel.CAPTURE_THE_RELICS, "MarkerInfoButton");
        
        m_FusangProjectsMarker.m_Name = _parent.FUSANG_PROJECTS;
        m_FusangProjectsMarkerInfo = attachMovie("MarkerInfo", "m_FusangProjectsMarkerInfo", getNextHighestDepth());
        m_FusangProjectsMarkerInfo.SetupInfo(MarkerInfo.LEFT, _parent.FUSANG_PROJECTS, SidePanel.PRERSISTENT_WARZONE, "MarkerInfoButton");
		
		m_ShambalaMarker.m_Name = _parent.SHAMBALA;
		m_ShambalaMarkerInfo = attachMovie("MarkerInfo", "m_ShambalaMarkerInfo", getNextHighestDepth());
		m_ShambalaMarkerInfo.SetupInfo(MarkerInfo.LEFT, _parent.SHAMBALA, SidePanel.CAPTURE_THE_RELICS, "MarkerInfoButton");
        
        m_MarkerArray = new Array(m_ElDoradoMarker, m_StonehengeMarker, m_FusangProjectsMarker, m_ShambalaMarker);
        
        for (var i:Number = 0; i < m_MarkerArray.length; i++)
        {
            m_MarkerArray[i].SignalMarkerSelected.Connect(SlotMarkerSelected, this);

            if (_parent.m_SidePanel.m_SelectedIndex == i)
            {
                DropdownSelected(m_MarkerArray[i].m_Name);
            }
        }
        
        m_MarkerInfoArray = new Array(m_ElDoradoMarkerInfo, m_StonehengeMarkerInfo, m_FusangProjectsMarkerInfo, m_ShambalaMarkerInfo);
        
        for (var i:Number = 0; i < m_MarkerInfoArray.length; i++)
        {
            m_MarkerInfoArray[i].m_Button.SignalButtonSelected.Connect(SlotMarkerInfoSelected, this);
            
            m_MarkerInfoArray[i]._xscale = m_MarkerInfoArray[i]._yscale = MARKER_INFO_SCALE;
            m_MarkerInfoArray[i]._x = m_MarkerArray[i]._x;
            m_MarkerInfoArray[i]._y = m_MarkerArray[i]._y;
            
            Marker.m_SelectSound = false;
            
            m_MarkerInfoArray[_parent.m_SidePanel.m_SelectedIndex].selected = true;
        }
        
        Marker.m_SelectSound = true;
        
        m_Character = Character.GetClientCharacter();
        
        CreateWorldDominationBuffs();
        CreateBattleRank();
        
        m_Instructions = attachMovie("Instructions", "m_Instructions", getNextHighestDepth());
        m_Instructions.SignalInstructionsAreVisible.Connect(SlotInstructionsAreVisible, this);
        
        m_InstructionsAreVisible = false;
        
        m_CouncilLogo = createEmptyMovieClip("m_CouncilLogoLoader", getNextHighestDepth());
        
        var m_CouncilLogoLoader:MovieClipLoader = new MovieClipLoader();
        m_CouncilLogoLoader.loadClip("CouncilLogoPvpMap.swf", m_CouncilLogo);
		
		var badge:MovieClip = m_PvPSpoilsIcon.attachMovie("_Numbers", "m_Badge", m_PvPSpoilsIcon.getNextHighestDepth());
		badge.UseSingleDigits = true;
		badge.SetColor(0xFF0000);		
		badge._x = m_PvPSpoilsIcon._x + 35;
		badge._y = m_PvPSpoilsIcon._y + 35;
		badge._xscale = badge._yscale = 110;
		SlotPendingRewardsUpdated();
		PendingReward.SignalClaimsUpdated.Connect(SlotPendingRewardsUpdated, this);
		
		m_PvPSpoilsIcon.onPress = OpenPvPSpoils;
		m_NotificationThrottleIntervalId = -1;
    	m_NotificationThrottleInterval = 2000; 		
		if (m_NotificationThrottleIntervalId > -1)
    	{
        	clearInterval( m_NotificationThrottleIntervalId );
		}    
    	m_NotificationThrottleIntervalId = setInterval(Delegate.create(this, AnimatePvPSpoils), m_NotificationThrottleInterval );
		m_PvPSpoilsIcon.m_AnimatingIcon.gotoAndStop(0);
    }
	
	private function onUnload():Void
	{	
    	if (m_NotificationThrottleIntervalId > -1)
    	{
        	clearInterval( m_NotificationThrottleIntervalId );
    	}
	}
	
	function SlotPendingRewardsUpdated():Void
	{
		m_PvPSpoilsIcon.m_Badge.SetCharge(PendingReward.m_Claims.length);
		if (PendingReward.m_Claims.length > 0)
		{
			m_PvPSpoilsIcon.m_Badge._visible = true;
		}
		else
		{
			m_PvPSpoilsIcon.m_Badge._visible = false;
		}
	}
	
	/// calls a throttle effect on PvP Spoils if there are any available
	function AnimatePvPSpoils():Void
	{
		if (PendingReward.m_Claims.length > 0)
		{
			m_PvPSpoilsIcon.m_AnimatingIcon.gotoAndPlay("throttle");
		}
	}
	
	private function OpenPvPSpoils():Void
	{
		var character:Character = Character.GetClientCharacter();
    	var allowedToReceiveItems:Boolean = character.CanReceiveItems();
		
		if (allowedToReceiveItems)
		{
			DistributedValue.SetDValue("pvp_spoils_window", true);
		}
	}

    //Create World Domination Buffs
    private function CreateWorldDominationBuffs():Void
    {
        m_ActiveBuffsLabel.autoSize = "left";
        m_ActiveBuffsLabel.text = ACTIVE_BUFFS_LABEL;

        m_WorldDominationBuff = attachMovie("BuffComponent", "m_WorldDominationBuff", getNextHighestDepth());
        m_WorldDominationBuff.SetBuffData(Spell.GetBuffData(7241309));
        m_WorldDominationBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        
        var faction:Number = m_Character.GetStat(_global.Enums.Stat.e_PlayerFaction);
        
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        m_BuffSupport = BUFF_SUPPORT_DRAGON; 
                                                                break;
                                        
            case _global.Enums.Factions.e_FactionTemplar:       m_BuffSupport = BUFF_SUPPORT_TEMPLARS; 
                                                                break;
                                        
            case _global.Enums.Factions.e_FactionIlluminati:    m_BuffSupport = BUFF_SUPPORT_ILLUMINATI; 
                                                                break;
        }
        
        m_CouncilSupportBuff = attachMovie("BuffComponent", "m_CouncilSupportBuff", getNextHighestDepth());
        m_CouncilSupportBuff.SetBuffData(Spell.GetBuffData(MiniMapReward.GetCouncilSupportBuffSpellID(faction)));
        m_CouncilSupportBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        m_CouncilSupportBuff._visible = false;
    
        m_CustodianBuff = attachMovie("BuffComponent", "m_CustodianBuff", getNextHighestDepth());
        m_CustodianBuff.SetBuffData(Spell.GetBuffData(MiniMapReward.GetCustodianBuffSpellID(faction)));
        m_CustodianBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        m_CustodianBuff._visible = false;

    }

    //Create Battle Rank
    private function CreateBattleRank():Void
    {        
        var battleRankIcon:ID32 = new ID32();
        battleRankIcon.SetType(1000624);
        battleRankIcon.SetInstance(BATTLE_RANK_ICON_INSTANCE);
        
        var battleRankIconLoader:MovieClipLoader = new MovieClipLoader();
        battleRankIconLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", battleRankIcon.GetType(), battleRankIcon.GetInstance()), m_BattleRankIconContainer);
        
        m_BattleRankIconContainer._xscale = m_BattleRankIconContainer._yscale = m_BattleRankIconTooltipContainer._xscale = m_BattleRankIconTooltipContainer._yscale = 70;
        m_BattleRankIconContainer._x = m_BattleRankIconTooltipContainer._x = 6;
        m_BattleRankIconContainer._y = m_BattleRankIconTooltipContainer._y = _parent.STAGE.height - (_parent.STAGE.height * MAP_HEIGHT_PERCENTAGE) + 8;
        
        var battleRankTooltipText:String = "<b>" + Utils.CreateHTMLString(BATTLE_RANK_TOOLTIP_TITLE, {face: "_StandardFont", color: "#FFFFFF", size: 16}) + "</b>";
        battleRankTooltipText += "<br/><br/>" + Utils.CreateHTMLString(BATTLE_RANK_TOOLTIP_TEXT, {face: "_StandardFont", color: "#FFFFFF", size: 12});

        TooltipUtils.AddTextTooltip(m_BattleRankIconTooltipContainer, battleRankTooltipText, 290, TooltipInterface.e_OrientationHorizontal, false);
        
        m_BattleRankProgressBarContainer._x = m_BattleRankIconContainer._x + 50;
        m_BattleRankProgressBarContainer._y = m_BattleRankIconContainer._y + 6;
        
        var battleRankBarWidth:Number = _parent.STAGE.width - m_SidePanelWidth - m_BattleRankProgressBarContainer._x - 20;
        var battleRankSectionWidth:Number = battleRankBarWidth / BATTLE_RANK_BAR_TOTAL_SECTIONS;
            
        for (var i:Number = 0; i < BATTLE_RANK_BAR_TOTAL_SECTIONS; i++)
        {
            var section:MovieClip = m_BattleRankProgressBarContainer.attachMovie("BattleRankProgressBarSection", "m_Section_" + i, m_BattleRankProgressBarContainer.getNextHighestDepth());
            section._width = battleRankSectionWidth;
        }
        
        m_BattleRankLabel.autoSize = "left";
        
        m_Character.SignalStatChanged.Connect(UpdateBattleRank, this);
        
        UpdateBattleRank();
    }
        
    //Update Battle Rank
    private function UpdateBattleRank():Void
    {
        var maxBattleXP:Number = BATTLE_XP_PER_SECTION * BATTLE_RANK_BAR_TOTAL_SECTIONS;
        var maxSectionXP:Number = maxBattleXP / BATTLE_RANK_BAR_TOTAL_SECTIONS;
        var currentBattleXP:Number = m_Character.GetStat(_global.Enums.Stat.e_PvPXP);
        
        for (var i:Number = 0; i < BATTLE_RANK_BAR_TOTAL_SECTIONS; i++)
        {
            var section:MovieClip = m_BattleRankProgressBarContainer["m_Section_" + i];
            var lowEndXP:Number = i * maxSectionXP;
            var highEndXP:Number = lowEndXP + maxSectionXP;

            if (currentBattleXP <= lowEndXP)
            {
                section.m_Fill._xscale = 0;
                section.m_LeftLight._alpha = section.m_RightLight._alpha = 0;
            }
            else if (currentBattleXP > lowEndXP && currentBattleXP < highEndXP)
            {
                Colors.ApplyColor(section.m_Fill, BATTLE_RANK_PARTIAL_SECTION_COLOR);
                
                section.m_Fill._xscale = (currentBattleXP - (maxSectionXP * i)) / maxSectionXP * 100;
                
                if (i == 0)
                {
                    section.m_LeftLight._alpha = section.m_RightLight._alpha = 0;
                }
                else
                {
                    section.m_LeftLight._alpha = 100;
                    section.m_RightLight._alpha = 0;
                }
            }
            else if (currentBattleXP >= highEndXP)
            {
                Colors.ApplyColor(section.m_Fill, BATTLE_RANK_FULL_SECTION_COLOR);
                
                section.m_Fill._xscale = 100;
                
                if (i == 0)
                {
                    section.m_LeftLight._alpha = 0;
                    section.m_RightLight._alpha = 100;
                }
                else if (i == BATTLE_RANK_BAR_TOTAL_SECTIONS - 1)
                {
                    section.m_LeftLight._alpha = 100;
                    section.m_RightLight._alpha = 0;
                }
                else
                {
                    section.m_LeftLight._alpha = section.m_RightLight._alpha = 100;
                }
            }

            if (i != 0)
            {
                var previousSection:MovieClip = m_BattleRankProgressBarContainer["m_Section_" + (i - 1)];
                
                section._x = previousSection._x + previousSection._width;
            }
        }
        
        m_BattleRankLabel.text = BATTLE_RANK_TITLE + ": " + m_Character.GetStat(_global.Enums.Stat.e_PvPLevel) + "    " + BATTLE_XP_TITLE + ": " + currentBattleXP + " / " + maxBattleXP;
        m_BattleRankLabel._x = m_BattleRankProgressBarContainer._x - 2;
        m_BattleRankLabel._y = m_BattleRankProgressBarContainer._y + m_BattleRankProgressBarContainer._height + 6;
    }
    
    //Layout
    public function Layout():Void
    {
        //Resize Map Background
        m_MapBackground._width = _parent.STAGE.width - m_SidePanelWidth;
        m_MapBackground._height = _parent.STAGE.height * MAP_HEIGHT_PERCENTAGE;
        m_MapBackground._x = 0;
        m_MapBackground._y = _parent.STAGE.height - m_MapBackground._height;
        
        //Scale Down Map
        var originalMapWidth:Number = m_Map._width;
        var originalMapHeight:Number = m_Map._height;
        
        m_Map._width = _parent.STAGE.width - m_SidePanelWidth - _parent.MARGIN * 2;
        m_Map._height = _parent.STAGE.height - _parent.STAGE.height * MAP_HEIGHT_ADDITIONAL_PERCENTAGE;
        m_Map._x = _parent.MARGIN;
        m_Map._y = _parent.STAGE.height - m_Map._height;
    
        //Draw Grid
        m_Grid.clear();
        m_Grid.lineStyle(LINE_THICKNESS, LINE_COLOR, LINE_ALPHA, true, "none");
        
        var totalLongitudeLines:Number = 23;
        var longitudeWidth:Number = (m_Map._width + _parent.MARGIN * 2) / totalLongitudeLines;
        
        var totalLatitudeLines:Number = 20;
        var latitudeHeight:Number = _parent.STAGE.height / totalLatitudeLines;
        
        for (var i:Number = 1; i < totalLongitudeLines + 1; i++)
        {
            m_Grid.moveTo(longitudeWidth * i - longitudeWidth / 2, 0);
            m_Grid.lineTo(longitudeWidth * i - longitudeWidth / 2, _parent.STAGE.height);
        }
        
        for (var i:Number = 1; i < totalLatitudeLines + 1; i++)
        {
            m_Grid.moveTo(0, latitudeHeight * i - latitudeHeight / 2);
            m_Grid.lineTo(m_Map._width + _parent.MARGIN * 2, latitudeHeight * i - latitudeHeight / 2);
        }
        
        //Draw Sine Waves
        var sineWidth:Number = m_Map._width + _parent.MARGIN * 2;
        var sineHeight:Number = _parent.STAGE.height / 5 - latitudeHeight;
        var sineY:Number = _parent.STAGE.height - sineHeight / 2 - _parent.MARGIN * 2;
        var offsetWidth:Number = _parent.MARGIN * 4;
        
        CreateSineWave(m_SineWave1, sineY, sineWidth, 0, sineHeight, 3);
        CreateSineWave(m_SineWave2, sineY, sineWidth, offsetWidth, sineHeight, 3);
        
        m_SineWave2._x = -offsetWidth;
        
        //Reposition Markers and Marker Info
        var repositionMarkers:Array = m_MarkerArray.concat(m_MarkerInfoArray);
        for (var i:Number = 0; i < repositionMarkers.length; i++)
        {
            repositionMarkers[i]._x = m_Map._width / originalMapWidth * repositionMarkers[i]._x + _parent.MARGIN;
            repositionMarkers[i]._y = m_Map._height / originalMapHeight * repositionMarkers[i]._y + _parent.STAGE.height - m_Map._height;
        }
        
        //Reposition Border Shadow
        m_BorderShadow._x = m_MapBackground._x + m_MapBackground._width;
        m_BorderShadow._y = _parent.STAGE.height * _parent.HEADER_HEIGHT_PERCENTAGE;
        m_BorderShadow._height = _parent.STAGE.height - m_BorderShadow._y;
        
        //Active Buffs
        m_ActiveBuffsLabel._x = m_MapBackground._x + 10;
        m_ActiveBuffsLabel._y = m_MapBackground._y + m_MapBackground._height - m_ActiveBuffsLabel._height - 5;
        
        var buffScale:Number = 80;
        var buffGap:Number = 8;
        
        m_WorldDominationBuff._xscale = m_WorldDominationBuff._yscale = buffScale;
        m_WorldDominationBuff._x = m_ActiveBuffsLabel._x + 1;
        m_WorldDominationBuff._y = m_ActiveBuffsLabel._y - m_WorldDominationBuff._height;
        
        m_CouncilSupportBuff._xscale = m_CouncilSupportBuff._yscale = buffScale;
        m_CouncilSupportBuff._x = m_WorldDominationBuff._x + m_WorldDominationBuff._width + buffGap;
        m_CouncilSupportBuff._y = m_ActiveBuffsLabel._y - m_CouncilSupportBuff._height;
        
        m_CustodianBuff._xscale = m_CustodianBuff._yscale = buffScale;
        m_CustodianBuff._x = m_CouncilSupportBuff._x;
        m_CustodianBuff._y = m_CouncilSupportBuff._y;
		
		m_PvPSpoilsIcon._x = m_MapBackground._x + m_MapBackground._width - m_PvPSpoilsIcon._width - 15;
		m_PvPSpoilsIcon._y = m_MapBackground._y + m_MapBackground._height - m_PvPSpoilsIcon._height - 15;
        
        if (m_BuffSupport != undefined)
        {
            switch (PvPMinigame.GetWorldStat(m_BuffSupport, 0, 0, PvPMinigame.GetCurrentDimensionId()))
            {
                case 2:     m_CouncilSupportBuff._visible = true;
                            m_CustodianBuff._visible = false;
                            break;
                            
                case 3:     m_CouncilSupportBuff._visible = false;
                            m_CustodianBuff._visible = true;
                            break;
            }
        }
        
        //Resize Instructions
        m_Instructions.SetSize  (
                                m_MapBackground._x,
                                _parent.STAGE.height * _parent.HEADER_HEIGHT_PERCENTAGE,
                                m_MapBackground._width,
                                m_MapBackground._height
                                )
                                
        //Council Logo
        m_CouncilLogo._x = m_MapBackground._x + m_MapBackground._width - 169;
        m_CouncilLogo._y = m_MapBackground._y + 10;
        m_CouncilLogo._alpha = 60;
        
        //Backgtround Council Logo
        m_BackgroundCouncilLogo._xscale = m_BackgroundCouncilLogo._yscale = (m_MapBackground._width * 0.8 / m_BackgroundCouncilLogo._width) * 100;
        m_BackgroundCouncilLogo._x = m_MapBackground._width / 2 - m_BackgroundCouncilLogo._width / 2;
        m_BackgroundCouncilLogo._y = m_MapBackground._height / 2 - m_BackgroundCouncilLogo._height / 2;
    }
    
    //Create Sine Wave
    private function CreateSineWave(target:MovieClip, y:Number, width:Number, offsetWidth:Number, height:Number, frequency:Number):Void
    {
        target.lineStyle(LINE_THICKNESS, LINE_COLOR, LINE_ALPHA);
        target.moveTo(0, y);
        
        for (var i:Number = 0; i <= width + offsetWidth; i++)
        {
            var angle:Number = 2 * Math.PI * frequency * i / width;
            
            target.lineTo(i, y + height / 2 * Math.sin(angle));
        }
    }
    
    //Slot Marker Selected
    public function SlotMarkerSelected(name:String):Void
    {
        for (var i:Number = 0; i < m_MarkerArray.length; i++)
        {
            if (m_MarkerArray[i].m_Name != name)
            {
                m_MarkerArray[i].selected = m_MarkerInfoArray[i].selected = false;
            }
            else
            {
                _parent.m_SidePanel.MarkerSelected(name)
                m_MarkerInfoArray[i].selected = true;
            }
        }
    }
    
    //Slot Marker Info Selected
    public function SlotMarkerInfoSelected(name:String):Void
    {
        switch (name)
        {
            case _parent.EL_DORADO:         m_Instructions.SetContent(_parent.EL_DORADO, SidePanel.CAPTURE_THE_RELICS, EL_DORADO_INSTRUCTIONS);
                                            break;
                                        
            case _parent.STONEHENGE:        m_Instructions.SetContent(_parent.STONEHENGE, SidePanel.CAPTURE_THE_RELICS, STONEHENGE_INSTRUCTIONS);
                                            break;
                                        
            case _parent.FUSANG_PROJECTS:   m_Instructions.SetContent(_parent.FUSANG_PROJECTS, SidePanel.PRERSISTENT_WARZONE, FUSANG_PROJECTS_INSTRUCTIONS);
											break;
						
			case _parent.SHAMBALA:   		m_Instructions.SetContent(_parent.SHAMBALA, SidePanel.CAPTURE_THE_RELICS, SHAMBALA_INSTRUCTIONS);
        }
        
        m_Instructions.Show();
    }
    
    //Slot Instructions Visibility Toggle
    public function SlotInstructionsAreVisible(visible:Boolean):Void
    {
        m_InstructionsAreVisible = visible;
        
        EnableMarkers(!visible);
    }
    
    //Enable Markers
    public function EnableMarkers(value:Boolean):Void
    {
        for (var i:Number = 0; i < m_MarkerArray.length; i++)
        {
            m_MarkerArray[i].enabled = value;
            m_MarkerInfoArray[i].m_Button.enabled = value;
        }
    }
    
    //Dropdown Selected
    private function DropdownSelected(name:String):Void
    {
        for (var i:Number = 0; i < m_MarkerArray.length; i++)
        {
            if (m_MarkerArray[i].m_Name == name)
            {
                m_MarkerArray[i].selected = m_MarkerInfoArray[i].selected = true;
            }
            else
            {
                m_MarkerArray[i].selected = m_MarkerInfoArray[i].selected = false;
            }
        }
        
        if (m_InstructionsAreVisible)
        {
            SlotMarkerInfoSelected(name);
        }
    }
}