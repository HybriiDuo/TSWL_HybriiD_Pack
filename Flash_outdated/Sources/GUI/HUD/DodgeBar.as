/// All logic for the castbar
import com.GameInterface.Command;
import com.GameInterface.Utils;
import com.GameInterface.ProjectUtils;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import mx.utils.Delegate;

var m_IntervalId:Number;
var m_Increments:Number;
var m_TotalFrames:Number; 
var m_StopFrame:Number;

var m_ProgressBarType:Number;

var m_DodgeBuffSpellID:Number;

var m_Character:Character;

var m_BuffStartTime:Number;
var m_BuffDuration:Number;

var m_EditModeMask:MovieClip;

function Init()
{
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
    m_Increments = 20; // The smoothness of updates (ms between each redraw)
    m_TotalFrames = i_Castbar._totalframes;
    m_ProgressBarType = _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill;
    
    m_StopFrame = ((m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty) ? m_TotalFrames : 1);

    // remove the looks of the castbar on load
    i_Castbar._visible = false;
    i_Castbar.gotoAndStop(m_StopFrame);
    
    m_DodgeBuffSpellID = ProjectUtils.GetUint32TweakValue("DashCooldownSpellID");
    m_SpellNameText.htmlText = LDBFormat.LDBGetText( "MiscGUI", "ActiveDodge" );
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
}

function onUnload()
{
    clearInterval( m_IntervalId );
}

function SetCharacter(character:Character)
{
	clearInterval( m_IntervalId );
    i_Castbar._visible = false;
    m_SpellNameText._visible = false;
    
    m_Character = character
    if (m_Character != undefined)
    {
        m_Character.SignalInvisibleBuffAdded.Connect( SlotBuffAdded, this);
        m_Character.SignalInvisibleBuffUpdated.Connect( SlotBuffUpdated, this);
        m_Character.SignalBuffRemoved.Connect( SlotBuffRemoved, this);
    }
}

/// Signal sent when a command is started.
/// @param name:String    The name of the command.
/// @param progressBarType:The type of progressbar _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill or _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty
function SlotBuffAdded(buffId:Number) : Void
{
    if (buffId != m_DodgeBuffSpellID || m_Character == undefined) { return; }
    
    if( i_Castbar._currentframe != 1 )
    {
        clearInterval(m_IntervalId);
    }
    i_Castbar.gotoAndStop( m_StopFrame );
    
    m_BuffStartTime = Utils.GetNormalTime();
    m_BuffDuration = m_Character.m_InvisibleBuffList[m_DodgeBuffSpellID].m_TotalTime/1000 - m_BuffStartTime;
    m_IntervalId = setInterval( Delegate.create( this, ExecuteCallback ), m_Increments );
    
    i_Castbar._visible = true;
    m_SpellNameText._visible = true;
}

function ExecuteCallback(): Void
{
    if (m_Character != undefined)
    {
        var percentCompleteFactor:Number = (Utils.GetNormalTime() - m_BuffStartTime) / m_BuffDuration;
        var scaleNum:Number = Math.min( Math.round(percentCompleteFactor * m_TotalFrames), m_TotalFrames);

        if (m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty)
        {
            scaleNum = m_TotalFrames - scaleNum;
        }
        i_Castbar.gotoAndStop(scaleNum);
    }
}

function SlotBuffUpdated(buffId:Number) : Void
{
}

function SlotBuffRemoved(buffId:Number) : Void
{
    if (buffId != m_DodgeBuffSpellID) { return; }
    
	clearInterval( m_IntervalId );
	if (!m_EditModeMask._visible)
	{
		i_Castbar._visible = false;
		m_SpellNameText._visible = false;
	}
}

function ResizeHandler() : Void
{
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if (edit)
	{
		LayoutEditModeMask();
		i_Castbar._visible = true;
    	m_SpellNameText._visible = true;
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("DodgebarScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		if (m_Character.m_InvisibleBuffList[m_DodgeBuffSpellID] == undefined)
		{
			i_Castbar._visible = false;
			m_SpellNameText._visible = false;
		}
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("DodgebarScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "DodgebarX" );
	var newY:DistributedValue = DistributedValue.Create( "DodgebarY" );	
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
