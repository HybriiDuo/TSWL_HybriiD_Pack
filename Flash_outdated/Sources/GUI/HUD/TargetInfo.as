import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import mx.utils.Delegate;

#include "CharacterInfo.as"

var m_FlashCharacter:Character;

var m_EditModeMask:MovieClip;

function onLoad()
{
	m_EditModeMask._visible = false;
    ShowName(true);
	m_IsPlayer = false;
    Initialize();
    Character.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
    m_FlashCharacter = Character.GetClientCharacter();
    if(m_FlashCharacter != undefined)
    {
        SetSelectedDynel(m_FlashCharacter.GetOffensiveTarget());
        m_FlashCharacter.SignalOffensiveTargetChanged.Connect(SlotOffensiveTargetChanged, this);
    }
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
}

function onUnload()
{
    Character.SignalClientCharacterAlive.Disconnect(SlotClientCharacterAlive, this);
}

function SlotClientCharacterAlive()
{
    m_FlashCharacter = Character.GetClientCharacter();
    SetSelectedDynel(m_FlashCharacter.GetOffensiveTarget());
    m_FlashCharacter.SignalOffensiveTargetChanged.Connect(SlotOffensiveTargetChanged, this);
}

function SlotOffensiveTargetChanged(targetID:ID32)
{
    SetSelectedDynel(targetID); 	
}

function SetSelectedDynel(dynelID:ID32)
{
    var dynel:Dynel= Dynel.GetDynel(dynelID);
    SetDynel(dynel)
	if (dynel == undefined && m_EditModeMask._visible)
	{
		SetSelectedDynel(Character.GetClientCharID());
		m_RankContainer._visible = false;
	}
	m_EditModeMask.swapDepths(this.getNextHighestDepth());
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if(edit)
	{
		if (m_Dynel == undefined)
		{
			SetSelectedDynel(Character.GetClientCharID());
			m_RankContainer._visible = false;
		}
		m_EditModeMask.swapDepths(this.getNextHighestDepth());
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("TargetInfoScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		if (m_Dynel == Dynel.GetDynel(Character.GetClientCharID()))
		{
			SetSelectedDynel(undefined)
		}
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("TargetInfoScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "TargetInfoX" );
	var newY:DistributedValue = DistributedValue.Create( "TargetInfoY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);	
}

function LayoutEditModeMask()
{
	m_EditModeMask._x = m_HealthBar.m_AegisDamageType._x - 5;
	m_EditModeMask._y = 0;
	m_EditModeMask._width = m_HealthBar._width + 25;
	m_EditModeMask._height = m_HealthBar._y + m_HealthBar._height + 15;
}