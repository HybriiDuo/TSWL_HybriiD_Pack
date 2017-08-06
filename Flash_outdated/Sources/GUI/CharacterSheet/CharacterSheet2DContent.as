import com.Components.WindowComponentContent;
import gfx.controls.Button;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.Game.Character;
import com.GameInterface.DistributedValue;
import com.Utils.ID32;
import com.Utils.LDBFormat;

class GUI.CharacterSheet.CharacterSheet2DContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_Equipment:MovieClip;
	private var m_NameBox:MovieClip;
	private var m_SkillsList:MovieClip;
	private var m_DressingRoomButton:Button;
	private var m_SprintsPetsButton:Button;
	private var m_AbilitiesButton:Button;
	
	private var m_StatsHeader:TextField;
	private var m_EquipmentHeader:TextField;
	private var m_WeaponsHeader:TextField;
	private var m_OtherHeader:TextField;
	
	//Variables
	private var m_Character:Character;

	//Statics
	
	public function CharacterSheet2DContent()
	{
		super();
	}
	
	private function configUI():Void
	{	
		m_Character = Character.GetClientCharacter();
		SetLabels();
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
		SetNameBox();
		
		m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
		SlotStatChanged(_global.Enums.Stat.e_Level);
		
		m_DressingRoomButton.addEventListener( "click", this, "SlotDressingRoomClicked" );
		m_DressingRoomButton.label = LDBFormat.LDBGetText("MiscGUI", "CharacterSheet_DressingRoom");
		
		m_SprintsPetsButton.addEventListener( "click", this, "SlotSprintsPetsClicked" );
		m_SprintsPetsButton.label = LDBFormat.LDBGetText("MiscGUI", "CharacterSheet_SprintsPets");
		m_SprintsPetsButton.disabled = !DistributedValue.GetDValue("PetsSprints_Allowed")
		
		m_AbilitiesButton.addEventListener( "click", this, "SlotAbilitiesClicked" );
		m_AbilitiesButton.label = LDBFormat.LDBGetText("MiscGUI", "CharacterSheet_Skillhive");
		m_AbilitiesButton.disabled = !DistributedValue.GetDValue("Skillhive_Allowed")
	}
	
	private function SetLabels()
	{
		m_StatsHeader.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "StatsHeader");
		m_EquipmentHeader.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "EquipmentHeader");
		m_WeaponsHeader.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "WeaponsHeader");
		m_OtherHeader.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "OtherHeader");
	}
	
	private function SetNameBox():Void
	{
		var currentTag:LoreNode = Lore.GetCurrentFactionRankNode();
		
		m_NameBox.m_TitleDropdown.disableFocus = true;
		
		m_NameBox.m_FactionRankIcon.autoSize = true;
		m_NameBox.m_FactionRankIcon.source = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + currentTag.m_Icon;
		m_NameBox.m_FactionRankIcon._y = -20;
		
		m_NameBox.m_CharacterName.text = m_Character.GetFirstName() + " " + '"' + m_Character.GetName() + '"' + " " + m_Character.GetLastName();		
		
		UpdateTitleDropdownContents();
		
		m_NameBox.m_TitleDropdown.rowCount = 13;
		m_NameBox.m_TitleDropdown.addEventListener("change", this, "TitleSelected");
		//CenterNameBox();
	}
	
	private function CenterNameBox()
	{
		var boxWidth = m_NameBox.m_FactionRankIcon._x + m_NameBox.m_FactionRankIcon._width;
		m_NameBox._x = this._width/2 - boxWidth/2;
	}
	
	private function UpdateTitleDropdownContents() : Void
	{
		var array:Array = Lore.GetTitleArray();
		var tag:Number = m_Character.GetStat(_global.Enums.Stat.e_SelectedTag);
		m_NameBox.m_TitleDropdown.dataProvider = array;
		for ( var i:Number = 0; i < array.length; ++i )
		{
			if (array[i].id == tag)
			{
				m_NameBox.m_TitleDropdown.selectedIndex = i;
				break;
			}
		}
	}
	
	private function TitleSelected(event:Object) : Void
	{
		var newTitle:Number = m_NameBox.m_TitleDropdown.dataProvider[ event.target.selectedIndex ].id;
		if (newTitle != m_Character.GetStat(_global.Enums.Stat.e_SelectedTag))
		{
			Lore.SetSelectedTag(newTitle);
		}
		Selection.setFocus(null);
	}
	
	function SlotTagAdded(tagId:Number, characterId:ID32)
	{
		if (!characterId.Equal(Character.GetClientCharID()))
		{
			return;
		}
		if (Lore.GetTagType(tagId) != _global.Enums.LoreNodeType.e_FactionTitle && Lore.GetTagType(tagId) != _global.Enums.LoreNodeType.e_Title)
		{
			return;
		}
		UpdateTitleDropdownContents();
	}
	
	private function SlotStatChanged(stat:Number)
	{
		if (stat == _global.Enums.Stat.e_Level)
		{
			m_NameBox.m_Level.text = m_Character.GetStat(_global.Enums.Stat.e_Level, 2);
		}
	}
	
	private function SlotDressingRoomClicked()
	{
		DistributedValue.SetDValue("dressingRoom_window", true);
		Selection.setFocus(null);
	}
	private function SlotSprintsPetsClicked()
	{
		DistributedValue.SetDValue("petInventory_window", true);
		Selection.setFocus(null);
	}
	private function SlotAbilitiesClicked()
	{
		DistributedValue.SetDValue("skillhive_window", true);
		Selection.setFocus(null);
	}
}