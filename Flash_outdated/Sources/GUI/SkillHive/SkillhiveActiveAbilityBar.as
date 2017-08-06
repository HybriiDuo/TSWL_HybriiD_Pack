import GUI.HUD.ActiveAbilitySlot;
import com.GameInterface.GUIUtils.FlashEnums;
import GUI.HUD.AbilitySlot;
import GUI.HUD.AbilityBase;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import flash.filters.GlowFilter;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.GameInterface.Utils;
import com.Utils.ShortcutLocation;
import com.Utils.Colors;
import com.GameInterface.Lore;
import com.GameInterface.Spell;
import com.GameInterface.SpellData;
import com.GameInterface.SpellBase;
import GUI.HUD.AugmentAbilitySlot;

dynamic class GUI.SkillHive.SkillhiveActiveAbilityBar extends MovieClip
{
	var m_AbilitySlots:Array;
	var m_AugmentSlots:Array;
    
    var SignalToggleVisibility:Signal;
	
	var m_AuxilliarySlotAchievement:Number = 5437;
	var AUGMENT_SLOT_ACHIEVEMENT:Number = 6277;
	
	var DAMAGE_AUGMENT_BIT:Number = 1;
	var HEALING_AUGMENT_BIT:Number = 2;
	var SURVIVABILITY_AUGMENT_BIT:Number = 4;
	var SUPPORT_AUGMENT_BIT:Number = 8;
    
    function SkillhiveActiveAbilityBar()
    {
        SignalToggleVisibility = new Signal();
    }

	function onLoad()
	{
		m_AbilitySlots = [];
		// loop the hive and push each of the slots in the m_AbilitySlots array.
		for( var i:Number = 0; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
		{
			var mc_slot:MovieClip = MovieClip( this["slot_"+i] );

			if( mc_slot != null )
			{
             /*   if (mc_slot.i_AbilityBase.i_AbilityMouseOverGlow != undefined)
                {
                    mc_slot.i_AbilityBase.i_AbilityMouseOverGlow.stop();
                }*/
				m_AbilitySlots.push(new ActiveAbilitySlot(mc_slot, _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + i) );
				m_AbilitySlots[i].SetCanUse(false);
			}
		}
		
		m_AugmentSlots = [];
		// loop the hive and push each of the slots in the m_AugmentSlots array.
		for( var i:Number = 0; i < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount; i++)
		{
			var mc_slot:MovieClip = MovieClip( this["Aug_"+i] );

			if( mc_slot != null )
			{
				m_AugmentSlots.push(new AugmentAbilitySlot( mc_slot, _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot + i));
			}
		}
		
	    /// connect the signals
		Shortcut.SignalShortcutAdded.Connect( SlotShortcutAdded, this  );
		Shortcut.SignalShortcutRemoved.Connect( SlotShortcutRemoved, this );
		Shortcut.SignalShortcutMoved.Connect( SlotShortcutMoved, this );
		Shortcut.SignalShortcutEnabled.Connect( SlotShortcutEnabled, this )
		
		Shortcut.RefreshShortcuts( _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount );
		Shortcut.RefreshShortcuts( _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot, _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount );
		
		gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "SlotDragEnd" );
        
        this.i_Bar.i_TopFrame.onPress = Delegate.create(this, SlotToggleVisibility);
		
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
		
		if (Lore.IsLocked(m_AuxilliarySlotAchievement))
		{
			this["slot_"+7]._visible = false;
			this["m_AuxilliaryFrame"]._visible = false;
			this._x += this["slot_"+7]._width;
			this.i_Bar._width -= this["slot_"+7]._x - this["slot_"+6]._x;
			this.i_Text._x -= (this["slot_"+7]._x - this["slot_"+6]._x)/2;
		}
		
		if (Lore.IsLocked(AUGMENT_SLOT_ACHIEVEMENT))
		{
			for (var i:Number = 0; i< _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount; i++)
			{
				this["Aug_"+i]._visible = false;
				
			}
		}
		else
		{
			this.i_Bar.i_TopFrame._y -= 25;
			this.i_Bar.i_Background._y -= 25;
			this.i_Text._y -= 25;
			this.i_Bar.i_Background._height += 25;
		}
	}

    function onUnload()
    {
		for (var i:Number = 0; i < m_AbilitySlots.length; i++)
		{
			m_AbilitySlots[i].CloseTooltip();
		}
		for (var i:Number = 0; i < m_AugmentSlots.length; i++)
		{
			m_AugmentSlots[i].CloseTooltip();
		}
        gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "SlotDragEnd" );
        
		Shortcut.SignalShortcutAdded.Disconnect( SlotShortcutAdded, this  );
		Shortcut.SignalShortcutRemoved.Disconnect( SlotShortcutRemoved, this );
		Shortcut.SignalShortcutMoved.Disconnect( SlotShortcutMoved, this );    
		Shortcut.SignalShortcutEnabled.Disconnect( SlotShortcutEnabled, this );
        Lore.SignalTagAdded.Disconnect(SlotTagAdded, this);
    }
    
	function SlotTagAdded(tag:Number)
	{
		if (tag == m_AuxilliarySlotAchievement)
		{
			this["slot_" + 7]._visible = true;
			this["m_AuxilliaryFrame"]._visible = true;
		}
		
		if (tag == AUGMENT_SLOT_ACHIEVEMENT)
		{
			for (var i:Number = 0; i<7; i++)
			{
				this["Aug_"+i]._visible = true;
				this.i_Bar.i_TopFrame._y += 25;
				this.i_Bar.i_Background._y += 25;
				this.i_Text._y += 25;
				this.i_Bar.i_Background._height -= 25;
			}
		}
	}
 
        
    function GetTopFrameHeight():Number
    {
        return (this.i_Bar.i_TopFrame._height * (this._yscale / 100)) + 5;
    }
    
    function SlotToggleVisibility()
    {
        SignalToggleVisibility.Emit();
    }
	
	public function EquipAugment(slotId:Number, spellId:Number)
	{
		if (CanAddShortcut(slotId, spellId))
		{
			if (Shortcut.IsSpellEquipped(spellId))
			{
				for ( var i in m_AugmentSlots )
				{
					if (m_AugmentSlots[i].m_Ability.GetSpellId() == spellId)
					{
						var srcID = m_AugmentSlots[i].GetSlotId();
						Shortcut.MoveShortcut( srcID, slotId + _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot );
						return;
					}
				}
			}
			Shortcut.AddAugment(slotId + _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot, spellId);
		}
	}

	public function EquipActive(slotId:Number, spellId:Number)
	{
		if (CanAddShortcut(slotId, spellId))
		{
			if (Shortcut.IsSpellEquipped(spellId))
			{
				for ( var i in m_AbilitySlots )
				{
					if (m_AbilitySlots[i].m_Ability.GetSpellId() == spellId)
					{
						var srcID = m_AbilitySlots[i].GetSlotId();
						Shortcut.MoveShortcut( srcID, slotId + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot );
						return;
					}
				}
			}
			Shortcut.AddSpell(slotId + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, spellId);
		}
	}
	
	public function UnEquipActive(spellId:Number)
	{
		for (var i:Number = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot +_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
		{
			if (Shortcut.m_ShortcutList[i].m_SpellId == spellId)
			{
				Shortcut.RemoveFromShortcutBar(i);
			}
		}
	}
	
	public function HighlightSlot(slotId:Number)
	{
		var filter:GlowFilter = new GlowFilter(0xFFFFFF,90,15,15,2,2,false,false);
		this["slot_" + slotId].filters = [filter];
	}
	
	public function StopHighlightSlot(slotId:Number)
	{
		this["slot_" + slotId].filters = [];
	}

	/// Signal sent when a shortcut has been added.
	/// This also happens when you teleport to a new pf.
	/// Note that you might get an SignalShortcutEnabled right afterward if the shortcut is disabled. And SignalCooldownTime if it's in cooldown.
	/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
	/// @param name:String      The name of the item in LDB format.
	/// @param icon:String      The icon resource information.
	/// @param itemClass:Number The type of shortcut. See Enums.StatItemClass
	function SlotShortcutAdded( itemPos:Number) : Void
	{
		var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
		if (itemPos >= _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot &&
			itemPos < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount)
		{
			var slotNo:Number = itemPos - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
			if ( slotNo >= 0 && slotNo < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount  && shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_SpellShortcut)
			{
				var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
				SlotShortcutRemoved(itemPos);
				var abilityslot:AbilitySlot = AbilitySlot( m_AbilitySlots[ slotNo ] );
				abilityslot.SetAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", false, spellData.m_ResourceGenerator );
			}
		}
		
		if (itemPos >= _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot &&
			itemPos < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot + _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount)
		{
			var slotNo:Number = itemPos - _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot;
			var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
            SlotShortcutRemoved(itemPos);
			var augmentslot:AbilitySlot = AbilitySlot( m_AugmentSlots[ slotNo ] );
            augmentslot.SetAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", false, spellData.m_ResourceGenerator );
			augmentslot.m_Ability._xscale = augmentslot.m_Ability._xscale/2
			augmentslot.m_Ability._yscale = augmentslot.m_Ability._yscale/2
		}
		ValidateAugments();
	}
	
	// Check the active ability slots and display which 
	//augments they can take in the augment bar.
	function ValidateAugments() : Void
	{
		for (var i:Number = 0; i< _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount; i++)
		{
			var augmentType:Number = -1;
			if (AbilitySlot(m_AugmentSlots[i]).m_Ability)
			{
				augmentType = SpellBase.GetSpellData(AbilitySlot(m_AugmentSlots[i]).m_Ability.GetSpellId()).m_SpellType;
				m_AugmentSlots[i].m_Ability.SetAvailable();
			}
			var activeShortcut:ShortcutData = Shortcut.m_ShortcutList[_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + i];
			if (activeShortcut != undefined)
			{
				var spellData:SpellData = SpellBase.GetSpellData(activeShortcut.m_SpellId);
				
				var allowedAugments = spellData.m_AllowedAugments;
				if((allowedAugments & DAMAGE_AUGMENT_BIT) > 0)
				{ 
					this["Aug_"+i].m_DamageIcon._visible = true;
				}
				else 
				{ 
					this["Aug_"+i].m_DamageIcon._visible = false;
					if(augmentType == _global.Enums.SpellItemType.eAugmentDamage)
					{
						m_AugmentSlots[i].m_Ability.SetDisabled();
					}
				}
				if((allowedAugments & HEALING_AUGMENT_BIT) > 0)
				{ 
					this["Aug_"+i].m_HealingIcon._visible = true;
				}
				else 
				{ 
					this["Aug_"+i].m_HealingIcon._visible = false;
					if(augmentType == _global.Enums.SpellItemType.eAugmentHealing)
					{
						m_AugmentSlots[i].m_Ability.SetDisabled();
					}
				}
				if((allowedAugments & SURVIVABILITY_AUGMENT_BIT) > 0)
				{ 
					this["Aug_"+i].m_SurvivabilityIcon._visible = true;
				}
				else 
				{ 
					this["Aug_"+i].m_SurvivabilityIcon._visible = false;
					if(augmentType == _global.Enums.SpellItemType.eAugmentSurvivability)
					{
						m_AugmentSlots[i].m_Ability.SetDisabled();
					}
				}
				if((allowedAugments & SUPPORT_AUGMENT_BIT) > 0)
				{ 
					this["Aug_"+i].m_SupportIcon._visible = true;
				}
				else 
				{ 
					this["Aug_"+i].m_SupportIcon._visible = false;
					if(augmentType == _global.Enums.SpellItemType.eAugmentSupport)
					{
						m_AugmentSlots[i].m_Ability.SetDisabled();
					}
				}
			}
			else
			{
				this["Aug_"+i].m_DamageIcon._visible = false;
				this["Aug_"+i].m_HealingIcon._visible = false;
				this["Aug_"+i].m_SurvivabilityIcon._visible = false;
				this["Aug_"+i].m_SupportIcon._visible = false;
				if(m_AugmentSlots[i].m_Ability) { m_AugmentSlots[i].m_Ability.SetDisabled(); }
			}
		}
	}

	/// Signal sent when a shortcut has been removed.
	/// This will not be sent if the shortcut changes position, moved.
	/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
	function SlotShortcutRemoved( itemPos:Number ) : Void
	{
		if (itemPos >= _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot &&
			itemPos < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount)
		{
			var slotNo:Number = itemPos - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
			if ( slotNo >= 0 && slotNo < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount )
			{
				var abilityslot:AbilitySlot = m_AbilitySlots[ slotNo ];
				if (abilityslot.IsActive)
				{
					abilityslot.Clear( );
				}
			}
		}
		if (itemPos >= _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot &&
			itemPos < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot + _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount)
		{
			var slotNo:Number = itemPos - _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot;
			if ( slotNo >= 0 && slotNo < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount )
			{
				var augmentslot:AbilitySlot = m_AugmentSlots[ slotNo ];
				if (augmentslot.IsActive)
				{
					augmentslot.Clear( );
				}
			}
		}
		ValidateAugments();
	}

	/// Signal sent when a shortcut has been move to some other spot.
	/// No add/remove signal will be triggered.
	/// @param fromPos:Number   The position the item was move from.
	/// @param toPos:Number     The position the item was move to.
	function SlotShortcutMoved( p_from:Number, p_to:Number ) : Void
	{
		if (p_from >= _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot &&
			p_from < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount)
		{
			var fromSlot:Number = p_from - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
			var toSlot:Number   = p_to - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
		
			if ( fromSlot >= 0 && fromSlot < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount  && toSlot >= 0 && toSlot < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount)  
			{
				/// get a reference to the slots
				var abilityTo:AbilitySlot = m_AbilitySlots[ toSlot ];
				var abilityFrom:AbilitySlot = m_AbilitySlots[ fromSlot ];
				
				//var fromName = abilityFrom.Name;
				//var fromIcon = abilityFrom.IconName;
				//var fromColor = abilityFrom.m_ColorLine;
				SlotShortcutRemoved( p_from );
				
				if( abilityTo.IsActive)
				{
					SlotShortcutAdded( p_from);
					abilityTo.Clear();
				} 
				SlotShortcutAdded( p_to);			
			}
		}
		if (p_from >= _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot &&
			p_from < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot + _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount)
		{
			var fromSlot:Number = p_from - _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot;
			var toSlot:Number   = p_to - _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot;
		
			if ( fromSlot >= 0 && fromSlot < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount  && toSlot >= 0 && toSlot < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount)  
			{
				/// get a reference to the slots
				var abilityTo:AbilitySlot = m_AugmentSlots[ toSlot ];
				var abilityFrom:AbilitySlot = m_AugmentSlots[ fromSlot ];
				
				//var fromName = abilityFrom.Name;
				//var fromIcon = abilityFrom.IconName;
				//var fromColor = abilityFrom.m_ColorLine;
				SlotShortcutRemoved( p_from );
				
				if( abilityTo.IsActive)
				{
					SlotShortcutAdded( p_from);
					abilityTo.Clear();
				} 
				SlotShortcutAdded( p_to);			
			}
		}
		ValidateAugments();
	}
	
	/// Signal sent when a shortcut is enabled/disabled.
	/// Will also be send when you enter a new playfield.
	/// @param itemPos:Number   The position of the item.
	/// @param enabled:Number   0=disable, 1=enabled
	function SlotShortcutEnabled( itemPos:Number, enabled:Boolean ) : Void
	{
		if (itemPos >= _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot &&
			itemPos < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot + _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount)
		{
			var slotNo:Number = itemPos - _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot;
			var abilitySlot:AugmentAbilitySlot = m_AugmentSlots[ slotNo ];
			if (abilitySlot.IsActive)
			{
				abilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_DISABLED );
			}
		}
	}
	
	function CanAddShortcut(pos:Number, spellId:Number) : Boolean
	{
		var spellData:SpellData = Spell.GetSpellData(spellId);
		if (spellData != undefined)
		{
			if (pos != 7 && spellData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
			{
				return false;
			}
			else if (pos == 7 && spellData.m_SpellType != _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
			{
				return false;
			}
		}
		return true;
	}
	
		
	function SlotDragEnd( event:Object )
	{
		if ( event.data.type == "shortcutbar/activeability" )
		{
			var dstID = GetMouseSlotID();
			
			if ( dstID >= _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot && 
				dstID < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount)
			{
				
				var fromData:ShortcutData = Shortcut.m_ShortcutList[event.data.slot_index];
				var toData:ShortcutData = Shortcut.m_ShortcutList[dstID];
                
                var canMove:Boolean = true;
                
				if (fromData != undefined && !CanAddShortcut(dstID - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, fromData.m_SpellId))
				{
					canMove = false;
				}
				if (toData != undefined && !CanAddShortcut(event.data.slot_index - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, toData.m_SpellId))
				{
					canMove = false;
				}
                if (canMove)
                {
                    Shortcut.MoveShortcut( event.data.slot_index, dstID );
                }
                event.data.DragHandled();
			}
		}
        else if ( event.data.type == "skillhive_active" )
        {
            var dstID = GetMouseSlotID();
            if ( dstID >= _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot && 
				dstID < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount)
            {
                EquipActive( dstID - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, event.data.ability );
                event.data.DragHandled();
            }
        }

		else if ( event.data.type == "shortcutbar/augmentability" )
        {
            var dstID = GetMouseSlotID();

            if ( dstID >= _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot && 
				dstID < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot + _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount)
            {
				var fromData:ShortcutData = Shortcut.m_ShortcutList[event.data.slot_index];
				var toData:ShortcutData = Shortcut.m_ShortcutList[dstID];
				
				var canMove:Boolean = true;
				
				if (fromData != undefined && !CanAddShortcut(dstID - _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot, fromData.m_SpellId))
				{
					canMove = false;
				}
				if (toData != undefined && !CanAddShortcut(event.data.slot_index - _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot, toData.m_SpellId))
				{
					canMove = false;
				}
				if (canMove)
				{
					Shortcut.MoveShortcut( event.data.slot_index, dstID );
				}
				event.data.DragHandled();
            }
        }
        else if ( event.data.type == "skillhive_augment" )
        {
            var dstID = GetMouseSlotID();
            if ( dstID >= _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot && 
				dstID < _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot + _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarSlotCount)
            {
                EquipAugment( dstID - _global.Enums.AugmentAbilityShortcutSlots.e_AugmentShortcutBarFirstSlot, event.data.ability );
                event.data.DragHandled();
            }
        }
        ToggleHighlightTopFrame(false);
	}	
		
	function GetMouseSlotID() : Number
	{
	  var mousePos:flash.geom.Point = new flash.geom.Point;

	  mousePos.x = _root._xmouse;
	  mousePos.y = _root._ymouse;

	  for ( var i in m_AbilitySlots )
	  {
		var abilitySlot:AbilitySlot = m_AbilitySlots[i];
		var abilityIcon:MovieClip = abilitySlot.Slot;
       
		if ( abilityIcon.hitTest( mousePos.x, mousePos.y, true ) )
		{
		  return abilitySlot.GetSlotId();
		}
	  }
	  for (var i in m_AugmentSlots)
	  {
		  var abilitySlot:AbilitySlot = m_AugmentSlots[i];
		  var abilityIcon:MovieClip = abilitySlot.Slot;
		  if (abilityIcon.hitTest( mousePos.x, mousePos.y, true))
		  {
			  return abilitySlot.GetSlotId();
		  }
	  }
	  return -1;
	}
    
    function GetAbilityColors():Array
    {
        var colorArray:Array = [];
        //Push colorline / undefined if no ability
        for (var i:Number = 0; i < m_AbilitySlots.length; i++)
        {
            if (m_AbilitySlots[i].m_ColorLine != undefined)
            {
                colorArray.push(Colors.GetColor( m_AbilitySlots[i].m_ColorLine));
            }
            else
            {
                colorArray.push(undefined);
            }
        }
        return colorArray;
    }
	
	function GetAugmentColors():Array
	{
		var colorArray:Array = [];
		//Push colorline / undefined if no ability
		for (var i:Number = 0; i < m_AugmentSlots.length; i++)
        {
            if (m_AugmentSlots[i].m_ColorLine != undefined)
            {
                colorArray.push(Colors.GetColor( m_AugmentSlots[i].m_ColorLine));
            }
            else
            {
                colorArray.push(undefined);
            }
        }
        return colorArray;
	}
    
    function ToggleHighlightTopFrame(highlight:Boolean)
    {
        if (!highlight)
        {
            Colors.ApplyColor(this.i_Bar.i_TopFrame, 0x737373)
        }
        else
        {
            Colors.ApplyColor(this.i_Bar.i_TopFrame, 0xAAAAB6)
        }
    }
}