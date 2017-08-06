//Imports
import com.Utils.Colors;
import com.Utils.ID32;
import com.Utils.Format;
import GUI.PvPScoreboard.PvPScoreboardColors;
import GUI.PvPScoreboard.PvPScoreboardContent;
import com.GameInterface.PvPScoreboard;

//Class
class GUI.PvPScoreboard.FactionScore extends MovieClip
{
    //Properties
    public var m_Faction:Number;
    public var m_Score:String;

    private var m_Label:TextField
    private var m_FactionIconContainer:MovieClip;
    private var m_Background:MovieClip;
	
	private static var EL_DORADO_ID:Number = 5820;
    private static var STONEHENGE_ID:Number = 5840;
	private static var SHAMBALA_ID:Number = 5830;
   
    //Constructor
    public function FactionScore()
    {
        super();
        
        SetFactionAndScore(m_Faction, m_Score);
    }
    
    //Set Faction And Score
    private function SetFactionAndScore(faction:Number, score:String):Void
    {
        m_FactionIconContainer = createEmptyMovieClip("m_FactionIconContainer", getNextHighestDepth());
        
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        
		if (PvPScoreboard.m_PlayfieldID == SHAMBALA_ID)
		{
			this._visible = false;

		}
		else
		{
			switch (faction)
			{
				case _global.Enums.Factions.e_FactionDragon:        icon.SetInstance(PvPScoreboardContent.RDB_DRAGON_ICON);
																	Colors.ApplyColor(m_Background, PvPScoreboardColors.DRAGON_BRIGHT_COLOR);
																	break;
																	
				case _global.Enums.Factions.e_FactionTemplar:       icon.SetInstance(PvPScoreboardContent.RDB_TEMPLARS_ICON);
																	Colors.ApplyColor(m_Background, PvPScoreboardColors.TEMPLARS_BRIGHT_COLOR);
																	break;
																	
				case _global.Enums.Factions.e_FactionIlluminati:    icon.SetInstance(PvPScoreboardContent.RDB_ILLUMINATI_ICON);
																	Colors.ApplyColor(m_Background, PvPScoreboardColors.ILLUMINATI_BRIGHT_COLOR);
			}
		}
        
		if (icon != undefined)
		{
			var movieClipLoader:MovieClipLoader = new MovieClipLoader();
			movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), m_FactionIconContainer);
		}
        
        m_FactionIconContainer._xscale = m_FactionIconContainer._yscale = 24;
        
        m_Label.text = score;
    }
}