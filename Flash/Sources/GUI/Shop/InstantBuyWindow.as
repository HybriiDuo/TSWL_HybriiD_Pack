//Imports
import com.GameInterface.Game.Character;
import com.Components.WinComp;
import com.GameInterface.ShopInterface;
import com.Utils.LDBFormat;
import com.Utils.Signal;

//Class
class GUI.Shop.InstantBuyWindow extends WinComp
{
    //Constants
    
    //Properties
	
    //Constructor
    public function InstantBuyWindow()
	{
        super();
        
		SetTitle(LDBFormat.LDBGetText("MiscGUI", "InstantBuy_Title"));
	    SetContent("InstantBuyContent");
        SetPadding(8);
            
        ShowCloseButton(true);
        ShowStroke(false);
        ShowFooter(false);
        ShowResizeButton(false);
		
		this.GetContent().SignalClose.Connect(CloseButtonHandler, this);
		Character.SignalCharacterEnteredReticuleMode.Connect(CloseButtonHandler, this);
		
        //Do this after we know how many items
		//SetSize(MIN_WIDTH, MIN_HEIGHT);
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
		Character.SetReticuleMode();
		this.removeMovieClip();
	}
}