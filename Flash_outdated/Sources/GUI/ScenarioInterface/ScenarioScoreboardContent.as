import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import gfx.controls.ScrollingList;
import gfx.controls.Button;
import com.Utils.Colors;
import com.GameInterface.ScenarioInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Utils;

class GUI.ScenarioInterface.ScenarioScoreboardContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_ScenarioName:TextField;
	private var m_ScenarioObjective:TextField;
	private var m_ScenarioGroup:TextField;
	private var m_ScenarioDifficulty:TextField;
	private var m_ScenarioGrade:TextField;
	private var m_EarnedGrade:TextField;
	private var m_GradeBackground:MovieClip;
	
	private var m_EventScrollingList:ScrollingList;
	
	private var m_AcceptButton:Button;
	
	//Variables
	private var m_Timer1:Number;
	private var m_Timer2:Number;
	private var m_AnimateIndex:Number;
	private var m_Results:Array;
	private var m_Icon:String;

	//Statics
	private static var FAIL = LDBFormat.LDBGetText("ScenarioGUI", "Failed");
	private static var GOLD = LDBFormat.LDBGetText("ScenarioGUI", "Gold");
	private static var SILVER = LDBFormat.LDBGetText("ScenarioGUI", "Silver");
	private static var BRONZE = LDBFormat.LDBGetText("ScenarioGUI", "Bronze");
	private static var PLATINUM = LDBFormat.LDBGetText("ScenarioGUI", "Platinum");
	
	public function ScenarioScoreboardContent()
	{
		super();
	}
	
	private function onUnload()
	{
		clearInterval( m_Timer1 );
		clearInterval( m_Timer2 );
	}
	
	private function configUI()
	{		
		SetLabels();
		m_AcceptButton.addEventListener("click", this, "ExitScenario");
		m_AnimateIndex = 0;
		m_EarnedGrade._visible = false;
		m_GradeBackground._visible = false;
		parseScenarioResults(ScenarioInterface.m_Results);
	}
	
	//Set Labels
    private function SetLabels():Void
    {
    	m_AcceptButton.label = LDBFormat.LDBGetText("ScenarioGUI", "ExitScenario");
    }
	
	private function parseScenarioResults(resultsArray:Array)
	{
		//This is horrible, but it's AS2, so we have to do it
		var len:Number = 0;
		for (arg in resultsArray) len++;
		
		var args = new Array();
		args.push(resultsArray.scenarioName);
		args.push(resultsArray.scenarioObjective);
		args.push(resultsArray.scenarioGroup);
		args.push(resultsArray.scenarioDifficulty);
		args.push(resultsArray.earnedGrade);
		args.push(resultsArray.reward);
		
		len -= args.length;
		len = len/4;
		
		for (var i=1; i<len + 1; i++)
		{
			args.push(resultsArray["eventName"+i]);
			args.push(resultsArray["eventDescription"+i]);
			args.push(resultsArray["localizeDescription"+i]);
			args.push(resultsArray["eventColor"+i]);
		}
		
		m_Results = args;
		SetDisplay();
		m_Timer1 = setInterval(this, "AnimateScoreboard", 300);
	}
	
	public function SetDisplay():Void
	{
		m_ScenarioName.text = LDBFormat.LDBGetText("ScenarioGUI", m_Results[0]);
		m_ScenarioObjective.text = LDBFormat.LDBGetText("ScenarioGUI", m_Results[1]);
		m_ScenarioGroup.text = LDBFormat.LDBGetText("ScenarioGUI", m_Results[2]);
		m_ScenarioDifficulty.text = LDBFormat.LDBGetText("ScenarioGUI", m_Results[3]);
		m_ScenarioGrade.text = LDBFormat.LDBGetText("ScenarioGUI", "Overall_Grade");
		m_EarnedGrade.text = LDBFormat.LDBGetText("ScenarioGUI", m_Results[4]);
		switch(m_EarnedGrade.text)
		{
			case FAIL:
				Colors.ApplyColor(m_GradeBackground, Colors.e_ColorTimeoutFail);
				m_GradeBackground._alpha = 50;
				m_Icon = "";
				break;
			case PLATINUM:
				Colors.ApplyColor(m_GradeBackground, 0xd9d9d9);
				m_GradeBackground._alpha = 50;
				m_Icon = "grade_platinum_GET";
				break;
			case GOLD:
				Colors.ApplyColor(m_GradeBackground, 0xffd700);
				m_GradeBackground._alpha = 50;
				m_Icon = "grade_gold_GET";
				break;
			case SILVER:
				Colors.ApplyColor(m_GradeBackground, 0x606060);
				m_GradeBackground._alpha = 50;
				m_Icon = "grade_silver_GET";
				break;
			case BRONZE:
				Colors.ApplyColor(m_GradeBackground, 0x5B391E);
				m_GradeBackground._alpha = 50;
				m_Icon = "grade_bronze_GET";
				break;
			default:
				m_GradeBackground._alpha = 0;
		}
	}
	
	private function AnimateScoreboard()
	{
		if (m_AnimateIndex*4+6 < m_Results.length)
		{
			var i = 6+(4*m_AnimateIndex)
			var listItem:Object = new Object;
			listItem.m_Name = LDBFormat.LDBGetText("ScenarioGUI", m_Results[i]);
			var description:String = m_Results[i+1];
			if (Number(m_Results[i+2]) == 1){ description = LDBFormat.LDBGetText("ScenarioGUI", description); }
			listItem.m_Description = description;
			listItem.m_Color = Number(m_Results[i+3]);
			
			m_EventScrollingList.dataProvider.push(listItem);
			m_EventScrollingList.invalidateData();
			m_AnimateIndex += 1;
		}
		else
		{
			clearInterval( m_Timer1 );
			m_Timer2 = setInterval(this, "AnimateGrade", 200);
		}
	}
	
	private function AnimateGrade()
	{
		clearInterval( m_Timer2 );
		m_GradeBackground._visible = true;
		m_EarnedGrade._visible = true;
		if (m_Icon != "")
		{
			var iconAnimation:MovieClip = this.attachMovie(m_Icon, "iconAnimation", getNextHighestDepth());
			iconAnimation._x = 380;
			iconAnimation._y = 227;
			iconAnimation.gotoAndPlay(1);
		}
		else
		{
			m_EarnedGrade._width = 198;
		}
	}
	
	private function ExitScenario()
	{
		ScenarioInterface.LeaveScenario();
	}
	
}