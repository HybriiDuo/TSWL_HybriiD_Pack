import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.TileList;
import gfx.controls.ScrollingList;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.Utils.Text;
import com.Utils.ID32;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.DressingRoom;
import com.GameInterface.DressingRoomNode;
import com.GameInterface.ShopInterface;
import com.GameInterface.DialogIF;

class GUI.DressingRoom.RightPanel extends UIComponent
{
	private var m_Background:MovieClip;
	private var m_CloseButton:Button;
	private var m_HeaderText:TextField;
	private var m_EquippedBanner:TextField;
	private var m_EquippedText:TextField;
	private var m_SourceBanner:MovieClip;
	private var m_SourceText:TextField;
	private var m_ColorPicker:MovieClip;
	private var m_ItemSelector:MovieClip;
	private var m_PriceDisplay:MovieClip;
	private var m_ImageBacker:MovieClip;
	private var m_ConfirmButton:Button;
	private var m_LockIcon:MovieClip;
	private var m_ClearPreview:MovieClip;
	
	private var m_Thumbnail:MovieClip;
	private var m_CurrentMode:Number;
	private var m_SelectedNode:DressingRoomNode;
	private var m_WardrobeInventory:Inventory;
    private var m_EquippedInventory:Inventory;
	private var m_EnableStickyPreview:Boolean;
	private var m_StickyPreviewNodeId:Number;
	
	private var SignalCloseDressingRoom:Signal;
	
	public static var MODE_NO_DATA:Number = -1;
	public static var MODE_COLORS:Number = 0;
	public static var MODE_ITEMS:Number = 1;
	
	public function RightPanel()
	{
		SignalCloseDressingRoom = new Signal();
	}
	
	private function configUI():Void
	{
		m_CloseButton.addEventListener("click", this, "CloseDressingRoom");
		m_ConfirmButton.addEventListener("click", this, "ConfirmSelection");
		m_ConfirmButton.disableFocus = true;
		m_ImageBacker._visible = false;
		
		m_EquippedText.text = LDBFormat.LDBGetText("GenericGUI", "DressingRoom_Equipped");
		
		var clientCharacterID:ID32 = Character.GetClientCharID();        
        m_WardrobeInventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, clientCharacterID.GetInstance()));
        m_EquippedInventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, clientCharacterID.GetInstance()));
				
		m_WardrobeInventory.SignalItemAdded.Connect(Update, this);
        m_WardrobeInventory.SignalItemLoaded.Connect(Update, this);
        m_WardrobeInventory.SignalItemChanged.Connect(Update, this);
        
        m_EquippedInventory.SignalItemAdded.Connect(Update, this);
        m_EquippedInventory.SignalItemLoaded.Connect(Update, this);
        m_EquippedInventory.SignalItemChanged.Connect(Update, this);
		
		m_ClearPreview.onRollOver = m_ClearPreview.onDragOver = function()
		{
			this.gotoAndStop("over");
		}
		m_ClearPreview.onRollOut = m_ClearPreview.onDragOut = function()
		{
			this.gotoAndStop("up");
		}
		m_ClearPreview.onRelease = Delegate.create(this, ClearPreview);
		
		SetDisplayMode(MODE_COLORS);
	}
	
	private function Update()
	{
		UpdateOwnership(m_SelectedNode);
		UpdateEquipped(m_SelectedNode);
	}
	
	private function ClearPreview()
	{
		ClearStickyPreview();
		DressingRoom.ClearPreview();
	}
	
	public function ClearStickyPreview()
	{
		m_StickyPreviewNodeId = undefined;
	}
	
	public function SetData(node:DressingRoomNode):Void
	{
		m_EnableStickyPreview = false;			
		if (node != undefined)
		{
			//Title
			m_HeaderText.text = node.m_Name;
			
			//TODO: This is not a good solution. This is checking the parent node's ID
			//to determine if we should show the item list or color picker. This data
			//should probably be passed through somewhere instead.
			if (DressingRoom.GetParent(node.m_NodeId).m_NodeId == 28101 ||
				DressingRoom.GetParent(node.m_NodeId).m_NodeId == 102)
			{
				SetDisplayMode(MODE_ITEMS);
			}
			else
			{
				SetDisplayMode(MODE_COLORS);
			}
			
			if (m_CurrentMode == MODE_ITEMS)
			{
				var itemList:ScrollingList = m_ItemSelector.m_ItemList;
				itemList.removeEventListener( "change", this, "OnItemSelected");
				itemList.removeEventListener( "itemClick", this, "OnItemClicked");
				/*
				itemList.removeEventListener( "itemRollOver", this, "OnItemRolledOver");
				itemList.removeEventListener( "itemRollOut", this, "OnItemRolledOut");
				*/
				itemList.dataProvider = new Array();
				
				var itemNodes:Array = DressingRoom.GetChildren(node.m_NodeId);
				itemList.selectedIndex = 0;
				var foundEquipped:Boolean = false;
				var foundOwned:Boolean = false;
				for (var i:Number = 0; i < itemNodes.length; i++)
				{
					itemList.dataProvider.push(itemNodes[i]);
					if (DressingRoom.NodeEquipped(itemNodes[i].m_NodeId))
					{
						itemList.selectedIndex = i;
						foundEquipped = true;
					}
					if (DressingRoom.NodeOwned(itemNodes[i].m_NodeId) && !foundEquipped && !foundOwned)
					{
						itemList.selectedIndex = i;
						foundOwned = true;
					}
				}
				
				itemList.addEventListener("change", this, "OnItemSelected");
				itemList.addEventListener( "itemClick", this, "OnItemClicked");
				/*
				itemList.addEventListener( "itemRollOver", this, "OnItemRolledOver");
				itemList.addEventListener( "itemRollOut", this, "OnItemRolledOut");
				*/
				//Explicitly call this. We do this instead of letting the selectedIndex change it
				//Because it will call the "change" event if the new index is equal to the old index
				OnItemSelected();
			}
			
			if (m_CurrentMode == MODE_COLORS)
			{
				var colorList:TileList = m_ColorPicker.m_ColorTileList;
				colorList.removeEventListener( "change", this, "OnColorSelected" );
				colorList.removeEventListener( "itemClick", this, "OnItemClicked");
				/*
				colorList.removeEventListener( "itemRollOver", this, "OnItemRolledOver");
				colorList.removeEventListener( "itemRollOut", this, "OnItemRolledOut");
				*/
				colorList.dataProvider = new Array();
				
				var colorNodes:Array = DressingRoom.GetChildren(node.m_NodeId);
				colorList.selectedIndex = 0;
				var foundEquipped:Boolean = false;
				var foundOwned:Boolean = false;
				for ( var i:Number = 0 ; i < colorNodes.length ; i++ )
				{
					colorList.dataProvider.push( colorNodes[i] );
					if (DressingRoom.NodeEquipped(colorNodes[i].m_NodeId))
					{
						colorList.selectedIndex = i;
						foundEquipped = true;
					}
					if (DressingRoom.NodeOwned(colorNodes[i].m_NodeId) && !foundEquipped && !foundOwned)
					{
						colorList.selectedIndex = i;
						foundOwned = true;
					}
				}
				
				colorList.addEventListener( "change", this, "OnColorSelected" );
				colorList.addEventListener( "itemClick", this, "OnItemClicked");
				/*
				colorList.addEventListener( "itemRollOver", this, "OnItemRolledOver");
				colorList.addEventListener( "itemRollOut", this, "OnItemRolledOut");
				*/
				//Explicitly call this. We do this instead of letting the selectedIndex change it
				//Because it will call the "change" event if the new index is equal to the old index
				OnColorSelected();
			}
		}
		else
		{
			SetDisplayMode(MODE_NO_DATA);
		}
		m_EnableStickyPreview = true;
	}
	
	private function SetDisplayMode(displayMode:Number)
	{
		switch(displayMode)
		{
			case MODE_COLORS:	m_CurrentMode = MODE_COLORS;
								m_ColorPicker._visible = true;
								m_ItemSelector._visible = false;
								m_Background.m_ColorPickerDetail._visible = true;
			break;
			case MODE_ITEMS:	m_CurrentMode = MODE_ITEMS;
								m_ColorPicker._visible = false;
								m_ItemSelector._visible = true;
								m_Background.m_ColorPickerDetail._visible = false;
			break;
			case MODE_NO_DATA: 	m_HeaderText.text = LDBFormat.LDBGetText("MiscGUI", "DressingRoom_NoSelection");
								m_LockIcon._visible = false;
								m_EquippedBanner._visible = false;
								m_EquippedText.text = "";
								m_SourceBanner._visible = false;
								m_SourceText.text = "";
								m_ColorPicker._visible = false;
								m_Background.m_ColorPickerDetail._visible = true;
								m_ItemSelector._visible = false;
								m_PriceDisplay._visible = false;
								m_ImageBacker._visible = false;
								if (m_Thumbnail != undefined)
								{
									m_Thumbnail.removeMovieClip();
								}
			break;
		}
	}
	
	private function OnItemSelected()
	{
		var itemData:DressingRoomNode = m_ItemSelector.m_ItemList.dataProvider[m_ItemSelector.m_ItemList.selectedIndex];
		m_SelectedNode = itemData;
		SetVisualNode(itemData);
	}
	
	private function OnColorSelected()
	{
		var colorData:DressingRoomNode = m_ColorPicker.m_ColorTileList.dataProvider[m_ColorPicker.m_ColorTileList.selectedIndex];
		m_SelectedNode = colorData;
		if (colorData.m_Color1Name != colorData.m_Color2Name)
		{
			m_ColorPicker.m_ColorText.text = colorData.m_Color1Name + " / " + colorData.m_Color2Name;
		}
		else
		{
			m_ColorPicker.m_ColorText.text = colorData.m_Color1Name;
		}
		if (Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0)
		{
			m_ColorPicker.m_ColorText.text += " [" + colorData.m_NodeId + "]";
		}
		
		SetVisualNode(colorData);		
	}
	
	private function OnItemClicked(event:Object)
	{
		if (event.item != undefined && m_EnableStickyPreview)
		{
			DressingRoom.PreviewNodeItem(event.item.m_NodeId);
		}
	}
	
	//Disabling this for now. Due to a bug with previewing, it is causing more
	//problems than it is worth
	/*
	private function OnItemRolledOver(event:Object)
	{
		if (event.item != undefined)
		{
			if (event.item.m_NodeId != m_StickyPreviewNodeId)
			{
				DressingRoom.PreviewNodeItem(event.item.m_NodeId);
			}
		}
	}
	
	private function OnItemRolledOut(event:Object)
	{
		if (event.item != undefined)
		{
			if (m_StickyPreviewNodeId != undefined)
			{
				if (m_StickyPreviewNodeId != event.item.m_NodeId)
				{
					DressingRoom.PreviewNodeItem(m_StickyPreviewNodeId);
				}
			}
			else
			{
				DressingRoom.PreviewNodeItem(event.item.m_NodeId);
			}
		}
	}
	*/
	
	private function SetVisualNode(nodeData:DressingRoomNode)
	{
		//Icon
		if (GetIcon(nodeData) != 0)
		{
			if (m_Thumbnail != undefined)
			{
				m_ImageBacker._visible = false;
				m_Thumbnail.removeMovieClip();
			}
			m_Thumbnail = this.createEmptyMovieClip("m_SelectedMedia", this.getNextHighestDepth());
       		LoadImage(m_Thumbnail, GetIcon(nodeData));
		}
		
		//Source
		if (GetPrice(nodeData) == 0)
		{
			m_SourceBanner._visible = true;
			m_SourceText._visible = true;
			m_SourceText.text = GetSource(nodeData);
		}
		else
		{
			m_SourceBanner._visible = false;
			m_SourceText._visible = false;
		}
		
		//Equipped
		UpdateEquipped(nodeData);
		
		//Ownership
		UpdateOwnership(nodeData);
		
		/*
		if (m_EnableStickyPreview)
		{
			m_StickyPreviewNodeId = nodeData.m_NodeId;
		}
		*/
	}
	
	private function UpdateEquipped(nodeData:DressingRoomNode)
	{
		if (DressingRoom.NodeEquipped(nodeData.m_NodeId))
		{
			m_EquippedText._visible = true;
			m_EquippedBanner._visible = true;
		}
		else
		{
			m_EquippedText._visible = false;
			m_EquippedBanner._visible = false;
		}
	}
	
	private function UpdateOwnership(nodeData:DressingRoomNode)
	{
		m_ConfirmButton.disabled = false;
		var owned:Boolean = DressingRoom.NodeOwned(nodeData.m_NodeId);
		var price:Number = GetPrice(nodeData);
		if (!owned)
		{
			m_LockIcon._visible = true;
			m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "DressingRoom_Buy");
			if (price != 0)
			{
				m_PriceDisplay.m_Text.text = Text.AddThousandsSeparator(price);
				var tokenType:Number = GetTokenType(nodeData);
				m_PriceDisplay.m_Token_10._visible = m_PriceDisplay.m_Token_201._visible = m_PriceDisplay.m_Token_202._visible = false;
				m_PriceDisplay["m_Token_"+tokenType]._visible = true;
				m_PriceDisplay._x = m_Background._width/2 - (m_PriceDisplay.m_Text._x + m_PriceDisplay.m_Text.textWidth)/2;
				m_PriceDisplay._visible = true;
			}
			else
			{
				m_PriceDisplay._visible = false;
				m_ConfirmButton.disabled = true;
			}
		}
		else
		{
			m_PriceDisplay._visible = false;
			m_LockIcon._visible = false;
			if (DressingRoom.NodeEquipped(nodeData.m_NodeId))
			{
				m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "Unwear");
			}
			else
			{
				m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "DressingRoom_Wear");
			}
		}
	}
	
	private function LoadImage(container:MovieClip, mediaId:Number)
    {
		var imageLoader:MovieClipLoader = new MovieClipLoader();
        
        var path = com.Utils.Format.Printf( "rdb:%.0f:%.0f", 1000624, mediaId );
	
		imageLoader.addListener( this );
		imageLoader.loadClip( path, container );
    }
	
	private function onLoadInit( target:MovieClip )
    {
        target._y = m_EquippedText._y + m_EquippedText._height + 15;        
        target._x = m_HeaderText._x + m_HeaderText._width/2 - target._width/2;
		
		m_ImageBacker._x = target._x - 15;
		m_ImageBacker._y = target._y - 15;
		m_ImageBacker._width = target._width + 30;
		m_ImageBacker._height = target._height + 30;
		m_ImageBacker._visible = true;
		
		m_LockIcon._x = m_ImageBacker._x + m_ImageBacker._width - m_LockIcon._width - 20;
		m_LockIcon._y = m_ImageBacker._y + m_ImageBacker._height - m_LockIcon._height - 20;
    }
	
	private function ConfirmSelection()
	{
		var owned:Boolean = DressingRoom.NodeOwned(m_SelectedNode.m_NodeId);		
		if (!owned)
		{
			var tokenType:Number = GetTokenType(m_SelectedNode);
			var price:Number = GetPrice(m_SelectedNode);
			var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+tokenType);
			if (tokenType == _global.Enums.Token.e_Gold_Bullion_Token)
			{
				tokenName = LDBFormat.LDBGetText("Tokens", "Token201_Plural");
			}
			var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "DressingRoom_PurchaseConfirmation"), m_SelectedNode.m_Name, Text.AddThousandsSeparator(price), tokenName));
			dialogIF.SignalSelectedAS.Connect(SlotConfirmPurchase, this);
			dialogIF.Go();
		}
		else
		{
			DressingRoom.EquipNode(m_SelectedNode.m_NodeId);
		}
	}
	
	private function SlotConfirmPurchase(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var tokenType:Number = GetTokenType(m_SelectedNode);
			var price:Number = GetPrice(m_SelectedNode);
			if (Character.GetClientCharacter().GetTokens(tokenType) >= price)
			{
				DressingRoom.PurchaseNode(m_SelectedNode.m_NodeId)
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
	
	private function GetSource(node:DressingRoomNode):String
	{
		if (node.m_Source != ""){return node.m_Source;}
		if (node.m_NodeId == 0){return "";}
		return GetSource(DressingRoom.GetParent(node.m_NodeId));
	}
	
	private function GetPrice(node:DressingRoomNode):Number
	{
		if (node.m_Price != 0){return node.m_Price;}
		if (node.m_NodeId == 0){return 0;}
		return GetPrice(DressingRoom.GetParent(node.m_NodeId));
	}
	
	private function GetTokenType(node:DressingRoomNode):Number
	{
		if (node.m_TokenType != 0){return node.m_TokenType;}
		if (node.m_NodeId == 0){return 0;}
		return GetTokenType(DressingRoom.GetParent(node.m_NodeId));
	}
	
	private function GetIcon(node:DressingRoomNode):Number
	{
		if (node.m_Icon != 0){return node.m_Icon;}
		if (node.m_NodeId == 0){return 0;}
		return GetIcon(DressingRoom.GetParent(node.m_NodeId));
	}
	
	private function CloseDressingRoom()
	{
		SignalCloseDressingRoom.Emit();
		RemoveFocus();
	}
	
	private function RemoveFocus()
	{
		Selection.setFocus(null);
	}
}