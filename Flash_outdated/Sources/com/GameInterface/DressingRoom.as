import com.GameInterface.DressingRoomNode;

intrinsic class com.GameInterface.DressingRoom
{
	//List of methods to call in C++
	static public function GetRootNodeId():Number;
	static public function GetParent(nodeId:Number):DressingRoomNode;
	static public function GetChildren(nodeId:Number):Array; //Array of DressingRoomNodes
	static public function NodeOwned(nodeId:Number):Boolean;
	static public function NodeEquipped(nodeId:Number):Boolean;
	static public function EquipNode(nodeId:Number):Void;
	static public function PurchaseNode(nodeId:Number):Boolean; //returns true if purchase successful
	static public function PreviewNodeItem(nodeId:Number):Void;
	static public function ClearPreview():Void;
	//List of members from C++
	
	//List of signals from C++
}