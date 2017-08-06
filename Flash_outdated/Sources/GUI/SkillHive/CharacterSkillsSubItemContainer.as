//Imports
import flash.geom.Point;
import gfx.controls.Button;
import GUI.SkillHive.CharacterPointsSubSkillsBar;
import com.GameInterface.CharacterPointRowData;
import com.GameInterface.FeatInterface;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.ProjectFeatInterface;

//Class
class GUI.SkillHive.CharacterSkillsSubItemContainer extends MovieClip
{
    //Constants
    private static var TDB_SP:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "SP");
    
    //Properties
    public  var m_BuyButton:MovieClip;
    
	private var m_Id:Number;
	private var m_ParentId:Number;
    private var m_Label:TextField;
    private var m_Category:String;
	private var m_IconName:String;
    private var m_MouseBlocker:MovieClip;
	private var m_WarningClip:MovieClip;
    private var m_SubSkillsBar:CharacterPointsSubSkillsBar;
    private var m_SubSkillsData:Array;
	private var m_TrainableFeatID:Number;
	private var m_CurrentFeatID:Number;
	private var m_CurrentFeatCost:Number;
	private var m_CurrentFeatLevel:Number;
	private var m_CharacterSkillPoints:Number;
	private var m_HasConnectedToButton:Boolean;
    private var m_Levels:Number;
	
	private var m_Tooltip:TooltipInterface;
	private var m_NextTooltip:TooltipInterface;
    
    //Constructor
    public function CharacterSkillsSubItemContainer()
    {
        super();
        
		m_HasConnectedToButton = false;
		m_Id = -1;
		m_ParentId = -1;
		m_SubSkillsData = new Array();
		m_TrainableFeatID = -1;
		m_CurrentFeatID = -1;
		m_CurrentFeatCost = 0;
		m_CharacterSkillPoints = 0;
		m_CurrentFeatLevel = -1;
		m_Levels = 10;
    }
    
    //On Load
    public function onLoad()
    {
        m_BuyButton.disableFocus = true;
    }
    
    //Slot Buy
    public function SlotBuy():Void
    {
		Selection.setFocus( null );
		var highestLevel:Number = ProjectFeatInterface.GetHighestLearnedSkillLevel(m_ParentId);
		if ((m_CurrentFeatLevel + 1 >= highestLevel) || (highestLevel == m_Levels) || 
			(DistributedValue.GetDValue("ShowSkillWarning", true) == false) ||
			(!IsWeaponSkill(m_ParentId)))
		{
			BuyFeat();
		}
		else if (m_WarningClip == undefined)
		{
			m_WarningClip = this._parent._parent._parent.attachMovie("SkillPurchaseWarning", "m_WarningClip", this._parent._parent._parent.getNextHighestDepth() );
			var pos:Point = new Point(Stage.width/2, Stage.height/2);
			this._parent._parent._parent.globalToLocal(pos);
			m_WarningClip._x = pos.x - m_WarningClip._width/2;
			m_WarningClip._y = pos.y - m_WarningClip._height/2;
			m_WarningClip.m_ConfirmButton.m_Text.text = LDBFormat.LDBGetText("MainGUI", "MainMenu_OptionsView_OK");
			m_WarningClip.m_CancelButton.m_Text.text = LDBFormat.LDBGetText("GenericGUI", "Cancel");
			m_WarningClip.m_HeaderText.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillWarningHeader");
			m_WarningClip.m_MainText.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillWarningMain");
			m_WarningClip.m_CheckboxText.text = LDBFormat.LDBGetText("GenericGUI", "TipView_DoNotShowThisTipAgain");
			m_WarningClip._xscale = m_WarningClip._yscale = 150;
			
			m_WarningClip.m_CancelButton.onRelease = Delegate.create(this, RemoveWarningClip);
			m_WarningClip.m_ConfirmButton.onRelease = Delegate.create(this, BuyFeat);
			m_WarningClip.m_Background.onRollOver = function(){};
		}
    }
	
	private function BuyFeat():Void
	{
		RemoveWarningClip();
		FeatInterface.TrainFeat(m_TrainableFeatID);
		var character:Character = Character.GetClientCharacter();
		if (character != undefined) 
		{ 
			character.AddEffectPackage( "sound_fxpackage_GUI_spend_skill_point.xml" ); 
		}
	}
	
	private function RemoveWarningClip():Void
	{
		if (m_WarningClip != undefined)
		{
			DistributedValue.SetDValue("ShowSkillWarning", !m_WarningClip.m_Checkbox.selected);
			m_WarningClip.removeMovieClip();
			m_WarningClip = undefined;
		}
	}
    
    //Update Data
    public function UpdateData():Void
    {
		m_SubSkillsData.sortOn("m_Level", Array.ASCENDING | Array.NUMERIC);
        
		if (!m_HasConnectedToButton)
		{
            m_MouseBlocker.onRelease = Delegate.create(this, MouseBlockerClickHandler);
			m_BuyButton.addEventListener("click", this, "SlotBuy");
			m_HasConnectedToButton = true;
		}
        
        SetLabel(LDBFormat.LDBGetText("CharacterSkillsGUI", m_ParentId+"_"+m_Id));
		
		m_SubSkillsBar.SetParentId(m_ParentId);
        m_SubSkillsBar.SetCategory(m_Category);
		m_SubSkillsBar.SetLevels(m_Levels);
        
        for (var i:Number = 0; i < m_SubSkillsData.length; i++)
		{
			if (m_SubSkillsData[i].m_Trained )
			{
				if (i != m_SubSkillsData.length - 1)
				{
					m_CurrentFeatCost = m_SubSkillsData[i + 1].m_Cost;
					SetBuyButtonLabel(m_CurrentFeatCost.toString());
					m_TrainableFeatID = m_SubSkillsData[i + 1].m_Id;
				}

				m_CurrentFeatID = m_SubSkillsData[i].m_Id;
				m_CurrentFeatLevel = m_SubSkillsData[i].m_Level;
				m_SubSkillsBar.SetPurchasedTotal(m_SubSkillsData[i].m_Level+1);
			}
			else if (i == 0)
			{
				SetBuyButtonLabel(m_SubSkillsData[i].m_Cost.toString());
				m_CurrentFeatCost = m_SubSkillsData[i].m_Cost;
				m_TrainableFeatID = m_SubSkillsData[i].m_Id;
				m_SubSkillsBar.SetPurchasedTotal(0);
			}
		}
        
        m_SubSkillsBar.Update();
    }
	
    //Clear Data
	public function ClearData():Void
	{
		m_SubSkillsData = new Array();
	}
    
    //Mouse Blocker Click Handler
    private function MouseBlockerClickHandler():Void
    {
        
    /*
     *  This method places a mouse click block around BuyButton(s) to ensures that players will not
     *  accidently collapse the CharacterSkillsItemContainer when they intend to make a purchase. 
     * 
     */
    
    }
    
    //Set Sub Skills Data
    public function SetData(subSkillsArray:Array):Void
    {
        m_SubSkillsData = subSkillsArray;
    }
	
    //Add Sub Skill
	public function AddSubSkill(subSkill:CharacterPointRowData):Void
	{
		m_SubSkillsData.push(subSkill);
	}

    //Set Category
    public function SetCategory(value:String):Void
    {
        m_Category = value;
    }
	
	public function SetLevels(levels:Number):Void
	{
		m_Levels = levels;
	}
    
    //Set Label
    public function SetLabel(value:String):Void
    {
        m_Label.text = value;
    }

    //Set Buy Button Label
    public function SetBuyButtonLabel(value:String):Void
    {
        m_BuyButton.label = value;
        m_BuyButton.SPTextField.text = TDB_SP;
    }
    
    //Has Feat
    public function HasFeat(featID):Boolean
    {
		for (var i:Number = 0; i < m_SubSkillsData.length; i++)
		{
			if (m_SubSkillsData[i].m_Id == featID)
			{
				return true;
			}
		}
		return false;
    }
	
    //Update Character Skill Points
	public function UpdateCharacterSkillPoints(newAmount:Number):Void
	{
		m_CharacterSkillPoints = newAmount;
		UpdateBuyButton();
	}
	
    //Update Buy Button
	private function UpdateBuyButton():Void
	{
		//Disable the buybutton if cannot afford
        if (m_CharacterSkillPoints < m_CurrentFeatCost)
		{
			m_BuyButton.disabled = true;
		}
		else
		{
			m_BuyButton.disabled = false;
		}
        
        //Hide the buy button if at top level
        if (m_CurrentFeatLevel == m_Levels-1)
        {
            m_BuyButton._visible = false;
        }
        else
        {
            m_BuyButton._visible = true;
        }
	}
	
    //Set ID
	public function SetID(id:Number):Void
	{
		m_Id = id;
	}
	
    //Sets parent ID (ID of the skill this subskill belongs to
	public function SetParentID(id:Number):Void
	{
		m_ParentId = id;
	}
	
    //Get ID
	public function GetID(id:Number):Number
	{
		return m_Id;
	}
	
	public function SetIconName(iconName:String)
	{
		m_IconName = iconName;
	}
	
	public function ShowTooltip()
	{
		var extraTooltip:Array = new Array();
		var tooltipData:TooltipData = undefined;
		
        if (m_CurrentFeatID != -1)
		{
			tooltipData = TooltipDataProvider.GetFeatTooltip( m_CurrentFeatID );
			tooltipData.m_IconName = m_IconName;
			var level:Number = (m_CurrentFeatLevel + 1);
			if (m_Levels == 1)
			{
				level = 10;
			}
			tooltipData.m_SubTitle = LDBFormat.Printf(LDBFormat.LDBGetText("CharacterSkillsGUI", "CharacterSkillType"), LDBFormat.LDBGetText("CharacterSkillsGUI", m_ParentId)) +" " +  level;
			tooltipData.m_Attributes = [];
		}
		
        if ((m_TrainableFeatID != -1) && (m_CurrentFeatLevel != m_Levels-1))
		{
			var nextTooltipData:TooltipData = TooltipDataProvider.GetFeatTooltip( m_TrainableFeatID );
			var nextRankString:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "NextRank")
			nextTooltipData.m_Header = "<font size='10' color='#FF8400'>" + nextRankString + "</font>";
			nextTooltipData.m_IconName = m_IconName;
			var level:Number = (m_CurrentFeatLevel + 2);
			if (m_Levels == 1)
			{
				level = 10;
			}
			nextTooltipData.m_SubTitle = LDBFormat.Printf(LDBFormat.LDBGetText("CharacterSkillsGUI", "CharacterSkillType"), LDBFormat.LDBGetText("CharacterSkillsGUI", m_ParentId)) + " " +  level;
			nextTooltipData.m_Attributes = [];
			
            if (m_CurrentFeatID == -1)
			{
				tooltipData = nextTooltipData;
			}
			else
			{
				extraTooltip.push(nextTooltipData);
			}
		}
		
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip( undefined, TooltipInterface.e_OrientationHorizontal, -1, tooltipData, extraTooltip );
	}
	
	public function onMouseMove()
	{
		//Only show tooltip if this fully shows
		if (_alpha == 100)
		{
			var hitBlocker:Boolean = m_MouseBlocker.hitTest(_root._xmouse, _root._ymouse, false);
			var hitThis:Boolean = this.hitTest(_root._xmouse, _root._ymouse, false) && !hitBlocker && Mouse["IsMouseOver"](this);
			if (m_Tooltip != undefined)
			{
				if (!hitThis)
				{
					RemoveTooltip();
				}
			}
			else
			{
				if (hitThis)
				{
					ShowTooltip();
				}
			}
		}
		else
		{
			RemoveTooltip();
		}
	}
	
	public function RemoveTooltip()
	{
		if (m_Tooltip != undefined)
		{
			m_Tooltip.Close();
			m_Tooltip = undefined;
		}
	}
	
	private function IsWeaponSkill(skillCategory:Number)
	{
		return(skillCategory == _global.Enums.CharacterSkills.e_Shotgun ||
			   skillCategory == _global.Enums.CharacterSkills.e_AssaultRifle ||
			   skillCategory == _global.Enums.CharacterSkills.e_DualPistols ||
			   skillCategory == _global.Enums.CharacterSkills.e_Blades ||
			   skillCategory == _global.Enums.CharacterSkills.e_Hammers ||
			   skillCategory == _global.Enums.CharacterSkills.e_FistWeapons ||
			   skillCategory == _global.Enums.CharacterSkills.e_Blood ||
			   skillCategory == _global.Enums.CharacterSkills.e_Chaos ||
			   skillCategory == _global.Enums.CharacterSkills.e_Elementalism)
	}
}