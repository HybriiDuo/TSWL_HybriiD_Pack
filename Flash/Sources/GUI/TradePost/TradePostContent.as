﻿//Imports
import com.Utils.LDBFormat;
import gfx.controls.ButtonBar;
import gfx.core.UIComponent;
import GUI.TradePost.TradePostViewsContainer;
import com.Components.WindowComponentContent;
import com.GameInterface.Game.Character;
import com.GameInterface.Guild.*;
import com.GameInterface.Inventory;
import com.GameInterface.DistributedValue;
import com.Utils.ID32;

//Class
class GUI.TradePost.TradePostContent extends WindowComponentContent
{
    //Constants
    private static var BUY:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Buy");
    private static var POSTAL_SERVICE:String = LDBFormat.LDBGetText("GenericGUI", "TradePost_PostalService");
	private static var EXCHANGE:String = LDBFormat.LDBGetText("Tradepost", "Exchange");
    private static var SCROLL_WHEEL_SPEED:Number = 10;

    //Properties
    private var m_ButtonBar:ButtonBar;
    private var m_TabButtonArray:Array;
    private var m_ViewsContainer:MovieClip;
    private var m_ShowMailTabMonitor:DistributedValue;
    
    //Constructor
    public function TradePostContent()
    {
        super();
        
        enabled = false;
        
        m_ShowMailTabMonitor = DistributedValue.Create("show_mail_tab");
        m_ShowMailTabMonitor.SignalChanged.Connect(SlotShowMailTab, this);        
    }
    
    //Configure UI
	private function configUI():Void
    {
        super.configUI();

        var clientCharacter:Character = Character.GetClientCharacter();
        var isGM:Boolean = false;
        if (clientCharacter != undefined)
        {
            isGM = clientCharacter.GetStat(_global.Enums.Stat.e_GmLevel, 2) != 0;
        }
        
        m_TabButtonArray = new Array();        
        if ( com.GameInterface.Utils.GetGameTweak("TradePost_SellingEnabled") )
        {
            m_TabButtonArray.push( { label: BUY, view: TradePostViewsContainer.BUY_VIEW } );
        }
        if (com.GameInterface.Utils.GetGameTweak("Exchange_Disabled") == 0 || isGM)
        {
		    m_TabButtonArray.push( { label: EXCHANGE, view: TradePostViewsContainer.EXCHANGE_VIEW } );
        }
        m_TabButtonArray.push( { label: POSTAL_SERVICE, view: TradePostViewsContainer.POSTAL_SERVICE_VIEW } );  

        m_ButtonBar.addEventListener("focusIn", this, "RemoveFocus");
        m_ButtonBar.tabChildren = false;
        m_ButtonBar.itemRenderer = "TabButtonLight";
        m_ButtonBar.direction = "horizontal";
        m_ButtonBar.spacing = -5;
        m_ButtonBar.autoSize = "left";
        m_ButtonBar.dataProvider = m_TabButtonArray;
        m_ButtonBar.addEventListener("change", this, "SetSelectedContent");
        
        var buttonBarLine:MovieClip = m_ButtonBar.createEmptyMovieClip("buttonBarLine", m_ButtonBar.getNextHighestDepth());
        buttonBarLine.lineStyle(1, 0x656565, 100, true, "noScale");
        buttonBarLine.moveTo(0, 0);
        buttonBarLine.lineTo(_width, 0);
        buttonBarLine.endFill();
        buttonBarLine._y = Math.round(30);
        
        m_ViewsContainer.view = m_TabButtonArray[m_ButtonBar.selectedIndex].view;
        
        DistributedValue.SetDValue("show_mail_tab", false);
    }
    
    //Slot Show Mail Tab
    private function SlotShowMailTab():Void
    {
        var open:Boolean = DistributedValue.GetDValue("show_mail_tab")
        
        if (open)
        {
            DistributedValue.SetDValue("show_mail_tab", false);
            
            for (var i:Number = 0; i < m_TabButtonArray.length; ++i)
            {
                if ( m_TabButtonArray[i].view == TradePostViewsContainer.POSTAL_SERVICE_VIEW )
                {
                    m_ButtonBar.selectedIndex = i;
                    return;
                }
            }
        }
    }
    
    //Remove Focus
    private function RemoveFocus():Void
    {
        Selection.setFocus(null);
    }
    
    //Set Selected Content
    private function SetSelectedContent(event:Object):Void
    {
        m_ViewsContainer.view = m_TabButtonArray[event.index].view;
    }
    
    //Set Selected Index
    public function SetSelectedIndex(value:Number):Void
    {
        m_ButtonBar.selectedIndex = (m_TabButtonArray[value]) ? value : 0;
    }
    
    //Get Selected Index
    public function GetSelectedIndex():Number
    {
        return m_ButtonBar.selectedIndex;
    }
}