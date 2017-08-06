import com.GameInterface.DistributedValue;
import com.GameInterface.Utils;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.Signal;
import com.Utils.Text;
import flash.filters.DropShadowFilter;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import flash.geom.Point;
import com.GameInterface.Log;
import com.Utils.LDBFormat;
import GUIFramework.SFClipLoader;

var m_Character:Character;
var m_TotalFrames:Number;
var m_ScreenWidth:Number = 0;
var m_CurrentXPBar:MovieClip;
var m_NumSegments:Number = 1;
//var m_Padding:Number = 2;
var m_LastXP:Number;
var m_Format:TextFormat;
var m_XPText:TextField;
var m_Shadow:DropShadowFilter
var m_FIFOOverwriteThreshold:Number = 30; // the percentage of a tween that must be completed if we want to create a new fifo object, if not reached, we update the text of the fifo instead.
var m_UID:Number = 0; /// if multiple instances of  the xp FIFO, use and increment this to create unique instances

var m_TDB_XP:String = LDBFormat.LDBGetText("MiscGUI", "xp")+":";
var m_TDB_SP:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "SP") + ":"; 
var m_TDB_AP:String = LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsAbbreviation") + ":";

var m_TDB_NEXT_AP:String = LDBFormat.LDBGetText("MiscGUI", "NextAP")+":";
var m_TDB_NEXT_PP:String = LDBFormat.LDBGetText("MiscGUI", "NextPP")+":";
var m_TDB_NEXT_LEVEL:String = LDBFormat.LDBGetText("MiscGUI", "NextLevel")+":";
var m_TDB_MAX_LEVEL:String = LDBFormat.LDBGetText("MiscGUI", "MaxLevel");

var m_XPBarAlignmentMonitor:DistributedValue = DistributedValue.Create("XPBarAlignment");

function onLoad()
{
    Log.Info2("XpBar", "onLoad()");

    m_Format = new TextFormat;
    m_Format.font = "_StandardFont";
    m_Format.size = 10;
    m_Format.color = 0xFFFFFF;
    
    SFClipLoader.SignalDisplayResolutionChanged.Connect(SlotResolutionChange, this);
        
    SlotClientCharacterAlive();
    CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
    
    m_Shadow = new DropShadowFilter( 1, 35, 0x000000, 0.7, 1, 2, 2, 3, false, false, false );
    
    m_XPText = this.createTextField("xpinfo", this.getNextHighestDepth(), 0, textY, 0, 0);
    m_XPText.autoSize = "left";
    m_XPText.selectable = false;
    m_XPText.setNewTextFormat( m_Format );
    m_XPText.filters = [ m_Shadow ];
    m_XPText._visible = true;
   
    m_TotalFrames = m_XPBarSegment_0._totalframes;
	
	m_Handle_0.onRollOver = Delegate.create(this, ShowAPText);	
	m_Handle_1.onRollOver = Delegate.create(this, ShowPPText);	
    m_Background.onRollOver = Delegate.create(this, ShowLevelText);
    
    m_Background.onRollOut = m_Handle_0.onRollOut = m_Handle_1.onRollOut = function()
    {
      //  Log.Info2("XpBar", "out");
        m_XPText._visible = false;
    }
    
    m_Background.onReleaseOutside = function()
    {
        m_XPText._visible = false;
    }
    
	m_XPBarAlignmentMonitor.SignalChanged.Connect(XPBarAlignmentChanged, this);
	XPBarAlignmentChanged();
    Layout();
    
    m_Character = Character.GetClientCharacter();
    UpdateXPBar( GetXP(), false );       
}

function SlotClientCharacterAlive()
{
    m_Character = Character.GetClientCharacter();
    m_LastXP = GetXP();
    
    if (m_Character != undefined)
    {
      //  m_Character.SignalTokenAmountChanged.Connect( SlotTokenAmountChanged, this );
        m_Character.SignalStatChanged.Connect( SlotStatChanged, this );
    }
}

function ShowAPText():Void
{
	m_XPText.text = m_TDB_NEXT_AP + " " + Text.AddThousandsSeparator(GetXP()) + "/" + Text.AddThousandsSeparator(GetNextAP());
	var xpNumberWidth:Number = m_XPText._width + 10;
			
	if ( (m_Handle_0._x + m_Handle_0._width + xpNumberWidth) > m_ScreenWidth  )
	{
		m_XPText._x = m_Handle_0._x - xpNumberWidth;
	}
	else
	{
	   m_XPText._x =  m_Handle_0._x + m_Handle_0._width + 10;
	}

	m_XPText._visible = true;
}

function ShowPPText():Void
{
	m_XPText.text = m_TDB_NEXT_PP + " " + Text.AddThousandsSeparator(GetXP()) + "/" + Text.AddThousandsSeparator(GetNextPP());
	var xpNumberWidth:Number = m_XPText._width + 10;
			
	if ( (m_Handle_1._x + m_Handle_1._width + xpNumberWidth) > m_ScreenWidth  )
	{
		m_XPText._x = m_Handle_1._x - xpNumberWidth;
	}
	else
	{
	   m_XPText._x =  m_Handle_1._x + m_Handle_1._width + 10;
	}

	m_XPText._visible = true;
}

function ShowAPPPText():Void
{
	m_XPText.text = m_TDB_NEXT_AP + " " + Text.AddThousandsSeparator(GetXP()) + "/" + Text.AddThousandsSeparator(GetNextAP()) + "   " + m_TDB_NEXT_PP + " " + Text.AddThousandsSeparator(GetXP()) + "/" + Text.AddThousandsSeparator(GetNextPP());
	var xpNumberWidth:Number = m_XPText._width + 10;
			
	if ( (m_Handle_1._x + m_Handle_1._width + xpNumberWidth) > m_ScreenWidth  )
	{
		m_XPText._x = m_Handle_1._x - xpNumberWidth;
	}
	else
	{
	   m_XPText._x =  m_Handle_1._x + m_Handle_1._width + 10;
	}

	m_XPText._visible = true;
}

function ShowLevelText():Void
{
	if (GetNextLevelXP() != 0)
	{
		m_XPText.text = m_TDB_NEXT_LEVEL + " " + Text.AddThousandsSeparator(GetXP()) + "/" + Text.AddThousandsSeparator(GetNextLevelXP());
	}
	else
	{
		m_XPText.text = m_TDB_MAX_LEVEL.toUpperCase() + "   " + m_TDB_NEXT_AP + " " + Text.AddThousandsSeparator(GetNextAP() - GetXP()) + "   " + m_TDB_NEXT_PP + " " + Text.AddThousandsSeparator(GetNextPP() - GetXP());
	}
	var mouseX:Number = (m_Background._xmouse * (m_ScreenWidth / 100));
	var xpNumberWidth:Number = m_XPText._width + 10;
					
	if ( (mouseX + xpNumberWidth) > m_ScreenWidth  )
	{
		m_XPText._x = mouseX - xpNumberWidth;
	}
	else
	{
	   m_XPText._x =  mouseX + 5
	}

	m_XPText._visible = true;
}

function GetNextAP():Number
{
	if (m_Character != null)
	{
		var xp:Number = GetXP();
		return xp + Character.GetXPToNextAP();
	}
	return 0;
}

function GetNextPP():Number
{
	if (m_Character != null)
	{
		var xp:Number = GetXP();
		return xp + Character.GetXPToNextSP();
	}
	return 0;
}

function GetNextLevelXP() : Number
{
	if(m_Character != null)
    {
		return m_Character.GetStat( Enums.Stat.e_NextXP, 2 );
    }
    return 0;
}

function GetLastLevelXP() : Number
{
	if(m_Character != null)
    {
		return m_Character.GetStat( Enums.Stat.e_LastXP, 2 );
    }
    return 0;
}

function GetAP() : Number
{
    if(m_Character != null)
    {
        return m_Character.GetTokens( 1 );
    }
    return 0;
}

function GetXP() : Number
{
    if(m_Character != null)
    {
        var XP:Number = m_Character.GetStat( Enums.Stat.e_XP, 2 );
		if (XP < 0)
		{
			XP = XP + 4294967296;
		}
		else
		{
			XP = XP + 1000000000 * m_Character.GetStat( Enums.Stat.e_XP_Billions);
		}
		return XP;
    }
    return 0;
}

function GetSP() : Number
{
    if(m_Character != null)
    {
        return m_Character.GetTokens( 2 );
    }
    return 0;
}

function SlotResolutionChange()
{
    var xp = GetXP();

    Layout();
    UpdateXPBar( xp,false );
}

function SlotStatChanged(p_Stat:Number)
{
    if( p_Stat == Enums.Stat.e_XP || p_Stat == Enums.Stat.e_XP_Billions)
    {
        var oldXP:Number = m_LastXP;
        var newXP:Number = GetXP();
        
        Log.Info2("XpBar", "SlotStatChanged(XP, " + newXP + ")");

        UpdateXPBar( newXP, true );
    }
	else if (p_Stat == Enums.Stat.e_NextXP || p_Stat == Enums.Stat.e_LastXP || p_Stat == Enums.Stat.e_Level || 
			 p_Stat == Enums.Stat.e_XPtoNextAP || p_Stat == Enums.Stat.e_XPtoNextSP)
	{
		UpdateXPBar(GetXP(), false);
	}
}
/*
function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number)
{
    Log.Info2("XpBar", "SlotTokenAmountChanged(" + id + "," + newValue + ", " + oldValue + ")");

    /// TODO: create the enum for the token enum
    if(newValue > oldValue && ( id == 1 || id == 2) )
    {
        var pos:Point = m_Character.GetScreenPosition(_global.Enums.AttractorPlace.e_CameraAim);
        pos.x += Stage["visibleRect"].x;
        pos.y += Stage["visibleRect"].y;
		var pointsGet:MovieClip
		if(id == 1)
        {
			pointsGet = this.attachMovie("AnimaPointsGet", "pointget", this.getNextHighestDepth());
		}
		else if (id == 2)
		{
			pointsGet = this.attachMovie("SkillPointsGet", "pointget", this.getNextHighestDepth());
		}
        this.globalToLocal(pos);
        pointsGet._x = pos.x;
        pointsGet._y =  pos.y - 100;
        pointsGet._xscale = 50;
        pointsGet._yscale = 50;
        pointsGet.play();
    }
}
*/
/// every time there is a change to the screen or there is an onload, Layout is called
function Layout()
{
    var visibleRect:Object = Stage["visibleRect"];
    var x:Number = visibleRect.x;
    var y:Number = visibleRect.y;
    m_ScreenWidth = visibleRect.width;
    var height:Number = visibleRect.height;

	var segmentWidth:Number = m_ScreenWidth / m_NumSegments
    m_Background._xscale = m_ScreenWidth;
    m_Background._x = 0;
    
	m_XPBarSegment_0._x = 0;
	m_XPBarSegment_0._xscale = segmentWidth;
	m_Handle_2._x = m_ScreenWidth - 5; 
	m_Handle_2.gotoAndStop("level");
}

function ShowXPFIFO(xp:Number)
{
    var newXP:Number = xp - m_LastXP;
    if (newXP <= 0 || newXP >= 10000000)
    {
        return;
    }
    
    var xpNum:MovieClip = this["i_XPNumber"];
    
    if (xpNum)
    {
        if (xpNum._alpha > (100 - m_FIFOOverwriteThreshold) )
        {
            xpNum["xp"] += newXP;
            xpNum.textField.text = "+" + xpNum["xp"] ;
            return;
        }
        else
        {
            m_UID++;
            xpNum._name = "i_XPNumber"+m_UID; 
        }
    }
    
    var xpFIFO:MovieClip = this.attachMovie("_Number", "i_XPNumber", this.getNextHighestDepth());
    xpFIFO["xp"] = newXP;
	xpFIFO.textField.autoSize = "right";
    xpFIFO.textField.text = "+" + Text.AddThousandsSeparator(newXP);
	
	var xpFIFOX:Number = m_CurrentXPBar.i_Bar.getBounds(this).xMax
	var maxXpFIFOX:Number = Stage["visibleRect"].width - xpFIFO._width;
	if (xpFIFOX < xpFIFO._width)
	{
		xpFIFOX = xpFIFO._width - 25; // 25 is the with of the xp text
	}
	else if (xpFIFOX > maxXpFIFOX)
	{
		xpFIFOX = maxXpFIFOX + 25; // 25 is the with of the xp text
	}
	
    xpFIFO._x = xpFIFOX; // m_CurrentXPBar.i_Bar.getBounds(this).xMax
    xpFIFO._y = m_CurrentXPBar._y;
    xpFIFO.tweenTo( 1.4, { _alpha:0, _xscale:120, _yscale:120, _y:m_CurrentXPBar._y -150 }, None.easeNone);
    xpFIFO.onTweenComplete = function()
    {
        this.removeMovieClip();
    }
}

function UpdateXPBar( xp:Number, showFIFO:Boolean )
{
	m_LevelDisplay.m_LevelText.text = m_Character.GetStat( Enums.Stat.e_Level, 2 );
	
	var nextApXP:Number = GetNextAP();
	var nextPpXP:Number = GetNextPP();
	var nextLevelXP:Number = GetNextLevelXP();
	var lastLevelXP:Number = GetLastLevelXP();
	var totalLevelXP:Number = nextLevelXP - lastLevelXP;
	
	m_Handle_0._visible = m_Handle_1._visible = false;
	var xpThisLevel:Number = xp - GetLastLevelXP();
	
	var oldPos = m_CurrentXPBar.i_Bar.getBounds( this );
	
	if (nextLevelXP != 0)
	{
		if (nextApXP < nextLevelXP)
		{
			m_Handle_0._visible = true;
			var nextApRatio:Number = (nextApXP - lastLevelXP) / totalLevelXP;		
			m_Handle_0._x = m_Background._width * nextApRatio;
			m_Handle_0.gotoAndStop("active");
		}
		if (nextPpXP < nextLevelXP)
		{
			m_Handle_1._visible = true;
			var nextPpRatio:Number = (nextPpXP - lastLevelXP) / totalLevelXP;
			m_Handle_1._x = m_Background._width * nextPpRatio;
			
			//Since PP and AP will be awarded at the same point half the time, we need a special state
			if (nextApXP == nextPpXP)
			{
				m_Handle_0._visible = false;
				m_Handle_1.onRollOver = Delegate.create(this, ShowAPPPText);
				m_Handle_1.gotoAndStop("activeAndPassive");
			}
			else
			{
				m_Handle_1.onRollOver = Delegate.create(this, ShowPPText);
				m_Handle_1.gotoAndStop("passive");
			}
		}
		
		var xpLevel:Number = xpThisLevel / totalLevelXP;
		frame = Math.floor( ( xpLevel ) * (m_TotalFrames));
		m_CurrentXPBar = m_XPBarSegment_0;
		m_CurrentXPBar.gotoAndStop( (frame % 500) );
	}
	//Max level
	else
	{
		m_CurrentXPBar = m_XPBarSegment_0;
		m_CurrentXPBar.gotoAndStop(500);
	}
    
    if (showFIFO)
    {
        ShowXPFIFO( xp );
    }
    m_LastXP = xp;
    
    var newPos = m_CurrentXPBar.i_Bar.getBounds(this);
    m_XPBarHook._x = newPos.xMax;
     
    // Show effect if not too small chunk.
    var size = (oldPos.xMax - oldPos.xMin) - (newPos.xMax - newPos.xMin);

    if( size < -15 )
    {
        var y:Number = m_CurrentXPBar._y;
        var height:Number = m_CurrentXPBar._height
        var clip:MovieClip = createEmptyMovieClip( "Fade", getNextHighestDepth() );
		m_LevelDisplay.swapDepths(getNextHighestDepth());
        clip.beginFill(0xFFFFFF);
        clip.lineTo(size, 0);
        clip.lineTo(size, height);
        clip.lineTo(0, height);
        clip.lineTo(0, 0);
        
        clip._x = newPos.xMax
        clip._y = y

        clip.tweenTo( 1, { _alpha:0 }, None.easeNone);
        clip.onTweenComplete = function()
        {
            this.removeMovieClip();
        }
    }
}

function XPBarAlignmentChanged()
{
	var xpBarAlignment:Number = DistributedValue.GetDValue( "XPBarAlignment", 1);
	if (xpBarAlignment == 0) 
	{ 
		m_XPText._y = 0; 
		m_LevelDisplay._y = 0;
		m_LevelDisplay.m_Top._visible = true;
		m_LevelDisplay.m_Bottom._visible = false;
	}
	else
	{
		m_XPText._y = -15;
		m_LevelDisplay._y = -5.9;
		m_LevelDisplay.m_Top._visible = false;
		m_LevelDisplay.m_Bottom._visible = true;
	}
}

