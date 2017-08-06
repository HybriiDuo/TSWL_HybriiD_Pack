import com.Utils.Signal;

intrinsic class com.GameInterface.Claim
{
    static public var m_Claims : Array; //Array of ClaimItemData objects
    
    static public var SignalClaimsUpdated : Signal; // ()
    
    static public function ClaimAllItems() : Boolean; 
	static public function ClaimLinkedItems() : Boolean;
	static public function LinkedItemsAvailable() : Boolean;
	static public function ClaimSteamItems() : Boolean;
	static public function SteamItemsAvailable() : Boolean;
    static public function ClaimItem( ClaimItemId:Number ) : Boolean;
    static public function DeleteClaimItem( ClaimItemId:Number ) : Void;
	static public function MarkAllAsOld() : Void;
}