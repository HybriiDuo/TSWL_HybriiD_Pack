import gfx.core.UIComponent;
import mx.utils.Delegate;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.Utils.ID32;

class GUI.HUD.GadgetSlot extends UIComponent
{
	//Components in .fla
	private var m_Content:MovieClip;
	private var m_Gloss:MovieClip;
	private var m_GlossMask:MovieClip;
	private var m_CooldownLine:MovieClip;
	private var m_CooldownMask:MovieClip;
	private var m_BGMask:MovieClip;
	private var m_UseBG:MovieClip;
	private var m_NoUseBG:MovieClip;
	
	//Variables
	private var m_MovieClipLoader:MovieClipLoader;
	private var m_Inventory:Inventory;
	private var m_GadgetItem:InventoryItem;
	private var m_Icon:MovieClip;
	
	private var m_HasCooldown:Boolean;
	private var m_CooldownIntervalID:Number;
	private var m_TotalCooldownDuration:Number;
	private var m_CooldownExpireTime:Number;
	private var m_CooldownTimer:MovieClip;
	
	private var m_Tooltip:TooltipInterface;
	private var m_TooltipTimeout:Number;
	
	
	public function GadgetSlot()
	{
		m_Gloss.setMask(m_GlossMask);
		m_CooldownLine.setMask(m_CooldownMask);
		m_UseBG.setMask(m_BGMask);
		m_MovieClipLoader = new MovieClipLoader();
		m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharID().GetInstance()));
		m_Inventory.SignalItemCooldown.Connect(SlotItemCooldown, this);
    	m_Inventory.SignalItemCooldownRemoved.Connect(SlotItemCooldownRemoved, this);
		m_Inventory.SignalItemAdded.Connect(SlotItemAdded, this);
		m_Inventory.SignalItemLoaded.Connect(SlotItemAdded, this);
		m_Inventory.SignalItemRemoved.Connect(SlotItemRemoved, this);
		
		SetData(m_Inventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Aegis_Talisman_1));
	}
	
	public function SetData(item:InventoryItem):Void
	{
		ClearData();
		if (item == undefined)
		{
			return;
		}
		
		m_GadgetItem = item;
		m_UseBG._visible = true;
		m_Gloss._visible = true;
		com.Utils.Colors.Tint(m_NoUseBG, 0x000000, 0);
		if( m_GadgetItem.m_Icon != undefined && m_GadgetItem.m_Icon != "" )
		{
			SetIcon(com.Utils.Format.Printf( "rdb:%.0f:%.0f", m_GadgetItem.m_Icon.GetType(), m_GadgetItem.m_Icon.GetInstance() ));
		}
		if (item.m_CooldownEnd != undefined && item.m_CooldownEnd > 0 && (item.m_CooldownEnd - com.GameInterface.Utils.GetGameTime()) > 0)
		{
			if (item.m_CooldownStart == undefined)
			{
				var cooldownStart:Number = com.GameInterface.Utils.GetGameTime();
				var cooldownEnd:Number = cooldownEnd = cooldownStart + cooldownEnd;
				SetCooldown(cooldownEnd, cooldownStart);
			}
			else
			{
				SetCooldown(item.m_CooldownEnd, item.m_CooldownStart);
			}
		}
	}
	
	private function ClearData():Void
	{
		m_GadgetItem = undefined;
		m_UseBG._visible = false;
		m_Gloss._visible = false;
		com.Utils.Colors.Tint(m_NoUseBG, 0x000000, 60);
		if (m_Icon != undefined)
		{
			m_Icon.removeMovieClip(m_Icon);
			m_Icon = undefined;
		}
		RemoveCooldown();
	}
	
	private function SetIcon(itemIcon:String):Void
	{
        if (m_Icon == undefined)
        {
            m_Icon = m_Content.createEmptyMovieClip("m_Icon", m_Content.getNextHighestDepth());
        }
        
        var isLoaded:Boolean = m_MovieClipLoader.loadClip( itemIcon, m_Icon );
        m_Icon._xscale = m_UseBG._width;
        m_Icon._yscale = m_UseBG._height;
	}
	
	private function SetCooldown( cooldownEnd:Number, cooldownStart:Number)
	{
		if (m_HasCooldown)
		{
			RemoveCooldown();
		}
		
		m_HasCooldown = true;
		m_Gloss._visible = false;
		m_CooldownLine._visible = true;
		m_Content._alpha = 75;
        m_TotalCooldownDuration = cooldownEnd - cooldownStart;
        m_CooldownExpireTime = cooldownEnd;
		
		m_CooldownTimer = this.attachMovie( "cooldown_template_gadget", "cooldown", this.getNextHighestDepth() );
		m_CooldownTimer._x = m_UseBG._width/2 - m_CooldownTimer._width /2;
		m_CooldownTimer._y = 2;
		m_CooldownIntervalID = setInterval(this,  "UpdateTimer", 20);
	}
	
	private function RemoveCooldown()
    {
		if (m_GadgetItem != undefined)
		{
			m_Gloss._visible = true;
		}
		m_CooldownLine._visible = false;
		m_Content._alpha = 100;
		if (m_CooldownTimer != undefined)
		{
			m_CooldownTimer.removeMovieClip();
			m_CooldownTimer = undefined;
		}
        if (m_CooldownIntervalID != undefined)
		{
			clearInterval(m_CooldownIntervalID)
			m_CooldownIntervalID = undefined;
		}
		m_HasCooldown = false;
    }
	
	private function onMouseDown()
	{
		if (this.hitTest(_root._xmouse, _root._ymouse))
        {
			onRollOut();
		}
	}
	
	private function onMouseUp()
	{
		if (this.hitTest(_root._xmouse, _root._ymouse))
        {
			m_Inventory.UseItem(_global.Enums.ItemEquipLocation.e_Aegis_Talisman_1);
		}
	}
	
	private function onRollOver() : Void
	{
		if (m_GadgetItem != undefined)
		{
			StartTooltipTimeout();
		}
	}
	
	private function onRollOut() : Void
	{
		StopTooltipTimeout();
		if (m_Tooltip != undefined)
		{
			CloseTooltip();
		}
	}
	
	private function onDragOut() : Void
	{
		onRollOut();
	}
	
	private function StartTooltipTimeout()
	{
		if (m_TooltipTimeout != undefined)
		{
			return;
		}
		var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelay");
		if (delay == 0)
		{
			OpenTooltip();
			return;
		}
		m_TooltipTimeout = _global.setTimeout( Delegate.create( this, OpenTooltip ), delay*1000 );
	}
	
	private function StopTooltipTimeout()
	{
		if (m_TooltipTimeout != undefined)
		{
			_global.clearTimeout(m_TooltipTimeout);
			m_TooltipTimeout = undefined;
		}
	}

    public function OpenTooltip() : Void
    {
		StopTooltipTimeout();
        if (m_Tooltip == undefined)
        {
            var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip( m_Inventory.m_InventoryID, _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1 );
            m_Tooltip = TooltipManager.GetInstance().ShowTooltip( this, TooltipInterface.e_OrientationHorizontal, 0, tooltipData );
		}
    }
    
    public function CloseTooltip() : Void
    {
		StopTooltipTimeout();
        if ( m_Tooltip != undefined && !m_Tooltip.IsFloating() )
        {
            m_Tooltip.Close();
        }
        m_Tooltip = undefined;
    }
	
	private function UpdateTimer() : Void
	{
		var timeLeft:Number = m_CooldownExpireTime - com.GameInterface.Utils.GetGameTime();

        if ( timeLeft > 0 )
        {
			if (m_TotalCooldownDuration > 0)
			{
				var percentage:Number = timeLeft / m_TotalCooldownDuration;
				m_BGMask._y = m_UseBG._height * percentage;
				m_CooldownLine._y = m_BGMask._y;
			}
			m_CooldownTimer.ms_txt.text = com.Utils.Format.Printf( "%02.0f:%02.0f:%02.0f", Math.floor(timeLeft / 60), Math.floor(timeLeft) % 60, Math.floor(timeLeft * 100) % 100 );
        }
        else
		{
			RemoveCooldown();				
		}
	} 
	
	private function SlotItemCooldown(inventoryID:com.Utils.ID32, itemPos:Number, seconds:Number):Void
	{
		if (itemPos == _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1)
		{
			SetCooldown(com.GameInterface.Utils.GetGameTime() + seconds, com.GameInterface.Utils.GetGameTime());
		}
	}
	
	private function SlotItemCooldownRemoved(inventoryID:com.Utils.ID32, itemPos:Number):Void
	{
		if (itemPos == _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1)
		{
			RemoveCooldown();
		}
	}
	
	private function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number):Void
	{
		if (itemPos == _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1)
		{
			SetData(m_Inventory.GetItemAt(itemPos));
		}
	}
	
	private function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean):Void
	{
		if (itemPos == _global.Enums.ItemEquipLocation.e_Aegis_Talisman_1)
		{
			ClearData();			
		}
	}
	
	private function onUnload()
	{
		StopTooltipTimeout();
		ClearData();
	}
}
