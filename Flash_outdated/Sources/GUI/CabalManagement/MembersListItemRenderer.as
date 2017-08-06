import gfx.controls.ListItemRenderer;
import com.GameInterface.Utils;
import com.Utils.Colors;
import com.GameInterface.Guild.*;
import com.Utils.LDBFormat;

class GUI.CabalManagement.MembersListItemRenderer extends ListItemRenderer
{	

	private var _disableFocus:Boolean = true;
	private var m_MembersListItemRendererBackground:MovieClip;

	public var id:Number;
	public var m_NickName:TextField;
	public var m_Playfield:TextField;
	public var m_GuildRank:TextField;
	public var m_StatusBool:Boolean;
	public var m_Status:TextField;
	public var m_LastOnline:Number;
	
	private function MembersListItemRenderer() { super(); }
	
	public function setData(data:Object):Void
	{
		if (data == undefined) {
        	this._visible = false;
        	return;
      	}
      	this.data = data;
      	this._visible = true; 
		
		this.data = data;
		
		m_NickName.text = data.nickName;
		m_Playfield.text = data.playfield;
		m_GuildRank.text = Guild.GetInstance().GetRankArray()[data.guildRank - 1].GetName();
		m_StatusBool = data.online;
		m_LastOnline = data.lastOnline;
		
		var onlineDate:Date = new Date(m_LastOnline);
		var currentDate:Date = new Date();
		var dateStr:String = (LDBFormat.LDBGetText("Months", onlineDate.getMonth()) + " " + onlineDate.getDate());
		
		//If it has been a year since last login, show the year instead
		if (onlineDate.getFullYear() != currentDate.getFullYear() && onlineDate.getMonth() >= currentDate.getMonth())
		{
			dateStr = onlineDate.getFullYear().toString();
		}
		
		var textColor:Number = (m_StatusBool) ? Colors.e_ColorPureGreen : Colors.e_ColorPureRed;
		m_Status.text = (m_StatusBool) ? LDBFormat.LDBGetText("FriendsGUI", "statusOnline") : dateStr;
		
		m_NickName.textColor = textColor;
		m_Playfield.textColor = textColor;
		m_GuildRank.textColor = textColor;
		m_Status.textColor = textColor;
		
		if (data.selected)
		{
			Colors.Tint(m_MembersListItemRendererBackground, textColor, 25);
		}
		else
		{
			Colors.Tint(m_MembersListItemRendererBackground, textColor, 0);
		}
	}
	
private function updateAfterStateChange():Void
{
      if (!initialized) { return;}
     
	  setData(data);
	  validateNow();
      
	 if (constraints != null) {
         constraints.update(width, height);
      }
      dispatchEvent({type:"stateChange", state:state});
   }
}