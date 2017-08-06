import gfx.controls.ListItemRenderer;


class GUI.HUD.SMSListItemRenderer extends ListItemRenderer
{
	private var m_Name:TextField;
	private var m_Text:TextField;
	private var m_Icon:MovieClip;
	
	public function SMSListItemRenderer()
    {
        super();
    }
	
    public function setData( data:Object ) : Void
    {
		if (data == undefined)
		{
        	this.enabled = false;
			m_Name.text = "";
			m_Text.text = "";
			m_Icon._visible = false;
			gotoAndPlay("disabled");
        	return;
      	}
      	
		this.data = data;
      	this.enabled = true;
		
		m_Name.text = data.from;
		m_Text.text = data.desc;
		m_Icon._visible = true;
		gotoAndPlay("up");
    }
}