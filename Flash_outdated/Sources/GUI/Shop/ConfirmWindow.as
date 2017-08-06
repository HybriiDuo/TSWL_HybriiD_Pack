//Imports
import com.GameInterface.Game.Character;
import com.Components.WinComp;
import com.GameInterface.ShopInterface;
import com.Utils.LDBFormat;
import com.Utils.Signal;

//Class
class GUI.Shop.ConfirmWindow extends WinComp
{
    //Constants
    
    //Properties
	
    //Constructor
    public function ConfirmWindow()
	{
        super();
        
		SetTitle(LDBFormat.LDBGetText("MiscGUI", "PurchaseConfirm_Title"));
	    SetContent("ConfirmContent");
        SetPadding(8);
            
        ShowCloseButton(true);
        ShowStroke(true);
        ShowFooter(true);
        ShowResizeButton(false);
		
		this.GetContent().SignalClose.Connect(Close, this);
		Character.SignalCharacterEnteredReticuleMode.Connect(CloseButtonHandler, this);
		
		this._x = Stage["visibleRect"].width/2;
		this._y = Stage["visibleRect"].height/2;
	}
	
	public function Layout()
	{
		super.Layout();
		this._x = Stage["visibleRect"].width/2 - this._width/2;
		this._y = Stage["visibleRect"].height/2 - this._height/2;
	}
	
	public function CloseButtonHandler()
	{
		this.GetContent().Close();
	}
	
	private function Close()
	{
		Character.SetReticuleMode();
		this.removeMovieClip();
	}
}