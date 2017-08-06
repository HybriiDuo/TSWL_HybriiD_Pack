import flash.geom.Point;
import flash.geom.Rectangle;
import com.Utils.LDBFormat;
import com.Utils.ID32;

import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.GameInterface.ProjectUtils;
import com.Utils.Faction;
import com.GameInterface.Lore;
import com.GameInterface.LoreBase;
import com.GameInterface.LoreNode;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Quests;
import com.GameInterface.QuestsBase;

import gfx.utils.Delegate;
import gfx.core.UIComponent;
import gfx.motion.Tween; 
import mx.transitions.easing.*;

import gfx.controls.Button;
import gfx.controls.UILoader;
import gfx.controls.ProgressBar;
import gfx.controls.Label;


class GUI.CharacterSheet.FactionRankComponent extends UIComponent
{
    //Constants
    private static var BATTLE_RANK_ICON_ID:Number = 8141020;
    
    public var m_CloseButton:MovieClip;
    
    private var m_Character:Character;
    
    private var m_Background:MovieClip;
	private var m_Header:TextField;
    
	private var m_CurrentRankIcon:UILoader;
	private var m_CurrentRankName:TextField;
	private var m_CurrentRankNumber:TextField;
	private var m_CurrentFactionXP:TextField;
	private var m_FactionRankRewardIcon:MovieClip;
	private var m_NextRankView:MovieClip;
	
	private var m_CurrentXPValue:Number;
	private var m_TotalXPValue:Number;
	private var m_NextRankRequiredXPValue:Number;
	private var m_FactionRankProgressBar:ProgressBar;	
	
    private var m_Padding:Number = 7;
    private var m_Width:Number;
    private var m_Height:Number;
    
    private var m_BattleRankIcon:UILoader;
    private var m_BattleRankTextField:TextField;
    private var m_BattleXPTextField:TextField;
    private var m_BattleRankProgressBar:ProgressBar;
	
    public function FactionRankComponent() 
    {
        super();
        
        m_Width = this._width;
        m_Height = this._height;
    }
    
    public function configUI()
    {
        super.configUI();
        
        m_Header.text = LDBFormat.LDBGetText("GenericGUI", "FactionBattleRankTitle");
        
        m_Character = Character.GetClientCharacter();
        m_Character.SignalStatChanged.Connect(SetData, this);
        
        ActivateRewardTooltip(m_FactionRankRewardIcon);
        
		SetData();
    }
    
    private function RemoveFocus()
    {
        Selection.setFocus(null);
    }
    
    private function SetData()
    {
        var currentTag:LoreNode = Lore.GetCurrentFactionRankNode();
        var nextTag:LoreNode = Lore.GetNextFactionRankNode();
        var currentRankNumber:Number = Lore.GetRank(currentTag.m_Id);
        
        // current rank data
		m_CurrentRankIcon.source = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + currentTag.m_Icon;
		m_CurrentRankName.htmlText = "<font color='#FF4400'>" + currentTag.m_Name + "</font>";
		m_CurrentRankNumber.htmlText = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "FactionAndRank"), Faction.GetName(m_Character.GetStat( _global.Enums.Stat.e_PlayerFaction ), false), currentRankNumber);
		
        if ( nextTag == undefined )
		{
            // we've reached the end! (for now)
            m_NextRankView.gotoAndStop("MaxRankView");
            m_NextRankView.m_TopRankHeader.text = LDBFormat.LDBGetText("MiscGUI", "MaximumRankReached");
            m_NextRankView.m_TopRankInfoText.text = LDBFormat.LDBGetText("MiscGUI", "MaximumRankReachedDescription");
        }
        else
        {
            // there's a next rank!
            m_NextRankView.gotoAndStop("NextRankView");
            
            // progress bar
            var lastXP:Number = Lore.GetCounterTargetValue(currentTag.m_Id);
            var currentXP:Number = Lore.GetCounterCurrentValue(nextTag.m_Id) - lastXP;
            var requiredXP:Number = Lore.GetCounterTargetValue(nextTag.m_Id) - lastXP;
            
            if (currentXP > requiredXP)
            {
                currentXP = requiredXP;
            }
            
            m_FactionRankProgressBar.minimum = 0;
            m_FactionRankProgressBar.maximum = requiredXP;
            m_FactionRankProgressBar.value = currentXP;
            m_CurrentFactionXP.htmlText = currentXP + " / " + requiredXP + " " + LDBFormat.LDBGetText("MiscGUI", "xp");
            
            // next rank data
            m_NextRankView.m_NextRankIcon.source = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + nextTag.m_Icon;
            m_NextRankView.m_NextRankLabel.text = LDBFormat.LDBGetText("MiscGUI", "NextRank");
            m_NextRankView.m_NextRankName.htmlText = nextTag.m_Name;
            
            // schmancy dynamic requirements list
            var requirements:Array = new Array();
            
            // required xp
            if (requiredXP > 0)
            {
                requirements.push( { label:LDBFormat.LDBGetText("MiscGUI", "XpRequired"), data:requiredXP + " " + LDBFormat.LDBGetText("MiscGUI", "xp"), completed:(currentXP==requiredXP) } );
            }
            
            // required quests
            var requiredQuest:Number = LoreBase.GetRequiredQuest(nextTag.m_Id);
            if (requiredQuest != 0)
            {
                var quest:com.GameInterface.Quest = Quests.GetQuest( requiredQuest, true, false );
                if (quest != undefined)
                {
                    requirements.push( { label:LDBFormat.LDBGetText("MiscGUI", "MissionRequired"), data:quest.m_MissionName, completed:quest.m_HasCompleted } );
                }
            }
            
            // rewards
            var rewardNameArray:Array = Lore.GetRewardItemNameArray(nextTag.m_Id);
            for (var i:Number = 0; i < rewardNameArray.length; i++)
            {
                requirements.push( { label:LDBFormat.LDBGetText("MiscGUI", "Reward"), data:rewardNameArray[i], completed:false } );
            }
            
            // set the data
            m_NextRankView.m_RequirementsList.addEventListener("focusIn", this, "RemoveFocus");
            m_NextRankView.m_RequirementsList.dataProvider = requirements;
        }
		// battle rank
		var currentBattleXP:Number = m_Character.GetStat(_global.Enums.Stat.e_PvPXP);
		var maxBattleXP:Number = (ProjectUtils.GetUint32TweakValue("PvPXPPerChunk") * ProjectUtils.GetUint32TweakValue("PvPXPChunksPerRank"));
		
		m_BattleRankIcon.source = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + BATTLE_RANK_ICON_ID;
		m_BattleRankTextField.text = LDBFormat.LDBGetText("GenericGUI", "BattleRankTitle") + " " + m_Character.GetStat(_global.Enums.Stat.e_PvPLevel);
		m_BattleXPTextField.text = currentBattleXP + " / " + maxBattleXP + " " + LDBFormat.LDBGetText("GenericGUI", "BattleXPTitle");
	
		m_BattleRankProgressBar.minimum = 0;
		m_BattleRankProgressBar.maximum = maxBattleXP;
		m_BattleRankProgressBar.value = currentBattleXP;
    }   

    private function ActivateRewardTooltip(icon:MovieClip)
    {
		var text:String = "<b>" + LDBFormat.LDBGetText("MiscGUI", "CumulatedRewards") + "</b><br>";
        var factionRankArray:Array = Lore.GetFactionRankArray(true);
        
        for (var i:Number = 0; i < factionRankArray.length; i++)
        {
            var node:LoreNode = Lore.GetDataNodeById(factionRankArray[i].id);
            
            if (!node.m_Locked)
            {
                var rewardNameArray:Array = Lore.GetRewardItemNameArray(node.m_Id);
                
                for (var j:Number = 0; j < rewardNameArray.length; j++)
                {
                    text += "<br>" + LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "FactionRewardRank"), Lore.GetRank(node.m_Id)) + "&nbsp;-&nbsp;" + rewardNameArray[j];
                }
            }
        }
        
		TooltipUtils.AddTextTooltip( icon, " " + text, 250, TooltipInterface.e_OrientationHorizontal,  true);
    }
    
    public function GetWidth():Number
    {
        return m_Width;
    }
    
    public function GetHeight():Number
    {
        return m_Height;
    }
}