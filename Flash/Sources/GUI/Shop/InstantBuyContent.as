//Imports
import com.Components.WindowComponentContent;
import com.Components.ItemComponent;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.Utils.Signal;
import gfx.core.UIComponent

//Class
class GUI.Shop.InstantBuyContent extends WindowComponentContent
{
    //Constants
	private static var SPLIT_MIN:Number = 7;
    
    //Properties
	private var m_Entries:Array;
	private var SignalClose:Signal;
	public var SignalContentInitialized:Signal;
        
    //Constructor
    public function InstantBuyContent()
    {
        super();
		SignalContentInitialized = new Signal();
		SignalClose = new Signal();
    }
    
    //Config UI
    private function configUI():Void
    {
		m_Entries = new Array();
		SignalContentInitialized.Emit();
    }
	
	public function SetOffers(offers:Array, overridePrices:Array, overrideCurrency:Array):Void
	{
		var entryY:Number = 0;
		var splitRow:Number = SPLIT_MIN;
		if (offers.length > SPLIT_MIN)
		{
			splitRow = Math.floor(offers.length/2);
		}
		for (var i:Number = 0; i < offers.length; i++)
		{
			var offerItem:InventoryItem = Inventory.CreateACGItemFromTemplate(offers[i], 0, 0, 1);
			var offerEntry:MovieClip = attachMovie("InstantBuyEntry", "entry_" + i, this.getNextHighestDepth());
			offerEntry._x = 0 + (offerEntry._width + 5) * Math.floor(i/(splitRow+1));
			offerEntry._y = entryY;
			if (overridePrices != undefined)
			{
				offerEntry.OverridePrice(overridePrices[i]);
			}
			if (overrideCurrency != undefined)
			{
				offerEntry.OverrideCurrency(overrideCurrency);
			}
			offerEntry.SetData(offerItem);
			entryY += offerEntry._height + 5;
			if (i != 0 && i % splitRow == 0)
			{
				entryY = 0;
			}
			offerEntry.SignalClose.Connect(Close, this);
			m_Entries.push(offerEntry);
		}
		SignalSizeChanged.Emit();
	}
	
	private function Close()
	{
		SignalClose.Emit();
	}
}