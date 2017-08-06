import gfx.controls.ListItemRenderer;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;
import com.Utils.Colors;

class GUI.ScenarioInterface.EventListItemRenderer extends ListItemRenderer
{	

	private var _disableFocus:Boolean = true;
	
	public var m_Name:TextField;
	public var m_Description:TextField;
	public var m_Background:MovieClip;
	
	private static var COLOR_NONE = 0;
	private static var COLOR_GREEN = 1;
	private static var COLOR_YELLOW = 2;
	private static var COLOR_RED = 3;
	
	private function EventListItemRenderer() 
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
		
		m_Name.text = data.m_Name;
		m_Description.text = data.m_Description;
		switch(data.m_Color)
		{
			case COLOR_NONE:
				m_Background._alpha = 0;
				break;
			case COLOR_GREEN:
				Colors.ApplyColor(m_Background, Colors.e_ColorTimeoutSuccess);
				m_Background._alpha = 25;
				break;
			case COLOR_YELLOW:
				Colors.ApplyColor(m_Background, Colors.e_ColorYellow);
				m_Background._alpha = 25;
				break;
			case COLOR_RED:
				Colors.ApplyColor(m_Background, Colors.e_ColorTimeoutFail);
				m_Background._alpha = 25;
				break;
			default:
				m_Background._alpha = 0;
		}
	}
}