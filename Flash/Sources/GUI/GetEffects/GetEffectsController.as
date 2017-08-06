//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.ScryWidgets;
import com.GameInterface.Tooltip.*;
import com.GameInterface.SpellBase;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.Quest;
import com.GameInterface.Quests;
import com.GameInterface.QuestsBase;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import flash.geom.Point;
import flash.geom.Rectangle;
import GUIFramework.SFClipLoader;

//Constants
var AP_VALUE:Number = 1;
var SP_VALUE:Number = 2;
var AURUM_VALUE:Number = 202;
var AUXILIARY_VALUE:Number = 5437;
var AUGMENT_UNLOCK_VALUE:Number = 6277;
var AUGMENT_DAMAGE_VALUE:Number = 3101;
var AUGMENT_SUPPORT_VALUE:Number = 3201;
var AUGMENT_HEALING_VALUE:Number = 3301;
var AUGMENT_SURVIVABILITY_VALUE:Number = 3401;
var AEGIS_UNLOCK_VALUE = 6817;
var AEGIS_SHIELD_VALUE = 6818;

var TDB_AUXILIARY_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AuxiliaryWeaponSlotActivated");
var TDB_AUGMENT_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AugmentSlotsActivated");
var TDB_AEGIS_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AegisSlotsActivated");
var TDB_AEGIS_SHIELD_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AegisShieldActivated");
var TDB_AUGMENT_LEARNED: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AugmentLearned");
var TDB_PENDING_DOMINATION_HEADER: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_PendingDominationHeader");
var TDB_PENDING_DOMINATION_TEMPLAR_TEXT: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_PendingDominationTemplarText");
var TDB_PENDING_DOMINATION_ILLUMINATI_TEXT: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_PendingDominationIlluminatiText");
var TDB_PENDING_DOMINATION_DRAGON_TEXT: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_PendingDominationDragonText");
var TDB_TOTAL_DOMINATION_HEADER: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_TotalDominationHeader");
var TDB_TOTAL_DOMINATION_TEXT: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_TotalDominationText");
var TDB_SHUTDOWN_DOMINATION_HEADER: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_ShutdownDominationHeader");
var TDB_SHUTDOWN_DOMINATION_TEXT: String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_ShutdownDominationText");
var TDB_EFFECT_TEXTS:Array = [
							  LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_Aegis1"),
							  LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AchievementFailed"),
							  undefined
							 ]

//Defined Get Effects triggered by ScryWidgets.SignalTriggerGetEffect
var AEGIS_1:Number = 0;
var ACHIEVEMENT_FAIL:Number = 1;
var ROOKIE_DUNGEON:Number = 2;
var PENDING_DOMINATION_TEMPLAR:Number = 3;
var PENDING_DOMINATION_DRAGON:Number = 4;
var PENDING_DOMINATION_ILLUMINATI:Number = 5;
var TOTAL_DOMINATION_TEMPLAR:Number = 6;
var TOTAL_DOMINATION_DRAGON:Number = 7;
var TOTAL_DOMINATION_ILLUMINATI:Number = 8;
var SHUTDOWN_DOMINATION_TEMPLAR:Number = 9;
var SHUTDOWN_DOMINATION_DRAGON:Number = 10;
var SHUTDOWN_DOMINATION_ILLUMINATI:Number = 11;

//Variables
var m_Character:Character;
var m_HorisontalCenter:Number;
var m_LoreStartPos:Point;
var m_AchievementStartPos:Point;
var m_TutorialStartPos:Point;
var m_GetEffectStartPos:Point;
var m_Scale:Number = 100;
var m_Language:String;
var m_LanguageMonitor:DistributedValue;

var m_AnimationQueue:Array;
var m_PlayingAnimation:Object;

var m_TutorialQueue:Array;
var m_PlayingTutorial:Object;
var m_TutorialClip:MovieClip;

var m_IsActive:Boolean;

var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode; // Only used for tutorial get effects

//On Load
function onLoad():Void
{
	m_IsActive = true;
    m_AnimationQueue = [];
	m_PlayingAnimation = undefined;
	m_TutorialQueue = [];
	m_PlayingTutorial = undefined;
    
    m_Character = Character.GetClientCharacter();
	
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
	moduleIF.SignalStatusChanged.Connect( SlotModuleStatusChanged, this );
          
    m_ResolutionScaleMonitor = DistributedValue.Create("GUIResolutionScale");
    m_ResolutionScaleMonitor.SignalChanged.Connect(SlotResolutionChange, this);

    SlotClientCharacterAlive();
    CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
    
    Lore.SignalTagAdded.Connect(SlotTagAdded, this);
	Lore.SignalGetAnimationComplete.Connect(SlotGetAnimationComplete, this);
    
	com.GameInterface.Quests.SignalTaskAdded.Connect(SlotTaskAdded, this);
	com.GameInterface.Quests.SignalMissionCompleted.Connect(SlotMissionCompleted, this);
	com.GameInterface.Quests.SignalQuestRewardMakeChoice.Connect(SlotQuestRewardMakeChoice, this);
	
	FeatInterface.SignalFeatTrained.Connect(SlotFeatTrained, this);
	
	ScryWidgets.SignalTriggerGetEffect.Connect(SlotTriggerGetEffect, this);
    
    SlotResolutionChange();
    
    m_LanguageMonitor = DistributedValue.Create("Language");
    m_LanguageMonitor.SignalChanged.Connect(SlotSetLanguage, this);
    SlotSetLanguage()
}

function SlotModuleStatusChanged(module:GUIModuleIF, isActive:Boolean):Void
{	
	m_IsActive = isActive;
	
	if (m_IsActive)
	{
		m_PlayingAnimation = undefined; // This is sort of a hack because the other one won't work (no character to connect the signal to)
		RunAnimationQueue();
	}
	//RunAnimationQueue();
}

//Slot Get Animation Complete
function SlotGetAnimationComplete(tagId:Number):Void
{
	if (Lore.GetTagType(tagId) == _global.Enums.LoreNodeType.e_TutorialTip)
	{
		m_PlayingTutorial = undefined;
		RunTutorialQueue();
	}
	else
	{
		m_PlayingAnimation = undefined;
		RunAnimationQueue();
	}
}

//GetPet
function GetPet(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_achievement_get.xml");
    }
    
    var name:String = Lore.GetTagName(tagId);

    var achievementGet:MovieClip = attachMovie("AchievementGet", "m_Animation", getNextHighestDepth());
	
	if (achievementGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    achievementGet._xscale = m_Scale;
    achievementGet._yscale = m_Scale;
    achievementGet._x = m_AchievementStartPos.x;
    achievementGet._y = m_AchievementStartPos.y;
    
    var attachedIcon:MovieClip = achievementGet.m_Icon.m_Container.attachMovie("PetDefaultIcon", "defaultIcon", achievementGet.m_Icon.m_Container.getNextHighestDepth());    
    attachedIcon._height = 108;
    attachedIcon._width = 108;
    attachedIcon._alpha = 100;
    
    achievementGet.m_AchievementText.m_Name.autoSize = "center"
    achievementGet.m_AchievementText.m_Name.text = name;
    achievementGet.m_AchievementText.m_Description.autoSize = "center";
    achievementGet.m_AchievementText.m_Description.text = "(<variable name='hotkey:Toggle_PetWindow'/ >)" + " " + LDBFormat.LDBGetText("MiscGUI", "toView");
    achievementGet.m_Id = tagId;
    
    achievementGet.gotoAndPlay(1);
    
    achievementGet.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//GetMount
function GetMount(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_achievement_get.xml");
    }
    
    var name:String = Lore.GetTagName(tagId);

    var achievementGet:MovieClip = attachMovie("AchievementGet", "m_Animation", getNextHighestDepth());
	
	if (achievementGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    achievementGet._xscale = m_Scale;
    achievementGet._yscale = m_Scale;
    achievementGet._x = m_AchievementStartPos.x;
    achievementGet._y = m_AchievementStartPos.y;
    
    var attachedIcon:MovieClip = achievementGet.m_Icon.m_Container.attachMovie("MountDefaultIcon", "defaultIcon", achievementGet.m_Icon.m_Container.getNextHighestDepth());    
    attachedIcon._height = 108;
    attachedIcon._width = 108;
    attachedIcon._alpha = 100;
    
    achievementGet.m_AchievementText.m_Name.autoSize = "center"
    achievementGet.m_AchievementText.m_Name.text = name;
    achievementGet.m_AchievementText.m_Description.autoSize = "center";
    achievementGet.m_AchievementText.m_Description.text = "(<variable name='hotkey:Toggle_PetWindow'/ >)" + " " + LDBFormat.LDBGetText("MiscGUI", "toView");
    achievementGet.m_Id = tagId;
    
    achievementGet.gotoAndPlay(1);
    
    achievementGet.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//GetTeleport
function GetTeleport(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_achievement_get.xml");
    }
    
    var name:String = Lore.GetTagName(tagId);

    var achievementGet:MovieClip = attachMovie("AchievementGet", "m_Animation", getNextHighestDepth());
	
	if (achievementGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    achievementGet._xscale = m_Scale;
    achievementGet._yscale = m_Scale;
    achievementGet._x = m_AchievementStartPos.x;
    achievementGet._y = m_AchievementStartPos.y;
    
    var attachedIcon:MovieClip = achievementGet.m_Icon.m_Container.attachMovie("TeleportDefaultIcon", "defaultIcon", achievementGet.m_Icon.m_Container.getNextHighestDepth());    
    attachedIcon._height = 108;
    attachedIcon._width = 108;
    attachedIcon._alpha = 100;
    
    achievementGet.m_AchievementText.m_Name.autoSize = "center"
    achievementGet.m_AchievementText.m_Name.text = name;
    achievementGet.m_AchievementText.m_Description.autoSize = "center";
    achievementGet.m_AchievementText.m_Description.text = "(<variable name='hotkey:Toggle_RegionTeleportWindow'/ >)" + " " + LDBFormat.LDBGetText("MiscGUI", "toView");
    achievementGet.m_Id = tagId;
    
    achievementGet.gotoAndPlay(1);
    
    achievementGet.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//Get Achievement
function GetAchievement(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_achievement_get.xml");
    }
    
    var name:String = Lore.GetTagName(tagId);
    var tagText:String = Lore.GetTagText(tagId);
	var hotkey:String = "(<variable name='hotkey:Toggle_AchievementWindow'/ >)" + " " + LDBFormat.LDBGetText("MiscGUI", "toView");

    var loreNode:LoreNode = Lore.GetDataNodeById(tagId, Lore.GetAchievementTree().m_Children);
    var achievementGet:MovieClip = attachMovie("AchievementGet", "m_Animation", getNextHighestDepth());
	
	if (achievementGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    achievementGet._xscale = m_Scale;
    achievementGet._yscale = m_Scale;
    achievementGet._x = m_AchievementStartPos.x;
    achievementGet._y = m_AchievementStartPos.y;
    
    if (loreNode.m_Icon > 0)
    {
        LoadImage(achievementGet.m_Icon.m_Container, loreNode.m_Icon);
    }
    else
    {
        AttachDefaultImage(achievementGet.m_Icon.m_Container);
    }
    
    achievementGet.m_AchievementText.m_Name.autoSize = "center"
    achievementGet.m_AchievementText.m_Name.text = name;
    achievementGet.m_AchievementText.m_Description.autoSize = "center";
    achievementGet.m_AchievementText.m_Description.htmlText = tagText + "<br>" + hotkey;
    achievementGet.m_Id = tagId;
    
    achievementGet.gotoAndPlay(1);
    
    achievementGet.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//Get Tutorial
function GetTutorial(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_lore_get.xml");
    }
    
    var text:String = Lore.GetTagText(tagId);
    var tutorialGet:MovieClip = attachMovie("TutorialGet", "m_Animation", getNextHighestDepth());
	m_TutorialClip = tutorialGet;
    
	if (tutorialGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
	escapeNode = new com.GameInterface.EscapeStackNode;
    escapeNode.SignalEscapePressed.Connect( EscapePressed, this );
	com.GameInterface.EscapeStack.Push( escapeNode );
	
    tutorialGet._xscale = m_Scale;
    tutorialGet._yscale = m_Scale;
    tutorialGet._x = m_TutorialStartPos.x;
    tutorialGet._y = m_TutorialStartPos.y;
 
    tutorialGet.m_TextClip.m_Text.autoSize = "left";
    tutorialGet.m_TextClip.m_Text._width = 280;
    tutorialGet.m_TextClip.m_Text.htmlText = text;
	trace(tutorialGet.m_DismissClip.m_DismissText);
	tutorialGet.m_DismissClip.m_DismissText.htmlText = LDBFormat.LDBGetText("GenericGUI", "ClickToDismiss");
    
    if (tutorialGet.m_TextClip.m_Text._height > 75)
    {
        tutorialGet.m_TextClip.m_Text._height = 75; // force size to prevent text overflowing
    }
    
    tutorialGet.m_TextClip.m_Text._y = (37 - (tutorialGet.m_TextClip.m_Text._height * 0.5)) -4;
    
    tutorialGet.m_Id = tagId;
    tutorialGet.gotoAndPlay(1);
    
    // break after expanding, wait 4 secs and continue
    tutorialGet.onEnterFrame = function()
    {
        if (this._currentframe  == 95)
        {
            this.gotoAndPlay(35)
			this.onRelease = function()
			{
				this.gotoAndPlay(170);
				this.onRelease = undefined;
			}
        }
        else if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(tagId);
            this.removeMovieClip();
        }
    }
}

//Get Lore
function GetLore(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_lore_get.xml");
    }
    
    var name:String = Lore.GetTagName(Lore.GetTagParent(tagId));
    var tagText:String = Lore.GetTagText(tagId);
	var hotkey:String = "(<variable name='hotkey:Toggle_AchievementWindow'/ >)" + " " + LDBFormat.LDBGetText("MiscGUI", "toView");
    var loreNode:LoreNode = Lore.GetDataNodeById(tagId, Lore.GetLoreTree().m_Children);
    
    var loreGet:MovieClip;
	if (Lore.GetTagViewpoint(tagId) == 1)
	{
		loreGet = attachMovie("LoreFilthGet", "m_Animation", getNextHighestDepth());
	}
	else
	{
		loreGet = attachMovie("LoreGet", "m_Animation", getNextHighestDepth());
	}
	
	if (loreGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    loreGet._xscale = m_Scale;
    loreGet._yscale = m_Scale;
    loreGet._x = m_LoreStartPos.x;
    loreGet._y = m_LoreStartPos.y;
    loreGet.m_LoreText.m_TagText.text = tagText;
    loreGet.m_LoreText.m_TagName.text = name;
	loreGet.m_LoreText.m_Hotkey.text = hotkey;
    loreGet.m_Id = tagId;
        
    loreGet.gotoAndPlay(1);
    
    loreGet.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

function GetEffect(effectNumber:Number):Void
{
	var effectSound:String;
	var effectClip:String;
	var startPosX:Number;
	var startPosY:Number;
	var headerText:String;
	var descText:String;
	
	switch (effectNumber)
	{
		case (AEGIS_1):							if (DistributedValue.GetDValue("aegis_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_achievement_get.xml";
													effectClip = "AEGIS_upgrade_GET";
													startPosX = m_GetEffectStartPos.x;
													startPosY = m_GetEffectStartPos.y;
												}
												break;
					
		case (ACHIEVEMENT_FAIL):				if (DistributedValue.GetDValue("achievement_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_achievement_failed.xml";
													effectClip = "Achievement_Failed_GET";
													startPosX = m_GetEffectStartPos.x;
													startPosY = m_GetEffectStartPos.y;
												}
												break;
												
		case (ROOKIE_DUNGEON):					effectSound = "sound_fxpackage_GUI_achievement_get.xml";
												effectClip = "rookie_GET";
												startPosX = m_GetEffectStartPos.x;
												startPosY = m_GetEffectStartPos.y;
												break;
												
		case (PENDING_DOMINATION_TEMPLAR):		if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_templar";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_PENDING_DOMINATION_HEADER;
													descText = TDB_PENDING_DOMINATION_TEMPLAR_TEXT;
												}
												break;
												
		case (PENDING_DOMINATION_ILLUMINATI):	if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_illuminati";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_PENDING_DOMINATION_HEADER;
													descText = TDB_PENDING_DOMINATION_ILLUMINATI_TEXT;
												}
												break;
												
		case (PENDING_DOMINATION_DRAGON):		if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_dragon";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_PENDING_DOMINATION_HEADER;
													descText = TDB_PENDING_DOMINATION_DRAGON_TEXT;
												}
												break;
		
		case (TOTAL_DOMINATION_TEMPLAR):		if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_templar";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_TOTAL_DOMINATION_HEADER;
													descText = TDB_TOTAL_DOMINATION_TEXT;
												}
												break;
												
		case (TOTAL_DOMINATION_ILLUMINATI):		if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_illuminati";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_TOTAL_DOMINATION_HEADER;
													descText = TDB_TOTAL_DOMINATION_TEXT;
												}
												break;
												
		case (TOTAL_DOMINATION_DRAGON):			if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_dragon";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_TOTAL_DOMINATION_HEADER;
													descText = TDB_TOTAL_DOMINATION_TEXT;
												}
												break;
												
		case (SHUTDOWN_DOMINATION_TEMPLAR):		if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_templar";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_SHUTDOWN_DOMINATION_HEADER;
													descText = TDB_SHUTDOWN_DOMINATION_TEXT;
												}
												break;
												
		case (SHUTDOWN_DOMINATION_ILLUMINATI):	if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_illuminati";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_SHUTDOWN_DOMINATION_HEADER;
													descText = TDB_SHUTDOWN_DOMINATION_TEXT;
												}
												break;
												
		case (SHUTDOWN_DOMINATION_DRAGON):		if (DistributedValue.GetDValue("worldDomination_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_rank.xml";
													effectClip = "worldDomination_dragon";
													startPosX = m_LoreStartPos.x;
													startPosY = m_LoreStartPos.y;
													headerText = TDB_SHUTDOWN_DOMINATION_HEADER;
													descText = TDB_SHUTDOWN_DOMINATION_TEXT;
												}
												break;
	}
	if (m_Character != undefined && effectSound != undefined)
    {
        m_Character.AddEffectPackage(effectSound);
    }
        
    var clip:MovieClip = attachMovie(effectClip, "m_Animation", getNextHighestDepth());
	
	if (clip == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}
	
    clip._xscale = m_Scale;
    clip._yscale = m_Scale;
    clip._x = startPosX;
    clip._y = startPosY;
	if (headerText != undefined && descText != undefined)
	{
		clip.m_LoreText.m_TagText.text = descText;
    	clip.m_LoreText.m_TagName.text = headerText;
	}
    
    clip.gotoAndPlay(1);
    
    clip.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

//Get Notification Effect
function GetNotificationEffect(value:Number, value2:Number):Void
{
    var effectSound:String;
    var effectClip:String;
	    
    switch (value)
    {
        case AP_VALUE:          				if (DistributedValue.GetDValue("ap_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_anima_point_get.xml";
													effectClip = "ApGet";
												}                            
                                				break;
                            
        case SP_VALUE:          				if (DistributedValue.GetDValue("sp_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_skill_point_get.xml";
                               						effectClip = "SpGet";
												}                            
                               					break;
												
		case AURUM_VALUE:						effectSound = "sound_fxpackage_GUI_get_aurum.xml";
                               					effectClip = "Aurum_Get";
                               					break;
                            
		case AUXILIARY_VALUE:   				effectSound = "sound_fxpackage_GUI_achievement_get.xml";
												effectClip = "AuxiliaryGet";
										
												break;
								
		case AUGMENT_UNLOCK_VALUE:				effectSound = "sound_fxpackage_GUI_augment_unlock.xml";
												effectClip = "AugmentUnlockGet";
												
												break;
								
		case AUGMENT_DAMAGE_VALUE:				if (DistributedValue.GetDValue("augment_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_augment_get.xml";
													effectClip = "AugmentDamageGet";
												}
												break;
							
		case AUGMENT_SUPPORT_VALUE:				if (DistributedValue.GetDValue("augment_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_augment_get.xml";
													effectClip = "AugmentSupportGet";
												}
												
												break;
										
		case AUGMENT_HEALING_VALUE:				if (DistributedValue.GetDValue("augment_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_augment_get.xml";
													effectClip = "AugmentHealingGet";
												}
												
												break;
										
		case AUGMENT_SURVIVABILITY_VALUE:		if (DistributedValue.GetDValue("augment_notifications", true))
												{
													effectSound = "sound_fxpackage_GUI_augment_get.xml";
													effectClip = "AugmentSurvivabilityGet";
												}
												
												break;
											
		case AEGIS_UNLOCK_VALUE:				effectSound = "sound_fxpackage_GUI_achievement_get.xml";
												effectClip = "AEGIS_upgrade_GET";
												
												break;
												
		case AEGIS_SHIELD_VALUE:				effectSound = "sound_fxpackage_GUI_achievement_get.xml";
												effectClip = "AEGIS_upgrade_GET";
												
    }
    
    if (m_Character != undefined && effectSound != undefined)
    {
        m_Character.AddEffectPackage(effectSound);
    }
        
    var clip:MovieClip = attachMovie(effectClip, "m_Animation", getNextHighestDepth());
	
	if (clip == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}
	
    clip._xscale = m_Scale;
    clip._yscale = m_Scale;
    clip._x = m_GetEffectStartPos.x;
    clip._y = m_GetEffectStartPos.y;
    
    if (value == AP_VALUE || value == SP_VALUE)
    {
        clip.m_Icon.m_IconEn._visible = (m_Language == "en");
        clip.m_Icon.m_IconFr._visible = (m_Language == "fr");
        clip.m_Icon.m_IconDe._visible = (m_Language == "de");
    }
	else if (value == AURUM_VALUE)
	{
		clip.m_Anim.m_Text.textField.text = "+" + value2 + " " + LDBFormat.LDBGetText("Tokens", "Token202");
	}
    
    clip.gotoAndPlay(1);
    
    clip.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

//Queue Animation
function QueueAnimation(animationInfo:Object):Void
{
	switch(animationInfo.callback)
	{
		case GetAP:
		case GetSP:
		case GetSendReport:     if (m_PlayingAnimation.callback == animationInfo.callback)
                                {
                                    return;
                                }
                                for (var i:Number = 0; i < m_AnimationQueue.length; i++)
                                {
                                    if (m_AnimationQueue[i].callback == animationInfo.callback)
                                    {
                                        return;
                                    }
                                }		
                                break;
							
		case GetTutorial:		if (m_PlayingTutorial.callback == animationInfo.callback)
								{
									if (Number(m_PlayingTutorial.argument) == Number(animationInfo.argument))
									{
										return;
									}
									else
									{
										m_TutorialClip.gotoAndPlay(170);
										m_TutorialClip.onRelease = undefined;
									}
								}
								for (var i:Number = 0; i < m_TutorialQueue.length; i++)
								{
									if (m_TutorialQueue[i].callback == animationInfo.callback)
									{
										if (Number(m_TutorialQueue[i].argument) == Number(animationInfo.argument))
										{
											return;
										}
									}
								}
								m_TutorialQueue.push(animationInfo);
								return;
	}
    
	m_AnimationQueue.push(animationInfo);
}

//Get Send Report
function GetSendReport():Void
{
    var sendReport:MovieClip = attachMovie("SendReport", "m_Animation", getNextHighestDepth());
	
	if (sendReport == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}
	
    sendReport._xscale = m_Scale;
    sendReport._yscale = m_Scale;
    sendReport._x = m_GetEffectStartPos.x;
    sendReport._y = m_GetEffectStartPos.y;
    sendReport.m_SendReportText.textField.autoSize = "center";
    sendReport.m_SendReportText.textField.htmlText = LDBFormat.LDBGetText("Quests", "Mission_SendReport");
    sendReport.gotoAndPlay(1);
    
    sendReport.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
            GUI.Mission.MissionSignals.SignalMissionRewardsAnimationDone.Emit();
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

function GetBonusMission(missionName:String):Void
{
	var bonusMission:MovieClip = attachMovie("BonusMission_GET", "m_Animation", getNextHighestDepth());
	
	if (bonusMission == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}
	
    bonusMission._xscale = m_Scale;
    bonusMission._yscale = m_Scale;
    bonusMission._x = m_GetEffectStartPos.x - 75;
    bonusMission._y = m_GetEffectStartPos.y;
	bonusMission.m_MissionName.m_Text.text = missionName;
    bonusMission.gotoAndPlay(1);
    
    bonusMission.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

//Get Send Report
function GetChallengeReport():Void
{
    var sendReport:MovieClip = attachMovie("ChallengeReport", "m_Animation", getNextHighestDepth());
	
	if (sendReport == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}
	
	if (m_Character != undefined)
	{
		m_Character.AddEffectPackage("sound_fxpackage_GUI_challenge_complete.xml");
	}
	
    sendReport._xscale = m_Scale;
    sendReport._yscale = m_Scale;
    sendReport._x = m_AchievementStartPos.x;
    sendReport._y = m_AchievementStartPos.y;
    sendReport.m_SendReportText.m_Text.autoSize = "center";
    sendReport.m_SendReportText.m_Text.htmlText = LDBFormat.LDBGetText("Quests", "Mission_ChallengeReport");
	sendReport.m_HotkeyText.m_Text.text = "(<variable name='hotkey:Toggle_ChallengeJournalWindow'/ >)" + " " + LDBFormat.LDBGetText("MiscGUI", "toView");
    sendReport.gotoAndPlay(1);
    
    sendReport.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
            GUI.Mission.MissionSignals.SignalChallengeRewardsAnimationDone.Emit();
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

function GetSMS(buffId:Number):Void
{
	if (m_Character.m_InvisibleBuffList[buffId] == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(); 
		return;
	}
	var sms:MovieClip = attachMovie("SMSGet", "m_Animation", getNextHighestDepth());
	
	if (sms == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(); 
		return;
	}
	
	if (m_Character != undefined)
	{
		m_Character.AddEffectPackage("sound_fxpackage_GUI_send_report.xml");
	}
	
	var tooltipData:TooltipData = TooltipDataProvider.GetBuffTooltip( buffId, Character.GetClientCharID());
	
    sms._xscale = m_Scale;
    sms._yscale = m_Scale;
    sms._x = m_LoreStartPos.x;
    sms._y = m_LoreStartPos.y;
    sms.m_LoreText.m_TagText.text = tooltipData.m_Descriptions[0];
    sms.m_LoreText.m_TagName.text = tooltipData.m_Title;
    sms.m_Id = buffId;
    sms.gotoAndPlay(1);
	
	sms.onRelease = function()
	{
		GUI.Mission.MissionSignals.SignalSMSAnimationDone.Emit(buffId);
		Lore.SignalGetAnimationComplete.Emit();
		SpellBase.ActivateNotification(SpellBase.GetStat(buffId, _global.Enums.Stat.e_NotificationBuff));
		this.removeMovieClip();
	}
    
    sms.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
            GUI.Mission.MissionSignals.SignalSMSAnimationDone.Emit(buffId);
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

function GetWeaponLevel(weaponStat:Number):Void
{
	var effectClip:String = undefined;
	switch(weaponStat)
	{
		case _global.Enums.Stat.e_ShotgunsXP: 		effectClip = "weaponlevel_shotgun_GET";
											  		break;
		case _global.Enums.Stat.e_PistolsXP:  		effectClip = "weaponlevel_pistol_GET";
											  		break;
		case _global.Enums.Stat.e_AssaultRiflesXP:  effectClip = "weaponlevel_assaultrifle_GET";
											  		break;
		case _global.Enums.Stat.e_ChaosXP:			effectClip = "weaponlevel_chaos_GET";
											  		break;
		case _global.Enums.Stat.e_ElementalismXP:	effectClip = "weaponlevel_elemental_GET";
											  		break;
		case _global.Enums.Stat.e_BloodMagicXP:		effectClip = "weaponlevel_blood_GET";
											  		break;
		case _global.Enums.Stat.e_FistsXP:			effectClip = "weaponlevel_fist_GET";
											  		break;
		case _global.Enums.Stat.e_BladesXP:			effectClip = "weaponlevel_blade_GET";
											  		break;
		case _global.Enums.Stat.e_HammersXP:		effectClip = "weaponlevel_hammer_GET";
											  		break;
		case _global.Enums.Stat.e_RocketLauncherXP:	effectClip = undefined;
											  		break;
		case _global.Enums.Stat.e_ChainsawXP:		effectClip = undefined;
											  		break;
		case _global.Enums.Stat.e_WhipXP:			effectClip = undefined;
											  		break;
		case _global.Enums.Stat.e_FlamethrowerXP:	effectClip = undefined;
											  		break;
		case _global.Enums.Stat.e_QuantumXP:		effectClip = undefined;
											  		break;
	}
	if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_achievement_get.xml");
    }
        
    var clip:MovieClip = attachMovie(effectClip, "m_Animation", getNextHighestDepth());
	
	if (clip == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}
	
    clip._xscale = m_Scale;
    clip._yscale = m_Scale;
    clip._x = m_GetEffectStartPos.x;
    clip._y = m_GetEffectStartPos.y;
    
    clip.gotoAndPlay(1);
    
    clip.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}
    

//Get Send Report
function GetBattleToken():Void
{
    var battleToken:MovieClip = attachMovie("BattleTokenGet", "m_Animation", getNextHighestDepth());
	
	if (battleToken == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}

    var effectSound:String = "sound_fxpackage_GUI_token.xml";
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage(effectSound);
    }
	
    battleToken._xscale = m_Scale;
    battleToken._yscale = m_Scale;
    battleToken._x = m_GetEffectStartPos.x;
    battleToken._y = m_GetEffectStartPos.y;
    battleToken.gotoAndPlay(1);
    
    battleToken.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
            Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

//Slot Set Language
function SlotSetLanguage():Void
{
    m_Language = m_LanguageMonitor.GetValue();
}

function SlotTaskAdded(missionID:Number):Void
{
	var quest:Quest = GetMission(missionID);
	if (quest != undefined)
	{
		if (quest.m_MissionType == _global.Enums.MainQuestType.e_AreaMission)
		{
			QueueAnimation({callback: GetBonusMission, argument: [quest.m_MissionName]});
			RunAnimationQueue();
		}
	}
	
}

function GetMission(missionID) : Quest
{
    var quests:Array = Quests.GetAllActiveQuests();
	for ( var i = 0; i < quests.length; ++i )
	{
		if (quests[i].m_ID == missionID)
		{
			return quests[i];
		}
	}    
    return null;
}

//Slot Mission Completed
function SlotMissionCompleted(missionID:Number):Void
{
	if (DistributedValue.GetDValue("challenge_notifications", true))
	{
		if (QuestsBase.IsChallengeMission(missionID))
		{
			QueueAnimation({ callback: GetChallengeReport });
			RunAnimationQueue();
		}
	}
}

//Slot Quest Reward Make Choice - When a mission has rewards attached
function SlotQuestRewardMakeChoice(taskID:Number):Void
{
	if (!QuestsBase.IsChallengeMission(QuestsBase.GetMainQuestIDByQuestID(taskID)))
	{
		QueueAnimation({ callback: GetSendReport });
		RunAnimationQueue();
	}
}

function SlotStatChanged(stat:Number):Void
{
    if (stat == _global.Enums.Stat.e_PvPLevel)
    {
        var inplay:Number = m_Character.GetStat(_global.Enums.Stat.e_InPlay);
        var isInPlay:Boolean = (inplay == 1);
        if (isInPlay)
        {
            QueueAnimation({ callback: GetBattleRankEffect });//GetRank, argument: [12] });
            RunAnimationQueue();
        }
    }
	if (stat == _global.Enums.Stat.e_Level)
	{
		var inplay:Number = m_Character.GetStat(_global.Enums.Stat.e_InPlay);
        var isInPlay:Boolean = (inplay == 1);
		if (isInPlay)
		{
			QueueAnimation({ callback: GetLevelUpEffect });
			RunAnimationQueue();
		}
	}
}

//Get GetBattleRankEffect
function GetBattleRankEffect():Void
{
    var rankGet:MovieClip = attachMovie("BattleRankGet", "m_Animation", getNextHighestDepth());
	
	if (rankGet == undefined)
	{
		return;
	}
    
    var effectSound:String = "sound_fxpackage_GUI_rank.xml";
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage(effectSound);
    }

    rankGet._xscale = m_Scale;
    rankGet._yscale = m_Scale;
    rankGet._x = m_GetEffectStartPos.x;
    rankGet._y = m_GetEffectStartPos.y;
    rankGet.m_Animation.gotoAndPlay(1);
    rankGet.m_Id = tagId;
    
    rankGet.onEnterFrame = function()
    {
        if (this["m_Animation"]._currentframe == this["m_Animation"]._totalframes)
        {
            Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

function GetLevelUpEffect():Void
{
	var levelGet:MovieClip = attachMovie("LevelUp_GET", "m_Animation", getNextHighestDepth());
	
	if (levelGet == undefined)
	{
		return;
	}
	
	levelGet._xscale = m_Scale;
	levelGet._yscale = m_Scale;
	levelGet._x = m_LevelEffectStartPos.x;
	levelGet._y = m_LevelEffectStartPos.y;
	levelGet.gotoAndPlay(1);
	
	levelGet.onEnterFrame = function()
	{
		if (this._currentframe == this._totalframes)
		{
			Lore.SignalGetAnimationComplete.Emit();
			this.removeMovieClip();
		}
	}
	m_Character.AddEffectPackage("sound_fxpackage_GUI_level_up_icon.xml");
}

//Slot Tag Added
function SlotTagAdded(tagId:Number, characterId:ID32):Void
{
    if (tagId == AUXILIARY_VALUE)
    {
        QueueAnimation( { callback: GetNotificationEffect, argument: [tagId] } );
        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(TDB_AUXILIARY_UNLOCKED, 0)
        RunAnimationQueue();
        
        return;
    }
	
	if (tagId == AUGMENT_UNLOCK_VALUE)
    {
        QueueAnimation( { callback: GetNotificationEffect, argument: [tagId] } );
        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(TDB_AUGMENT_UNLOCKED, 0)
        RunAnimationQueue();
        
        return;
    }
	
	if (tagId == AEGIS_UNLOCK_VALUE)
	{
		QueueAnimation( { callback: GetNotificationEffect, argument: [tagId] } );
        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(TDB_AEGIS_UNLOCKED, 0)
        RunAnimationQueue();
        
        return;
	}
	
	if (tagId == AEGIS_SHIELD_VALUE)
	{
		QueueAnimation( { callback: GetNotificationEffect, argument: [tagId] } );
        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(TDB_AEGIS_SHIELD_UNLOCKED, 0)
        RunAnimationQueue();
        
        return;
	}

    if (!characterId.Equal(Character.GetClientCharID()))
    {
        return;
    }
    
    if (!Lore.ShouldShowGetAnimation(tagId))
    {
        return;
    }
    
    var loreNodeType:Number = Lore.GetTagType(tagId);
    switch(loreNodeType)
    {
        case _global.Enums.LoreNodeType.e_Achievement:
        case _global.Enums.LoreNodeType.e_SubAchievement:
		case _global.Enums.LoreNodeType.e_SeasonalAchievement:
		case _global.Enums.LoreNodeType.e_SeasonalSubAchievement:	if (DistributedValue.GetDValue("achievement_notifications", true))
																	{
																		QueueAnimation({ callback: GetAchievement, argument: [tagId] });
																	}
                                                            		break;
                                                            
        case _global.Enums.LoreNodeType.e_Lore:             		if (DistributedValue.GetDValue("lore_notifications", true))
																	{
																		QueueAnimation({ callback: GetLore, argument: [tagId] });
																	}
                                                            		break;
                                                            
        case _global.Enums.LoreNodeType.e_TutorialTip:      		if (DistributedValue.GetDValue("tutorial_notifications", true))
																	{
																		QueueAnimation({ callback: GetTutorial, argument: [tagId] });
																		RunTutorialQueue();
																		return;
																	}
                                                           		 	break;
                                                            
        case _global.Enums.LoreNodeType.e_Tutorial:         		if (DistributedValue.GetDValue("tutorial_notifications", true))
																	{
																		Lore.OpenTag(tagId);
																	}
                                                            		break;
                                                            
        case _global.Enums.LoreNodeType.e_Title:            		//QueueAnimation({ callback: GetTitle, argument: [tagId] });
                                                            		break;
                                                            
        case _global.Enums.LoreNodeType.e_FactionTitle:     		QueueAnimation({ callback: GetRank, argument: [tagId] });
																	break;
		
		case _global.Enums.LoreNodeType.e_Pets:						if (DistributedValue.GetDValue("pet_notifications", true))
																	{
																		QueueAnimation({ callback: GetPet, argument: [tagId] });
																	}
																	break;
																	
		case _global.Enums.LoreNodeType.e_Mounts:					if (DistributedValue.GetDValue("mount_notifications", true))
																	{
																		QueueAnimation({ callback: GetMount, argument: [tagId] });
																	}
																	break;
																	
		case _global.Enums.LoreNodeType.e_Teleports:				if (DistributedValue.GetDValue("teleport_notifications", true))
																	{
																		QueueAnimation({ callback: GetTeleport, argument: [tagId] });
																	}
																	break;
    }
    
    RunAnimationQueue();
}

//Slot Feat Trained
function SlotFeatTrained(featID:Number): Void
{
	var featData:FeatData = FeatInterface.m_FeatList[featID];
	//TODO: Change these to featData.m_SpellType when we have different spell types for each augment type
	if (featData.m_ClusterIndex > 3100 && featData.m_ClusterIndex < 3500)
	{
		QueueAnimation( { callback: GetNotificationEffect, argument: [featData.m_ClusterIndex] } );
        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(TDB_AUGMENT_LEARNED, 0)
        RunAnimationQueue();
	}
}

function SlotTriggerGetEffect(effectNumber:Number): Void
{
	QueueAnimation( { callback: GetEffect, argument: [effectNumber] } );
	if (TDB_EFFECT_TEXTS[effectNumber] != undefined)
	{
		com.GameInterface.Chat.SignalShowFIFOMessage.Emit(TDB_EFFECT_TEXTS[effectNumber], 0);
	}
	RunAnimationQueue();
}

function SlotInvisibleBuffAdded(buffId:Number)
{
	var inplay:Number = m_Character.GetStat(_global.Enums.Stat.e_InPlay);
    var isInPlay:Boolean = (inplay == 1);
	if(m_Character.m_BuffsInitialized && isInPlay)
	{
		if (SpellBase.GetStat(buffId, _global.Enums.Stat.e_NotificationBuff) != 0)
		{
			QueueAnimation( { callback: GetSMS, argument: [buffId] } );
			RunAnimationQueue();
		}
	}
	else
	{
		if (SpellBase.GetStat(buffId, _global.Enums.Stat.e_NotificationBuff) != 0)
		{
			GUI.Mission.MissionSignals.SignalSMSAnimationDone.Emit(buffId);
		}
	}
}

function SlotGainedWeaponLevel(weaponStat:Number, newLevel:Number)
{
	QueueAnimation({callback: GetWeaponLevel, argument: [weaponStat]});
	RunAnimationQueue()
}

//Slot Client Character Alive
function SlotClientCharacterAlive():Void
{
    m_Character = Character.GetClientCharacter();
	
	m_TutorialQueue = new Array();
	if (m_PlayingTutorial != undefined || m_TutorialClip != undefined)
	{
		m_TutorialClip.removeMovieClip();
		m_PlayingTutorial = undefined;
		m_TutorialClip = undefined;
	}
    
    if (m_Character != undefined)
    {
        m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
        m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
		m_Character.SignalInvisibleBuffAdded.Connect(SlotInvisibleBuffAdded, this);
		m_Character.SignalGainedWeaponLevel.Connect(SlotGainedWeaponLevel, this);
    }
}

//GetTitle
function GetTitle(tagId:Number):Void
{
    var titleName:String = Lore.GetTagName(tagId);
    var rankGet:MovieClip = attachMovie("Title_GET", "m_Animation", getNextHighestDepth());
	
    
    var effectSound:String = "sound_fxpackage_GUI_achievement_get.xml";
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage(effectSound);
    }
    
	if (rankGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    rankGet._xscale = m_Scale;
    rankGet._yscale = m_Scale;
    rankGet._x = m_GetEffectStartPos.x;
    rankGet._y = m_GetEffectStartPos.y;
    rankGet.m_Animation.gotoAndPlay(1);
    rankGet.m_Id = tagId;
	rankGet.m_UnlockText.m_Text.text = LDBFormat.LDBGetText("GenericGUI", "TitleUnlock");
	rankGet.m_TitleText.m_Text.text = titleName;
    
    rankGet.onEnterFrame = function()
    {
        if (this["m_Animation"]._currentframe == this["m_Animation"]._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//Get Rank
function GetRank(tagId:Number):Void
{
    var faction:String = com.Utils.Faction.GetFactionNameNonLocalized(m_Character.GetStat(_global.Enums.Stat.e_PlayerFaction));
    var rank:Number = Lore.GetRank(tagId);
    var rankGet:MovieClip = attachMovie(faction+"_"+rank, "m_Animation", getNextHighestDepth());
	
    
    var effectSound:String = "fxpackage_dialogue_ai_FactionRankIncreased_generic";
	var effectSound2:String = "sound_fxpackage_GUI_faction_rank_up_icon.xml";
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage(effectSound);
		m_Character.AddEffectPackage(effectSound2);
    }
    
	if (rankGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    rankGet._xscale = m_Scale;
    rankGet._yscale = m_Scale;
    rankGet._x = m_GetEffectStartPos.x;
    rankGet._y = m_GetEffectStartPos.y;
    rankGet.m_Animation.gotoAndPlay(1);
    rankGet.m_Id = tagId;
    
    rankGet.onEnterFrame = function()
    {
        if (this["m_Animation"]._currentframe == this["m_Animation"]._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//Slot Resolution Change
function SlotResolutionChange():Void
{
    var visibleRect:Rectangle = Stage["visibleRect"];
    var realScale:Number = m_ResolutionScaleMonitor.GetValue();
    
    m_Scale = realScale * 100;
    m_HorisontalCenter = visibleRect.width * 0.5;
    
    var loreStartY:Number = visibleRect.height - (170 * realScale);
    m_LoreStartPos = new Point(m_HorisontalCenter, loreStartY);
    
    var tutorialStartY:Number = visibleRect.height - (350 * realScale);
    m_TutorialStartPos = new Point(m_HorisontalCenter - (715 * realScale), tutorialStartY);
    
    var achievementsY:Number = visibleRect.height - (300 * realScale);
    m_AchievementStartPos = new Point(m_HorisontalCenter, achievementsY);
    
    var getEffectsStartY:Number = 200 * realScale;
    m_GetEffectStartPos = new Point(m_HorisontalCenter, getEffectsStartY);
	
	var levelEffectsStartY:Number = 0;
    m_LevelEffectStartPos = new Point(m_HorisontalCenter - (267 * realScale), levelEffectsStartY);
}

//Slot Token Amount Changed
function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number):Void
{
    if (newValue > oldValue)
    {
        if (id == _global.Enums.Token.e_Prowess_Point)
        {
            QueueAnimation({ callback: GetBattleToken });
        }
        else
        {
            QueueAnimation( { callback: GetNotificationEffect, argument: [id, newValue - oldValue] } );
        }
        
        RunAnimationQueue();
    }
}

//Run the Tutorial Queue
function RunTutorialQueue()
{
	if (m_PlayingTutorial == undefined && m_IsActive)
    {
        if (m_TutorialQueue.length > 0)
        {
            m_PlayingTutorial = m_TutorialQueue.shift();
            m_PlayingTutorial.callback.apply(this, m_PlayingTutorial.argument);
        }
    }
}

//Run Animation Queue
function RunAnimationQueue()
{
    if (m_PlayingAnimation == undefined && m_IsActive)
    {
        if (m_AnimationQueue.length > 0)
        {
            m_PlayingAnimation = m_AnimationQueue.shift();
            m_PlayingAnimation.callback.apply(this, m_PlayingAnimation.argument);
        }
    }
}

//Load Image
function LoadImage(container:MovieClip, mediaId:Number):Void
{
    var imageLoader:MovieClipLoader = new MovieClipLoader();
    var path = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + mediaId;
    
    imageLoader.addListener(this);
    imageLoader.loadClip(path, container);
}

//On Load Init
function onLoadInit(target:MovieClip):Void
{
    target._height = 108;
    target._width = 108;
    target._alpha = 100;
    target._x = 3;
    target._y = 3;
}

//On Load Error
function onLoadError(target:MovieClip, errorcode:String):Void
{
    AttachDefaultImage(target);
}

//Attach Default Image
function AttachDefaultImage(container:MovieClip):Void
{
    var attachedIcon:MovieClip = container.attachMovie("AchievementDefaultIcon", "defaultIcon", container.getNextHighestDepth());
    
    attachedIcon._height = 108;
    attachedIcon._width = 108;
    attachedIcon._alpha = 100;
}

function EscapePressed():Void
{
	if (m_TutorialClip != undefined)
	{
		m_TutorialClip.gotoAndPlay(170); // This is a hack!
		escapeNode = undefined;
	}
}