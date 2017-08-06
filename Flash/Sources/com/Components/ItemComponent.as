//import mx.core.UIComponent
import com.Utils.Colors;
import com.GameInterface.Log;
import mx.utils.Delegate;
import com.GameInterface.InventoryItem;

class com.Components.ItemComponent extends MovieClip
{
    
    private var DECORATION_STRIPES:Number = 0;
    private var DECORATION_CIRCLES:Number = 1;
    private var DECORATION_GRID:Number = 2;
    private var DECORATION_NONE:Number = 3;
	private var DECORATION_AEGIS:Number = 4;

    private var PLAIN:Number = 0;
    private var CHAKRA1:Number = 1;
    private var CHAKRA2:Number = 2;
    private var CHAKRA3:Number = 3;
    private var CHAKRA4:Number = 4;
    private var CHAKRA5:Number = 5;
    private var CHAKRA6:Number = 6;
    private var CHAKRA7:Number = 7;
	private var AEGIS1:Number = 8;
	private var AEGIS2:Number = 9;

    private var m_ItemShape:Number;
    private var m_StackSize:Number;
    private var m_Alpha:Number;
    private var m_Locked:Boolean;
    private var m_InventoryItem:InventoryItem;
    
    private var m_Content:MovieClip;
    private var m_Background:MovieClip;
	private var m_Stroke:MovieClip;
    private var m_Decoration:MovieClip;
   // private var m_OuterBorder:MovieClip;
    private var m_Glow:MovieClip;
    private var m_Icon:MovieClip;
    private var m_StackSizeClip:MovieClip;
	private var m_LevelClip:MovieClip;
    //private var m_CanNotUse:MovieClip;
    private var m_DurabilityBackground:MovieClip;
	private var m_Pips:MovieClip;
    
    private var m_BackgroundColor:Number;
    
	private var m_IconLoader:MovieClipLoader;
    
    private var m_StackSizeScale:Number;
	private var m_ShowCanUse:Boolean;
	
	private var m_CooldownIntervalID:Number;
	private var m_Increments:Number;
	private var m_ExpireTime:Number;
	private var m_HasCooldown:Boolean;
	private var m_TotalDuration:Number;
    private var m_CooldownTimer:MovieClip;
	private var m_CooldownTint:Number;
	
	private var m_IconLoadInterval:Number;
    
    public function ItemComponent()
    {
        super.init();
        Glow(false);
        
        m_StackSizeClip = undefined;
		m_LevelClip = undefined;
        
        m_StackSize = 0;
        m_Alpha = 100;
        m_Locked = false;
		m_IconLoadInterval = -1;
        
        m_StackSizeScale = 100;
		m_HasCooldown = false;
        
		var mclistener:Object = new Object();
		m_IconLoader  = new MovieClipLoader();
		m_IconLoader.addListener( mclistener );
		
		m_CooldownIntervalID = -1;
		m_Increments = 20;
		m_ExpireTime = 0;
		m_TotalDuration = 0;
		
		m_ShowCanUse = true;
		
    }
    
    public function PrintStats()
    {
        trace("ItemComponent rarity = " + m_InventoryItem.m_Rarity + " type = " + m_InventoryItem.m_ItemType);
    }
    
    public function SetData(inventoryItem:InventoryItem, iconLoadDelay:Number)
    {
        m_InventoryItem = inventoryItem;
       	
        SetType();
		SetLevel();
        SetRarity();
		SetPips();
		SetCanUse();
        SetColorLine();

		//Durability		
		if (m_DurabilityBackground != undefined)
		{
			m_DurabilityBackground.removeMovieClip();
			m_DurabilityBackground = undefined;
		}
        if (m_InventoryItem.m_MaxDurability > 0)
        {
            var iconBackgroundName:String = "";
            var iconID:String = "";
            if (m_InventoryItem.IsBroken())
            {
                iconBackgroundName = "DurabilityBroken";
                iconID = "rdb:1000624:7363471";
            }
            else if (m_InventoryItem.IsBreaking())
            {
                iconBackgroundName = "DurabilityBreaking";
                iconID = "rdb:1000624:7363472";
            }
            
            if (iconBackgroundName.length > 0)
            {
                m_DurabilityBackground = attachMovie(iconBackgroundName, "m_DurabilityBackground", getNextHighestDepth());
                m_DurabilityBackground._y = _height - 17;
                m_DurabilityBackground._x = -3;
                var container:MovieClip = m_DurabilityBackground.createEmptyMovieClip("m_Container", m_DurabilityBackground.getNextHighestDepth());
                     
                var imageLoader:MovieClipLoader = new MovieClipLoader();
                var imageLoaderListener:Object = new Object;
                imageLoaderListener.onLoadInit = function(target:MovieClip)
                {
                    target._x = 1;
                    target._y = 1;
                    target._xscale = 18;
                    target._yscale = 18;
                }
                
                imageLoader.addListener( imageLoaderListener );
                imageLoader.loadClip( iconID, container );      
            }
        }
		
		if (iconLoadDelay != undefined)
		{
			if (m_IconLoadInterval != -1)
			{
				clearInterval(m_IconLoadInterval);
				m_IconLoadInterval = -1;
			}
			m_IconLoadInterval = setInterval(Delegate.create(this, SetIcon), iconLoadDelay)
		}
		else
		{
			SetIcon();
		}
    }
    
    private function SetIcon() : Void
    {
        if (m_IconLoadInterval != -1)
		{
            clearInterval(m_IconLoadInterval);
            m_IconLoadInterval = -1;
        }
        
        var icon:com.Utils.ID32 = m_InventoryItem.m_Icon;
        
        if (icon != undefined && icon.GetType() != 0 && icon.GetInstance() != 0)
        {
            var iconString:String = com.Utils.Format.Printf( "rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance() );
			
            m_IconLoader.loadClip( iconString, m_Content );

            var w = m_Background._width - 4;
            var h = m_Background._height - 4;
            
            m_Content._xscale = w;
            m_Content._yscale = h;
            m_Content._x = 2;
            m_Content._y = 2;
            
            m_Icon = m_Content;
        }
    }
    
    private function SetRarity()
    {
		var color:Number = GetRarityColor();
		if (color > -1)
		{
			SetStrokeColor( color );
			if (m_LevelClip != undefined)
			{
				Colors.ApplyColor( m_LevelClip.m_Frame, color);
			}
		}
    }
	
	private function SetPips()
	{
		if (m_Pips != undefined)
		{
			m_Pips.removeMovieClip();
			m_Pips = undefined;
		}
		var numPips:Number = m_InventoryItem.m_Pips;
		if (numPips > 0)
		{
			m_Pips = attachMovie("Pips_"+numPips, "m_Pips", this.getNextHighestDepth());
			m_Pips._y = m_Background._y + m_Background._height - m_Pips._height - 2;
			m_Pips._x = m_Background._x + m_Background._width/2 - m_Pips._width/2;
		}
	}
	
	private function SetCanUse()
	{
		/*
		if (m_InventoryItem.m_CanUse != undefined && !m_InventoryItem.m_CanUse && m_ShowCanUse)
		{
            if ( m_CanNotUse == undefined )
            {
                m_CanNotUse = attachMovie("CannotUseIcon", "m_CanNotUse", getNextHighestDepth());	
            }
		}
        else if (m_CanNotUse != undefined)
        {
            m_CanNotUse.removeMovieClip();
            m_CanNotUse = undefined;
        }
		*/

	}
    
    private function GetRarityColor():Number
    {
        var color:Number = -1;
        switch(m_InventoryItem.m_Rarity)
        {
            case _global.Enums.ItemPowerLevel.e_Superior:
                color = Colors.e_ColorBorderItemSuperior;
				break;
            case _global.Enums.ItemPowerLevel.e_Enchanted:
                color = Colors.e_ColorBorderItemEnchanted;
				break;
            case _global.Enums.ItemPowerLevel.e_Rare:
                color = Colors.e_ColorBorderItemRare;
				break;
			case _global.Enums.ItemPowerLevel.e_Epic:
                color = Colors.e_ColorBorderItemEpic;
				break;
			case _global.Enums.ItemPowerLevel.e_Legendary:
                color = Colors.e_ColorBorderItemLegendary;
				break;
			case _global.Enums.ItemPowerLevel.e_Red:
                color = Colors.e_ColorBorderItemRed;
				break;
        }
        return color;
    }
    
    private function SetType()
    {
        switch(m_InventoryItem.m_ItemType)
        {
            case _global.Enums.ItemType.e_ItemType_CraftingItem:
                SetTypeCrafting();
            break;
            case _global.Enums.ItemType.e_ItemType_MissionItem:
                SetTypeMission();
            break;
            case _global.Enums.ItemType.e_ItemType_MissionItemConsumable:
                SetTypeMissionUsable();
            break;
            case _global.Enums.ItemType.e_ItemType_Weapon:
                SetTypeWeapons();
            break;
            case _global.Enums.ItemType.e_ItemType_Chakra:
                SetTypeChakras()
            break;
			case _global.Enums.ItemType.e_ItemType_Gadget:
				SetTypeGadget();
			break;
            case _global.Enums.ItemType.e_ItemType_Consumable:
                SetTypeConsumable();
            break;
			
			case _global.Enums.ItemType.e_ItemType_AegisWeapon:
			case _global.Enums.ItemType.e_ItemType_AegisShield:
			case _global.Enums.ItemType.e_ItemType_AegisGeneric:
			case _global.Enums.ItemType.e_ItemType_AegisSpecial:
				SetTypeAegis();
			break;
            case    _global.Enums.ItemType.e_ItemType_None:
                    default:
                SetTypeNone();

        }
    }
    
    
    private function SetColorLine()
    {
        var colorObject:Object = Colors.GetColorlineColors( m_InventoryItem.m_ColorLine );
        
        Colors.ApplyColor( m_Background.background, colorObject.background);
        Colors.ApplyColor(m_Background.highlight, colorObject.highlight);
        
    }
    

    
    /// iterates the stroke array and the background array setting the correct viaibility.
    /// after settingt this we can manuipulate a single m_Background and m_Stroke for this item
    /// @param index:Number - the type (position in array) of icon to set visible
    private function SetItemShape( index:Number )
    {
        m_ItemShape = index;		
		var strokeName:String = "ItemStroke_Plain";
		var backgroundName:String = "ItemBackground_Plain";
		switch(m_ItemShape)
		{
			case CHAKRA1:		strokeName = "ItemStroke_Chakra1";
								backgroundName = "ItemBackground_Chakra1";
								break;
			case CHAKRA2:		strokeName = "ItemStroke_Chakra2";
								backgroundName = "ItemBackground_Chakra2";
								break;
			case CHAKRA3:		strokeName = "ItemStroke_Chakra3";
								backgroundName = "ItemBackground_Chakra3";
								break;
			case CHAKRA4:		strokeName = "ItemStroke_Chakra4";
								backgroundName = "ItemBackground_Chakra4";
								break;
			case CHAKRA5:		strokeName = "ItemStroke_Chakra5";
								backgroundName = "ItemBackground_Chakra5";
								break;
			case CHAKRA6:		strokeName = "ItemStroke_Chakra6";
								backgroundName = "ItemBackground_Chakra6";
								break;
			case CHAKRA7:		strokeName = "ItemStroke_Chakra7";
								backgroundName = "ItemBackground_Chakra7";
								break;
			case AEGIS1:		strokeName = "ItemStroke_Aegis1";
								backgroundName = "ItemBackground_Aegis1";
								break;
			case AEGIS2:		strokeName = "ItemStroke_Aegis2";
								backgroundName = "ItemBackground_Aegis2";
								break;
		}
		
		if (m_Background != undefined)
		{
			m_Background.removeMovieClip();
			m_Background = undefined;
		}
		m_Background = this.attachMovie(backgroundName, "m_Background", getNextHighestDepth());
		
		if (m_Stroke != undefined)
		{
			m_Stroke.removeMovieClip();
			m_Stroke = undefined;
		}
		m_Stroke = this.attachMovie(strokeName, "m_Stroke", getNextHighestDepth());
		
		m_Content.swapDepths(getNextHighestDepth());
		if (m_StackSizeClip != undefined)
		{
			m_StackSizeClip.swapDepths(getNextHighestDepth());
		}
		if (m_LevelClip != undefined)
		{
			m_LevelClip.swapDepths(getNextHighestDepth());
		}
    }
	public function SetShowCanUse(show:Boolean)
	{
		m_ShowCanUse = show;
	}
	
    public function SetStackSize(stackSize:Number)
    {
        m_StackSize = stackSize;
        
        if (m_StackSize > 1)
        {
            if (m_StackSizeClip == undefined)
            {
                m_StackSizeClip = attachMovie("_BuffCharge", "m_StackSizeClip", getNextHighestDepth(), { _x:_width, _y:_height, _xscale:m_StackSizeScale, _yscale:m_StackSizeScale } );
            }

            m_StackSizeClip.SetMax(m_StackSize);
            m_StackSizeClip.SetCharge(m_StackSize);
        }
        else
        {
            if (m_StackSizeClip != undefined)
            {
                m_StackSizeClip.removeMovieClip();
                m_StackSizeClip = undefined;
            }
        }
    }
	
	public function SetLevel()
	{
		var level = m_InventoryItem.m_Rank;
		
		//We don't show level 1 items because everything is level 1 and that is too much clutter.
		//Level 1 items are, for the most part, breakdown trash
		if (level > 1 && ShouldShowLevel())
		{
			if (m_LevelClip == undefined)
			{
				m_LevelClip = attachMovie("LevelBadge", "m_LevelClip", getNextHighestDepth());
				m_LevelClip._x = -5;
				m_LevelClip._y = -5;
			}
			m_LevelClip.m_TextField.text = level;
		}
		else
		{
			if (m_LevelClip != undefined)
			{
				m_LevelClip.removeMovieClip();
				m_LevelClip = undefined;
			}
		}
	}
	
	private function ShouldShowLevel():Boolean
	{
		return (m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_Generated_Prefix_NonWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_Generated_Suffix_NonWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_Generated_Core_NonWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_ShotgunWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_HandgunWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_AssaultRifleWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_FocusItem_Jinx ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_FocusItem_Fire ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_FocusItem_Death ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_BladeWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_HammerWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_FistWeapon ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_RocketLauncher ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_Whip ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_Quantum ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_Chainsaw ||
				m_InventoryItem.m_RealType == _global.Enums.ItemType.e_Type_GC_Item_TSW_Flamethrower);
	}
    
    public function SetStackSizeScale(scale:Number)
    {
        m_StackSizeScale = scale;
        m_StackSizeClip._xscale = m_StackSizeClip._yscale = m_StackSizeScale;
    }
    
    public function SetAlpha(alpha:Number)
    {
        m_Alpha = alpha;
        if (!m_Locked)
        {
            _alpha = m_Alpha;
        }
    }

    public function GetAlpha() : Number
    {
        return (m_Locked) ? 30 : m_Alpha;
    }
    
    public function SetLocked(locked:Boolean)
    {
        m_Locked = locked
        _alpha = (m_Locked) ? 30 : m_Alpha;
    }
    

    
    public function Glow(glow:Boolean)
    {
        m_Glow._visible = glow;
        var scale:Number = (glow ? 69 : 35);
    }
    
    public function SetThrottle(throttle:Boolean)
    {
        var color:Number = GetRarityColor();
        if (color == -1)
        {
            color = 0xFFFFFF;
        }
        var throttleSpeed:Number = (arguments.length > 1) ? arguments[1] : 20; // time it takes for a throttle to complete in secounds
        m_Background.m_Color = (arguments.length > 2) ? arguments[2] : color;        
        if (throttle)
        {
            m_Background.m_Increase = true;
            m_Background.m_CurrentBlend = 0;
            /// method for the throttle
            m_Background.Throttle = function()
            {
                if (this.m_Increase)
                {
                    this.m_CurrentBlend += 2;
                    if (this.m_CurrentBlend >= 100)
                    {
                        this.m_Increase = false;
                    }
                }
                else
                {
                    this.m_CurrentBlend -= 2;
                    if (this.m_CurrentBlend <= 0)
                    {
                        this.m_Increase = true;
                    }
                }
                com.Utils.Colors.Tint(this, this.m_Color, this.m_CurrentBlend);
            }
            
            // execute
            m_Background.m_IntervalId = setInterval( m_Background, "Throttle", throttleSpeed);
           
        }
        else
        {
            if (!isNaN( m_Background.m_IntervalId))
            {
                clearInterval( m_Background.m_IntervalId );
            }
            
            if (m_Background.Throttle != undefined)
            {
                m_Background.Throttle = undefined;
                com.Utils.Colors.Tint(m_Background, m_Background.m_Color, 0);
            }
        }
    }
    
    public function HasThrottle()
    {
        return (m_Background.Throttle != undefined && !isNaN( m_Background.m_IntervalId))
      
    } 
    /*
    public function SetOuterBorderColor(color:Number):Void
    {
     //   Colors.ApplyColor(m_OuterBorder, color);
    }
    
    private function SetNoBorderColor()
    {
        if (m_InventoryItem.m_ItemType != _global.Enums.ItemType.e_ItemType_MissionItem || m_InventoryItem.m_ItemType != _global.Enums.ItemType.e_ItemType_MissionItemConsumable)
        {
            m_Stroke._visible = false;
        }
    }
 
    private function SetBorderColor(color:Number)
    {
        
       /* 
        if ( m_InventoryItem.m_ItemType == _global.Enums.ItemType.e_ItemType_Chakra )
		{
			m_InnerBorder._visible = false;
			
			for (var i:Number = 1; i <= 7; i++)
			{
				Colors.ApplyColor(this["m_Chakra"+i].m_Stroke, color);
			}
			
		}
		else
		{
			m_InnerBorder._visible = true;
			Colors.ApplyColor(m_InnerBorder, color);
		}
    }
    */
    private function SetDecoration(index:Number)
    {
		var decorationName:String = "";
		var decorationX:Number = 0;
		var decorationY:Number = 0;
		switch(index)
		{
			case DECORATION_STRIPES:		decorationName = "ItemStripes";
											decorationX = 2;
											decorationY = 2;
											break;
			case DECORATION_CIRCLES:		decorationName = "ItemCircles";
											decorationX = 2;
											decorationY = 2;
											break;
			case DECORATION_GRID:			decorationName = "ItemGrid";
											decorationX = 4;
											decorationY = 4;
											break;
			case DECORATION_NONE:			decorationName = "";
											break;
			case DECORATION_AEGIS:			decorationName = "ItemPattern_hexa";
											decorationX = 0;
											decorationY = 0;
											break;
		}
		
		if (m_Decoration != undefined)
		{
			m_Decoration.removeMovieClip();
			m_Decoration = undefined;
		}
		if (decorationName != "")
		{
			m_Decoration = this.attachMovie(decorationName, "m_Decoration", getNextHighestDepth());
			m_Decoration._x = decorationX;
			m_Decoration._y = decorationY;
		}
    }
    
    private function SetBackgroundColor(color:Number)
    {
        Colors.ApplyColor( m_Background, color);
    }
    
    private function SetStrokeColor(color:Number)
    {
        m_Stroke._visible = true;
        Colors.ApplyColor( m_Stroke, color);
    }
    
    private function SetTypeCrafting()
    {
        SetItemShape( PLAIN );
		m_Stroke._visible = false;
        SetDecoration( DECORATION_NONE  );
    }
    
    private function SetTypeMission()
    {
        SetItemShape( PLAIN );        
        SetStrokeColor( Colors.e_ColorBorderItemMission );
        SetDecoration( DECORATION_NONE  );
    }

    private function SetTypeMissionUsable()
    {
        SetItemShape( PLAIN );
        SetBackgroundColor( Colors.e_ColorItemTypeMissionUsable )
        SetStrokeColor( Colors.e_ColorBorderItemMissionUsable );
        SetDecoration( DECORATION_NONE  );
    }
    
    private function SetTypeWeapons()
    {
        SetItemShape( PLAIN );
        //SetDecoration( DECORATION_STRIPES  );
    }
    
    private function SetTypeChakras()
    {
        switch(  m_InventoryItem.m_DefaultPosition )
        {
            case _global.Enums.ItemEquipLocation.e_Chakra_1:
                SetItemShape( CHAKRA1  );
            break;
            case _global.Enums.ItemEquipLocation.e_Chakra_2:
                SetItemShape( CHAKRA2  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_3:
                SetItemShape( CHAKRA3  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_4:
                SetItemShape( CHAKRA4  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_5:
                SetItemShape( CHAKRA5  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_6:
                SetItemShape( CHAKRA6  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_7:
                SetItemShape( CHAKRA7  );
            break;
        }
        SetDecoration( DECORATION_NONE );
    }
	
    private function SetTypeConsumable()
    {
        SetItemShape( PLAIN );
		m_Stroke._visible = false;
        SetDecoration( DECORATION_NONE  );
    }
	
	private function SetTypeGadget()
	{
		SetItemShape(AEGIS2);
		//SetDecoration(DECORATION_AEGIS);
	}
	
	private function SetTypeAegis()
	{
		switch(m_InventoryItem.m_ItemType)
		{
			case _global.Enums.ItemType.e_ItemType_AegisWeapon:
				SetItemShape( PLAIN );
				break;
			case _global.Enums.ItemType.e_ItemType_AegisShield:
				SetItemShape( CHAKRA7 );
				break;
			case _global.Enums.ItemType.e_ItemType_AegisGeneric:
				SetItemShape( AEGIS2 );
				break;
			case _global.Enums.ItemType.e_ItemType_AegisSpecial:
				SetItemShape( AEGIS1 );
				break;
		}
		SetDecoration( DECORATION_AEGIS );
	}
    
    private function SetTypeNone()
    {
        SetItemShape( PLAIN );
		m_Stroke._visible = false;
        SetDecoration( DECORATION_NONE  );
    }
	
	public function UnloadIcon()
	{
		clearInterval( m_CooldownIntervalID );		
		m_IconLoader.unloadClip(m_Icon);
	}
    
    public function GetIcon(): MovieClip
    {
        return m_Icon;
    }
	
	public function SetCooldown( cooldownEnd:Number, cooldownStart, showTimer:Boolean)
	{
		if (m_HasCooldown)
		{
			RemoveCooldown();
		}
		
		m_HasCooldown = true;
		        
        m_TotalDuration = cooldownEnd - cooldownStart;
        m_ExpireTime = cooldownEnd;
              		
		if (showTimer)
		{
			m_CooldownTimer = attachMovie( "CooldownTimer", "cooldown", getNextHighestDepth() );
		}
		
		m_CooldownIntervalID = setInterval(this,  "UpdateTimer", m_Increments);
	}
	
    public function RemoveCooldown()
    {
        clearInterval( m_CooldownIntervalID );
		if (m_CooldownTimer != undefined)
		{
			m_CooldownTimer.removeMovieClip();
			m_CooldownTimer = undefined
		}
		m_HasCooldown = false;
		Colors.Tint(m_Background, 0x000000, 0);
		Colors.Tint(m_Icon, 0x000000, 0);
    }
	
	/// Method that updates
	private function UpdateTimer() : Void
	{
		var timeLeft:Number = m_ExpireTime - com.GameInterface.Utils.GetGameTime();

        if ( timeLeft > 0 )
        {
			if (m_TotalDuration > 0)
			{
				var percentage:Number = timeLeft / m_TotalDuration;
				var tint:Number = Math.round(10  + percentage * 80);
				if (tint != m_CooldownTint)
				{
					m_CooldownTint = tint;
				}
				Colors.Tint(m_Background, 0x000000, tint);
				Colors.Tint(m_Icon, 0x000000, tint);
			}
            if (m_CooldownTimer != undefined)
            {
				var hours:Number = Math.floor(timeLeft / 3600);
				var minutes:Number = Math.floor(timeLeft / 60 % 60);
				var seconds:Number = Math.floor(timeLeft) % 60;
				if (hours > 0)
				{
					m_CooldownTimer.ms_txt.text = com.Utils.Format.Printf( "%02.0f:%02.0f:%02.0f", hours, minutes, seconds);
				}
				else
				{
					m_CooldownTimer.ms_txt.text = com.Utils.Format.Printf( "%02.0f:%02.0f", minutes, seconds);
				}
            }
        }
        else
		{
            clearInterval( m_CooldownIntervalID );
			RemoveCooldown();
				
		}
	}    
}
