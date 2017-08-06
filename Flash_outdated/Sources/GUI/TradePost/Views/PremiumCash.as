﻿//Imports
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.LDBFormat;
import com.Utils.Text;

//Class
class GUI.TradePost.Views.PremiumCash extends MovieClip
{
    //Properties
    private var m_Label:TextField;
    private var m_Character:Character;
    
    //Constructor
    public function PremiumCash()
    {
        super();
        
        m_Label.autoSize = "left";
        
        Init();
    }
    
    //Initialize
    private function Init():Void
    {
        m_Character = Character.GetClientCharacter();
    
        if (m_Character != undefined)
        {
            m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
            var cash:Number = m_Character.GetTokens(_global.Enums.Token.e_Premium_Token);
            m_Label.text = Text.AddThousandsSeparator(cash);
        }
    }
    
    //Slot Token Amount Changed
    function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number):Void
    {
        if (id == _global.Enums.Token.e_Premium_Token)
        {
            m_Label.text = Text.AddThousandsSeparator(newValue); //com.Utils.Format.Printf("%.2f", newValue / 100);
        }
    }
}