//Imports
import com.Components.WindowComponentContent;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.Game.Character;
import com.GameInterface.PvPScoreboard;
import com.GameInterface.ProjectUtils;
import com.GameInterface.ScryWidgets;
import com.GameInterface.GUIModuleIF;
import flash.geom.Point;

//Class
class GUI.PvPScoreboard.PvPScoreboardContent extends WindowComponentContent
{
    //Constants
    public static var RDB_DRAGON_ICON:Number = 7469011;
    public static var RDB_TEMPLARS_ICON:Number = 7469013;
    public static var RDB_ILLUMINATI_ICON:Number = 7469012;
	public static var RDB_MOON_ICON:Number = 9211777;
	public static var RDB_SUN_ICON:Number = 9211776;
    
    private static var EL_DORADO_ID:Number = 5820;
    private static var STONEHENGE_ID:Number = 5840;
	private static var SHAMBALA_ID:Number = 5830;
        
    //Properties
    private var m_Character:Character;
    private var m_ContentCanvas:MovieClip;
    private var m_Header:MovieClip;
    private var m_Table:MovieClip;
    private var m_Footer:MovieClip;
    private var m_FactionPlacement:Array;
    private var m_FactionScores:Array;
    
    //Constructor
    public function PvPScoreboardContent()
    {
        super();
    }
    
    //On Load
    private function onLoad():Void
    {
		RefreshData();
		ScryWidgets.SignalScryMessage.Connect(SlotScryMessage, this); //Scry will tell us what the rewards are!
        m_Footer.SignalSortTypeSelected.Connect(SlotSortTypeSelected, this);
		PvPScoreboard.SignalScoreboardUpdated.Connect(RefreshData, this);
    }
	
	private function RefreshData():Void
	{
		m_Character = Character.GetClientCharacter();
        m_MatchPlayfieldID = PvPScoreboard.m_PlayfieldID;
		m_Footer.RefreshData();
		var scoreBoardArray:Array = new Array();
			
		if (m_MatchPlayfieldID == SHAMBALA_ID)
		{
			scoreBoardArray.push( { faction: _global.Enums.Factions.e_FactionDragon,     wins: PvPMinigame.GetSideScore(_global.Enums.Factions.e_FactionDragon, 0) } );
			scoreBoardArray.push( { faction: _global.Enums.Factions.e_FactionTemplar,    wins: PvPMinigame.GetSideScore(_global.Enums.Factions.e_FactionTemplar, 0) } );
		}
		else
		{
			scoreBoardArray.push( { faction: _global.Enums.Factions.e_FactionDragon,     wins: PvPMinigame.GetSideScore(_global.Enums.Factions.e_FactionDragon, 0) } );
			scoreBoardArray.push( { faction: _global.Enums.Factions.e_FactionTemplar,    wins: PvPMinigame.GetSideScore(_global.Enums.Factions.e_FactionTemplar, 0) } );
			scoreBoardArray.push( { faction: _global.Enums.Factions.e_FactionIlluminati, wins: PvPMinigame.GetSideScore(_global.Enums.Factions.e_FactionIlluminati, 0) } );
		}
        
        scoreBoardArray.sortOn("wins", Array.DESCENDING | Array.NUMERIC);

                
        if ( PvPScoreboard.m_MatchResult != _global.Enums.PvPMatchResult.e_MinigameNoResult )
        {        
            var winnerFaction:Number = GetFactionFromColor(PvPScoreboard.m_WinnerSide);
            var arraySize:Number = scoreBoardArray.length;
            
            for (var i:Number = 0; i < arraySize; ++i )
            {
                if (winnerFaction != -1 && scoreBoardArray[i].faction == winnerFaction)
                {
                    var winner:Array = scoreBoardArray.splice(i, 1);
                    scoreBoardArray = winner.concat(scoreBoardArray);
                    break;
                }
            }
        }        
        
        
        m_FactionPlacement = new Array();
		for (var i:Number=0; i<scoreBoardArray.length; i++)
		{
			m_FactionPlacement.push(scoreBoardArray[i].faction);
		}
        
        m_FactionScores = new Array();
		for (var i:Number=0; i<scoreBoardArray.length; i++)
		{
			m_FactionScores.push(scoreBoardArray[i].wins);
		}
        
        m_Header.SetResults(m_FactionPlacement, m_FactionScores);
        
        m_Table.SetTable(m_FactionPlacement, m_Character);
	}
	
	function SlotScryMessage(messageArray:Array):Void
	{
		var messageType = messageArray.messageType;
		switch( messageType )
		{
			case "PvPScoreboard_SetRewards":
				m_Footer.SetRewards(Number(messageArray.majorReward), Number(messageArray.minorReward), Number(messageArray.gameModifier));
				break;
			default:
		}
	}

    
    //@Warning This match between enums is INTENTIONALLY WRONG. Done to fix a problem with the data sent by PvPMatchMaking::SignalPvPMatchMakingMatchEnded
    //It's very difficult to fix that in the gamecode right now, so this temporary HACK will be here until http://jira.funcom.com/browse/TSW-94901 is done
    private function GetFactionFromColor(colorEnum:Number):Number
    {
        switch(colorEnum)
        {
            case _global.Enums.PvPMatchMakingSide.e_PvPSideRed: return _global.Enums.Factions.e_FactionDragon;
            case _global.Enums.PvPMatchMakingSide.e_PvPSideBlue: return _global.Enums.Factions.e_FactionTemplar;
            case _global.Enums.PvPMatchMakingSide.e_PvPSideGreen: return _global.Enums.Factions.e_FactionIlluminati;
        }
        return -1;
    }
    
    //Slot Sort Type Selected
    private function SlotSortTypeSelected(sortType:String):Void
    {
        m_Table.SlotSortRows(undefined, sortType);
    }
}
