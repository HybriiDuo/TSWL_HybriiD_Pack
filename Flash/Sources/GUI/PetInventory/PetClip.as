import gfx.core.UIComponent;
import com.GameInterface.Lore;
import com.GameInterface.LoreBase;
import com.GameInterface.LoreNode;
import com.GameInterface.SpellBase;
import com.Utils.Colors;

class GUI.PetInventory.PetClip extends UIComponent
{
	private var m_Background:MovieClip;
	private var m_Foreground:MovieClip;
	private var m_UseFrame:MovieClip;
	private var m_PetNode:LoreNode;
	private var m_Selected:Boolean;
	
	public function PetClip()
	{
		super();
		m_UseFrame._visible = false;
		Colors.ApplyColor(m_Background.background, Colors.e_ColorWeaponItemsBackground);
		Colors.ApplyColor(m_Background.highlight, Colors.e_ColorWeaponItemsHightlight);
		m_Selected = false;
	}
	
	function onMousePress(mouseBtnId:Number)
    {
		_parent.SelectNodeClip(this);
        if(mouseBtnId == 2 && !LoreBase.IsLocked(m_PetNode.m_Id))
        {
            _parent.SummonNode(m_PetNode.m_Id);
        }       
    }
	
	public function SetSelected(select:Boolean)
	{
		m_UseFrame._visible = select;
		if(select && !m_Selected)
		{
			this._x -= 2.5;
			this._y -= 2.5;
			this._height += 5;
			this._width += 5;
			m_Selected = true;
		}
		else if (!select && m_Selected)
		{
			this._x += 2.5;
			this._y += 2.5;
			this._height -= 5;
			this._width -= 5;
			m_Selected = false;
		}
	}
	
	public function GetNode():LoreNode
	{
		return m_PetNode;
	}
	
	public function SetData(petNode)
	{
		m_PetNode = petNode;
		LoadImage(m_Foreground, m_PetNode.m_Icon);
		if(LoreBase.IsLocked(m_PetNode.m_Id)){ m_Foreground._alpha = m_Background._alpha = 35; }
	}
	
	public function SetFavorite(favorite:Boolean)
	{
		if(favorite)
		{
			Colors.ApplyColor(m_Background.background, Colors.e_ColorDarkOrange); //0xAF7817
			Colors.ApplyColor(m_Background.highlight, Colors.e_ColorDarkOrange);  //0xAF7817
		}
		else
		{
			Colors.ApplyColor(m_Background.background, Colors.e_ColorWeaponItemsBackground);
			Colors.ApplyColor(m_Background.highlight, Colors.e_ColorWeaponItemsHightlight);
		}
	}
	
	private function TagAdded()
	{
		m_Foreground._alpha = m_Background._alpha = 100;
	}

	private function LoadImage(container:MovieClip, mediaId:Number)
	{
		var path = com.Utils.Format.Printf("rdb:%.0f:%.0f", _global.Enums.RDBID.e_RDB_FlashFile, mediaId);
		var movieClipLoader:MovieClipLoader = new MovieClipLoader();
		movieClipLoader.addListener(this);
		var isLoaded = movieClipLoader.loadClip(path, container);
		
		container._x = 1;
		container._y = 1;
		container._xscale = m_Background._width-(container._x*2);
		container._yscale = m_Background._height-(container._y*2);
	}

	private function onLoadInit(target:MovieClip)
	{
		/*
		target._height = 42;
		target._width = 42;
		*/
	}

	private function onLoadError(target:MovieClip, errorcode:String, httpStatus:Number)
	{
		trace("PetInventory:onLoadError( " + errorcode + ", httpStatus = " + httpStatus);
	}
}