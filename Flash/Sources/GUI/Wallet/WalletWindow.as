import gfx.core.UIComponent
import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.GameInterface.Game.Character;
import com.GameInterface.Utils;
import com.Components.ListHeader;
import com.Components.WindowComponentContent;
import gfx.controls.Button;
import mx.utils.Delegate;
import com.Utils.Text;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;

class GUI.Wallet.WalletWindow extends WindowComponentContent
{
    private var m_Tokens:Array;
    private var m_Character:Character;
    
    private var m_MultiColumnList:MultiColumnListView
    
    private var m_Width:Number
    private var m_Height:Number
    
    private var m_ItemWidth:Number = 275;
    private var m_AmountWidth:Number = 130;
	//private var m_WeeklyCapWidth:Number = 130;
    
    private var m_ItemColumn:Number = 0;
    private var m_AmountColumn:Number = 1;
	//private var m_WeeklyCapColumn:Number = 3;
	
	private var m_IsMember:Boolean = false;

    public var SignalClose:Signal;

    public function WalletWindow()
    {
        SignalClose = new Signal();
        m_Character = Character.GetClientCharacter();
		m_Character.SignalMemberStatusUpdated.Connect(UpdateMembershipStatus, this);
		UpdateMembershipStatus(m_Character.IsMember());
		Character.SignalReloadTokens.Connect(SlotReloadTokens, this);
                    
        var tokenId:Number;
        m_Tokens = [];      
		
		tokenId = _global.Enums.Token.e_Premium_Token;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 /*
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 */
						 id:tokenId}); 
		tokenId = _global.Enums.Token.e_Gold_Bullion_Token;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId),
						 /*
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 */
						 id:tokenId});
		tokenId = _global.Enums.Token.e_Cash;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 /*
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 */
						 id:tokenId}); 
		tokenId = _global.Enums.Token.e_CashShop_Token;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 /*
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 */
						 id:tokenId}); 
		
		//THESE OLD TOKENS ARE NO LONGER USED
		/*
		tokenId = _global.Enums.Token.e_Unrefined_Gold_Bullion_Token;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 id:tokenId });
		tokenId = _global.Enums.Token.e_Heroic_Token;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 id:tokenId }); 
		tokenId = _global.Enums.Token.e_Coupon_Barbershop;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 id:tokenId });    
		tokenId = _global.Enums.Token.e_Coupon_PlasticSurgery;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 id:tokenId }); 
        tokenId = _global.Enums.Token.e_Major_Anima_Fragment;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
        tokenId = _global.Enums.Token.e_Minor_Anima_Fragment;
        m_Tokens.push({ name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
        tokenId = _global.Enums.Token.e_Solomon_Island_Token;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
        tokenId = _global.Enums.Token.e_Egypt_Token;
        m_Tokens.push({ name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
        tokenId = _global.Enums.Token.e_Transylvania_Token;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
		tokenId = _global.Enums.Token.e_Tokyo_Token;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
        tokenId = _global.Enums.Token.e_DLC_Token;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
        tokenId = _global.Enums.Token.e_Prowess_Point;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
		tokenId = _global.Enums.Token.e_Scenario_Token;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), cap:9999, weekValue:0, weekCap:100, id:tokenId });
		*/
		// These are temporary tokens for events.
		if (Utils.GetGameTweak("Seasonal_Mayan_2013") != 0)
		{
			tokenId = _global.Enums.Token.e_Apocalypse_Token;
			m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
							 value:m_Character.GetTokens(tokenId), 
							 /*
							 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
							 weekValue:m_Character.GetWeeklyTokens(tokenId), 
							 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
							 */
							 id:tokenId}); 
		}
		/*
		if (Utils.GetGameTweak("Seasonal_AgarthaFilth") != 0)
		{
			tokenId = _global.Enums.Token.e_Agartha_Token1;
			m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
							 value:m_Character.GetTokens(tokenId), 
							 id:tokenId});   
			tokenId = _global.Enums.Token.e_Agartha_Token2;
			m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
							 value:m_Character.GetTokens(tokenId), 
							 id:tokenId});   
		}
		*/
		if (Utils.GetGameTweak("TSW_GoldGolemEvent_2013") != 0)
		{
			tokenId = _global.Enums.Token.e_GoldenWeek_Token;
			m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
							 value:m_Character.GetTokens(tokenId), 
							 /*
							 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
							 weekValue:m_Character.GetWeeklyTokens(tokenId), 
							 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
							 */
							 id:tokenId});   
		}
		
		//These are keys used for various chests
		tokenId = _global.Enums.Token.e_Lockbox_Key;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 /*
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 */
						 id:tokenId}); 
						 
		tokenId = _global.Enums.Token.e_Dungeon_Key;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 /*
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 */
						 id:tokenId}); 
						 
		tokenId = _global.Enums.Token.e_Scenario_Key;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 /*
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 */
						 id:tokenId}); 
						 
		tokenId = _global.Enums.Token.e_Lair_Key;
		m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), 
					  	 value:m_Character.GetTokens(tokenId), 
						 /*
						 cap:Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId)), 
						 weekValue:m_Character.GetWeeklyTokens(tokenId), 
						 weekCap:Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId)), 
						 */
						 id:tokenId}); 

        m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
		//m_Character.SignalWeeklyTokenAmountChanged.Connect(SlotWeeklyTokenAmountChanged, this); 
    } 
	
	public function UpdateMembershipStatus(member:Boolean)
	{
		m_IsMember = member;
		//TODO: Any member token benefits
	}
    
    public function SetSize(width:Number, height:Number)
    {
        m_Width = width;
        m_Height = height;
    }
    
    private function SlotTokenAmountChanged(tokenId:Number, newAmount:Number, oldAmount:Number)
    {
        for (var i:Number = 0; i < m_Tokens.length; i++)
        {
            if (m_Tokens[i].id == tokenId)
            {
                m_Tokens[i].value = newAmount;
                UpdateToken(m_Tokens[i]);
                return;
            }
        }      
    }
	
	/*
	private function SlotWeeklyTokenAmountChanged(tokenId:Number, newAmount:Number, oldAmount:Number)
    {
        for (var i:Number = 0; i < m_Tokens.length; i++)
        {
            if (m_Tokens[i].id == tokenId)
            {
                m_Tokens[i].weekValue = newAmount;
                UpdateToken(m_Tokens[i]);
                return;
            }
        }      
    }
	*/
	
	private function SlotReloadTokens()
	{
		for (var i:Number = 0; i < m_Tokens.length; i++)
		{
			var tokenId:Number = m_Tokens[i].id;
			m_Tokens[i].value = m_Character.GetTokens(tokenId);
			/*
			m_Tokens[i].cap = Utils.GetGameTweak(m_Character.GetTokenCapTweakName(tokenId));
			m_Tokens[i].weekValue = m_Character.GetWeeklyTokens(tokenId);
			m_Tokens[i].weekCap = Utils.GetGameTweak(m_Character.GetWeeklyTokenCapTweakName(tokenId));
			*/
			UpdateToken(m_Tokens[i]);
		}
	}
    
    public function configUI()
    {        
        m_MultiColumnList.SignalSizeChanged.Connect(Layout, this)
        m_MultiColumnList.SetItemRenderer("TokenItemRenderer");
        m_MultiColumnList.SetHeaderSpacing(3);
        m_MultiColumnList.SetShowBottomLine(false);
        
        m_MultiColumnList.AddColumn(m_ItemColumn, LDBFormat.LDBGetText("GenericGUI", "Name"), m_ItemWidth, 0);
        m_MultiColumnList.AddColumn(m_AmountColumn,  LDBFormat.LDBGetText("GenericGUI", "Amount"), m_AmountWidth, 0);
		//m_MultiColumnList.AddColumn(m_WeeklyCapColumn, LDBFormat.LDBGetText("GenericGUI", "WeeklyCap"), m_WeeklyCapWidth, 0);
        m_MultiColumnList.SetRowCount(m_Tokens.length);
        
        CreateTokens();
        
        Layout();
        
    }
    
    private function CreateTokens()
    {
        var ypos:Number = 0;
        for (var i:Number = 0; i < m_Tokens.length; i++ )
        {
            var tokenObj:Object = m_Tokens[i];
            UpdateToken(tokenObj);
        }
    }
    
    private function UpdateToken(tokenObj:Object)
    {
        var tokenItem:MCLItemDefault = new MCLItemDefault(tokenObj.id);
        var textAndIconValue:MCLItemValueData = new MCLItemValueData();
        textAndIconValue.m_Text = tokenObj.name;
        textAndIconValue.m_MovieClipName = "T" + tokenObj.id;
        textAndIconValue.m_MovieClipWidth = 35;
        tokenItem.SetValue(m_ItemColumn, textAndIconValue, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
		
        var amountValue:MCLItemValueData = new MCLItemValueData();
        amountValue.m_Text = Text.AddThousandsSeparator(tokenObj.value);
		amountValue.m_Number = tokenObj.value;
        amountValue.m_TextAlignment = "right";
        tokenItem.SetValue(m_AmountColumn, amountValue, MCLItemDefault.LIST_ITEMTYPE_STRING_SORT_BY_NUMBER);
		
		/*
		var weeklyCap:MCLItemValueData = new MCLItemValueData();
		weeklyCap.m_Text = tokenObj.weekValue;
		if (tokenObj.weekCap > 0)
		{
			if (m_IsMember)
			{
				weeklyCap.m_TextColor = 0xD3A308;
			}
			weeklyCap.m_Text += " / " + tokenObj.weekCap;
		}
		weeklyCap.m_Number = tokenObj.weekValue;
		weeklyCap.m_TextAlignment = "right";
		tokenItem.SetValue(m_WeeklyCapColumn, weeklyCap, MCLItemDefault.LIST_ITEMTYPE_STRING_SORT_BY_NUMBER);
		*/

        m_MultiColumnList.SetItem(tokenItem);
    }

    private function Layout()
    {        
        SignalSizeChanged.Emit();
    }
}
