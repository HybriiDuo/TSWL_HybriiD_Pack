//Imports
import com.GameInterface.Tradepost;
import com.Utils.Signal;
import com.Utils.ID32;
import com.GameInterface.Utils;
import com.GameInterface.Game.Character;

//Class
class GUI.TradePost.TradePostViewsContainer extends MovieClip
{
    //Constants
    public static var BUY_VIEW:String = "BuyView";
    public static var POSTAL_SERVICE_VIEW:String = "PostalServiceView";
	public static var EXCHANGE_VIEW:String = "ExchangeView";
    
    //Properties
    public var SignalViewChanged:Signal;
    
    private var m_BuyViewView:MovieClip;
    private var m_PostalServiceView:MovieClip;
	private var m_ExchangeView:MovieClip;
    private var m_ViewsArray:Array;
    private var m_View:String;
    
    //Constructor
    public function TradePostViewsContainer()
    {
        super();
        
        Init();
        
        SignalViewChanged = new Signal();
    }
    
    //Initialize
    private function Init():Void
    {
        var clientCharacter:Character = Character.GetClientCharacter();
        var isGM:Boolean = false;
        if (clientCharacter != undefined)
        {
            isGM = clientCharacter.GetStat(_global.Enums.Stat.e_GmLevel, 2) != 0;
        }
        Tradepost.UpdateMail(); 

        m_BuyViewView = attachMovie(BUY_VIEW, "m_" + BUY_VIEW, getNextHighestDepth());
        m_PostalServiceView = attachMovie(POSTAL_SERVICE_VIEW, "m_" + POSTAL_SERVICE_VIEW, getNextHighestDepth());
        if (Utils.GetGameTweak("Exchange_Disabled") == 0 || isGM)
		{
            m_ExchangeView = attachMovie(EXCHANGE_VIEW, "m_" + EXCHANGE_VIEW, getNextHighestDepth());
        }
        
        m_ViewsArray = new Array();
        m_ViewsArray.push({name: BUY_VIEW, view: m_BuyViewView});
        m_ViewsArray.push({name: POSTAL_SERVICE_VIEW, view: m_PostalServiceView});
        if (Utils.GetGameTweak("Exchange_Disabled") == 0 || isGM)
		{
            m_ViewsArray.push({name: EXCHANGE_VIEW, view: m_ExchangeView});
        }
        
        for (var i:Number = 0; i < m_ViewsArray.length; i++)
        {
            m_ViewsArray[i].view._visible = false;
        } 
		
		com.Utils.GlobalSignal.SignalSendItemToTradepost.Connect(SlotReceiveItem, this);
    }
	
	public function SlotReceiveItem(srcInventory:ID32, srcSlot:Number)
	{
		if (m_View == BUY_VIEW)
		{
			m_BuyViewView.PromptSale(srcInventory, srcSlot)
		}
	}
    
    //Set View
    public function set view(value:String):Void
    {
        m_View = value;
        
        for (var i:Number = 0; i < m_ViewsArray.length; i++)
        {
            if (m_ViewsArray[i].name == value)
            {
                m_ViewsArray[i].view._visible = true;
                
                SignalViewChanged.Emit();
            }
            else
            {
                m_ViewsArray[i].view._visible = false;
            }
        }
    }
    
    //Get View
    public function get view():String
    {
        return m_View;
    }
}