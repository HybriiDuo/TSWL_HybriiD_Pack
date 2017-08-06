import gfx.core.UIComponent;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.Spell;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.*;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.Utils.DragObject;
import com.Utils.Signal;
import flash.geom.Point;
import mx.utils.Delegate;
import GUI.HUD.AbilityBase;

class GUI.SkillHiveSimple.AbilityClip extends UIComponent
{
	//Elements created in flash editor
	private var m_Ability:MovieClip;
	
	//Variables
	private var m_FeatData:FeatData;
	private var m_ResourceIconMonitor:DistributedValue; 
	private var m_Tooltip:TooltipInterface;
	private var m_TooltipTimeout:Number;
	private var m_WasHit:Boolean;
	private var m_HitPos:Point;
	private var m_DragType:String;
	
	public var m_SignalAbilityFocus:Signal;
	
	public function AbilityClip()
	{
		super();
		/*
		m_ResourceIconMonitor = DistributedValue.Create("ShowResourceIcons");
		m_ResourceIconMonitor.SignalChanged.Connect(UpdateResourceIcons, this);
		*/
		m_HitPos = new Point();
		m_SignalAbilityFocus = new Signal();
	}

	private function configUI()
	{
		super.configUI();
	}
	
	public function SetData(featData:FeatData)
	{
		m_FeatData = featData;
		if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eMagicSpell ||
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eBuilderAbility ||
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eConsumerAbility ||
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility ||
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
        {
			m_DragType = "spell";
		}
		else if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.ePassiveAbility ||
				 m_FeatData.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility ||
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
        {
			m_DragType = "passive";
		}
		UpdateAbilityIcon();
	}
	
	private function UpdateAbilityIcon():Void
	{         
        var moviecliploader:MovieClipLoader = new MovieClipLoader();        
        var iconString:String = Utils.CreateResourceString(m_FeatData.m_IconID);
        moviecliploader.loadClip( iconString, m_Ability.m_Content);
        
		//Size the icons
        m_Ability.m_Content._x = 2;
        m_Ability.m_Content._y = 2;
        m_Ability.m_Content._xscale = m_Ability.m_Background._width - 4;
        m_Ability.m_Content._yscale = m_Ability.m_Background._height - 4;
        
		//Background colors
        var iconColor = Colors.GetColorlineColors( m_FeatData.m_ColorLine );
        Colors.ApplyColor( m_Ability.m_Background.highlight, iconColor.highlight);
        Colors.ApplyColor( m_Ability.m_Background.background, iconColor.background);
        
		//Lines and frames
        if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eMagicSpell ||
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eBuilderAbility ||
			m_FeatData.m_SpellType == _global.Enums.SpellItemType.eConsumerAbility)
        {
            m_Ability.m_Lines._visible = false;
            m_Ability.m_EliteFrame._visible = false;
        }
        else if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility)
        {
            m_Ability.m_Lines._visible = false;
            m_Ability.m_EliteFrame._visible = true;
        }
        else if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility)
        {
            m_Ability.m_Lines._visible = true;
            m_Ability.m_EliteFrame._visible = true;
        }
        else if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
        {
            m_Ability.m_Lines._visible = true;
            m_Ability.m_EliteFrame._visible = false;
        }
        else if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
        {
            m_Ability.m_Lines._visible = false;
            m_Ability.m_EliteFrame._visible = false;
        }		
        else
        {
            m_Ability.m_Lines._visible = true;
            m_Ability.m_EliteFrame._visible = false;
        }
		
		//UpdateResourceIcons();
		UpdateFilter();
	}
	
	private function UpdateFilter()
	{
		if (m_FeatData.m_Trained)
		{
			m_Ability._alpha = 100;
			com.Utils.Colors.Tint(m_Ability, 0x000000, 0);
		}
		else
		{
			m_Ability._alpha = 50;
			if (m_FeatData.m_CanTrain)
			{
				com.Utils.Colors.Tint(m_Ability, 0x000000, 0);
			}
			else
			{
				com.Utils.Colors.Tint(m_Ability, 0x000000, 75);
			}
		}
	}
	
	private function UpdateResourceIcons():Void
	{
		/*
		//Builder & consumer Icons
		if (m_FeatData.m_ResourceGenerator > 0 && m_ResourceIconMonitor.GetValue())
		{
			m_Ability.m_BuilderIcon._visible = true;
			m_Ability.m_ConsumerIcon._visible = false;
		}
		else if (m_FeatData.m_ResourceGenerator < 0 && m_ResourceIconMonitor.GetValue())
		{
			m_Ability.m_BuilderIcon._visible = false;
			m_Ability.m_ConsumerIcon._visible = true;
		}
		else
		{
			m_Ability.m_BuilderIcon._visible = false;
			m_Ability.m_ConsumerIcon._visible = false;
		}
		*/
	}
	
	private function onRelease() :Void
    {
		m_SignalAbilityFocus.Emit(m_FeatData);
		this._parent.m_Tile.gotoAndPlay("selected");
    }
	
	private function onMouseRelease(mouseBtnId:Number) : Void
	{
		m_WasHit = false;
		if (mouseBtnId == 2)
		{
			if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility || 
				m_FeatData.m_SpellType == _global.Enums.SpellItemType.ePassiveAbility)
			{
				var nextFreeSlot:Number = Spell.GetNextFreePassiveSlot();
				if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
				{
					nextFreeSlot = 7;
				}
				if (nextFreeSlot >= 0)
				{
					Spell.EquipPassiveAbility( nextFreeSlot, m_FeatData.m_Spell);
				}
			}
			else if(m_FeatData.m_SpellType == _global.Enums.SpellItemType.eMagicSpell || 
					m_FeatData.m_SpellType == _global.Enums.SpellItemType.eBuilderAbility || 
					m_FeatData.m_SpellType == _global.Enums.SpellItemType.eConsumerAbility || 
					m_FeatData.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility ||
					m_FeatData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility )
			{
				var slot:Number = -1;
				if (m_FeatData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
				{
					slot = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + 7;
				}
				Shortcut.AddSpell( slot, m_FeatData.m_Spell);
			}
		}
	}
    
    private function onMousePress(mouseBtnId:Number) : Void
    {
		if (mouseBtnId == 2)
		{
			return;
		}
		else
		{
			if ( m_Tooltip != undefined && Key.isDown( Key.SHIFT ) )
			{
				m_Tooltip.MakeFloating();
			}
			else
			{
				m_WasHit = true;
				m_HitPos.x = _root._xmouse;
				m_HitPos.y = _root._ymouse;
			}
		}
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
   
    public function CloseTooltip() : Void
    {
		StopTooltipTimeout();
        if ( m_Tooltip != undefined )
        {
            if ( !m_Tooltip.IsFloating() )
            {
                m_Tooltip.Close();
            }
            m_Tooltip = undefined;
        }
    }
	
	public function OpenTooltip() : Void
	{
		StopTooltipTimeout();
		if ( m_Tooltip == undefined )
		{
			var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( m_FeatData.m_Spell, 0 )
			m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_Ability, TooltipInterface.e_OrientationVertical, 0, tooltipData);
		}
	}
	
	private function onRollOver() : Void
	{
		if (!DragObject.GetCurrentDragObject())
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
	
	private function onUnload() : Void
	{
		CloseTooltip();
	}
	
	private function onMouseMove():Void
	{
        var mousePos:Point = new Point( _root._xmouse, _root._ymouse );

        if ( m_WasHit && Point.distance( m_HitPos, mousePos ) > 3  )
        {
            if(!DragObject.GetCurrentDragObject() && m_FeatData.m_Trained)
            {
                var dragData:DragObject = new DragObject();
                dragData.type = m_DragType;
				dragData.id = m_FeatData.m_Spell;

                var dragClip = AbilityBase(m_Ability.attachMovie( "Ability", "drag_clip", m_Ability.getNextHighestDepth()));
                dragClip.SetColor( m_FeatData.m_ColorLine ); 
                dragClip.SetIcon( Utils.CreateResourceString(m_FeatData.m_IconID) );
                dragClip.SetSpellType( m_FeatData.m_SpellType );
				dragClip.SetResources( m_FeatData.m_ResourceGenerator );

                gfx.managers.DragManager.instance.startDrag( m_Ability, dragClip, dragData, dragData, m_Ability, false );
                gfx.managers.DragManager.instance.removeTarget = true;
                
                dragClip.topmostLevel = true;
                dragClip.hitTestDisable = true;
                
				CloseTooltip();
            }
            m_WasHit = false;
        }
		if (m_Tooltip != undefined && !m_Ability.hitTest(_root._xmouse, _root._ymouse))
		{
			onRollOut();
		}
    }
}