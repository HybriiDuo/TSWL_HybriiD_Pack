import com.Utils.ID32;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Character;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;

#include "CastBar.as"

var m_FlashCharacter:Character
var m_EditModeMask:MovieClip;

function onLoad()
{
	Init();
	CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	m_FlashCharacter = Character.GetClientCharacter();
	if(m_FlashCharacter != undefined)
	{
		SetSelectedCharacter(m_FlashCharacter.GetOffensiveTarget());
		m_FlashCharacter.SignalOffensiveTargetChanged.Connect(SlotOffensiveTargetChanged, this);
	}
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
}

function SlotClientCharacterAlive()
{
	m_FlashCharacter = Character.GetClientCharacter();
	SetSelectedCharacter(m_FlashCharacter.GetOffensiveTarget());
	m_FlashCharacter.SignalOffensiveTargetChanged.Connect(SlotOffensiveTargetChanged, this);
}

function SlotOffensiveTargetChanged(targetID:ID32)
{
	SetSelectedCharacter(targetID); 	
}

function SetSelectedCharacter(characterID:ID32)
{
	var character:Character= Character.GetCharacter(characterID);
  	SetCharacter(character);
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if (edit)
	{
		LayoutEditModeMask();
		m_ForceVisible = true;
		i_Castbar._visible = true;
		m_SpellNameText.htmlText = LDBFormat.LDBGetText("GenericGUI", "Target");
    	m_SpellNameText._visible = true;
		m_InterruptBlocker._visible = true;
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("TargetCastbarScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		m_ForceVisible = false;
		i_Castbar._visible = false;
    	m_SpellNameText._visible = false;
		m_InterruptBlocker._visible = false;
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("TargetCastbarScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "TargetCastbarX" );
	var newY:DistributedValue = DistributedValue.Create( "TargetCastbarY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);	
}

function LayoutEditModeMask()
{
	m_EditModeMask._x = i_Castbar._x - 5;
	m_EditModeMask._y = m_SpellNameText._y - 5;
	m_EditModeMask._width = i_Castbar._width + 10;
	m_EditModeMask._height = m_SpellNameText._height + i_Castbar._height + 10;
}