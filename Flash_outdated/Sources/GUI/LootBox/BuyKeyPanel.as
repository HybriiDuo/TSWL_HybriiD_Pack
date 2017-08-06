import gfx.core.UIComponent;
import gfx.controls.Button;
import com.Utils.LDBFormat;
import com.Utils.Text;
import com.Components.ItemComponent;
import com.GameInterface.DialogIF;
import com.GameInterface.ShopInterface;
import com.GameInterface.Game.Character;

class GUI.LootBox.BuyKeyPanel extends UIComponent
{
	//Components created in .fla
	private var m_Item_0:ItemComponent;
	private var m_Item_1:ItemComponent;
	private var m_Item_2:ItemComponent;
	private var m_Item_3:ItemComponent;
	private var m_Price_0:MovieClip;
	private var m_Price_1:MovieClip;
	private var m_Price_2:MovieClip;
	private var m_Price_3:MovieClip;
	private var m_BuyButton_0:Button;
	private var m_BuyButton_1:Button;
	private var m_BuyButton_2:Button;
	private var m_BuyButton_3:Button;

	//Variables
	private var m_Data:Array;
	private var m_Initialized:Boolean;
	
	//Statics

	
	public function BuyKeyPanel() 
	{
		super();
		m_Initialized = false;
	}
	
	public function configUI()
	{
		if (m_Data != undefined)
		{
			PopulateItems();
		}
		m_BuyButton_0.label = m_BuyButton_1.label = m_BuyButton_2.label = m_BuyButton_3.label = LDBFormat.LDBGetText("GenericGUI", "InstantBuy_Buy");
		m_BuyButton_0.addEventListener("click", this, "PurchaseItem0");	
		m_BuyButton_1.addEventListener("click", this, "PurchaseItem1");
		m_BuyButton_2.addEventListener("click", this, "PurchaseItem2");
		m_BuyButton_3.addEventListener("click", this, "PurchaseItem3");
		m_Initialized = true;
	}
	
	public function SetData(receivedItems:Array):Void
	{
		m_Data = receivedItems;
		if (m_Initialized)
		{
			PopulateItems()
		}
	}
	
	private function PopulateItems()
	{
		for (var i:Number = 0; i < m_Data.length; i++)
		{
			if (this["m_Item_"+i] != undefined)
			{
				this["m_Item_"+i].SetData(m_Data[i]);
				this["m_Price_"+i].m_Text.text = Text.AddThousandsSeparator(m_Data[i].m_TokenCurrencyPrice1);
				this["m_Price_"+i]._x = this["m_BuyButton_"+i]._x + this["m_BuyButton_"+i]._width/2 - (this["m_Price_"+i].m_Text._x + this["m_Price_"+i].m_Text.textWidth)/2;	
			}
		}
	}
	
	private function PurchaseItem0()
	{
		var tokenType:Number = m_Data[0].m_TokenCurrencyType1;
		var price:Number = m_Data[0].m_TokenCurrencyPrice1;
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+tokenType);
		if (tokenType == _global.Enums.Token.e_Gold_Bullion_Token)
		{
			tokenName = LDBFormat.LDBGetText("Tokens", "Token201_Plural");
		}
		var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "DressingRoom_PurchaseConfirmation"), m_Data[0].m_Name, Text.AddThousandsSeparator(price), tokenName));
		dialogIF.SignalSelectedAS.Connect(SlotConfirmPurchase0, this);
		dialogIF.Go();
	}
	
	private function SlotConfirmPurchase0(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var tokenType:Number = m_Data[0].m_TokenCurrencyType1;
			var price:Number = m_Data[0].m_TokenCurrencyPrice1;
			if (Character.GetClientCharacter().GetTokens(tokenType) >= price)
			{
				ShopInterface.BuyItemTemplate(m_Data[0].m_ACGItem.m_TemplateID0, tokenType, price);
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
	
	private function PurchaseItem1()
	{
		var tokenType:Number = m_Data[1].m_TokenCurrencyType1;
		var price:Number = m_Data[1].m_TokenCurrencyPrice1;
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+tokenType);
		if (tokenType == _global.Enums.Token.e_Gold_Bullion_Token)
		{
			tokenName = LDBFormat.LDBGetText("Tokens", "Token201_Plural");
		}
		var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "DressingRoom_PurchaseConfirmation"), m_Data[1].m_Name, Text.AddThousandsSeparator(price), tokenName));
		dialogIF.SignalSelectedAS.Connect(SlotConfirmPurchase1, this);
		dialogIF.Go();
	}
	
	private function SlotConfirmPurchase1(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var tokenType:Number = m_Data[1].m_TokenCurrencyType1;
			var price:Number = m_Data[1].m_TokenCurrencyPrice1;
			if (Character.GetClientCharacter().GetTokens(tokenType) >= price)
			{
				ShopInterface.BuyItemTemplate(m_Data[1].m_ACGItem.m_TemplateID0, tokenType, price);
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
	
	private function PurchaseItem2()
	{
		var tokenType:Number = m_Data[2].m_TokenCurrencyType1;
		var price:Number = m_Data[2].m_TokenCurrencyPrice1;
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+tokenType);
		if (tokenType == _global.Enums.Token.e_Gold_Bullion_Token)
		{
			tokenName = LDBFormat.LDBGetText("Tokens", "Token201_Plural");
		}
		var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "DressingRoom_PurchaseConfirmation"), m_Data[2].m_Name, Text.AddThousandsSeparator(price), tokenName));
		dialogIF.SignalSelectedAS.Connect(SlotConfirmPurchase2, this);
		dialogIF.Go();
	}
	
	private function SlotConfirmPurchase2(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var tokenType:Number = m_Data[2].m_TokenCurrencyType1;
			var price:Number = m_Data[2].m_TokenCurrencyPrice1;
			if (Character.GetClientCharacter().GetTokens(tokenType) >= price)
			{
				ShopInterface.BuyItemTemplate(m_Data[2].m_ACGItem.m_TemplateID0, tokenType, price);
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
	
	private function PurchaseItem3()
	{
		var tokenType:Number = m_Data[3].m_TokenCurrencyType1;
		var price:Number = m_Data[3].m_TokenCurrencyPrice1;
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+tokenType);
		if (tokenType == _global.Enums.Token.e_Gold_Bullion_Token)
		{
			tokenName = LDBFormat.LDBGetText("Tokens", "Token201_Plural");
		}
		var dialogIF = new DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "DressingRoom_PurchaseConfirmation"), m_Data[3].m_Name, Text.AddThousandsSeparator(price), tokenName));
		dialogIF.SignalSelectedAS.Connect(SlotConfirmPurchase3, this);
		dialogIF.Go();
	}
	
	private function SlotConfirmPurchase3(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var tokenType:Number = m_Data[3].m_TokenCurrencyType1;
			var price:Number = m_Data[3].m_TokenCurrencyPrice1;
			if (Character.GetClientCharacter().GetTokens(tokenType) >= price)
			{
				ShopInterface.BuyItemTemplate(m_Data[3].m_ACGItem.m_TemplateID0, tokenType, price);
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