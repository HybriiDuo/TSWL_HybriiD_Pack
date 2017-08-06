import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.GroupElement;

dynamic class com.Components.NameBox extends MovieClip
{
    //var m_Slot:Number;
    var m_Dynel:Dynel; // Reference to the slot.
    var m_GroupElement:GroupElement; // Reference to the slot.
    var m_NameXOrgPos:Number; // Used for placing the star and for moving the text back to org pos.
    var i_Star:MovieClip;
    private var m_UseUpperCase:Boolean;
	private var m_ShowLevel:Boolean;
    
    private var i_NameField:TextField;
    
    function Init()
    {
        //trace('CommonLib.NameBox:Init()')
        m_NameXOrgPos = i_NameField._x;
		i_NameField.autoSize = "left";
        m_UseUpperCase = false;
    }
    
    
    //Setting a character for this namebox (For client character and targets)
    function SetDynel(dynel:Dynel)
    {
		m_Dynel.SignalStatChanged.Disconnect(SlotStatChanged, this);
        m_Dynel = dynel;
        _visible = (dynel != undefined);
		
		var sameDimension:Boolean = true;
		if (dynel != undefined)
		{
			if (m_Dynel.GetStat(_global.Enums.Stat.e_Dimension) != Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_Dimension))
			{
				sameDimension = false;
			}
			m_Dynel.SignalStatChanged.Connect(SlotStatChanged, this);
		}
		
        // Set name if field exist.
        if( dynel != undefined && i_NameField )
        {
			i_NameField.text = "";
			if (m_ShowLevel)
			{
				i_NameField.text += m_Dynel.GetStat(_global.Enums.Stat.e_Level, 2) + " - ";
			}
            i_NameField.text += m_Dynel.GetName();  
            if (m_UseUpperCase)
            {
                i_NameField.text = i_NameField.text.toUpperCase();
            }
			i_NameField._width = i_NameField.textWidth + 5;
            com.GameInterface.Utils.TruncateText(i_NameField);
        }
    }
    
    //Setting the group element for this namebox (For teammembers)
    function SetGroupElement(groupElement:GroupElement)
    {
        if (m_GroupElement != undefined)
        {
            m_GroupElement.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
            m_GroupElement.SignalCharacterExitedClient.Disconnect(SlotCharacterExited, this);
        }
        m_GroupElement = groupElement;
        _visible = (m_GroupElement != undefined);
        if (m_GroupElement == undefined)
        {
            return;
        }
		
		var sameDimension:Boolean = true;
		if (m_GroupElement != undefined)
		{
			if (m_GroupElement.m_Dimension != Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_Dimension))
			{
				sameDimension = false;
			}
		}
		
        // Set name if field exist.
        if( i_NameField )
        {
            i_NameField.text = m_GroupElement.m_Name;
            if (m_UseUpperCase)
            {
                i_NameField.text = i_NameField.text.toUpperCase();
            }
			i_NameField._width = i_NameField.textWidth + 5;
            com.GameInterface.Utils.TruncateText(i_NameField);
        }
        SetOnClient(m_GroupElement.m_OnClient);
        
        m_GroupElement.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
        m_GroupElement.SignalCharacterExitedClient.Connect(SlotCharacterExited, this);
        
        //TeamInterface.SignalNewTeamLeader.Connect( SlotNewTeamLeader, this );
    }
	
	function SlotStatChanged(statId:Number)
	{
		if (statId == _global.Enums.Stat.e_Level)
		{
			if( i_NameField )
        	{
				i_NameField.text = "";
				if (m_ShowLevel)
				{
					i_NameField.text += m_Dynel.GetStat(_global.Enums.Stat.e_Level, 2) + " - ";
				}
				i_NameField.text += m_Dynel.GetName();  
				if (m_UseUpperCase)
				{
					i_NameField.text = i_NameField.text.toUpperCase();
				}
				i_NameField._width = i_NameField.textWidth + 5;
			}
		}
	}
    
    function SlotCharacterEntered()
    {
        SetOnClient(true);
    }
    
    function SlotCharacterExited()
    {
        SetOnClient(false);
    }

    // If the dynel is gone, but still in team, we grey out the name.
    function SetOnClient( onClient:Boolean )
    {
      // Change color if name exist.
      if( i_NameField )
      {
        i_NameField.textColor = onClient ? 0xFFFFFF : 0x999999;
		var character:Character = Character.GetCharacter(m_GroupElement.m_CharacterId);
		m_Dynel = Dynel(character);
		m_Dynel.SignalStatChanged.Disconnect(SlotStatChanged, this);
		if (onClient)
		{
			m_Dynel.SignalStatChanged.Connect(SlotStatChanged, this);
			i_NameField.text = "";
			if (m_ShowLevel)
			{
				i_NameField.text += character.GetStat(_global.Enums.Stat.e_Level, 2) + " - ";
			}
            i_NameField.text += character.GetName();  
            if (m_UseUpperCase)
            {
                i_NameField.text = i_NameField.text.toUpperCase();
            }
		}
      }
    }
    function SetMaxWidth(maxWidth:Number)
    {
        i_NameField.autoSize = "none";
        i_NameField._width = maxWidth;
        com.GameInterface.Utils.TruncateText(i_NameField);
    }
    
    public function UseUpperCase(useUpperCase:Boolean)
    {
        m_UseUpperCase = useUpperCase;        
    }
	
	public function SetShowLevel(showLevel:Boolean)
	{
		m_ShowLevel = showLevel;
	}
}
