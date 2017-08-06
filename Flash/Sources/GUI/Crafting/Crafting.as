import com.Utils.ID32;
import com.GameInterface.DistributedValue;
import com.GameInterface.Inventory
import com.GameInterface.CraftingInterface;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.Game.Character;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.Utils.Archive;

var m_Inventory:Inventory;

var m_ScaleMonitor:DistributedValue;

var m_NumRows:Number;
var m_NumColumns:Number;
var m_SkinName:String;
var m_SlotPadding:Number;

var m_CraftingSkin:MovieClip;
var m_Borders:Rectangle;

var m_ConfigName:String;

function onLoad()
{
    m_ConfigName = "CraftingWindowConfig";
    m_Borders = new Rectangle();
    
	m_ScaleMonitor = DistributedValue.Create( "GUIScaleInventory" );
	m_ScaleMonitor.SignalChanged.Connect(SlotScaleChanged, this);
	
	m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( LayoutHandler, this );
    m_Inventory = undefined;
        
	    
    m_NumRows = 4;
    m_NumColumns = 4;
    m_SkinName = "ItemUpgradeSkin";
    m_SlotPadding = 10;
	
    
    CraftingInterface.SignalCraftingResultFeedback.Connect(SlotCraftingResultFeedback, this);
	
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
	
	moduleIF.SignalStatusChanged.Connect( SlotModuleStatusChanged, this );
	SlotModuleStatusChanged( moduleIF, moduleIF.IsActive() );

	LayoutHandler();
}

function OnUnload()
{
    SaveConfig();
	if (m_CraftingSkin != undefined)
	{
		m_CraftingSkin.Unload();
		m_CraftingSkin.removeMovieClip();
		m_CraftingSkin = undefined;
	}
}

function LayoutHandler()
{
    var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
    _x = visibleRect.x;
    _y = visibleRect.y;
    
    CapPosition();
}

function SlotScaleChanged()
{
	if (m_CraftingSkin != undefined)
	{
		m_CraftingSkin._xscale = m_ScaleMonitor.GetValue();
		m_CraftingSkin._yscale = m_ScaleMonitor.GetValue();
	}
}


function CapPosition()
{
	if (m_CraftingSkin != undefined)
	{
		m_Borders.left = -m_CraftingSkin._width + 30;
		m_Borders.top = -m_CraftingSkin._height + 30;
		m_Borders.right =  Stage.width  * (100 / _xscale) - 30;
		m_Borders.bottom = Stage.height * (100 / _yscale) - 30;
		
		m_CraftingSkin._x = Math.max(m_Borders.left, m_CraftingSkin._x);
		m_CraftingSkin._x = Math.min(m_Borders.right, m_CraftingSkin._x);
		m_CraftingSkin._y = Math.max(m_Borders.top, m_CraftingSkin._y);
		m_CraftingSkin._y = Math.min(m_Borders.bottom, m_CraftingSkin._y);
	}
}

function SlotModuleStatusChanged( module:GUIModuleIF, isActive:Boolean )
{
    if (!isActive)
	{
		CloseCrafting();
	}
}

function LoadArgumentsReceived ( args:Array ) : Void
{
    var skin:String = args[0];
    var rows:Number = args[1];
    var cols:Number = args[2];
    var padding:Number = args[3];
	var inventoryId:Number = args[4];
    if (skin != undefined)
    {
        m_SkinName = skin;
    }
    
    var m_CraftingSkin:MovieClip = attachMovie(m_SkinName, "m_CraftingSkin", getNextHighestDepth());
	m_CraftingSkin._x = _x + (Stage.width / 2) - (m_CraftingSkin._width / 2);
	m_CraftingSkin._y = _y + (Stage.height / 2) - (m_CraftingSkin._height / 2);
	
    if (rows != undefined)
    {
        m_NumRows = rows;
    }
    if (cols != undefined)
    {
        m_NumColumns = cols;
    }
    if (padding != undefined)
    {
        m_SlotPadding = padding;
    }
	if (inventoryId != undefined)
	{
		m_Inventory = new Inventory(new ID32(inventoryId, Character.GetClientCharID().GetInstance()));
	}
	else
	{
		//Default to the regular crafting inventory
		m_Inventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_CraftingInventory, Character.GetClientCharID().GetInstance()));
	}
	
	m_CraftingSkin.SetNumColumns(m_NumColumns);
	m_CraftingSkin.SetNumRows(m_NumRows);
	m_CraftingSkin.SetSlotPadding(m_SlotPadding);
	m_CraftingSkin.SetInventory(m_Inventory);
	
	m_CraftingSkin.SignalClose.Connect(SlotCloseCrafting);
	m_CraftingSkin.SignalClear.Connect(SlotResetCraftingGUI);
	m_CraftingSkin.SignalStartCraft.Connect(SlotStartCrafting);
	m_CraftingSkin.SignalStartDisassembly.Connect(SlotStartDisassembly);
	m_CraftingSkin.SignalStartDrag.Connect(SlotStartDrag);
	m_CraftingSkin.SignalStopDrag.Connect(SlotStopDrag);
	
    m_CraftingSkin.InitializeItemSlots();
	
	CraftingInterface.SetDisassemblySlot(m_CraftingSkin.GetDisassemblySlot());	
    
    LoadConfig();
	
	LayoutHandler();
	SlotScaleChanged()
}

function LoadConfig()
{
    var config:Archive = DistributedValue.GetDValue(m_ConfigName, undefined)
    if (config != undefined)
    {
        var position:Point = config.FindEntry("Position", undefined);
        if (position != undefined && m_CraftingSkin != undefined)
        {
            m_CraftingSkin._x = position.x;
            m_CraftingSkin._y = position.y;
        }
    }
}

function SaveConfig()
{
    var config:Archive = new Archive();
    config.AddEntry("Position", new Point(m_CraftingSkin._x, m_CraftingSkin._y));
    DistributedValue.SetDValue(m_ConfigName, config);
}

function SlotStartCrafting()
{
	CraftingInterface.StartCrafting(m_Inventory.m_InventoryID.GetType());
}

function SlotStartDisassembly()
{
	CraftingInterface.StartDisassembly(m_Inventory.m_InventoryID.GetType());
}

function SlotCloseCrafting()
{
	SlotResetCraftingGUI();
	CraftingInterface.CloseCrafting();
	CloseSplitItemPopup();
}

function SlotResetCraftingGUI()
{
	CraftingInterface.EndCrafting();
}

function SlotStartDrag()
{
    m_CraftingSkin.startDrag(false, m_Borders.left,m_Borders.top, m_Borders.right, m_Borders.bottom);
}

function SlotStopDrag()
{
    m_CraftingSkin.stopDrag();
}

function SlotCraftingResultFeedback(result:Number, numItems:Number, feedback:String, items:Array, percentChance:Number)
{
	if (m_CraftingSkin != undefined)
	{
		if (percentChance == undefined)
		{
			percentChance = 100;
		}
		m_CraftingSkin.CraftingResultFeedback(result, numItems, feedback, items, percentChance);
	}
}

function onUnload()
{
	SlotCloseCrafting();
}

