import com.Components.WindowComponentContent;
import gfx.controls.ScrollingList;
import gfx.controls.Button;
import gfx.controls.ButtonGroup;
import com.Utils.LDBFormat;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.LoreBase;
import com.GameInterface.SpellBase;
import mx.utils.Delegate;


class GUI.Emotes.EmotesContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_ItemList:ScrollingList;
	
	//Variables
	private var m_TabGroup:ButtonGroup;
	private var m_NumTabs:Number;
	private var m_ImagesLoaded:Number;
	
	//Statics
	
	public function EmotesContent()
	{
		super();
	}
	
	private function configUI():Void
	{		
		super.configUI();
		m_TabGroup = new ButtonGroup();
		SetLabels();
		SetupTabs();
		
		m_ItemList.addEventListener("focusIn", this, "RemoveFocus");
        m_ItemList.addEventListener("change", this, "OnItemSelected");
	}
	
	//Set Labels
    private function SetLabels():Void
    {
       
    }
	
	private function SetupTabs():Void
	{
		var rootNode:LoreNode = Lore.GetEmoteTree();
		var tabNodes:Array = rootNode.m_Children;
		
		m_ImagesLoaded = 0;		
		//TODO swap 5 for children.length when using real data		
		m_NumTabs = 5;
		var tabY:Number = 2;
		for (var i=0; i<m_NumTabs; i++)
		{
			var tab:MovieClip = this.attachMovie("TabButtonVertical", "m_Tab_" + i, this.getNextHighestDepth());
			tab.group = m_TabGroup;
			tab.data = tabNodes[i];
			LoadImage(tab.m_Content, tab.data.m_Icon);
			tab._y = tabY;
			tabY += tab._height;
		}
		m_TabGroup.addEventListener("change",this,"TabChanged");
	}
	
	private function LoadImage(container:MovieClip, mediaId:Number)
	{
		var path = com.Utils.Format.Printf("rdb:%.0f:%.0f", _global.Enums.RDBID.e_RDB_FlashFile, mediaId);
		var movieClipLoader:MovieClipLoader = new MovieClipLoader();
		movieClipLoader.addListener(this);
		var isLoaded = movieClipLoader.loadClip(path, container);
		
		container._x = 1;
		container._y = 1;
		container._xscale = 38.3-(container._x*2);
		container._yscale = 35-(container._y*2);
	}
	
	private function onLoadComplete()
	{
		m_ImagesLoaded++;
		if (m_ImagesLoaded == m_NumTabs)
		{
			m_TabGroup.setSelectedButton(m_TabGroup.getButtonAt(0));
		}
	}
	
	private function onLoadError()
	{
		m_ImagesLoaded++;
		if (m_ImagesLoaded == m_NumTabs)
		{
			m_TabGroup.setSelectedButton(m_TabGroup.getButtonAt(0));
		}
	}
	
	private function TabChanged(button:Button):Void
	{
		var categoryNode:LoreNode = LoreNode(button.data);
		m_ItemList.dataProvider = categoryNode.m_Children;
		m_ItemList.invalidateData();
		RemoveFocus();
	}
	
	private function OnItemSelected(event:Object):Void
	{
		var loreNode:LoreNode = m_ItemList.dataProvider[m_ItemList.selectedIndex];
		SpellBase.CastEmoteFromTag(loreNode.m_Id);
	}
	
	private function RemoveFocus()
	{
		Selection.setFocus(null);
	}
}