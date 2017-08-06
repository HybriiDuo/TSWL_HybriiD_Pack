import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.DistributedValue;

var m_Overlay:MovieClip;
var m_OverlayTop:MovieClip;
var m_OverlayText:MovieClip;
var m_EditModeMask:MovieClip;

function onLoad()
{
	//m_Overlay = this.attachMovie("Vignette-All", "Vignette-All", this.getNextHighestDepth());
	m_Overlay = this.attachMovie("Vignette-Background", "Vignette-Background", this.getNextHighestDepth());
	m_OverlayTop = this.attachMovie("Vignette-Top", "Vignette-Top", this.getNextHighestDepth());
	m_OverlayText = this.attachMovie("m_OverlayText", "m_OverlayText", this.getNextHighestDepth());
	m_OverlayText.m_OverlayText.htmlText = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "MouseModeOverlayContinue"), "<variable name='hotkey:Toggle_Target_Mode'/>");
	Layout();

	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);

}

function Layout()
{
	m_Overlay._x = 0;
	m_Overlay._y = 25; // Placing it below the top bar
	m_Overlay._width = (Stage["visibleRect"].width);
	m_Overlay._height = (Stage["visibleRect"].height) - 25;
	m_OverlayText._x = (Stage["visibleRect"].width - m_OverlayText._width) / 2;
	//m_OverlayText._y = (Stage["visibleRect"].height - m_OverlayText._height) / 2;
	m_OverlayText._y = 75;

	// Top bar graphics, don't stretch this one
	m_OverlayTop._x = (Stage["visibleRect"].width - m_OverlayTop._width) / 2;
	m_OverlayTop._y = 25;

	m_OverlayText.m_OverlayText.selectable = false;
	m_OverlayText.m_OverlayText.mouseEnabled = false;
	m_OverlayText.m_OverlayText.mouseChildren = false;
	
}


function ResizeHandler( w, h ,x, y )
{
	Layout();
}

function SlotSetGUIEditMode(edit:Boolean)
{
	if (edit)
	{
		if (m_EditModeMask != undefined)
		{
			m_EditModeMask.removeMovieClip();
			m_EditModeMask = undefined;
		}
		m_EditModeMask = this.attachMovie("EditModeMask", "EditModeMask", this.getNextHighestDepth());

		if (DistributedValueBase.GetDValue("UseIconX") == 0)
		{
			m_EditModeMask._x = Stage["visibleRect"].width / 2 + 150;
		}
		else
		{
			m_EditModeMask._x = DistributedValueBase.GetDValue("UseIconX") ;
		}

		if (DistributedValueBase.GetDValue("UseIconY") == 0)
		{
			m_EditModeMask._y = Stage["visibleRect"].height / 2 -13;
		}
		else
		{
			m_EditModeMask._y = DistributedValueBase.GetDValue("UseIconY") ;
		}

		m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
		m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	}
	else
	{
		if (m_EditModeMask != undefined)
		{
			m_EditModeMask.removeMovieClip();
			m_EditModeMask = undefined;
		}
	}
}

function SlotEditMaskPressed()
{
	m_EditModeMask.startDrag(false
	, 0 // left
	, 0 // top
	, Stage["visibleRect"].width - m_EditModeMask._width // right
	, Stage["visibleRect"].height - m_EditModeMask._height // bottom
	);
}

function SlotEditMaskReleased()
{
	m_EditModeMask.stopDrag();

	var newX:DistributedValue = DistributedValue.Create( "UseIconX" );
	var newY:DistributedValue = DistributedValue.Create( "UseIconY" );	
	newX.SetValue(m_EditModeMask._x);
	newY.SetValue(m_EditModeMask._y);
}