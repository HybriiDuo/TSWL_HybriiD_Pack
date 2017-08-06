import gfx.core.UIComponent;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.LoreNode;
import com.GameInterface.Utils;
import GUI.RegionTeleport.PlayfieldEntry;

class GUI.RegionTeleport.RegionTeleportScrollPanel extends UIComponent
{
	//Components created in .fla
	private var m_Background:MovieClip;
	
	//Variables
	private var m_ListContent:MovieClip;
	private var m_PlayfieldEntries:Array;
	private var m_Mask:MovieClip;
	private var m_ScrollBar:MovieClip;

	public var SignalEntryFocused:Signal;
	public var SignalEntryActivated:Signal;

	//Statics
	private static var LIST_TOP_PADDING = 4;
	private static var ENTRY_PADDING:Number = 1;
	private static var SCROLL_SPEED:Number = 10;
	private static var SCROLL_PADDING:Number = 3;
	
	public function RegionTeleportScrollPanel() 
	{
		super();
		SignalEntryFocused = new Signal();
		SignalEntryActivated = new Signal();
	}
	
	public function SetData(headerNode:LoreNode):Void
	{
		RemoveContent();
		CreateContent(headerNode);
	}
	
	private function CreateContent(headerNode:LoreNode):Void
	{
		m_PlayfieldEntries = new Array();
		m_ListContent = this.createEmptyMovieClip("m_ListContent", this.getNextHighestDepth());
		for (var i:Number = 0; i < headerNode.m_Children.length; i++)
		{
			if (Utils.GetGameTweak("HideTeleport_" + headerNode.m_Children[i].m_Id) == 0)
			{
				var playfieldEntry:PlayfieldEntry = PlayfieldEntry(m_ListContent.attachMovie("PlayfieldEntry", "PlayfieldEntry_" + headerNode.m_Children[i].m_Id, m_ListContent.getNextHighestDepth()));
				playfieldEntry.SetData(headerNode.m_Children[i], 0);
				playfieldEntry.SignalEntrySizeChanged.Connect(LayoutEntries, this);
				playfieldEntry.SignalEntryFocused.Connect(SlotEntryFocused, this);
				playfieldEntry.SignalEntryActivated.Connect(SlotEntryActivated, this);
				m_PlayfieldEntries.push(playfieldEntry);
			}
		}
		CreateScrollBar();
		for (var i:Number = 0; i < m_PlayfieldEntries.length; i++)
		{
			m_PlayfieldEntries[i].Expand();
		}
	}
	
	private function RemoveContent():Void
	{
		if (m_PlayfieldEntries != undefined)
		{
			m_PlayfieldEntries = undefined;
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
	
	private function LayoutEntries():Void
	{
		var entryY:Number = LIST_TOP_PADDING;
		for (var i:Number = 0; i<m_PlayfieldEntries.length; i++)
		{
			m_PlayfieldEntries[i]._y = entryY;
			m_PlayfieldEntries[i].LayoutSubEntries();
			entryY += m_PlayfieldEntries[i].GetFullHeight() + ENTRY_PADDING;
		}
		ContentSizeUpdated();
	}
	
	private function ContentSizeUpdated():Void
	{
		m_ScrollBar.setScrollProperties( m_Background._height, 0, m_ListContent._height - m_Background._height); 
		if (m_ListContent._height > m_Background._height)
		{
			Mouse.addListener( this );
			m_ScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
			if (m_ListContent._height + m_ListContent._y < m_Background._height)
			{
				m_ListContent.tweenEnd(false);
				m_ListContent.tweenTo(0.1, { _y: m_Background._height - m_ListContent._height }, None.easeNone);
			}
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
	
	private function SlotEntryFocused(loreNode:LoreNode):Void
	{
		for (var i:Number = 0; i < m_PlayfieldEntries.length; i++)
		{
			m_PlayfieldEntries[i].SetFocusById(loreNode.m_Id);
		}
		SignalEntryFocused.Emit(loreNode);
	}
	
	private function SlotEntryActivated(nodeId:Number):Void
	{
		SignalEntryActivated.Emit(nodeId);
	}
}