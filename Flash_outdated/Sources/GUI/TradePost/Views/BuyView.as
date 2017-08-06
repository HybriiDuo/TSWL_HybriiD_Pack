//Imports
import com.Components.ItemSlot;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Tradepost;
import com.GameInterface.TradepostSearchData;
import com.GameInterface.TradepostSearchResultData;
import com.GameInterface.InventoryItem;
import com.GameInterface.DialogIF;
import com.GameInterface.Game.Character;
import com.GameInterface.ItemPrice;
import com.GameInterface.Inventory;
import GUI.TradePost.Views.SortButton;
import GUI.TradePost.Views.PromptWindow;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.Utils.DragObject;
import com.Utils.ID32;
import gfx.core.UIComponent;
import mx.utils.Delegate;
import com.Components.RightClickMenu;
import com.Components.RightClickItem;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.InventoryItemList.MCLItemInventoryItem;
import com.Components.BankItemSlot;
import gfx.controls.TextInput;
import gfx.controls.Button;
import gfx.controls.ScrollBar;

//Class
class GUI.TradePost.Views.BuyView extends UIComponent
{
    //Constants
    private static var RIGHT_CLICK_MOUSE_OFFSET:Number = 5;
    private static var DEFAULT_CHECKBOX_WIDTH:Number = 110;
    private static var CHECKBOX_GAP:Number = 2;
    private static var GENERAL_GAP:Number = 10;
    private static var SEARCH_CONTROLS_Y:Number = 78;
	private static var DROPDOWN_CONTROLS_Y:Number = 26;
    private static var RESULT_CONTROLS_Y:Number = 7;
    private static var SCROLL_WHEEL_SPEED:Number = 10;
	private static var TRADE_INVENTORY_SIZE = 10;
	private static var RIGHT_CLICK_LIST:Number = 0;
	private static var RIGHT_CLICK_SALE:Number = 1;
	private static var RIGHT_CLICK_PURCHASE:Number = 2;
    
    private static var SEARCH:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Search");
    private static var USABLE_ITEMS_ONLY:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_UsableItemsOnly");
    private static var USE_EXACT_NAME:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_UseExactName");
    
    private static var ITEM_TYPE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ItemType");
    private static var SUB_TYPE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_SubType");
	private static var RARITY:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Rarity");
	private static var PRICE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Price")
	private static var STACKS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Stacks");
    private static var KEYWORDS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_KeyWords");
    
    private static var RESULTS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Results");
    
    private static var TYPE_ALL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Class_All");
	private static var TYPE_PAX:String = LDBFormat.LDBGetText("Tokens", "CashToken");
	private static var TYPE_PREMIUM:String = LDBFormat.LDBGetText("Tokens", "Premium_Token_Name");
    private static var BUY:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Buy");
    private static var BUYITEM:String = LDBFormat.LDBGetText("MiscGUI", "Tradepost_BuyItem");
	private static var CANCEL_SALE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_CancelSale");
	private static var CLAIM_ITEM:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ClaimPurchase");
    
    private static var EXPIRATION_DAYS:String = LDBFormat.LDBGetText("MiscGUI", "expirationDays");
    private static var PRESS_SEARCH_BUTTON:String = LDBFormat.LDBGetText("MiscGUI", "Tradepost_Buy_PressSearchHelp");
	
	private static var RARITY_WHITE = LDBFormat.LDBGetText("MiscGUI", "PowerLevel_1");
	private static var RARITY_GREEN = LDBFormat.LDBGetText("MiscGUI", "PowerLevel_2");
	private static var RARITY_BLUE = LDBFormat.LDBGetText("MiscGUI", "PowerLevel_3");
	private static var RARITY_PURPLE = LDBFormat.LDBGetText("MiscGUI", "PowerLevel_4");
	private static var RARITY_ORANGE = LDBFormat.LDBGetText("MiscGUI", "PowerLevel_5");
	private static var RARITY_RED = LDBFormat.LDBGetText("MiscGUI", "PowerLevel_6");
	
	private static var SALES_HEADER = LDBFormat.LDBGetText("MiscGUI", "TradePost_SalesHeader");
	private static var PURCHASES_HEADER = LDBFormat.LDBGetText("MiscGUI", "TradePost_PurchasesHeader");
    
    //Properties
    private var m_UsableItemsOnlyCheckBox:MovieClip;
    private var m_UseExactNameCheckBox:MovieClip;

	private var m_MinStacksField:TextInput;
	private var m_MaxStacksField:TextInput;
    private var m_SearchField:TextInput;
    private var m_SearchHelptext:TextField;
    private var m_SearchContainer:MovieClip;
    private var m_ItemTypeDropdownMenu:MovieClip;
    private var m_SubTypeDropdownMenu:MovieClip;
	private var m_RarityDropdownMenu:MovieClip;
    private var m_RightClickMenu:MovieClip;
    private var m_SearchButton:MovieClip;
    private var m_ResultsFooter:MovieClip;
    private var m_ScrollBar:ScrollBar;
    private var m_CurrentDialog:DialogIF;
	private var m_SellItemPromptWindow:MovieClip;
	private var m_MySalesHeader:TextField;
	private var m_MySalesNumber:TextField;
	private var m_SaleInventory:MovieClip;
	private var m_MyPurchasesHeader:TextField;
	private var m_MyPurchasesNumber:TextField;
	private var m_PurchaseInventory:MovieClip;
	private var m_Cash:MovieClip;
	private var m_TimeCash:MovieClip;
	private var m_PremiumCash:MovieClip;
	private var m_MemberIcon:MovieClip;
	private var m_MemberText:TextField;
	
	private var m_SaleItemSlotsArray:Array;
	private var m_PurchaseItemSlotsArray:Array;
	private var m_TradepostInventory:Inventory;
	private var m_TradepostPurchaseInventory:Inventory;
	private var m_SellItemSlot:Number;
	private var m_SellItemInventory:ID32;
	private var m_CancelSaleSlot:Number;
	private var m_TakeItemSlot:Number;

    private var m_ResultsList:MultiColumnListView;
    private var m_ScrollBarPosition:Number;
    private var m_ResultsRowsArray:Array;
    
    private var m_BuyButton:Button;
    
    private var m_CheckBoxArray:Array;
    private var m_DropdownMenuArray:Array;

    private var m_CheckInterval:Number;
    private var m_UpdateSubtypeInterval:Number;
    
    private var m_SelectedItem:Number;
	private var m_CurrentSearchResult:Number;
    
    private var m_DisableSearchInterval:Number;
    private var m_Character:Character;
	    
    //Constructor
    public function BuyView()
    {
        super();
		
        var keyListener:Object = new Object();
        keyListener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(keyListener);
        
        m_Character = Character.GetClientCharacter();
        if (m_Character != undefined)
        {
            m_Character.SignalTokenAmountChanged.Connect(UpdateList, this);
			m_Character.SignalMemberStatusUpdated.Connect(SlotMemberStatusUpdated, this);
			SlotMemberStatusUpdated(m_Character.IsMember());
        }
		gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );  
    }
    
    public function onUnload()
    {
		gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "onDragEnd" );
        if (m_CurrentDialog != undefined)
        {
            m_CurrentDialog.Close();
        }
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
		
        m_SearchContainer.m_ItemTypeTextField.text = ITEM_TYPE;
        m_SearchContainer.m_SubTypeTextField.text = SUB_TYPE;
		m_SearchContainer.m_RarityTextField.text = RARITY;
		m_SearchContainer.m_StacksTextField.text = STACKS;
        m_SearchContainer.m_KeywordsTextField.text = KEYWORDS;
        
        m_UseExactNameCheckBox = m_SearchContainer.attachMovie("CheckboxDark", "m_UseExactNameCheckBox", m_SearchContainer.getNextHighestDepth());
        m_UseExactNameCheckBox.autoSize = "left";
        m_UseExactNameCheckBox.label = USE_EXACT_NAME;
        m_UseExactNameCheckBox.selected = false;
        
        m_UsableItemsOnlyCheckBox = m_ResultsFooter.attachMovie("CheckboxDark", "m_UsableItemsOnlyCheckBox", m_ResultsFooter.getNextHighestDepth());
        m_UsableItemsOnlyCheckBox.autoSize = "left";
        m_UsableItemsOnlyCheckBox.label = USABLE_ITEMS_ONLY;
        m_UsableItemsOnlyCheckBox.selected = false;
        m_UsableItemsOnlyCheckBox.addEventListener("select", this, "SlotFilterUsableItems");
        
        var types:Array = GetTypes();       
        m_ItemTypeDropdownMenu = m_SearchContainer.attachMovie("DropdownGray", "m_ItemTypeDropdownMenu", m_SearchContainer.getNextHighestDepth());
        m_ItemTypeDropdownMenu.dataProvider = types;
        m_ItemTypeDropdownMenu.width = 151;
        m_ItemTypeDropdownMenu.addEventListener("select", this, "SlotDropdownTypeSelected");  
        
        m_SubTypeDropdownMenu = m_SearchContainer.attachMovie("DropdownGray", "m_SubTypeDropdownMenu", m_SearchContainer.getNextHighestDepth());
        m_SubTypeDropdownMenu.dataProvider = [ { label: TYPE_ALL, idx: TYPE_ALL } ];
        m_SubTypeDropdownMenu.width = 191;
        m_SubTypeDropdownMenu.addEventListener("select", this, "RemoveFocusEventHandler"); 
		
		m_RarityDropdownMenu = m_SearchContainer.attachMovie("DropdownGray", "m_RarityDropdownMenu", m_SearchContainer.getNextHighestDepth());
        m_RarityDropdownMenu.dataProvider = [ { label: TYPE_ALL, idx: TYPE_ALL }, {label: RARITY_WHITE, idx: RARITY_WHITE}, 
											  {label: RARITY_GREEN, idx: RARITY_GREEN}, {label: RARITY_BLUE, idx: RARITY_BLUE}, 
											  {label: RARITY_PURPLE, idx: RARITY_PURPLE}, {label: RARITY_ORANGE, idx: RARITY_ORANGE},
											  {label: RARITY_RED, idx: RARITY_RED}];
        m_RarityDropdownMenu.width = 151;
        m_RarityDropdownMenu.addEventListener("select", this, "RemoveFocusEventHandler"); 

        m_DropdownMenuArray = new Array (
                                        m_ItemTypeDropdownMenu,
                                        m_SubTypeDropdownMenu,
										m_RarityDropdownMenu
                                        )
        
        for (var i:Number = 0; i < m_DropdownMenuArray.length; i++)
        {
            m_DropdownMenuArray[i].direction = "down";
            m_DropdownMenuArray[i].rowCount = m_DropdownMenuArray[i].dataProvider.length;
            m_DropdownMenuArray[i].selectedIndex = 0;
            m_DropdownMenuArray[i].dropdown = "DarkScrollingList";
            m_DropdownMenuArray[i].itemRenderer = "DarkListItemRenderer";
        } 
		
		m_MinStacksField.textField.restrict = m_MaxStacksField.textField.restrict = "0-9";
		
		m_MinStacksField.text = "0";
		m_MinStacksField.addEventListener("textChange", this, "SlotMinStacksChanged");
		
		m_MaxStacksField.text = "9999999";
		m_MaxStacksField.addEventListener("textChange", this, "SlotMaxStacksChanged");
        
        m_SelectedItem = 0;
        
        m_SearchButton = m_SearchContainer.attachMovie("ChromeButtonWhite", "m_SearchButton", m_SearchContainer.getNextHighestDepth());
        m_SearchButton.label = SEARCH;
        m_SearchButton.disableFocus = true;
        m_SearchButton.addEventListener("click", this, "SearchButtonClickEventHandler");

        m_ResultsList.SetItemRenderer("ResultItemRenderer");
        m_ResultsList.SetHeaderSpacing(3);
        m_ResultsList.SetShowBottomLine(true);
        m_ResultsList.SetScrollBar(m_ScrollBar);
        m_ResultsList.SignalItemClicked.Connect(SlotItemClicked, this);
        m_ResultsList.SignalSortClicked.Connect(SlotSortClicked, this);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ICON, LDBFormat.LDBGetText("MiscGUI", "TradePost_Item"), 58, ColumnData.COLUMN_NON_RESIZEABLE);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_NAME, LDBFormat.LDBGetText("MiscGUI", "TradePost_Name"), 333, 0);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_EXPIRES, LDBFormat.LDBGetText("MiscGUI", "TradePost_Expires"), 117, 0);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_BUY_PRICE, LDBFormat.LDBGetText("MiscGUI", "TradePost_Price"), 117, ColumnData.COLUMN_NON_RESIZEABLE);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_SELLER, LDBFormat.LDBGetText("MiscGUI", "TradePost_Seller"), 123, 0);
        m_ResultsList.SetSize(758, 390);
        m_ResultsList.SetSecondarySortColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_BUY_PRICE);
        m_ResultsList.DisableRightClickSelection(false);
        
        m_ScrollBar._height = m_ResultsList._height - 10;
        
        m_BuyButton.label = BUYITEM.toUpperCase();
        m_BuyButton.disabled = true;
        m_BuyButton.disableFocus = true;
        m_BuyButton.addEventListener("click", this, "BuyButtonClickEventHandler");
        
        m_CheckBoxArray = new Array(m_UsableItemsOnlyCheckBox, m_UseExactNameCheckBox);

        for (var i:Number = 0; i < m_CheckBoxArray.length; i++)
        {
            m_CheckBoxArray[i].addEventListener("click", this, "RemoveFocusEventHandler");
        }
        
        m_SearchField.maxChars = 100;
        m_ScrollBarPosition = 0;
        
        m_SearchHelptext.text = PRESS_SEARCH_BUTTON;
        
        CreateRightClickMenu();
		
		m_SellItemPromptWindow = attachMovie("SellItemPromptWindow", "m_SellItemPromptWindow", getNextHighestDepth());
        m_SellItemPromptWindow.SignalPromptResponse.Connect(SlotSellPromptResponse, this);
		
		m_TradepostInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_TradepostContainer, Character.GetClientCharID().GetInstance()));
		m_TradepostPurchaseInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_TradepostPurchaseContainer, Character.GetClientCharID().GetInstance()));
        
        m_TradepostInventory.SignalItemAdded.Connect(SlotItemAdded, this);
        m_TradepostInventory.SignalItemRemoved.Connect(SlotItemRemoved, this);
        m_TradepostInventory.SignalItemChanged.Connect(SlotItemChanged, this);
        m_TradepostInventory.SignalItemStatChanged.Connect(SlotItemChanged, this);
        m_TradepostInventory.SignalItemLoaded.Connect( SlotItemAdded, this );
		m_TradepostPurchaseInventory.SignalItemAdded.Connect(SlotItemAdded, this);
        m_TradepostPurchaseInventory.SignalItemRemoved.Connect(SlotItemRemoved, this);
        m_TradepostPurchaseInventory.SignalItemChanged.Connect(SlotItemChanged, this);
        m_TradepostPurchaseInventory.SignalItemStatChanged.Connect(SlotItemChanged, this);
        m_TradepostPurchaseInventory.SignalItemLoaded.Connect( SlotItemAdded, this );
		
		m_MySalesHeader.text = SALES_HEADER;
		m_MyPurchasesHeader.text = PURCHASES_HEADER;
		m_SaleItemSlotsArray = new Array();
		for (var i:Number = 0; i < TRADE_INVENTORY_SIZE; i++)
        {
			var itemSlotMovieClip:MovieClip = m_SaleInventory.m_Inventory.attachMovie("TradeInventoryItemTemplate", "m_ItemSlotMovieClip_" + i, m_SaleInventory.m_Inventory.getNextHighestDepth());
			itemSlotMovieClip._y = 2;
			itemSlotMovieClip._x = itemSlotMovieClip._width * i;
			
			var itemSlot:BankItemSlot = new BankItemSlot(m_TradepostInventory.m_InventoryID, i, itemSlotMovieClip);
			itemSlot.SignalMouseDown.Connect(SlotTradeInventoryMouseDown, this);
			m_SaleItemSlotsArray.push(itemSlot);
		}
		m_PurchaseItemSlotsArray = new Array();
		for (var i:Number = 0; i < TRADE_INVENTORY_SIZE; i++)
		{
			var itemSlotMovieClip:MovieClip = m_PurchaseInventory.m_Inventory.attachMovie("TradeInventoryItemTemplate", "m_ItemSlotMovieClip_" + i, m_PurchaseInventory.m_Inventory.getNextHighestDepth());
			itemSlotMovieClip._y = 2;
			itemSlotMovieClip._x = itemSlotMovieClip._width * i;
			
			var itemSlot:BankItemSlot = new BankItemSlot(m_TradepostPurchaseInventory.m_InventoryID, i, itemSlotMovieClip);
			itemSlot.SignalMouseDown.Connect(SlotPurchaseInventoryMouseDown, this);
			itemSlot.SignalStartDrag.Connect(onPurchaseDragBegin, this);
			m_PurchaseItemSlotsArray.push(itemSlot);
		}
		
		m_PremiumCash._x = m_Cash._x + m_Cash._width + 50;
		m_TimeCash._x = m_PremiumCash._x + m_PremiumCash._width + 50;
		
		UpdateItems();
        
        /*
         *  Tragedy strikes!
         * 
         *  Overriding UIComponent() doesn't work, so here I will employ a super ghetto interval check before calling the Layout
         *  function so the precious component can have its beauty sleep before updating its width after the auto-sizing
         *  label has been assigned.
         * 
         */
        
        Tradepost.SignalSearchResult.Connect(SlotResultsReceived, this);
         
        m_CheckInterval = setInterval(CheckButtonResize, 20, this);
    }
	
	function SlotMemberStatusUpdated(member:Boolean)
	{
		if (member)
		{
			m_MemberText.text = LDBFormat.LDBGetText("Tradepost", "MemberRemoteDelivery");
			m_MemberIcon._alpha = 100;
			m_MemberText.textColor = 0xD3A308;
		}
		else
		{
			m_MemberText.text = LDBFormat.LDBGetText("Tradepost", "NonMemberRemoteDelivery");
			m_MemberIcon._alpha = 33;
			m_MemberText.textColor = 0x666666;
		}
	}
	
	private function SlotTradeInventoryMouseDown(itemSlot:BankItemSlot, buttonIdx:Number, clickCount:Number):Void
	{
		if ( buttonIdx == 2 )
        {
			m_CancelSaleSlot = itemSlot.GetSlotID();
            UpdateRightClickMenu(RIGHT_CLICK_SALE, undefined, itemSlot.GetSlotID());
            PositionRightClickMenu();
            m_RightClickMenu.Show();
        }
        else 
        {
            m_RightClickMenu.Hide();
        }
	}
	
	private function SlotPurchaseInventoryMouseDown(itemSlot:BankItemSlot, buttonIdx:Number, clickCount:Number):Void
	{
		if (Tradepost.CanClaimTradepostPurchase())
		{
			if ( buttonIdx == 2 )
			{
				m_TakeItemSlot = itemSlot.GetSlotID();
				UpdateRightClickMenu(RIGHT_CLICK_PURCHASE, undefined, itemSlot.GetSlotID());
				PositionRightClickMenu();
				m_RightClickMenu.Show();
			}
			else 
			{
				m_RightClickMenu.Hide();
			}
		}
		else
		{
			com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("Tradepost", "PurchaseClaimRestricted"), 0);
		}
	}
	
	private function onPurchaseDragBegin(item:BankItemSlot, stackSize:Number):Void
    {
		if (Tradepost.CanClaimTradepostPurchase())
		{
			var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, item, stackSize);
			dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
			dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
		}
		else
		{
			com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("Tradepost", "PurchaseClaimRestricted"), 0);
		}
    }
	
	private function SlotItemDroppedOnDesktop():Void
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        currentDragObject.DragHandled();
    }
	
	private function SlotDragHandled()
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        var slot:BankItemSlot = m_PurchaseItemSlotsArray[currentDragObject.inventory_slot];
        
        if ( slot != undefined && slot.HasItem() )
        {
            slot.SetAlpha(100);
            slot.UpdateFilter();
        }
    }
	
	//Update Items
    private function UpdateItems():Void
    {
    	var numItems:Number = 0;
		for (var i:Number = 0; i < m_SaleItemSlotsArray.length; i++)
		{
			m_SaleItemSlotsArray[i].SetSlotID(i);
			
			if (m_TradepostInventory.GetItemAt(i) != undefined)
			{
				numItems++;
				m_SaleItemSlotsArray[i].SetData(m_TradepostInventory.GetItemAt(i));
			}
			else
			{
				m_SaleItemSlotsArray[i].Clear();
			}
		}        
        var numMaxItems:Number = m_TradepostInventory.GetMaxItems();		
		m_MySalesNumber.text = numItems + "/" + numMaxItems +" " + LDBFormat.LDBGetText("GenericGUI", "Items" );
		
		numItems = 0;
		for (var i:Number = 0; i < m_PurchaseItemSlotsArray.length; i++)
		{
			m_PurchaseItemSlotsArray[i].SetSlotID(i);
			
			if (m_TradepostPurchaseInventory.GetItemAt(i) != undefined)
			{
				numItems++;
				m_PurchaseItemSlotsArray[i].SetData(m_TradepostPurchaseInventory.GetItemAt(i));
			}
			else
			{
				m_PurchaseItemSlotsArray[i].Clear();
			}
		}        
        numMaxItems = m_TradepostPurchaseInventory.GetMaxItems();		
		m_MyPurchasesNumber.text = numItems + "/" + numMaxItems +" " + LDBFormat.LDBGetText("GenericGUI", "Items" );
    }
	
	//Slot Min Stacks Changed
    private function SlotMinStacksChanged(event:Object):Void
    {
        var min:Number = parseInt(m_MinStacksField.text, 10);
        var max:Number = parseInt(m_MaxStacksField.text, 10);
        
        if ( min > max )
        {
            m_MinStacksField.text = max.toString();
        }
    }
    
    //Slot Max Stacks Changed
    private function SlotMaxStacksChanged(event:Object):Void
    {
        var max:Number = parseInt(m_MaxStacksField.text, 10);
        var min:Number = parseInt(m_MinStacksField.text, 10);

        if (max > 9999999)
        {
            m_MaxStacksField.text = "9999999";
        }
        
        if ( max < min )
        {
            m_MaxStacksField.text = min.toString();
        }
    }
	
	public function PromptSale(inventoryID:ID32, slotID:Number)
	{
		if (inventoryID.GetType() != _global.Enums.InvType.e_Type_GC_GuildContainer)
		{
			m_SellItemPromptWindow.ShowPrompt();
			m_SellItemInventory = inventoryID;
			m_SellItemSlot = slotID;
		}
	}
	
	//On Drag End
    private function onDragEnd(event:Object):Void
    {
		if (event.cancelled || event.data.inventory_id.Equal(m_TradepostPurchaseInventory.GetInventoryID()))
        {
            event.data.DragHandled();
            return;
        }
		
		var isTheRightType:Boolean = ( event.data.type == "item");
		
		if ( isTheRightType && Mouse["IsMouseOver"](this))
        {
			PromptSale(event.data.inventory_id, event.data.inventory_slot);
			event.data.DragHandled();
		}
	}
	
	//Slot Prompt Response
    private function SlotSellPromptResponse(price:Number):Void
    {
        Tradepost.SellItem(m_SellItemInventory, m_SellItemSlot, GetItemPriceFromCash(price));
    }
	
	public function GetItemPriceFromCash(cash:Number):ItemPrice
    {
        var price:ItemPrice = new ItemPrice();
		price.m_TokenType1 = _global.Enums.Token.e_Gold_Bullion_Token;
		price.m_TokenType1_Amount = cash;
        price.m_TokenType2 = _global.Enums.Token.e_InvalidToken;
        price.m_TokenType2_Amount = 0;  
        return price;
    }
    
    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        switch (Key.getCode())
        {
            case Key.TAB:      	if (Selection.getFocus() == m_MinStacksField.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? HighlightTextField(m_SearchField.textField) : HighlightTextField(m_MaxStacksField.textField);
                                }
								else if (Selection.getFocus() == m_MaxStacksField.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? HighlightTextField(m_MinStacksField.textField) : Selection.setFocus(m_SearchField.textField);
                                }
                                else if (Selection.getFocus() == m_SearchField.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? HighlightTextField(m_MaxStacksField.textField) : HighlightTextField(m_MinStacksField.textField);
                                }
                                
                                break;

            case Key.ENTER:     if (Selection.getFocus() == m_SearchField.textField ||
									Selection.getFocus() == m_MinStacksField.textField || Selection.getFocus() == m_MaxStacksField.textField)
                                {
                                    if (!m_SearchButton.disabled)
                                    {
                                        Search();
                                    }
                                }	
                                
                                break;
        }
    }
    
        //Create Right Click Menu
    public function CreateRightClickMenu():Void
    {
        var ref:MovieClip = m_ResultsList._parent;
        m_RightClickMenu = ref.attachMovie("RightClickMenu", "m_RightClickMenu", ref.getNextHighestDepth());
        m_RightClickMenu.width = 250;
        m_RightClickMenu._visible = false;
        m_RightClickMenu.SetHandleClose(false);
        m_RightClickMenu.SignalWantToClose.Connect(SlotHideRightClickMenu, this);
    }
    
    //Slot Hide Right Click Menu
    function SlotHideRightClickMenu():Void
    {
        m_RightClickMenu.Hide();
    }
    
    //Update Menu Title
    function UpdateRightClickMenu(RightClickMode:Number, item:MCLItemInventoryItem, itemSlot:Number):Void
    {
        var menuDataProvider:Array = new Array();
        if (RightClickMode == RIGHT_CLICK_LIST)
		{
			var isItemFromUser:Boolean = IsItemFromUser(item);
			menuDataProvider.push(new RightClickItem(item.m_InventoryItem.m_Name, true, RightClickItem.CENTER_ALIGN));
			
			menuDataProvider.push(RightClickItem.MakeSeparator());
			
			var option:RightClickItem;
			option = new RightClickItem(BUYITEM, false, RightClickItem.LEFT_ALIGN);
			option.SignalItemClicked.Connect(BuyButtonClickEventHandler, this);
			
			if (isItemFromUser)
			{
				option.SetEnabled(false);
			}
			menuDataProvider.push(option);
			if ( isItemFromUser )
			{
				option = new RightClickItem(LDBFormat.LDBGetText("Tradepost", "CantBuyItemFromSelf"), false, RightClickItem.LEFT_ALIGN);
				option.SetEnabled(false);
				option.SetIsNotification(true);
				menuDataProvider.push(option);
			}
		}
		else if (RightClickMode == RIGHT_CLICK_SALE)
		{
			var inventoryItem:InventoryItem = m_TradepostInventory.GetItemAt(itemSlot);
			menuDataProvider.push(new RightClickItem(inventoryItem.m_Name, true, RightClickItem.CENTER_ALIGN));
			menuDataProvider.push(RightClickItem.MakeSeparator());
			
			var option:RightClickItem = new RightClickItem(CANCEL_SALE, false, RightClickItem.LEFT_ALIGN);
			option.SignalItemClicked.Connect(CancelSaleClickEventHandler, this);
			menuDataProvider.push(option);			
		}
		else if (RightClickMode == RIGHT_CLICK_PURCHASE)
		{
			var inventoryItem:InventoryItem = m_TradepostPurchaseInventory.GetItemAt(itemSlot);
			menuDataProvider.push(new RightClickItem(inventoryItem.m_Name, true, RightClickItem.CENTER_ALIGN));
			menuDataProvider.push(RightClickItem.MakeSeparator());
			
			var option:RightClickItem = new RightClickItem(CLAIM_ITEM, false, RightClickItem.LEFT_ALIGN);
			option.SignalItemClicked.Connect(ClaimItemClickEventHandler, this);
			menuDataProvider.push(option);	
		}

        m_RightClickMenu.dataProvider = menuDataProvider;
    }
    
    //Position Right Click Menu
    private function PositionRightClickMenu():Void
    {
        var visibleRect = Stage["visibleRect"];
        
        m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._xmouse + m_RightClickMenu._width - visibleRect.width);
        m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._ymouse + m_RightClickMenu._height - visibleRect.height);
    }
    
    //Highlight Text Field
    private function HighlightTextField(textField:TextField):Void
    {
        Selection.setFocus(textField);
        Selection.setSelection(0, textField.text.length);
    }
    
    //Get Types
    private function GetTypes():Array
    {
        var types:Array = new Array();
        for ( var key:String in Tradepost.m_TradepostItemTypes )
        {
            key = parseInt(key, 10); //The String has something wrong
            types.push({label: LDBFormat.LDBGetText(10010, key), idx: key});
        }
		types.sortOn("label");
        return types;
    }
    
    //Get Sub Types
    private function GetSubtypes(type:String):Array 
    {
        var subtypes:Array = new Array();
        for (var i:Number = 0; i < Tradepost.m_TradepostItemTypes[type].length; ++i )
        {
            var key:String = Tradepost.m_TradepostItemTypes[type][i];
            subtypes.push({label: LDBFormat.LDBGetText(10010, key), idx: key});
        }
        subtypes.sortOn("label");
        return subtypes;
    }
    
    //Slot Dropdown Type Selected
    private function SlotDropdownTypeSelected(event:Object):Void
    {
        if (!event.target.isOpen)
        {
            m_UpdateSubtypeInterval = setInterval(UpdateSubtypesDropdown, 20, this);
            Selection.setFocus(null);
        }
    }
    
    //Slot Filter Usable Items
    private function SlotFilterUsableItems(event:Object):Void
    {
        SlotResultsReceived();
    }
    
    //Update Subtypes Dropdown
    private function UpdateSubtypesDropdown(scope:Object):Void
    {
        clearInterval(scope.m_UpdateSubtypeInterval);
        
        var subtypes:Array = new Array();
        subtypes.push({label: TYPE_ALL, idx: TYPE_ALL});
        subtypes = subtypes.concat( scope.GetSubtypes(scope.m_ItemTypeDropdownMenu.selectedItem.idx));
        
        scope.m_SubTypeDropdownMenu.dataProvider = subtypes;
        scope.m_SubTypeDropdownMenu.rowCount = subtypes.length;
    }
    
    //Remove Focus Event Handler
    private function RemoveFocusEventHandler(event:Object):Void
    {
        if (!event.target.isOpen)
        {
            Selection.setFocus(null);
        }
    }
    
    //Search Button Click Event Handler
    private function SearchButtonClickEventHandler(event:Object):Void
    {
        Search();
        
        RemoveFocusEventHandler(event);
    }
    
    //Search
    private function Search():Void
    {
        m_SearchButton.disabled = true;
        
        Tradepost.m_SearchCriteria.m_ItemTypeVec = new Array();
        
        if ( m_ItemTypeDropdownMenu.selectedItem.idx != TYPE_ALL )
        {
            Tradepost.m_SearchCriteria.m_ItemTypeVec.push(parseInt(m_ItemTypeDropdownMenu.selectedItem.idx, 10));
        }

        Tradepost.m_SearchCriteria.m_ItemClassVec = new Array();
        Tradepost.m_SearchCriteria.m_ItemSubtypeVec = new Array();
        
        if ( m_SubTypeDropdownMenu.selectedItem.idx != TYPE_ALL )
        {
            Tradepost.m_SearchCriteria.m_ItemSubtypeVec.push(m_SubTypeDropdownMenu.selectedItem.idx);
        }        

        Tradepost.m_SearchCriteria.m_ItemPlacement = -1;
		
		var powerLevel:Number = m_RarityDropdownMenu.selectedIndex;
		if (powerLevel == 0){ powerLevel = -1; } //We don't use powerlevel 0 items, and this index is TYPE_ALL
		
		Tradepost.m_SearchCriteria.m_TokenTypeVec = new Array();
		//Always search for all currencies, there is only one anyway
		
		var minStacks:Number = parseInt(m_MinStacksField.text, 10);
        var maxStacks:Number = parseInt(m_MaxStacksField.text, 10);
        
        if ( minStacks == 0 && maxStacks == 9999999 ||
			 minStacks == 0 && maxStacks == 0)
        {
            Tradepost.m_SearchCriteria.m_MinStackSize = -1;
            Tradepost.m_SearchCriteria.m_MaxStackSize = -1;
        }
        else
        {
            Tradepost.m_SearchCriteria.m_MinStackSize = minStacks;
            Tradepost.m_SearchCriteria.m_MaxStackSize = maxStacks;
        }
		        
        Tradepost.m_SearchCriteria.m_MinPowerLevel = powerLevel;
        Tradepost.m_SearchCriteria.m_MaxPowerLevel = powerLevel;
        Tradepost.m_SearchCriteria.m_MinPrice = 0;
        Tradepost.m_SearchCriteria.m_MaxPrice = 99999999;
        Tradepost.m_SearchCriteria.m_SellerName = "";
        Tradepost.m_SearchCriteria.m_SearchString = m_SearchField.text;
        Tradepost.m_SearchCriteria.m_SellerInstance = 0;
        Tradepost.m_SearchCriteria.m_UseExactName = m_UseExactNameCheckBox.selected;
        Tradepost.MakeSearch();
        
        m_ScrollBar.position = m_ScrollBarPosition = 0;
        
        m_DisableSearchInterval = setInterval(Delegate.create(this, SlotEnableSearch),2000,this);
    }
    
    private function SlotEnableSearch():Void
    {
        m_SearchButton.disabled = false;
        if (m_DisableSearchInterval != undefined)
        {
            clearInterval(m_DisableSearchInterval);
            m_DisableSearchInterval = undefined;
        }
    }

    //Slot Results Received
    private function SlotResultsReceived() : Void
    {
        m_SearchHelptext._visible = false;
        
        var itemsArray:Array = new Array();
        UnSelectRows();
        m_ResultsList.RemoveAllItems();
        
        var resultsCount:Number = Tradepost.m_SearchResults.length;
        var showUsableOnly:Boolean = m_UsableItemsOnlyCheckBox.selected;
            
        for (var i:Number = 0; i < resultsCount; ++i )
        {
            var result:TradepostSearchResultData = Tradepost.m_SearchResults[i];
			m_CurrentSearchResult = result.m_SearchResultId;
            
            if (!showUsableOnly || result.m_Item.m_CanUse)
            {
				trace(result.m_TokenType1);
                result.m_Item.m_TokenCurrencyType1 = result.m_TokenType1;
                result.m_Item.m_TokenCurrencyPrice1 = result.m_TokenType1_Amount;
                result.m_Item.m_TokenCurrencyType2 = result.m_TokenType2;
                result.m_Item.m_TokenCurrencyPrice2 = result.m_TokenType2_Amount;
				

                
                var item:MCLItemInventoryItem = new MCLItemInventoryItem(result.m_Item, undefined);
				item.SetId( result.m_ItemId );
		
                item.m_Seller = result.m_SellerName;
                item.m_Expires = Math.round(result.m_ExpireDate / 86400) + " " + EXPIRATION_DAYS;
                
                itemsArray.push(item);
            }
        }        

        m_ResultsList.AddItems(itemsArray);
        m_ResultsList.SetSortColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_NAME);
        m_ResultsList.Resort();
        m_ResultsList.SetScrollBar(m_ScrollBar);
        Layout();
    }
    
    private function UpdateList():Void
    {
        m_ResultsList.ResetRenderers();
    }
    
	private function CancelSaleClickEventHandler(event:Object):Void
	{
		Tradepost.CancelSellItem( m_CancelSaleSlot )
	}
	
	private function ClaimItemClickEventHandler(event:Object):Void
	{
		var succeed:Boolean = false;
		var backpackInventory:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, Character.GetClientCharID().GetInstance()));
		var firstSlot:Number = backpackInventory.GetFirstFreeItemSlot();
		if (firstSlot != -1)
		{
			var addItemResult:Number = backpackInventory.AddItem(m_TradepostPurchaseInventory.GetInventoryID(), m_TakeItemSlot, firstSlot);
			succeed = (addItemResult == _global.Enums.InventoryAddItemResponse.e_AddItem_Success);
		}
		Character.GetClientCharacter().AddEffectPackage((succeed) ? "sound_fxpackage_GUI_item_slot.xml" : "sound_fxpackage_GUI_item_slot_fail.xml");
	}
	
    //Buy Button Click Event Handler
    private function BuyButtonClickEventHandler(event:Object):Void
    {
        var dialogText:String;
        if ( m_SelectedItem > 0)
        {
            dialogText = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI",  "TradePost_BuyConfirm"), m_ResultsList.GetItems()[m_ResultsList.GetIndexById(m_SelectedItem)].m_InventoryItem.m_Name);
        }
        else
        { //No name available? Use generic message
            dialogText = LDBFormat.LDBGetText("MiscGUI", "ConfirmBuyTradepostItem");
        }
        
        m_CurrentDialog = new DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "ConfirmBuyItem" );
        m_CurrentDialog.SignalSelectedAS.Connect( SlotBuyItemDialog, this );
        m_CurrentDialog.Go(undefined);
    }
    
    //Slot Buy Item Dialog
    private function SlotBuyItemDialog(buttonID:Number, boxIdx:Number)
    {
        if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
        {
            if (m_SelectedItem > 0)
            {
                var itemID:Number = m_ResultsList.GetItems()[m_ResultsList.GetIndexById(m_SelectedItem)].GetId();;
                
                var buy:Boolean = Tradepost.BuyItem(m_SelectedItem, m_CurrentSearchResult);
                
                if ( buy )
                {
                    var arraySize:Number = Tradepost.m_SearchResults.length;
                    for (var i:Number = 0; i < arraySize; ++i )
                    {
                        if (Tradepost.m_SearchResults[i].m_SearchResultId == m_CurrentSearchResult && Tradepost.m_SearchResults[i].m_ItemId == m_SelectedItem )
                        {
                            Tradepost.m_SearchResults.splice(i,1);
                            break;
                        }
                    }
                    
                    m_ResultsList.RemoveItemById(m_SelectedItem);
                    m_ResultsList.ClearSelection();
                    m_BuyButton.disabled = true;
                }
            }
        }
    }
    
    //Check Button Resize
    private function CheckButtonResize(scope:Object):Void
    {
        if (
           (scope.m_UsableItemsOnlyCheckBox._width   != DEFAULT_CHECKBOX_WIDTH)     &&
           (scope.m_UseExactNameCheckBox._width      != DEFAULT_CHECKBOX_WIDTH)     
           )
        {
            clearInterval(scope.m_CheckInterval);
            scope.Layout();
        }
    }
    
    //Layout
    private function Layout():Void
    {
        m_UseExactNameCheckBox._x = m_SearchField._x + m_SearchField._width - m_UseExactNameCheckBox._width;
        m_UseExactNameCheckBox._y = m_SearchContainer.m_KeywordsTextField._y;
       
        m_UsableItemsOnlyCheckBox._x = m_ResultsFooter._width - m_UsableItemsOnlyCheckBox._width - GENERAL_GAP;
        m_UsableItemsOnlyCheckBox._y = m_ResultsFooter._height / 2 - m_UsableItemsOnlyCheckBox._height / 2;
        
        m_ItemTypeDropdownMenu._x = m_SearchContainer.m_ItemTypeTextField._x;
        m_SubTypeDropdownMenu._x = m_SearchContainer.m_SubTypeTextField._x;
		m_RarityDropdownMenu._x = m_SearchContainer.m_RarityTextField._x;
        
        for (var i:Number = 0; i < m_DropdownMenuArray.length; i++)
        {
            m_DropdownMenuArray[i]._y = DROPDOWN_CONTROLS_Y;
        }
        
        m_SearchButton._x = m_SearchContainer._width - m_SearchButton._width - GENERAL_GAP;
        m_SearchButton._y = SEARCH_CONTROLS_Y;
        
        var textFormat:TextFormat = m_SearchField.textField.getTextFormat();
        textFormat.align = "left";
        m_SearchField.textField.setTextFormat(textFormat);
    }

    //Slot Item Clicked
    private function SlotItemClicked(index:Number,buttonIndex:Number):Void
    {
        m_SelectedItem = m_ResultsList.GetItems()[index].GetId();
        
        m_BuyButton.disabled = IsItemFromUser(m_ResultsList.GetItems()[index]);
        
        if ( buttonIndex == 2 )
        {
            UpdateRightClickMenu(RIGHT_CLICK_LIST, m_ResultsList.GetItems()[index], undefined);
            PositionRightClickMenu();
            m_RightClickMenu.Show();
        }
        else 
        {
            m_RightClickMenu.Hide();
        }
    }
    
    private function IsItemFromUser(item:MCLItemInventoryItem):Boolean
    {
        return item.m_Seller == m_Character.GetName();
    }
    
    //Slot Sort Clicked
    private function SlotSortClicked():Void
    {
        UnSelectRows();
    }
    
    //Unselect Rows
    private function UnSelectRows():Void
    {
        m_BuyButton.disabled = true;
        m_SelectedItem = 0;
        m_ResultsList.ClearSelection(); 
        m_RightClickMenu.Hide();
    }
	
	//Slot Item Added
    function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number):Void
    {
		var inventory = undefined;
		var slotArray = undefined;
		var counterClip:TextField = undefined;
		if (inventoryID.Equal(m_TradepostInventory.GetInventoryID()))
		{
			inventory = m_TradepostInventory;
			slotArray = m_SaleItemSlotsArray;
			counterClip = m_MySalesNumber;
		}
		else if (inventoryID.Equal(m_TradepostPurchaseInventory.GetInventoryID()))
		{
			inventory = m_TradepostPurchaseInventory;
			slotArray = m_PurchaseItemSlotsArray;
			counterClip = m_MyPurchasesNumber;
		}
		slotArray[itemPos].SetData(inventory.GetItemAt(itemPos));  
		
		var numItems:Number = 0;
		for (var prop:String in inventory.m_Items)
        {
            if (inventory.GetItemAt(prop) != undefined )
            {
                numItems++;
            }
        }		
        var numMaxItems:Number = inventory.GetMaxItems();		
		counterClip.text = numItems + "/" + numMaxItems +" " + LDBFormat.LDBGetText("GenericGUI", "Items" );
    }
    
    //Slot Item Removed
    function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean):Void
    {
		var inventory = undefined;
		var slotArray = undefined;
		var counterClip:TextField = undefined;
		if (inventoryID.Equal(m_TradepostInventory.GetInventoryID()))
		{
			inventory = m_TradepostInventory;
			slotArray = m_SaleItemSlotsArray;
			counterClip = m_MySalesHeader;
		}
		else if (inventoryID.Equal(m_TradepostPurchaseInventory.GetInventoryID()))
		{
			inventory = m_TradepostPurchaseInventory;
			slotArray = m_PurchaseItemSlotsArray;
			counterClip = m_MyPurchasesNumber;
		}
    	slotArray[itemPos].Clear();
		
		var numItems:Number = 0;
		for (var prop:String in inventory.m_Items)
        {
            if (inventory.GetItemAt(prop) != undefined )
            {
                numItems++;
            }
        }		
        var numMaxItems:Number = inventory.GetMaxItems();		
		counterClip.text = numItems + "/" + numMaxItems +" " + LDBFormat.LDBGetText("GenericGUI", "Items" );
    }
    
    //Slot Item Stat Changed
    function SlotItemStatChanged(inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number):Void
    {  
        SlotItemChanged(inventoryID, itemPos);
    }
    
    //Slot Item Changed
    function SlotItemChanged(inventoryID:com.Utils.ID32, itemPos:Number):Void
    {
		var inventory = undefined;
		var slotArray = undefined;
		if (inventoryID.Equal(m_TradepostInventory.GetInventoryID()))
		{
			inventory = m_TradepostInventory;
			slotArray = m_SaleItemSlotsArray;
		}
		else if (inventoryID.Equal(m_TradepostPurchaseInventory.GetInventoryID()))
		{
			inventory = m_TradepostPurchaseInventory;
			slotArray = m_PurchaseItemSlotsArray;
		}
		slotArray[itemPos].SetData(inventory.GetItemAt(itemPos));
    }
}
