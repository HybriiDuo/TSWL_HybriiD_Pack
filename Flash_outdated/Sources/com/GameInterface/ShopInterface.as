﻿import com.Utils.ID32;
import com.Utils.Signal;
intrinsic class com.GameInterface.ShopInterface
{
	
	public function ShopInterface(shopID:ID32);
	public function BuyItem(itemPos:Number);
    public function SellItem(inventoryID:ID32, itemPos:Number);
    public function RepairItem(inventoryID:ID32, itemPos:Number);
    public function RepairAllItems();
	public function PreviewItem(itemPos:Number);
    public function CanPreview(itemPos:Number):Boolean;
    public function CloseShop();
    public function UndoSell();
    public function GetNumUndoItems() : Number;
    public function UpdateShopItems();
    public function IsVendorSellOnly():Boolean;
	
	public static function BuyItemTemplate(templateID:Number, tokenType:Number, tokenAmount:Number):Void
	public static function BuyTag(tagID:Number, tokenType:Number, tokenAmount:Number):Void;
	public static function GetTagPriceInfo(tagId:Number):Object; //First parameter is token type, second is token amount
	public static function RequestAurumPurchase();
	public static function ConfirmRealMoneyPurchase();
	public static function CancelRealMoneyPurchase();
	public static function ChangePaymentInfo();
	public static function ShowLegalInfo();
	public static function RequestMembershipPrice();
	public static function PurchaseMembership();
	
	public var SignalCloseShop:Signal;
	public var SignalShopItemsUpdated:Signal;
	
	public static var SignalOpenShop:Signal;
	public static var SignalOpenInstantBuy:Signal;
	public static var SignalConfirmPurchase:Signal;
	public static var SignalMembershipPriceUpdated:Signal;
	
	public var m_Items:Array;
}