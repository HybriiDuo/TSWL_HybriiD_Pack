import com.Utils.Colors;
import com.Utils.LDBFormat;

class GUI.Mission.MissionUtils
{
    /// constructor to load in GamecodeInterface
    public function MissionUtils()
    {
        
    }
    /// returns the mission type as a string, gets it from the missiontypeenum
	/// 
	public static function MissionTypeToString( p_missiontype:Number ) :String
	{
		var iconname:String = "Unknown";
		switch( p_missiontype )
		{
			case _global.Enums.MainQuestType.e_Action:
				iconname = "Action";
			break;
			case _global.Enums.MainQuestType.e_Sabotage:
				iconname = "Sabotage";
			break;
			case _global.Enums.MainQuestType.e_Story:
				iconname = "Story";
			break;
			case _global.Enums.MainQuestType.e_StoryRepeat:
				iconname = "StoryRepeat";
			break;
            case _global.Enums.MainQuestType.e_Investigation:
                iconname = "Investigation";
            break;
            case _global.Enums.MainQuestType.e_Group:
                iconname = "Group";
            break;
            case _global.Enums.MainQuestType.e_Raid:
                iconname = "Raid";
            break;
			case _global.Enums.MainQuestType.e_Scenario:
				iconname = "Scenario";
			break;
            case _global.Enums.MainQuestType.e_Lair:
                iconname = "Dungeon";
            break;
            case _global.Enums.MainQuestType.e_PvP:
                iconname = "PvP";
            break;
            case _global.Enums.MainQuestType.e_Massacre:
                iconname = "Massacre";
            break;
            case _global.Enums.MainQuestType.e_Item:
			case _global.Enums.MainQuestType.e_AreaMission:
                iconname = "Item";
            break;
			case _global.Enums.MainQuestType.e_InvestigationSide:
				iconname = "InvestigationSide";
			break;
			case _global.Enums.MainQuestType.e_DailyMission:
                iconname = "DailyMission";
            break;
			case _global.Enums.MainQuestType.e_DailyDungeon:
                iconname = "DailyDungeon";
            break;
			case _global.Enums.MainQuestType.e_DailyRandomDungeon:
                iconname = "DailyRandomDungeon";
            break;
			case _global.Enums.MainQuestType.e_DailyPvP:
                iconname = "DailyPvP";
            break;
			case _global.Enums.MainQuestType.e_DailyMassivePvP:
                iconname = "DailyMassivePvP";
            break;
			case _global.Enums.MainQuestType.e_DailyScenario:
                iconname = "DailyScenario";
            break;
			case _global.Enums.MainQuestType.e_WeeklyMission:
                iconname = "WeeklyMission";
            break;
			case _global.Enums.MainQuestType.e_WeeklyDungeon:
                iconname = "WeeklyDungeon";
            break;
			case _global.Enums.MainQuestType.e_WeeklyRaid:
                iconname = "WeeklyRaid";
            break;
			case _global.Enums.MainQuestType.e_WeeklyPvP:
                iconname = "WeeklyPvP";
            break;
			case _global.Enums.MainQuestType.e_WeeklyScenario:
                iconname = "WeeklyScenario";
            break;
			case _global.Enums.MainQuestType.e_MetaChallenge:
                iconname = "MetaChallenge";
            break;
			case _global.Enums.MainQuestType.e_EventMetaChallenge:
				iconname = "EventMetaChallenge";
			break;
		}
		return iconname;
	}
    
    
    /// returns the name and color of the MonsterBand thing
    public static function GetMissionDifficultyText(missionLevel:Number, playerLevel:Number, format:Object) : String
    {
		var difficulty:Number = missionLevel - playerLevel;
        format = (format == undefined) ? { face: "_Headline", size:10 } : format;
        var color:String = "#FFFFFF";
        var text:String = "";
        
        if (difficulty <= -2) // easy
        {
            color = Colors.ColorToHtml( Colors.e_Moderate );
        }
        else if (difficulty <= 0) // equal
        {
            color = Colors.ColorToHtml( Colors.e_Equal );
        }
        else if (difficulty <= 2) // Challenging
        {
            color = Colors.ColorToHtml( Colors.e_Challenging );
        }        
        else // Hard
        {
            color = Colors.ColorToHtml( Colors.e_Difficult );
        }
        format.color = color;
        return com.GameInterface.Utils.CreateHTMLString("("+LDBFormat.LDBGetText("Gamecode", "MissionLevel")+" "+missionLevel+")",format);
    }
	
	//returns the name of the slot that a missiontype will be added to
	public static function GetMissionSlotTypeName(missionType:Number) : String
	{
		switch( missionType )
		{
			case    _global.Enums.MainQuestType.e_Action:
			case    _global.Enums.MainQuestType.e_Sabotage:
			case    _global.Enums.MainQuestType.e_Challenge:
			case    _global.Enums.MainQuestType.e_Investigation:
			case	_global.Enums.MainQuestType.e_StoryRepeat:
				return LDBFormat.LDBGetText( "Quests", "MainMissionMixedCase" );
			case    _global.Enums.MainQuestType.e_Lair:
			case    _global.Enums.MainQuestType.e_Group:
            case    _global.Enums.MainQuestType.e_Raid:
			case	_global.Enums.MainQuestType.e_Scenario:
				return LDBFormat.LDBGetText( "Quests", "DungeonMissionMixedCase" );
			case    _global.Enums.MainQuestType.e_Story:
				return LDBFormat.LDBGetText( "Quests", "StoryMissionMixedCase" );
			case    _global.Enums.MainQuestType.e_Item:
			case	_global.Enums.MainQuestType.e_AreaMission:
			case    _global.Enums.MainQuestType.e_Massacre:
			case    _global.Enums.MainQuestType.e_InvestigationSide:
				return LDBFormat.LDBGetText( "Quests", "SideMissionMixedCase" );
			case    _global.Enums.MainQuestType.e_PvP:
				return LDBFormat.LDBGetText( "Quests", "PvPMissionMixedCase" );
				
		}
		return "";
	}
	
	//returns the name of the slot that a missiontype will be added to
	public static function GetMissionSlotTypeColor(missionType:Number) : String
	{
		switch( missionType )
		{
			case    _global.Enums.MainQuestType.e_Action:
			case    _global.Enums.MainQuestType.e_Sabotage:
			case    _global.Enums.MainQuestType.e_Challenge:
			case    _global.Enums.MainQuestType.e_Investigation:
			case	_global.Enums.MainQuestType.e_StoryRepeat:
				return "#824430";
			case    _global.Enums.MainQuestType.e_Lair:
			case    _global.Enums.MainQuestType.e_Group:
            case    _global.Enums.MainQuestType.e_Raid:
			case	_global.Enums.MainQuestType.e_Scenario:
				return "#715F8E";
			case    _global.Enums.MainQuestType.e_Story:
				return "#5099AA";
			case    _global.Enums.MainQuestType.e_Item:
			case    _global.Enums.MainQuestType.e_AreaMission:
			case    _global.Enums.MainQuestType.e_PvP:
			case    _global.Enums.MainQuestType.e_Massacre:
			case    _global.Enums.MainQuestType.e_InvestigationSide:
				return "#515956";
				
		}
		return "#000000";
	}
}