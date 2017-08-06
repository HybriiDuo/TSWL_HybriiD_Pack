import gfx.core.UIComponent;
import mx.utils.Delegate;
import com.Components.ItemComponent;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.*;
import com.GameInterface.ShopInterface;
import com.GameInterface.DialogIF;
import com.GameInterface.Game.Character;
import gfx.controls.Button;
import com.Utils.LDBFormat;
import com.Utils.Text;
import com.Utils.Signal;

class GUI.Shop.InstantBuyEntry extends UIComponent
{
	//Properties
	private var m_Item:ItemComponent;
	private var m_Name:TextField;
	private var m_Price:MovieClip;
	private var m_Button:Button;
	
	//variables
	private var m_InventoryItem:InventoryItem;
	private var m_Initialized:Boolean;
	private var m_Tooltip:TooltipInterface;
	private var SignalClose:Signal;
	private var m_OverridePrice:Number;
	private var m_OverrideCurrency:String;
	
	//Statics
	private static var NAME_START_Y:Number = 8.5;
	private static var ITEM_NAME_HEIGHT:Number = 25;
	
	public function InstantBuyEntry() 
	{
		super();
		SignalClose = new Signal();
		m_Initialized = false;
	}
	
	private function configUI()
	{
		super.configUI();
		m_Button.disableFocus = true;
		if (m_InventoryItem != undefined)
		{
			SetDisplay();
		}
		m_Initialized = true;
	}
	
	private function onUnload()
	{
		CloseTooltip();
	}
	
	public function SetData(inventoryItem:InventoryItem)
	{
		m_InventoryItem = inventoryItem;
		m_Price.m_Text.autoSize = 'left';
		if (m_Initialized)
		{
			SetDisplay();
		}
	}
	
	public function OverridePrice(overridePrice:Number)
	{
		m_OverridePrice = overridePrice;
	}
	
	public function OverrideCurrency(overrideCurrency:String)
	{
		m_OverrideCurrency = overrideCurrency;
	}
	
	private function SetDisplay()
	{
		m_Item.SetData(m_InventoryItem);
		
		m_Name.htmlText = m_InventoryItem.m_Name;
		//Shift the text field depending on how many lines of text there are
		if (m_Name.textHeight < ITEM_NAME_HEIGHT)
		{
			m_Name._y = NAME_START_Y + ITEM_NAME_HEIGHT/2;
		}
		else
		{
			m_Name._y = NAME_START_Y;
		}
		
		if (m_OverridePrice == undefined)
		{
			m_Price.m_Text.text = Text.AddThousandsSeparator(m_InventoryItem.m_TokenCurrencyPrice1);
		}
		else
		{
			m_Price.m_Text.text = m_OverridePrice;
		}
		if (m_OverrideCurrency == undefined)
		{
			m_Price.attachMovie("T"+m_InventoryItem.m_TokenCurrencyType1, "m_Token", m_Price.getNextHighestDepth());
		}
		else
		{
			m_Price.m_Text.text += " " + m_OverrideCurrency;
			m_Price.m_Text._x = 0;
		}
		m_Button.label = LDBFormat.LDBGetText("GenericGUI", "InstantBuy_Buy");
		
		m_Item.onRollOver = Delegate.create(this, OpenTooltip);
		m_Item.onRollOut = m_Item.onDragOut = Delegate.create(this, CloseTooltip);
		m_Button.addEventListener("click", this, "PurchaseItem");		
		
		m_Price._x = m_Button._x + m_Button._width/2 - (m_Price.m_Text._x + m_Price.m_Text.textWidth)/2;
	}
	
	private function OpenTooltip()
	{
		if (m_Tooltip == undefined)
		{
			var tooltipData:TooltipData = TooltipDataProvider.GetACGItemTooltip(m_InventoryItem.m_ACGItem, 1);
			m_Tooltip = TooltipManager.GetInstance().ShowTooltip(m_Item, TooltipInterface.e_OrientationHorizontal, 0, tooltipData);
		}
	}
	
	private function CloseTooltip()
	{
		if (m_Tooltip != undefined && !m_Tooltip.IsFloating())
		{
			m_Tooltip.Close();
			m_Tooltip = undefined;
		}
	}
	
	private function PurchaseItem()
	{
		//This only happens if this is a real money transaction, which has its own confirmation window
		if (m_OverrideCurrency != undefined)
		{
			ShopInterface.BuyItemTemplate(m_InventoryItem.m_ACGItem.m_TemplateID0, m_InventoryItem.m_TokenCurrencyType1, m_InventoryItem.m_TokenCurrencyPrice1);
			CloseTooltip();
			SignalClose.Emit();
		}
		else
		{
			var tokenType:Number = m_InventoryItem.m_TokenCurrencyType1;
			var price:Number = m_InventoryItem.m_TokenCurrencyPrice1;
			var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+tokenType);
			if (tokenType == _global.Enums.Token.e_Gold_Bullion_Token)
			{
				tokenName = LDBFormat.LDBGetText("Tokens", "Token201_Plural");
			}
			var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "DressingRoom_PurchaseConfirmation"), m_InventoryItem.m_Name, Text.AddThousandsSeparator(price), tokenName));
			dialogIF.SignalSelectedAS.Connect(SlotConfirmPurchase, this);
			dialogIF.Go();
		}
	}
	
	private function SlotConfirmPurchase(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var tokenType:Number = m_InventoryItem.m_TokenCurrencyType1;
			var price:Number = m_InventoryItem.m_TokenCurrencyPrice1;
			if (Character.GetClientCharacter().GetTokens(tokenType) >= price)
			{
				ShopInterface.BuyItemTemplate(m_InventoryItem.m_ACGItem.m_TemplateID0, m_InventoryItem.m_TokenCurrencyType1, m_InventoryItem.m_TokenCurrencyPrice1);
				CloseTooltip();
				SignalClose.Emit();
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
}