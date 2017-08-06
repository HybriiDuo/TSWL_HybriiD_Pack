import com.Utils.Signal;
import com.GameInterface.CharacterLFG;

intrinsic class com.GameInterface.LookingForGroup
{
    public var m_CharactersLookingForGroup:Array; //Array of com.GameInterface.CharacterLFG
    
    public var SignalSearchResult:Signal;
    public var SignalCharacterCountResult:Signal; //(Dictionary[playfieldId]= characterCount, count:Number) //THIS IS PROBABLY UNRELIABLE!
    
    static public var SignalClientJoinedTeam:Signal;
    static public var SignalClientJoinedLFG:Signal; //Void 
    static public var SignalClientLeftLFG:Signal; //Void
    
    public function LookingForGroup();
    public function SignUp(mode:Number, playfieldInstances:Array, location:Number, rolesArray:Array, comment:String, maxTeamSize:Number):Void;
    public function SignOff():Void;
    public function DoSearch(modes:Array, playfieldInstances:Array, rolesArray:Array, getAllResults:Boolean, skipResults:Number):Void;
	public function DoReminderSearch();
    public function RequestCharacterCount(mode:Number):Void; //THIS IS PROBABLY UNRELIABLE!
    
    static public function GetPlayerSignedUpData():CharacterLFG;
    static public function HasCharacterSignedUp():Boolean;
    static public function CanCharacterJoinEliteDungeons():Boolean;
    static public function CanCharacterJoinNightmareDungeons():Boolean;
}
