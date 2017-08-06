import com.GameInterface.Game.Character;
import com.GameInterface.Game.BuffData;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.utils.Delegate;
import mx.transitions.easing.*;

class com.Components.WeaponStatuses.ShotgunWeaponStatus extends UIComponent
{	
	private var m_Shells:MovieClip;
	private var m_Base:MovieClip;
	private var m_DepleatedUranium:MovieClip;
	private var m_DragonsBreath:MovieClip;
	private var m_ArmorPiercing:MovieClip;
	private var m_Anima:MovieClip;
	private var m_ShellAnims:MovieClip;

	private var m_Character:Character;
	private var m_CurrentCount:Number;
	private var m_CurrentType:Number;
	private var m_PlaySound:Boolean;
	private var m_Empty:Boolean;
	
	private static var COUNTER_BUFF:Number = 9253306;
	private static var DEPLEATED_URANIUM_BUFF:Number = 9253310;
	private static var DRAGONS_BREATH_BUFF:Number = 9253311;
	private static var ARMOR_PIERCING_BUFF:Number = 9253312;
	private static var ANIMA_BUFF:Number = 9253313;
	private static var MAX_COUNT:Number = 6;
	private static var SHELL_START:Number = 0;
	private static var SHELL_PADDING:Number = 27;
	
	public function ShotgunWeaponStatus()
	{
		super();
		m_CurrentCount = 0;
		m_CurrentType = 0;
		m_Empty = true;
	}
	
	private function configUI()
	{
		m_PlaySound = false;
		m_Character = Character.GetClientCharacter();
		m_Character.SignalInvisibleBuffAdded.Connect(UpdateBuff, this);
		m_Character.SignalBuffRemoved.Connect(UpdateBuff, this);
		m_Character.SignalInvisibleBuffUpdated.Connect(UpdateBuff, this);
		
		//Starts empty
		for (var i:Number = 0; i < MAX_COUNT; i++)
		{
			m_Shells["m_Shell_" + i]._visible = false;
		}
		
		//Hide Anims
		m_ShellAnims["m_Anim_1"]._visible = false;
		m_ShellAnims["m_Anim_2"]._visible = false;
		m_ShellAnims["m_Anim_3"]._visible = false;
		
		UpdateBuff(GetCurrentTypeBuff());
		UpdateBuff(COUNTER_BUFF);
		m_PlaySound = true;
	}
	
	private function onUnload()
	{
		if (m_Character != undefined)
		{
			m_Character.SignalInvisibleBuffAdded.Disconnect(UpdateBuff, this);
			m_Character.SignalBuffRemoved.Disconnect(UpdateBuff, this);
			m_Character.SignalInvisibleBuffUpdated.Disconnect(UpdateBuff, this);
		}
	}
	
	private function UpdateBuff(buffId:Number)
	{
		if (buffId != COUNTER_BUFF && buffId != DEPLEATED_URANIUM_BUFF && buffId != DRAGONS_BREATH_BUFF && buffId != ARMOR_PIERCING_BUFF && buffId != ANIMA_BUFF)
		{
			return;
		}
		if (buffId == COUNTER_BUFF)
		{
			var updateCount:Number = 0;
			if (m_Character.m_InvisibleBuffList[COUNTER_BUFF])
			{
				updateCount = Math.min(6, m_Character.m_InvisibleBuffList[COUNTER_BUFF].m_Count);
			}
			
			if (updateCount == 0)
			{
				if (!m_Empty)
				{
					if (m_PlaySound)
					{
						m_Character.AddEffectPackage( "sound_fxpackage_GUI_shotgun_reload_needed.xml" );
					}
					m_Empty = true;
				}
			}
			else
			{
				m_Empty = false;
			}
			
			var shellsVisible:Number = 0;
			if (updateCount == m_CurrentCount)
			{
				return;
			}
			for (var i:Number = 0; i < MAX_COUNT; i++)
			{
				var shellIcon:MovieClip = m_Shells["m_Shell_" + i];
				var spent:Number = MAX_COUNT - updateCount;
				if (i < spent)
				{
					shellIcon._x = SHELL_START;
					shellIcon._visible = false;
				}
				else
				{
					if (shellsVisible == 0 && m_CurrentCount < updateCount)
					{
						shellIcon._x = SHELL_START - SHELL_PADDING;
					}
					shellIcon.tweenEnd(false);
					var newX:Number = SHELL_START + (shellsVisible * SHELL_PADDING);
					shellIcon.tweenTo(0.1, {_x:newX}, None.easeNone);
					shellIcon._visible = true;
					shellsVisible = shellsVisible + 1;
				}
			}
			if (updateCount < m_CurrentCount)
			{
				var rand:Number = Math.floor(Math.random() * (3-1+1)) + 1;
				m_ShellAnims["m_Anim_"+rand]._visible = true;
				m_ShellAnims["m_Anim_"+rand].gotoAndPlay(1);
			}
			m_CurrentCount = updateCount;
		}
		
		else if (buffId != m_CurrentType)
		{
			m_CurrentType = buffId;
			var color:Number = GetCurrentTypeColor();
			for (var i:Number = 0; i < MAX_COUNT; i++)
			{
				Colors.ApplyColor(m_Shells["m_Shell_" + i].m_Top.m_Tint, color);
				Colors.ApplyColor(m_ShellAnims["m_Anim_1"].m_Shell.m_Top, color);
				Colors.ApplyColor(m_ShellAnims["m_Anim_2"].m_Shell.m_Top, color);
				Colors.ApplyColor(m_ShellAnims["m_Anim_3"].m_Shell.m_Top, color);
			}
			
			m_DepleatedUranium._visible = false;
			m_DragonsBreath._visible = false;
			m_ArmorPiercing._visible = false;
			m_Anima._visible = false;
			switch(m_CurrentType)
			{
				case DEPLEATED_URANIUM_BUFF:	m_DepleatedUranium._visible = true;
												break;
				case DRAGONS_BREATH_BUFF:		m_DragonsBreath._visible = true;
												break;
				case ARMOR_PIERCING_BUFF:		m_ArmorPiercing._visible = true;
												break;
				case ANIMA_BUFF:				m_Anima._visible = true;
												break;
			}
		}
	}
	
	private function GetCurrentTypeBuff():Number
	{
		if (m_Character.m_InvisibleBuffList[DEPLEATED_URANIUM_BUFF]) { return DEPLEATED_URANIUM_BUFF; }
		else if (m_Character.m_InvisibleBuffList[DRAGONS_BREATH_BUFF]) { return DRAGONS_BREATH_BUFF; }
		else if (m_Character.m_InvisibleBuffList[ARMOR_PIERCING_BUFF]) { return ARMOR_PIERCING_BUFF; }
		else if (m_Character.m_InvisibleBuffList[ANIMA_BUFF]) { return ANIMA_BUFF; }
		return 0;
	}
	
	private function GetCurrentTypeColor():Number
	{
		switch(m_CurrentType)
		{
			case DEPLEATED_URANIUM_BUFF:
				return 0x9B52CE;
			case DRAGONS_BREATH_BUFF:
				return Colors.e_ColorTrueBandBuffHighlight;
			case ARMOR_PIERCING_BUFF:
				return Colors.e_ColorSupportSpellHighlight; 
			case ANIMA_BUFF:
				return Colors.e_ColorHealBuffHighlight;
			default:
				return Colors.e_ColorWhite;
		}
	}
}