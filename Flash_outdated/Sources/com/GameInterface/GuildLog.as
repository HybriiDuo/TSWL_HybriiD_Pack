import com.Utils.Signal;

intrinsic class com.GameInterface.GuildLog
{
	public static var SignalGuildLogUpdated : Signal; // ()
	public static var m_LogRecords : Array; //Array of GuildLogEntry objects
	
	public static function GetTotalRecords() : Number;
	public static function RequestGuildLog(getBank:Boolean, getMembership:Boolean, getGovernment, sortDesc:Boolean, firstRow:Number, lastRow:Number) : Void;
	public static function GetRecord(recordIndex:Number) : Void;
}