﻿//Imports
import com.Utils.LDBFormat;
import com.Utils.Faction;
import flash.geom.Matrix;
import GUI.PvPScoreboard.PvPScoreboardColors;
import com.GameInterface.PvPScoreboard;

//Class
class GUI.PvPScoreboard.Header extends MovieClip
{
    //Constants
    public static var DRAGON_FONT:String = "_StandardFont";
    public static var TEMPLARS_FONT:String = "_StandardFont";
    public static var ILLUMINATI_FONT:String = "_StandardFont";
    public static var STANDARD_FONT:String = "_StandardFont";
	
	private static var EL_DORADO_ID:Number = 5820;
    private static var STONEHENGE_ID:Number = 5840;
	private static var SHAMBALA_ID:Number = 5830;
    
    private static var WINNING_FACTION:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_winningFaction");
	private static var WINNING_SQUAD:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_winningSquad");
    private static var TIED_SCORE:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_tiedScore");
    
    private static var BACKGROUND_WIDTH:Number = 1106;
    private static var BACKGROUND_HEIGHT:Number = 72;
        
    private static var WINNER_IS_FONT_SIZE:Number = 18;
    private static var FACTION_FONT_SIZE:Number = 38;
    private static var FACTION_LABEL_Y:Number = 20;
    
    private static var LABEL_COLOR:Number = 0xFFFFFF;
    private static var LABEL_X:Number = 10;
    private static var WINNER_IS_LABEL_Y = 4;
    private static var TIED_IS_LABEL_Y = 23;
    private static var FACTION_SCORE_GAP:Number = 12;

    //Properties
    private var m_BackgroundGradient:MovieClip;
    private var m_BackgroundAnimationsContainer:MovieClip;
    private var m_AnimationLoader:MovieClip;
    private var m_AnimationMask:MovieClip;
	private var m_TiedScore:TextField;
    private var m_WinnerIsLabel:TextField;
    private var m_FactionLabel:TextField;
    private var m_FactionScore_1:MovieClip;
    private var m_FactionScore_2:MovieClip;
    private var m_FactionScore_3:MovieClip;
    
    private var m_Color:Number;
    
    //Constructor
    public function Header()
    {
        super();
    }

    //Set Results
    public function SetResults(factionPlacement:Array, factionScores:Array):Void
    {
		if (m_BackgroundGradient != undefined)
		{
			m_BackgroundGradient.removeMovieClip();
		}
        m_BackgroundGradient = createEmptyMovieClip("m_BackgroundGradient", getNextHighestDepth());
        
		if (m_BackgroundAnimationsContainer != undefined)
		{
			m_BackgroundAnimationsContainer.removeMovieClip();
		}
        m_BackgroundAnimationsContainer = createEmptyMovieClip("m_BackgroundAnimationsContainer", getNextHighestDepth());
        
		if (m_TiedScore != undefined)
		{
			m_TiedScore.removeTextField();
		}
		if (m_WinnerIsLabel != undefined)
		{
			m_WinnerIsLabel.removeTextField();
		}
		if (m_FactionLabel != undefined)
		{
			m_FactionLabel.removeTextField();
		}
        if ( PvPScoreboard.m_MatchResult == _global.Enums.PvPMatchResult.e_MinigameDraw || 
             PvPScoreboard.m_WinnerSide == _global.Enums.PvPMatchMakingSide.e_PvPSideInvalid )
        {
            CreateBackground(0x565656);
            
            m_TiedScore = createTextField("m_TiedScore", getNextHighestDepth(), LABEL_X, TIED_IS_LABEL_Y, 0, 0);
            m_TiedScore.autoSize = "left";
            m_TiedScore.text = TIED_SCORE;
            m_TiedScore.setTextFormat(new TextFormat(STANDARD_FONT, WINNER_IS_FONT_SIZE, LABEL_COLOR));
        }
        else
        {
            m_WinnerIsLabel = createTextField("m_WinnerIsLabel", getNextHighestDepth(), LABEL_X, WINNER_IS_LABEL_Y, 0, 0);
            m_WinnerIsLabel.autoSize = "left";
            m_WinnerIsLabel.text = PvPScoreboard.m_PlayfieldID == SHAMBALA_ID ? WINNING_SQUAD : WINNING_FACTION;
            m_WinnerIsLabel.setTextFormat(new TextFormat(STANDARD_FONT, WINNER_IS_FONT_SIZE, LABEL_COLOR));
            
            m_FactionLabel = createTextField("m_FactionLabel", getNextHighestDepth(), LABEL_X, 0, 0, 0);
            m_FactionLabel.autoSize = "left";
            m_FactionLabel.textColor = LABEL_COLOR;
        
            var textFormat:TextFormat = m_FactionLabel.getTextFormat();
            
			var faction1Color:Number = PvPScoreboardColors.DRAGON_BRIGHT_COLOR;
			var faction2Color:Number = PvPScoreboardColors.TEMPLARS_BRIGHT_COLOR;
			var faction3Color:Number = PvPScoreboardColors.ILLUMINATI_BRIGHT_COLOR
			var winnerName:String = Faction.GetName(factionPlacement[0]);
			
			if (PvPScoreboard.m_PlayfieldID == SHAMBALA_ID)
			{
				var faction1Color:Number = PvPScoreboardColors.PURPLE_BRIGHT_COLOR;
				var faction2Color:Number = PvPScoreboardColors.YELLOW_BRIGHT_COLOR;
				if (factionPlacement[0] == _global.Enums.Factions.e_FactionDragon)
				{
					winnerName = LDBFormat.LDBGetText("WorldDominationGUI", "MoonSquad");
				}
				else
				{
					winnerName = LDBFormat.LDBGetText("WorldDominationGUI", "SunSquad");
				}
			}
			
            switch (factionPlacement[0])
            {
                case _global.Enums.Factions.e_FactionDragon:        m_FactionLabel._y = FACTION_LABEL_Y;
                                                                    textFormat.font = DRAGON_FONT;
                                                                    textFormat.size = FACTION_FONT_SIZE;
                                                                    textFormat.bold = true;
                                                                    CreateBackground(faction1Color);
                                                                    break;
                                                                    
                case _global.Enums.Factions.e_FactionTemplar:       m_FactionLabel._y = FACTION_LABEL_Y;
                                                                    textFormat.font = TEMPLARS_FONT;
                                                                    textFormat.size = FACTION_FONT_SIZE;
                                                                    textFormat.bold = true;
                                                                    CreateBackground(faction2Color);
                                                                    break;
                                                                    
                case _global.Enums.Factions.e_FactionIlluminati:    m_FactionLabel._y = FACTION_LABEL_Y;
                                                                    textFormat.font = ILLUMINATI_FONT;
                                                                    textFormat.size = FACTION_FONT_SIZE;
                                                                    textFormat.bold = true;
                                                                    CreateBackground(faction3Color);
            }
            
            m_FactionLabel.text = winnerName;
            m_FactionLabel.setTextFormat(textFormat);
        }
        
		if (m_FactionScore_3 != undefined)
		{
			m_FactionScore_3.removeMovieClip();
		}
		if (m_FactionScore_2 != undefined)
		{
			m_FactionScore_2.removeMovieClip();
		}
		if (m_FactionScore_1 != undefined)
		{
			m_FactionScore_1.removeMovieClip();
		}
		
		var xLoc:Number = m_BackgroundGradient._width;
		if (factionPlacement[2] != undefined)
		{
			m_FactionScore_3 = attachMovie("FactionScore", "m_FactionScore_3", getNextHighestDepth(), {m_Faction: factionPlacement[2], m_Score: factionScores[2]});
			m_FactionScore_3._x = xLoc - m_FactionScore_3._width - FACTION_SCORE_GAP;
			m_FactionScore_3._y = m_BackgroundGradient._height - m_FactionScore_3._height >> 1;
			xLoc = m_FactionScore_3._x;
		}
        
		if (factionPlacement[1] != undefined)
		{
			m_FactionScore_2 = attachMovie("FactionScore", "m_FactionScore_2", getNextHighestDepth(), {m_Faction: factionPlacement[1], m_Score: factionScores[1]});
			m_FactionScore_2._x = xLoc - m_FactionScore_2._width - FACTION_SCORE_GAP;
			m_FactionScore_2._y = m_BackgroundGradient._height - m_FactionScore_2._height >> 1;
			xLoc = m_FactionScore_2._x;
		}
        
        m_FactionScore_1 = attachMovie("FactionScore", "m_FactionScore_1", getNextHighestDepth(), {m_Faction: factionPlacement[0], m_Score: factionScores[0]});
        m_FactionScore_1._x = xLoc - m_FactionScore_1._width - FACTION_SCORE_GAP;
        m_FactionScore_1._y = m_BackgroundGradient._height - m_FactionScore_1._height >> 1;
		
		InitHeaderAnimation();
    }
    
    //Create Background Gradient
    private function CreateBackground(color:Number):Void
    {
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
        
        m_BackgroundGradient.clear();
        m_BackgroundGradient.beginGradientFill("liniar", [color, color], [100, 0], [0, 180], matrix);
        m_BackgroundGradient.moveTo(0, 0);
        m_BackgroundGradient.lineTo(BACKGROUND_WIDTH, 0);
        m_BackgroundGradient.lineTo(BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
        m_BackgroundGradient.lineTo(0, BACKGROUND_HEIGHT);
        m_BackgroundGradient.lineTo(0, 0);
        m_BackgroundGradient.endFill();
        
        m_Color = color;
    }
    
    //Initialize Header Animation
    private function InitHeaderAnimation():Void
    {
		if (m_AnimationLoader == undefined)
		{
        	var m_AnimationLoader:MovieClipLoader = new MovieClipLoader();
			m_AnimationLoader.addListener(this);
		}
        m_AnimationLoader.loadClip("PvPScoreboardHeaderAnimation.swf", m_BackgroundAnimationsContainer);
        
		if (m_AnimationMask != undefined)
		{
			m_AnimationMask.removeMovieClip();
		}
        m_AnimationMask = createEmptyMovieClip("animationMask", getNextHighestDepth());
        m_AnimationMask.beginFill(0xFF0000, 0);
        m_AnimationMask.moveTo(0, 0);
        m_AnimationMask.lineTo(BACKGROUND_WIDTH, 0);
        m_AnimationMask.lineTo(BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
        m_AnimationMask.lineTo(0, BACKGROUND_HEIGHT);
        m_AnimationMask.lineTo(0, 0);
        m_AnimationMask.endFill();
    }
    
    //On Load Complete
    private function onLoadComplete(target:MovieClip):Void
    {
		target.m_DragonIcon._visible = (m_Color == PvPScoreboardColors.DRAGON_BRIGHT_COLOR) ? true : false;
		target.m_TemplarsIcon._visible = (m_Color == PvPScoreboardColors.TEMPLARS_BRIGHT_COLOR) ? true : false;
		target.m_IlluminatiIcon._visible = (m_Color == PvPScoreboardColors.ILLUMINATI_BRIGHT_COLOR) ? true : false;
		target.m_SunIcon._visible = (m_Color == PvPScoreboardColors.YELLOW_BRIGHT_COLOR) ? true : false;
		target.m_MoonIcon._visible = (m_Color == PvPScoreboardColors.PURPLE_BRIGHT_COLOR) ? true : false;
		m_BackgroundAnimationsContainer.setMask(m_AnimationMask);
    }
}