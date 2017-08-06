import gfx.controls.ListItemRenderer;

class GUI.CharacterCreation.ColorPickerItemRenderer extends ListItemRenderer
{
	
	public var m_Color:MovieClip;
	
	private function BaseHeadItemRenderer()
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
      	this._visible = true; 
		
		var newColor:Color = new Color(m_Color);
		newColor.setRGB(data._color);
	}
}