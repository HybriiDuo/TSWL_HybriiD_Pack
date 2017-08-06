import com.GameInterface.MathLib.Vector3;
import com.Utils.ID32;
import com.Utils.Signal;
import flash.geom.Point;
import com.GameInterface.Game.Dynel;

intrinsic class com.GameInterface.Game.CharacterBase extends Dynel
{
    public static function GetClientCharID():ID32;
	public static function SwapAegisController(primary:Boolean, up:Boolean);
	public static function GetLevelForWeapon(weaponType:Number);
	public static function GetXPForWeaponLevel(level:Number);
	public static function UsePotion();
	public static function GetPotionCooldown();
	public static function BuyPotionRefill();
	public static function BuyDungeonKey();
	public static function BuyScenarioKey();
	public static function BuyLairKey();
	public static function IsInReticuleMode();
	public static function GetXPPerAP(level:Number);
	public static function GetXPPerSP(level:Number);
	public static function GetXPToNextAP();
	public static function GetXPToNextSP();
	public static function SetReticuleMode();
    public static function ExitReticuleMode();
	public static function RequestLootBoxUpdate();
	public static function SendLootBoxReply(openBox:Boolean);
	public static function SetNextWeaponActive(weaponSlotId:Number);
	public static function ToggleVanityMode(toggle:Boolean);
	public static function ClearDeathPenalty();
    
    public function CharacterBase( charId:com.Utils.ID32 );
    public function GetTitle():String;
    public function GetFirstName():String;
    public function GetLastName():String;
    public function GetGuildName():String;
    public function GetDimensionName():String;
	public function GetDifficulty():Number;
    public function GetTokens(tokenID:Number);
	public function GetWeeklyTokens(tokenID:Number);
	public function GetTokenCapTweakName(tokenID:Number);
	public function GetWeeklyTokenCapTweakName(tokenID:Number);
    public function SetBaseAnim( name:String );
    
    public function GetDefensiveTarget():ID32;
    public function GetOffensiveTarget():ID32;
    
    public function ConnectToCommandQueue();
    public function GetCommandProgress():Number;
    
    public function IsInCharacterCreation():Boolean;
    public function IsInCombat():Boolean;
	public function IsThreatened():Boolean;
    public function IsNPC():Boolean;
    public function IsBoss():Boolean;
	public function IsPet():Boolean;
    public function IsMerchant():Boolean;
    public function IsBanker():Boolean;
    public function IsRare():Boolean;
    public function IsQuestTarget():Boolean;
    public function IsGhosting():Boolean;
	public function IsInCinematic():Boolean;
	public function IsMember():Boolean;
	public function IsLifetimeAccount():Boolean;
	public function IsUnlimitedTrialAccount():Boolean;
    
    public function IsClientChar():Boolean;

	public function CanReceiveItems():Boolean;

    public var SignalTokenAmountChanged:Signal;
	public var SignalWeeklyTokenAmountChanged:Signal;
    public var SignalToggleCombat:Signal;
    
    public var SignalBuffAdded:Signal;
    public var SignalBuffUpdated:Signal;
    public var SignalBuffRemoved:Signal;
    public var SignalInvisibleBuffAdded:Signal;
    public var SignalInvisibleBuffUpdated:Signal;
	
	public var SignalPotionCooldown:Signal;
	public var SignalEndPotionCooldown:Signal;
    
    public var SignalDefensiveTargetChanged:Signal;
    public var SignalOffensiveTargetChanged:Signal;
    
    public var SignalStateAdded:Signal;
    public var SignalStateUpdated:Signal;
    public var SignalStateRemoved:Signal;
    
    ///*** Signals sent only if you are connected to the CommandQueue through ConnectToCommandQueue function  ***///
    
    /// Signal sent when a command is started.
    public var SignalCommandStarted:Signal; // -> OnSignalCommandStarted( name:String, progressBarType:Number)

    /// Signal sent when a command is ended.
    public var SignalCommandEnded:Signal; // -> OnSignalCommandEnded()

    /// Signal sent when a command is aborted.
    public var SignalCommandAborted:Signal; // -> OnSignalCommandAborted()
    
    ///Signal sent when the character dies
    public var SignalCharacterDied:Signal;
	
    ///Signal sent when the character is resurrected
    public var SignalCharacterAlive:Signal;

	///Signal sent when the character re-enters the world of the living (leaves the ghosting phase or resurrects).
	public var SignalCharacterRevived:Signal;
    
    ///Signal sent when the character teleports
    public var SignalCharacterTeleported:Signal;
    
    ///Signal sent when the character is being removed from the client for whatever reason (logged out, teleported away, etc)
    public var SignalCharacterDestructed:Signal;
	
	///Signal sent when the character's membership status is updated, returns a bool with the new status
	public var SignalMemberStatusUpdated:Signal;
	
	//Signal sent when the character gains weapon expertise
	public var SignalGainedWeaponLevel:Signal;
	
	///*** -------------------------------------------------------------------------------------------------  ***///
	
	//Signal sent when the character enters reticule mode
	public static var SignalCharacterEnteredReticuleMode:Signal;
	
	//Signal sent when the character exits reticule mode
	public static var SignalCharacterExitedReticuleMode:Signal;
    
    public static var SignalClientCharacterAlive:Signal;
	public static var SignalReloadTokens:Signal;
	
	public static var SignalClientCharacterOfferedLootBox:Signal;
	public static var SignalClientCharacterOpenedLootBox:Signal;
    
    public var m_StateList:Object;
    
    public var m_BuffList:Object;
    public var m_InvisibleBuffList:Object;
	public var m_BuffsInitialized:Boolean;
}
