//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.Utils.Archive;
import com.Utils.LDBFormat;
import GUI.Team.TeamMember;
import flash.geom.Point;

//Class
class GUI.Team.DefensiveMenu extends MovieClip
{
    //Properties
    private var m_TeamMember:TeamMember;
    
    private var m_MenuItems:Array;
	private var m_LockDefensiveWindow:Boolean;
	
	private var m_LockDefensiveWindowText:String;
    
    private var m_LastClicked:String;
    private var m_CurrentClicked:String;
    
    //Constructor
    public function DefensiveMenu()
    {
        super();
        
        Mouse.addListener(this);
        Key.addListener(this);

        var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
        escapeNode.SignalEscapePressed.Connect(RemoveMenu, this);
		Character.SignalCharacterEnteredReticuleMode.Connect(RemoveMenu, this);
        
        com.GameInterface.EscapeStack.Push(escapeNode);
    }
    
    //Initialize
    public function Initialize():Void
    {        
        m_MenuItems = [];
		
		m_MenuItems.push({ name: m_LockDefensiveWindowText, callback: "ToggleLockDefensiveWindow", enabled:true });
        
        DrawMenu(m_MenuItems, 0, 0);
    }
    
    //Draw Menu
    private function DrawMenu(items:Array, y:Number, depth:Number):Void
    {
        if (this["menu_" + depth] != undefined)
        {
            this["menu_" + depth].removeMovieClip();
            
            if (m_CurrentClicked == m_LastClicked)
            {
                return;
            }
        }
        
        var menu:MovieClip = this.createEmptyMovieClip("menu_" + depth, this.getNextHighestDepth());
        menu.attachMovie("TeamMenuBackground", "m_Background", menu.getNextHighestDepth());
        
        var ypos:Number = 5;
        var maxWidth:Number = 0;

        for (var i:Number = 0; i < items.length; i++ )
        {
            var menuItem:Object = items[i];
            var renderer:MovieClip = menu.attachMovie("TeamMenuItemRenderer", "renderer_" + i, menu.getNextHighestDepth());
            
            renderer.m_Background._alpha = 0;
            renderer._x = 4;
            renderer._y = ypos;
            renderer.m_Name.autoSize = "left"
            renderer.m_Name.text = menuItem.name;
            renderer.callback = menuItem.callback;
            renderer.args = menuItem.args
            renderer.depth = depth;
            renderer.ref = this;
            
            maxWidth = Math.max(maxWidth, renderer.m_Name._width);
            
            if (menuItem.children == undefined)
            {
                renderer.m_LeftArrow._visible = false;
                renderer.m_RightArrow._visible = false;
            }
            else
            {
				renderer.m_LeftArrow._visible = false;
				renderer.m_RightArrow._visible = true;
            }
            
            if (menuItem.enabled == true)
            {
                renderer.onRollOver = function()
                {
                    this.m_Background._alpha = 100;
                    
                    if (this["m_LeftArrow"]._visible || this["m_RightArrow"]._visible)
                    {
                        this["ref"].m_CurrentClicked = this["m_Name"]
                        this["ref"][this["callback"]](this["args"]);
                    }
                    else
                    {
                        var newClip:MovieClip = this["ref"]["menu_" + (Number(this["depth"]) + 1)];
                        if (newClip != undefined)
                        {
                            newClip.removeMovieClip();
                        }
                    }
                }

                renderer.onRollOut = function()
                {
                    if (this["m_LeftArrow"]._visible || this["m_RightArrow"]._visible)
                    {
                        var newClip:MovieClip = this["ref"]["menu_" + (Number(this["depth"]) + 1)];
                               
                        if ((_xmouse < -newClip._width && _xmouse >= 0) && (_ymouse < -1 && _ymouse >= newClip._height))
                        {
                            this["ref"][this["callback"]](this["args"]);
                        }
                    }
                    
                    this.m_Background._alpha = 0;
                }
                
                renderer.onRelease = function()
                {
                    this["ref"].m_CurrentClicked = this["m_Name"]
                    this["ref"][this["callback"]](this["args"]);
                }
            }
            else
            {
                renderer.m_Name._alpha = 60;
            }
            
            menuItem.ypos = ypos;
            ypos += renderer._height + 2;
        }

        for (var i:Number = 0; i < items.length; i++)
        {
            var renderer:MovieClip = this["menu_" + depth]["renderer_" + i];
            
            renderer.m_Background._xscale = maxWidth + 41;
            
			renderer.m_Name._x = 10;
			renderer.m_RightArrow._x = renderer.m_Background._width - renderer.m_RightArrow._width - 8;
        }
        
        menu.m_Background._height = ypos + 4;
        menu.m_Background._width = maxWidth + 50;
        
        var xpos:Number = 0;              
        
		for (var i:Number = 0; i < depth; i++)
		{
			xpos += this["menu_" + i]._width + 1;
		}
        
        menu._x = xpos
        menu._y = y;
        
        m_LastClicked = m_CurrentClicked;
    }
    
    //On Mouse Up
    private function onMouseUp():Void
    {
        if (!this.hitTest(_root._xmouse, _root._ymouse) && m_TeamMember.MissedButton())
        {
            RemoveMenu();
        }
    }
    
    //Remove Menu
    public function RemoveMenu():Void
    {   
		m_TeamMember.DefensiveMenuClosed();
        this.removeMovieClip();
    }
        
    
    //Open Sub Menu
    private function OpenSubMenu(index):Void
    {
        var menuItem:Object = m_MenuItems[index]
        var itemArray:Array = menuItem.children;
        var itemY:Number = menuItem.ypos;
        
        DrawMenu(itemArray, itemY, 1);   
    }
	
	private function ToggleLockDefensiveWindow()
	{
		m_LockDefensiveWindow = !m_LockDefensiveWindow;
        m_TeamMember.LockDefensiveWindow(m_LockDefensiveWindow);
        RemoveMenu();
	}
	
	public function SetLockDefensiveWindow(value:Boolean):Void
    {
        m_LockDefensiveWindow = value;
        m_LockDefensiveWindowText = (m_LockDefensiveWindow ? LDBFormat.LDBGetText("TeamGUI", "UnlockDefensiveWindow") : LDBFormat.LDBGetText("TeamGUI", "LockDefensiveWindow"));
    }
	
}