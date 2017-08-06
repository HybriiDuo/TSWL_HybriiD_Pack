import com.GameInterface.FeatData;
import com.GameInterface.Utils;
import com.Utils.Colors;
import gfx.core.UIComponent;

class GUI.CharacterCreation.PreviewAbility extends UIComponent
{      
    public var m_FeatData:FeatData;
    
    private var m_Content:MovieClip;
	private var m_Lines:MovieClip
    private var m_Background:MovieClip;
    private var m_EliteFrame:MovieClip;
    
    public function PreviewAbility()
    {
        super();		
        if (m_FeatData != undefined)
        {
            SetFeatData(m_FeatData);
        }
    }
    
    public function SetFeatData(featData:FeatData)
    {
        m_FeatData = featData;        
        if (m_FeatData != undefined)
        {
            LoadIcon();
        }
    }    
        
    private function LoadIcon()
    {
        var iconString:String = Utils.CreateResourceString(m_FeatData.m_IconID);
        var moviecliploader:MovieClipLoader = new MovieClipLoader();
        
		moviecliploader.loadClip( iconString, m_Content);
        
		m_Content._x = 2;
		m_Content._y = 2;
		m_Content._xscale = m_Background._width - 4;
		m_Content._yscale = m_Background._height - 4;
		
		var iconColor = Colors.GetColorlineColors( m_FeatData.m_ColorLine );
        Colors.ApplyColor( m_Background.highlight, iconColor.highlight);
		Colors.ApplyColor( m_Background.background, iconColor.background);
        
		if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eMagicSpell || 
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eBuilderAbility ||
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eConsumerAbility)
		{
			m_Lines._visible = false;
            m_EliteFrame._visible = false;
		}
        else if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility)
        {
            m_Lines._visible = false;
            m_EliteFrame._visible = true;
        }
        else if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility)
        {
            m_Lines._visible = true;
            m_EliteFrame._visible = true;
        }
		else
		{
			m_Lines._visible = true;
            m_EliteFrame._visible = false;
		}
    }
}