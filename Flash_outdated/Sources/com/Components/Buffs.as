﻿import com.GameInterface.Spell;
import com.Components.BuffComponent;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.BuffData;
import com.Utils.Signal;
import mx.utils.Delegate;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import com.GameInterface.Utils;
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import gfx.core.UIComponent;

class com.Components.Buffs extends UIComponent
{
	private var m_BuffList:Array;
	private var m_MovieClipLoader:MovieClipLoader;
	private var m_Direction:Number;
	private var SizeChanged:Signal; // Signal sent when this movieclip changed size.
    private var SignalBuffAdded:Signal;
    private var SignalBuffRemoved:Signal;
	private var m_UseTimers:Boolean;
	private var m_ShowCharges:Boolean;
	private var m_MaxPerLine:Number;
	private var m_NumLines:Number;
    private var m_Multiline:Boolean;
    
	/// magics to control removal of buff debuffs
	private static var BUFF:Number = 0;
	private static var DEBUFF:Number = 1;
	private static var ALL:Number = 2;
    
	// controller
	private var m_ShowBuff:Boolean;
	private var m_ShowDebuff:Boolean;

	private var m_Character:Character;
	private var m_GroupElement:GroupElement;
    
    private var m_Width:Number
    private var m_NeedSizeUpdate:Boolean;
	

	public function Buffs()
	{
		m_BuffList = new Array();
		
		m_ShowBuff = true;
		m_ShowDebuff = true;
		
		m_UseTimers = true;
		m_ShowCharges = true;
		m_Direction = -1; // Tell which direction the icons are layed out.
		m_MaxPerLine = 4;
        m_Multiline = true;
		m_NumLines = 0;
        m_NeedSizeUpdate = true;

		m_MovieClipLoader = new MovieClipLoader();
		SizeChanged = new Signal();
		SignalBuffAdded = new Signal();
		SignalBuffRemoved = new Signal();
        
        m_Width = 100;
	}
        
    public function SetWidth(width:Number)
    {
        if (m_Width != width)
        {
            m_NeedSizeUpdate = true;
            m_Width = width;
            Layout();
        }
    }

    public function SetMultiline(multiline:Boolean):Void
    {
        if (m_Multiline != multiline)
        {
            m_NeedSizeUpdate = true;
            m_Multiline = multiline;
            Layout();
        }
    }
    
	function SetCharacter(character:Character)
	{
		ClearAllBuffs( );
		if (m_Character != undefined)
		{
			m_Character.SignalBuffAdded.Disconnect(SlotBuffAdded, this);
			m_Character.SignalBuffRemoved.Disconnect(SlotBuffRemoved, this);
			m_Character.SignalBuffUpdated.Disconnect(SlotBuffAdded, this);
			m_Character.SignalCharacterDied.Disconnect(ClearAllBuffs, this);
		}
		m_Character = character;
		
		if (character != undefined)
		{
			m_Character.SignalBuffAdded.Disconnect(SlotBuffAdded, this);
			m_Character.SignalBuffRemoved.Disconnect(SlotBuffRemoved, this);
			m_Character.SignalBuffUpdated.Disconnect(SlotBuffAdded, this);
			m_Character.SignalCharacterDied.Disconnect(ClearAllBuffs, this);
			
			m_Character.SignalBuffAdded.Connect(SlotBuffAdded, this);
			m_Character.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
			m_Character.SignalBuffUpdated.Connect(SlotBuffAdded, this);
			m_Character.SignalCharacterDied.Connect(ClearAllBuffs, this);
			
			AddExistingBuffs();	
		}
	}

	function SetGroupElement(groupElement:GroupElement)
	{
		if (m_GroupElement != undefined)
		{
			m_GroupElement.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
			m_GroupElement.SignalCharacterExitedClient.Disconnect(SlotCharacterExited, this);
		}
		m_GroupElement = groupElement;
		if (m_GroupElement.m_OnClient)
		{
			SetCharacter(Character.GetCharacter(groupElement.m_CharacterId));
		}
		else
		{
			SetCharacter(undefined);
		}
		if (groupElement != undefined)
		{
			m_GroupElement.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
			m_GroupElement.SignalCharacterExitedClient.Connect(SlotCharacterExited, this);
		}
	}

	function ClearAllBuffs()
	{
		ClearBuffs(ALL);
	}

	function SlotCharacterEntered()
	{
		SetCharacter(Character.GetCharacter(m_GroupElement.m_CharacterId));
	}
	
	function SlotCharacterExited()
	{
		ClearAllBuffs();
	}

	function AddExistingBuffs()
	{
		for(var prop in m_Character.m_BuffList)
		{
			AddBuff(m_Character.m_BuffList[prop]);
		}
	}
    
    function ShowTimers(show:Boolean)
	{
		m_UseTimers = show;
		ClearAllBuffs();
		ShowAllBuffs();
	}
    
    function GetShowTimer():Boolean
    {
        return m_UseTimers;
    }

	function NoTimers()
	{
		m_UseTimers = false;
	}

    function ShowCharges(show:Boolean)
	{
		m_ShowCharges = show;
		ClearAllBuffs();
		ShowAllBuffs();
	}

	function NoCharges( )
	{
		m_ShowCharges = false;
	}

	function ShowBuffs( show:Boolean )
	{
		m_ShowBuff = show;
		if (!show)
		{
			ClearBuffs(BUFF);
		}
		else
		{
			ShowAllBuffs();
		}
	}

	function ShowDebuffs(show:Boolean )
	{
		m_ShowDebuff = show;
		if (!show)
		{
			ClearBuffs( DEBUFF );
		}
		else
		{
			ShowAllBuffs();
		}
	}

	function SetDirectionDown()
	{
        if (m_Direction != 1)
        {
            m_Direction = 1;
            m_NeedSizeUpdate = true;
            Layout();
        }
	}

	/// clears all buffs from the visuals
	/// @param type:Number - BUFF, DEBUFF or ALL depending on what you want to remove
	/// @return Void
	function ClearBuffs(type:Number) : Void
	{
		if (m_BuffList.length != NaN)
		{
			for(var i:Number = m_BuffList.length-1; i >= 0; i--)
			{
				/// remove all
				if (type === ALL)
				{
					SlotBuffRemoved( m_BuffList[i].GetBuffData().m_BuffId )
				}
				/// remove debuffs
				else if ((type === DEBUFF) && m_BuffList[i].GetBuffData().m_Hostile)
				{
					SlotBuffRemoved( m_BuffList[i].GetBuffData().m_BuffId )
				}
				/// remove buffs
				else if ((type === BUFF) && !m_BuffList[i].GetBuffData().m_Hostile)
				{
					SlotBuffRemoved( m_BuffList[i].GetBuffData().m_BuffId )
				}
			}
		}
	}

	/// @todo implement method to request all buffs on a dynel
	/// enables all buffs if these have not been showed
	/// @return Void
	function ShowAllBuffs() : Void
	{
		AddExistingBuffs();
	}

    public function GetBuffCount():Number 
    {
        return m_BuffList.length;
    }

	function AddBuff(buffData:BuffData)
	{
		if (buffData == undefined)
		{
			return;
		}
		/// disregard states as they are being dealth with on their own
		if (Spell.IsTokenState(buffData.m_BuffId))
		{
			return;
		}
		/// disregard buffs if set to not show
		else if (buffData.m_Hostile && !m_ShowDebuff)
		{
			return;
		}
		// disregard debuffs if set to not show
		else if (!buffData.m_Hostile && !m_ShowBuff)
		{
			return;
		}

		// Create buff if it does not exist.
		var clientCharacterID:ID32 = Character.GetClientCharID();
		var buffClip:BuffComponent = GetBuffClip(buffData.m_BuffId);
		var newBuff:Boolean = false;
		if( buffClip == undefined)
		{
			newBuff = true;
            buffClip = BuffComponent(attachMovie( "BuffComponent", ""+buffData.m_BuffId, getNextHighestDepth()));
            buffClip.SetShowCharges( m_ShowCharges );
            buffClip.SetUseTimers( m_UseTimers);
			buffClip.SetCharacterID(m_Character.GetID());
            if (m_Character != undefined && m_Character.GetID().Equal(clientCharacterID))
            {
                buffClip.SetIsPlayer(true);
            }
			//These buffs are special and should be at the bottom of the list
			if (buffData.m_BuffType != _global.Enums.BuffType.e_BuffType_TrueBand &&
				buffData.m_BuffType != _global.Enums.BuffType.e_BuffType_Trigger &&
				buffData.m_BuffType != _global.Enums.BuffType.e_BuffType_Resistance &&
				buffData.m_BuffType != _global.Enums.BuffType.e_BuffType_TrueDebuff) 
				{ 
					m_BuffList.push( buffClip ); 
				}
			else { m_BuffList.unshift( buffClip ); }
		}
		//Always update the buff with stacks applied by this player or if the current buff should be expired
		if (buffData.m_CasterId == clientCharacterID.GetInstance() || buffClip.GetTimeLeft()/1000 <= 0)
		{
			if (newBuff)
			{
        		buffClip.SetBuffData( buffData ); 
			}
			else
			{
				buffClip.UpdateBuffData( buffData );
			}
		}
		else if (!(buffClip.GetBuffData().m_CasterId == clientCharacterID.GetInstance()) && 
				 (buffClip.GetBuffData().m_Count == undefined || 
				  buffData.m_Count >= buffClip.GetBuffData().m_Count ||
				  buffClip.GetBuffData().m_CasterId == buffData.m_CasterId))
		{
			if (newBuff)
			{
				buffClip.SetBuffData( buffData );
			}
			else
			{
				buffClip.UpdateBuffData( buffData );
			}
		}
		if (newBuff)
		{
			if (Math.ceil(m_BuffList.length/m_MaxPerLine) != m_NumLines)
			{
				m_NeedSizeUpdate = true;
			}
			Layout();
			SignalBuffAdded.Emit();
		}
	}


	function SlotBuffAdded(buffId:Number)
	{
		AddBuff(m_Character.m_BuffList[buffId]);
	}

	// Deactivates a buff.
	/// @param buffId:Number - the ID of the buff to deactivate;
	function SlotBuffRemoved( buffId:Number, casterId:Number )
	{
		for(var i:Number = 0; i < m_BuffList.length; i++)
		{
			if( m_BuffList[i].GetBuffData().m_BuffId == buffId)
			{
				m_BuffList[i].Remove();
				m_BuffList[i] = null;
				m_BuffList.splice(i, 1);
				if (Math.ceil(m_BuffList.length/m_MaxPerLine) != m_NumLines)
				{
					m_NeedSizeUpdate = true;
				}
				Layout();
				SignalBuffRemoved.Emit();
				break;
			}
		}
	}

	function GetBuffClip(buffId):BuffComponent
	{
		for( var i:Number = 0; i < m_BuffList.length; i++)
		{
			if (m_BuffList[i].GetBuffData().m_BuffId == buffId)
			{
				return m_BuffList[i];
			}
		}
		return undefined;
	}
	
	function SetMaxPerLine(max:Number)
	{
        if (m_MaxPerLine != max)
        {
            m_MaxPerLine = max;
            m_NeedSizeUpdate = true;
        }
	}
    
    /// SortOrder
    /// TrueBand -> Trigger -> Resistance -> Buff/Debuff (Sorted on timeleft)
    function BuffCompare(a:BuffComponent, b:BuffComponent):Number
	{
        //Sort buffs by type if type is not buff/debuff
        if (a.GetBuffData().m_BuffType >= _global.Enums.BuffType.e_BuffType_TrueBand && b.GetBuffData().m_BuffType >=_global.Enums.BuffType.e_BuffType_TrueBand)
        {
            return a.GetBuffData().m_BuffType - b.GetBuffData().m_BuffType;
        }
        else if (a.GetBuffData().m_BuffType >= _global.Enums.BuffType.e_BuffType_TrueBand || b.GetBuffData().m_BuffType >= _global.Enums.BuffType.e_BuffType_TrueBand)
        {
            return b.GetBuffData().m_BuffType - a.GetBuffData().m_BuffType;
        }
        else
        {
            //If they are buffs/debuffs, sort by time left
            return a.GetTimeLeft() - b.GetTimeLeft();
        }
	}

	function Layout()
	{
        //m_BuffList.sort(BuffCompare);
        
        var currentBuff:Number = 0;
        var currentDebuff:Number = 0;
        var index:Number = 0;
        var buffComponentsSeparation:Number = 5;
        var buffDebuffSeparation:Number = 2;
        
        var line:Number = 0;
        for ( var i:Number = 0; i < m_BuffList.length; i++)
        {
            var startX:Number = 0;
            
            var buffComponent:BuffComponent = m_BuffList[i];
            
            if (buffComponent.GetBuffData().m_BuffType == _global.Enums.BuffType.e_BuffType_Debuff ||
				buffComponent.GetBuffData().m_BuffType == _global.Enums.BuffType.e_BuffType_TrueDebuff ||
                buffComponent.GetBuffData().m_BuffType == _global.Enums.BuffType.e_BuffType_None && buffComponent.GetBuffData().m_Hostile)
            {
                index = currentDebuff++;
                startX = m_MaxPerLine * (buffComponent.GetWidth() + buffComponentsSeparation) + buffDebuffSeparation; //m_Width / 2 + 5;
            }
            else
            {
                index = currentBuff++;
            }
            
            line = Math.floor( index / m_MaxPerLine);
            if (line > 0 && !m_Multiline)
            {
                buffComponent._visible = false;
            }
            else
            {
                buffComponent._visible = true;
                buffComponent._x = startX + ((buffComponent.GetWidth() + buffComponentsSeparation) * (index - (line * m_MaxPerLine))) + 2*buffComponentsSeparation;
                if (m_Direction == -1)
                {
                    line += 1;
                }
                buffComponent._y = m_Direction * line * (buffComponent.GetHeight() + buffComponentsSeparation)
            }
            
        }
        if (m_NeedSizeUpdate)
        {
			m_NumLines = Math.ceil(m_BuffList.length/m_MaxPerLine);
			if (m_Multiline || m_NumLines < 2)
			{
            	SizeChanged.Emit();
			}
            m_NeedSizeUpdate = false;
        }
	}
}
