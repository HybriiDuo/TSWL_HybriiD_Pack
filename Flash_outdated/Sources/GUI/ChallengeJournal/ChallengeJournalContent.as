import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import com.GameInterface.Quests;
import com.GameInterface.Utils;
import GUI.ChallengeJournal.ScrollPanel;

class GUI.ChallengeJournal.ChallengeJournalContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_BonusBlocker:MovieClip;
	private var m_MoFTip:TextField;
	private var m_DailyTitle:TextField;
	private var m_DailyTime:TextField;
	private var m_DailyDivider:MovieClip;
	private var m_DailyPanel:ScrollPanel;
	
	private var m_WeeklyTitle:TextField;
	//private var m_WeeklyTime:TextField;
	private var m_WeeklyDivider:MovieClip;
	private var m_WeeklyPanel:ScrollPanel;
	
	/*
	private var m_OverallTitle:TextField;
	private var m_OverallDivider:MovieClip;
	private var m_OverallPanel:ScrollPanel;
	*/
	
	//Variables
	private var m_TimeInterval:Number;
	private var m_DailyTotal:Number;
	private var m_DailyComplete:Number;	
	private var m_WeeklyTotal:Number;
	private var m_WeeklyComplete:Number;
	/*
	private var m_MetaTotal:Number;
	private var m_MetaComplete:Number;
	*/

	//Statics
	private var PANEL_WIDTH:Number = 500;
	private var DAILY_HEIGHT:Number = 210;
	
	private var WEEKLY_HEIGHT:Number = 210;
	/*
	private var OVERALL_HEIGHT:Number = 166;	
	private var RESET_DAY:Number = 2;
	*/
	private var RESET_HOUR:Number = 7;
	private var RESET_MINUTE:Number = 0;
	private var RESET_SECOND:Number = 0;
	
	private var PANEL_TOP_PADDING:Number = 5;
	private var PANEL_BOTTOM_PADDING:Number = 10;
	
	public function ChallengeJournalContent()
	{
		super();
	}
	
	private function configUI():Void
	{	
		Layout();
		m_BonusBlocker.m_BonusBlockerText.text = LDBFormat.LDBGetText("GenericGUI", "BonusBlockerText");
		m_MoFTip.text = LDBFormat.LDBGetText("GenericGUI", "ChallengeJournal_MoFTip");
		m_TimeInterval = setInterval(this, "OnUpdateTime", 1000);
		OnUpdateTime();
		
		Quests.SignalTaskAdded.Connect(PopulateChallenges, this);
		Quests.SignalMissionRemoved.Connect(PopulateChallenges, this);
		Quests.SignalMissionCompleted.Connect(SlotMissionCompleted, this);
		Quests.SignalGoalProgress.Connect(SlotGoalUpdated, this );
		PopulateChallenges();
	}
	
	private function Layout():Void
	{
		m_DailyPanel.SetSize(PANEL_WIDTH, DAILY_HEIGHT);		
		m_WeeklyPanel.SetSize(PANEL_WIDTH, WEEKLY_HEIGHT);
		/*
		m_OverallPanel.SetSize(PANEL_WIDTH, OVERALL_HEIGHT);
		*/
		m_WeeklyTitle._y = m_WeeklyTime._y = m_DailyPanel._y + m_DailyPanel._height + PANEL_BOTTOM_PADDING;
		m_WeeklyDivider._y = m_WeeklyTitle._y + m_WeeklyTitle._height;
		m_WeeklyPanel._y = m_WeeklyDivider._y + PANEL_TOP_PADDING;
		
		/*
		m_OverallTitle._y = m_WeeklyPanel._y + m_WeeklyPanel._height + PANEL_BOTTOM_PADDING;
		m_OverallDivider._y = m_OverallTitle._y + m_OverallTitle._height;
		m_OverallPanel._y = m_OverallDivider._y + PANEL_TOP_PADDING;
		*/
		
		SignalSizeChanged.Emit();
	}
	
	private function PopulateChallenges():Void
	{		
		var activeChallenges:Array = Quests.GetAllActiveChallenges();		
		var dailyActive:Array = new Array();		
		var weeklyActive:Array = new Array();
		
		/*
		var metaActive:Array = new Array();
		*/
		for (var i=0; i<activeChallenges.length; i++)
		{
			switch(activeChallenges[i].m_MissionType)
			{
				case _global.Enums.MainQuestType.e_DailyMission:
				case _global.Enums.MainQuestType.e_DailyDungeon:
				case _global.Enums.MainQuestType.e_DailyRandomDungeon:
				case _global.Enums.MainQuestType.e_DailyPvP:
				case _global.Enums.MainQuestType.e_DailyMassivePvP:
				case _global.Enums.MainQuestType.e_DailyScenario:
					dailyActive.push(activeChallenges[i]);
					break;
				
				case _global.Enums.MainQuestType.e_WeeklyMission:
				case _global.Enums.MainQuestType.e_WeeklyDungeon:
				case _global.Enums.MainQuestType.e_WeeklyRaid:
				case _global.Enums.MainQuestType.e_WeeklyPvP:
				case _global.Enums.MainQuestType.e_WeeklyScenario:
					weeklyActive.push(activeChallenges[i]);
					break;
				/*
				case _global.Enums.MainQuestType.e_MetaChallenge:
				case _global.Enums.MainQuestType.e_EventMetaChallenge:
					metaActive.push(activeChallenges[i]);
					break;
				*/
				default:
			}
		}
		dailyActive.sortOn("m_SortOrder");
		m_DailyTotal = dailyActive.length;
		
		weeklyActive.sortOn("m_SortOrder");
		m_WeeklyTotal = weeklyActive.length;
		/*
		metaActive.sortOn("m_SortOrder");
		m_MetaTotal = metaActive.length;
		*/
		
		var completeChallenges:Array = Quests.GetAllCompletedChallenges();
		var dailyComplete:Array = new Array();
		var weeklyComplete:Array = new Array();
		/*
		var metaComplete:Array = new Array();
		*/
		for (var i=0; i<completeChallenges.length; i++)
		{
			switch(completeChallenges[i].m_MissionType)
			{
				case _global.Enums.MainQuestType.e_DailyMission:
				case _global.Enums.MainQuestType.e_DailyDungeon:
				case _global.Enums.MainQuestType.e_DailyRandomDungeon:
				case _global.Enums.MainQuestType.e_DailyPvP:
				case _global.Enums.MainQuestType.e_DailyMassivePvP:
				case _global.Enums.MainQuestType.e_DailyScenario:
					dailyComplete.push(completeChallenges[i]);
					break;
				
				case _global.Enums.MainQuestType.e_WeeklyMission:
				case _global.Enums.MainQuestType.e_WeeklyDungeon:
				case _global.Enums.MainQuestType.e_WeeklyRaid:
				case _global.Enums.MainQuestType.e_WeeklyPvP:
				case _global.Enums.MainQuestType.e_WeeklyScenario:
					weeklyComplete.push(completeChallenges[i]);
					break;
				/*
				case _global.Enums.MainQuestType.e_MetaChallenge:
				case _global.Enums.MainQuestType.e_EventMetaChallenge:
					metaComplete.push(completeChallenges[i]);
					break;
				*/
				default:
			}
		}
		dailyComplete.sortOn("m_SortOrder");
		m_DailyComplete = dailyComplete.length;
		m_DailyTotal += m_DailyComplete;
		weeklyComplete.sortOn("m_SortOrder");
		m_WeeklyComplete = weeklyComplete.length;
		m_WeeklyTotal += m_WeeklyComplete;
		/*
		metaComplete.sortOn("m_SortOrder");
		m_MetaComplete = metaComplete.length;
		m_MetaTotal += m_MetaComplete;
		*/
		
		m_DailyPanel.SetData(dailyActive.concat(dailyComplete));
		m_WeeklyPanel.SetData(weeklyActive.concat(weeklyComplete));
		/*
		m_OverallPanel.SetData(metaActive.concat(metaComplete));
		*/
		
		UpdateHeaders();
		UpdateBonusBlocker();
	}
	
	private function UpdateHeaders():Void
	{
		var TDBComplete:String = LDBFormat.LDBGetText("GenericGUI", "completeHeader");
		m_DailyTitle.text = LDBFormat.LDBGetText("GenericGUI", "ChallengeJournal_DailyChallenges");	
		m_WeeklyTitle.text = LDBFormat.LDBGetText("GenericGUI", "ChallengeJournal_WeeklyChallenges");		
		/*
		m_OverallTitle.text = LDBFormat.LDBGetText("GenericGUI", "ChallengeJournal_Overall");
		*/
		
		m_DailyTitle.text += " " + m_DailyComplete + "/";
		m_WeeklyTitle.text += " " + m_WeeklyComplete + "/";
		/*
		m_OverallTitle.text += " " + m_MetaComplete + "/";
		*/
		m_DailyTitle.text += m_DailyTotal + " " + TDBComplete;
		m_WeeklyTitle.text += m_WeeklyTotal + " " + TDBComplete;
		/*
		m_OverallTitle.text += m_MetaTotal + " " + TDBComplete;
		*/
	}
	
	private function UpdateBonusBlocker():Void
	{
		if (m_DailyComplete == m_DailyTotal)
		{
			m_BonusBlocker._visible = false;
			m_WeeklyPanel._visible = true;
		}
		else
		{
			m_WeeklyPanel._visible = false;
			m_BonusBlocker._visible = true;
			m_BonusBlocker._x = m_WeeklyPanel._x;
			m_BonusBlocker._y = m_WeeklyPanel._y;
			m_BonusBlocker.m_Background._width = PANEL_WIDTH;
			m_BonusBlocker.m_Background._height = WEEKLY_HEIGHT;
		}
	}
	
	private function OnUpdateTime():Void
	{
		m_DailyTime.text = LDBFormat.LDBGetText("GenericGUI", "ChallengeJournal_TimeRemaining") + " " + GetDailyTimeRemaining();
		//m_WeeklyTime.text = LDBFormat.LDBGetText("GenericGUI", "ChallengeJournal_TimeRemaining") + " " + GetWeeklyTimeRemaining();
	}
	
	private function GetDailyTimeRemaining():String
	{
		var currentDate:Date = new Date();
		
		var needHours:Number = GetNeedHours(currentDate);
		var needMinutes:Number = GetNeedMinutes(currentDate);
		var needSeconds:Number = GetNeedSeconds(currentDate);
		
		var needMinutesStr:String = needMinutes > 9 ? needMinutes : "0" + needMinutes;
		
		return needHours + ":" + needMinutesStr;
	}
	/*
	private function GetWeeklyTimeRemaining():String
	{
		var currentDate:Date = new Date();
		
		var needDays:Number = GetNeedDays(currentDate);
		var needHours:Number = GetNeedHours(currentDate);
		var needMinutes:Number = GetNeedMinutes(currentDate);
		var needSeconds:Number = GetNeedSeconds(currentDate);
		
		if (needDays > 0)
		{
			return LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "TimeFormatDays"), needDays)
		}
		
		var needMinutesStr:String = needMinutes > 9 ? needMinutes : "0" + needMinutes;		
		return needHours + ":" + needMinutesStr;
	}
	private function GetNeedDays(currentDate:Date):Number
	{
		var desiredDay:Number = RESET_DAY;
		var currentDay = currentDate.getUTCDay();
		var needDays:Number = desiredDay - currentDay;
		if(currentDate.getUTCHours() >= RESET_HOUR){needDays--};
		if (needDays < 0){needDays += 7;}
		return needDays;
	}
	*/
	
	private function GetNeedHours(currentDate:Date):Number
	{
		var desiredHours:Number = RESET_HOUR;
		var currentHours = currentDate.getUTCHours();
		var needHours:Number = desiredHours - currentHours;		
		if(currentDate.getUTCMinutes() >= RESET_MINUTE){needHours--};
		if (needHours < 0){needHours += 24;}
		return needHours;
	}
	
	private function GetNeedMinutes(currentDate:Date):Number
	{
		var desiredMinutes:Number = RESET_MINUTE;
		var currentMinutes = currentDate.getUTCMinutes();
		var needMinutes:Number = desiredMinutes - currentMinutes;
		if(currentDate.getUTCSeconds() >= RESET_SECOND){needMinutes--};
		if (needMinutes < 0){needMinutes += 60;}
		return needMinutes;
	}
	
	private function GetNeedSeconds(currentDate:Date):Number
	{
		var desiredSeconds:Number = RESET_SECOND;
		var currentSeconds = currentDate.getUTCSeconds();
		var needSeconds:Number = desiredSeconds - currentSeconds;
		if (needSeconds < 0){needSeconds += 60;}
		return needSeconds;
	}
	
	private function SlotMissionCompleted(missionID:Number):Void
	{
		switch(Quests.GetQuest(missionID, false, false).m_MissionType)
		{
			case _global.Enums.MainQuestType.e_DailyMission:
			case _global.Enums.MainQuestType.e_DailyDungeon:
			case _global.Enums.MainQuestType.e_DailyRandomDungeon:
			case _global.Enums.MainQuestType.e_DailyPvP:
			case _global.Enums.MainQuestType.e_DailyMassivePvP:
			case _global.Enums.MainQuestType.e_DailyScenario:
				m_DailyPanel.MissionCompleted(missionID);
				m_DailyComplete += 1;
				break;

			case _global.Enums.MainQuestType.e_WeeklyMission:
			case _global.Enums.MainQuestType.e_WeeklyDungeon:
			case _global.Enums.MainQuestType.e_WeeklyRaid:
			case _global.Enums.MainQuestType.e_WeeklyPvP:
			case _global.Enums.MainQuestType.e_WeeklyScenario:
				m_WeeklyPanel.MissionCompleted(missionID);
				m_WeeklyComplete += 1;
				break;
			/*
			case _global.Enums.MainQuestType.e_MetaChallenge:
			case _global.Enums.MainQuestType.e_EventMetaChallenge:
				m_OverallPanel.MissionCompleted(missionID);
				m_MetaComplete += 1;
				break;
			*/
			default:
		}
		UpdateHeaders();
		UpdateBonusBlocker();
	}
	
	private function SlotGoalUpdated(tierID:Number, goalID:Number, solvedTimes:Number, repeatCount:Number):Void
	{
		m_DailyPanel.GoalUpdated(goalID, solvedTimes);
		m_WeeklyPanel.GoalUpdated(goalID, solvedTimes);
		/*
		m_OverallPanel.GoalUpdated(goalID, solvedTimes);
		*/
	}
}