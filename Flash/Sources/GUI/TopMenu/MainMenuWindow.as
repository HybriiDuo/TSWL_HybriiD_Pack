//Imports
import flash.display.BitmapData;
import mx.utils.Delegate;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.GameInterface.DistributedValue;
import com.GameInterface.LoreBase;
import com.GameInterface.Utils;
import com.GameInterface.Game.Character;
import com.GameInterface.ClientServerPerfTracker;
import com.GameInterface.Tradepost;
import com.GameInterface.WaypointInterface;
import com.GameInterface.SpellBase;
import com.GameInterface.ShopInterface;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.Utils.HUDController;
import com.Utils.ID32;
import com.Utils.Format;
import com.Utils.Colors;
import com.Utils.GlobalSignal;
import com.Utils.LDBFormat;
import com.Utils.Text;
import GUIFramework.SFClipLoader;

var STANDARD_FONT:String = "_Headline";
var FONT_SIZE:Number = 11;
var FONT_SIZE_LARGE:Number = 14;
var COLOR:Number = 0xFFFFFF;

var ICON_MARGIN:Number = 8;
var ICON_LABEL_Y:Number = 1;
var STARTING_Y_POSITION:Number = 41;
var ANIMATION_DURATION:Number = 0.2;
var BLINK_ANIMATION_DURATION:Number = 0.1;
var MAX_BLINK_AMOUNT:Number = 4;
var GROUP_FINDER_ENABLE:Number = Utils.GetGameTweak("GroupFinderGateTag");
var REGION_TELEPORT_ENABLE:Number = Utils.GetGameTweak("RegionTeleportGateTag");

var RECEIVE_MAIL_SOUND_EFFECT:String = "sound_fxpackage_GUI_receive_tell.xml";

var m_TDB_CharacterSheet:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_CharacterSheet");
var m_TDB_AbilityWheel:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_AbilityWheelLabel");
var m_TDB_Inventory:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Inventory");
var m_TDB_Journal:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Journal");
var m_TDB_PvP:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_PvPSpoils");
var m_TDB_RegionTeleport:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_RegionTeleport");
var m_TDB_Settings:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Settings");
var m_TDB_Shop:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_ItemShop");
var m_TDB_Shop_DisabledTooltip:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_ItemShop_DisabledTooltip");
var m_TDB_Exit:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Exit");
var m_TDB_Achievement:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Achievement");
var m_TDB_Help:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Help");
var m_TDB_Crafting:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Crafting");
var m_TDB_Petition:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Petition");
var m_TDB_Cabal:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Cabal");
var m_TDB_Friends:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Friends");
var m_TDB_LFG:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_LFG");
var m_TDB_Claim:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Claim");
var m_TDB_WebBrowser:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_WebBrowser");
var m_TDB_Leaderboards:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Leaderboards");
//var m_TDB_Lockouts:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Lockouts");
var m_TDB_Pets:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Pets");
var m_TDB_ChallengeJournal:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_ChallengeJournal");
var m_TDB_GroupFinder:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_GroupFinder");
var m_TDB_Tradepost:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Tradepost");
//var m_TDB_Bank:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Bank");
var m_TDB_Membership:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_MemberBenefits");
var m_TDB_TrialRemainingDays:String = LDBFormat.LDBGetText("GenericGUI", "TrialDaysRemaining");
var m_TDB_TrialRemainingHours:String = LDBFormat.LDBGetText("GenericGUI", "TrialHoursRemaining");
var m_TDB_TrialExpired:String = LDBFormat.LDBGetText("GenericGUI", "TrialExpired");
var m_TDB_BuyAurum:String = LDBFormat.LDBGetText("GenericGUI", "BuyAurum");

//Properties
var m_MenuIconContainer:MovieClip;
var m_MenuIcon:MovieClip;

/*
var m_SprintIconContainer:MovieClip;
var m_SprintIcon:MovieClip;
*/

var m_MemberIconContainer:MovieClip;
var m_MemberIcon:MovieClip;

var m_ShopIconContainer:MovieClip;
var m_ShopIcon:MovieClip;

var m_TrialContainer:MovieClip;

var m_TokenIconContainer_1:MovieClip;
var m_TokenIcon_1:MovieClip;

var m_TokenIconContainer_2:MovieClip;
var m_TokenIcon_2:MovieClip;

var m_TokenIconContainer_201:MovieClip;
var m_TokenIcon_201:MovieClip;

var m_TokenIconContainer_202:MovieClip;
var m_TokenIcon_202:MovieClip;

var m_TokenIconContainer_10:MovieClip;
var m_TokenIcon_10:MovieClip;

var m_ShardGainContainer:MovieClip;
var m_LastShardGain:Number;

var m_FPSIconContainer:MovieClip;
var m_FPSIcon:MovieClip;

var m_MailIconContainer:MovieClip;
var m_MailIcon:MovieClip;

var m_GUILockIconContainer:MovieClip;
var m_GUILockIcon:MovieClip;

var m_ClockIconContainer:MovieClip;
var m_ClockIcon:MovieClip;

var m_DownloadingIconContainer:MovieClip;
var m_DownloadingIcon:MovieClip;

var m_IsMenuOpen:Boolean;

var m_Character:Character;

var m_CharacterSheetMonitor:DistributedValue;
var m_AnimaWheelMonitor:DistributedValue;
var m_InventoryMonitor:DistributedValue;
var m_JournalMonitor:DistributedValue;
var m_PvPMonitor:DistributedValue;
var m_RegionTeleportMonitor:DistributedValue;
var m_ItemShopMonitor:DistributedValue;
var m_AchievementMonitor:DistributedValue;
var m_HelpMonitor:DistributedValue;
var m_CraftingMonitor:DistributedValue;
var m_PetitionMonitor:DistributedValue;
var m_CabalMonitor:DistributedValue;
var m_FriendsMonitor:DistributedValue;
var m_LFGMonitor:DistributedValue;
var m_ItemShopMonitor:DistributedValue;
var m_ClaimMonitor:DistributedValue;
var m_BrowserMonitor:DistributedValue;
var m_LeaderboardsMonitor:DistributedValue;
//var m_LockoutsMonitor:DistributedValue;
var m_PetsMonitor:DistributedValue;
var m_ChallengeJournalMonitor:DistributedValue;
var m_GroupFinderMonitor:DistributedValue;
var m_TradepostMonitor:DistributedValue;
//var m_BankMonitor:DistributedValue;

var m_ClockShowRealTimeMonitor:DistributedValue;

var m_MinimapScaleMonitor:DistributedValue;

var m_InvisibleButton:MovieClip;
var m_CharacterSheetButton:MovieClip;
var m_ExitButton:MovieClip;
var m_InventoryButton:MovieClip;
var m_PvPButton:MovieClip;
var m_RegionTeleportButton:MovieClip;
var m_SettingsButton:MovieClip;
var m_JournalButton:MovieClip;
var m_AnimaWheelButton:MovieClip;
var m_ShopButton:MovieClip;
var m_CraftingButton:MovieClip;
var m_AchievementButton:MovieClip;
var m_HelpButton:MovieClip;
var m_CabalButton:MovieClip;
var m_FriendsButton:MovieClip;
var m_LFGButton:MovieClip;
var m_ClaimButton:MovieClip;
var m_BrowserButton:MovieClip;
var m_LeaderboardsButton:MovieClip;
//var m_LockoutButton:MovieClip;
var m_PetButton:MovieClip;
var m_ChallengeJournalButton:MovieClip;
var m_GroupFinderButton:MovieClip;
var m_TradepostButton:MovieClip;
//var m_BankButton:MovieClip;

var m_BackgroundBar:MovieClip;
var m_MenuItems:Array;

var m_ServerFramerate:Number;
var m_ClientFramerate:Number;
var m_Latency:Number;
var m_CurrentDate:Date;
var m_Tooltip:TooltipInterface;
var m_EscapeNode:com.GameInterface.EscapeStackNode = undefined;

var m_BlinkAmount:Number;
var m_ClockShowRealTime:Boolean;
var m_AnimateDownload:Boolean;

var m_UpdateInterval:Number;
var m_TrialEndTime:Number;

var m_MinimapEditModeMask:MovieClip;

var m_ScryTimerActive:Boolean;
var m_ScryCounterActive:Boolean;
var m_ScryTimerCounterComboActive:Boolean;
var m_FakeScryTimer:Boolean;
var m_FakeScryCounter:Boolean;
var m_FakeScryTimerCounterCombo:Boolean;

//On Load
function onLoad()
{
    m_Character = Character.GetClientCharacter();
	Character.SignalCharacterEnteredReticuleMode.Connect(SlotEnteredReticuleMode, this);
    
    //Create Distributed Values
    m_CharacterSheetMonitor 		= DistributedValue.Create("character_sheet");
    m_AnimaWheelMonitor 			= DistributedValue.Create("skillhive_window");
	m_InventoryMonitor 				= DistributedValue.Create("inventory_visible");
    m_JournalMonitor 				= DistributedValue.Create("mission_journal_window");
    m_PvPMonitor 					= DistributedValue.Create("pvp_spoils_window");
	m_RegionTeleportMonitor			= DistributedValue.Create("regionTeleport_window");
    m_AchievementMonitor 		    = DistributedValue.Create("achievement_lore_window");
    m_HelpMonitor 					= DistributedValue.Create("tutorial_window");
    m_CraftingMonitor               = DistributedValue.Create("ItemUpgradeWindow");
    m_PetitionMonitor               = DistributedValue.Create("petition_browser");
    m_CabalMonitor                  = DistributedValue.Create("guild_window");
    m_FriendsMonitor                = DistributedValue.Create("friends_window");
    m_LFGMonitor                    = DistributedValue.Create("group_search_window");
    m_ItemShopMonitor               = DistributedValue.Create("itemshop_window");
    m_ClaimMonitor                  = DistributedValue.Create("claim_window");
    m_BrowserMonitor                = DistributedValue.Create("web_browser");
    m_LeaderboardsMonitor           = DistributedValue.Create("leaderboards_browser");
	//m_LockoutsMonitor				= DistributedValue.Create("lockoutTimers_window");
	m_PetsMonitor					= DistributedValue.Create("petInventory_window");
	m_ChallengeJournalMonitor		= DistributedValue.Create("challengeJournal_window");
	m_GroupFinderMonitor			= DistributedValue.Create("groupFinder_window");
	m_TradepostMonitor				= DistributedValue.Create("tradepost_window");
	//m_BankMonitor					= DistributedValue.Create("bank_window");
    	
	m_ClockShowRealTimeMonitor		= DistributedValue.Create("ClockShowRealTime");
	
	m_MinimapScaleMonitor			= DistributedValue.Create("MinimapScale");
	
    m_ServerFramerate = 0;
    m_ClientFramerate = 0;
    m_Latency = 0;
    m_Tooltip = undefined;
    
    //Signal Listeners
	com.Utils.GlobalSignal.SignalInterfaceOptionsReset.Connect(Layout, this);
    m_CharacterSheetMonitor.SignalChanged.Connect(SlotCharacterSheetState, this);
    m_AnimaWheelMonitor.SignalChanged.Connect(SlotAnimaWheelState, this);
    m_InventoryMonitor.SignalChanged.Connect(SlotInventoryState, this);
    m_JournalMonitor.SignalChanged.Connect(SlotJournalState, this);
	m_PvPMonitor.SignalChanged.Connect(SlotPvPState, this);
	m_RegionTeleportMonitor.SignalChanged.Connect(SlotRegionTeleportState, this);
	m_HelpMonitor.SignalChanged.Connect(SlotHelpState, this);
    m_AchievementMonitor.SignalChanged.Connect(SlotAchievementState, this);
    m_CraftingMonitor.SignalChanged.Connect(SlotCraftingState, this);
    m_PetitionMonitor.SignalChanged.Connect(SlotPetitionState, this);
    m_CabalMonitor.SignalChanged.Connect(SlotCabalState, this);
    m_FriendsMonitor.SignalChanged.Connect(SlotFriendsState, this);
    m_LFGMonitor.SignalChanged.Connect(SlotLookingForGroupState, this);
    m_ItemShopMonitor.SignalChanged.Connect(SlotItemShopState, this);
	m_ClaimMonitor.SignalChanged.Connect(SlotClaimState, this);
    m_BrowserMonitor.SignalChanged.Connect(SlotBrowserState, this);
    m_LeaderboardsMonitor.SignalChanged.Connect(SlotLeaderboardsState, this);
	//m_LockoutsMonitor.SignalChanged.Connect(SlotLockoutsState, this);
	m_PetsMonitor.SignalChanged.Connect(SlotPetsState, this);
	m_ChallengeJournalMonitor.SignalChanged.Connect(SlotChallengeJournalState, this);
	m_GroupFinderMonitor.SignalChanged.Connect(SlotGroupFinderState, this);
	m_TradepostMonitor.SignalChanged.Connect(SlotTradepostState, this);
	//m_BankMonitor.SignalChanged.Connect(SlotBankState, this);
    
	SFClipLoader.SignalDisplayResolutionChanged.Connect(Layout, this);	
	
	m_ClockShowRealTimeMonitor.SignalChanged.Connect(SlotClockTypeChanged, this);
	
	m_MinimapScaleMonitor.SignalChanged.Connect(LayoutEditModeMask, this);
    
    m_MenuIconContainer = createEmptyMovieClip("m_MenuIconContainer", getNextHighestDepth());
    m_InvisibleButton.swapDepths(m_MenuIconContainer);
    m_MenuIcon = m_MenuIconContainer.attachMovie("MenuIcon", "m_MenuIcon", m_MenuIconContainer.getNextHighestDepth());
    m_MenuIconContainer._x = ICON_MARGIN;
    
    var label:TextField = m_MenuIconContainer.createTextField("m_Label", m_MenuIconContainer.getNextHighestDepth(), 17, ICON_LABEL_Y, 0, 0);
    label.autoSize = "left";
    label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
    label.text = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Menu");
	label._x = 20;
	label._y = 3;
	
	/*
	m_SprintIconContainer = createEmptyMovieClip("m_SprintIconContainer", getNextHighestDepth());
	m_SprintIcon = m_SprintIconContainer.attachMovie("SprintIcon", "m_SprintIcon", m_SprintIconContainer.getNextHighestDepth());
	m_SprintIconContainer.onPress = Delegate.create(this, ToggleSprint);
	TooltipUtils.AddTextTooltip(m_SprintIconContainer, LDBFormat.LDBGetText("GenericGUI", "MainMenuToggleSprintTooltip") + " (<variable name='hotkey:Movement_SprintToggle'/ >)", 160, TooltipInterface.e_OrientationHorizontal, true);
	*/
	
	m_MemberIconContainer = createEmptyMovieClip("m_MemberIconContainer", getNextHighestDepth());
	m_MemberIcon = m_MemberIconContainer.attachMovie("MemberIcon", "m_MemberIcon", m_MemberIconContainer.getNextHighestDepth());
	m_MemberIconContainer.onPress = Delegate.create(this, ToggleShopMembership);
	TooltipUtils.AddTextTooltip(m_MemberIconContainer, m_TDB_Membership, 300, TooltipInterface.e_OrientationVertical, true);
	m_Character.SignalMemberStatusUpdated.Connect(this, UpdateMembershipStatus);
	UpdateMembershipStatus(m_Character.IsMember());	
	
	m_ShopIconContainer = createEmptyMovieClip("m_ShopIconContainer", getNextHighestDepth());
	m_ShopIcon = m_ShopIconContainer.attachMovie("ShopIcon", "m_ShopIcon", m_ShopIconContainer.getNextHighestDepth());
	m_ShopIconContainer.onPress = Delegate.create(this, ToggleShop);
	TooltipUtils.AddTextTooltip(m_ShopIconContainer, m_TDB_Shop, 160, TooltipInterface.e_OrientationHorizontal, true);
	
	if (m_Character.IsUnlimitedTrialAccount())
	{
		m_TrialContainer = createEmptyMovieClip("m_TrialContainer", getNextHighestDepth());
		m_TrialContainer.onPress = Delegate.create(this, ToggleShop);
		label = m_TrialContainer.createTextField("m_DaysRemainingLabel", m_TrialContainer.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
		label.autoSize = "left";
		label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE_LARGE, COLOR, true));
		m_TrialEndTime = m_Character.GetStat(_global.Enums.Stat.e_TrialDays);
		label.text = FormatTrialTime(m_TrialEndTime);
		label._x = 5;
		label._y = 2;	
		m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
	}
	
	m_TokenIconContainer_1 = createEmptyMovieClip("m_TokenIconContainer_1", getNextHighestDepth());
	m_TokenIcon_1 = m_TokenIconContainer_1.attachMovie("T1", "m_Token1Icon", m_TokenIconContainer_1.getNextHighestDepth());
	label = m_TokenIconContainer_1.createTextField("m_Label", m_TokenIconContainer_1.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
	label.autoSize = "left";
	label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
	label.text = Text.AddThousandsSeparator(m_Character.GetTokens(_global.Enums.Token.e_Anima_Point));
	label._x = 23;
	label._y = 3;
	m_TokenIconContainer_1.onPress = Delegate.create(this, OpenAnimaWheel);
	TooltipUtils.AddTextTooltip(m_TokenIconContainer_1, m_TDB_AbilityWheel, 160, TooltipInterface.e_OrientationHorizontal, true);
	
	m_TokenIconContainer_2 = createEmptyMovieClip("m_TokenIconContainer_2", getNextHighestDepth());
	m_TokenIcon_2 = m_TokenIconContainer_2.attachMovie("T2", "m_Token2Icon", m_TokenIconContainer_2.getNextHighestDepth());
	label = m_TokenIconContainer_2.createTextField("m_Label", m_TokenIconContainer_2.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
	label.autoSize = "left";
	label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
	label.text = Text.AddThousandsSeparator(m_Character.GetTokens(_global.Enums.Token.e_Skill_Point));
	label._x = 23;
	label._y = 3;
	m_TokenIconContainer_2.onPress = Delegate.create(this, OpenAnimaWheel);
	TooltipUtils.AddTextTooltip(m_TokenIconContainer_2, m_TDB_AbilityWheel, 160, TooltipInterface.e_OrientationHorizontal, true);
	
	m_TokenIcon_1.m_EN._visible = m_TokenIcon_1.m_FR._visible = m_TokenIcon_1.m_DE._visible = false;
	m_TokenIcon_2.m_EN._visible = m_TokenIcon_2.m_FR._visible = m_TokenIcon_2.m_DE._visible = false;
	var languageCode:String = LDBFormat.GetCurrentLanguageCode();
	switch(languageCode)
	{
		case "en":
			m_TokenIcon_1.m_EN._visible = m_TokenIcon_2.m_EN._visible = true;
		case "fr":
			m_TokenIcon_1.m_FR._visible = m_TokenIcon_2.m_FR._visible = true;
		case "de":
			m_TokenIcon_1.m_DE._visible = m_TokenIcon_2.m_DE._visible = true;
	}
	
	m_TokenIconContainer_201 = createEmptyMovieClip("m_TokenIconContainer_201", getNextHighestDepth());
	m_TokenIcon_201 = m_TokenIconContainer_201.attachMovie("T201", "m_Token201Icon", m_TokenIconContainer_201.getNextHighestDepth());
	label = m_TokenIconContainer_201.createTextField("m_Label", m_TokenIconContainer_201.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
	label.autoSize = "left";
	label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
	label.text = Text.AddThousandsSeparator(m_Character.GetTokens(_global.Enums.Token.e_Gold_Bullion_Token));
	label._x = 23;
	label._y = 3;
	m_TokenIconContainer_201.onPress = Delegate.create(this, OpenTradepost);
	TooltipUtils.AddTextTooltip(m_TokenIconContainer_201, m_TDB_Tradepost, 160, TooltipInterface.e_OrientationHorizontal, true);
	
	m_TokenIconContainer_202 = createEmptyMovieClip("m_TokenIconContainer_202", getNextHighestDepth());
	m_TokenIcon_202 = m_TokenIconContainer_202.attachMovie("T202", "m_Token202Icon", m_TokenIconContainer_202.getNextHighestDepth());
	label = m_TokenIconContainer_202.createTextField("m_Label", m_TokenIconContainer_202.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
	label.autoSize = "left";
	label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
	label.text = Text.AddThousandsSeparator(m_Character.GetTokens(_global.Enums.Token.e_Premium_Token));
	label._x = 34;
	label._y = 3;
	m_TokenIconContainer_202.onPress = Delegate.create(this, BuyAurum);
	TooltipUtils.AddTextTooltip(m_TokenIconContainer_202, m_TDB_BuyAurum, 160, TooltipInterface.e_OrientationHorizontal, true);
	
	m_TokenIconContainer_10 = createEmptyMovieClip("m_TokenIconContainer_10", getNextHighestDepth());
	m_TokenIcon_10 = m_TokenIconContainer_10.attachMovie("T10", "m_Token10Icon", m_TokenIconContainer_10.getNextHighestDepth());
	label = m_TokenIconContainer_10.createTextField("m_Label", m_TokenIconContainer_10.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
	label.autoSize = "left";
	label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
	label.text = Text.AddThousandsSeparator(m_Character.GetTokens(_global.Enums.Token.e_Cash));
	label._x = 22;
	label._y = 3;
	
	m_ShardGainContainer = createEmptyMovieClip("m_ShardGainContainer", getNextHighestDepth());
	label = m_ShardGainContainer.createTextField("m_Label", m_ShardGainContainer.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
	label.autoSize = "left";
	label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
	label.text = "SHARD GAIN";
	label._x = 0;
	label._y = 3;
	m_ShardGainContainer._alpha = 0;
	m_LastShardGain = 0;
	
	
	m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
	
	m_LockIconContainer = createEmptyMovieClip("m_LockIconContainer", getNextHighestDepth());
	m_LockIcon = m_LockIconContainer.attachMovie("LockIcon", "m_LockIcon", m_LockIconContainer.getNextHighestDepth());
	m_LockIconContainer.onPress = Delegate.create(this, ToggleGUILock);
	
	m_LockIcon.m_Unlocked._visible = false;
	TooltipUtils.AddTextTooltip(m_LockIconContainer, LDBFormat.LDBGetText("GenericGUI", "MainMenuGUILockTooltip"), 160, TooltipInterface.e_OrientationHorizontal,  true);
	GlobalSignal.SignalSetGUIEditMode.Emit(false);
    
    m_ClockIconContainer = createEmptyMovieClip("m_ClockIconContainer", getNextHighestDepth());
    m_ClockIcon = m_ClockIconContainer.attachMovie("ClockIcon", "m_ClockIcon", m_ClockIconContainer.getNextHighestDepth());
	m_ClockIconContainer.onPress = Delegate.create(this, SlotToggleClockType);
    
    label = m_ClockIconContainer.createTextField("m_Label", m_ClockIconContainer.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
    label.autoSize = "left";
    label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
    label.text = "00:00"
	label._x = 17;
	label._y = 3;
	
	TooltipUtils.AddTextTooltip(m_ClockIconContainer, LDBFormat.LDBGetText("GenericGUI", "MainMenuClockTooltip"), 160, TooltipInterface.e_OrientationHorizontal,  true);
	
	SlotClockTypeChanged();
    
    m_FPSIconContainer = createEmptyMovieClip("m_FPSIconContainer", getNextHighestDepth());
    m_FPSIcon = m_FPSIconContainer.attachMovie("LatencyIcon", "m_FPSIcon", m_FPSIconContainer.getNextHighestDepth());
    
    m_FPSIconContainer.onPress = function() { };
    m_FPSIconContainer.onRollOver = Delegate.create(this, SlotRollOverLatency);
    m_FPSIconContainer.onRollOut = m_FPSIconContainer.onDragOut = Delegate.create(this, SlotRollOutIcon);
    
    m_MailIconContainer = createEmptyMovieClip("m_MailIconContainer", getNextHighestDepth());
    m_MailIcon = m_MailIconContainer.attachMovie("MailIcon", "m_MailIcon", m_MailIconContainer.getNextHighestDepth());
    m_MailIconContainer.onPress = function() { if(this.enabled) DistributedValue.SetDValue("tradepost_window", true); };
    m_MailIconContainer.onRollOver = Delegate.create(this, SlotRollOverMail);
    m_MailIconContainer.onRollOut = m_MailIconContainer.onDragOut = Delegate.create(this, SlotRollOutIcon);

    m_MailIconContainer._alpha = (Tradepost.HasUnreadMail()) ? 100 : 0;
    m_MailIcon.enabled = (Tradepost.HasUnreadMail()) ? true : false;

    Tradepost.SignalAllMailRead.Connect(SlotAllMailReadNotification, this);
    Tradepost.SignalNewMailNotification.Connect(SlotNewMailNotification, this);
    
    m_BlinkAmount = MAX_BLINK_AMOUNT;
    
    m_DownloadingIconContainer = createEmptyMovieClip("m_DownloadingIconContainer", getNextHighestDepth());
    m_DownloadingIcon = m_DownloadingIconContainer.attachMovie("DownloadingIcon", "m_DownloadingIcon", m_DownloadingIconContainer.getNextHighestDepth());
    m_DownloadingIconContainer.onRollOver = Delegate.create(this, SlotRollOverDownloading);
    m_DownloadingIconContainer.onRollOut = m_DownloadingIconContainer.onDragOut = Delegate.create(this, SlotRollOutIcon);
    m_DownloadingIcon._visible = false;
    
    Layout();
    
    UpdateMainMenuItems();
    
	m_PvPQueueMarker._visible = false;
    m_ButtonsBackground._visible = false;
    m_IsMenuOpen = false;
    
    m_UpdateInterval = setInterval(SlotUpdateInterval, 1000);
    
    ClientServerPerfTracker.SignalLatencyUpdated.Connect(SlotLatencyUpdated, this);
    ClientServerPerfTracker.SignalServerFramerateUpdated.Connect(SlotServerFramerateUpdated, this);
    ClientServerPerfTracker.SignalClientFramerateUpdated.Connect(SlotClientFramerateUpdated, this);
    
    SlotLatencyUpdated(ClientServerPerfTracker.GetLatency());
    SlotClientFramerateUpdated(ClientServerPerfTracker.GetClientFramerate());
    SlotServerFramerateUpdated(ClientServerPerfTracker.GetServerFramerate());
	
	GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);
	GlobalSignal.SignalScryTimerLoaded.Connect(SlotScryTimerLoaded, this);
	GlobalSignal.SignalScryCounterLoaded.Connect(SlotScryCounterLoaded, this);
	GlobalSignal.SignalScryTimerCounterComboLoaded.Connect(SlotScryTimerCounterComboLoaded, this);
	
	//Setup editing controls
	m_MinimapEditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_MinimapEditModeMask.onRelease = m_MinimapEditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_MinimapEditModeMask._visible = false;
}

//On Unload
function onUnload():Void
{
    clearInterval(m_UpdateInterval);
	if (m_FakeScryCounter)
	{
		_root.UnloadFlash("ScryCounter");
	}
	if (m_FakeScryTimer)
	{
		_root.UnloadFlash("ScryTimer");
	}
	if (m_FakeScryTimerCounterCombo)
	{
		_root.UnloadFlash("ScryTimerCounterCombo");
	}
}

function UpdateMembershipStatus(member:Boolean):Void
{
	if (member)
	{
		m_MemberIcon._alpha = 100;
	}
	else
	{
		m_MemberIcon._alpha = 33;
	}
}

//Update Main Menu Items
function UpdateMainMenuItems():Void
{
    MainMenuToggleMouseListeners(true);

    m_MenuItems = new Array();

    m_InvisibleButton._alpha = 0;
    m_InvisibleButton.onRelease = Delegate.create(this, MainMenuReleaseEventHandler);
    m_InvisibleButton.disableFocus = true;
    
    var allowedToReceiveItems:Boolean = m_Character.CanReceiveItems();
    
	if (DistributedValue.GetDValue("CharacterSheet_Allowed"))
	{
    	SetupMenuItem(m_CharacterSheetButton, "character_sheet", "CharacterSheetHandler", m_TDB_CharacterSheet + " (<variable name='hotkey:Toggle_SP_Character'/ >)");
	}
	else
	{
		m_CharacterSheetButton._visible = false;
	}
	if (DistributedValue.GetDValue("Inventory_Allowed"))
	{
    	SetupMenuItem(m_InventoryButton, "inventory_visible", "InventoryHandler", m_TDB_Inventory + " (<variable name='hotkey:Toggle_InventoryView'/ >)");
	}
	else
	{
		m_InventoryButton._visible = false;
	}
	if (DistributedValue.GetDValue("Crafting_Allowed"))
	{
		SetupMenuItem(m_CraftingButton, "ItemUpgradeWindow", "CraftingHandler", m_TDB_Crafting + " (<variable name='hotkey:Toggle_CraftingWindow'/ >)");
	}
	else
	{
		m_CraftingButton._visible = false;
	}
	if (DistributedValue.GetDValue("Skillhive_Allowed"))
	{
    	SetupMenuItem(m_AnimaWheelButton, "skillhive_window", "AnimaWheelHandler", m_TDB_AbilityWheel + " (<variable name='hotkey:Toggle_SkillHive'/ >)");
	}
	else
	{
		m_AnimaWheelButton._visible = false;
	}
	if (DistributedValue.GetDValue("PetsSprints_Allowed"))
	{
		SetupMenuItem(m_PetButton, "petInventory_window", "PetHandler", m_TDB_Pets + " (<variable name='hotkey:Toggle_PetWindow'/ >)");
	}
	else
	{
		m_PetButton._visible = false;
	}
	if (!LoreBase.IsLocked(REGION_TELEPORT_ENABLE))
	{
		SetupMenuItem(m_RegionTeleportButton, "regionTeleport_window", "RegionTeleportHandler", m_TDB_RegionTeleport + " (<variable name='hotkey:Toggle_RegionTeleportWindow'/ >)");
	}
	else
	{
		m_RegionTeleportButton._visible = false;
	}
	if (DistributedValue.GetDValue("AchievementLore_Allowed"))
	{
    	SetupMenuItem(m_AchievementButton, "achievement_lore_window", "AchievementHandler", m_TDB_Achievement + " (<variable name='hotkey:Toggle_AchievementWindow'/ >)");
	}
	else
	{
		m_AchievementButton._visible = false;
	}	
	if (DistributedValue.GetDValue("MissionJournal_Allowed"))
	{
		SetupMenuItem(m_JournalButton, "mission_journal_window", "JournalHandler", m_TDB_Journal + " (<variable name='hotkey:Toggle_MissionJournalWindow'/ >)");
	}
	else
	{
		m_JournalButton._visible = false;
	}
	if (DistributedValue.GetDValue("ChallengeJournal_Allowed"))
	{
		SetupMenuItem(m_ChallengeJournalButton, "challengeJournal_window", "ChallengeJournalHandler", m_TDB_ChallengeJournal + " (<variable name='hotkey:Toggle_ChallengeJournalWindow'/ >)");
	}
	else
	{
		m_ChallengeJournalButton._visible = false;
	}	
	if (DistributedValue.GetDValue("Friends_Allowed"))
	{
		SetupMenuItem(m_FriendsButton, "friends_window", "FriendsHandler", m_TDB_Friends + " (<variable name='hotkey:Toggle_FriendsView'/ >)");
	}
	else
	{
		m_FriendsButton._visible = false;
	}
	if (DistributedValue.GetDValue("Cabal_Allowed"))
	{
    	SetupMenuItem(m_CabalButton, "guild_window", "CabalHandler", m_TDB_Cabal + " (<variable name='hotkey:Toggle_GuildWindow'/ >)");
	}
	else
	{
		m_CabalButton._visible = false;
	}
	if (DistributedValue.GetDValue("Social_Allowed"))
	{
		SetupMenuItem(m_LFGButton, "group_search_window", "LFGHandler", m_TDB_LFG + " (<variable name='hotkey:Toggle_GroupSearchWindow'/ >)");
	}
	else
	{
		m_LFGButton._visible = false;
	}
	if (!LoreBase.IsLocked(GROUP_FINDER_ENABLE))
	{
		SetupMenuItem(m_GroupFinderButton, "groupFinder_window", "GroupFinderHandler", m_TDB_GroupFinder + " (<variable name='hotkey:Toggle_GroupFinderWindow'/ >)");
	}
	else
	{
		m_GroupFinderButton._visible = false;
		m_PvPButton._visible = false;
	}
	/*
	if (DistributedValue.GetDValue("Lockouts_Allowed"))
	{
		SetupMenuItem(m_LockoutButton, "lockoutTimers_window", "LockoutHandler", m_TDB_Lockouts + " (<variable name='hotkey:Toggle_LockoutWindow'/ >)");
	}
	else
	{
		m_LockoutButton._visible = false;
	}
	*/
    if ( allowedToReceiveItems )
    {
		SetupMenuItem(m_PvPButton, "pvp_spoils_window", "PvPHandler", m_TDB_PvP);
        SetupMenuItem(m_ClaimButton, "claim_window", "ClaimHandler", m_TDB_Claim);
		SetupMenuItem(m_TradepostButton, "tradepost_window", "TradepostHandler", m_TDB_Tradepost + " (<variable name='hotkey:Toggle_TradepostWindow'/ >)");
		//SetupMenuItem(m_BankButton, "bank_window", "BankHandler", m_TDB_Bank + " (<variable name='hotkey:Toggle_BankWindow'/ >)");
    }
	else
	{
		m_ClaimButton._visible = false;
		m_TradepostButton._visible = false;
		//m_BankButton._visible = false;
	}
    
    SetupMenuItem(m_BrowserButton, "web_browser", "BrowserHandler", m_TDB_WebBrowser + " (<variable name='hotkey:Toggle_Browser'/ >)");
    SetupMenuItem(m_HelpButton, "petition_browser", "PetitionHandler", m_TDB_Help); 
	if ( allowedToReceiveItems )
	{
    	SetupMenuItem(m_ShopButton, "itemshop_window", "ShopHandler", m_TDB_Shop, allowedToReceiveItems, m_TDB_Shop_DisabledTooltip);
	}
    
    var enableChronicle:Number = com.GameInterface.Utils.GetGameTweak("GUIEnableChronicle");
    if (enableChronicle != 0) 
    {
        SetupMenuItem(m_LeaderboardsButton, "leaderboards_browser", "LeaderboardsHandler", m_TDB_Leaderboards + " (<variable name='hotkey:Toggle_Leaderboards'/ >)");
    }
	else
	{
		m_LeaderboardsButton._visible = false;
	}

    SetupMenuItem(m_SettingsButton, null, "SettingsHandler", m_TDB_Settings + " (<variable name='hotkey:Toggle_Options'/ >)");
    SetupMenuItem(m_ExitButton, null, "ExitHandler", m_TDB_Exit);
	
	for (var i:Number = 0; i < m_MenuItems.length; i++)
	{
		var menuItem:MovieClip = m_MenuItems[i];

		menuItem._alpha = 0;
		menuItem._y = 0;
		menuItem._visible = false;
	}
}

//Setup Menu Item
function SetupMenuItem(item:MovieClip, distributedValue:String, eventHandler:String, label:String, enable:Boolean, disabledTooltip:String):Void
{
	if (enable == undefined)
	{
		enable = true;
	}
	
    if (distributedValue)
    {
        SetDotState(item, DistributedValue.GetDValue(distributedValue));
    }
    
    item.m_TextField.text = label;
	item.disableFocus = true;
	
	if (enable)
	{
		item.addEventListener("click", this, eventHandler);
	}
	else
	{
		if (disabledTooltip != undefined)
		{
			// explain why the item is disabled
			TooltipUtils.AddTextTooltip(item, disabledTooltip);
		}
		item.m_TextField.textColor = 0xAAAAAA;
		item.disabled = true;
	}
    
	m_MenuItems.push(item);
}

//Layout
function Layout():Void
{
    var fullScreenWidth = Stage["visibleRect"].width;
    m_BackgroundBar._x = 0;
    m_BackgroundBar._width = fullScreenWidth;
        
    var baseSize:Number = m_BackgroundBar._height;
    
    m_MenuIcon._xscale = m_MenuIcon._yscale = baseSize * 0.70;
    m_InvisibleButton._x = m_InvisibleButton._y = 0;
    m_InvisibleButton._height = m_BackgroundBar._height;
    m_InvisibleButton._width = m_MenuIconContainer._width + ICON_MARGIN;
    m_MenuIcon._y = 4;
	
	/*
	m_SprintIcon._xscale = m_SprintIcon._yscale = baseSize * 0.65;
	m_SprintIconContainer._x = m_InvisibleButton._width + ICON_MARGIN;
	m_SprintIcon._y = 4;
	*/

	m_MemberIconContainer._x = m_MenuIconContainer._x + m_MenuIconContainer._width + ICON_MARGIN;
	m_MemberIcon._y = 0;
	
	m_ShopIcon._xscale = m_ShopIcon._yscale = 90;
	m_ShopIconContainer._x = m_MemberIconContainer._x + m_MemberIconContainer._width + ICON_MARGIN;
	m_ShopIcon._y = 1;
	
	var clipBeforeTokens: MovieClip = m_ShopIconContainer;
	if (m_TrialContainer != undefined)
	{
		m_TrialContainer._x = m_ShopIconContainer._x + m_ShopIconContainer._width + ICON_MARGIN;
		var clipBeforeTokens = m_TrialContainer;
	}
	
	m_TokenIcon_202._xscale = m_TokenIcon_202._yscale = 90;
	m_TokenIconContainer_202._x = clipBeforeTokens._x + clipBeforeTokens._width + ICON_MARGIN - 3;
	m_TokenIconContainer_202._y = 0;
	
	m_TokenIcon_201._xscale = m_TokenIcon_201._yscale = 90;
	m_TokenIconContainer_201._x = m_TokenIconContainer_202._x + m_TokenIconContainer_202._width + ICON_MARGIN;
	m_TokenIconContainer_201._y = 0;
	
	m_TokenIcon_10._xscale = m_TokenIcon_10._yscale = 90;
	m_TokenIconContainer_10._x = m_TokenIconContainer_201._x + m_TokenIconContainer_201._width + ICON_MARGIN;
	m_TokenIconContainer_10._y = 1;
	
	m_ShardGainContainer._x = m_TokenIconContainer_10._x + m_TokenIconContainer_10._width;
	m_ShardGainContainer._y = 1;
	
	m_LockIcon._xscale = m_LockIcon._yscale = baseSize * 0.65;
	m_LockIconContainer._x = m_BackgroundBar._width - m_LockIconContainer._width - ICON_MARGIN;
	m_LockIcon._y = 4;

    m_ClockIcon._xscale = m_ClockIcon._yscale = baseSize * 0.65;
    m_ClockIconContainer._x = m_LockIconContainer._x - m_ClockIconContainer._width - ICON_MARGIN;
    m_ClockIcon._y = 4;

    m_FPSIcon._xscale = m_FPSIcon._yscale = baseSize * 0.65;
    m_FPSIconContainer._x = m_ClockIconContainer._x - m_FPSIconContainer._width - 12;
    m_FPSIcon._y = 5;
	
	m_TokenIcon_1._xscale = m_TokenIcon_1._yscale = 90;
	m_TokenIconContainer_1._x = m_FPSIconContainer._x - m_TokenIconContainer_1._width - 12;
	m_TokenIconContainer_1._y = 1;
	
	m_TokenIcon_2._xscale = m_TokenIcon_2._yscale = 90;
	m_TokenIconContainer_2._x = m_TokenIconContainer_1._x - m_TokenIconContainer_2._width - 12;
	m_TokenIconContainer_2._y = 1;
    
    m_MailIcon._xscale = m_MailIcon._yscale  = baseSize * 0.65;
    m_MailIconContainer._x = m_TokenIconContainer_2._x - m_MailIconContainer._width - 12;
    m_MailIcon._y = 5;

    m_DownloadingIcon._xscale = m_DownloadingIcon._yscale  = baseSize * 0.65;
    m_DownloadingIconContainer._x = (m_MailIcon.enabled) ? m_MailIconContainer._x - m_DownloadingIconContainer._width - 6 : m_TokenIconContainer_2._x - m_DownloadingIconContainer._width - 6;
    m_DownloadingIcon._y = 9;
	
	LayoutEditModeMask();
}

//Main Menu Toggle Mouse Listeners
function MainMenuToggleMouseListeners(enabled:Boolean):Void
{
    if (enabled)
    {
        m_InvisibleButton.onRollOver = function() {Colors.ApplyColor(m_MenuIconContainer.m_MenuIcon, 0xFFFFFF)};
        m_InvisibleButton.onRollOut = m_InvisibleButton.onReleaseOutside = function() {Colors.ApplyColor(m_MenuIconContainer.m_MenuIcon, COLOR)};  
    }
    else
    {
        m_InvisibleButton.onRollOver = null;
        m_InvisibleButton.onRollOut = m_InvisibleButton.onReleaseOutside = null;
    }
}

//Slot Roll Over Latency
function SlotRollOverLatency()
{
    if (m_Character != undefined && m_Character.GetStat(_global.Enums.Stat.e_GmLevel) != 0) 
    {
        if (m_Tooltip != undefined)
        {
            m_Tooltip.Close();
        }
        
        var tooltipData:TooltipData = new TooltipData();
        tooltipData.m_Descriptions.push(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "MainMenu_LatencyTooltip"), Math.floor(m_Latency * 1000)));
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 100;
        
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
    }
}

//Slot Roll Over Mail
function SlotRollOverMail()
{
    if (m_Tooltip != undefined)
    {
        m_Tooltip.Close();
    }

    if (m_MailIcon.enabled)
    {
        var tooltipData:TooltipData = new TooltipData();
        tooltipData.AddAttribute("", LDBFormat.LDBGetText("GenericGUI", "MainMenu_MailTooltipTitle"));
        tooltipData.AddAttributeSplitter();
        tooltipData.AddAttribute("", LDBFormat.LDBGetText("GenericGUI", "MainMenu_MailTooltip"));
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 160;
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
    }
}

//Slot Roll Over Downloading
function SlotRollOverDownloading()
{
    if (m_Tooltip != undefined)
    {
        m_Tooltip.Close();
    }

    if (m_DownloadingIcon.enabled)
    {
        var t:Number = ClientServerPerfTracker.GetDownloadSecondsRemaining();
        var tooltipData:TooltipData = new TooltipData();
        tooltipData.m_Descriptions.push(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "MainMenu_DownloadingTooltip"), Math.floor(t / 3600), Math.floor((t / 3600) / 60), Math.floor((t / 3600) % (60)))); //Download Time Remaining: %d:$d:%d
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 160;
        
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
    }
}

//Slot Roll Out Icon
function SlotRollOutIcon()
{
    if (m_Tooltip != undefined)
    {
        m_Tooltip.Close();
    }
}

//Slot Update Interval
function SlotUpdateInterval():Void
{
    DownloadContent(ClientServerPerfTracker.GetTotalRemainingDownloads() != 0);
    
    var timeOfDay:Number;
    var hours:Number = 0;
    var minutes:Number = 0;
    
	if (m_ClockShowRealTime)
	{
        m_CurrentDate = new Date();
        
		hours = m_CurrentDate.getHours();
		minutes = m_CurrentDate.getMinutes();
	}
	else
	{
		timeOfDay = com.GameInterface.Utils.GetTimeOfDay();        
        hours = Math.floor(timeOfDay / 60 / 60);
        minutes = Math.floor(timeOfDay / 60 % 60);
	}
    
    m_ClockIconContainer.m_Label.text = com.Utils.Format.Printf("%02d:%02d", hours ,minutes);
	
	if (m_TrialContainer != undefined)
	{
		m_TrialContainer.m_DaysRemainingLabel.text = FormatTrialTime(m_TrialEndTime);
	}
}

function SlotStatChanged(statId:Number)
{
	if (statId == _global.Enums.Stat.e_TrialDays)
	{
		m_TrialEndTime = m_Character.GetStat(_global.Enums.Stat.e_TrialDays);
		m_TrialContainer.m_DaysRemainingLabel.text = FormatTrialTime(m_TrialEndTime);
	}
	else if (statId == _global.Enums.Stat.e_SubscriptionFlags)
	{
		if (!m_Character.IsUnlimitedTrialAccount() && m_TrialContainer != undefined)
		{
			m_TrialContainer.removeMovieClip();
			m_TrialContainer = undefined;
		}
	}
}

function FormatTrialTime(trialEndTime:Number):String
{
	var currTime:Number = com.GameInterface.Utils.GetServerSyncedTime();
	var timeLeft:Number = trialEndTime - currTime;
	
	if (timeLeft <= 0)
	{
		return m_TDB_TrialExpired;
	}	
	else if (timeLeft < 86400)
	{
		var numHours:Number = Math.ceil(timeLeft/3600);
		return LDBFormat.Printf(m_TDB_TrialRemainingHours, numHours);
	}
	else
	{
		var numDays:Number = Math.ceil(timeLeft/86400);
		return LDBFormat.Printf(m_TDB_TrialRemainingDays, numDays);
	}
}

//Slot Latency Update
function SlotLatencyUpdated(latency:Number):Void
{
    m_Latency = latency;
    m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = false;
    m_FPSIconContainer.m_FPSIcon.m_LatencyBar2._visible = false;
    m_FPSIconContainer.m_FPSIcon.m_LatencyBar3._visible = false;
    m_FPSIconContainer.m_FPSIcon.m_LatencyBar4._visible = false;
    
    if (m_Latency < 0.05)
    {
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar2._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar3._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar4._visible = true;
    }
    else if (m_Latency < 0.15)
    {
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar2._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar3._visible = true;
    }
    else if (m_Latency < 0.5)
    {
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar2._visible = true;
    }
    else
    {
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = true;
    }
}

//Slot Server Framerate Update
function SlotServerFramerateUpdated(framerate:Number):Void
{
    m_ServerFramerate = framerate;
}

//Slot Client Framerate Update
function SlotClientFramerateUpdated(framerate:Number):Void
{
    m_ClientFramerate = framerate;
}

//Slot New Mail notification
function SlotNewMailNotification():Void
{
    if (m_MailIconContainer != undefined)
    {
        BlinkMailIcon();
    
        m_Character.AddEffectPackage(RECEIVE_MAIL_SOUND_EFFECT);

        m_MailIcon.enabled = true;
        
        Layout();
    }
}

//Slot Mail Read Notification
function SlotAllMailReadNotification():Void
{
    if (m_MailIconContainer != undefined)
    {
        m_BlinkAmount = MAX_BLINK_AMOUNT;
        
        m_MailIconContainer.tweenTo(BLINK_ANIMATION_DURATION, { _alpha: 0 }, None.easeNone);
        m_MailIconContainer.onTweenComplete = undefined;
        
        m_MailIcon.enabled = false;
        
        Layout();
    }
}

//Blink Mail Icon
function BlinkMailIcon():Void
{
    m_MailIconContainer.tweenTo(BLINK_ANIMATION_DURATION, { _alpha: 100 }, None.easeNone);
    
    if (m_BlinkAmount > 0)
    {
        m_BlinkAmount--;
        m_MailIconContainer.onTweenComplete = BlinkMailIconCallback;
    }
    else
    {
        m_BlinkAmount = MAX_BLINK_AMOUNT;
        m_MailIconContainer.onTweenComplete = undefined;
    }
}

//Blink Mail Notification
function BlinkMailIconCallback():Void
{
    m_MailIconContainer.tweenTo(BLINK_ANIMATION_DURATION, { _alpha: 0 }, None.easeNone);
    m_MailIconContainer.onTweenComplete = BlinkMailIcon;
}

//Download Content
function DownloadContent(contentAvaliable:Boolean):Void
{
    if (m_DownloadingIconContainer != undefined)
    {
        m_DownloadingIcon._visible = contentAvaliable;
        m_AnimateDownload = contentAvaliable;
        
        AnimateDownloadingIcon();
    }
}

//Animate Downloading Icon
function AnimateDownloadingIcon():Void
{
    if (m_AnimateDownload)
    {
        m_DownloadingIcon.tweenTo(1.0, {_rotation: 360}, None.easeNone);
        m_DownloadingIcon.onTweenComplete = CheckDownloadingProgress;
    }
    else
    {
        m_DownloadingIcon.onTweenComplete = undefined;
    }
}

//Check Downloading Progress
function CheckDownloadingProgress():Void
{
    if (ClientServerPerfTracker.GetTotalRemainingDownloads() <= 0)
    {
        m_AnimateDownload = false;
    }
    
    DownloadContent(m_AnimateDownload);
}

//Set Dot State
function SetDotState(button:MovieClip, isOpen:Boolean)
{
	var label:String = (isOpen ? "open" : "close");
    button.i_OnOff.gotoAndStop(label);
}

//Main Menu Release Event Handler
function MainMenuReleaseEventHandler():Void
{
    if (m_IsMenuOpen)
    {
        m_IsMenuOpen = false;
		
        for (var i:Number = 0; i < m_MenuItems.length; i++)
		{
			var menuItem:MovieClip = m_MenuItems[i];

			menuItem.tweenTo(ANIMATION_DURATION, { _alpha: 0, _y: 0 }, None.easeNone);
			menuItem.onTweenComplete = function()
			{
				this._visible = false;
			}
		}
        
		m_ButtonsBackground.tweenTo(ANIMATION_DURATION, { _yscale: 0 }, None.easeNone);
		m_ButtonsBackground.onTweenComplete = function()
		{
			this._visible = false;
            Colors.ApplyColor(m_MenuIconContainer.m_MenuIcon, COLOR);
            MainMenuToggleMouseListeners(true);
		}
        if ( m_EscapeNode != undefined )
        {
            m_EscapeNode.SignalEscapePressed.Disconnect( RemoveMenu, this );
            m_EscapeNode = undefined;
        }
    }
    else
    {
        UpdateMainMenuItems();
        
        m_EscapeNode = new com.GameInterface.EscapeStackNode;
        m_EscapeNode.SignalEscapePressed.Connect( SlotEscapePressed, this );
        com.GameInterface.EscapeStack.Push( m_EscapeNode );
        
        MainMenuToggleMouseListeners(false);
        Colors.ApplyColor(m_MenuIconContainer.m_MenuIcon, 0xFFFFFF);
		
        m_IsMenuOpen = true;
        
		var directionModifier:Number = 1;
		if (DistributedValue.GetDValue( "TopMenuAlignment", 0 ) == 1)
		{
			directionModifier = -1;
		}
		var yPos:Number = STARTING_Y_POSITION * directionModifier;
		
        for (var i:Number = 0; i < m_MenuItems.length; i++)
		{
			var menuItem:MovieClip = m_MenuItems[i];
			menuItem._visible = true;
			menuItem._alpha = 0;
			menuItem.tweenTo(ANIMATION_DURATION, { _alpha: 100, _y:yPos }, None.easeNone);
			menuItem.onTweenComplete = undefined;
			yPos += menuItem._height * directionModifier;
		}
		
        m_ButtonsBackground._visible = true;
		m_ButtonsBackground._yscale = 0;
		m_ButtonsBackground.tweenTo(ANIMATION_DURATION, { _yscale: yPos + STARTING_Y_POSITION - m_BackgroundBar._height}, None.easeNone);
		m_ButtonsBackground.onTweenComplete = undefined;
    }
}

function SlotEscapePressed()
{
    if ( m_IsMenuOpen )
    {
        MainMenuReleaseEventHandler();
    }
}

//Character Sheet Handler
function CharacterSheetHandler():Void
{
	DistributedValue.SetDValue("character_sheet",!DistributedValue.GetDValue("character_sheet") );
	MainMenuReleaseEventHandler();
}

//Anima Wheel Handler
function AnimaWheelHandler():Void
{
	DistributedValue.SetDValue("skillhive_window", !DistributedValue.GetDValue("skillhive_window"));
	MainMenuReleaseEventHandler();
}

function OpenAnimaWheel():Void
{
	DistributedValue.SetDValue("skillhive_window", true);
}

//Journal Handler
function JournalHandler():Void
{
	DistributedValue.SetDValue("mission_journal_window", !DistributedValue.GetDValue("mission_journal_window"));
	MainMenuReleaseEventHandler();
}

//PvP Handler
function PvPHandler():Void
{
	DistributedValue.SetDValue("pvp_spoils_window", !DistributedValue.GetDValue("pvp_spoils_window"));
	MainMenuReleaseEventHandler();
}

//RegionTeleport Handler
function RegionTeleportHandler():Void
{
	DistributedValue.SetDValue("regionTeleport_window", !DistributedValue.GetDValue("regionTeleport_window"));
	MainMenuReleaseEventHandler();
}

//Achievements Handler
function AchievementHandler():Void
{
	DistributedValue.SetDValue("achievement_lore_window", !DistributedValue.GetDValue("achievement_lore_window"));
	MainMenuReleaseEventHandler();
}

//Help Handler
function HelpHandler():Void
{
	DistributedValue.SetDValue("tutorial_window", !DistributedValue.GetDValue("tutorial_window"));
	MainMenuReleaseEventHandler();
}

//Browser Handler
function BrowserHandler():Void
{
	DistributedValue.SetDValue("web_browser", !DistributedValue.GetDValue("web_browser"));
	MainMenuReleaseEventHandler();
}

//Petition Handler
function PetitionHandler():Void
{
	DistributedValue.SetDValue("petition_browser", !DistributedValue.GetDValue("petition_browser"));
	MainMenuReleaseEventHandler();
}

//Crafting Handler
function CraftingHandler():Void
{
	DistributedValue.SetDValue("ItemUpgradeWindow", !DistributedValue.GetDValue("ItemUpgradeWindow"));
	MainMenuReleaseEventHandler();
}

//Friends Handler
function FriendsHandler():Void
{
    DistributedValue.SetDValue("friends_window", !DistributedValue.GetDValue("friends_window"));
    MainMenuReleaseEventHandler();
}

function LFGHandler():Void
{
    DistributedValue.SetDValue("group_search_window", !DistributedValue.GetDValue("group_search_window"));
    MainMenuReleaseEventHandler();
}

function GroupFinderHandler():Void
{
	DistributedValue.SetDValue("groupFinder_window", !DistributedValue.GetDValue("groupFinder_window"));
    MainMenuReleaseEventHandler();
}

//Cabal Handler
function CabalHandler():Void
{
	DistributedValue.SetDValue("guild_window", !DistributedValue.GetDValue("guild_window"));
	MainMenuReleaseEventHandler();
}

//Claim Handler
function ClaimHandler():Void
{
    DistributedValue.SetDValue("claim_window", !DistributedValue.GetDValue("claim_window"));
	MainMenuReleaseEventHandler();
}

//Inventory Handler
function InventoryHandler():Void
{
	DistributedValue.SetDValue("inventory_visible", !DistributedValue.GetDValue("inventory_visible"));
	MainMenuReleaseEventHandler();
}

//Shop handler
function ShopHandler():Void
{
    ToggleShop();
	MainMenuReleaseEventHandler();
}

//Toggle the shop
function ToggleShop():Void
{
	if (m_Character.CanReceiveItems())
	{
		DistributedValue.SetDValue("itemshop_window", !DistributedValue.GetDValue("itemshop_window"));
	}
	else
	{
		com.GameInterface.Chat.SignalShowFIFOMessage.Emit(m_TDB_Shop_DisabledTooltip, 0);
	}
}

function ToggleShopMembership():Void
{
	DistributedValue.SetDValue("membershipPurchase_window", !DistributedValue.GetDValue("membershipPurchase_window"));
}

//Leaderboards Handler
function LeaderboardsHandler():Void
{
    DistributedValue.SetDValue("leaderboards_browser", !DistributedValue.GetDValue("leaderboards_browser"));
	MainMenuReleaseEventHandler();
}

/*
//Lockouts Handler
function LockoutHandler():Void
{
	DistributedValue.SetDValue("lockoutTimers_window", !DistributedValue.GetDValue("lockoutTimers_window"));
	MainMenuReleaseEventHandler();
}
*/

function PetHandler():Void
{
	DistributedValue.SetDValue("petInventory_window",!DistributedValue.GetDValue("petInventory_window") );
	MainMenuReleaseEventHandler();
}

//Journal Handler
function ChallengeJournalHandler():Void
{
	DistributedValue.SetDValue("challengeJournal_window", !DistributedValue.GetDValue("challengeJournal_window"));
	MainMenuReleaseEventHandler();
}

function TradepostHandler():Void
{
	if (!DistributedValue.GetDValue("tradepost_window"))
	{
		Tradepost.RequestOpenTradepost();
	}
	else
	{
		DistributedValue.SetDValue("tradepost_window", false);
	}
	MainMenuReleaseEventHandler();
}

function OpenTradepost():Void
{
	if (m_Character.CanReceiveItems())
	{
		Tradepost.RequestOpenTradepost();
	}
}

/*
function BankHandler():Void
{
	if (!DistributedValue.GetDValue("bank_window"))
	{
		Tradepost.RequestOpenBank();
	}
	else
	{
		DistributedValue.SetDValue("bank_window", false);
	}
	MainMenuReleaseEventHandler();
}
*/

//Settings Handler
function SettingsHandler():Void
{
    DistributedValue.SetDValue("mainmenu_window", true);
    MainMenuReleaseEventHandler();
}

//Exit Handler
function ExitHandler():Void
{
    com.GameInterface.ProjectUtils.StartQuitGame();
}

//Slot Character Sheet State
function SlotCharacterSheetState():Void
{
	var isOpen = DistributedValue.GetDValue("character_sheet")
	SetDotState(m_CharacterSheetButton, isOpen);
}

//Slot Anima Wheel State
function SlotAnimaWheelState():Void
{
	var isOpen = DistributedValue.GetDValue("skillhive_window")
 	SetDotState(m_AnimaWheelButton, isOpen);
}

//Slot Inventory State
function SlotInventoryState():Void
{
	var isOpen = DistributedValue.GetDValue("inventory_visible")
	SetDotState(m_InventoryButton, isOpen);
}

//Slot Journal State
function SlotJournalState():Void
{
	var isOpen = DistributedValue.GetDValue("mission_journal_window")
    SetDotState(m_JournalButton, isOpen);
}

//Slot PvP State
function SlotPvPState():Void
{
	var isOpen = DistributedValue.GetDValue("pvp_spoils_window");
	SetDotState(m_PvPButton, isOpen);	
}

//Slot Region Teleport State
function SlotRegionTeleportState():Void
{
	var isOpen = DistributedValue.GetDValue("regionTeleport_window");
	SetDotState(m_RegionTeleportButton, isOpen);	
}

//Slot Achievement State
function SlotHelpState():Void
{
	var isOpen = DistributedValue.GetDValue("tutorial_window");
	SetDotState(m_HelpButton, isOpen);	
}

//Slot Crafting State
function SlotCraftingState():Void
{
	var isOpen = DistributedValue.GetDValue("ItemUpgradeWindow");
	SetDotState(m_CraftingButton, isOpen);	
}

//Slot Friends State
function SlotFriendsState():Void
{
    var isOpen = DistributedValue.GetDValue("friends_window");
    SetDotState(m_FriendsButton, isOpen);
}

//Slot LFG State
function SlotLookingForGroupState():Void
{
    var isOpen = DistributedValue.GetDValue("group_search_window");
    SetDotState(m_LFGButton, isOpen);
}

function SlotGroupFinderState():Void
{
    var isOpen = DistributedValue.GetDValue("groupFinder_window");
    SetDotState(m_GroupFinderButton, isOpen);
}

//Slot Item Shop State
function SlotItemShopState():Void
{
    var isOpen = DistributedValue.GetDValue("itemshop_window");
    SetDotState(m_ShopButton, isOpen);   
}

//Slot Cabal State
function SlotCabalState():Void
{
	var isOpen = DistributedValue.GetDValue("guild_window");
	SetDotState(m_CabalButton, isOpen);	
}

//Slot Help State
function SlotAchievementState():Void
{
	var isOpen = DistributedValue.GetDValue("achievement_lore_window");
	SetDotState(m_AchievementButton, isOpen);	
}

//Slot Claim State
function SlotClaimState():Void
{
	var isOpen = DistributedValue.GetDValue("claim_window");
	SetDotState(m_ClaimButton, isOpen);
}

//Slot Browser State
function SlotBrowserState():Void
{
	var isOpen = DistributedValue.GetDValue("web_browser");
	SetDotState(m_BrowserButton, isOpen);	
}

//Slot Leaderboards State
function SlotLeaderboardsState():Void
{
	var isOpen = DistributedValue.GetDValue("leaderboards_browser");
	SetDotState(m_LeaderboardsButton, isOpen);	
}

/*
//Slot Lockouts State
function SlotLockoutsState():Void
{
	var isOpen = DistributedValue.GetDValue("lockoutTimers_window");
	SetDotState(m_LockoutButton, isOpen);	
}
*/

function SlotPetsState():Void
{
	var isOpen = DistributedValue.GetDValue("petIvnentory_window")
	SetDotState(m_PetButton, isOpen);
}

//Slot Challenge Journal State
function SlotChallengeJournalState():Void
{
	var isOpen = DistributedValue.GetDValue("challengeJournal_window")
    SetDotState(m_ChallengeJournalButton, isOpen);
}

function SlotTradepostState():Void
{
	var isOpen = DistributedValue.GetDValue("tradepost_window")
    SetDotState(m_ChallengeJournalButton, isOpen);
}

/*
function SlotBankState():Void
{
	var isOpen = DistributedValue.GetDValue("bank_window")
    SetDotState(m_ChallengeJournalButton, isOpen);
}
*/

function ToggleSprint() : Void
{
	SpellBase.SummonMountFromTag();
}

function BuyAurum() : Void
{
	ShopInterface.RequestAurumPurchase();
}

function ToggleGUILock() : Void
{
	if (m_LockIcon.m_Locked._visible)
	{
		m_LockIcon.m_Locked._visible = false;
		m_LockIcon.m_Unlocked._visible = true;
		if (!m_ScryCounterActive)
		{ 
			m_FakeScryCounter = true;
			_root.LoadFlash("ScryCounter.swf", "ScryCounter" , false, _root.getNextHighestDepth(), 0 ); 
		}
		if (!m_ScryTimerActive)
		{ 
			m_FakeScryTimer = true;
			_root.LoadFlash("ScryTimer.swf", "ScryTimer" , false, _root.getNextHighestDepth(), 0 ); 
		}
		if (!m_ScryTimerCounterComboActive)
		{ 
			m_FakeScryTimerCounterCombo = true;
			_root.LoadFlash("ScryTimerCounterCombo.swf", "ScryTimerCounterCombo" , false, _root.getNextHighestDepth(), 0 ); 
		}
		GlobalSignal.SignalSetGUIEditMode.Emit(true);
	}
	else
	{
		m_LockIcon.m_Locked._visible = true;
		m_LockIcon.m_Unlocked._visible = false;
		if (m_FakeScryCounter)
		{
			m_FakeScryCounter = false;
			_root.UnloadFlash("ScryCounter");
		}
		if (m_FakeScryTimer)
		{
			m_FakeScryTimer = false;
			_root.UnloadFlash("ScryTimer");
		}
		if (m_FakeScryTimerCounterCombo)
		{
			m_FakeScryTimerCounterCombo = false;
			_root.UnloadFlash("ScryTimerCounterCombo");
		}
		GlobalSignal.SignalSetGUIEditMode.Emit(false);
	}
}

function SlotToggleClockType() : Void
{
	m_ClockShowRealTimeMonitor.SetValue(!m_ClockShowRealTime);
}

function SlotClockTypeChanged()
{
	m_ClockShowRealTime = m_ClockShowRealTimeMonitor.GetValue();
    
	m_ClockIconContainer.m_Label.textColor = (m_ClockShowRealTime) ? 0xAAFFAA : 0xFFFFFF;
    
	SlotUpdateInterval();
}

function SlotTokenAmountChanged(tokenId:Number, newAmount:Number, oldAmount:Number)
{
    if (tokenId == _global.Enums.Token.e_Gold_Bullion_Token || 
		tokenId == _global.Enums.Token.e_Premium_Token || 
		tokenId == _global.Enums.Token.e_Cash ||
		tokenId == _global.Enums.Token.e_Anima_Point ||
		tokenId == _global.Enums.Token.e_Skill_Point)
	{
    	this["m_TokenIconContainer_" + tokenId].m_Label.text = Text.AddThousandsSeparator(newAmount);
    	Layout();
		
		//Do some extra stuff for cash gain
		if (tokenId == _global.Enums.Token.e_Cash && newAmount > oldAmount)
		{
			var diff:Number = newAmount - oldAmount;
			if (m_ShardGainContainer._alpha == 0)
			{
				m_ShardGainContainer.m_Label.text = "+" + Text.AddThousandsSeparator(diff);
				m_LastShardGain = diff;
				m_ShardGainContainer._alpha = 100;
			}
			else
			{
				m_ShardGainContainer.m_Label.text = "+" + Text.AddThousandsSeparator(m_LastShardGain + diff);
				m_LastShardGain += diff;
			}
			m_ShardGainContainer.tweenEnd();
			m_ShardGainContainer._y = (DistributedValue.GetDValue( "TopMenuAlignment", 0 ) == 0) ? 1 : 1 - m_ShardGainContainer._height;
			m_ShardGainContainer._xscale = m_ShardGainContainer._yscale = 200;
			m_ShardGainContainer.tweenTo(0.5, { _xscale: 100, _yscale: 100, _y: 1 }, None.easeNone);
			m_ShardGainContainer.onTweenComplete = function ()
			{
				this.tweenTo(3, { _alpha: 0, _xscale: 100, _yscale: 100 }, None.easeNone);
				this.onTweenComplete = undefined;
			}
		}
	}
}

function SlotScryTimerLoaded(loaded:Boolean)
{
	m_ScryTimerActive = loaded;
	GlobalSignal.SignalSetGUIEditMode.Emit(m_LockIcon.m_Unlocked._visible);
}

function SlotScryCounterLoaded(loaded:Boolean)
{
	m_ScryCounterActive = loaded;
	GlobalSignal.SignalSetGUIEditMode.Emit(m_LockIcon.m_Unlocked._visible);
}

function SlotScryTimerCounterComboLoaded(loaded:Boolean)
{
	m_ScryTimerCounterComboActive = loaded;
	GlobalSignal.SignalSetGUIEditMode.Emit(m_LockIcon.m_Unlocked._visible);
}

function SlotEnteredReticuleMode()
{
	if (m_IsMenuOpen)
    {
		MainMenuReleaseEventHandler();
	}
	if (m_Tooltip != undefined)
	{
		m_Tooltip.Close();
	}
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_MinimapEditModeMask._visible = edit;
	if(edit)
	{
		LayoutEditModeMask();
		WaypointInterface.ForceShowMinimap(true);
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("MinimapScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		WaypointInterface.ForceShowMinimap(false);
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("MinimapScale", 100) / 100;
	m_MinimapEditModeMask.startDrag(false, 0 - this._x, 0 - this._y, Stage.width - m_MinimapEditModeMask._width + 2 - this._x, Stage.height - m_MinimapEditModeMask._height - this._y);
	this.onMouseMove = function()
	{
		var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
		WaypointInterface.MoveMinimap(m_MinimapEditModeMask._y + this._y, visibleRect.right - (m_MinimapEditModeMask._x + m_MinimapEditModeMask._width) + this._x);
	}
}

function SlotEditMaskReleased()
{
	m_MinimapEditModeMask.stopDrag();
	this.onMouseMove = function(){}
	
	var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
	var newTopOffset:DistributedValue = DistributedValue.Create( "MinimapTopOffset" );
	var newRightOffset:DistributedValue = DistributedValue.Create( "MinimapRightOffset" );	
	newTopOffset.SetValue(m_MinimapEditModeMask._y + this._y);
	newRightOffset.SetValue(visibleRect.right - (m_MinimapEditModeMask._x + m_MinimapEditModeMask._width) + this._x);
}

function LayoutEditModeMask()
{
	//This is weird. Because this is going to go off to the old gui system, and the minimap is aligned
	//with the top right of the screen. We store coordinates as an offset from the top right
	//Coordinates are stored as a frame, not an origin, so offsetTop is the gap between the top 
	//of the screen and the top of the minimap, and offsetRight is the gap between the right of the screen
	//and the right of the minimap
	var minimapTopOffset:DistributedValue = DistributedValue.Create( "MinimapTopOffset" );
	var minimapRightOffset:DistributedValue = DistributedValue.Create( "MinimapRightOffset" );
	if (minimapTopOffset.GetValue() == "undefined") { minimapTopOffset.SetValue(20); }
	if (minimapRightOffset.GetValue() == "undefined") { minimapRightOffset.SetValue(0); }
	
	var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
	
	var scale:Number = DistributedValue.GetDValue("MinimapScale", 100) / 100;
	
	m_MinimapEditModeMask._x = visibleRect.right - minimapRightOffset.GetValue() - this._x - (209 - 2) * scale; //209 is the width of the minimap
	m_MinimapEditModeMask._width = (209 + 2) * scale;
	m_MinimapEditModeMask._y = visibleRect.top + minimapTopOffset.GetValue() - this._y;
	m_MinimapEditModeMask._height = (209 + 2) * scale;
}