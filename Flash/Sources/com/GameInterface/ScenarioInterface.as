import com.Utils.Signal;

intrinsic class com.GameInterface.ScenarioInterface
{
	static public var m_Scenarios:Array; //Array of com.GameInterface.Scenario
	static public var m_Results:Array; //Scenario results string table
	
	public static function ActivateScenario( loc:Number, objective:Number, time:Number, difficulty:Number): Void;
	public static function LeaveScenario(): Void;
	public static function CloseSetupInterface():Void;
	public static function OpenDLCShop(tagId:Number):Void;
}