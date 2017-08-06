import com.Utils.Signal;
import gfx.core.UIComponent;
import gfx.controls.Button;
import mx.utils.Delegate;
import com.GameInterface.Game.Character;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.GameInterface.Spell;
import com.GameInterface.Game.Shortcut;
dynamic class GUI.SkillHive.SkillHiveBuyPanel extends UIComponent
{
    public var SignalBuyPressed;
	public var SignalEquipPressed;
	public var SignalUnEquipPressed;
	public var SignalRefundPressed;
    
	
	var m_Character:Character;
	var m_Token:Number;
	var m_Cost:Number;
	var m_FeatId:Number;
	var m_SP:MovieClip;
	var m_FirstButton:Button;
    
    var m_Initialized:Boolean;
    var m_IsTrained:Boolean;
    var m_IsEquipped:Boolean;
	var m_ShouldUnequip:Boolean;
	var m_CanTrain:Boolean;
	var m_CanEquip:Boolean;
	
	private static var PADDING:Number = 5;
    
    function SkillHiveBuyPanel()
    {
        super();
        this._alpha = 0;
		SignalBuyPressed = new Signal();
		SignalEquipPressed = new Signal();
		SignalUnEquipPressed = new Signal();
		SignalRefundPressed = new Signal();
        	
        m_Initialized = false;
        m_IsTrained = false;
		m_IsEquipped = false;
		m_ShouldUnequip = false;
		m_CanEquip = true;
    }
    
    function configUI()
    {
		super.configUI();
		
        m_FirstButton.autoSize = "left";        
        m_FirstButton.addEventListener("click", this, "SlotFirstButtonClicked");
		
		m_FirstButton.disableFocus = true;
        
        m_Initialized = true;
		UpdateText();
		_global.setTimeout(Delegate.create(this, UpdateLayout), 1);
    }
    
    
    function SlotFirstButtonClicked(event:Object)
    {
        if (!m_IsTrained)
        {
            if (m_Character.GetTokens(m_Token) >= m_Cost)
            {
                BuyAbility();
            }
        }
        else
        {
            EquipAbility();
        }
    }
	
	function SetData(character:Character, cost:Number, token:Number, featId:Number, canTrain:Boolean)
	{
		m_Character = character;
		m_Cost = cost;
		m_Token = token;
		m_FeatId = featId;
		m_CanTrain = canTrain;
		if (token == _global.Enums.Token.e_Anima_Point)
		{
			m_SP.m_SkillPointsLabel.text = LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsAbbreviation");
		}
		if (token == _global.Enums.Token.e_Skill_Point)
		{
			m_SP.m_SkillPointsLabel.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillPointsAbbreviation");
		}
	}
	
	function SetShouldUnequip(unequip:Boolean)
	{
		m_ShouldUnequip = unequip;
	}
    
    function Update(isTrained:Boolean, isRefundable:Boolean, spellId:Number, canTrain:Boolean)
    {
        m_IsTrained = isTrained;
		m_CanTrain = canTrain;
		
		if (Spell.IsPassiveSpell(spellId))
        {
			m_IsEquipped = Spell.IsPassiveEquipped(spellId);
        }
		//This should cover both actives and passives
        else
        {
			m_IsEquipped = Shortcut.IsSpellEquipped(spellId);
        }
		
        if (m_Initialized)
        {
			UpdateText();
			_global.setTimeout(Delegate.create(this, UpdateLayout), 1);
        }
    }
    
    function UpdateLayout()
    {
		if (!m_IsTrained)
        {
            m_SP._visible = true;
			if (m_CanTrain)
			{
				m_FirstButton._visible = true;
				var totalWidth:Number = m_SP._width + PADDING + m_FirstButton._width;
				m_SP._x = this._width/2 - totalWidth/2;
				m_FirstButton._x = m_SP._x + m_SP._width + PADDING;
			}
			else
			{
				m_FirstButton._visible = false;
				m_SP._x = this._width/2 - m_SP._width/2;
			}
			if (m_Character.GetTokens(m_Token) >= m_Cost)
			{
				m_SP.m_SkillPointsLabel.textColor = m_SP.m_SkillPointsText.textColor = Colors.e_ColorPureGreen;
			}
			else
			{
				m_SP.m_SkillPointsLabel.textColor = m_SP.m_SkillPointsText.textColor = Colors.e_ColorPureRed;
			}
        }
		else if (!m_CanEquip)
		{
			m_SP._visible = false;
			m_FirstButton._visible = false;
		}
        else
        {
            m_SP._visible = false;
			m_FirstButton._visible = true;
			m_FirstButton._x = this._width/2 - m_FirstButton._width/2;
        }
		this._alpha = 100;
    }
	
	function UpdateText()
    {
		if (!m_IsTrained)
        {
			if (m_CanTrain)
			{
				m_FirstButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "BuyAbility");
			}
			m_SP.m_SkillPointsText.text = m_Cost;
        }
        else
        {
			if (m_IsEquipped)
			{
				if (m_ShouldUnequip)
				{
					m_FirstButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "UnEquipAbility");
				}
				else
				{
					m_FirstButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "ReEquipAbility");
				}
			}
			else
			{
				m_FirstButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "EquipAbility");
			}
        }
    }
    
    function BuyAbility()
    {
        SignalBuyPressed.Emit(m_FeatId);
    }
    
    function RefundAbility()
    {
        SignalRefundPressed.Emit(m_FeatId);    
    }
    
    function EquipAbility()
    {
		if (m_IsEquipped && m_ShouldUnequip)
		{
			SignalUnEquipPressed.Emit(m_FeatId);
		}
		else
		{
			SignalEquipPressed.Emit(m_FeatId, this._parent);  
		}
    }
}