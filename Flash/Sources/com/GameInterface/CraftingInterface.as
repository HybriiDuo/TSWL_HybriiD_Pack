import com.Utils.Signal;
intrinsic class com.GameInterface.CraftingInterface
{
    public static function StartCrafting(inventoryType:Number);
    public static function StartDisassembly(inventoryType:Number);
	public static function StartEmpowerment(inventoryType:Number);
	public static function StartFusion(inventoryType:Number);
    public static function EndCrafting();
    public static function CloseCrafting();
    public static function SetDisassemblySlot(slotID:Number);
	public static function DestroyGlyph(inventoryType:Number);
	public static function RecoverGlyph(inventoryType:Number);
	public static function DestroySignet(inventoryType:Number);
	public static function RecoverSignet(inventoryType:Number);
    
    public static var SignalCraftingResultFeedback:Signal;  
}