import com.Components.WindowComponentContent;
import com.GameInterface.Game.Character;
import com.GameInterface.SpellBase
import com.GameInterface.Quests;
import com.GameInterface.Utils;
import gfx.controls.ScrollingList;
import gfx.controls.Button;
import gfx.controls.ButtonGroup;
import com.Utils.LDBFormat;
import mx.utils.Delegate;

class GUI.LockoutTimers.LockoutTimersContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_Description:TextField;
	private var m_ItemList:ScrollingList;
	//private var m_DungeonTab:Button;
	private var m_RaidTab:Button;
	private var m_ScenarioTab:Button;
	private var m_MissionTab:Button;
	
	//Variables
	private var m_TabGroup:ButtonGroup;

	//Statics
	/* Dungeons don't have lockouts anymore
	private static var m_DungeonList:Array = [
											   7522763, //The Polaris
											   7522770, //Hell Raised
											   7522771, //Darkness War
											   7522772, //The Ankh
											   7522791, //Hell Fallen
											   7522792, //The Facility
											   7522793, //Hell Eternal
											   7522794, //The Slaughterhouse
											   9117707	//Orochi Tower - Penthouse
											  ]
	*/
	private static var m_RaidList:Array = [
										   7961764, //Manhattan Exclusion Zone
										   8157728, //N'aga-Pei the Corpse-Island
										   9121640,	//Corrupted Agartha
										   9125207, //Manhattan Exclusion Zone - Nightmare
										   9166680, //N'aga-Pei the Corpse-Island - Nightmare
										   9166679 //Corrupted Agartha - Nightmare
										  ]
	private static var m_ScenarioList:Array = [
											   8354752, //Hotel Wahid normal
											   8371313, //Hotel Wahid group
											   8371312, //Hotel Wahid night
											   8371314, //Hotel Wahid night group
											   8354755, //Franklin Mansion normal
											   8371317, //Franklin Mansion group
											   8371315, //Franklin Mansion night
											   8371318, //Franklin Mansion night group
											   8354756, //Dracuelas Castle normal
											   8371320, //Dracuelas Castle group
											   8371319, //Dracuelas Castle night
											   8371321  //Dracuelas Castle night group
									   		  ]
									   
	private static var TYPE_BUFF = 0;
	private static var TYPE_MISSION = 1;
	private static var MAX_ROWS = 7;
	
	public function LockoutTimersContent()
	{
		super();
	}
	
	private function configUI()
	{		
		m_TabGroup = new ButtonGroup();
		/*
		m_DungeonTab.group = m_TabGroup;
		m_DungeonTab.data = 0;
		*/
		m_RaidTab.group = m_TabGroup;
		m_RaidTab.data = 0;
		m_ScenarioTab.group = m_TabGroup;
		m_ScenarioTab.data = 1;
		m_MissionTab.group = m_TabGroup;
		m_MissionTab.data = 2;
		
		//Hide scenarios tab if gametweak is not active
		var hideScenarios:Number = Utils.GetGameTweak("Disable_I8_Scenario_Lockout_GUI");
		if (hideScenarios == 1)
		{
			m_ScenarioTab._visible = false;
			m_MissionTab._x -= 70;
		}
		
		m_TabGroup.addEventListener("change",this,"TabChanged");
		m_ItemList.addEventListener("focusIn", this, "RemoveFocus");
		SetLabels();
		m_TabGroup.setSelectedButton(m_RaidTab);
	}
	
	//Set Labels
    private function SetLabels():Void
    {
        m_Description.text = LDBFormat.LDBGetText("GenericGUI", "Lockout");
		//m_DungeonTab.label = LDBFormat.LDBGetText("GenericGUI", "LockoutDungeons");
		m_RaidTab.label = LDBFormat.LDBGetText("GenericGUI", "LockoutRaids");
		m_ScenarioTab.label = LDBFormat.LDBGetText("GenericGUI", "LockoutScenarios");
		m_MissionTab.label = LDBFormat.LDBGetText("GenericGUI", "LockoutMissions");
    }
	
	private function GetLockoutsFromBuffs(buffArray:Array, iconString:String):Array
	{
		var lockoutList = new Array();
		for(var i=0; i<buffArray.length; i++)
		{
			var listItem:Object = new Object;
			listItem.m_Name = SpellBase.GetBuffData(buffArray[i]).m_Name;
			listItem.m_TotalTime = undefined;
			listItem.m_TimerType = TYPE_BUFF;
			listItem.m_IconName = iconString;
			for(buff in Character.GetClientCharacter().m_InvisibleBuffList)
			{
				if(Character.GetClientCharacter().m_InvisibleBuffList[buff].m_BuffId == buffArray[i])
				{
					listItem.m_TotalTime = Character.GetClientCharacter().m_InvisibleBuffList[buff].m_TotalTime;
				}
			}
			if (listItem.m_TotalTime){ lockoutList.unshift(listItem); }
			else { lockoutList.push(listItem); }
		}
		return lockoutList;
	}
	
	private function TabChanged(button:Button):Void
	{
		if (m_MissionTab.getDepth() > m_ScenarioTab.getDepth()){ m_MissionTab.swapDepths(m_ScenarioTab); }
		if (m_ScenarioTab.getDepth() > m_RaidTab.getDepth()){ m_ScenarioTab.swapDepths(m_RaidTab); }
		//if (m_RaidTab.getDepth() > m_DungeonTab.getDepth()){ m_RaidTab.swapDepths(m_DungeonTab); }
		/* Dungeons don't have lockouts anymore
		if (button.data == m_DungeonTab.data) 
		{ 
			m_ItemList.dataProvider = GetLockoutsFromBuffs(m_DungeonList, "DungeonIcon");
			m_ItemList.invalidateData();
			SetScrollBarVisibility();
		}
		*/
		if (button.data == m_RaidTab.data)
		{
			//m_RaidTab.swapDepths(m_DungeonTab);
			m_ItemList.dataProvider = GetLockoutsFromBuffs(m_RaidList, "RaidIcon");
			m_ItemList.invalidateData();
			SetScrollBarVisibility();
		}
		else if (button.data == m_ScenarioTab.data)
		{
			m_ScenarioTab.swapDepths(m_RaidTab);
			m_ItemList.dataProvider = GetLockoutsFromBuffs(m_ScenarioList, "ScenarioIcon");
			m_ItemList.invalidateData();
			SetScrollBarVisibility();
		}
		else if (button.data == m_MissionTab.data)
		{
			if (m_ScenarioTab._visible){	m_MissionTab.swapDepths(m_ScenarioTab); }
			else { m_MissionTab.swapDepths(m_RaidTab); }
			
			var missions:Array = Quests.GetAllQuestsOnCooldown();
			var missionLockoutList:Array = new Array();
			for (mission in missions)
			{
				if (missions[mission].m_CooldownExpireTime)
				{
					var listItem:Object = new Object;
					listItem.m_Name = missions[mission].m_MissionName;
					listItem.m_TimerType = TYPE_MISSION;
					listItem.m_IconName = GUI.Mission.MissionUtils.MissionTypeToString( missions[mission].m_MissionType ) + "Icon";
					listItem.m_TotalTime = missions[mission].m_CooldownExpireTime;
					missionLockoutList.push(listItem);
				}
			}
			m_ItemList.dataProvider = missionLockoutList;
			m_ItemList.invalidateData();
			SetScrollBarVisibility();
		}
		RemoveFocus()
	}
	
	//Remove Focus
    private function RemoveFocus():Void
    {
        Selection.setFocus(null);
    }
	
	private function SetScrollBarVisibility():Void
	{
		if (m_ItemList.dataProvider.length > MAX_ROWS){ m_ItemList.scrollBar._visible = true; }
		else { m_ItemList.scrollBar._visible = false; }
	}
}