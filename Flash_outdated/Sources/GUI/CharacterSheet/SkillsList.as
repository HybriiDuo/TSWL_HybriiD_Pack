import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.ButtonGroup;
import com.Utils.LDBFormat;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.TooltipUtils;
import GUI.CharacterSheet.SkillEntry;

class GUI.CharacterSheet.SkillsList extends UIComponent
{  
    private var m_OverviewHeader:TextField;
	private var m_PrimaryHeader:TextField;
	private var m_SecondaryHeader:TextField;
	private var m_LevelName:TextField;
	private var m_LevelValue:TextField;
	private var m_ItemPowerName:TextField;
	private var m_ItemPowerValue:TextField;
	private var m_HPName:TextField;
	private var m_HPValue:TextField;
	private var m_PrimaryWeaponButton:Button;
	private var m_SecondaryWeaponButton:Button;
    
	private var m_HP:SkillEntry;
	private var m_CombatPower:SkillEntry;
	private var m_HealingPower:SkillEntry;
	private var m_Protection:SkillEntry;
	private var m_HitRating:SkillEntry;
	private var m_CritChance:SkillEntry;
	private var m_CritPower:SkillEntry;
	private var m_DefenseRating:SkillEntry;
	private var m_EvadeChance:SkillEntry;
	
	private var m_WeaponButtonGroup:ButtonGroup;
	private var m_Character:Character;
	private var m_Inventory:Inventory;
	private var m_PrimaryWeaponIcon:MovieClip;
	private var m_SecondaryWeaponIcon:MovieClip;
    
    public function SkillsList()
    {
        super();
    }
	
	public function configUI()
	{
		m_Character = Character.GetClientCharacter();
		m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
		
		m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharID().GetInstance()));
		m_Inventory.SignalItemAdded.Connect( SlotItemAdded, this);
		m_Inventory.SignalItemRemoved.Connect( SlotItemRemoved, this);
		
		m_WeaponButtonGroup = new ButtonGroup();
		m_PrimaryWeaponButton.group = m_WeaponButtonGroup;
		m_PrimaryWeaponButton.data = 0;
		m_PrimaryWeaponButton.disableFocus = true;
		m_SecondaryWeaponButton.group = m_WeaponButtonGroup;
		m_SecondaryWeaponButton.data = 1;
		m_SecondaryWeaponButton.disableFocus = true;
		m_WeaponButtonGroup.addEventListener("change",this,"WeaponChanged");
		m_WeaponButtonGroup.setSelectedButton(m_PrimaryWeaponButton);
		SetWeaponButtonIcons();
		
		m_OverviewHeader.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "OverviewHeader");
		m_PrimaryHeader.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "PrimaryHeader");
		m_SecondaryHeader.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "SecondaryHeader");
		
		m_LevelName.text = LDBFormat.LDBGetText("CharacterSkillsGUI", 54);
		m_LevelValue.text = m_Character.GetStat(_global.Enums.Stat.e_Level, 2);
		
		m_ItemPowerName.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "GearScoreLabel");
		//How strong your equipment is relative to a zebra. Similar to horsepower.
		m_ItemPowerValue.text = m_Character.GetStat(_global.Enums.Stat.e_ZebraFactor, 2);
		
		m_HPName.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "HitPoints");
		m_HPValue.text = m_Character.GetStat(_global.Enums.Stat.e_Life, 2);
		
		InitializeSkills();
	}
	
	private function InitializeSkills()
	{
		m_CombatPower.SetSkill(_global.Enums.SkillType.e_Skill_CombatPower);
		m_HealingPower.SetSkill(_global.Enums.SkillType.e_Skill_HealingPower);
		m_Protection.SetSkill(_global.Enums.SkillType.e_Skill_PhysicalMitigation);
		m_HitRating.SetSkill(_global.Enums.SkillType.e_Skill_GlanceReduction);
		m_CritChance.SetSkill(_global.Enums.SkillType.e_Skill_CriticalChance);
		m_CritPower.SetSkill(_global.Enums.SkillType.e_Skill_CritPower);
		m_DefenseRating.SetSkill(_global.Enums.SkillType.e_Skill_GlanceChance);
		m_EvadeChance.SetSkill(_global.Enums.SkillType.e_Skill_EvadeChance);
		
	}
	
	public function SlotStatChanged(stat:Number)
	{
		if (stat == _global.Enums.Stat.e_Level)
		{
			m_LevelValue.text = m_Character.GetStat(_global.Enums.Stat.e_Level, 2);
		}
		else if (stat == _global.Enums.Stat.e_ZebraFactor)
		{
			m_ItemPowerValue.text = m_Character.GetStat(_global.Enums.Stat.e_ZebraFactor, 2);
		}
		else if (stat == _global.Enums.Stat.e_Life)
		{
			m_HPValue.text = m_Character.GetStat(_global.Enums.Stat.e_Life, 2);
		}
	}
	
	private function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number)
	{
		if (itemPos == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ||
			itemPos == _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot)
		{
			SetWeaponButtonIcons();
		}
	}
	
	private function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean)
	{
		if (itemPos == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ||
			itemPos == _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot)
		{
			SetWeaponButtonIcons();
		}
	}
	
	
	private function SetWeaponButtonIcons()
	{
		if (m_PrimaryWeaponIcon != undefined)
		{
			m_PrimaryWeaponIcon.removeMovieClip();
			m_PrimaryWeaponIcon = undefined;
		}
		if (m_SecondaryWeaponIcon != undefined)
		{
			m_SecondaryWeaponIcon.removeMovieClip();
			m_SecondaryWeaponIcon = undefined;
		}
		var primaryIcon:String = TooltipUtils.GetWeaponRequirementIconNameFromType(m_Inventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot).m_ItemTypeGUI);
		var secondaryIcon:String = TooltipUtils.GetWeaponRequirementIconNameFromType(m_Inventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot).m_ItemTypeGUI);
		if (primaryIcon != undefined)
		{
			m_PrimaryWeaponIcon = MovieClip(m_PrimaryWeaponButton).m_Content.attachMovie(primaryIcon, "m_Icon", MovieClip(m_PrimaryWeaponButton).m_Content.getNextHighestDepth());
			m_PrimaryWeaponIcon._width = m_PrimaryWeaponIcon._height = 35;
		}
		if (secondaryIcon != undefined)
		{
			m_SecondaryWeaponIcon = MovieClip(m_SecondaryWeaponButton).m_Content.attachMovie(secondaryIcon, "m_Icon", MovieClip(m_SecondaryWeaponButton).m_Content.getNextHighestDepth());
			m_SecondaryWeaponIcon._width = m_SecondaryWeaponIcon._height = 35;
		}		
	}
	
	private function WeaponChanged(button:Button):Void
	{
		if (button.data == 0)
		{
			Character.SetNextWeaponActive(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot);
		}
		if (button.data == 1)
		{
			Character.SetNextWeaponActive(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot);
		}
	}
}
