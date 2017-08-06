import gfx.controls.ListItemRenderer;
import com.GameInterface.AccountManagement;
import com.GameInterface.DimensionData;
import com.GameInterface.CharacterData;
import com.Utils.LDBFormat;

class GUI.LoginCharacterSelection.CharacterListItemRenderer extends ListItemRenderer
{
    private var m_CharacterName:TextField;
	private var m_PlayfieldInfo:TextField;
    private var m_Title:TextField;
    private var m_CreateNewCharacter:TextField;
    private var m_SlotsLeft:TextField;
    private var m_FactionIcon:MovieClip;
    private var m_IsConfigured:Boolean;
    private var m_Level:TextField;
    
	public function CharacterListItemRenderer()
    {
        super();

        m_IsConfigured = false;
    }
	private function configUI()
	{
		super.configUI();
        m_IsConfigured = true;
        UpdateVisuals();
	}
		
	public function setData(characterData:Object)
	{
        super.setData(characterData);

        if ( m_IsConfigured )
        {
            UpdateVisuals();
        }
    }

    private function UpdateVisuals()
    {
        if (data == undefined)
		{
			_visible = false;
			return;
		}
        
		_visible = true;

        if (m_FactionIcon.m_FactionLogo != undefined)
        {
            m_FactionIcon.m_FactionLogo.removeMovieClip();
        }
        
        if (data.m_CreateCharacter)
        {
            m_CreateNewCharacter.htmlText = data.m_Name;
            m_SlotsLeft.htmlText = data.m_Location;
            
            m_CharacterName._visible = false;
            m_Title._visible = false;
            m_PlayfieldInfo._visible = false;
            m_FactionIcon._visible = false;
            m_Level._visible = false;
            
            m_CreateNewCharacter._visible = true;
            m_SlotsLeft._visible = true;
        }
        else
        {
            m_CharacterName._visible = true;
            m_Title._visible = true;
            m_PlayfieldInfo._visible = true;
            m_FactionIcon._visible = true;
            m_Level._visible = true;
            
            m_CreateNewCharacter._visible = false;
            m_SlotsLeft._visible = false;
            
            m_CharacterName.htmlText = data.m_Name;
            m_Title.htmlText = data.m_Title;
            m_PlayfieldInfo.text = data.m_Location;
            m_Level.text = LDBFormat.LDBGetText("CharacterSkillsGUI", 54) + " " + data.m_Level;
                    
            var factionLogo:MovieClip = m_FactionIcon.attachMovie( GetFactionLogo(data.m_FactionId), "m_FactionLogo", m_FactionIcon.getNextHighestDepth());
            factionLogo._width = 32;
            factionLogo._height = 32;
            factionLogo._x = 2;
            factionLogo._y = 2;
        }
    }
    
    private function GetDimensionData(dimensionId:Number) : DimensionData
    {
        var dimensions:Array = AccountManagement.GetInstance().m_Dimensions;
        for (var i:Number = 0; i < dimensions.length; i++)
        {
            if (dimensions[i].m_Id == dimensionId)
            {
                return dimensions[i];
            }
        }
        return undefined;
    }
	
    //Get Faction Logo
    private function GetFactionLogo(faction:Number):String
    {
        var factionLogo:String = "LogoTemplar";
		
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:
                factionLogo = "LogoDragon";
                break;
                
            case _global.Enums.Factions.e_FactionIlluminati:
                factionLogo = "LogoIlluminati";
                break;
            case _global.Enums.Factions.e_FactionTemplar:                                         
                factionLogo = "LogoTemplar";
                break;
        }
        
        return factionLogo;        
    }

}