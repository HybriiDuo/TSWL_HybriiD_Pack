import gfx.core.UIComponent;
import com.Utils.LDBFormat;
import com.Components.ItemSlot;
import com.GameInterface.InventoryItem;

class GUI.LootBox.PossibleItem extends UIComponent
{
	//Components created in .fla
	private var m_Slot:MovieClip;
	private var m_Name:TextField;
	
	//Variables
	private var m_ItemSlot:ItemSlot;
	
	//Statics

	
	public function PossibleItem() 
	{
		super();
		this._visible = false;
		m_ItemSlot = new ItemSlot(undefined, 0, m_Slot);
	}
	
	public function SetData(item:InventoryItem):Void
	{
		if (item != undefined)
		{
			m_Name.text = item.m_Name;
			m_ItemSlot.SetData(item);
			this._visible = true;
		}
		else
		{
			this._visible = false;
		}
	}
}