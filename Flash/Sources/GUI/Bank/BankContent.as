//Imports
import com.Utils.LDBFormat;
import gfx.controls.ButtonBar;
import gfx.core.UIComponent;
import GUI.Bank.BankViewsContainer;
import com.Components.WindowComponentContent;
import com.GameInterface.Game.Character;
import com.GameInterface.Guild.*;
import com.GameInterface.Inventory;
import com.GameInterface.DistributedValue;
import com.Utils.ID32;

//Class
class GUI.Bank.BankContent extends WindowComponentContent
{
    //Constants
    private static var STORE_AND_SELL:String = LDBFormat.LDBGetText("GenericGUI", "TradePost_StoreAndSell");
    private static var GUILD_BANK:String = LDBFormat.LDBGetText("GenericGUI", "TradePost_GuildBank");
    private static var SCROLL_WHEEL_SPEED:Number = 10;

    //Properties
    private var m_ButtonBar:ButtonBar;
    private var m_TabButtonArray:Array;
    private var m_ViewsContainer:MovieClip;
    
    //Constructor
    public function BankContent()
    {
        super();
        
        enabled = false;
            
        Guild.GetInstance().SignalCharacterLeftGuild.Connect(SlotGuildCharacterLeftCabal, this);
    }
    
    //Configure UI
	private function configUI():Void
    {
        super.configUI();
        
        m_TabButtonArray = new Array();
        m_TabButtonArray.push( { label: STORE_AND_SELL, view: BankViewsContainer.STORE_AND_SELL_VIEW } );       
        var inventory:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_GuildContainer, Character.GetClientCharID().GetInstance()));        
        if (GuildBase.HasGuild() && inventory.IsInitialized())
        {
            m_TabButtonArray.push( { label: GUILD_BANK, view: BankViewsContainer.GUILD_BANK_VIEW } );
        }

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
    }
    
    //Slot Guild Character Left Cabal
    private function SlotGuildCharacterLeftCabal(characterId:ID32):Void
    {
        if (Character.GetClientCharID().Equal(characterId))
        {
            var gotoView:Number = m_ButtonBar.selectedIndex;
            
            m_ViewsContainer.RemoveView(BankViewsContainer.GUILD_BANK_VIEW);
            
            configUI();
            
            if ( gotoView < m_TabButtonArray.length )
            {
                m_ButtonBar.selectedIndex = gotoView;
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