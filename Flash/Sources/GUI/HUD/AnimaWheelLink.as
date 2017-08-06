//Imports
import com.Components.Numbers;
import com.GameInterface.Claim;
import com.GameInterface.PendingReward;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Inventory;
import com.GameInterface.Lore;
import com.GameInterface.Tooltip.*
import com.GameInterface.DistributedValue;
import com.GameInterface.SpellBase;
import com.Utils.LDBFormat;
import com.Utils.ID32;
import flash.filters.ColorMatrixFilter;
import flash.filters.DisplacementMapFilter;
import mx.transitions.easing.*;
import GUIFramework.SFClipLoader;
import mx.utils.Delegate;
import gfx.controls.ScrollingList;

//Constants
var ICON_GLOW_BLEED:Number = 2;
var ICON_DISPLACEMENT:Number = 45;
var AUXILIARY_VALUE:Number = 5437;

var ANIMA_POINTS:String = "animapoints";
var SKILL_POINTS:String = "skillpoints";
var LORE:String = "lore";
var ACHIEVEMENT:String = "achievement"
var BREAKING_ITEMS:String = "breakingitems"
var BROKEN_ITEMS:String = "brokenitems"
var TUTORIAL:String = "tutorial";
var PETITION:String = "petition";
var CLAIM:String = "claim";
var AUXILIARY:String = "auxiliary";

//Variables
var m_LoreIcon:MovieClip;
var m_LoreFilthIcon:MovieClip;
var m_AchievementIcon:MovieClip;
var m_BreakingItemsIcon:MovieClip;
var m_BrokenItemsIcon:MovieClip;
var m_TutorialIcon:MovieClip;
var m_PetitionIcon:MovieClip;
var m_ClaimIcon:MovieClip;
var m_PvPSpoilsIcon:MovieClip;
var m_AuxiliaryIcon:MovieClip;
var m_PetIcon:MovieClip;
var m_SMSIcon:MovieClip;
var m_MountIcon:MovieClip;
var m_TeleportIcon:MovieClip;
var m_ChallengeIcon:MovieClip;

var m_SMSList:MovieClip;
var m_EditModeMask:MovieClip;

var m_Character:Character;
var m_EquipInventory:Inventory;

var m_NumBrokenItems:Number;
var m_NumBreakingItems:Number;

var m_NotificationThrottleIntervalId:Number;
var m_NotificationThrottleInterval:Number// ms between the throttleeffect

var m_AnimaWheelMonitor:DistributedValue;
var m_AchievementWindowMonitor:DistributedValue;
var m_PetitionWindowMonitor:DistributedValue;
var m_PetitionUpdatedMonitor:DistributedValue;
var m_ClaimWindowMonitor:DistributedValue;
var m_PvPSpoilsMonitor:DistributedValue;
var m_PetInventoryMonitor:DistributedValue;
var m_RegionTeleportMonitor:DistributedValue;
var m_CharacterSheetMonitor:DistributedValue;
var m_ChallengeJournalMonitor:DistributedValue;

var m_IconHeight:Number;
var m_IconWidth:Number;
var m_VisibleNotificationsArray:Array;

var m_LastTag:Number;
var m_SMSQueue:Array;

var m_MadeFakeIcon:Boolean;

//On Load
function onLoad():Void
{         
    m_AchievementWindowMonitor = DistributedValue.Create("achievement_lore_window");
    m_AchievementWindowMonitor.SignalChanged.Connect(SlotAchievementWindowOpen, this);

    m_PetitionWindowMonitor = DistributedValue.Create("petition_browser");
    m_PetitionWindowMonitor.SignalChanged.Connect(SlotPetitionWindowOpen, this);
    
    m_PetitionUpdatedMonitor = DistributedValue.Create("HasUpdatedPetition");
    m_PetitionUpdatedMonitor.SignalChanged.Connect(SlotPetitionUpdated, this);
    
    m_ClaimWindowMonitor = DistributedValue.Create("claim_window");
    m_ClaimWindowMonitor.SignalChanged.Connect(SlotClaimWindowOpen, this);
	
	m_PvPSpoilsMonitor = DistributedValue.Create("pvp_spoils_window");
    m_PvPSpoilsMonitor.SignalChanged.Connect(SlotPvPSpoilsOpen, this);
	
	m_PetInventoryMonitor = DistributedValue.Create("petInventory_window");
	m_PetInventoryMonitor.SignalChanged.Connect(SlotPetInventoryOpen, this);
	
	m_RegionTeleportMonitor = DistributedValue.Create("regionTeleport_window");
	m_RegionTeleportMonitor.SignalChanged.Connect(SlotRegionTeleportOpen, this);
	
	m_CharacterSheetMonitor = DistributedValue.Create("character_sheet");
	m_CharacterSheetMonitor.SignalChanged.Connect(SlotCharacterSheetOpen, this);
	
	m_ChallengeJournalMonitor = DistributedValue.Create("challengeJournal_window");
    m_ChallengeJournalMonitor.SignalChanged.Connect(SlotChallengeJournalOpen, this);

    Claim.SignalClaimsUpdated.Connect(SlotClaimUpdated, this);
	PendingReward.SignalClaimsUpdated.Connect(SlotPendingRewardsUpdated, this);
	GUI.Mission.MissionSignals.SignalSMSAnimationDone.Connect( SlotSMSAnimationDone, this );
	GUI.Mission.MissionSignals.SignalChallengeRewardsAnimationDone.Connect( SlotChallengeRewardsAnimationDone, this );
	com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect(SlotSetGUIEditMode, this);

    m_VisibleNotificationsArray = new Array();
    
    //LoadDurabilityIcons();
	
	//Setup editing controls
	m_EditModeMask.onPress = Delegate.create(this, SlotEditMaskPressed);
	m_EditModeMask.onRelease = m_EditModeMask.onReleaseOutside = Delegate.create(this, SlotEditMaskReleased);
	m_EditModeMask._visible = false;
    
    SetVisible(m_LoreIcon, false);
	SetVisible(m_LoreFilthIcon, false);
    SetVisible(m_AchievementIcon, false);
    SetVisible(m_BrokenItemsIcon, false);
    SetVisible(m_BreakingItemsIcon, false);
    SetVisible(m_TutorialIcon, false);
    SetVisible(m_PetitionIcon, false);
    SetVisible(m_ClaimIcon, false);
	SetVisible(m_PvPSpoilsIcon, false);
    SetVisible(m_AuxiliaryIcon, false);
	SetVisible(m_PetIcon, false);
	SetVisible(m_SMSIcon, false);
	SetVisible(m_MountIcon, false);
	SetVisible(m_TeleportIcon, false);
	SetVisible(m_ChallengeIcon, false);
	
	m_SMSList._visible = false;
	m_SMSList.m_MessageList.addEventListener("focusIn", this, "RemoveFocus");
	m_SMSList.m_MessageList.addEventListener("itemClick", this, "SMSItemClickHandler");
        
    m_IconHeight = m_LoreIcon._height - ICON_GLOW_BLEED;
    m_IconWidth = m_LoreIcon._width;
    
    AttatchBadge(m_BrokenItemsIcon);
    AttatchBadge(m_BreakingItemsIcon);
    AttatchBadge(m_ClaimIcon);
	AttatchBadge(m_PvPSpoilsIcon);
	AttatchBadge(m_SMSIcon);

    Character.SignalClientCharacterAlive.Connect(SlotCharacterAlive, this);
    
    SlotCharacterAlive();
    SlotClaimUpdated();
	SlotPendingRewardsUpdated();
    SlotPetitionUpdated();
    
    m_NotificationThrottleIntervalId = -1;
    m_NotificationThrottleInterval = 2000; 
    
    if (m_NotificationThrottleIntervalId > -1)
    {
        clearInterval( m_NotificationThrottleIntervalId );
    }
    
    m_NotificationThrottleIntervalId = setInterval(Delegate.create(this, AnimateUnclickedNotifications), m_NotificationThrottleInterval );
}

function onUnload()
{
    if (m_NotificationThrottleIntervalId > -1)
    {
        clearInterval( m_NotificationThrottleIntervalId );
    }
}

function BuildSMSQueue()
{
	m_SMSQueue = new Array();
	for(buff in m_Character.m_InvisibleBuffList)
	{
		if(SpellBase.GetStat(m_Character.m_InvisibleBuffList[buff].m_BuffId, _global.Enums.Stat.e_NotificationBuff) != 0)
		{
			SlotSMSAnimationDone(m_Character.m_InvisibleBuffList[buff].m_BuffId);
		}
	}
}

//Load Durability Icons
/*
function LoadDurabilityIcons()
{
    var brokenContainer:MovieClip = m_BrokenItemsIcon.createEmptyMovieClip("container", m_BrokenItemsIcon.getNextHighestDepth());
    var breakingContainer:MovieClip = m_BreakingItemsIcon.createEmptyMovieClip("container", m_BreakingItemsIcon.getNextHighestDepth());
    
    var imageLoader:MovieClipLoader = new MovieClipLoader();
    var imageLoaderListener:Object = new Object;
    
    imageLoaderListener.onLoadInit = function(target:MovieClip)
    {
        target._x = 1;
        target._y = 1;
        target._xscale = 33;
        target._yscale = 33;
    }
    
    imageLoader.addListener(imageLoaderListener);
    
    imageLoader.loadClip("rdb:1000624:7363471", brokenContainer);   
    imageLoader.loadClip("rdb:1000624:7363472", breakingContainer);     
}
*/

//Slot Character Alive
function SlotCharacterAlive():Void
{
    m_Character = Character.GetClientCharacter();
    
    if (m_Character != undefined)
    {
		m_Character.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
        
        Lore.SignalGetAnimationComplete.Connect(SlotGetAnimationComplete, this);
    
		BuildSMSQueue();
    }
}

//Slot Item Added
/*
function SlotItemAdded(inventoryID:ID32, itemPos:Number):Void
{
    UpdateDurabilityItems();
}

//Slot Item Removed
function SlotItemRemoved(inventoryID:ID32, itemPos:Number, moved:Boolean):Void
{
    UpdateDurabilityItems();
}

//Slot Item Stat Changed
function SlotItemStatChanged(inventoryID:ID32, itemPos:Number, stat:Number, newValue:Number):Void
{
    if (stat == _global.Enums.Stat.e_Durability || stat == _global.Enums.Stat.e_MaxDurability)
    {
        UpdateDurabilityItems();
    }
}
*/


/// calls a throttle effect on missions you have not yet had
function AnimateUnclickedNotifications()
{
    for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++ )
    {
        if (!m_VisibleNotificationsArray[i].m_IsClicked)
        {
            m_VisibleNotificationsArray[i].m_AnimatingIcon.gotoAndPlay("throttle");
        }
    }
}

//Update Durability Items
/*
function UpdateDurabilityItems():Void
{
    m_NumBrokenItems = 0;
    m_NumBreakingItems = 0;
    
    for (var i:Number = 0; i < m_EquipInventory.GetMaxItems(); i++)
    {
        if (m_EquipInventory.GetItemAt(i) != undefined)
        {
            if (m_EquipInventory.GetItemAt(i).IsBroken())
            {
                m_NumBrokenItems++;
            }
            else if (m_EquipInventory.GetItemAt(i).IsBreaking())
            {
                m_NumBreakingItems++;
            }
        }
    }
    
    UpdateDurabilityNotifications();
}
*/

//Update Durability Notifications
/*
function UpdateDurabilityNotifications():Void
{
	if (!DistributedValue.GetDValue("repair_notifications", true))
	{
		return;
	}
    var headline:String = "";
    var bodyText:String = "";
    
    if (m_NumBreakingItems > 0 && m_NumBreakingItems != m_BreakingItemsIcon.m_Badge.m_Charge)
    {
        m_BreakingItemsIcon.m_Badge.SetCharge(m_NumBreakingItems);
        SetVisible(m_BreakingItemsIcon, true);
        
        headline = LDBFormat.LDBGetText("GenericGUI", "Notifications_BreakingItemsHeader");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "Notifications_BreakingItemsBody"), m_NumBreakingItems);

        CreateRealTooltip(m_BreakingItemsIcon, headline, bodyText);
        m_BreakingItemsIcon.onPress = RealPresshandler;
        m_BreakingItemsIcon.m_IsClicked = false;
    }
    else if (m_NumBreakingItems == 0)
    {
        m_BreakingItemsIcon.m_Badge.SetCharge(-1);
        SetVisible(m_BreakingItemsIcon, false);
    }
    
    if (m_NumBrokenItems > 0 && m_NumBrokenItems != m_BrokenItemsIcon.m_Badge.m_Charge)
    {
        m_BrokenItemsIcon.m_Badge.SetCharge(m_NumBrokenItems);
        SetVisible(m_BrokenItemsIcon, true);
        
        headline = LDBFormat.LDBGetText("GenericGUI", "Notifications_BrokenItemsHeader");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "Notifications_BrokenItemsBody"), m_NumBrokenItems);
        
        CreateRealTooltip(m_BrokenItemsIcon, headline, bodyText);
        m_BrokenItemsIcon.onPress = RealPresshandler;
        m_BrokenItemsIcon.m_IsClicked = false;
        
    }
    else if (m_NumBrokenItems == 0)
    {
        m_BrokenItemsIcon.m_Badge.SetCharge(-1);
        SetVisible(m_BrokenItemsIcon, false);
    }
}
*/

//Attach Badge
function AttatchBadge(target:MovieClip):Void
{
    var badge:MovieClip = target.attachMovie("_Numbers", "m_Badge", target.getNextHighestDepth());
    badge.UseSingleDigits = true;
    badge.SetColor(0xFF0000);
    
    badge._x = target._x + m_IconWidth;
    badge._y = target._y + m_IconHeight + 2;
    badge._xscale = badge._yscale = 110;
}

// lore and achievements updated
function SlotGetAnimationComplete(tagId:Number):Void
{
	//We don't want to show these anymore.
	/*
	if (tagId == undefined)
	{
		return; // this happens for ap, sp and mission reports - no tagId
	}
	
    var dataType:Number = Lore.GetTagCategory(tagId);
    
    // tutorial nodes (TYPE tutorial, not category) pop up in your face and therefore need no button
    if (Lore.GetTagType(tagId) == _global.Enums.LoreNodeType.e_Tutorial)
    {
        return;
    }
	
    var targetIcon:MovieClip;
    var headline:String = "";
    var bodyText:String = "";
    
    var loreName:String = Lore.GetTagName(tagId);
    
    if (loreName == "") // lots of lore and acievement items has no name
    {
        loreName = Lore.GetTagName(Lore.GetTagParent(tagId));
    }

    if (dataType == _global.Enums.LoreNodeType.e_Achievement || dataType == _global.Enums.LoreNodeType.e_SeasonalAchievement)
    {
        if (!Lore.ShouldShowGetAnimation(tagId) || !DistributedValue.GetDValue("achievement_notifications", true))
        {
            return; // invisible node - don't update the icon
        }
        
        headline = LDBFormat.LDBGetText("GenericGUI", "Achievements_AllCaps");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "Achievements_Tooltip"), loreName);
        targetIcon = m_AchievementIcon;
    }
    else if (dataType == _global.Enums.LoreNodeType.e_Lore)
    {
        if (!Lore.ShouldShowGetAnimation(tagId) || !DistributedValue.GetDValue("lore_notifications", true))
        {
            return; // invisible node - don't update the icon
        }

        headline = LDBFormat.LDBGetText("GenericGUI", "Lore_AllCaps");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "LoreTooltip"), loreName);
		if (Lore.GetTagViewpoint(tagId) == 1)
		{
			targetIcon = m_LoreFilthIcon;
		}
		else
		{
        	targetIcon = m_LoreIcon;
		}
    }
	else if (dataType == _global.Enums.LoreNodeType.e_Tutorial)
    {
		//We don't want to show tutorial notifications anymore.
		if (!Lore.ShouldShowGetAnimation(tagId) || !Lore.IsVisible(tagId) || !DistributedValue.GetDValue("tutorial_notifications", true))
        {
            // tutorial nodes hide the (possibly) existing icon if an invisible one is added
            SetVisible(targetIcon, false);
            return;
        }
        else
        {
            headline = LDBFormat.LDBGetText("GenericGUI", "Notifications_TutorialHeader");
            bodyText = LDBFormat.LDBGetText("GenericGUI", "Notifications_TutorialBody");
            targetIcon = m_TutorialIcon;
        }
	}
	else if (dataType == _global.Enums.LoreNodeType.e_Pets)
	{
		if (!Lore.ShouldShowGetAnimation(tagId) || !DistributedValue.GetDValue("pet_notifications", true))
        {
            return; // invisible node - don't update the icon
        }
		headline = Lore.GetTagName(tagId);
        targetIcon = m_PetIcon;
	}
	
	else if (dataType == _global.Enums.LoreNodeType.e_Mounts)
	{
		if (!Lore.ShouldShowGetAnimation(tagId) || !DistributedValue.GetDValue("mount_notifications", true))
        {
            return; // invisible node - don't update the icon
        }
		headline = Lore.GetTagName(tagId);
        targetIcon = m_MountIcon;
	}
	
	else if (dataType == _global.Enums.LoreNodeType.e_Teleports)
	{
		if (!Lore.ShouldShowGetAnimation(tagId) || !DistributedValue.GetDValue("teleport_notifications", true))
        {
            return; // invisible node - don't update the icon
        }
		headline = Lore.GetTagName(tagId);
        targetIcon = m_TeleportIcon;
	}
    
    if (targetIcon != undefined)
    {
        CreateRealTooltip(targetIcon, headline, bodyText);
        targetIcon.m_Id = tagId;
        targetIcon.m_IsClicked = false;
        SetVisible(targetIcon, true);
        targetIcon.onPress = RealPresshandler;
    }
	*/
}

function RealPresshandler()
{
    this.m_IsClicked = true;
    
    var character:Character = Character.GetClientCharacter();
    var allowedToReceiveItems:Boolean = character.CanReceiveItems();
    
    switch (this)
    {        
        case m_LoreIcon:
		case m_LoreFilthIcon:
        //case m_TutorialIcon:
        case m_AchievementIcon:     Lore.OpenTag(this.m_Id);
                                    SetVisible(this, false);
                                    break;
                                    
        case m_BrokenItemsIcon:     DistributedValue.SetDValue("character_sheet", true);
                                    SetVisible(this, false);
                                    break;
                                    
        case m_BreakingItemsIcon:   DistributedValue.SetDValue("character_sheet", true);
                                    SetVisible(this, false);
                                    break;
                                    
        case m_PetitionIcon:        DistributedValue.SetDValue("petition_browser", true);
                                    DistributedValue.SetDValue("HasUpdatedPetition", false);
                                    SetVisible(this, false);
                                    break;
                                    
        case m_ClaimIcon:           if (allowedToReceiveItems)
                                    {
                                        DistributedValue.SetDValue("claim_window", true);
                                    }
                                    SetVisible(this, false);
                                    break;
									
		case m_PvPSpoilsIcon:        if (allowedToReceiveItems)
                                    {
                                        DistributedValue.SetDValue("pvp_spoils_window", true);
                                    }
                                    SetVisible(this, false);
                                    break;
                                    
        case m_AuxiliaryIcon:       DistributedValue.SetDValue("skillhive_window", true);
                                    SetVisible(this, false);
                                    break;
		case m_PetIcon: 
		case m_MountIcon:	DistributedValue.SetDValue("petInventory_window", true);
							SetVisible(this, false);
							break;
							
		case m_TeleportIcon: DistributedValue.SetDValue("regionTeleport_window", true);
							 SetVisible(this, false);
							 break;
						
		case m_SMSIcon: if (m_SMSQueue.length > 1)
						{
							ToggleSMSList();
						}
						else
						{
							var notificationID:Number = SpellBase.GetStat(m_SMSQueue[0], _global.Enums.Stat.e_NotificationBuff);
							SpellBase.ActivateNotification(notificationID);
						}
						break;
						
		case m_ChallengeIcon:	DistributedValue.SetDValue("challengeJournal_window", true);
								SetVisible(this, false);
								break;
    }
}

function ToggleSMSList()
{
	if (!m_SMSList._visible)
	{
		m_SMSList._visible = true;
		if (this._x >= Stage.width / 2){ m_SMSList._x = m_SMSIcon._x - m_SMSList._width - 10; }
		else { m_SMSList._x = m_SMSIcon._x + m_SMSIcon._width + 10; }
		m_SMSList._y = Math.min(m_SMSIcon._y, m_SMSIcon._height + m_SMSList._height * -1);
		var SMSArray = new Array();
		for (var i=0; i<m_SMSQueue.length; i++)
		{
			var tooltipData:TooltipData = TooltipDataProvider.GetBuffTooltip(m_SMSQueue[i], Character.GetClientCharID());
			SMSArray.push({from:tooltipData.m_Title, desc:tooltipData.m_Descriptions[0]});
		}
		m_SMSList.m_MessageList.dataProvider = SMSArray;
		m_SMSList.m_MessageList.invalidateData();
		m_SMSList.m_MessageList.selectedIndex = -1;
		if (SMSArray.length < 4)
		{
			m_SMSList.m_MessageList.scrollBar._visible = false;
		}
		else
		{
			m_SMSList.m_MessageList.scrollBar._visible = true;
		}
	}
	else
	{
		m_SMSList._visible = false;
	}
}

function SMSItemClickHandler(event:Object)
{
	var notificationID:Number = SpellBase.GetStat(m_SMSQueue[event.index], _global.Enums.Stat.e_NotificationBuff);
	SpellBase.ActivateNotification(notificationID);
	ToggleSMSList();
}

function CreateRealTooltip(target:MovieClip, headline:String, bodyText:String)
{
    var htmlText:String = "<b>" + com.GameInterface.Utils.CreateHTMLString( headline, { face:"_StandardFont", color: "#FFFFFF", size: 14 } )+"</b>";
    htmlText += "<br/>" + com.GameInterface.Utils.CreateHTMLString( bodyText,{ face:"_StandardFont", color: "#FFFFFF", size: 12 }  );

    com.GameInterface.Tooltip.TooltipUtils.AddTextTooltip( target, htmlText, 210, TooltipInterface.e_OrientationHorizontal, false );
}

//Slot Petition Updated
function SlotPetitionUpdated():Void
{
    var visible:Boolean = DistributedValue.GetDValue("HasUpdatedPetition") && DistributedValue.GetDValue("petition_notifications", true);
    SetVisible(m_PetitionIcon, visible );
    
    if (visible)
    {
        CreateRealTooltip(m_PetitionIcon, LDBFormat.LDBGetText("GenericGUI", "Notifications_PetitionHeader"), LDBFormat.LDBGetText("GenericGUI", "Notifications_PetitionBody"));
        m_PetitionIcon.onPress = RealPresshandler;
        m_PetitionIcon.m_IsClicked = false;
    }
}

//Slot Claim Window Open
function SlotClaimWindowOpen():Void
{
    SetVisible(m_ClaimIcon, false);
}

//Slot Claim Window Open
function SlotPvPSpoilsOpen():Void
{
    SetVisible(m_PvPSpoilsIcon, false);
}

//Slot Claim Updated
function SlotClaimUpdated():Void
{
	if (DistributedValue.GetDValue("claim_notifications", true))
	{
		var showIcon:Boolean = false;
		for (var i:Number = 0; i < Claim.m_Claims.length; i++)
		{
			if (Claim.m_Claims[i].m_IsNew)
			{
				showIcon = true;
				break;
			}
		}
		if (showIcon)
		{
			var claimsCount:Number = GetClaims();
			
			var character:Character = Character.GetClientCharacter();
			var allowedToReceiveItems:Boolean = character.CanReceiveItems();
			
			SetVisible(m_ClaimIcon, (claimsCount > 0 && allowedToReceiveItems));
			m_ClaimIcon.m_Badge.SetCharge(claimsCount);
		
			var claimBody:String = LDBFormat.Printf( LDBFormat.LDBGetText("GenericGUI", "Notifications_ClaimBody"), GetClaims());
			CreateRealTooltip(m_ClaimIcon, LDBFormat.LDBGetText("GenericGUI", "Notifications_ClaimHeader"), claimBody );
			m_ClaimIcon.onPress = RealPresshandler;
			m_ClaimIcon.m_IsClicked = false;
		}
	}
}

//Slot Pending Rewards Updated
function SlotPendingRewardsUpdated():Void
{
	if (DistributedValue.GetDValue("pvp_spoils_notifications", true))
	{
		var showIcon:Boolean = false;
		for (var i:Number = 0; i < PendingReward.m_Claims.length; i++)
		{
			if (PendingReward.m_Claims[i].m_IsNew)
			{
				showIcon = true;
				break;
			}
		}
		if (showIcon)
		{
			var claimsCount:Number = GetPendingRewards();
			
			var character:Character = Character.GetClientCharacter();
			var allowedToReceiveItems:Boolean = character.CanReceiveItems();
			
			SetVisible(m_PvPSpoilsIcon, (claimsCount > 0 && allowedToReceiveItems));
			m_PvPSpoilsIcon.m_Badge.SetCharge(claimsCount);
		
			var claimBody:String = LDBFormat.Printf( LDBFormat.LDBGetText("GenericGUI", "Notifications_PvPSpoilsBody"), GetPendingRewards());
			CreateRealTooltip(m_PvPSpoilsIcon, LDBFormat.LDBGetText("GenericGUI", "Notifications_PvPSpoilsHeader"), claimBody );
			m_PvPSpoilsIcon.onPress = RealPresshandler;
			m_PvPSpoilsIcon.m_IsClicked = false;
		}
	}
}

function SlotChallengeRewardsAnimationDone()
{
	/*
	if (DistributedValue.GetDValue("challenge_notifications", true))
	{
		SetVisible(m_ChallengeIcon, true)
		CreateRealTooltip(m_ChallengeIcon, LDBFormat.LDBGetText("GenericGUI", "Notifications_ChallengeHeader"), LDBFormat.LDBGetText("Quests", "Mission_ChallengeReport"));
		m_ChallengeIcon.onPress = RealPresshandler;
		m_ChallengeIcon.m_IsClicked = false;
	}
	*/
}

function SlotSMSAnimationDone(buffId:Number)
{
	if (m_Character.m_InvisibleBuffList[buffId] == undefined)
	{
		return;
	}
	for (var i=0; i<m_SMSQueue.length; i++)
	{
		if (m_SMSQueue[i] == buffId)
		{
			return;
		}
	}
	m_SMSQueue.push(buffId);
	SetVisible(m_SMSIcon, true);
	m_SMSIcon.m_Badge.SetCharge(m_SMSQueue.length);
	m_SMSIcon.onPress = RealPresshandler;
	m_SMSIcon.m_IsClicked = false;
	if (m_SMSQueue.length == 1)
	{
		var tooltipData:TooltipData = TooltipDataProvider.GetBuffTooltip( buffId, Character.GetClientCharID());
		CreateRealTooltip(m_SMSIcon, tooltipData.m_Title, tooltipData.m_Descriptions[0]);
	}
}

function SlotBuffRemoved(buffId:Number, casterId:Number)
{
	var removed:Boolean = false;
	for (var i=0; i<m_SMSQueue.length; i++)
	{
		if (m_SMSQueue[i] == buffId)
		{
			m_SMSQueue.splice(i, 1);
			removed = true;
			break;
		}
	}
	if(removed)
	{
		m_SMSIcon.m_Badge.SetCharge(m_SMSQueue.length);
		var tooltipData:TooltipData = TooltipDataProvider.GetBuffTooltip( m_SMSQueue[0], Character.GetClientCharID());
		CreateRealTooltip(m_SMSIcon, tooltipData.m_Title, tooltipData.m_Descriptions[0]);
		if (m_SMSQueue.length <=0)
		{
			SetVisible(m_SMSIcon, false);
		}
	}
}

function SlotPetInventoryOpen():Void
{
	SetVisible(m_PetIcon, false);
	SetVisible(m_MountIcon, false);
}

function SlotRegionTeleportOpen():Void
{
	SetVisible(m_TeleportIcon, false);
}

// Slot Achievement Window Open
function SlotAchievementWindowOpen():Void
{
	SetVisible(m_AchievementIcon, false);
	SetVisible(m_LoreIcon, false);
	SetVisible(m_LoreFilthIcon, false);
}

//Slot Petition Window Open
function SlotPetitionWindowOpen():Void
{
    SetVisible(m_PetitionIcon, false);
}

//Slot Challenge Journal open
function SlotChallengeJournalOpen():Void
{
	SetVisible(m_ChallengeIcon, false);
}

//Get Claims
function GetClaims():Number
{
    return Claim.m_Claims.length;
}

//Get Pending Rewards
function GetPendingRewards():Number
{
	return PendingReward.m_Claims.length;
}

//Set Visible
function SetVisible(targetIcon:MovieClip, visible:Boolean):Void
{
    if (visible == targetIcon._visible )
    {
        return;
    }
    
    if (visible)
    {
        m_VisibleNotificationsArray.push(targetIcon);
    }
    else
    {
        
        for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++)
        {
            if (m_VisibleNotificationsArray[i] == targetIcon)
            {
                m_VisibleNotificationsArray.splice(i, 1);
            }
        }
    }

    targetIcon._visible = visible;
    
    for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++)
    {
        m_VisibleNotificationsArray[i]._y = 0 - ICON_DISPLACEMENT * i;
    }
	if (m_EditModeMask._visible)
	{
		LayoutEditModeMask();
		if (m_VisibleNotificationsArray.length == 0)
		{
			m_MadeFakeIcon = true;
			SetVisible(m_TutorialIcon, true);
		}
	}
}

function RemoveFocus():Void
{
	Selection.setFocus(null);
}

function SlotSetGUIEditMode(edit:Boolean)
{	
	m_EditModeMask._visible = edit;
	if (edit)
	{
		if (m_VisibleNotificationsArray.length == 0)
		{
			m_MadeFakeIcon = true;
			SetVisible(m_TutorialIcon, true);
		}
		LayoutEditModeMask();
		this.onMouseWheel = function( delta:Number )
		{
			var scaleDV:DistributedValue = DistributedValue.Create("AnimaWheelLinkScale");
			var scale:Number = scaleDV.GetValue();
			if (scale >= 50 && scale <= 200)
			{
				scaleDV.SetValue(scale + delta);
			}
		}
	}
	else
	{
		if (m_MadeFakeIcon)
		{
			m_MadeFakeIcon = false;
			SetVisible(m_TutorialIcon, false);
		}
		this.onMouseWheel = function(){}
	}
}

function SlotEditMaskPressed()
{
	var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
	scale *= DistributedValue.GetDValue("AnimaWheelLinkScale", 100) / 100;
	this.startDrag(false, 0 - (m_EditModeMask._x * scale), 0 - (m_EditModeMask._y * scale), Stage.width - ((m_EditModeMask._width + m_EditModeMask._x) * scale - (2*scale)), Stage.height - ((m_EditModeMask._height + m_EditModeMask._y) * scale - (2*scale)));
}

function SlotEditMaskReleased()
{
	this.stopDrag();
	
	var newX:DistributedValue = DistributedValue.Create( "AnimaWheelLinkX" );
	var newY:DistributedValue = DistributedValue.Create( "AnimaWheelLinkY" );	
	newX.SetValue(this._x);
	newY.SetValue(this._y);	
}

function LayoutEditModeMask()
{
	var topNotification:MovieClip = m_VisibleNotificationsArray[m_VisibleNotificationsArray.length - 1];
	m_EditModeMask._x = topNotification._x - 10;
	m_EditModeMask._y = topNotification._y - 10;
	m_EditModeMask._width = topNotification._width + 20;
	m_EditModeMask._height = ICON_DISPLACEMENT * m_VisibleNotificationsArray.length + 10;
}