import com.Components.WindowComponentContent;
import com.GameInterface.Game.Character;
import com.GameInterface.ShopInterface;
import com.GameInterface.DistributedValue;
import gfx.controls.Button;
import com.Utils.LDBFormat;

class GUI.Shop.MembershipPurchaseContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_PriceText:TextField;
	private var m_Name:TextField;
	private var m_ConfirmButton:Button;
	private var m_Art:MovieClip;
	
	//Variables
	private var m_Character:Character;

	//Statics
	
	public function MembershipPurchaseContent()
	{
		super();
		var languageCode:String = LDBFormat.GetCurrentLanguageCode();
		switch(languageCode)
		{
			case "en":	m_Art.m_EN._visible = true;
						m_Art.m_FR._visible = false;
						m_Art.m_DE._visible = false;
						break;
			case "fr":  m_Art.m_EN._visible = false;
						m_Art.m_FR._visible = true;
						m_Art.m_DE._visible = false;
						break;
			case "de":  m_Art.m_EN._visible = false;
						m_Art.m_FR._visible = false;
						m_Art.m_DE._visible = true;
						break;
		}
	}
	
	private function configUI()
	{
		ShopInterface.SignalMembershipPriceUpdated.Connect(SlotMembershipPriceUpdated, this)
		ShopInterface.RequestMembershipPrice();		
		m_Character = Character.GetClientCharacter();
		
		m_ConfirmButton.disableFocus = true;
		m_Character.SignalMemberStatusUpdated.Connect(this, SlotMemberStatusUpdated);
		SlotMemberStatusUpdated(m_Character.IsMember());
		m_ConfirmButton.addEventListener("click", this, "ConfirmClickHandler");
		SetLabels();
	}
	
	//Set Labels
    private function SetLabels():Void
    {
		m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "MembershipPurchaseButton");
		m_Name.text = LDBFormat.LDBGetText("GenericGUI", "Membership30Days");
    }
	
	private function SlotMemberStatusUpdated(member:Boolean)
	{
		m_ConfirmButton.disabled = member;
	}
	
	private function SlotMembershipPriceUpdated(price:String)
	{
		m_PriceText.text = price;
	}
	
	private function ConfirmClickHandler():Void
	{
		ShopInterface.PurchaseMembership();
		DistributedValue.SetDValue("membershipPurchase_window", false);
	}
}