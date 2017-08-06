import gfx.controls.ListItemRenderer;
import com.GameInterface.LoreNode;
import com.GameInterface.LoreBase;
import com.GameInterface.Game.Character;

class GUI.Emotes.EmoteListItemRenderer extends ListItemRenderer
{
	//Components created in .fla
	private var m_Name:TextField;
	private var m_LockIcon:MovieClip;
	
	//Variables
	private var m_LoreNode:LoreNode;
	
	//Statics
	private var LOCKED_ALPHA = 60;
	private var UNLOCKED_ALPHA = 100;
	
	public function EmoteListItemRenderer()
    {
        super();
    }
	
	 private function configUI()
	{
		super.configUI();
	}
	
    public function setData( data:Object ) : Void
    {
		super.setData(data);
		if (data != undefined)
        {
            m_LoreNode = LoreNode(data);
			m_Name.text = m_LoreNode.m_Name;
			if (Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0)
			{
				m_Name.text += " - " + String(m_LoreNode.m_Id);
			}
			if (m_LoreNode.m_Locked)
			{
				this._alpha = LOCKED_ALPHA;
				m_LockIcon._visible = true;
			}
			else
			{
				this._alpha = UNLOCKED_ALPHA;
				m_LockIcon._visible = false;
			}
			this._visible = true;
        }
        else
        {
            this._visible = false;
		}
    }
}