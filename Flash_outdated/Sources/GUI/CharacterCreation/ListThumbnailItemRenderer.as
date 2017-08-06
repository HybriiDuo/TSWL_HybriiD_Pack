import gfx.controls.ListItemRenderer;
import gfx.controls.UILoader;

class GUI.CharacterCreation.ListThumbnailItemRenderer extends ListItemRenderer
{
	
	public var m_ImageLoader:UILoader;
	public var m_ImageMask:MovieClip;
	public var m_NamedImage:MovieClip;

	private function ListThumbnailItemRenderer()
	{
		super();
		this.disabled = true;
	}
	
	public function setData(data:Object):Void 
	{
        super.setData( data );
        if ( initialized )
        {
            UpdateControls();
        }
		m_ImageLoader.setMask(m_ImageMask);
	}
    private function configUI()
    {
        super.configUI();
        UpdateControls();
		m_ImageLoader.setMask(m_ImageMask);
    }

    private function UpdateControls()
    {
        if ( data )
        {
			if (m_NamedImage != undefined)
			{
				m_NamedImage.removeMovieClip();
				m_NamedImage = undefined;
			}
			if (data.m_IconName != undefined)
			{
				this._alpha = 90;
				m_ImageLoader.source = com.Utils.Format.Printf( "rdb:%.0f:%.0f", 1000624, 0 );
				m_NamedImage = this.attachMovie(data.m_IconName, "m_NamedImage", this.getNextHighestDepth());
				m_NamedImage._xscale = m_NamedImage._yscale = 250;
			}
			else
			{
				if ( data.m_IconID == 0 )
				{				
					this._alpha = 90;
					m_ImageLoader.source = "CharacterCreation/RemoveOutfit.swf";
				}
				else
				{
					this._alpha = 90;
					m_ImageLoader.source = com.Utils.Format.Printf( "rdb:%.0f:%.0f", 1000624, data.m_IconID );
				}
			}
			m_ImageLoader._alpha = 100;
			this.disabled = false;
			this._visible = true;
        }
		else
		{
			//This really shouldn't ever happen, but...
			//Get a different icon for empty slots
			this._alpha = 50;
			m_ImageLoader.source = "CharacterCreation/RemoveOutfit.swf";
			m_ImageLoader._alpha = 0;
			this.disabled = true;
			this._visible = false;
		}
    }
}