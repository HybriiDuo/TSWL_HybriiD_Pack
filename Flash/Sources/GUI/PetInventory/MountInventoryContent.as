import GUI.PetInventory.PetInventoryContentBase
import com.Utils.LDBFormat;
import com.Utils.Archive;
import gfx.controls.Button;
import gfx.controls.CheckBox;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.LoreBase;
import com.GameInterface.SpellBase;
import com.GameInterface.Utils;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.ShopInterface;
import com.GameInterface.Game.Character;
import com.Utils.Colors;
import mx.utils.Delegate;
import com.Utils.Text;
import GUI.PetInventory.PetClip;
import gfx.controls.DropdownMenu;

class GUI.PetInventory.MountInventoryContent extends PetInventoryContentBase
{
	//Components created in .fla
	//Check PetInventoryContentBase
	private var m_SprintLevelText:TextField;
	private var m_TypeLabel:TextField;
	private var m_EquipLabel:TextField;
	private var m_TypeDropdown:DropdownMenu;
	private var m_EquipDropdown:DropdownMenu;
	private var m_SpeedDropdown:DropdownMenu;
	private var m_UpgradeSprintButton:MovieClip;

	//Variables
	//Check PetInventoryContentBase
	private var m_SprintFeats:Array;
	private var m_SprintItems:Array;

	//Statics
	//Check PetInventoryContentBase
	private var DEFAULT_SPRINT_ID:Number = 7913;

	public function MountInventoryContent()
	{
		super();
	}

	private function configUI()
	{		
		super.configUI();
		
		//Setup static values
		//These aren't really static. We have to do it this way because of superclassing.
		//They still look like static values to keep people from changing them!
		ICONS_START_X = 5;
		ICONS_START_Y = 97;
		ICONS_BUFFER = 7.75;
		ICONS_PER_ROW = 10;
		NODES_PER_PAGE = 30;
		
		m_SprintFeats = new Array();
		m_SprintFeats.push(Utils.GetGameTweak("SprintTier1Feat"));
		m_SprintFeats.push(Utils.GetGameTweak("SprintTier2Feat"));
		m_SprintFeats.push(Utils.GetGameTweak("SprintTier3Feat"));
		m_SprintFeats.push(Utils.GetGameTweak("SprintTier4Feat"));
		m_SprintFeats.push(Utils.GetGameTweak("SprintTier5Feat"));
		m_SprintFeats.push(Utils.GetGameTweak("SprintTier6Feat"));
		
		m_SprintItems = new Array();
		m_SprintItems.push([0]); //There is no item for this sprint, this is placeholder
		m_SprintItems.push([9306766]);
		m_SprintItems.push([9306768, 9306765]);
		m_SprintItems.push([9306769, 9306764]);
		m_SprintItems.push([9306770]);
		m_SprintItems.push([9306771]);
		UpdateSprintLevels();
		
		FeatInterface.SignalFeatTrained.Connect(SlotFeatTrained, this);
		m_EquipDropdown.disableFocus = true;
		m_EquipDropdown.addEventListener("change", this, "EquipStyleChanged");
		m_TypeDropdown.disableFocus = true;
		m_TypeDropdown.addEventListener("change", this, "FiltersChanged");
		m_SpeedDropdown.disableFocus = true;
		m_SpeedDropdown.addEventListener("change", this, "SpeedChanged");
		
		m_UpgradeSprintButton.onMouseRelease = Delegate.create(this, UpgradeSprint);
		
		SignalLoaded.Emit();
	}
	
	private function OnModuleActivated(config:Archive):Void
	{
		super.OnModuleActivated(config);
		m_EquipDropdown.selectedIndex = m_MountEquipStyle;
		m_TypeDropdown.selectedIndex = m_VisibleMountType;
		UpdateSelectedSprint();
	}

	//Set Labels
	private function SetLabels():Void
	{
		super.SetLabels();
		m_OwnedButtonText = LDBFormat.LDBGetText("GenericGUI", "SummonMount");
		m_PurchaseButtonText = LDBFormat.LDBGetText("GenericGUI", "BuyMount");
		m_EquipLabel.text = LDBFormat.LDBGetText("GenericGUI", "MountEquipPreference");
		m_TypeLabel.text = LDBFormat.LDBGetText("GenericGUI", "MountShowType");
		
		m_EquipDropdown.dataProvider = [LDBFormat.LDBGetText("GenericGUI", "MountSelected"),
									    LDBFormat.LDBGetText("GenericGUI", "MountRandom"),
									    LDBFormat.LDBGetText("GenericGUI", "MountFavorite")
									   ];
		m_TypeDropdown.dataProvider = [LDBFormat.LDBGetText("GenericGUI", "MountTypeAll"),
									   LDBFormat.LDBGetText("GenericGUI", "MountTypeSprint"),
									   LDBFormat.LDBGetText("GenericGUI", "MountTypeClassic")
									   ];
	}
	
	private function UpgradeSprint() : Void
	{
		for (var i:Number = 0; i < m_SprintFeats.length; i++)
		{
			var sprintFeat:FeatData = FeatInterface.m_FeatList[m_SprintFeats[i]]
			if (!sprintFeat.m_Trained)
			{
				if (i == 0)
				{
					//Don't have sprint 1? Just give it to them
					FeatInterface.TrainFeat(m_SprintFeats[0])
					return;
				}
				else
				{
					ShopInterface.SignalOpenInstantBuy.Emit(m_SprintItems[i]);
					return;
				}
			}
		}
	}
	
	private function UpdateSprintLevels() : Void
	{
		m_SprintLevelText.text = LDBFormat.LDBGetText("GenericGUI", "SprintLevel");
		var speedArray:Array = new Array();
		var firstUntrained:FeatData = undefined;
		var firstUntrainedIndex:Number = -1;
		for (var i:Number = 0; i < m_SprintFeats.length; i++)
		{
			if (FeatInterface.m_FeatList[m_SprintFeats[i]].m_Trained)
			{
				speedArray.push(GetSprintLevelText(i) + " - " + LDBFormat.LDBGetText("GenericGUI", "SprintMaxSpeed") + " " + GetSprintSpeed(i) + "%");
			}
			else if (firstUntrained == undefined)
			{
				firstUntrained = FeatInterface.m_FeatList[m_SprintFeats[i]];
				firstUntrainedIndex = i;
			}
		}
		m_SpeedDropdown.dataProvider = speedArray;
		m_SpeedDropdown.rowCount = speedArray.length;
		m_SpeedDropdown.invalidateData();
		UpdateSelectedSprint();
		
		if (firstUntrained == undefined)
		{
			m_UpgradeSprintButton._visible = false;
		}
	}
	
	private function UpdateSelectedSprint() : Void
	{
		var speedIndex:Number = 0;
		//Selected speed is 0 if there is no preference saved. Use the highest trained level!
		if (m_SelectedSpeed == 0)
		{
			//Backwards iterator to find the highest level first
			for (var i:Number = m_SprintFeats.length - 1; i > -1; i--)
			{
				if (FeatInterface.m_FeatList[m_SprintFeats[i]].m_Trained)
				{
					m_SelectedSpeed = m_SprintFeats[i];
					speedIndex = i;
					break;
				}
			}
		}
		//Speed selection is saved as a feat ID, not an index, so we have to search for it
		else
		{
			for (var i:Number = 0; i < m_SprintFeats.length; i++)
			{
				if (m_SprintFeats[i] == m_SelectedSpeed)
				{
					speedIndex = i;
					break;
				}
			}
		}
		m_SpeedDropdown.selectedIndex = speedIndex;
	}
	
	private function GetSprintLevelText(level:Number) : String
	{
		switch(level)
		{
			case 0:	return "I";
					break;
			case 1: return "II";
					break;
			case 2: return "III";
					break;
			case 3: return "IV";
					break;
			case 4: return "V";
					break;
			case 5: return "VI";
					break;
			default: return "0";
		}
		return "0";
	}
	
	private function GetSprintSpeed(level:Number) : Number
	{
		switch(level)
		{
			case 0:	return 150;
					break;
			case 1: return 162.5;
					break;
			case 2: return 175;
					break;
			case 3: return 200;
					break;
			case 4: return 225;
					break;
			case 5: return 250;
					break;
			default: return 100;
		}
		return 100;
	}

	private function GetNodes():Void
	{
		m_RootNode = Lore.GetMountTree();
		var allNodes:Array = m_RootNode.m_Children;
		allNodes.sortOn("m_Name");
		m_OwnedNodes = new Array();
		m_UnownedNodes = new Array();
		var OwnedFavorites = new Array();
		var UnownedFavorites = new Array();
		for (var i = 0; i < allNodes.length; i++)
		{
			if (Utils.GetGameTweak("HideMount_" + allNodes[i].m_Id) == 0)
			{
				var isFavorite:Boolean = false;
				for (var j = 0; j < m_FavoriteTags.length; j++)
				{
					if (m_FavoriteTags[j] == allNodes[i].m_Id)
					{
						isFavorite = true;
					}
				}
				if (!LoreBase.IsLocked(allNodes[i].m_Id))
				{
					if (isFavorite)
					{
						OwnedFavorites.push(allNodes[i]);
					}
					else
					{
						m_OwnedNodes.push(allNodes[i]);
					}
				}
				else
				{
					if (isFavorite)
					{
						UnownedFavorites.push(allNodes[i]);
					}
					else
					{
						m_UnownedNodes.push(allNodes[i]);
					}
				}
			}
		}
		m_OwnedNodes = OwnedFavorites.concat(m_OwnedNodes);
		m_UnownedNodes = UnownedFavorites.concat(m_UnownedNodes);
	}

	public function SelectNodeClip(nodeClip:PetClip):Void
	{
		if (nodeClip == undefined)
		{
			m_Name.text = LDBFormat.LDBGetText("GenericGUI", "NoMountSelected");
			m_Name.textColor = Colors.e_ColorWhite;
			m_Rarity.text = "";
			m_Description.text = "";
			m_FavoriteCheckBox._visible = false;
			m_FavoriteLabel._visible = false;
		}
		else
		{
			super.SelectNodeClip(nodeClip);
		}
	}
	
	private function FavoriteSelected():Void
	{
		super.FavoriteSelected();
		var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "PetInventory" );
		moduleIF.StoreConfig(OnModuleDeactivated());
	}
	
	private function FiltersChanged():Void
	{
		super.FiltersChanged();
		m_VisibleMountType = m_TypeDropdown.selectedIndex;
	}
	
	private function SpeedChanged():Void
	{
		m_SelectedSpeed = m_SprintFeats[m_SpeedDropdown.selectedIndex];
		var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "PetInventory" );
		moduleIF.StoreConfig(OnModuleDeactivated());
		//Force this, because disableFocus doesn't seem to be doing it for this dropdown
		Selection.setFocus(null);
	}

	private function SummonNode(nodeId:Number):Void
	{
		super.SummonNode(nodeId);
		if (typeof(nodeId) != "number") //If called from the button, this will be an object type!
		{
			nodeId = m_SelectedNodeClip.GetNode().m_Id;
		}
		if (!LoreBase.IsLocked(nodeId))
		{
			m_SelectedMount = m_SelectedNodeClip.GetNode().m_Id;
			var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "PetInventory" );
			moduleIF.StoreConfig(OnModuleDeactivated());
			SpellBase.SummonMountFromTag(m_SelectedNodeClip.GetNode().m_Id);
		}
		RemoveFocus();
	}

	private function GetDisplayArray():Array
	{
		var unfilteredArray = super.GetDisplayArray();
		var filteredArray:Array = new Array();
		for (var i=0; i<unfilteredArray.length; i++)
		{
			if(m_TypeDropdown.selectedIndex == 0 || Lore.GetTagMountType(unfilteredArray[i].m_Id) == m_TypeDropdown.selectedIndex)
			{
				//Default sprint should show up at the front of the list!
				if (unfilteredArray[i].m_Id == DEFAULT_SPRINT_ID)
				{
					filteredArray.unshift(unfilteredArray[i]);
				}
				else
				{
					filteredArray.push(unfilteredArray[i]);
				}
			}
		}
		return filteredArray;
	}
	
	private function SlotFeatTrained(featId:Number) : Void
	{
		if (featId == Utils.GetGameTweak("SprintTier6Feat") ||
			featId == Utils.GetGameTweak("SprintTier5Feat") ||
			featId == Utils.GetGameTweak("SprintTier4Feat") ||
			featId == Utils.GetGameTweak("SprintTier3Feat") ||
			featId == Utils.GetGameTweak("SprintTier2Feat") ||
			featId == Utils.GetGameTweak("SprintTier1Feat"))
		{
			UpdateSprintLevels();
			m_SpeedDropdown.selectedIndex = m_SpeedDropdown.dataProvider.length-1;
			Character.GetClientCharacter().AddEffectPackage( "sound_fxpackage_GUI_purchase_power.xml" );
		}
	}
	
	private function EquipStyleChanged() : Void
	{
		m_MountEquipStyle = m_EquipDropdown.selectedIndex;
		var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "PetInventory" );
		moduleIF.StoreConfig(OnModuleDeactivated());
		RemoveFocus();
	}
}