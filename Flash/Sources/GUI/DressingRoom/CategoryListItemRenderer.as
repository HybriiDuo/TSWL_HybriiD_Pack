import gfx.controls.ListItemRenderer;
import com.GameInterface.Game.Character;
import com.GameInterface.DressingRoom;
import com.GameInterface.DressingRoomNode;
import com.GameInterface.Inventory;
import com.Utils.ID32;

class GUI.DressingRoom.CategoryListItemRenderer extends ListItemRenderer
{
	//Componenets
	private var m_Text:TextField;
	private var m_Owned:MovieClip;
	private var m_Equipped:MovieClip
	
	//Variables
	private var m_Data:DressingRoomNode;
	private var m_WardrobeInventory:Inventory;
    private var m_EquippedInventory:Inventory;
	
	//Statics
	
	public function CategoryListItemRenderer()
    {
        super();
    }
	
	 private function configUI()
	{
		super.configUI();
		this.disableFocus = true;
	}
	
    public function setData( data:DressingRoomNode ) : Void
    {
		super.setData(data);
		if (data != undefined)
        {
            this._visible = true;
			m_Data = data;
			m_Text.text = data.m_Name;
			if (Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0)
			{
				m_Text.text += " [" + data.m_NodeId + "]";
			}
			if (DressingRoom.NodeOwned(data.m_NodeId))
			{
				m_Owned.gotoAndPlay("owned");
			}
			else
			{
				m_Owned.gotoAndPlay("unowned");
			}
			if (DressingRoom.NodeEquipped(data.m_NodeId))
			{
				m_Equipped._visible = true;
			}
			else
			{
				m_Equipped._visible = false;
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
        else
        {
            this._visible = false;
		}
    }
	
	public function Update():Void
	{
		if (m_Data)
		{
			if (DressingRoom.NodeOwned(data.m_NodeId))
			{
				m_Owned.gotoAndPlay("owned");
			}
			else
			{
				m_Owned.gotoAndPlay("unowned");
			}
			if (DressingRoom.NodeEquipped(data.m_NodeId))
			{
				m_Equipped._visible = true;
			}
			else
			{
				m_Equipped._visible = false;
			}
		}
	}
}