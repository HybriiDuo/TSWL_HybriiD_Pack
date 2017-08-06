import gfx.controls.ListItemRenderer;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;
import com.Utils.Colors;

class GUI.CabalManagement.LogListItemRenderer extends ListItemRenderer
{	

	private var _disableFocus:Boolean = true;
	
	public var m_Time:TextField;
	public var m_Type:TextField;
	public var m_Activity:TextField;
	
	private function LogListItemRenderer() 
	{ 
		super();
	}
	
	public function setData(data:Object):Void
	{
		if (data == undefined) 
		{
        	this._visible = false;
        	return;
      	}
		this.data = data;
		this.visible = true;
		
		m_Time.text = data.recordTime;
		m_Type.text = data.actionType;
		m_Activity.text = data.logText;
		
		var textColor:Number;
		textColor = Colors.e_ColorWhite;
		if (data.actionType == LDBFormat.LDBGetText("GuildLog", "ActionType_Membership")){ textColor = Colors.e_ColorYellow; }
		if (data.actionType == LDBFormat.LDBGetText("GuildLog", "ActionType_Bank")){ textColor = Colors.e_ColorGreen; }
		if (data.actionType == LDBFormat.LDBGetText("GuildLog", "ActionType_Government")){ textColor = Colors.e_ColorCyan; }
		m_Type.textColor = textColor;
		m_Activity.textColor = textColor;
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