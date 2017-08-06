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
import com.Utils.Colors;
import GUI.PetInventory.PetClip;

class GUI.PetInventory.PetInventoryContent extends PetInventoryContentBase
{
	//Components created in .fla
	//Check PetInventoryContentBase
	
	//Variables
	//Check PetInventoryContentBase
	
	//Statics
	//Check PetInventoryContentBase

	public function PetInventoryContent()
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
		ICONS_START_Y = 48;
		ICONS_BUFFER = 7.75;
		ICONS_PER_ROW = 10;
		NODES_PER_PAGE = 40;
		
		SignalLoaded.Emit();
	}

	//Set Labels
	private function SetLabels():Void
	{
		super.SetLabels();
		m_OwnedButtonText = LDBFormat.LDBGetText("GenericGUI", "SummonPet");
		m_PurchaseButtonText = LDBFormat.LDBGetText("GenericGUI", "BuyPet");
	}

	private function GetNodes():Void
	{
		m_RootNode = Lore.GetPetTree();
		var allNodes:Array = m_RootNode.m_Children;
		allNodes.sortOn("m_Name");
		m_OwnedNodes = new Array();
		m_UnownedNodes = new Array();
		var OwnedFavorites = new Array();
		var UnownedFavorites = new Array();
		for (var i = 0; i < allNodes.length; i++)
		{
			if (Utils.GetGameTweak("HidePet_" + allNodes[i].m_Id) == 0)
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
			m_Name.text = LDBFormat.LDBGetText("GenericGUI", "NoPetSelected");
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

	private function SummonNode(nodeId:Number):Void
	{
		super.SummonNode(nodeId);
		if (typeof(nodeId) != "number") //If called from the button, this will be an object type!
		{
			nodeId = m_SelectedNodeClip.GetNode().m_Id;
		}
		if (!LoreBase.IsLocked(nodeId))
		{
			SpellBase.SummonPetFromTag(nodeId);
		}
		RemoveFocus();
	}
}