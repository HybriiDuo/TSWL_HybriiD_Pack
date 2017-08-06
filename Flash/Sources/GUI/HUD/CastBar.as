/// All logic for the castbar
import com.GameInterface.Command;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import mx.utils.Delegate;

var m_IntervalId:Number;
var m_Increments:Number;
var m_TotalFrames:Number; 
var m_StopFrame:Number;

var m_ProgressBarType:Number;
var m_AbilityIsUninterruptable:Boolean;
var m_Character:Character;

var m_ForceVisible:Boolean;

function Init()
{
	m_ForceVisible = false;
    m_Increments = 20; // The smoothness of updates (ms between each redraw)
    m_TotalFrames = i_Castbar._totalframes;
    m_ProgressBarType = _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill;
    
    m_StopFrame = ((m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty) ? m_TotalFrames : 1);

    // remove the looks of the castbar on load
    i_Castbar._visible = m_ForceVisible;
    i_Castbar.gotoAndStop(m_StopFrame);
	m_InterruptBlocker._visible = false;
	m_AbilityIsUninterruptable = false;
}

function onUnload()
{
    clearInterval( m_IntervalId );
}

function SetCharacter(character:Character)
{
	if (m_Character != undefined)
    {
        m_Character.SignalCommandStarted.Disconnect( SlotSignalCommandStarted, this);
        m_Character.SignalCommandEnded.Disconnect( SlotSignalCommandEnded, this);
        m_Character.SignalCommandAborted.Disconnect( SlotSignalCommandAborted, this);
		m_Character.SignalStatChanged.Disconnect( SlotStatChanged, this);
    }
    if ( character != undefined && character.GetID().GetType() != _global.Enums.TypeID.e_Type_GC_Character )
    {
        character = undefined;
    }
	clearInterval( m_IntervalId );
    i_Castbar._visible = m_ForceVisible;
    m_SpellNameText._visible = m_ForceVisible;
	m_InterruptBlocker._visible = false;
    
    m_Character = character
    if (m_Character != undefined)
    {
        m_Character.SignalCommandStarted.Connect( SlotSignalCommandStarted, this);
        m_Character.SignalCommandEnded.Connect( SlotSignalCommandEnded, this);
        m_Character.SignalCommandAborted.Connect( SlotSignalCommandAborted, this);
		m_Character.SignalStatChanged.Connect( SlotStatChanged, this);
        m_Character.ConnectToCommandQueue();
    }
}

/// Signal sent when a command is started.
/// @param name:String    The name of the command.
/// @param progressBarType:The type of progressbar _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill or _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty
function SlotSignalCommandStarted( name:String, progressBarType:Number, uninterruptable:Boolean) : Void
{
    m_ProgressBarType = progressBarType;
	m_AbilityIsUninterruptable = uninterruptable;
	m_InterruptBlocker._visible = m_AbilityIsUninterruptable || (m_Character.GetStat(_global.Enums.Stat.e_Uninterruptable, 2) > 0);
    
    if( i_Castbar._currentframe != 1 )
    {
        clearInterval(m_IntervalId);
    }

    i_Castbar.gotoAndStop( m_StopFrame );
    m_IntervalId = setInterval( Delegate.create( this, ExecuteCallback ), m_Increments );
    i_Castbar._visible = true;
    
    m_SpellNameText.htmlText = name;
    m_SpellNameText._visible = true;
}

function ExecuteCallback(): Void
{
    if (m_Character != undefined)
    {
        var scaleNum:Number = Math.min( Math.round( m_Character.GetCommandProgress() * m_TotalFrames ), m_TotalFrames);

        if (m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty)
        {
            scaleNum = m_TotalFrames - scaleNum;
        }
        i_Castbar.gotoAndStop(scaleNum);
    }
}

function SlotSignalCommandEnded() : Void
{
	clearInterval( m_IntervalId );
    i_Castbar._visible = m_ForceVisible;
    m_SpellNameText._visible = m_ForceVisible;
	m_InterruptBlocker._visible = m_ForceVisible;
	m_AbilityIsUninterruptable = false;
	i_Castbar.stop();
}

function SlotSignalCommandAborted() : Void
{
	clearInterval( m_IntervalId );
    i_Castbar._visible = m_ForceVisible;
    m_SpellNameText._visible = m_ForceVisible;
	m_InterruptBlocker._visible = m_ForceVisible;
	m_AbilityIsUninterruptable = false;
}

function SlotStatChanged(statID:Number) : Void
{
	if (i_Castbar._visible && statID == _global.Enums.Stat.e_Uninterruptable)
	{
		m_InterruptBlocker._visible = m_ForceVisible || m_AbilityIsUninterruptable || (m_Character.GetStat(_global.Enums.Stat.e_Uninterruptable, 2) > 0);
	}
}

function ResizeHandler() : Void
{
}
