import com.Components.WindowComponentContent;
import com.GameInterface.ScenarioInterface;
import com.GameInterface.Scenario;
import com.GameInterface.Lore;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Game.Team;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.GroupElement;
import gfx.controls.DropdownMenu;
import gfx.controls.Button;
import com.Utils.LDBFormat;
import com.Utils.ID32
import com.GameInterface.DistributedValue;
import com.GameInterface.PvPMinigame.PvPMinigame;

class GUI.ScenarioInterface.ScenarioContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_SettingsLabel:TextField;
	private var m_LocationLabel:TextField;
	private var m_ObjectiveLabel:TextField;
	private var m_TimeLabel:TextField;
	private var m_DifficultyLabel:TextField;
	private var m_RoleLabel:TextField;
	
	private var m_LocationDropdown:DropdownMenu;
	private var m_ObjectiveDropdown:DropdownMenu;
	private var m_TimeDropdown:DropdownMenu;
	private var m_DifficultyDropdown:DropdownMenu;
	private var m_RoleDropdown:DropdownMenu;
	
	private var m_ScenarioName:TextField;
	private var m_ScenarioObjective:TextField;
	private var m_ScenarioDescription:TextField;
	private var m_ActivationStatus:TextField;
	
	private var m_ActivateButton:Button;
	
	//Variables
	private var m_Locations:Array;
	private var m_Objectives:Array;
	private var m_Descriptions:Array;
	private var m_Times:Array;
	private var m_Difficulties:Array;
	private var m_Roles:Array;
	private var m_PvPScenarios:Array;

	private var m_Team:Team;
	private var m_Initialized:Boolean;
	private var m_Reloading:Boolean;
	
	private var m_BuyDLC:Boolean;
	
	//Statics
	private static var NO_UNLOCK_REQ = -1;
	private static var ACTIVATE_LABEL = LDBFormat.LDBGetText("ScenarioGUI", "ActivateScenario");
	private static var PURCHASE_LABEL = LDBFormat.LDBGetText("ScenarioGUI", "PurchaseDLC");
	
	private static var BEGINNER = 0;
	private static var NORMAL = 1;
	private static var ELITE = 2;
	private static var NIGHTMARE = 3;
	private static var GROUP = 2;
	
	private static var DAMAGE = 0;
	private static var TANK = 1;
	private static var HEAL = 2;
	
	public function ScenarioContent()
	{
		super();
	}
	
	private function configUI()
	{
		m_Initialized = false;
		m_Times  = [
					LDBFormat.LDBGetText("ScenarioGUI", "Beginner"),
					LDBFormat.LDBGetText("ScenarioGUI", "Day"),
					LDBFormat.LDBGetText("ScenarioGUI", "Dusk"),
					LDBFormat.LDBGetText("ScenarioGUI", "Night")
				   ];
		
		m_Difficulties = [
						  LDBFormat.LDBGetText("ScenarioGUI", "Solo"),
						  LDBFormat.LDBGetText("ScenarioGUI", "Duo"),
						  LDBFormat.LDBGetText("ScenarioGUI", "Group")
						 ];
		m_Roles = [
				   LDBFormat.LDBGetText("ScenarioGUI", "DPS"),
				   LDBFormat.LDBGetText("ScenarioGUI", "Tank"),
				   LDBFormat.LDBGetText("ScenarioGUI", "Heal")
				  ];
		m_PvPScenarios = [ 5830 ]; //Shambala
		m_LocationDropdown.addEventListener("change", this, "SlotLocationChanged");
		m_ObjectiveDropdown.addEventListener("change", this, "SlotObjectiveChanged");
		m_TimeDropdown.addEventListener("change", this, "SlotDifficultyChanged");
		m_DifficultyDropdown.addEventListener("change", this, "SlotDifficultyChanged");
		m_RoleDropdown.addEventListener("change", this, "SlotRoleChanged");
		
		m_ActivateButton.addEventListener("click", this, "SlotActivateClicked");
		
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
		
		TeamInterface.SignalClientJoinedTeam.Connect(SlotClientJoinedTeam, this);
    	TeamInterface.SignalClientLeftTeam.Connect(SlotClientLeftTeam, this);
		
		TeamInterface.RequestTeamInformation();
		
		SetLabels();
		SetData();
	}
	
	private function SetLabels()
	{
		this.m_SettingsLabel.text = LDBFormat.LDBGetText("ScenarioGUI", "ScenarioSettings");
		this.m_LocationLabel.text = LDBFormat.LDBGetText("ScenarioGUI", "ScenarioLocation");
		this.m_ObjectiveLabel.text = LDBFormat.LDBGetText("ScenarioGUI", "ScenarioObjective");
		this.m_TimeLabel.text = LDBFormat.LDBGetText("ScenarioGUI", "ScenarioTime");
		this.m_DifficultyLabel.text = LDBFormat.LDBGetText("ScenarioGUI", "ScenarioDifficulty");
		this.m_RoleLabel.text = LDBFormat.LDBGetText("ScenarioGUI", "ScenarioRole");
	}
	
	private function SetData()
	{
		m_Objectives = new Array();
		for(var i:Number = 0; i<ScenarioInterface.m_Scenarios.length; i++)
		{
			var objective = LDBFormat.LDBGetText("ScenarioGUI", ScenarioInterface.m_Scenarios[i].m_Objective);
			m_Objectives.push(objective);
		}
		m_ObjectiveDropdown.dataProvider = m_Objectives;
		m_ObjectiveDropdown.selectedIndex = 0;
		m_ObjectiveDropdown.rowCount = m_ObjectiveDropdown.dataProvider.length;
		
		m_TimeDropdown.dataProvider = m_Times;
		m_TimeDropdown.selectedIndex = 1;
		m_TimeDropdown.rowCount = m_TimeDropdown.dataProvider.length;
		
		m_DifficultyDropdown.dataProvider = m_Difficulties;
		m_DifficultyDropdown.selectedIndex = 0;
		m_DifficultyDropdown.rowCount = m_DifficultyDropdown.dataProvider.length;
		
		m_RoleDropdown.dataProvider = m_Roles;
		m_RoleDropdown.selectedIndex = 0;
		m_RoleDropdown.rowCount = m_RoleDropdown.dataProvider.length;
		
		m_Initialized = true;
	}
	
	private function SetDescription()
	{
		this.m_ScenarioName.text = m_LocationDropdown.dataProvider[m_LocationDropdown.selectedIndex];
		this.m_ScenarioObjective.text = m_ObjectiveDropdown.dataProvider[m_ObjectiveDropdown.selectedIndex];
		this.m_ScenarioDescription.text = m_Descriptions[m_LocationDropdown.selectedIndex];
		this.m_ScenarioObjective2.text = m_ObjectiveDropdown.dataProvider[m_ObjectiveDropdown.selectedIndex] + ":";
		this.m_ObjectiveDescription.text = LDBFormat.LDBGetText("ScenarioGUI", ScenarioInterface.m_Scenarios[m_ObjectiveDropdown.selectedIndex].m_Objective + "_Description");
		SetActivationStatus();
	}
	
	private function SetActivationStatus()
	{
		m_ActivateButton.disabled = false;
		m_ActivateButton.label = ACTIVATE_LABEL;
		m_BuyDLC = false;
		if(!(TeamInterface.IsClientTeamLeader() || TeamInterface.GetClientTeamID().IsNull()))
		{
			this.m_ActivationStatus.text = LDBFormat.LDBGetText("ScenarioGUI", "TeamLeaderOnly");
			m_ActivateButton.disabled = true;
		}
		else
		{
			var playersNotPresent:Array = CheckLocations();
			var playersOnCooldown:Array = CheckCooldowns();
			var playersWithoutDLC:Array = CheckDLC();
			
			//Special restrictions for PvP Scenarios
			if (ScenarioInterface.m_Scenarios[scenarioIndex].m_Objective == "Objective_PvP")
			{
				//only allow solo signups
				//TODO: This may change in the future
				if (!TeamInterface.GetClientTeamID().IsNull())
				{
					this.m_ActivationStatus.text = LDBFormat.LDBGetText("ScenarioGUI", "SoloOnly");
					m_ActivateButton.disabled = true;
				}
				//Allowed to join PvP Minigame
				if (!PvPMinigame.CanSignUpForMinigame(m_PvPScenarios[m_LocationDropdown.selectedIndex]))
				{
					this.m_ActivationStatus.text = LDBFormat.LDBGetText("ScenarioGUI", "PvPNotAllowed");
					m_ActivateButton.disabled = true;
				}
			}
			
			else if (playersNotPresent.length > 0)
			{
				this.m_ActivationStatus.text = LDBFormat.LDBGetText("ScenarioGUI", "NotPresent");
				m_ActivateButton.disabled = true;
			}
			
			else if (playersWithoutDLC.length > 0)
			{
				if (TeamInterface.GetClientTeamID().IsNull())
				{
					m_ActivateButton.label = PURCHASE_LABEL;
					m_BuyDLC = true;
					this.m_ActivationStatus.text = LDBFormat.LDBGetText("ScenarioGUI", "NoDLC");
				}
				//We don't actually have team logic since we can only check the client
				//Just do the single player logic here for now.
				else
				{
					m_ActivateButton.label = PURCHASE_LABEL;
					m_BuyDLC = true;
					this.m_ActivationStatus.text = LDBFormat.LDBGetText("ScenarioGUI", "NoDLC");
				}
			}
			else if (playersOnCooldown.length > 0)
			{	
				m_ActivateButton.disabled = true;
				if (TeamInterface.GetClientTeamID().IsNull())
				{
					this.m_ActivationStatus.text = LDBFormat.LDBGetText("ScenarioGUI", "OnCooldown");
				}
				else
				{
					var activationString:String = LDBFormat.LDBGetText("ScenarioGUI", "TeamOnCooldown") + "\n";
					for(var i=0; i<playersOnCooldown.length; i++)
					{
						activationString = activationString + playersOnCooldown[i] + ", ";
					}
					activationString = activationString.slice(0, -2);
					this.m_ActivationStatus.text = activationString;
				}
			}
			else
			{
				this.m_ActivationStatus.text = "";
			}
		}
	}
	
	private function CheckLocations():Array
	{
		var notPresent = new Array()
		if (m_Team != undefined)
		{
			for (teamMember in m_Team.m_TeamMembers)
			{
				var groupElement:GroupElement = m_Team.m_TeamMembers[teamMember]
				groupElement.SignalCharacterEnteredClient.Connect(SetActivationStatus, this);
				groupElement.SignalCharacterExitedClient.Connect(SetActivationStatus, this);
				if(!groupElement.m_OnClient)
				{
					notPresent.push(m_Team.m_TeamMembers[teamMember].m_Name);
				}
			}
		}
		return notPresent;
	}
	
	private function CheckCooldowns():Array
	{
		var onCooldown = new Array();
		if (m_Team != undefined)
		{
			for (teamMember in m_Team.m_TeamMembers)
			{
				var character:Character = Character.GetCharacter(m_Team.m_TeamMembers[teamMember].m_CharacterId)
				character.SignalBuffAdded.Connect(SetActivationStatus, this);
				character.SignalBuffRemoved.Connect(SetActivationStatus, this);
				character.SignalBuffUpdated.Connect(SetActivationStatus, this);
				for(buff in character.m_InvisibleBuffList)
				{
					if(character.m_InvisibleBuffList[buff].m_BuffId == Number(ScenarioInterface.m_Scenarios[m_ObjectiveDropdown.selectedIndex].m_Lockouts[m_LocationDropdown.selectedIndex][GetDifficultyLockout()]))
					{
						onCooldown.push(m_Team.m_TeamMembers[teamMember].m_Name);
					}
				}				
			}
		}
		else
		{	
			var character:Character = Character.GetClientCharacter();
			character.SignalBuffAdded.Connect(SetActivationStatus, this);
			character.SignalBuffRemoved.Connect(SetActivationStatus, this);
			character.SignalBuffUpdated.Connect(SetActivationStatus, this);
			for(buff in character.m_InvisibleBuffList)
			{
				if(character.m_InvisibleBuffList[buff].m_BuffId == Number(ScenarioInterface.m_Scenarios[m_ObjectiveDropdown.selectedIndex].m_Lockouts[m_LocationDropdown.selectedIndex][GetDifficultyLockout()]))
				{
					onCooldown.push(Character.GetClientCharacter().GetName());
				}
			}
		}
		return onCooldown;
	}
	
	private function CheckDLC():Array
	{
		var noDLC = new Array();
		//TODO: Check team members tags when we can do that
		// For now only check the client.
		var unlockId:Number = ScenarioInterface.m_Scenarios[m_ObjectiveDropdown.selectedIndex].m_UnlockId[m_LocationDropdown.selectedIndex];
		if (unlockId != NO_UNLOCK_REQ && Lore.IsLocked(unlockId))
		{
			//Special case for HotelWahid, which is only locked for nightmare difficulty
			if (unlockId != 6278) //6278 is the hotel wahid tag
			{
				noDLC.push(Character.GetClientCharacter().GetName());
			}
			else if (m_TimeDropdown.selectedIndex == NIGHTMARE)
			{
				noDLC.push(Character.GetClientCharacter().GetName());
			}
		}
		return noDLC;
	}
	
	private function GetDifficultyLockout():Number
	{
		var nightDifficulty:Boolean = false;
		var group:Boolean = false;
		if (m_TimeDropdown.selectedIndex == NIGHTMARE) { nightDifficulty = true; }
		if (m_DifficultyDropdown.selectedIndex == GROUP) { group = true; }
		if (!nightDifficulty && !group) { return 0; }
		if (!nightDifficulty && group) 	{ return 1; }
		if (nightDifficulty && !group) { return 2; }
		if (nightDifficulty && group)  { return 3; }
	}
	
	private function SlotDifficultyChanged()
	{
		if (m_Initialized) { Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_click_tiny.xml"); }
		SetActivationStatus();
		RemoveFocus();
	}
	
	private function SlotObjectiveChanged()
	{
		if (m_Initialized) { Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_click_tiny.xml"); }
		var scenarioIndex = m_ObjectiveDropdown.selectedIndex
		m_Reloading = true;
		m_Locations = new Array();
		m_Descriptions = new Array();
		for (var i:Number = 0; i<ScenarioInterface.m_Scenarios[scenarioIndex].m_Location.length; i++)
		{
			var loc = LDBFormat.LDBGetText("ScenarioGUI", ScenarioInterface.m_Scenarios[scenarioIndex].m_Location[i]);
			m_Locations.push(loc)

			var description = LDBFormat.LDBGetText("ScenarioGUI", ScenarioInterface.m_Scenarios[scenarioIndex].m_Description[i]);
			m_Descriptions.push(description)
		}
		m_LocationDropdown.dataProvider = m_Locations;
		m_LocationDropdown.selectedIndex = 0;
		m_LocationDropdown.rowCount = m_LocationDropdown.dataProvider.length;
		m_Reloading = false;
		
		SetDescription();
		
		if (ScenarioInterface.m_Scenarios[scenarioIndex].m_Objective == "Objective_PvP")
		{
			m_TimeDropdown._visible = m_TimeLabel._visible = false;
			m_DifficultyDropdown._visible = m_DifficultyLabel._visible = false;
			m_RoleDropdown._visible = m_RoleLabel._visible = true;
		}
		else
		{
			m_TimeDropdown._visible = m_TimeLabel._visible = true;
			m_DifficultyDropdown._visible = m_DifficultyLabel._visible = true;
			m_RoleDropdown._visible = m_RoleLabel._visible = false;
		}
		
		RemoveFocus();
	}
	
	private function SlotLocationChanged()
	{
		if (m_Initialized && !m_Reloading) { Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_click_tiny.xml"); }
		SetDescription();
		RemoveFocus();
	}
	
	private function SlotRoleChanged()
	{
		if (m_Initialized) { Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_click_tiny.xml"); }
		RemoveFocus();
	}
	
	private function SlotActivateClicked()
	{
		if(m_BuyDLC)
		{
			var unlockId:Number = ScenarioInterface.m_Scenarios[m_ObjectiveDropdown.selectedIndex].m_UnlockId[m_LocationDropdown.selectedIndex];
			ScenarioInterface.OpenDLCShop(unlockId);
		}
		else if (ScenarioInterface.m_Scenarios[m_ObjectiveDropdown.selectedIndex].m_Objective == "Objective_PvP")
		{
			var playfield:Number = m_PvPScenarios[m_LocationDropdown.selectedIndex];
			var role:Number = roleMap(m_RoleDropdown.selectedIndex);
			PvPMinigame.SignUpForMinigame(playfield, role, false, true); //3rd parameter is join as group, this may change in the future
            Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_PvP_sign_in.xml");
			ScenarioInterface.CloseSetupInterface();
		}
		else
		{
			Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_rank.xml");
			var loc:Number = Number(ScenarioInterface.m_Scenarios[m_ObjectiveDropdown.selectedIndex].m_LocationId[m_LocationDropdown.selectedIndex]) + 1;
			var objective:Number = m_ObjectiveDropdown.selectedIndex + 1;
			var time:Number = timeMap(m_TimeDropdown.selectedIndex) + 1;
			var difficulty:Number = m_DifficultyDropdown.selectedIndex + 1;
			ScenarioInterface.ActivateScenario(loc, objective, time, difficulty);
		}
	}
	
	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}
	
	function SlotClientJoinedTeam(team:Team):Void
	{
		m_Team = team;
		m_Team.SignalCharacterJoinedTeam.Connect(SetActivationStatus, this);
		m_Team.SignalCharacterLeftTeam.Connect(SetActivationStatus, this);
		m_Team.SignalNewTeamLeader.Connect(SetActivationStatus, this);
		SetActivationStatus();
	}
	function SlotClientLeftTeam():Void
	{
		m_Team.SignalCharacterJoinedTeam.Disconnect(SetActivationStatus, this);
		m_Team.SignalCharacterLeftTeam.Disconnect(SetActivationStatus, this);
		m_Team.SignalNewTeamLeader.Disconnect(SetActivationStatus, this);
		m_Team = undefined;
		SetActivationStatus();
	}
	
	function timeMap(time:Number):Number
	{
		switch(time)
		{
			case BEGINNER:
				return 3;
				break;
			case NORMAL:
				return 0;
				break;
			case ELITE:
				return 1;
				break;
			case NIGHTMARE:
				return 2;
				break
		}
	}
	
	function roleMap(role:Number):Number
	{
		switch(role)
		{
			case DAMAGE:
				return _global.Enums.Class.e_Damage;
				break;
			case TANK:
				return _global.Enums.Class.e_Tank;
				break;
			case HEAL:
				return _global.Enums.Class.e_Heal;
				break;
		}
	}
	
	function SlotTagAdded():Void
	{
		SetActivationStatus();
	}
}