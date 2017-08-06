//Imports
import com.Components.WindowComponentContent;
import com.GameInterface.ShopInterface;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.core.UIComponent
import gfx.controls.Button;
import gfx.utils.Delegate;

//Class
class GUI.Shop.ConfirmContent extends WindowComponentContent
{
	//Elements
	private var m_PaymentInfo:MovieClip;
	private var m_TextBlock:TextField;
	private var m_ConfirmButton:Button;
	private var m_CancelButton:Button;
	
    //Constants
    
    //Properties
	private var SignalClose:Signal;
	public var SignalContentInitialized:Signal;
	private var m_Confirmed:Boolean;
        
    //Constructor
    public function ConfirmContent()
    {
        super();
		m_TextBlock._visible = false;
		m_Confirmed = false;
		m_PaymentInfo.m_PayPalLogo._visible = false;
		SignalContentInitialized = new Signal();
		SignalClose = new Signal();
    }
    
    //Config UI
    private function configUI():Void
    {
		m_ConfirmButton.addEventListener("click", this, "ConfirmButtonClicked");
		m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "Confirm");
		m_CancelButton.addEventListener("click", this, "CancelButtonClicked");
		m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
		m_PaymentInfo.m_ChangePayment.onRelease = Delegate.create(this, ChangePaymentInfo);
		m_PaymentInfo.m_LegalInfo.onRelease = Delegate.create(this, ShowLegalInfo);
		
		m_PaymentInfo.m_DetailHeader.text = LDBFormat.LDBGetText("MiscGUI", "PurchaseConfirm_DetailHeader");
		m_PaymentInfo.m_PaymentHeader.text = LDBFormat.LDBGetText("MiscGUI", "PurchaseConfirm_PaymentHeader");
		m_PaymentInfo.m_Recurring.text = LDBFormat.LDBGetText("MiscGUI", "PurchaseConfirm_Recurring");
		m_PaymentInfo.m_ChangePayment.m_Text.text = LDBFormat.LDBGetText("MiscGUI", "PurchaseConfirm_ChangePayment");
		m_PaymentInfo.m_LegalInfo.m_Text.htmlText = LDBFormat.LDBGetText("MiscGUI", "PurchaseConfirm_LegalInfo");
		m_TextBlock.text = LDBFormat.LDBGetText("MiscGUI", "PurchaseConfirm_Processing");
		SignalContentInitialized.Emit();
    }
	
	public function SetPaymentInfo(itemName:String, itemPrice:String, recurring:Boolean, paymentType:String, cardNumber:String):Void
	{
		m_TextBlock._visible = false;
		m_PaymentInfo._visible = true;
		m_PaymentInfo.m_ItemName.htmlText = itemName;
		m_PaymentInfo.m_ItemPrice.text = itemPrice;
		if (paymentType.toLowerCase() == "paypal")
		{
			m_PaymentInfo.m_PayPalLogo._visible = true;
		}
		else
		{
			m_PaymentInfo.m_PayPalLogo._visible = false;
			m_PaymentInfo.m_CardType.text = paymentType;
		}
		m_PaymentInfo.m_CardNumber.text = cardNumber;
		m_PaymentInfo.m_Recurring._visible = recurring;
	}
	
	private function ChangePaymentInfo()
	{
		ShopInterface.ChangePaymentInfo();
		Close();
	}
	
	private function ShowLegalInfo()
	{
		ShopInterface.ShowLegalInfo();
	}
	
	private function ConfirmButtonClicked():Void
	{
		ShopInterface.ConfirmRealMoneyPurchase();
		m_Confirmed = true;
		
		//Disable these buttons to avoid confusion
		m_ConfirmButton.disabled = true;
		m_CancelButton.disabled = true;
		
		m_PaymentInfo._visible = false;
		m_TextBlock._visible = true;
	}
	
	private function CancelButtonClicked():Void
	{
		Close();
	}
	
	public function Close()
	{
		if (!m_Confirmed)
		{
			ShopInterface.CancelRealMoneyPurchase();
		}
		SignalClose.Emit();
	}
}