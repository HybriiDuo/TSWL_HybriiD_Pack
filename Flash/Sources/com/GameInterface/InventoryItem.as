﻿import com.GameInterface.ACGItem;

intrinsic class com.GameInterface.InventoryItem
{
    public var m_Name:String;
    public var m_Icon:com.Utils.ID32;
    public var m_InventoryPos:Number;
    public var m_StackSize:Number;
    public var m_MaxStackSize:Number;
    public var m_Placement:Number;
    public var m_DefaultPosition:Number;
    public var m_Type:Number;
    public var m_ItemType:Number;
	public var m_AegisItemType:Number;
	public var m_ItemTypeGUI:Number;
	public var m_RealType:Number; //This is getting stupid now...
    public var m_Locked:Boolean;
    public var m_Deleteable:Boolean;
    public var m_Unique:Boolean;
    public var m_IsBindOnPickup:Boolean;
    public var m_IsNoDropOnUse:Boolean;
    public var m_IsBoundToPlayer:Boolean;
    public var m_CanUse:Boolean;
    public var m_CanBuy:Boolean;
    public var m_ACGItem:ACGItem;
	public var m_IsACGItem:Boolean;
	public var m_Rarity:Number;
	public var m_GlyphRarity:Number;
	public var m_SignetRarity:Number;
	public var m_ColorLine:Number;
	public var m_InFilter:Boolean;
	public var m_SellPrice:Number;
	public var m_BuyPrice:Number;
	public var m_CooldownStart:Number;
	public var m_CooldownEnd:Number;
	public var m_RepairPrice:Number;
	public var m_Durability:Number;
	public var m_MaxDurability:Number;
	public var m_TokenCurrencyType1:Number;
	public var m_TokenCurrencyPrice1:Number;
	public var m_TokenCurrencyType2:Number;
	public var m_TokenCurrencyPrice2:Number;
	public var m_TokenCurrencySellType1:Number;
	public var m_TokenCurrencySellPrice1:Number;
	public var m_TokenCurrencySellType2:Number;
	public var m_TokenCurrencySellPrice2:Number;
	public var m_BuyLimit:Number;
	public var m_MaxBuyLimit:Number;
    public var m_Rank:Number;
	public var m_GlyphRank:Number;
	public var m_SignetRank:Number;
	public var m_XP:Number;
	public var m_GlyphXP:Number;
	public var m_SignetXP:Number;
	public var m_HasRemovablePrefix:Boolean;
	public var m_HasRemovableSuffix:Boolean;
	public var m_Pips:Number;
    
    public function IsBroken():Boolean;
    public function IsBreaking():Boolean;
}
