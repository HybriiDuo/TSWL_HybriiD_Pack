//Imports
import com.GameInterface.Tradepost;
import com.GameInterface.Inventory;
import com.GameInterface.Game.Character;
import com.Utils.Signal;
import com.Utils.ID32;

//Class
class GUI.Bank.BankViewsContainer extends MovieClip
{
    //Constants
    public static var STORE_AND_SELL_VIEW:String = "StoreAndSellView";
    public static var GUILD_BANK_VIEW:String = "GuildBankView";
    
    //Properties
    public var SignalViewChanged:Signal;
    
    private var m_StoreAndSellView:MovieClip;
    private var m_GuildBankView:MovieClip;
    private var m_ViewsArray:Array;
    private var m_View:String;
    
    //Constructor
    public function BankViewsContainer()
    {
        super();
        
        Init();
        
        SignalViewChanged = new Signal();
    }
    
    //Initialize
    private function Init():Void
    {
        m_StoreAndSellView = attachMovie(STORE_AND_SELL_VIEW, "m_" + STORE_AND_SELL_VIEW, getNextHighestDepth());
        m_GuildBankView = attachMovie(GUILD_BANK_VIEW, "m_" + GUILD_BANK_VIEW, getNextHighestDepth())
        
        m_ViewsArray = new Array();
        m_ViewsArray.push({name: STORE_AND_SELL_VIEW, view: m_StoreAndSellView});
        m_ViewsArray.push( { name: GUILD_BANK_VIEW, view: m_GuildBankView } );
        
        for (var i:Number = 0; i < m_ViewsArray.length; i++)
        {
            m_ViewsArray[i].view._visible = false;
        } 
		
		com.Utils.GlobalSignal.SignalSendItemToBank.Connect(SlotReceiveItem, this);
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
    
    public function RemoveView(view:String):Void
    {
        m_GuildBankView._visible = false;
        m_GuildBankView.removeMovieClip();
        m_GuildBankView = undefined;
    }
    
    //Get View
    public function get view():String
    {
        return m_View;
    }
	
	public function SlotReceiveItem(srcInventory:ID32, srcSlot:Number)
	{
		var inventory:Inventory = undefined;
		var clientCharID:ID32 = Character.GetClientCharID();
		if (m_View == STORE_AND_SELL_VIEW)
		{
			inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BankContainer, clientCharID.GetInstance()));
		}
		else if (m_View == GUILD_BANK_VIEW)
		{
			inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_GuildContainer, clientCharID.GetInstance()));
		}
		//Make sure we're set up to receive items
		if (inventory != undefined)
		{
			var firstFree:Number = inventory.GetFirstFreeItemSlot();
			//If there is room
			if (firstFree != -1)
			{
				inventory.AddItem(srcInventory, srcSlot, firstFree);
			}
		}
	}
}