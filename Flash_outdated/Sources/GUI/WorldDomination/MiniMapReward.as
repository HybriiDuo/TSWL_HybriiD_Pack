﻿//Imports
import com.GameInterface.Game.BuffData;
import com.GameInterface.Spell;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Utils.Format;
import com.Utils.ID32;
import com.Utils.LDBFormat;

//Class
class GUI.WorldDomination.MiniMapReward extends MovieClip
{
    //Get Support Buff Spell
    public static function GetCouncilSupportBuffSpellID(faction:Number):Number
    {
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        return 7964955;
            case _global.Enums.Factions.e_FactionTemplar:       return 7964956;
            case _global.Enums.Factions.e_FactionIlluminati:    return 7964957;
            
            default:                                            return 7968005;
        }
    }

    //Get Custodian Buff Spell
    public static function GetCustodianBuffSpellID(faction:Number):Number
    {
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        return 7964959;
            case _global.Enums.Factions.e_FactionTemplar:       return 7964960;
            case _global.Enums.Factions.e_FactionIlluminati:    return 7964961;
            
            default:                                            return 7967981;
        }
    }
    
    //Constants
    public static var BUFF:String = "buff";
    public static var TOKEN:String = "token";
	public static var MARK_OF_PANTHEON:Number = 9123478;
	public static var SHAMBALA_REWARD_CACHE:Number = 9211887;
    
    private static var FACTION_BUFF:String = LDBFormat.LDBGetText("WorldDominationGUI", "factionBuff");
	private static var PANTHEON_MARKS:String = LDBFormat.LDBGetText("WorldDominationGUI", "MarkOfThePantheon");
	private static var SHAMBALA_REWARD_CACHE_TEXT = LDBFormat.LDBGetText("WorldDominationGUI", "ShambalaRewardCache");
    private static var PVP_TOKEN:String = LDBFormat.LDBGetText("WorldDominationGUI", "pvpToken");
	private static var PVP_SPOILS:String = LDBFormat.LDBGetText("WorldDominationGUI", "pvpSpoils");
    
    //Properties
    private var m_Icon:MovieClip;
    private var m_Title:TextField;
    private var m_SubTitle:TextField;
    
    //Constructor
    public function MiniMapReward()
    {
        super();
    }
    
    //Set Reward
    public function SetReward(rewardType:String, rewardID:Number):Void
    {
        switch (rewardType)
        {
            case BUFF:      m_Icon = attachMovie("BuffComponent", "m_WorldDominationBuff", getNextHighestDepth());
                            m_Icon.SetBuffData(Spell.GetBuffData(rewardID));
                            m_Icon.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
                            
                            m_Title.text = m_Icon.GetBuffData().m_Name.toUpperCase();
                            m_SubTitle.text = FACTION_BUFF;
                            
                            m_Icon._y = 6;
                            m_Icon._xscale = m_Icon._yscale = 90;
        
                            break;
                            
            case TOKEN:     m_Icon = createEmptyMovieClip("m_Icon", getNextHighestDepth());
                            
                            var icon:ID32 = new ID32();
                            icon.SetType(1000624);
                            icon.SetInstance(rewardID);

                            var movieClipLoader:MovieClipLoader = new MovieClipLoader();
                            movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), m_Icon);
                            
							switch(rewardID)
							{
								case MARK_OF_PANTHEON:			m_Title.text = PANTHEON_MARKS;
																m_SubTitle.text = PVP_TOKEN;
																break;
								case SHAMBALA_REWARD_CACHE:		m_Title.text = SHAMBALA_REWARD_CACHE_TEXT;
																m_SubTitle.text = PVP_SPOILS;
																break;
							}
                            
                            m_Icon._x = -1;
                            m_Icon._y = 9;
                            m_Icon._xscale = m_Icon._yscale = 40;
        }
        

        //***** use this code below when the White and Black Mark of Venice rewards have a BuffID, which contain tooltip information
        //***** Rasmus is suppose to add this these buff ID.
        
        
        //switch (rewardType)
        //{
            //case BUFF:      m_Icon = attachMovie("BuffComponent", "m_WorldDominationBuff_" + rewardID, getNextHighestDepth());
                            //m_Icon.SetBuffData(Spell.GetBuffData(rewardID));
                            //m_Icon.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
                            //
                            //m_Title.text = m_Icon.GetBuffData().m_Name.toUpperCase();
                            //m_SubTitle.text = FACTION_BUFF;
                            //
                            //m_Icon._y = 6;
                            //m_Icon._xscale = m_Icon._yscale = 90;
        //
                            //break;
                            //
            //case TOKEN:     m_Icon = attachMovie("TokenComponent", "m_WorldDominationToken_" + rewardID, getNextHighestDepth());
                            //m_Icon.SetBuffData(Spell.GetBuffData(rewardID));
                            //m_Icon.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);                            
                            //
                            //m_Title.text = m_Icon.GetBuffData().m_Name.toUpperCase();
                            //m_SubTitle.text = PVP_TOKEN;
                            //
                            //m_Icon._x = -1;
                            //m_Icon._y = 9;
                            //m_Icon._xscale = m_Icon._yscale = 40;
        //}
    }
}