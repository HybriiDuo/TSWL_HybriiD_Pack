import flash.geom.Point;
import flash.geom.Rectangle;
import GUI.Wallet.WalletWindow
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.Utils.LDBFormat;


var m_VisibleValue:DistributedValue;
var m_WalletWindow:WalletWindow;

function onLoad()
{
    m_WalletWindow = attachMovie("WalletWindowComponent", "m_WalletWindow", getNextHighestDepth());
    m_WalletWindow.SetContent( "WalletWindow" );
    m_WalletWindow.SignalClose.Connect( SlotCloseWallet, this );
    m_WalletWindow.SetTitle(LDBFormat.LDBGetText("Tokens", "Tokens"));
    m_WalletWindow.ShowFooter( false );
    m_WalletWindow.ShowResizeButton( false );
    m_WalletWindow.ShowStroke( false );
    m_WalletWindow.SetSize( 415, 250 );
    
    m_WalletWindow._x = 100;
    m_WalletWindow._y = 100;
}

function OnModuleDeactivated():Archive
{
	var archive:Archive = new Archive();
	archive.AddEntry("WindowX", m_WalletWindow._x);
	archive.AddEntry("WindowY", m_WalletWindow._y);
	return archive;       
}


function OnModuleActivated(config:Archive)
{
	if (config != undefined)
	{
		m_WalletWindow._x = config.FindEntry("WindowX", 100);
		m_WalletWindow._y = config.FindEntry("WindowY", 100);
	}
}


function SlotCloseWallet()
{
    DistributedValue.SetDValue("wallet_window", false);
}
