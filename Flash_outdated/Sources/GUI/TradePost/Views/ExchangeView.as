import gfx.core.UIComponent;
import gfx.controls.TextInput;
import gfx.controls.Button;
import com.Utils.Text;
import com.Components.FCButton;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;
import com.GameInterface.Tradepost;
import com.GameInterface.ItemPrice;
import com.GameInterface.Utils;
import com.GameInterface.ShopInterface;
import com.GameInterface.DialogIF;
import com.Utils.LDBFormat;

class GUI.TradePost.Views.ExchangeView extends UIComponent
{
	//Components created in .fla
	private var m_Cash:MovieClip;
	private var m_PremiumCash:MovieClip;
	private var m_TimeCash:MovieClip;
	private var m_BuyPane:MovieClip;
	private var m_SellPane:MovieClip;
	private var m_WithdrawButton:Button;
	private var m_BalanceHeader:TextField;
	private var m_PremiumBalance:TextField;
	private var m_Balance:TextField;
	private var m_BuyAurumButton:Button;
	
	//Variables
	
	//Statics
	private static var COLUMN_QUANTITY:Number = 0;
    private static var COLUMN_PRICE:Number = 1;
	
	public function ExchangeView()
    {
        super();
    }
	
	private function configUI():Void
    {
        super.configUI();
		
		m_BuyPane.m_Quantity.textField.restrict = m_BuyPane.m_UnitPrice.textField.restrict = "0-9";
        
        m_BuyPane.m_Quantity.text = "";
        m_BuyPane.m_Quantity.addEventListener("textChange", this, "UpdatePostStatus");
        
        m_BuyPane.m_UnitPrice.text = "";
        m_BuyPane.m_UnitPrice.addEventListener("textChange", this, "UpdatePostStatus"); 
		
		m_BuyPane.m_RefreshButton.addEventListener("click", this, "RequestRefresh")
		
		m_BuyPane.m_PostButton.addEventListener("click", this, "PostBuyOrder");
		m_BuyPane.m_CancelButton.addEventListener("click", this, "CancelBuyOrder");
		m_BuyPane.m_PostButton.disableFocus = true;
		m_BuyPane.m_CancelButton.disableFocus = true;
		
		m_SellPane.m_Quantity.textField.restrict = m_SellPane.m_UnitPrice.textField.restrict = "0-9";
        
        m_SellPane.m_Quantity.text = "";
        m_SellPane.m_Quantity.addEventListener("textChange", this, "UpdatePostStatus");
        
        m_SellPane.m_UnitPrice.text = "";
        m_SellPane.m_UnitPrice.addEventListener("textChange", this, "UpdatePostStatus"); 
		
		m_SellPane.m_RefreshButton.addEventListener("click", this, "RequestRefresh")
		
		m_SellPane.m_PostButton.addEventListener("click", this, "PostSellOrder");
		m_SellPane.m_CancelButton.addEventListener("click", this, "CancelSellOrder");
		m_SellPane.m_PostButton.disableFocus = true;
		m_SellPane.m_CancelButton.disableFocus = true;
		
		var saleList:MultiColumnListView = m_BuyPane.m_List;
		var buyList:MultiColumnListView = m_SellPane.m_List;
		
		saleList.SetItemRenderer("ExchangeItemRenderer");
        saleList.SetHeaderSpacing(3);
        saleList.SetShowBottomLine(true);        
        saleList.AddColumn(COLUMN_QUANTITY, LDBFormat.LDBGetText("Tradepost", "Exchange_QuantityForSale"), 175, 0);
        saleList.AddColumn(COLUMN_PRICE, LDBFormat.LDBGetText("Tradepost", "Exchange_UnitPrice"), 175, 0);
        saleList.SetSize(350, 180);
		saleList.SetSortColumn(COLUMN_PRICE);
		saleList.SetSortDirection(Array.ASCENDING);
		
		buyList.SetItemRenderer("ExchangeItemRenderer");
        buyList.SetHeaderSpacing(3);
        buyList.SetShowBottomLine(true);        
        buyList.AddColumn(COLUMN_QUANTITY, LDBFormat.LDBGetText("Tradepost", "Exchange_QuantityRequested"), 175, 0);
        buyList.AddColumn(COLUMN_PRICE, LDBFormat.LDBGetText("Tradepost", "Exchange_UnitPrice"), 175, 0);
        buyList.SetSize(350, 180);
		buyList.SetSortColumn(COLUMN_PRICE);
		buyList.SetSortDirection(Array.ASCENDING);
		
		m_WithdrawButton.disableFocus = true;
		m_WithdrawButton.addEventListener("click", this, "WithdrawExchangeBalance");
		
		m_BuyAurumButton.disableFocus = true;
		m_BuyAurumButton.addEventListener("click", this, "BuyAurum");
		
		SetLabels();
		
		//Disable these until the exchange status comes back.
		m_BuyPane.m_PostButton.disabled = true;
		m_SellPane.m_PostButton.disabled = true;
		
		Tradepost.SignalExchangeUpdated.Connect(SlotUpdateExchange, this);
		Tradepost.RequestExchangeUpdate();
		
		m_PremiumCash._x = m_Cash._x + m_Cash._width + 50;
		m_TimeCash._x = m_PremiumCash._x + m_PremiumCash._width + 50;
	}
	
	private function SetLabels():Void
	{
		m_BuyPane.m_Header.text = LDBFormat.LDBGetText("Tradepost", "Exchange_BuyHeader");
		m_BuyPane.m_QuantityLabel.text = LDBFormat.LDBGetText("Tradepost", "Exchange_BuyPremium");
		m_BuyPane.m_PriceLabel.text = LDBFormat.LDBGetText("Tradepost", "Exchange_MaximumPrice");
		m_BuyPane.m_InstructionText.text = LDBFormat.LDBGetText("Tradepost", "Exchange_BuyInstructions");
		m_BuyPane.m_PostButton.label = LDBFormat.LDBGetText("Tradepost", "Exchange_Post");
		m_BuyPane.m_ListHeader.text = LDBFormat.LDBGetText("Tradepost", "Exchange_TopSales");
		m_BuyPane.m_OrderHeader.text = LDBFormat.LDBGetText("Tradepost", "Exchange_CurrentBuyOrder");
		m_BuyPane.m_OrderQuantityLabel.text = LDBFormat.LDBGetText("Tradepost", "Exchange_PurchaseQuantity");
		m_BuyPane.m_OrderPriceLabel.text = LDBFormat.LDBGetText("Tradepost", "Exchange_UnitPrice");
		m_BuyPane.m_CancelButton.label = LDBFormat.LDBGetText("Tradepost", "Exchange_Cancel");
		
		m_SellPane.m_Header.text = LDBFormat.LDBGetText("Tradepost", "Exchange_SellHeader");
		m_SellPane.m_QuantityLabel.text = LDBFormat.LDBGetText("Tradepost", "Exchange_SellPremium");
		m_SellPane.m_PriceLabel.text = LDBFormat.LDBGetText("Tradepost", "Exchange_MinimumPrice");
		m_SellPane.m_InstructionText.text = LDBFormat.LDBGetText("Tradepost", "Exchange_SellInstructions");
		m_SellPane.m_PostButton.label = LDBFormat.LDBGetText("Tradepost", "Exchange_Post");
		m_SellPane.m_ListHeader.text = LDBFormat.LDBGetText("Tradepost", "Exchange_TopPurchases");
		m_SellPane.m_OrderHeader.text = LDBFormat.LDBGetText("Tradepost", "Exchange_CurrentSellOrder");
		m_SellPane.m_OrderQuantityLabel.text = LDBFormat.LDBGetText("Tradepost", "Exchange_SellQuantity");
		m_SellPane.m_OrderPriceLabel.text = LDBFormat.LDBGetText("Tradepost", "Exchange_UnitPrice");
		m_SellPane.m_CancelButton.label = LDBFormat.LDBGetText("Tradepost", "Exchange_Cancel");
		
		m_WithdrawButton.label = LDBFormat.LDBGetText("Tradepost", "Exchange_Withdraw");
		m_BalanceHeader.text = LDBFormat.LDBGetText("Tradepost", "Exchange_BalanceHeader");
		m_BuyAurumButton.label = LDBFormat.LDBGetText("Tradepost", "Exchange_BuyAurum");
	}
	
	private function RequestRefresh():Void
	{
		Tradepost.RequestExchangeUpdate();
		Selection.setFocus(null);
	}
	
	private function SlotUpdateExchange():Void
	{
		PopulateOrders();
		PopulateOffers();
		PopulateBalance();
		UpdatePostStatus();
	}
	
	private function PopulateOrders():Void
	{
		if (Tradepost.HasBuyOrder())
		{
			var buyOrder:ItemPrice = Tradepost.GetBuyOrder();
			m_BuyPane.m_OrderQuantity.text = buyOrder.m_TokenType1_Amount;
			m_BuyPane.m_OrderPrice.text = buyOrder.m_TokenType2_Amount;
		}
		else
		{
			m_BuyPane.m_OrderQuantity.text = 0;
			m_BuyPane.m_OrderPrice.text = 0;
		}
		if (Tradepost.HasSellOrder())
		{
			var sellOrder:ItemPrice = Tradepost.GetSellOrder();
			m_SellPane.m_OrderQuantity.text = sellOrder.m_TokenType1_Amount;
			m_SellPane.m_OrderPrice.text = sellOrder.m_TokenType2_Amount;
		}
		else
		{
			m_SellPane.m_OrderQuantity.text = 0;
			m_SellPane.m_OrderPrice.text = 0;
		}
	}
	
	private function PopulateOffers():Void
	{
		var saleList:MultiColumnListView = m_BuyPane.m_List;
		var buyList:MultiColumnListView = m_SellPane.m_List;
		
		saleList.RemoveAllItems();
		buyList.RemoveAllItems();
		
		var saleOffers = Tradepost.GetTopSaleOffers();
		for (var i:Number = 0; i < saleOffers.length; i++)
		{
			var offerItem:MCLItemDefault = new MCLItemDefault(i);
			
			var quantityValueData:MCLItemValueData = new MCLItemValueData();
			quantityValueData.m_MovieClipName = "T" + saleOffers[i].m_TokenType1;
			quantityValueData.m_MovieClipWidth = 30;
			quantityValueData.m_Number = saleOffers[i].m_TokenType1_Amount;
			offerItem.SetValue(COLUMN_QUANTITY, quantityValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
			
			var priceValueData:MCLItemValueData = new MCLItemValueData();
			priceValueData.m_MovieClipName = "T" + saleOffers[i].m_TokenType2;
			priceValueData.m_MovieClipWidth = 30;
			priceValueData.m_Number = saleOffers[i].m_TokenType2_Amount;
			offerItem.SetValue(COLUMN_PRICE, priceValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
			
			saleList.SetItem(offerItem);
		}
		
		saleList.SetSortColumn(COLUMN_PRICE);
		saleList.SetSortDirection(Array.ASCENDING);
		saleList.Resort();
		
		var buyOffers = Tradepost.GetTopBuyOffers();
		for (var i:Number = 0; i < buyOffers.length; i++)
		{
			var offerItem:MCLItemDefault = new MCLItemDefault(i);
			
			var quantityValueData:MCLItemValueData = new MCLItemValueData();
			quantityValueData.m_MovieClipName = "T" + buyOffers[i].m_TokenType1;
			quantityValueData.m_MovieClipWidth = 30;
			quantityValueData.m_Number = buyOffers[i].m_TokenType1_Amount;
			offerItem.SetValue(COLUMN_QUANTITY, quantityValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
			
			var priceValueData:MCLItemValueData = new MCLItemValueData();
			priceValueData.m_MovieClipName = "T" + buyOffers[i].m_TokenType2;
			priceValueData.m_MovieClipWidth = 30;
			priceValueData.m_Number = buyOffers[i].m_TokenType2_Amount;
			offerItem.SetValue(COLUMN_PRICE, priceValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
			
			buyList.SetItem(offerItem);
		}
		
		buyList.SetSortColumn(COLUMN_PRICE);
		buyList.SetSortDirection(Array.DESCENDING);
		buyList.Resort();
	}
	
	private function PopulateBalance():Void
	{
		var balance:ItemPrice = Tradepost.GetExchangeBalance();
		m_PremiumBalance.text = balance.m_TokenType1_Amount.toString();
		m_Balance.text = balance.m_TokenType2_Amount.toString();
	}
	
	private function UpdatePostStatus():Void
	{
		var maxPrice:Number = Utils.GetGameTweak("CurrencyExchangeMax");
		var minPrice:Number = Utils.GetGameTweak("CurrencyExchangeMin");
		var maxExchangeAurumBid:Number = Utils.GetGameTweak("MaxExchangeAurumBid");
		var buyQuantity:Number = parseInt(m_BuyPane.m_Quantity.text, 10);
		var buyPrice:Number = parseInt(m_BuyPane.m_UnitPrice.text, 10);	
		if (buyPrice > maxPrice)
		{
			m_BuyPane.m_UnitPrice.text = maxPrice;
		}
		if (buyQuantity > maxExchangeAurumBid)
		{
			m_BuyPane.m_Quantity.text = maxExchangeAurumBid;
		}
		m_BuyPane.m_PostButton.disabled = !(buyQuantity > 0 && buyPrice >= minPrice && !Tradepost.HasBuyOrder() && m_BuyPane.m_UnitPrice.text != "");
		
		var sellQuantity:Number = parseInt(m_SellPane.m_Quantity.text, 10);
		var sellPrice:Number = parseInt(m_SellPane.m_UnitPrice.text, 10);
		if (sellPrice > maxPrice)
		{
			m_SellPane.m_UnitPrice.text = maxPrice;
		}
		if (sellQuantity > maxExchangeAurumBid)
		{
			m_SellPane.m_Quantity.text = maxExchangeAurumBid;
		}
		m_SellPane.m_PostButton.disabled = !(sellQuantity > 0 && sellPrice >= minPrice && !Tradepost.HasSellOrder() && m_SellPane.m_UnitPrice.text != "");
	}
	
	private function PostBuyOrder():Void
	{
		var buyQuantity:Number = parseInt(m_BuyPane.m_Quantity.text, 10);
		var buyPrice:Number = parseInt(m_BuyPane.m_UnitPrice.text, 10);
		var totalPrice:Number = buyPrice * buyQuantity;
		var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("Tradepost", "ConfirmBuyOrder"), Text.AddThousandsSeparator(buyQuantity), Text.AddThousandsSeparator(buyPrice), Text.AddThousandsSeparator(totalPrice)));
		dialogIF.SignalSelectedAS.Connect(ConfirmPostBuyOrder, this);
		dialogIF.Go();
	}
	
	private function ConfirmPostBuyOrder(buttonId:Number):Void
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var buyQuantity:Number = parseInt(m_BuyPane.m_Quantity.text, 10);
			var buyPrice:Number = parseInt(m_BuyPane.m_UnitPrice.text, 10);
			Tradepost.PostBuyOrder(buyQuantity, buyPrice);
		}
	}
	
	private function PostSellOrder():Void
	{
		var sellQuantity:Number = parseInt(m_SellPane.m_Quantity.text, 10);
		var sellPrice:Number = parseInt(m_SellPane.m_UnitPrice.text, 10);
		var totalPrice:Number = sellPrice * sellQuantity;
		var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("Tradepost", "ConfirmSellOrder"), Text.AddThousandsSeparator(sellQuantity), Text.AddThousandsSeparator(sellPrice), Text.AddThousandsSeparator(totalPrice)));
		dialogIF.SignalSelectedAS.Connect(ConfirmPostSellOrder, this);
		dialogIF.Go();
	}
	
	private function ConfirmPostSellOrder(buttonId:Number):Void
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var sellQuantity:Number = parseInt(m_SellPane.m_Quantity.text, 10);
			var sellPrice:Number = parseInt(m_SellPane.m_UnitPrice.text, 10);
			Tradepost.PostSellOrder(sellQuantity, sellPrice);
		}
	}
	
	private function CancelBuyOrder():Void
	{
		Tradepost.CancelBuyOrder();
	}
	
	private function CancelSellOrder():Void
	{
		Tradepost.CancelSellOrder();
	}
	
	private function WithdrawExchangeBalance():Void
	{
		Tradepost.WithdrawExchangeBalance();
	}
	
	private function BuyAurum():Void
	{
		ShopInterface.RequestAurumPurchase();
	}
}