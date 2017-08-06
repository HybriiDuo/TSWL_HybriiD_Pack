import gfx.controls.ListItemRenderer;
import gfx.controls.CheckBox;
import com.GameInterface.Utils;
import com.GameInterface.Guild.*;
import com.Utils.LDBFormat;

class GUI.CabalManagement.PermissionsListItemRenderer extends ListItemRenderer
{	

	private var _disableFocus:Boolean = true;

	public var m_ID:String;
	public var m_CheckBox1:CheckBox;
	public var m_CheckBox2:CheckBox;
	public var m_Name1:TextField;
	public var m_Name2:TextField;
	
	private function PermissionsListItemRenderer() 
	{ 
		super();
	}
	
	public function setData(data:Object):Void
	{
		if (data == undefined) {
        	this._visible = false;
        	return;
      	}
		if (data.name1 == undefined)
		{
			this._visible = false;
			return;
		}
		if (data.name1 == undefined)
		{
			m_Name1._visible = false;
			m_CheckBox1._visible = false;
		}
		else
		{
			m_Name1._visible = true;
			m_CheckBox1._visible = true;
		}
		if (data.name2 == undefined)
		{
			m_Name2._visible = false;
			m_CheckBox2._visible = false;
		}
		else
		{
			m_Name2._visible = true;
			m_CheckBox2._visible = true;
		}

      	this.data = data;
      	this._visible = true; 
		
		this.data = data;
		
		m_ID = data.category;
		m_Name1.text = data.name1;
		m_Name2.text = data.name2;
		m_CheckBox1.selected = data.hasAccess1;
		m_CheckBox1.disableFocus = true;
		m_CheckBox2.selected = data.hasAccess2;
		m_CheckBox2.disableFocus = true;
		
		if (!Guild.GetInstance().CanChangeGoverningform())
		{
			m_CheckBox1._visible = false;
			m_CheckBox2._visible = false;
			
			if (!m_CheckBox1.selected)
			{
				m_Name1._visible = false
			}
			else
			{
				m_Name1._visible = true
			}
			if (!m_CheckBox2.selected)
			{
				m_Name2._visible = false
			}
			else
			{
				m_Name2._visible = true
			}
		}
		var alphaVal:Number = 100;
		if (this._parent._parent.disabled) { alphaVal = 50; }
		m_CheckBox1._alpha = alphaVal;
		m_CheckBox2._alpha = alphaVal;
		m_Name1._alpha = alphaVal;
		m_Name2._alpha = alphaVal;
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