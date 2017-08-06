//Imports
import com.Utils.ID32;
import com.Utils.Format;
import com.GameInterface.Game.Character;

//Class
class GUI.PvPScoreboard.AnimaFragment extends MovieClip
{
    //Constants
    public static var MARK_OF_PANTHEON:String = "markOfThePantheon";
    
    //Properties
    private var m_IconContainer:MovieClip;
    private var m_Label:TextField;

    //Constructor
    public function AnimaFragment()
    {
        super();
        
        m_Label.autoSize = "left";
    }
    
    //Set Reward
    public function SetReward(rewardType:String, rewardAmount:String):Void
    {
        m_IconContainer = createEmptyMovieClip("m_IconContainer", getNextHighestDepth());
        
        if (rewardType == MARK_OF_PANTHEON)
        {
            AttachAnimaFragmentIcon(9123478); //Mark of the Pantheon
            m_Label._x -= 2;
        }
        
        m_Label.text = rewardAmount;
    }
    
    //Attach Anima Fragment Icon
    public function AttachAnimaFragmentIcon(RDBInstance:Number):Void
    {
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        icon.SetInstance(RDBInstance);

        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), m_IconContainer);
		
        if (RDBInstance == 9219163)
		{
			m_IconContainer._xscale = m_IconContainer._yscale = 100;
		}
		else
		{
        	m_IconContainer._xscale = m_IconContainer._yscale = 28;
		}
        m_IconContainer._y = 1;
    }
}