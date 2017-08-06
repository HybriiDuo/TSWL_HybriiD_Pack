import gfx.core.UIComponent;
import GUI.ChallengeJournal.MissionEntry;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import mx.utils.Delegate;

class GUI.ChallengeJournal.ScrollPanel extends UIComponent
{
	//Components created in .fla
	private var m_Background:MovieClip;
	
	//Variables
	private var m_ListContent:MovieClip;
	private var m_Mask:MovieClip;
	private var m_ScrollBar:MovieClip;
	private var m_MissionEntries:Array;

	//Statics
	private var ENTRY_PADDING:Number = 2;
	private var SCROLL_SPEED:Number = 10;
	private var SCROLL_PADDING:Number = 3;
	
	public function ScrollPanel() 
	{
		super();
	}
	
	public function SetData(challengeData:Array):Void
	{
		RemoveContent();
		CreateContent(challengeData);
	}
	
	public function SetSize(newWidth:Number, newHeight:Number):Void
	{
		m_Background._width = newWidth;
		m_Background._height = newHeight;
	}
	
	private function CreateContent(challengeData:Array):Void
	{
		m_MissionEntries = new Array();
		m_ListContent = this.createEmptyMovieClip("m_ListContent", this.getNextHighestDepth());		
		var entryY:Number = 0;
		for (var i:Number = 0; i < challengeData.length; i++)
		{
			var missionEntry:MissionEntry = MissionEntry(m_ListContent.attachMovie("MissionEntry", "MissionEntry_" + i, m_ListContent.getNextHighestDepth()));
			missionEntry._y = entryY;
			entryY += missionEntry._height + ENTRY_PADDING;
			missionEntry.SetData(challengeData[i], i);
			missionEntry.SignalEntrySelected.Connect(SlotEntrySelected, this);
			missionEntry.SignalSizeChanged.Connect(ContentSizeUpdated, this);
			m_MissionEntries.push(missionEntry);
		}
		CreateScrollBar();
		ContentSizeUpdated();
	}
	
	private function RemoveContent():Void
	{
		if (m_MissionEntries != undefined)
		{
			m_MissionEntries = undefined;
		}
		if (m_ListContent != undefined)
		{
			m_ListContent.removeMovieClip();
		}
		// remove the mask if any
        if (m_Mask != undefined)
        {
            this.setMask(null);
            m_Mask.removeMovieClip();
        }        
        // remove the scrollbar if any
        if (m_ScrollBar != undefined)
        {
            m_ScrollBar.removeMovieClip();
        }
	}
	
	private function ContentSizeUpdated():Void
	{
		m_ScrollBar.setScrollProperties( m_Background._height, 0, m_ListContent._height - m_Background._height); 
		if (m_ListContent._height > m_Background._height)
		{
			Mouse.addListener( this );
			m_ScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
		}
		else
		{
			Mouse.removeListener( this );
			m_ScrollBar.removeEventListener("scroll", this, "OnScrollbarUpdate");
			m_ListContent.tweenEnd(false);
			m_ListContent.tweenTo(0.1, { _y: 0 }, None.easeNone);
			m_ScrollBar.position = 0;
		}
		UpdateScrollbarVisibility();
	}
	
	private function CreateScrollBar():Void
	{
		m_Mask = com.GameInterface.ProjectUtils.SetMovieClipMask(m_ListContent, this, m_Background._height);
		
		m_ScrollBar = attachMovie("ScrollBar", "m_ScrollBar", this.getNextHighestDepth());
		m_ScrollBar._y = 0
		m_ScrollBar._x = this._width - m_ScrollBar._width/2 + SCROLL_PADDING;
		m_ScrollBar.setScrollProperties( m_Background._height, 0, m_ListContent._height - m_Background._height); 
		m_ScrollBar._height = m_Background._height;
		m_ScrollBar.trackMode = "scrollPage"
		m_ScrollBar.trackScrollPageSize = m_Background._height;
		m_ScrollBar.disableFocus = true;
	}
	
	private function OnScrollbarUpdate(event:Object) : Void
    {
        var target:MovieClip = event.target;
        var pos:Number = event.target.position;
        
        m_ListContent._y = -pos;        
        Selection.setFocus(null);
    }
	
	private function onMouseWheel( delta:Number ):Void
    {
        if ( Mouse["IsMouseOver"]( this ) )
        {
            var newPos:Number = m_ScrollBar.position + -(delta * SCROLL_SPEED);
            var event:Object = { target : m_ScrollBar };
            
            m_ScrollBar.position = Math.min(Math.max(0.0, newPos), m_ScrollBar.maxPosition);
            
            OnScrollbarUpdate(event);
        }
    }
	
	private function UpdateScrollbarVisibility():Void
	{
		if (m_ListContent._height > m_Background._height)
		{
			m_ScrollBar._visible = true;
		}
		else
		{
			m_ScrollBar._visible = false;
		}
	}
	
	private function SlotEntrySelected( index:Number, isExpanded:Boolean ):Void
	{
		var expandHeight:Number = m_MissionEntries[index].EXPAND_HEIGHT - m_MissionEntries[index].CONTRACT_HEIGHT;
		for (var i:Number = 0; i<m_MissionEntries.length; i++)
		{
			//Lock all the entries
			m_MissionEntries[i].SetHittable(false);
			//Shift entries after the selected one down
			if (i > index)
			{
				var originalY:Number = m_MissionEntries[i]._y;
				if (isExpanded)
				{
					m_MissionEntries[i].tweenEnd(false);
					m_MissionEntries[i].tweenTo(0.3, { _y: originalY - (expandHeight) }, None.easeNone);
				}
				else
				{
					m_MissionEntries[i].tweenEnd(false);
					m_MissionEntries[i].tweenTo(0.3, { _y: originalY + expandHeight }, None.easeNone);
				}
			}
		}
		var contentHeight:Number = isExpanded ? (m_ListContent._height - expandHeight) : (m_ListContent._height + expandHeight);
		var scrollTo:Number = Math.min(m_MissionEntries[index]._y, Math.abs(contentHeight - m_Background._height));
		m_ListContent.tweenEnd(false);
		m_ListContent.tweenTo(0.3, { _y: -scrollTo }, None.easeNone);
		m_ListContent.onTweenComplete = Delegate.create(this, CleanupAfterAnimation);
		m_ScrollBar.maxPosition = scrollTo; //This is a hack to make our position valid before tweening
		m_ScrollBar.removeEventListener("scroll", this, "OnScrollbarUpdate"); //Don't update the scrollbar when we do this
		m_ScrollBar.position = scrollTo;
	}
	
	private function CleanupAfterAnimation():Void
	{
		for (var i:Number = 0; i<m_MissionEntries.length; i++)
		{
			//Unlock all the entries
			m_MissionEntries[i].SetHittable(true);
		}
	}
	
	public function MissionCompleted(missionID:Number):Void
	{
		for (var i:Number = 0; i<m_MissionEntries.length; i++)
		{
			if (missionID == m_MissionEntries[i].m_MissionInfo.m_ID)
			{
				m_MissionEntries[i].SetComplete(true);
			}
		}
	}
	public function GoalUpdated(goalID:Number, solvedTimes:Number):Void
	{
		for (var i:Number = 0; i<m_MissionEntries.length; i++)
		{
			if (goalID == m_MissionEntries[i].m_MissionInfo.m_CurrentTask.m_Goals[0].m_ID)
			{
				m_MissionEntries[i].UpdateProgress(solvedTimes);
			}
		}
	}
}