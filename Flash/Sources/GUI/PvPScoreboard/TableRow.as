//Imports
import com.Utils.Colors;
import com.Utils.ID32;
import com.Utils.Format;
import GUI.PvPScoreboard.PvPScoreboardColors;
import GUI.PvPScoreboard.PvPScoreboardContent;
import com.GameInterface.PvPScoreboard;

//Class
class GUI.PvPScoreboard.TableRow extends MovieClip
{
    //Constants
    public static var DRAGON_ICON_CLIP_NAME:String = "LogoDragon";
    public static var TEMPLARS_ICON_CLIP_NAME:String = "LogoTemplar";
    public static var ILLUMINATI_ICON_CLIP_NAME:String = "LogoIlluminati";
	
	private static var EL_DORADO_ID:Number = 5820;
    private static var STONEHENGE_ID:Number = 5840;
	private static var SHAMBALA_ID:Number = 5830;
    
    private static var FACTION_HEADER_HEIGHT:Number = 35;
    
    //Properties
    private var m_TableRowHeader:MovieClip;
    private var m_Rank:MovieClip;
    private var m_PlayerName:MovieClip;
    private var m_Role:MovieClip;
    private var m_BattleRank:MovieClip;
    private var m_Damage:MovieClip;
    private var m_Healing:MovieClip;
    private var m_CrowdControl:MovieClip;
    private var m_DamageTaken:MovieClip;
    private var m_Kills:MovieClip;
    private var m_Death:MovieClip;
    private var m_DynamicPoints:MovieClip;
    private var m_Points:MovieClip;
    private var m_FieldsArray:Array;
    
    //Constructor
    public function TableRow()
    {
        super();
        
        m_FieldsArray = new Array(m_Rank, m_PlayerName, m_Role, m_BattleRank, m_Damage, m_Healing, m_CrowdControl, m_DamageTaken, m_Kills, m_Death, m_DynamicPoints, m_Points);
    }
    
    //Set Faction Header
    public function SetFactionHeader(faction:Number):Void
    {
        var backgroundColor:Number;
        var iconClipName:String;
        
		if (PvPScoreboard.m_PlayfieldID == SHAMBALA_ID)
		{
			switch (faction)
			{
				case _global.Enums.Factions.e_FactionDragon:        backgroundColor = PvPScoreboardColors.PURPLE_BRIGHT_COLOR;
																	iconClipName = "";
																	break;
																	
				case _global.Enums.Factions.e_FactionTemplar:       backgroundColor = PvPScoreboardColors.YELLOW_BRIGHT_COLOR;
																	iconClipName = "";
			}
		}
		else
		{
			switch (faction)
			{
				case _global.Enums.Factions.e_FactionDragon:        backgroundColor = PvPScoreboardColors.DRAGON_BRIGHT_COLOR;
																	iconClipName = DRAGON_ICON_CLIP_NAME;
																	break;
																	
				case _global.Enums.Factions.e_FactionTemplar:       backgroundColor = PvPScoreboardColors.TEMPLARS_BRIGHT_COLOR;
																	iconClipName = TEMPLARS_ICON_CLIP_NAME;
																	break;
																	
				case _global.Enums.Factions.e_FactionIlluminati:    backgroundColor = PvPScoreboardColors.ILLUMINATI_BRIGHT_COLOR
																	iconClipName = ILLUMINATI_ICON_CLIP_NAME;
			}
		}
        
		if (m_TableRowHeader != undefined)
		{
			m_TableRowHeader.removeMovieClip();
		}
        m_TableRowHeader = attachMovie("TableRowHeader", "m_TableRowHeader", getNextHighestDepth());
        m_TableRowHeader.SetupHeader(faction, iconClipName, backgroundColor);
    }
    
    //Set Row Colors
    public function SetRowColors(faction:Number, sortTarget:String, isPlayer:Boolean):Void
    {
        var playerColor:Number;
        var sortColor:Number;
        var factionColor:Number;
		
        if (PvPScoreboard.m_PlayfieldID == SHAMBALA_ID)
		{
			switch (faction)
			{
				case _global.Enums.Factions.e_FactionDragon:        playerColor = PvPScoreboardColors.PURPLE_NEUTRAL_COLOR;
																	sortColor = PvPScoreboardColors.PURPLE_NEUTRAL_COLOR;
																	factionColor = PvPScoreboardColors.PURPLE_DARK_COLOR;
																	break;
																	
				case _global.Enums.Factions.e_FactionTemplar:       playerColor = PvPScoreboardColors.YELLOW_NEUTRAL_COLOR;
																	sortColor = PvPScoreboardColors.YELLOW_NEUTRAL_COLOR;
																	factionColor = PvPScoreboardColors.YELLOW_DARK_COLOR;
			}
		}
		else
		{
			switch (faction)
			{
				case _global.Enums.Factions.e_FactionDragon:        playerColor = PvPScoreboardColors.DRAGON_NEUTRAL_COLOR;
																	sortColor = PvPScoreboardColors.DRAGON_NEUTRAL_COLOR;
																	factionColor = PvPScoreboardColors.DRAGON_DARK_COLOR;
																	break;
																	
				case _global.Enums.Factions.e_FactionTemplar:       playerColor = PvPScoreboardColors.TEMPLARS_NEUTRAL_COLOR;
																	sortColor = PvPScoreboardColors.TEMPLARS_NEUTRAL_COLOR;
																	factionColor = PvPScoreboardColors.TEMPLARS_DARK_COLOR;
																	break;
																	
				case _global.Enums.Factions.e_FactionIlluminati:    playerColor = PvPScoreboardColors.ILLUMINATI_NEUTRAL_COLOR;
																	sortColor = PvPScoreboardColors.ILLUMINATI_NEUTRAL_COLOR;
																	factionColor = PvPScoreboardColors.ILLUMINATI_DARK_COLOR;
			}
		}
        
        for (var i:Number = 0; i < m_FieldsArray.length; i++)
        {
            if (isPlayer)
            {
                Colors.ApplyColor(m_FieldsArray[i].m_Background, playerColor)
            }
            else
            {
                if (m_FieldsArray[i].name == sortTarget)
                {
                    Colors.ApplyColor(m_FieldsArray[i].m_Background, sortColor);
                }
                else
                {
                    Colors.ApplyColor(m_FieldsArray[i].m_Background, factionColor);
                }
            }
        }
    }
    
    //Set Rank Icon
    public function SetRankIcon(faction:Number):Void
    {
        var iconInstance:Number;
        
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        iconInstance = PvPScoreboardContent.RDB_DRAGON_ICON;
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionTemplar:       iconInstance = PvPScoreboardContent.RDB_TEMPLARS_ICON;
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionIlluminati:    iconInstance = PvPScoreboardContent.RDB_ILLUMINATI_ICON;
        }
        
        SetIcon(iconInstance, m_Rank.m_IconContainer, m_Rank.m_Background._height - 6, m_Rank.m_Background._width / 2, 3);
    }
    
    //Set Role Icon
    public function SetRoleIcon(role:Number):Void
    {
        var iconInstance:Number;
        
        switch (role)
        {
            case _global.Enums.Class.e_Damage:  iconInstance = 7190654;
                                                break;
                                                
            case _global.Enums.Class.e_Tank:    iconInstance = 7190655;
                                                break;
                                                
            case _global.Enums.Class.e_Heal:    iconInstance = 7190657;
        }
        
        SetIcon(iconInstance, m_Role.m_IconContainer, m_Role.m_Background._height - 6, m_Role.m_Background._width / 2, 3);
    }
    
    //Set Battle Rank Icon
    public function SetBattleRankIcon():Void
    {
        var iconInstance:Number = 8141667;
        
        SetIcon(iconInstance, m_BattleRank.m_IconContainer, 75, m_BattleRank.m_Label._x + m_BattleRank.m_Label._width + 8, 0);
    }
    
    //Set Icon
    private function SetIcon(iconInstance:Number, targetContainer:MovieClip, scale:Number, xPosition:Number, yPosition:Number):Void
    {
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        icon.SetInstance(iconInstance);
        
		if (movieClipLoader == undefined)
		{
        	var movieClipLoader:MovieClipLoader = new MovieClipLoader();
		}
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), targetContainer);
        
        targetContainer._xscale = targetContainer._yscale = scale;
        targetContainer._x = xPosition - m_Rank.m_IconContainer._xscale / 2;
        targetContainer._y = yPosition;
    }
}