import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;

var m_Window:MovieClip;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
	this._xscale = this._yscale = DistributedValue.GetDValue("GUIResolutionScale", 1) * 100;
	var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "MembershipPurchaseTitle");
	
	m_Window.SetTitle(windowTitle, "left");
	m_Window.SetPadding(10);
	m_Window.SetContent("MembershipPurchaseContent");
	
	m_Window.ShowCloseButton(true);
	m_Window.ShowStroke(false);
	m_Window.ShowResizeButton(false);
	m_Window.ShowFooter(false);
	
	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
	
	m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}

function CloseWindowHandler():Void
{
	DistributedValue.SetDValue("membershipPurchase_window", false);
}