import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.GameInterface.LoreNode;
import com.GameInterface.Lore;
import com.GameInterface.LoreBase;
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import flash.geom.Point;
import GUI.Achievement.ViewPanelBase;
import gfx.motion.Tween; 
import mx.transitions.easing.*; 

class GUI.Achievement.LorePanelView extends ViewPanelBase
{
    private var m_CounterText:TextField;
    private var m_PanelNameText:TextField;
    private var m_Header:TextField;
    private var m_SubHeader:TextField;    
    private var m_MainText:TextField;
    private var m_LoreProgress:MovieClip;
    private var m_ProgressView:MovieClip;
	private var m_SoundControlIndicator:MovieClip;
    private var m_PlayButton:MovieClip;
	private var m_PauseButton:MovieClip;
	private var m_StopButton:MovieClip;
	private var m_Filter:MovieClip;
	private var m_Overlay:MovieClip;
    private var m_DrawProgressMeters:Boolean;
    private var m_EntryWidth:Number;
	private var m_Viewpoints:Array;
	
	private var BUZZING_VIEWPOINT = 0;
	private var FILTH_VIEWPOINT = 1;

    
    private var LOCKED:Number = 0;
    private var UNLOCKED:Number = 1;
    
    private var m_TDB_LoreEntryLocked:String;
    
    public function LorePanelView()
    {
        m_TDB_LoreEntryLocked = LDBFormat.LDBGetText( "GenericGUI", "LoreEntryLockedNumber" );
        SignalClicked = new Signal;
        m_MainText.autoSize = "left";
    }
    
    private function configUI()
    {
        if (m_Data != undefined)
        {
            SetMedia();
            init();
        }
		m_PlayButton.addEventListener("click", this, "OnPlay");
		m_PauseButton.addEventListener("click", this, "OnPause");
		m_StopButton.addEventListener("click", this, "OnStop");
		PositionButtons();
		OnStop();
    }
	
	private function OnPlay()
	{
		m_PlayButton._visible = false;
		m_PauseButton._visible = true;
		m_PlayButton.disabled = true;
		m_PauseButton.disabled = false;
		m_StopButton.disabled = false;
		m_SoundControlIndicator.gotoAndPlay("play");
		
		if ( LoreBase.IsPlayingTagSound() )
		{
			LoreBase.PauseTagSound();
		}
		else LoreBase.PlayTagSound(m_Data.m_Id);
	}
	private function OnPause()
	{
		LoreBase.PauseTagSound();
		m_PlayButton._visible = true;
		m_PauseButton._visible = false;
		m_PauseButton.disabled = true;
		m_PlayButton.disabled = false;
		m_StopButton.disabled = false;
		m_SoundControlIndicator.gotoAndPlay("pause");
	}
	private function OnStop()
	{
		LoreBase.StopTagSound();
		if ( !LoreBase.IsLocked(m_Data.m_Id) && LoreBase.LoadTagSound(m_Data.m_Id) )
		{
			m_PlayButton._visible = true;
		}
		m_PauseButton._visible = false;
		m_PauseButton.disabled = true;
		m_PlayButton.disabled = false;
		m_StopButton.disabled = true;
		m_SoundControlIndicator.gotoAndPlay("stop");
	}
    
	private function onEnterFrame()
	{
		if ( !LoreBase.IsPlayingTagSound() )
		{
			LoreBase.StopTagSound();
		}
	}
	
    public function SetData(data:LoreNode)
    {
        super.SetData(data);
        if (initialized)
        {
            init();
        }
		
    }
    
    private function init()
    {
		var soundLoaded:Boolean = (!LoreBase.IsLocked(m_Data.m_Id) && LoreBase.LoadTagSound(m_Data.m_Id));
		m_PlayButton._visible = soundLoaded;
		m_PauseButton._visible = false;
		m_StopButton._visible = soundLoaded;
		m_SoundControlIndicator._visible = soundLoaded;
		
		if (m_Filter != undefined)
		{
			m_Filter.removeMovieClip();
			m_Filter = undefined;
		}
		if (m_Overlay != undefined)
		{
			m_Overlay.removeMovieClip();
			m_Overlay = undefined;
		}
		
		if (soundLoaded)
		{
			OnStop();
		}
		
        Lore.SignalTagAdded.Connect(SlotTagAdded, this);
        
        m_DrawProgressMeters = (m_Data.m_Children.length == 0 || m_Data.m_Children[0].m_Children.length != 0);

        m_Header.text = m_Data.m_Name;
        m_SubHeader.text = GetBreadCrumbs(m_Data);
        
        /// if there is text, draw it and add teh height of it oto m_ConentY
        var text = Lore.GetTagText(m_Data.m_Id);
        if (text == "")
        {
            m_MainText.text = text;
		}
        m_ContentY += m_MainText._height + 20;

        if (m_Content != undefined)
        {
            m_Content.removeMovieClip();
        }
        m_Content = this.createEmptyMovieClip("m_Content", this.getNextHighestDepth());
        m_Content._y = m_ContentY

        if (m_DrawProgressMeters) // draw progress fior all children if we are not a leaf node
        {
            DrawProgressMeters();
        }
        else // Draw the lore entries as we are a leaf node
        {
			CreateViewpointDropdown();
            DrawLoreEntries();
        }
    }
	
	public function PositionButtons()
	{
		m_StopButton._y = 5;
		m_PauseButton._y = 5;
		m_PlayButton._y = 5;
		m_SoundControlIndicator._y = 7;
		m_StopButton._x = m_Content._width - m_StopButton._width;
		m_PauseButton._x = m_StopButton._x - 5 - m_PauseButton._width;
		m_PlayButton._x = m_PauseButton._x;
		m_SoundControlIndicator._x = m_PlayButton._x - 5 - m_SoundControlIndicator._width;
	}
    
    public function SetSize(width:Number, height:Number)
    {
        super.SetSize(width, height);
        
        m_Header._width = width;
        m_SubHeader._width = width;
        m_MainText._width = width;
        m_EntryWidth = width - 25;

        RepositionProgressMeters();
        RepositionLoreEntries();
    }
    

    public function GetYPos(id:Number)
    {
        if (m_Content["entry_" + id] != undefined)
        {
            return m_Content["entry_" + id]._y + m_Content["entry_" + id]._height*2/3;
        }
        return 0;
    }
	
	public function SetViewpointByNode(id:Number)
	{
		if (Lore.IsValidId(id))
		{
			var viewpoint:Number = Lore.GetTagViewpoint(id);
			for(var i=0; i<m_Viewpoints.length; i++)
			{
				if(m_Viewpoints[i].id == viewpoint)
				{
					m_Content.m_ViewpointDropdown.selectedIndex = i;
					break;
				}
			}
		}
	}
    
    private function SlotTagAdded(tagId:Number, character:ID32)
    {
        if (character.Equal(Character.GetClientCharID()))
        {
            if (!m_DrawProgressMeters)
            {
                for (var i:Number = 0; i < m_Data.m_Children.length; i++)
                {
                    var node:LoreNode = m_Data.m_Children[i];
                    if (tagId == node.m_Id)
                    {
                        var entry:MovieClip = m_Content["entry_" + node.m_Id];
                        if (entry != undefined)
                        {
                            entry.removeMovieClip();
                            entry = m_Content.attachMovie("UnlockedLoreEntry", "entry_" + node.m_Id, m_Content.getNextHighestDepth());    
                            entry.m_Text.text = Lore.GetTagText(node.m_Id);
                            entry.m_Text.autoSize = "left";
                            entry._x = 6;
                            RepositionLoreEntries();
                        }
                        break;
                    }
                }
            }
            else
            {
                UpdateProgressMeters();
            }
        }
    }
	
	private function CreateViewpointDropdown()
	{
		m_Content.attachMovie( "DropdownGray", "m_ViewpointDropdown", m_Content.getNextHighestDepth());
		m_Content.m_ViewpointDropdown.disableFocus = true;
		m_Content.m_ViewpointDropdown.dropdown = "ScrollingListGray";
		m_Content.m_ViewpointDropdown.itemRenderer = "ListItemRendererGray";
		m_Content.m_ViewpointDropdown.scrollBar = "ScrollBar";
		
		m_Viewpoints = new Array();
		for (var i:Number = 0; i < m_Data.m_Children.length; i++)
		{
			var viewpoint:Number = Lore.GetTagViewpoint(m_Data.m_Children[i].m_Id);
			var addViewpoint:Boolean = true;
			for (var j:Number = 0; j < m_Viewpoints.length; j++)
			{
				if (m_Viewpoints[j].id == viewpoint){ addViewpoint = false; }
			}
			if (addViewpoint)
			{
				var viewpointName:String = LDBFormat.LDBGetText( "AchievementGUI", "Viewpoint_" + viewpoint );
				m_Viewpoints.push({ label:viewpointName, id:viewpoint });
			}
		}
		m_Content.m_ViewpointDropdown.dataProvider = m_Viewpoints;
		m_Content.m_ViewpointDropdown.addEventListener("change", this, "ViewpointSelected");
		if (m_Content.m_ViewpointDropdown.dataProvider.length < 2)
		{
			m_Content.m_ViewpointDropdown._visible = false;
		}
	}
	
	private function ViewpointSelected(event:Object)
	{
		DrawLoreEntries();
		SignalClicked.Emit();
	}
	
	private function DrawOverlays()
	{
		if (m_Filter != undefined)
		{
			m_Filter.removeMovieClip();
			m_Filter = undefined;
		}
		if (m_Overlay != undefined)
		{
			m_Overlay.removeMovieClip();
			m_Overlay = undefined;
		}
		if(m_Content.m_ViewpointDropdown.dataProvider[m_Content.m_ViewpointDropdown.selectedIndex].id == FILTH_VIEWPOINT && m_HasMedia)
		{
			m_Overlay = attachMovie("FilthPanelOverlay", "m_Overlay", this.getNextHighestDepth());
			m_Overlay._x = 0;
			m_Overlay._y = 0;
			m_Overlay._width = this._width;
			m_Overlay._height = this._height;
			m_Overlay._alpha = 0;		 
			
			m_Filter = attachMovie("FilthFilter", "m_Filter", this.getNextHighestDepth());
			m_Filter._x = this["m_Media"]._x - 15;
			m_Filter._y = this["m_Media"]._y - 27.5;
			m_Filter._alpha = 0;
			 
			m_Filter.tweenTo(0.3, {_alpha:100}, None.easeIn);
			m_Overlay.tweenTo(0.3, {_alpha:100}, None.easeIn);
		}
	}
    
    private function DrawLoreEntries()
    {
		var drawnLores:Number = 0;
        for (var i:Number = 0; i < m_Data.m_Children.length; i++)
        {
            var dataNode:LoreNode = m_Data.m_Children[i];
			if (m_Content["entry_" + dataNode.m_Id] != undefined)
			{
				m_Content["entry_" + dataNode.m_Id].removeMovieClip();
			}
			var loreViewpoint:Number = m_Content.m_ViewpointDropdown.dataProvider[m_Content.m_ViewpointDropdown.selectedIndex].id;
			if (Lore.GetTagViewpoint(dataNode.m_Id) == loreViewpoint)
			{
				if (Lore.IsLocked(dataNode.m_Id))
				{
					var entry:MovieClip = m_Content.attachMovie( "LockedLoreEntry", "entry_" + dataNode.m_Id, m_Content.getNextHighestDepth());
					entry.m_Text.text = LDBFormat.Printf(m_TDB_LoreEntryLocked, drawnLores+1); // people don't like 0 base
				}
				else
				{
					var entry:MovieClip = m_Content.attachMovie( "UnlockedLoreEntry", "entry_"+dataNode.m_Id, m_Content.getNextHighestDepth());
					entry.m_Text.text = Lore.GetTagText(dataNode.m_Id);
					if (dataNode.m_IsNew)
					{
						var notification:MovieClip = entry.attachMovie( "NewNotification", "notification", entry.getNextHighestDepth());
						notification._x = 0;
						entry.m_Text._x = notification._width + 2;
						Lore.MarkAsOld( dataNode.m_Id );
						notification.tweenTo(5, { _alpha:20 }, None.easeNone);
						notification.onTweenComplete = function()
						{
							this.removeMovieClip();
							this = undefined;
							GUI.Achievement.AchievementWindow.SignalTagRead.Emit(dataNode.m_Id);
						}
					}
					if (loreViewpoint == FILTH_VIEWPOINT) 
					{ 
						entry.m_Text.htmlText = "<font color='#707070'><i>" + entry.m_Text.text + "</i></font>";
					}
				} 
				drawnLores = drawnLores + 1;
				entry.m_Text.autoSize = "left";
				entry._x = 6;
			}
        }
        RepositionLoreEntries();
    }
    
    private function RepositionLoreEntries()
    {
        var ypos:Number = 0;
		m_Content.m_ViewpointDropdown._y = ypos;
		m_Content.m_ViewpointDropdown._x = 5;
		if (m_Content.m_ViewpointDropdown._visible)
		{
			ypos += m_Content.m_ViewpointDropdown._height + 10;
		}
        for (var i:Number = 0; i < m_Data.m_Children.length; i++)
        {
            var entry:MovieClip = m_Content["entry_" + m_Data.m_Children[i].m_Id]
            if (entry != undefined)
            {
                entry._y = ypos;
                entry.m_Text._width = m_EntryWidth;
                ypos += entry._height + 10
            }
        }
		PositionButtons();
		DrawOverlays();
    }
}