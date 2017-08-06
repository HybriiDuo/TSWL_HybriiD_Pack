import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import mx.utils.Delegate;
import gfx.controls.Button;
import com.GameInterface.Game.Character;
import com.GameInterface.ShopInterface;
import GUI.LootBox.PossibleItem;
import com.GameInterface.Inventory;
import com.GameInterface.DistributedValue;

class GUI.LootBox.LootBoxContent extends WindowComponentContent
{
	//Components created in .fla	
	private var m_KeyPanel:MovieClip;
	private var m_PossibleItems:MovieClip;
	private var m_Background:MovieClip;
	private var m_OpenButton:Button;
	
	//Variables
	private var m_KeyIcon:MovieClip;
	private var m_BuyKeyPanel:MovieClip;
	private var m_Blackout:MovieClip;
	private var m_ReceivedItems:MovieClip;
	private var m_Character:Character;
	private var m_TokenType:Number;
	private var m_Chest:MovieClip;
	private var m_MoreAvailable:Boolean;
	public var SignalContentInitialized:Signal;
	private var m_Hovered:Boolean;
	private var m_ButtonHovered:Boolean;

	//Statics
	
	public function LootBoxContent()
	{
		super();
		SignalContentInitialized = new Signal();
		m_KeyPanel._visible = false;
	}
	
	private function configUI():Void
	{	
		Character.SignalClientCharacterOfferedLootBox.Connect(SlotOfferedLootBox, this);
		Character.SignalClientCharacterOpenedLootBox.Connect(SlotOpenedLootBox, this);
		m_Character = Character.GetClientCharacter();
		
		m_OpenButton.label = LDBFormat.LDBGetText("GenericGUI", "LootBox_Open");
		m_OpenButton.disableFocus = true;
		
		Character.RequestLootBoxUpdate();
		SignalContentInitialized.Emit();
	}
	
	private function CloseChest()
	{
		m_Hovered = false;
		m_OpenButton.disabled = false;
		m_Chest.gotoAndStop("Static");
		m_Chest.onMouseMove = Delegate.create(this, CheckHover);
		if (m_Character.GetTokens(m_TokenType) > 0)
		{
			m_OpenButton.addEventListener("click", this, "OpenChest");
		}
		else
		{
			m_OpenButton.addEventListener("click", this, "PurchaseKey");
		}
	}
	
	private function PurchaseKey()
	{
		if (m_TokenType == _global.Enums.Token.e_Dungeon_Key)
		{
			Character.BuyDungeonKey();
		}
		else if (m_TokenType == _global.Enums.Token.e_Scenario_Key)
		{
			Character.BuyScenarioKey();
		}
		else if (m_TokenType == _global.Enums.Token.e_Lair_Key)
		{
			Character.BuyLairKey();
		}
		else
		{
			ShopInterface.SignalOpenInstantBuy.Emit([9301738, 9301737, 9301736, 9301735]);
		}
	}
	
	private function CheckHover()
	{
		if (m_Chest.hitTest(_root._xmouse, _root._ymouse) || m_OpenButton.hitTest(_root._xmouse, _root._ymouse))
		{
			HoverChest();
		}
		else
		{
			CloseChest();
		}
	}
	
	private function HoverChest()
	{
		if (m_Character.GetTokens(m_TokenType) > 0 && !m_Hovered)
		{
			m_Hovered = true;
			m_Chest.gotoAndPlay("Hover");
			m_Chest.onMouseRelease = Delegate.create(this, OpenChest);
		}
	}
	
	private function OpenChest()
	{
		if (m_Character.GetTokens(m_TokenType) > 0)
		{
			m_Chest.onMouseMove = function() {};
			m_OpenButton.removeEventListener("rollOut", this, "CloseChest");
			m_OpenButton.removeEventListener("dragOut", this, "CloseChest");
			m_OpenButton.removeEventListener("click", this, "OpenChest");
			m_OpenButton.disabled = true;
			if (m_Character != undefined)
			{
				m_Character.AddEffectPackage( "sound_fxpackage_GUI_agartha_cache_open.xml" );
			}
			m_Chest.gotoAndPlay("Open");
			m_Chest.onEnterFrame = Delegate.create(this, CheckChestFrame);
		}
	}
	
	private function CheckChestFrame()
	{
		if (m_Chest._currentframe == m_Chest._totalframes)
		{
			m_Chest.stop();
			m_Chest.onEnterFrame = function(){};
			OpenBox();
		}
	}
	
	private function OpenBox()
	{
		Character.SendLootBoxReply(true);
	}
	
	private function SlotOfferedLootBox(possibleItems:Array, tokenType:Number, boxType:Number, backgroundId:Number)
	{
		if (m_Character != undefined)
		{
			m_Character.AddEffectPackage( "sound_fxpackage_GUI_dungeon_chest_investigate.xml" );
		}
		if (m_Chest != undefined)
		{
			m_Chest.removeMovieClip();
		}
		if (boxType == undefined)
		{
			boxType = 0;
		}
		
		m_Chest = this.attachMovie("Chest_" + boxType, "m_Chest", this.getNextHighestDepth());
		
		switch(boxType)
		{
			case 0: m_Chest._xscale = m_Chest._yscale = 75;
					m_Chest._x = m_OpenButton._x - 150;
					m_Chest._y = m_OpenButton._y - m_Chest._height - 50;
					break;
					
			case 1: m_Chest._xscale = m_Chest._yscale = 90;
					m_Chest._x = m_OpenButton._x - 140;
					m_Chest._y = m_OpenButton._y - m_Chest._height;
					break;
			
			case 2: m_Chest._xscale = m_Chest._yscale = 90;
					m_Chest._x = m_OpenButton._x - 140;
					m_Chest._y = m_OpenButton._y - m_Chest._height + 30;
					break;
		}
		
		m_PossibleItems.m_Header.text = LDBFormat.LDBGetText("GenericGUI", "LootBox_PotentialHeader");
		m_PossibleItems.gotoAndPlay("Open");
		for (var i:Number = 0; i < possibleItems.length; i++)
		{
			if (m_PossibleItems["m_PossibleItem_"+i] != undefined)
			{
				m_PossibleItems["m_PossibleItem_"+i].SetData(possibleItems[i]);
			}
		}
		
		m_TokenType = tokenType;
		var numTokens:Number = m_Character.GetTokens(tokenType);
		m_Character.SignalTokenAmountChanged.Connect(SlotTokenChanged, this);
		if (m_TokenType != _global.Enums.Token.e_Lockbox_Key)
		{
			if (numTokens <= 0)
			{
				PurchaseKey();
			}
		}
		else
		{
			m_BuyKeyPanel = this.attachMovie("BuyKeyPanel", "m_BuyKeyPanel", this.getNextHighestDepth());
			m_BuyKeyPanel._y = this._height/2 - m_BuyKeyPanel._height/2;
			m_BuyKeyPanel._x = this._width;
			m_BuyKeyPanel.SetData([Inventory.CreateACGItemFromTemplate(9301738, 0, 0, 1), Inventory.CreateACGItemFromTemplate(9301737, 0, 0, 1), Inventory.CreateACGItemFromTemplate(9301736, 0, 0, 1), Inventory.CreateACGItemFromTemplate(9301735, 0, 0, 1)]);
			SignalSizeChanged.Emit();
		}
		m_KeyPanel._visible = true;
		m_KeyPanel.m_KeyNum.text = numTokens;
		if (m_KeyIcon != undefined)
		{
			m_KeyIcon.removeMovieClip();
			m_KeyIcon = undefined;
		}
		var keyIcon:MovieClip = m_KeyPanel.attachMovie("T"+m_TokenType, "m_KeyIcon", this.getNextHighestDepth());
		
		CloseChest();
	}
	
	private function SlotOpenedLootBox(obtainedItems:Array, lootResult:Number, moreAvailable:Boolean)
	{
		if (lootResult == undefined)
		{
			lootResult = 0;
		}
		if (moreAvailable == undefined)
		{
			moreAvailable = false;
		}
		m_MoreAvailable = moreAvailable;
		if (m_Blackout != undefined)
		{
			m_Blackout.removeMovieClip();
			m_Blackout = undefined;
		}
		m_Blackout = this.attachMovie("Blackout", "m_Blackout", this.getNextHighestDepth());
		m_Blackout._width = m_Background._width;
		m_Blackout._height = m_Background._height;
		m_Blackout.onMouseDown = function(){};
		if (m_ReceivedItems != undefined)
		{
			m_ReceivedItems.removeMovieClip();
			m_ReceivedItems = undefined;
		}
		
		var panelName:String = "ReceivedItemsPanel";
		switch(lootResult)
		{
			case 0: 	panelName = "ReceivedItemsPanel";
						break;
			case 1: 	panelName = "ReceivedItemsPanel-Good";
						break;
			case 2: 	panelName = "ReceivedItemsPanel-SuperGood";
						break;
			default:	panelName = "ReceivedItemsPanel";
		}
		m_ReceivedItems = this.attachMovie(panelName, "m_ReceivedItems", this.getNextHighestDepth());
		m_ReceivedItems._x = this._width/2 - m_ReceivedItems._width/2 + 50;
		m_ReceivedItems._y = this._height/2 - m_ReceivedItems._height/2 + 50;
		m_ReceivedItems.SignalPanelClosed.Connect(SlotPanelClosed, this);
		m_ReceivedItems.SetData(obtainedItems);
	}
	
	private function SlotPanelClosed()
	{
		if (!m_MoreAvailable)
		{
			DistributedValue.SetDValue("lootBox_window", false);
		}
		else
		{
			//Remove the received panel
			if (m_ReceivedItems != undefined)
			{
				m_ReceivedItems.removeMovieClip();
				m_ReceivedItems = undefined;
			}
			if (m_Blackout != undefined)
			{
				m_Blackout.removeMovieClip();
				m_Blackout = undefined;
			}
			//Reset the UI
			CloseChest();
		}
	}
	
	private function SlotTokenChanged(tokenID:Number, newAmount:Number, oldAmount:Number)
	{
		if (tokenID == m_TokenType)
		{
			m_KeyPanel.m_KeyNum.text = newAmount;
			if (newAmount > 0)
			{
				m_OpenButton.removeEventListener("click", this, "PurchaseKey");
			}
			else
			{
				m_OpenButton.addEventListener("click", this, "PurchaseKey");
			}
		}
	}
}