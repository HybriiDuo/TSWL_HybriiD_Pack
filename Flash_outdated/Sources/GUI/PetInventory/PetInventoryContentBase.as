import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import com.Utils.Archive;
import gfx.controls.Button;
import gfx.controls.CheckBox;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.LoreBase;
import com.GameInterface.SpellBase;
import com.GameInterface.ShopInterface;
import com.GameInterface.Utils;
import com.GameInterface.DialogIF;
import com.GameInterface.Game.Character;
import com.Utils.Colors;
import com.Utils.Text;
import GUI.PetInventory.PetClip;

class GUI.PetInventory.PetInventoryContentBase extends WindowComponentContent
{
	//Components created in .fla
	private var m_PreviousButton:Button;
	private var m_NextButton:Button;
	private var m_SummonButton:Button;
	private var m_FavoriteCheckBox:CheckBox;
	private var m_OwnedCheckBox:CheckBox;
	private var m_UnownedCheckBox:CheckBox;
	private var m_FavoritesCheckBox:CheckBox;
	private var m_Name:TextField;
	private var m_Description:TextField;
	private var m_Rarity:TextField;
	private var m_FavoriteLabel:TextField;
	private var m_OwnedLabel:TextField;
	private var m_UnownedLabel:TextField;
	private var m_FavoritesLabel:TextField;
	private var m_TagPrice:MovieClip;

	//Variables
	private var m_RootNode:LoreNode;
	private var m_UnownedNodes:Array;
	private var m_OwnedNodes:Array;
	private var m_NodeClips:Array;
	private var m_FavoriteTags:Array;
	private var m_SelectedNodeClip:PetClip;
	private var m_CurrPage:Number;
	private var m_MountEquipStyle:Number;
	private var m_VisibleMountType:Number;
	private var m_SelectedMount:Number;
	private var m_SelectedSpeed:Number;
	private var m_OwnedButtonText:String;
	private var m_PurchaseButtonText:String;
	
	//Statics
	private var ICONS_START_X:Number;
	private var ICONS_START_Y:Number;
	private var ICONS_BUFFER:Number;
	private var ICONS_PER_ROW:Number;
	private var NODES_PER_PAGE:Number;

	public function PetInventoryContentBase()
	{
		super();
	}

	private function configUI()
	{
		m_PreviousButton.addEventListener("click",this,"PageBackward");
		m_NextButton.addEventListener("click",this,"PageForward");
		m_SummonButton.addEventListener("click",this,"SummonNode");
		m_FavoriteCheckBox.addEventListener("click",this,"FavoriteSelected");
		m_OwnedCheckBox.addEventListener("click",this,"FiltersChanged");
		m_UnownedCheckBox.addEventListener("click",this,"FiltersChanged");
		m_FavoritesCheckBox.addEventListener("click",this,"FiltersChanged");

		m_PreviousButton.disableFocus = true;
		m_NextButton.disableFocus = true;
		
		m_TagPrice.m_Cost.autoSize = "left";

		m_CurrPage = 0;
		SetLabels();
	}

	public function OnModuleActivated(config:Archive):Void
	{
		m_FavoriteTags = config.FindEntryArray("Favorites");
		if (m_FavoriteTags == undefined)
		{
			m_FavoriteTags = new Array();
		}
		m_OwnedCheckBox.selected = config.FindEntry("CheckOwned", true);
		m_UnownedCheckBox.selected = config.FindEntry("CheckUnowned", true);
		m_FavoritesCheckBox.selected = config.FindEntry("CheckFavorites", true);
		m_MountEquipStyle = config.FindEntry("EquipStyle", 0);
		m_VisibleMountType = config.FindEntry("VisibleMounts", 0);
		m_SelectedMount = config.FindEntry("SelectedMount", 0);
		m_SelectedSpeed = config.FindEntry("SprintFeat", 0);

		GetNodes();
		DrawNodeClips();
		Lore.SignalTagAdded.Connect(SlotTagAdded,this);
	}

	public function OnModuleDeactivated()
	{
		var archive:Archive = new Archive();
		archive.AddEntry("CheckOwned",m_OwnedCheckBox.selected);
		archive.AddEntry("CheckUnowned",m_UnownedCheckBox.selected);
		archive.AddEntry("CheckFavorites",m_FavoritesCheckBox.selected);
		archive.AddEntry("EquipStyle", m_MountEquipStyle);
		archive.AddEntry("VisibleMounts", m_VisibleMountType);
		archive.AddEntry("SelectedMount", m_SelectedMount);
		archive.AddEntry("SprintFeat", m_SelectedSpeed);
		for (var i = 0; i < m_FavoriteTags.length; i++)
		{
			archive.AddEntry("Favorites",m_FavoriteTags[i]);
		}
		return archive;
	}

	//Set Labels
	private function SetLabels():Void
	{
		m_FavoriteLabel.text = LDBFormat.LDBGetText("GenericGUI", "Favorite");
		m_OwnedLabel.text = LDBFormat.LDBGetText("GenericGUI", "Owned");
		m_UnownedLabel.text = LDBFormat.LDBGetText("GenericGUI", "Unowned");
		m_FavoritesLabel.text = LDBFormat.LDBGetText("GenericGUI", "Favorites");
		m_FavoriteCheckBox._x = m_FavoriteLabel._x + m_FavoriteLabel._width - m_FavoriteLabel.textWidth - m_FavoriteCheckBox._width - 5;
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

	private function DrawNodeClips():Void
	{
		for (var i = 0; i < m_NodeClips.length; i++)
		{
			m_NodeClips[i].removeMovieClip();
		}
		m_NodeClips = new Array();
		var currX = ICONS_START_X;
		var currY = ICONS_START_Y;

		var drawArray:Array = GetDisplayArray();
		var startNode:Number = m_CurrPage * NODES_PER_PAGE;
		drawArray = drawArray.slice(startNode, startNode + NODES_PER_PAGE);
		
		for (var i:Number = 0; i < drawArray.length; i++)
		{
			var nodeClip:MovieClip = this.attachMovie("PetClip", "nodeClip" + i, this.getNextHighestDepth());
			nodeClip._x = currX;
			nodeClip._y = currY;

			currX += nodeClip._width + ICONS_BUFFER;
			if ((i + 1) % 10 == 0)
			{
				currY += nodeClip._height + ICONS_BUFFER;
				currX = ICONS_START_X;
			}
			nodeClip.SetData(drawArray[i]);
			for (var j = 0; j < m_FavoriteTags.length; j++)
			{
				if (drawArray[i].m_Id == m_FavoriteTags[j])
				{
					nodeClip.SetFavorite(true);
				}
			}
			m_NodeClips.push(nodeClip);
		}
		SelectNodeClip(m_NodeClips[0]);
		UpdatePagination();
	}

	public function SelectNodeClip(nodeClip:PetClip):Void
	{
		for (var i = 0; i < m_NodeClips.length; i++)
		{
			m_NodeClips[i].SetSelected(false);
		}
		nodeClip.SetSelected(true);
		var node:Number = nodeClip.GetNode().m_Id;
		m_Name.text = LoreBase.GetTagName(node);
		if (Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0)
		{
			m_Name.text += " [" + node + "]";
		}
		m_Rarity.text = LDBFormat.LDBGetText("MiscGUI", "PowerLevel_" + LoreBase.GetRank(node));
		m_Name.textColor = Colors.GetItemRarityColor(LoreBase.GetRank(node));
		
		var price:Object = ShopInterface.GetTagPriceInfo(node);
		m_TagPrice._visible = LoreBase.IsLocked(node) && price[1] != 0;
		m_TagPrice.m_Cost.text = Text.AddThousandsSeparator(price[1]);
		m_TagPrice.m_Token.m_T201._visible = m_TagPrice.m_Token.m_T202._visible = false;
		m_TagPrice.m_Token["m_T"+price[0]]._visible = true;
		m_TagPrice._x = m_SummonButton._x + m_SummonButton._width/2 - (m_TagPrice.m_Cost._x + m_TagPrice.m_Cost.textWidth)/2;
		
		if (LoreBase.IsLocked(node))
		{
			if (price[1] > 0)
			{
				m_SummonButton.disabled = false;
				m_SummonButton.label = m_PurchaseButtonText;
			}
			else
			{
				m_SummonButton.disabled = true;
				m_SummonButton.label = m_OwnedButtonText;
			}
		}
		else
		{
			m_SummonButton.disabled = false;
			m_SummonButton.label = m_OwnedButtonText;
		}
		
		//Set the description
		m_Description.htmlText = LoreBase.GetTagText(node);
		if(LoreBase.IsLocked(node))
		{
			var fullText:String = LoreBase.GetTagText(node);
			var index:Number = fullText.lastIndexOf("\n");
			m_Description.htmlText = fullText.slice(index+1);
		}

		var isFavorite:Boolean = false;
		for (var i = 0; i < m_FavoriteTags.length; i++)
		{
			if (node == m_FavoriteTags[i])
			{
				isFavorite = true;
			}
		}
		m_FavoriteCheckBox._visible = true;
		m_FavoriteLabel._visible = true;
		if (isFavorite)
		{
			m_FavoriteCheckBox.selected = true;
		}
		else
		{
			m_FavoriteCheckBox.selected = false;
		}
		
		m_SelectedNodeClip = nodeClip;
	}
	
	private function SummonNode(nodeId:Number):Void
	{
		if (typeof(nodeId) != "number") //If called from the button, this will be an object type!
		{
			nodeId = m_SelectedNodeClip.GetNode().m_Id;
		}
		if (LoreBase.IsLocked(nodeId))
		{
			var priceInfo:Object = ShopInterface.GetTagPriceInfo(nodeId);
			var tokenType:Number = priceInfo[0];
			var price:Number = priceInfo[1];
			var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+tokenType);
			if (tokenType == _global.Enums.Token.e_Gold_Bullion_Token)
			{
				tokenName = LDBFormat.LDBGetText("Tokens", "Token201_Plural");
			}
			var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "DressingRoom_PurchaseConfirmation"), LoreBase.GetTagName(nodeId), Text.AddThousandsSeparator(price), tokenName));
			dialogIF.SignalSelectedAS.Connect(SlotConfirmPurchase, this);
			dialogIF.Go();
		}
		//Function is overridden in mount/pet content to handle summoning owned nodes
	}
	
	private function SlotConfirmPurchase(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var nodeId:Number = m_SelectedNodeClip.GetNode().m_Id;
			var priceInfo:Object = ShopInterface.GetTagPriceInfo(nodeId);
			var tokenType:Number = priceInfo[0];
			var price:Number = priceInfo[1];
			if (Character.GetClientCharacter().GetTokens(tokenType) >= price)
			{
				ShopInterface.BuyTag(nodeId, tokenType, price);
			}
			else
			{
				switch(tokenType)
				{
					case _global.Enums.Token.e_Cash:				com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("GenericGUI", "NotEnoughAnimaShards"), 0);
																	break;
					case _global.Enums.Token.e_Gold_Bullion_Token:	com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("GenericGUI", "NotEnoughMoFs"), 0);
																	break;
					case _global.Enums.Token.e_Premium_Token:		com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("GenericGUI", "NotEnoughAurum"), 0);
																	ShopInterface.RequestAurumPurchase();
																	break;
				}
			}
		}
	}

	private function PageBackward():Void
	{
		if (m_CurrPage != 0)
		{
			m_CurrPage -= 1;
			DrawNodeClips();
			UpdatePagination();
		}
	}

	private function PageForward():Void
	{
		var displayArray = GetDisplayArray();
		var numPages:Number = Math.ceil(displayArray.length / NODES_PER_PAGE);
		if (m_CurrPage != numPages - 1)
		{
			m_CurrPage += 1;
			DrawNodeClips();
			UpdatePagination();
		}
	}

	private function FiltersChanged():Void
	{
		GetNodes();
		m_CurrPage = 0;
		DrawNodeClips();
		UpdatePagination;
		RemoveFocus();
	}

	private function GetDisplayArray():Array
	{
		var displayArray:Array = new Array();
		if (m_OwnedCheckBox.selected)
		{
			displayArray = displayArray.concat(m_OwnedNodes);
		}
		else if (m_FavoritesCheckBox.selected)
		{
			for (var i = 0; i < m_OwnedNodes.length; i++)
			{
				for (var j = 0; j < m_FavoriteTags.length; j++)
				{
					if (m_OwnedNodes[i].m_Id == m_FavoriteTags[j])
					{
						displayArray.push(m_OwnedNodes[i]);
					}
				}
			}
		}
		if (m_UnownedCheckBox.selected)
		{
			displayArray = displayArray.concat(m_UnownedNodes);
		}
		else if (m_FavoritesCheckBox.selected)
		{
			for (var i = 0; i < m_UnownedNodes.length; i++)
			{
				for (var j = 0; j < m_FavoriteTags.length; j++)
				{
					if (m_UnownedNodes[i].m_Id == m_FavoriteTags[j])
					{
						displayArray.push(m_UnownedNodes[i]);
					}
				}
			}
		}
		return displayArray;
	}

	private function FavoriteSelected():Void
	{
		var nodeId:Number = m_SelectedNodeClip.GetNode().m_Id;
		if (m_FavoriteCheckBox.selected)
		{
			m_FavoriteTags.push(nodeId);
			m_SelectedNodeClip.SetFavorite(true);
		}
		else
		{
			m_SelectedNodeClip.SetFavorite(false);
			var removeIndex:Number = undefined;
			for (var i = 0; i < m_FavoriteTags.length; i++)
			{
				if (m_FavoriteTags[i] == nodeId)
				{
					removeIndex = i;
				}
			}
			if (removeIndex != undefined)
			{
				m_FavoriteTags.splice(removeIndex,1);
			}
			//If Node belongs to a filter that isn't being shown, redraw 
			if ((!m_OwnedCheckBox.selected && !LoreBase.IsLocked(nodeId)) || (!m_UnownedCheckBox.selected && LoreBase.IsLocked(nodeId)))
			{
				DrawNodeClips();
			}
		}
		RemoveFocus();
	}

	private function UpdatePagination():Void
	{
		m_PreviousButton._visible = true;
		m_NextButton._visible = true;
		if (m_CurrPage == 0)
		{
			m_PreviousButton._visible = false;
		}
		var displayArray = GetDisplayArray();
		var numPages:Number = Math.ceil(displayArray.length / NODES_PER_PAGE);
		if (m_CurrPage == numPages - 1)
		{
			m_NextButton._visible = false;
		}
	}

	//Remove Focus
	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}

	private function SlotTagAdded(tagId:Number):Void
	{
		for (var i:Number = 0; i < m_NodeClips.length; i++)
		{
			if (m_NodeClips[i].GetNode().m_Id == tagId)
			{
				//Update this tag to show it is owned
				m_NodeClips[i].TagAdded();
				//Check if the tag is currently selected
				if (m_SelectedNodeClip.GetNode().m_Id == tagId)
				{
					//Reselect it to update display
					SelectNodeClip(m_NodeClips[i]);
				}
			}
		}
	}
}