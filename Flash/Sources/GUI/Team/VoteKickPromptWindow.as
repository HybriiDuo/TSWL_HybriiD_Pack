//Imports
import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.GameInterface.Game.TeamInterface;

//Class
class GUI.Team.VoteKickPromptWindow extends MovieClip
{
    //Constants
    
    //Properties
	private var m_HeaderLabel:TextField;
	private var m_DescriptionLabel:TextField;
	private var m_OfflineButton:MovieClip;
	private var m_AFKButton:MovieClip;
	private var m_HarassmentButton:MovieClip;
	private var m_WarningLabel:TextField;
	private var m_ConfirmButton:MovieClip;
	private var m_CancelButton:MovieClip;
	
	//Variables
	private var m_TargetID:ID32;
	private var m_TargetName:String;
    
    //Constructor
    public function VoteKickPromptWindow()
    {
        super();
    }
    
    //On Load
    public function onLoad():Void
    {		
		m_HeaderLabel.text = LDBFormat.LDBGetText("TeamGUI", "VoteKickReasonPromptHeader");
		
		if (m_TargetName != undefined)
		{
        	m_DescriptionLabel.text = LDBFormat.Printf(LDBFormat.LDBGetText("TeamGUI", "VoteKickReasonPromptDescription"), m_TargetName);
		}
		
		m_OfflineButton.textField.autoSize = "left";
		m_OfflineButton.group = "RadioGroup";
		m_OfflineButton.label = LDBFormat.LDBGetText("Gamecode", "VoteKickReasonOffline");
		m_OfflineButton.selected = true;		
		m_OfflineButton.addEventListener("click", this, "RadioButtonClickEventHandler");
		
		m_AFKButton.textField.autoSize = "left";
		m_AFKButton.group = "RadioGroup";
		m_AFKButton.label = LDBFormat.LDBGetText("Gamecode", "VoteKickReasonAFK");
		m_AFKButton.selected = false;
		m_AFKButton.addEventListener("click", this, "RadioButtonClickEventHandler");
		
		m_HarassmentButton.textField.autoSize = "left";
		m_HarassmentButton.group = "RadioGroup";
		m_HarassmentButton.label = LDBFormat.LDBGetText("Gamecode", "VoteKickReasonHarassment");
		m_HarassmentButton.selected = false;		
		m_HarassmentButton.addEventListener("click", this, "RadioButtonClickEventHandler");
		
		m_WarningLabel.text = LDBFormat.LDBGetText("TeamGUI", "VoteKickWarningLabel");
		
		m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "Confirm");
		m_ConfirmButton.addEventListener("click", this, "ConfirmEventHandler");
		m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
		m_CancelButton.addEventListener("click", this, "CancelEventHandler");
		
		Position();
    }
	
	private function SetTarget(targetID:ID32, targetName:String):Void
	{
		m_TargetID = targetID;
		m_TargetName = targetName;
		m_DescriptionLabel.text = LDBFormat.Printf(LDBFormat.LDBGetText("TeamGUI", "VoteKickReasonPromptDescription"), m_TargetName);
	}
    
    //Position
    private function Position():Void
    {
        var visibleRect = Stage["visibleRect"];

        this._x = (visibleRect.width / 2) - (this._width / 2);
        this._y = (visibleRect.height / 2) - (this._height / 2);
    }
	
	private function RadioButtonClickEventHandler():Void
	{
		Selection.setFocus(null);
	}
	
	private function ConfirmEventHandler():Void
	{
		//DON'T LET THIS HAPPEN WITHOUT A VALID ID
		if (m_TargetID != undefined)
		{
			var reason:String = ""
			if (m_OfflineButton.selected){ reason = "VoteKickReasonOffline"; }
			else if (m_AFKButton.selected){ reason = "VoteKickReasonAFK"; }
			else if (m_HarassmentButton.selected){ reason = "VoteKickReasonHarassment"; }
			else { return; } //DON'T DO THIS WITHOUT A REASON!
			TeamInterface.StartVoteKick( m_TargetID, reason );
			this.removeMovieClip();
		}
	}
	
	private function CancelEventHandler():Void
	{
		this.removeMovieClip();
	}
}