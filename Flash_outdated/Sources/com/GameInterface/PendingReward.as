import com.Utils.Signal;

intrinsic class com.GameInterface.PendingReward
{
    static public var m_Claims : Array; //Array of PendingRewardItemData objects
    
    static public var SignalClaimsUpdated : Signal; // ()
    
    static public function ClaimAllItems() : Boolean;    
    static public function ClaimItem( ClaimItemId:Number ) : Boolean;
    static public function DeleteClaimItem( ClaimItemId:Number ) : Void;
	static public function MarkAllAsOld() : Void;
}