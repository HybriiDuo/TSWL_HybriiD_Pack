import com.Components.WindowComponentContent;
import com.Utils.Archive;
import com.Utils.LDBFormat;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Game.Character;
import mx.transitions.easing.*;
import mx.utils.Delegate;

class GUI.SkillHiveSimple.SkillsPage extends WindowComponentContent
{
	//Properties created in .fla
	private var m_Background:MovieClip;
	private var m_Footer:MovieClip;
	
	//Variables
	private var m_IsAnimating:Boolean;
	private var m_CharacterSkillsList:MovieClip;
	private var m_ScrollBar:MovieClip;
	private var m_Character:Character;
	private var m_VisibleListHeight:Number;
	
	//Statics	
	private static var SCROLL_INTERVAL:Number = 10;
	private static var SCROLL_SPEED:Number = 1;
	private static var TOP_PADDING = 26;
	private static var SIDE_PADDING = 10;
	
	public function SkillsPage()
	{
		super();		
		m_IsAnimating = false;
		
		Mouse.addListener(this);        
        m_Background.onPress = function()
        {
        }
		
		m_Character = Character.GetClientCharacter()
		m_Character.SignalTokenAmountChanged.Connect(SlotTokenChanged, this);
	}
	
	private function configUI():Void
	{
		super.configUI();
		m_CharacterSkillsList = attachMovie("CharacterSkillsList", "m_CharacterSkillsList", this.getNextHighestDepth());
		var listScale:Number = ((m_Background._width - SIDE_PADDING) / m_CharacterSkillsList._width) * 100;
		m_CharacterSkillsList._xscale = m_CharacterSkillsList._yscale = listScale;
		m_CharacterSkillsList._y = TOP_PADDING;
		
		m_CharacterSkillsList.SignalStartAnimation.Connect(SlotStartAnimation, this);
        m_CharacterSkillsList.SignalStopAnimation.Connect(SlotStopAnimation, this);
		
		m_VisibleListHeight = m_Background._height - m_Footer._height - 2;
		
		var mask:MovieClip = ProjectUtils.SetMovieClipMask(m_CharacterSkillsList, this, m_VisibleListHeight, m_Background._width, false);
        mask._x = m_Background._x;
        mask._y = m_Background._y;
		_global.setTimeout(Delegate.create(this, CreateScrollBar), 100);
		
		UpdateFooter();
	}
	
	//Create Scroll Bar
    private function CreateScrollBar():Void
    {
		m_Scrollbar = this.attachMovie("ScrollBar", "m_ScrollBar", this.getNextHighestDepth());
        m_ScrollBar._y = TOP_PADDING;
        m_ScrollBar._x = m_Background._width - m_ScrollBar._width - 3;
        m_ScrollBar._height = m_VisibleListHeight;
        m_ScrollBar.setScrollProperties(m_VisibleListHeight, 0, m_CharacterSkillsList._height - m_VisibleListHeight);
        m_ScrollBar.addEventListener("scroll", this, "ScrollBarEventHandler");
        m_ScrollBar.position = 1;
        m_ScrollBar.trackMode = "scrollPage";
        m_ScrollBar.trackScrollPageSize = 4;
        m_ScrollBar.disableFocus = true;
		m_ScrollBar._alpha = 100;
		
		UpdateScrollBar();
    }
	
	//Update Scroll Bar
    private function UpdateScrollBar():Void
    {
        var endScroll:Number = 0;
        var maxScroll:Number = 0;
        var listHeight:Number = m_CharacterSkillsList._height;
        var backgroundHeight:Number = m_VisibleListHeight;
        if (listHeight > backgroundHeight)
        {
            endScroll = listHeight - backgroundHeight;
            maxScroll = Math.ceil(endScroll / SCROLL_INTERVAL);
            m_ScrollBar._visible = true;
			
			if (m_CharacterSkillsList._y + listHeight < backgroundHeight)
			{
				m_CharacterSkillsList.tweenTo(0.25, {_y: TOP_PADDING - (listHeight - backgroundHeight)}, Regular.easeOut);
			}			
        }
        else
        {
			m_CharacterSkillsList.tweenTo(0.25, {_y: TOP_PADDING}, Regular.easeOut);
            m_ScrollBar.position = 0;
            m_ScrollBar._visible = false;
        }
        
        m_ScrollBar.setScrollProperties(m_VisibleListHeight, 0, m_CharacterSkillsList._height - m_VisibleListHeight);
    }
	
	//Scroll Bar Event Handler
    private function ScrollBarEventHandler(event:Object):Void
    {
		///update the position of the abilities
		var pos:Number = event.target.position;
		m_CharacterSkillsList._y = TOP_PADDING - (pos * SCROLL_SPEED);
		Selection.setFocus(null);
    }
	
	//On Mouse Wheel
	function onMouseWheel(delta:Number)
	{
		if (m_ScrollBar._visible && !m_IsAnimating)
		{
			m_ScrollBar.position -= delta * SCROLL_INTERVAL;
		}
	}
	
	//Slot Start Functionn
    public function SlotStartAnimation():Void
    {
        m_IsAnimating = true;
    }
    
    //Slot Stop Function
    public function SlotStopAnimation():Void
    {
        m_IsAnimating = false;
        UpdateScrollBar();
    }
	
	private function UpdateFooter():Void
	{
		m_Footer.m_AbilityPointsText.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillHive_TotalAnimaPoints") + ": " + m_Character.GetTokens(1) + "/" + (com.GameInterface.Utils.GetGameTweak("LevelTokensCap") + m_Character.GetStat(_global.Enums.Stat.e_PersonalAnimaTokenCap, 2 /* full */));
		m_Footer.m_SkillPointsText.text = LDBFormat.LDBGetText("CharacterSkillsGUI", "SkillPoints") + ": " + m_Character.GetTokens(2) + "/" + (com.GameInterface.Utils.GetGameTweak("SkillTokensCap") + m_Character.GetStat(_global.Enums.Stat.e_PersonalSkillTokenCap, 2 /* full */));
		m_Footer.m_SkillRankText.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillRankLabel") + " " + Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_PowerRank);
	}
	
	private function SlotTokenChanged(tokenID:Number, newAmount:Number, oldAmount:Number)
	{
		if (tokenID == 1 || tokenID == 2)
		{
			UpdateCells(m_CurrentCluster);
			UpdateFooter();
		}
	}
	
	public function OnModuleActivated(config:Archive):Void
	{
		//Intentionally left empty. SkillHiveSimpleWindow will attempt to call this, but we have nothing to do here.
	}

	public function OnModuleDeactivated()
	{
		var archive:Archive = new Archive();
		return archive;
	}
}