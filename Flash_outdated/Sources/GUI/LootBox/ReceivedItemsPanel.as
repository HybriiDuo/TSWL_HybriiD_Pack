import gfx.core.UIComponent;
import gfx.controls.Button;
import com.Utils.LDBFormat;
import com.Utils.Signal;

class GUI.LootBox.ReceivedItemsPanel extends UIComponent
{
	//Components created in .fla
	private var m_CloseButton:Button;
	//Variables
	private var m_Data:Array;
	private var m_Initialized:Boolean;
	public var SignalPanelClosed:Signal;
	
	//Statics

	
	public function ReceivedItemsPanel() 
	{
		super();
		m_Initialized = false;
		SignalPanelClosed = new Signal;
	}
	
	public function configUI()
	{
		m_CloseButton.addEventListener("click", this, "CloseReceivedHandler");
		if (m_Data != undefined)
		{
			PopulateItems();
		}
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
			if (this["m_ReceivedItem_"+i] != undefined)
			{
				this["m_ReceivedItem_"+i].SetData(m_Data[i]);
			}
		}
		//Only one item, make it look more important
		if (m_Data.length == 1)
		{
			var itemClip:MovieClip = this["m_ReceivedItem_0"];
			itemClip._xscale = itemClip._yscale = 200;
			itemClip._x = 70;
			itemClip._y = 90;
			
		}
	}
	
	private function CloseReceivedHandler()
	{
		SignalPanelClosed.Emit();
	}
}