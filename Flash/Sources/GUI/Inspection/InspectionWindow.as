import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.LoreBase;
import com.GameInterface.Utils;
import com.GameInterface.ShopInterface;
import com.Components.ItemSlot;
import com.Utils.ID32;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.Utils.Faction;
import com.Utils.Text;
import mx.utils.Delegate;
import gfx.controls.Button;
import gfx.controls.ScrollingList;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Components.WindowComponentContent;
import com.GameInterface.Lore;

class GUI.Inspection.InspectionWindow extends WindowComponentContent
{	
    public var SignalClose:Signal;
    public var SignalUpdateHeight:Signal;
    private var m_InspectionInventory:Inventory;
	private var m_ClothesInspectionInventory:Inventory;
    
    private var m_InspectionItemSlots:Array;
    private var m_InspectionCharacter:Character;
	private var m_ClientStaticInventory:Inventory;
	private var m_GenderMatch:Boolean;
    
    private var m_NameBox:MovieClip;	
    private var m_ChakrasTitle:TextField;
    private var m_IconChakra_1:MovieClip;
    private var m_IconChakra_2:MovieClip;
    private var m_IconChakra_3:MovieClip;
    private var m_IconChakra_4:MovieClip;
    private var m_IconChakra_5:MovieClip;
    private var m_IconChakra_6:MovieClip;
    private var m_IconChakra_7:MovieClip;	
	private var m_IconGadget:MovieClip;
    
    private var m_WeaponsTitle:TextField;
    private var m_IconWeapon_1:MovieClip;
    private var m_IconWeapon_2:MovieClip;
    
    private var m_ClothesTitle:TextField;
    private var m_ClothingIconHeadgear1:MovieClip;
    private var m_ClothingIconHeadgear2:MovieClip;
    private var m_ClothingIconHats:MovieClip;
    private var m_ClothingIconNeck:MovieClip;
    private var m_ClothingIconChest:MovieClip;
    private var m_ClothingIconBack:MovieClip;
    private var m_ClothingIconHands:MovieClip;
    private var m_ClothingIconLeg:MovieClip;
    private var m_ClothingIconFeet:MovieClip;
    private var m_ClothingIconMultislot:MovieClip;
	
	private var m_ClothingNameHeadgear1:TextField;
    private var m_ClothingNameHeadgear2:TextField;
    private var m_ClothingNameHats:TextField;
    private var m_ClothingNameNeck:TextField;
    private var m_ClothingNameChest:TextField;
    private var m_ClothingNameBack:TextField;
    private var m_ClothingNameHands:TextField;
    private var m_ClothingNameLeg:TextField;
    private var m_ClothingNameFeet:TextField;
    private var m_ClothingNameMultislot:TextField;
	
	private var m_BuyHeadgear1:MovieClip;
    private var m_BuyHeadgear2:MovieClip;
    private var m_BuyHat:MovieClip;
    private var m_BuyNeck:MovieClip;
    private var m_BuyChest:MovieClip;
    private var m_BuyBack:MovieClip;
    private var m_BuyHands:MovieClip;
    private var m_BuyLeg:MovieClip;
    private var m_BuyFeet:MovieClip;
    private var m_BuyMultislot:MovieClip;
	        
    private var m_Initialized:Boolean;
    
    function InspectionWindow()
    {
        super();
		m_GenderMatch = false;
        m_Initialized = false;
        SignalClose = new Signal();
        SignalUpdateHeight = new Signal();
        m_InspectionItemSlots = [];    
    }
    
    function configUI()
    {
		super.configUI();
        m_Initialized = true;
        
        SetLabels();
		
		Character.SignalCharacterEnteredReticuleMode.Connect(Close, this);
                
        if (m_InspectionCharacter != undefined)
        {
            UpdateData();
        }		
    }
    
    private function SetLabels()
    {
        m_WeaponsTitle.text = LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Weapons");
        m_ChakrasTitle.text = LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Talismans");
        m_ClothesTitle.text = LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Clothes");
    }
    
    private function Close()
    {
        SignalClose.Emit( m_InspectionCharacter.GetID() );
    }
    
    public function SetCharacter(characterID:ID32)
    {
		if (m_ClientStaticInventory == undefined)
		{
			m_ClientStaticInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, Character.GetClientCharID().GetInstance()));
			m_ClientStaticInventory.SignalItemAdded.Connect(SlotClientAddedStaticItem, this);
			m_ClientStaticInventory.SignalItemLoaded.Connect(SlotClientAddedStaticItem, this);
		}
		if (m_InspectionCharacter != undefined)
        {
			m_InspectionCharacter.SignalCharacterDestructed.Disconnect(SlotCharacterDestructed, this);
		}
        m_InspectionCharacter = Character.GetCharacter(characterID);
        if (m_InspectionCharacter != undefined)
        {
			m_InspectionCharacter.SignalCharacterDestructed.Connect(SlotCharacterDestructed, this);
			m_GenderMatch = m_InspectionCharacter.GetStat(_global.Enums.Stat.e_Sex) == Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_Sex);
            m_InspectionInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, characterID.GetInstance()));
			m_ClothesInspectionInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WearInventory, characterID.GetInstance()));
            
            InitializeChakras();
            InitializeWeapons();
            InitializeClothes();
        }
    }
    
    private function UpdateData()
    {		
        //Get Faction Icon
        if ( m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction ) == _global.Enums.Factions.e_FactionIlluminati )
        {
            m_NameBox.m_FactionIconLoader.attachMovie( "LogoIlluminati", "inspectedplayerFactionLogo", m_NameBox.m_FactionIconLoader.getNextHighestDepth() );
        }
        else if ( m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction ) == _global.Enums.Factions.e_FactionTemplar )
        {
            m_NameBox.m_FactionIconLoader.attachMovie( "LogoTemplar", "inspectedplayerFactionLogo", m_NameBox.m_FactionIconLoader.getNextHighestDepth() )
        }
        else if ( m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction ) == _global.Enums.Factions.e_FactionDragon )
        {
            m_NameBox.m_FactionIconLoader.attachMovie( "LogoDragon", "inspectedplayerFactionLogo", m_NameBox.m_FactionIconLoader.getNextHighestDepth() )
        }
        
        //Get Character Name
        var name:String = m_InspectionCharacter.GetFirstName();
        var nickName = m_InspectionCharacter.GetName();
        if (nickName.length != 0)
        {
            if (name.length != 0) { name += " "; }
            name += "\"" + nickName + "\"";
        }
        var lastName = m_InspectionCharacter.GetLastName();
        if (lastName.length != 0)
        {
            if (name.length != 0) { name += " "; }
            name += lastName;
        }		
        m_NameBox.m_Name.htmlText = name;
        
        //Get Character basic info
        m_NameBox.m_BasicInfo.htmlText = m_InspectionCharacter.GetTitle();
		
		m_NameBox.m_Level.text = m_InspectionCharacter.GetStat( _global.Enums.Stat.e_Level, 2 );
        
        
		for (var i:Number = 0; i < m_InspectionInventory.GetMaxItems(); i++)
		{
			if (m_InspectionInventory.GetItemAt(i) != undefined )
            {
                if (m_InspectionItemSlots[i] != undefined)
                {
                    m_InspectionItemSlots[i].SetData(m_InspectionInventory.GetItemAt(i));
                }
            }
		}
    }
    
    private function InitializeChakras()
    {
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_7, m_IconChakra_7);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_6, m_IconChakra_6);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_5, m_IconChakra_5);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_4, m_IconChakra_4);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_3, m_IconChakra_3);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_2, m_IconChakra_2);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_1, m_IconChakra_1);
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Aegis_Talisman_1, m_IconGadget)
    }
    
    private function InitializeWeapons()
    {
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot, m_IconWeapon_1);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot, m_IconWeapon_2);
    }
    
    private function InitializeSlot(itemPos:Number, icon:MovieClip):Void
    {
        m_InspectionItemSlots[ itemPos ] = new ItemSlot(m_InspectionInventory.m_InventoryID, itemPos, icon);
    }    
	
    private function InitializeClothes()
    {
		m_BuyHeadgear1._visible = false;
		m_BuyHeadgear2._visible = false;
		m_BuyHat._visible = false;
		m_BuyNeck._visible = false;
		m_BuyChest._visible = false;
		m_BuyBack._visible = false;
		m_BuyHands._visible = false;
		m_BuyLeg._visible = false;
		m_BuyFeet._visible = false;
		m_BuyMultislot._visible = false;
		
        m_ClothingIconHeadgear1._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face) != undefined ? 100 : 30;
        m_ClothingIconHeadgear2._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_HeadAccessory) != undefined ? 100 : 30;
        m_ClothingIconHats._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat) != undefined ? 100 : 30;
        m_ClothingIconNeck._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck) != undefined ? 100 : 30;
        m_ClothingIconChest._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest) != undefined ? 100 : 30;
        m_ClothingIconBack._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back) != undefined ? 100 : 30;
        m_ClothingIconHands._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands) != undefined ? 100 : 30;
        m_ClothingIconLeg._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs) != undefined ? 100 : 30;
        m_ClothingIconFeet._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet) != undefined ? 100 : 30;
        m_ClothingIconMultislot._alpha = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit) != undefined ? 100 : 30;
        
        var tooltipWidth:Number = 100;
        var tooltipOrientation = TooltipInterface.e_OrientationVertical;
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face) != undefined)
        {
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face)
			m_ClothingNameHeadgear1.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyHeadgear1.onMouseRelease = Delegate.create(this, BuyHeadgear1);
				m_BuyHeadgear1._visible = true;
			}
			else
			{
				m_BuyHeadgear1.onMouseRelease = function(){};
				m_BuyHeadgear1._visible = false;
			}
            //TooltipUtils.AddTextTooltip(m_ClothingIconHeadgear1, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_HeadAccessory) != undefined)
        {
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_HeadAccessory)
			m_ClothingNameHeadgear2.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyHeadgear2.onMouseRelease = Delegate.create(this, BuyHeadgear2);
				m_BuyHeadgear2._visible = true;
			}
			else
			{
				m_BuyHeadgear2.onMouseRelease = function(){};
				m_BuyHeadgear2._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconHeadgear2, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_HeadAccessory).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat) != undefined)
        {
            var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat)
			m_ClothingNameHats.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyHat.onMouseRelease = Delegate.create(this, BuyHat);
				m_BuyHat._visible = true;
			}
			else
			{
				m_BuyHat.onMouseRelease = function(){};
				m_BuyHat._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconHats, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck) != undefined)
        {
            var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck)
			m_ClothingNameNeck.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyNeck.onMouseRelease = Delegate.create(this, BuyNeck);
				m_BuyNeck._visible = true;
			}
			else
			{
				m_BuyNeck.onMouseRelease = function(){};
				m_BuyNeck._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconNeck, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest) != undefined)
        {
            var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest)
			m_ClothingNameChest.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyChest.onMouseRelease = Delegate.create(this, BuyChest);
				m_BuyChest._visible = true;
			}
			else
			{
				m_BuyChest.onMouseRelease = function(){};
				m_BuyChest._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconChest, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back) != undefined)
        {
            var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back)
			m_ClothingNameBack.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyBack.onMouseRelease = Delegate.create(this, BuyBack);
				m_BuyBack._visible = true;
			}
			else
			{
				m_BuyBack.onMouseRelease = function(){};
				m_BuyBack._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconBack, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands) != undefined)
        {
            var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands)
			m_ClothingNameHands.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyHands.onMouseRelease = Delegate.create(this, BuyHands);
				m_BuyHands._visible = true;
			}
			else
			{
				m_BuyHands.onMouseRelease = function(){};
				m_BuyHands._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconHands, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs) != undefined)
        {
            var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs)
			m_ClothingNameLeg.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyLeg.onMouseRelease = Delegate.create(this, BuyLegs);
				m_BuyLeg._visible = true;
			}
			else
			{
				m_BuyLeg.onMouseRelease = function(){};
				m_BuyLeg._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconLeg, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet) != undefined)
        {
            var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet)
			m_ClothingNameFeet.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyFeet.onMouseRelease = Delegate.create(this, BuyFeet);
				m_BuyFeet._visible = true;
			}
			else
			{
				m_BuyFeet.onMouseRelease = function(){};
				m_BuyFeet._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconFeet, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit) != undefined)
        {
            var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit)
			m_ClothingNameMultislot.text = item.m_Name;
			if (m_GenderMatch && !HasItem(item) && item.m_TokenCurrencyPrice1 > 1)
			{
				m_BuyMultislot.onMouseRelease = Delegate.create(this, BuyMultislot);
				m_BuyMultislot._visible = true;
			}
			else
			{
				m_BuyMultislot.onMouseRelease = function(){};
				m_BuyMultislot._visible = false;
			}
			//TooltipUtils.AddTextTooltip(m_ClothingIconMultislot, m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit).m_Name , tooltipWidth, tooltipOrientation, false);
        }
    }
	
	private function HasItem(item):Boolean
	{
		trace("HAS ITEM: " + item.m_Name);
		var equippedInventory:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WearInventory, Character.GetClientCharID().GetInstance()));
		var staticInventory:Inventory = m_ClientStaticInventory;
		for (var i:Number = 0; i < equippedInventory.GetMaxItems(); i++)
		{
			if (equippedInventory.GetItemAt(i).m_ACGItem.m_TemplateID0 == item.m_ACGItem.m_TemplateID0)
			{
				return true;
			}
		}
		for (var i:Number = 0; i < staticInventory.GetMaxItems(); i++)
		{
			if (staticInventory.GetItemAt(i).m_ACGItem.m_TemplateID0 == item.m_ACGItem.m_TemplateID0)
			{
				return true;
			}
		}
		return false;
	}
	
	private function TryBuyItem(item:InventoryItem)
	{
		if (HasItem(item))
		{
			trace("ATTEMPTING TO BUY ALREADY OWNED ITEM: " + item.m_Name);
			SlotClientAddedStaticItem(m_ClientStaticInventory.m_InventoryID, item.m_InventoryPos)
			return;
		}
		if (Character.GetClientCharacter().GetTokens(item.m_TokenCurrencyType1) >= item.m_TokenCurrencyPrice1)
		{
			ShopInterface.BuyItemTemplate(item.m_ACGItem.m_TemplateID0, item.m_TokenCurrencyType1, item.m_TokenCurrencyPrice1);
		}
		else
		{
			switch(item.m_TokenCurrencyType1)
			{
				case _global.Enums.Token.e_Cash:				com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("GenericGUI", "NotEnoughAnimaShards"), 0);
																break;
				case _global.Enums.Token.e_Gold_Bullion_Token:	com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("GenericGUI", "NotEnoughMoFs"), 0);
																break;
				case _global.Enums.Token.e_Premium_Token:		com.GameInterface.Chat.SignalShowFIFOMessage.Emit(LDBFormat.LDBGetText("GenericGUI", "NotEnoughAurum"), 0);
																ShopInterface.RequestAurumPurchase();
																break;
			}
		}
	}
	
	private function BuyHeadgear1()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyHeadgear1, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyHeadgear1(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face)
			ShopInterface.BuyItemTemplate(item.m_ACGItem.m_TemplateID0, item.m_TokenCurrencyType1, item.m_TokenCurrencyPrice1);
		}
	}
	
	private function BuyHeadgear2()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_HeadAccessory);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyHeadgear2, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyHeadgear2(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_HeadAccessory)
			TryBuyItem(item);
		}
	}
	
	private function BuyHat()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyHat, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyHat(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat)
			TryBuyItem(item);
		}
	}
	
	private function BuyNeck()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyNeck, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyNeck(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck)
			TryBuyItem(item);
		}
	}
	
	private function BuyChest()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyChest, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyChest(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest)
			TryBuyItem(item);
		}
	}
	
	private function BuyBack()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyBack, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyBack(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back)
			TryBuyItem(item);
		}
	}
	
	private function BuyHands()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyHands, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyHands(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands)
			TryBuyItem(item);
		}
	}
	
	private function BuyLegs()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyLegs, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyLegs(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs)
			TryBuyItem(item);
		}
	}
	
	private function BuyFeet()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyFeet, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyFeet(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet)
			TryBuyItem(item);
		}
	}
	
	private function BuyMultiSlot()
	{
		var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit);
		var tokenName:String = LDBFormat.LDBGetText("Tokens", "Token"+item.m_TokenCurrencyType1);
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Inspection_Purchase"), item.m_Name, Text.AddThousandsSeparator(item.m_TokenCurrencyPrice1), tokenName), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotConfirmBuyMultiSlot, this );
		dialogIF.Go();
	}
	
	private function SlotConfirmBuyMultiSlot(buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			var item:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit)
			TryBuyItem(item);
		}
	}
	
	private function SlotClientAddedStaticItem(inventoryID:com.Utils.ID32, itemPos:Number)
	{
		var addedItem:InventoryItem = m_ClientStaticInventory.GetItemAt(itemPos);
		var itemFace:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face)
		var itemHeadAccessory:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_HeadAccessory)
		var itemHat:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat)
		var itemNeck:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck)
		var itemChest:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest)
		var itemBack:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back)
		var itemHands:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands)
		var itemLegs:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs)
		var itemFeet:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet)
		var itemFullOutfit:InventoryItem = m_ClothesInspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit)
		
		if (HasItem(itemFace))
		{
			m_BuyHeadgear1.onMouseRelease = function(){};
			m_BuyHeadgear1._visible = false;
		}
		if (HasItem(itemHeadAccessory))
		{
			m_BuyHeadgear2.onMouseRelease = function(){};
			m_BuyHeadgear2._visible = false;
		}
		if (HasItem(itemHat))
		{
			m_BuyHat.onMouseRelease = function(){};
			m_BuyHat._visible = false;
		}
		if (HasItem(itemNeck))
		{
			m_BuyNeck.onMouseRelease = function(){};
			m_BuyNeck._visible = false;
		}
		if (HasItem(itemChest))
		{
			m_BuyChest.onMouseRelease = function(){};
			m_BuyChest._visible = false;
		}
		if (HasItem(itemBack))
		{
			m_BuyBack.onMouseRelease = function(){};
			m_BuyBack._visible = false;
		}
		if (HasItem(itemHands))
		{
			m_BuyHands.onMouseRelease = function(){};
			m_BuyHands._visible = false;
		}
		if (HasItem(itemLegs))
		{
			m_BuyLeg.onMouseRelease = function(){};
			m_BuyLeg._visible = false;
		}
		if (HasItem(itemFeet))
		{
			m_BuyFeet.onMouseRelease = function(){};
			m_BuyFeet._visible = false;
		}
		if (HasItem(itemFullOutfit))
		{
			m_BuyMultislot.onMouseRelease = function(){};
			m_BuyMultislot._visible = false;
		}
	}
	
	private function SlotCharacterDestructed()
	{
		m_BuyHeadgear1._visible = false;
		m_BuyHeadgear2._visible = false;
		m_BuyHat._visible = false;
		m_BuyNeck._visible = false;
		m_BuyChest._visible = false;
		m_BuyBack._visible = false;
		m_BuyHands._visible = false;
		m_BuyLeg._visible = false;
		m_BuyFeet._visible = false;
		m_BuyMultislot._visible = false;
	}
	
    private function SlotStartDragWindow()
    {
        this.startDrag();
    }
    
    private function SlotStopDragWindow()
    {
        this.stopDrag();
    }
}