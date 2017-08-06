import com.GameInterface.TextGame;
import com.Utils.Signal;

intrinsic class com.GameInterface.TextGameLoader
{
	public static var m_CurrentGame:TextGame;
	public static function LoadTextGame(gameName:String);
	public static var SignalTextGameLoaded:Signal;
}