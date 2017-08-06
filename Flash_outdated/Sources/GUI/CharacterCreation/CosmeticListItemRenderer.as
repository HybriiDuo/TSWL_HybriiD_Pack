import gfx.controls.ListItemRenderer;

class GUI.CharacterCreation.CosmeticListItemRenderer extends ListItemRenderer
{
	
	private var m_LockIcon:MovieClip;
	
	private function CosmeticListItemRenderer()
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
		
		m_LockIcon._visible = data.isLocked;
	}
}