//Imports
import com.Utils.LDBFormat;
import gfx.controls.Button;
import gfx.core.UIComponent;
import gfx.controls.CheckBox
import com.Utils.Signal;
import com.Utils.Text;
import GUI.TradePost.ItemCounter;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import mx.utils.Delegate;

//Class
class GUI.TradePost.Views.SellItemPromptWindow extends UIComponent
{
    //Constants
    private static var COMMISSION_FEE:Number = com.GameInterface.Utils.GetGameTweak("TradePost_SalesCommission");
    private static var SALES_FEE:Number = com.GameInterface.Utils.GetGameTweak("TradePost_SalesFee");
	private static var PATRON_COMMISSION_FEE:Number = com.GameInterface.Utils.GetGameTweak("TradePost_PatronSalesCommission");
	private static var PATRON_SALES_FEE:Number = com.GameInterface.Utils.GetGameTweak("TradePost_PatronSalesFee");
    
    private static var SELL_ITEM_TITLE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_sellItemTitle");
    private static var MESSAGE_WHEN_SOLD:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_sellItemMessageWhenSold");
	private static var MINIMUM_LISTING_PRICE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_minimumListingPrice");
    private static var OK_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Ok");
    private static var CANCEL_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
	private static var USE_PREMIUM:String = LDBFormat.LDBGetText("GenericGUI", "UsePremiumCurrency");
    
    //Properties
    public var SignalPromptResponse:Signal;
    
    private var m_Character:Character;
    private var m_Background:MovieClip;
    private var m_Title:TextField;
    private var m_Message:TextField;
    private var m_ItemCounter:ItemCounter;
    private var m_MessageWhenSold:TextField;
	private var m_WhenSoldPremiumCash:MovieClip;
    private var m_MessageListingFee:TextField;
	private var m_ListingFeePremiumCash:MovieClip;
    private var m_CancelButton:Button;
    private var m_ConfirmButton:Button;
    
    //Constructor
    public function SellItemPromptWindow()
    {
        super();
        
        SignalPromptResponse = new Signal;
        
        m_Character = Character.GetClientCharacter();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        _visible = false;
        
        m_Title.text = SELL_ITEM_TITLE;
		if (m_Character.IsMember())
		{
        	m_Message.text = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "TradePost_sellItemMessage"), PATRON_SALES_FEE * 100, PATRON_COMMISSION_FEE * 100);
		}
		else
		{
			m_Message.text = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "TradePost_sellItemMessage"), SALES_FEE * 100, COMMISSION_FEE * 100);
		}
        m_Message.autoSize = "center";
        
        m_ItemCounter._x = m_Background._width / 2 - m_ItemCounter._width / 2;
        m_ItemCounter.icon = "T201";
        m_ItemCounter.ShowBackground( false );
        m_ItemCounter.minAmount = 0;
        m_ItemCounter.maxAmount = ItemCounter.MAX_VALUE;
        m_ItemCounter.SignalValueChanged.Connect(SlotCashAmountChanged, this);
        
        var keyListener:Object = new Object();
        keyListener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(keyListener);
        
        m_MessageWhenSold.text = MESSAGE_WHEN_SOLD
		
		m_WhenSoldPremiumCash.m_Label.autoSize = "left";
        UpdateCash(m_WhenSoldPremiumCash, 0);
		
		m_ListingFeePremiumCash.m_Label.autoSize = "left";
        UpdateCash(m_ListingFeePremiumCash, 0);
        
        m_CancelButton.label = CANCEL_LABEL;
        m_CancelButton.disableFocus = true;
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_ConfirmButton.label = OK_LABEL;
        m_ConfirmButton.disableFocus = true;
        m_ConfirmButton.disabled = true;
        m_ConfirmButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        _x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;
    }
    
    //Show Prompt
    public function ShowPrompt():Void
    {
        if (_visible)
        {
            return;
        }
        
        _visible = true;
        swapDepths(_parent.getNextHighestDepth());
        
        m_ItemCounter.amount = 0;
        m_ItemCounter.TakeFocus();
    }
    
    //Text Change Event Handler
    private function SlotCashAmountChanged(newValue:Number):Void
    {
        var commissionFee:Number = (newValue == 0) ? 0 : Math.round(newValue * (1.0 - COMMISSION_FEE));
        var salesFee:Number = (newValue == 0) ? 0 : Math.max(1, Math.floor(newValue * SALES_FEE));
		var percentFee:Number = SALES_FEE * 100;
		
		if (m_Character.IsMember())
		{
			commissionFee = (newValue == 0) ? 0 : Math.round(newValue * (1.0 - PATRON_COMMISSION_FEE));
			salesFee = (newValue == 0) ? 0 : Math.max(1, Math.floor(newValue * PATRON_SALES_FEE));
			percentFee = PATRON_SALES_FEE * 100;
		}

		UpdateCash(m_WhenSoldPremiumCash, Math.min(newValue, commissionFee));
        UpdateCash(m_ListingFeePremiumCash, salesFee);
		
		var listingFee:String = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "TradePost_sellItemMessageListingFee"), percentFee);
        
        if (newValue < 20 || isNaN(newValue))
        {
            m_ConfirmButton.disabled = true;
			m_MessageListingFee.htmlText = MINIMUM_LISTING_PRICE;
			m_ListingFeePremiumCash._visible = false;
			m_WhenSoldPremiumCash._visible = false;
        }
        else if (salesFee > m_Character.GetTokens(_global.Enums.Token.e_Gold_Bullion_Token))
        {
			m_MessageListingFee.htmlText = listingFee;
			m_ListingFeePremiumCash._visible = true;
			m_WhenSoldPremiumCash._visible = true;
            m_ListingFeePremiumCash.m_Label.textColor = 0xFF0000;
            m_ConfirmButton.disabled = true;
        }
        else
        {
			m_MessageListingFee.htmlText = listingFee;
			m_ListingFeePremiumCash._visible = true;
			m_WhenSoldPremiumCash._visible = true;
            m_ListingFeePremiumCash.m_Label.textColor = 0xCCCCCC;
            m_ConfirmButton.disabled = false;
        }
    }
    
    //Update Cash
    private function UpdateCash(target:MovieClip, value:Number):Void
    {
        target.m_Label.text = (isNaN(value) || value == 0) ? 0 : Text.AddThousandsSeparator(value);
        target._x = m_Background._width / 2 - target._width / 2;
    }

    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        if (Selection.getFocus() == m_ItemCounter.m_TextInput.textField)
        {
            switch (Key.getCode())
            {
                case Key.ENTER:     if (m_ItemCounter.m_TextInput.textField.text == "0")
                                    {
                                        Selection.setSelection(0, 1);
                                    }
                                    else
                                    {
                                        ResponseButtonEventHandler({target: m_ConfirmButton});                
                                    }
                                    
                                    break;
                                    
                case Key.ESCAPE:    ResponseButtonEventHandler({target: m_CancelButton});
            }
        }
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        if (event.target == m_ConfirmButton)
        {                          
            SignalPromptResponse.Emit(m_ItemCounter.amount);
        }
        
        Selection.setFocus(null);
        _visible = false;
    }
}