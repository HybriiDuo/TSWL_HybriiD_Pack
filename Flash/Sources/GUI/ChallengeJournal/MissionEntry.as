import gfx.core.UIComponent;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import mx.utils.Delegate;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.GameInterface.Quest;
import com.GameInterface.QuestTask;
import com.GameInterface.QuestGoal;
import com.GameInterface.Quests;
import com.GameInterface.DistributedValue;
import com.GameInterface.Utils;
import com.GameInterface.Inventory;
import com.GameInterface.Game.Character;
import GUI.Mission.MissionUtils;
import com.Components.ItemSlot;
import com.Utils.Text;

class GUI.ChallengeJournal.MissionEntry extends UIComponent
{
	//Components created in .fla
	private var m_Background:MovieClip;
	private var m_Frame:MovieClip;
	private var m_HitArea:MovieClip;
	private var m_Progress:MovieClip;
	private var m_Name:TextField;
	private var m_CompleteText:TextField;
	private var m_ClaimButton:MovieClip;
	
	//Variables
	public var SignalEntrySelected:Signal;
	public var SignalSizeChanged:Signal;
	public var m_Index:Number;
	public var m_MissionInfo:Quest;
	public var m_Character:Character;
	public var m_IsExpanded:Boolean;
	public var m_CanHit:Boolean;
	public var m_Completed:Boolean;
	private var m_IntervalId:Number;
	
	public var m_Description:MovieClip;
	public var m_RewardsArray:Array;
	public var m_BonusRewardsArray:Array;
	public var m_MissionIcon:MovieClip;
	
	//Statics
	public var CONTRACT_HEIGHT = 40;
	public var EXPAND_HEIGHT = 124;
	public var REWARD_SIZE = 28;
	public var REWARD_PADDING = 5;
	public var INCOMPLETE_ALPHA = 100;
	public var COMPLETE_ALPHA = 30;
	public var BONUS_MARKS_ITEM = 9310069;
	
	public function MissionEntry() 
	{
		super();
		SignalEntrySelected = new Signal();
		SignalSizeChanged = new Signal();
		m_IsExpanded = false;
		m_CanHit = true;
		
		m_CompleteText.text = LDBFormat.LDBGetText("GenericGUI", "complete");
		m_ClaimButton.m_Text.text = LDBFormat.LDBGetText("GenericGUI", "claimReward");
        m_ClaimButton.onRelease = Delegate.create(this, ClaimRewards);
		m_ClaimButton.onRollOver = m_ClaimButton.onDragOver = function()
		{
			Colors.Tint(this, 0xFFFFFF, 20);
		}
		m_ClaimButton.onRollOut = m_ClaimButton.onDragOut = function()
		{
			Colors.Tint(this, 0x000000, 0);
		}
		
		m_HitArea.onRelease = Delegate.create(this, HitAreaReleaseHandler);
		
		m_Character = Character.GetClientCharacter();
		m_Character.SignalMemberStatusUpdated.Connect(SlotMemberStatusUpdated, this);
	}
	
	public function SetData(missionInfo:Quest, index:Number):Void
	{
		m_MissionInfo = missionInfo;
		m_Index = index;
		m_Name.text = m_MissionInfo.m_MissionName;
		
		UpdateProgress();
		
		//Attach the proper icon
		var missionType:String = MissionUtils.MissionTypeToString( m_MissionInfo.m_MissionType );
		m_MissionIcon = this.attachMovie("_Icon_Mission_" + missionType, "m_MissionIcon", this.getNextHighestDepth());
		m_MissionIcon._xscale = m_MissionIcon._yscale = 60;
		m_MissionIcon._x = m_MissionIcon._y = 5;
		m_MissionIcon.state = "up"
        m_MissionIcon.disableFocus = true;
		if (m_MissionInfo.m_CurrentTask.m_Difficulty > 10)
		{
			m_MissionIcon.attachMovie("NMIconFilter", "m_NMFilter", m_MissionIcon.getNextHighestDepth());
		}
		switch(m_MissionInfo.m_MissionType)
		{
			case _global.Enums.MainQuestType.e_DailyMission:
			case _global.Enums.MainQuestType.e_DailyDungeon:
			case _global.Enums.MainQuestType.e_DailyRandomDungeon:
			case _global.Enums.MainQuestType.e_DailyPvP:
			case _global.Enums.MainQuestType.e_DailyMassivePvP:
			case _global.Enums.MainQuestType.e_DailyScenario:
				var cocarde:MovieClip = m_MissionIcon.attachMovie("_Icon_Cocarde_Daily", "cocarde", m_MissionIcon.getNextHighestDepth());
				cocarde._xscale = cocarde._yscale = 75;
				cocarde._x = cocarde._y = -2;
				break;
			case _global.Enums.MainQuestType.e_WeeklyMission:
			case _global.Enums.MainQuestType.e_WeeklyDungeon:
			case _global.Enums.MainQuestType.e_WeeklyRaid:
			case _global.Enums.MainQuestType.e_WeeklyPvP:
			case _global.Enums.MainQuestType.e_WeeklyScenario:
				var cocarde:MovieClip = m_MissionIcon.attachMovie("_Icon_Cocarde_Weekly", "cocarde", m_MissionIcon.getNextHighestDepth());
				cocarde._xscale = cocarde._yscale = 75;
				cocarde._x = cocarde._y = -2;
				break;
			default:
		}
		
		//Set completion
		SetComplete(m_MissionInfo.m_CooldownExpireTime != undefined)
		FixLayers();
	}
	
	public function UpdateProgress(overrideSolves:Number):Void
	{
		var goal:QuestGoal = m_MissionInfo.m_CurrentTask.m_Goals[0];
		var totalRepeats:Number = goal.m_RepeatCount;
		//This is a stupid hack because SolvedTimes will be inaccurate here if this is an update
		var totalSolves:Number = overrideSolves == undefined ? goal.m_SolvedTimes : overrideSolves;
		
		m_Progress._visible = true;
		m_Progress.m_Text.text = totalSolves + "/" + totalRepeats;
		
		var percentage:Number = totalSolves/totalRepeats;
		m_Progress.m_Bar._width = (m_Progress.m_Background._width - 5) * percentage;
	}
	
	private function HitAreaReleaseHandler():Void
	{
		if (m_CanHit)
		{
			SignalEntrySelected.Emit(m_Index, m_IsExpanded);
			if (m_IsExpanded)
			{
				Contract();
			}
			else
			{
				Expand();
			}		
		}
	}
	
	public function Expand():Void
	{
		SetHittable(false);
		m_IsExpanded = true;
		
		AddDescription();
		AddRewards();
		
		m_Background.tweenEnd(false);
		m_Background.tweenTo(0.3, { _height: EXPAND_HEIGHT }, None.easeNone);
		m_Frame.tweenEnd(false);
        m_Frame.tweenTo(0.3, { _height: EXPAND_HEIGHT, _alpha: INCOMPLETE_ALPHA }, None.easeNone);
		m_HitArea.tweenEnd(false);
		m_HitArea.tweenTo(0.3, { _height: EXPAND_HEIGHT }, None.easeNone);
		m_Background.onTweenComplete = Delegate.create(this, CleanupAfterAnimation);
		FixLayers();
	}
	
	public function Contract():Void
	{
		SetHittable(false);
		m_IsExpanded = false;
		
		RemoveDescription();
		RemoveRewards();
		
		m_Background.tweenEnd(false);
		m_Background.tweenTo(0.3, { _height: CONTRACT_HEIGHT }, None.easeNone);
		m_Frame.tweenEnd(false);
        m_Frame.tweenTo(0.3, { _height: CONTRACT_HEIGHT, _alpha: COMPLETE_ALPHA }, None.easeNone);
		m_HitArea.tweenEnd(false);
		m_HitArea.tweenTo(0.3, { _height: CONTRACT_HEIGHT }, None.easeNone);
		m_Background.onTweenComplete = Delegate.create(this, CleanupAfterAnimation);
	}
	
	private function CleanupAfterAnimation():Void
	{
		SetHittable(true);
		SignalSizeChanged.Emit();
	}
	
	private function AddDescription():Void
	{
		m_Description = this.attachMovie("MissionEntryDescription", "m_Description", this.getNextHighestDepth());
		m_Description.m_Description.text = m_MissionInfo.m_MissionDesc;
		m_Description._x = 5;
		m_Description._y = m_Name._y + m_Name._height + 10;
		
		var finalAlpha:Number = m_Completed ? COMPLETE_ALPHA : INCOMPLETE_ALPHA;
		m_Description._alpha = 0;		
		m_Description.tweenEnd(false);
		m_Description.tweenTo(0.5, { _alpha: finalAlpha }, Strong.easeIn);
	}
	
	private function RemoveDescription():Void
	{
		m_Description.tweenEnd(false);
		m_Description.tweenTo(0.1, { _alpha: 0 }, Strong.easeOut);
		m_Description.onTweenComplete = function()
		{
			this.removeMovieClip();
		}
	}
	
	private function AddRewards():Void
	{
		if (m_Description != undefined)
		{
			m_RewardsArray = new Array();
			var rewardX:Number = m_Description._x + m_Description.m_Reward._x + REWARD_PADDING;
			var rewardY:Number = m_Description._y + m_Description.m_Reward._y + REWARD_PADDING;
			var finalAlpha:Number = m_Completed ? COMPLETE_ALPHA : INCOMPLETE_ALPHA;
			for (var i:Number = 0; i < m_MissionInfo.m_Rewards.length; i++)
			{				
				var rewardSlot:MovieClip = this.attachMovie("IconSlot", "m_Reward_" + i, this.getNextHighestDepth());
				rewardSlot._height = rewardSlot._width = REWARD_SIZE;		
				var itemSlot = new ItemSlot(undefined, i, rewardSlot);
				itemSlot.SetData(m_MissionInfo.m_Rewards[i].m_InventoryItem);				
				
				rewardSlot._x = rewardX;
				rewardSlot._y = rewardY;
				rewardX += REWARD_SIZE + REWARD_PADDING * 2;
				m_RewardsArray.push(rewardSlot);
				
				rewardSlot._alpha = 0;
				rewardSlot.tweenEnd(false);
				rewardSlot.tweenTo(0.5, { _alpha: finalAlpha }, Strong.easeIn);
			}
			
			m_Description.m_Divider._x = rewardX;
			m_Description.m_MemberIcon._x = m_Description.m_Divider._x + m_Description.m_Divider._width + REWARD_PADDING * 2;
			var incompleteAlpha:Number = m_Character.IsMember() ? INCOMPLETE_ALPHA : COMPLETE_ALPHA;
			finalAlpha = m_Completed ? COMPLETE_ALPHA : incompleteAlpha;
			m_Description.m_Divider._alpha = finalAlpha;
			m_Description.m_MemberIcon._alpha = finalAlpha;
			var bonusRewardSlot:MovieClip = this.attachMovie("IconSlot", "m_BonusReward", this.getNextHighestDepth());
			bonusRewardSlot._height = bonusRewardSlot._width = REWARD_SIZE;
			var itemSlot = new ItemSlot(undefined, i, bonusRewardSlot);
			itemSlot.SetData(Inventory.CreateACGItemFromTemplate(BONUS_MARKS_ITEM, 0, 0, 1));
			bonusRewardSlot._x = m_Description._x + m_Description.m_MemberIcon._x + m_Description.m_MemberIcon._width + REWARD_PADDING * 2;
			bonusRewardSlot._y = rewardY;
			m_RewardsArray.push(bonusRewardSlot);
			bonusRewardSlot._alpha = 0;
			bonusRewardSlot.tweenEnd(false);
			bonusRewardSlot.tweenTo(0.5, { _alpha:finalAlpha }, Strong.easeIn);
			
			
			if (m_MissionInfo.m_Xp > 0)
			{
				var incompleteAlpha:Number = m_Character.IsMember() ? INCOMPLETE_ALPHA : COMPLETE_ALPHA;
				finalAlpha = m_Completed ? COMPLETE_ALPHA : incompleteAlpha;
				m_Description.m_MemberIconXP._alpha = finalAlpha;
				if (!m_Character.IsMember())
				{
					m_Description.m_BonusXPText.textColor = 0x666666;
				}

				m_Description.m_BonusXPText.autoSize = "right";
				m_Description.m_BonusXPText.text = "+" + Text.AddThousandsSeparator(m_MissionInfo.m_Xp * (Utils.GetGameTweak("SubscriberBonusXPPercent")/100));
				m_Description.m_MemberIconXP._x = m_Description.m_BonusXPText._x + m_Description.m_BonusXPText._width - m_Description.m_BonusXPText.textWidth - m_Description.m_MemberIconXP._width - REWARD_PADDING*2;
				m_Description.m_XPText.autoSize = "right";
				m_Description.m_XPText.text = Text.AddThousandsSeparator(m_MissionInfo.m_Xp);
				m_Description.m_XPText._x = m_Description.m_MemberIconXP._x - m_Description.m_XPText._width - REWARD_PADDING * 2;
				m_Description.m_XPIcon._x = m_Description.m_XPText._x + m_Description.m_XPText._width - m_Description.m_XPText.textWidth - m_Description.m_XPIcon._width - REWARD_PADDING*2;
			}
			else
			{
				m_Description.m_XPText._visible = false;
				m_Description.m_XPIcon._visible = false;
				m_Description.m_BonusXPText._visible = false;
				m_Description.m_MemberIconXP._visible = false;
			}
		}
	}
	
	private function RemoveRewards():Void
	{
		for (var i:Number = 0; i< m_RewardsArray.length; i++)
		{
			m_RewardsArray[i].tweenEnd(false);
			m_RewardsArray[i].tweenTo(0.1, {_alpha: 0 }, Strong.easeOut);
			m_RewardsArray[i].onTweenComplete = function()
			{
				this.removeMovieClip();
			}
		}

		for (var i:Number = 0; i< m_BonusRewardsArray.length; i++)
		{
			m_BonusRewardsArray[i].tweenEnd(false);
			m_BonusRewardsArray[i].tweenTo(0.1, {_alpha: 0 }, Strong.easeOut);
			m_BonusRewardsArray[i].onTweenComplete = function()
			{
				this.removeMovieClip();
			}
		}
	}
	
	public function SetComplete(completed:Boolean)
	{
		m_Completed = completed;
		m_CompleteText._visible = completed;
		if (completed)
		{
			m_Progress._visible = false;
		}
		else
		{
			UpdateProgress();
		}
		
		var newAlpha:Number = m_Completed ? COMPLETE_ALPHA : INCOMPLETE_ALPHA;		
		m_Background._alpha = newAlpha;
		m_Name._alpha = newAlpha;
		if (m_MissionIcon != undefined)
		{
			m_MissionIcon._alpha = newAlpha;
		}
		if (m_Description != undefined)
		{
			m_Description._alpha = newAlpha;
		}
		if (m_RewardsArray != undefined)
		{
			for (var i:Number = 0; i< m_RewardsArray.length; i++)
			{
				m_RewardsArray[i]._alpha = newAlpha;
			}
		}

		if (m_BonusRewardsArray != undefined)
		{
			var bonusAlpha:Number = m_Completed || !m_Character.IsMember() ? COMPLETE_ALPHA : INCOMPLETE_ALPHA;
			for (var i:Number = 0; i< m_BonusRewardsArray.length; i++)
			{
				m_BonusRewardsArray[i]._alpha = bonusAlpha;
			}
			if (m_Description != undefined)
			{
				m_Description.m_MemberIconXP._alpha = bonusAlpha;
				m_Description.m_BonusXPText._alpha = bonusAlpha;
			}
		}

		CheckUnclaimedRewards();
	}
	
	private function SlotMemberStatusUpdated():Void
	{
		var bonusAlpha:Number = m_Completed || !m_Character.IsMember() ? COMPLETE_ALPHA : INCOMPLETE_ALPHA;
		if (m_BonusRewardsArray != undefined)
		{
			for (var i:Number = 0; i< m_BonusRewardsArray.length; i++)
			{
				m_BonusRewardsArray[i]._alpha = bonusAlpha;
			}
		}
		if (m_Description != undefined)
		{
			if (m_Character.IsMember())
			{
				m_Description.m_BonusXPText.textColor = 0xD3A308;
			}
			else
			{
				m_Description.m_BonusXPText.textColor = 0x666666;
			}
			m_Description.m_MemberIconXP._alpha = bonusAlpha;
		}
	}
	
	public function SetHittable(hittable:Boolean)
	{
		m_CanHit = hittable;
	}
	
	private function CheckUnclaimedRewards():Void
	{
		if (m_IntervalId != undefined)
		{
			clearInterval(m_IntervalId);
			m_IntervalId = undefined;
		}
		m_ClaimButton._visible = false;
		var rewardList:Array = Quests.GetAllChallengeRewards();
		for (var i:Number = 0; i < rewardList.length; i++ )
    	{
			if (rewardList[i].m_QuestTaskID == m_MissionInfo.m_CurrentTask.m_ID)
			{
				m_ClaimButton._visible = true;
				FixLayers();
			}
		}
	}
	
	private function FixLayers():Void
	{
		m_HitArea.swapDepths(this.getNextHighestDepth());
		if (m_RewardsArray != undefined)
		{
			for (var i:Number = 0; i< m_RewardsArray.length; i++)
			{
				m_RewardsArray[i].swapDepths(this.getNextHighestDepth());
			}
		}

		if (m_BonusRewardsArray != undefined)
		{
			for (var i:Number = 0; i< m_BonusRewardsArray.length; i++)
			{
				m_BonusRewardsArray[i].swapDepths(this.getNextHighestDepth());
			}
		}

		m_ClaimButton.swapDepths(this.getNextHighestDepth());
	}
	
	private function ClaimRewards():Void
	{
        Quests.AcceptQuestReward(m_MissionInfo.m_CurrentTask.m_ID, undefined);
		m_ClaimButton._visible = false;
		//If there was some failure in claiming rewards, get the reward button back!
		m_IntervalId = setInterval(Delegate.create(this, CheckUnclaimedRewards), 3000);
	}
	
	private function OpenShop():Void
	{
		DistributedValue.SetDValue("itemshop_window", true);
	}
}