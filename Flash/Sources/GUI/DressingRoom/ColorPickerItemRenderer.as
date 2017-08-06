import gfx.controls.ListItemRenderer;
import com.GameInterface.DressingRoom;
import com.GameInterface.DressingRoomNode;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.Utils.ID32;
class GUI.DressingRoom.ColorPickerItemRenderer extends ListItemRenderer
{
	
	public var m_Top:MovieClip;
	public var m_Bottom:MovieClip;
	private var m_LockIcon:MovieClip;
	private var m_Default:MovieClip;
	
	private var m_WardrobeInventory:Inventory;
    private var m_EquippedInventory:Inventory;
	private var data:DressingRoomNode;
	
	private function BaseHeadItemRenderer()
	{
		super();
	}
	
	public function setData(data:DressingRoomNode):Void 
	{
		if (data == undefined)
		{
        	this._visible = false;
        	return;
      	}
      	
		this.data = data;
      	this._visible = true; 

		m_LockIcon._visible = !DressingRoom.NodeOwned(data.m_NodeId);
		
		m_Default._visible = data.m_Color1Name.toLowerCase() == "default";
		
		var newColor1:Color = new Color(m_Top);
		newColor1.setRGB(data.m_Color1);
		
		var newColor2:Color = new Color(m_Bottom);
		if (data.m_Color2 != 0)
		{
			newColor2.setRGB(data.m_Color2);
		}
		else
		{
			newColor2.setRGB(data.m_Color1);
		}
		
		var clientCharacterID:ID32 = Character.GetClientCharID();        
        m_WardrobeInventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, clientCharacterID.GetInstance()));
        m_EquippedInventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_WearInventory, clientCharacterID.GetInstance()));
				
		m_WardrobeInventory.SignalItemAdded.Connect(Update, this);
        m_WardrobeInventory.SignalItemLoaded.Connect(Update, this);
        m_WardrobeInventory.SignalItemChanged.Connect(Update, this);
        
        m_EquippedInventory.SignalItemAdded.Connect(Update, this);
        m_EquippedInventory.SignalItemLoaded.Connect(Update, this);
        m_EquippedInventory.SignalItemChanged.Connect(Update, this);
	}
	
	public function Update()
	{
		if (data)
		{
			m_LockIcon._visible = !DressingRoom.NodeOwned(data.m_NodeId);
		}
	}
}