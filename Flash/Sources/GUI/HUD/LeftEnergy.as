import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import mx.utils.Delegate;

#include "EnergyBars.as"

var m_EditModeMask:MovieClip;

//Check EnergyBars.as for member variables

function onLoad() 
{
	//This is what makes this the left weapon
	//almost all other code should be done in EnergyBars, as it will be the same for the right weapon!
	m_WeaponSlot = _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot;
	
	Init();
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if (edit)
	{
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("LeftEnergyScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		if (m_FakeResource != undefined)
		{
			m_FakeResource.removeMovieClip();
			m_FakeResource = undefined;
		}
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("LeftEnergyScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "LeftEnergyX" );
	var newY:DistributedValue = DistributedValue.Create( "LeftEnergyY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);	
}

function LayoutEditModeMask()
{
	if (m_WeaponResource != undefined)
	{
		m_EditModeMask._x = m_WeaponResource._x - 5;
		m_EditModeMask._y = m_WeaponResource._y - 5;
		m_EditModeMask._width = m_WeaponResource._width + 10;
		m_EditModeMask._height = m_WeaponResource._height + 10;
	}
	else
	{
		if (m_FakeResource == undefined)
		{
			m_FakeResource = this.attachMovie("Player_Resource_Blade", "m_FakeResource", this.getNextHighestDepth());
		}
		m_EditModeMask._x = m_FakeResource._x - 5;
		m_EditModeMask._y = m_FakeResource._y - 5;
		m_EditModeMask._width = m_FakeResource._width + 10;
		m_EditModeMask._height = m_FakeResource._height + 10;
	}
	m_EditModeMask.swapDepths(this.getNextHighestDepth());
}