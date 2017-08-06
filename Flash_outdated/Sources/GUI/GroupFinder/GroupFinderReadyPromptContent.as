import com.Components.WindowComponentContent;
import com.GameInterface.GroupFinder;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
import gfx.controls.Button;

class GUI.GroupFinder.GroupFinderReadyPromptContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_AcceptButton:Button;
	private var m_CancelButton:Button;
	private var m_DPSIcon:MovieClip;
	private var m_TankIcon:MovieClip;
	private var m_HealIcon:MovieClip;
	private var m_NoRoleIcon:MovieClip;
	private var m_MainText:TextField;
	private var m_TimerText:TextField;
	private var m_RoleLabel:TextField;
	private var m_QueueLabel:TextField;
	private var m_ReadyText:TextField;

	//Variables
	private var m_TimerInterval:Number;
	private var m_SecondsRemaining:Number;
	private var m_HasAnswered:Boolean;

	//Statics
	private static var TIMER_TEXT:String = LDBFormat.LDBGetText("GroupSearchGUI", "GroupFinderReadyTimer");
	//TODO: Maybe get this from the server to avoid a desync? It probably doesn't matter much.
	private static var TIMEOUT:Number = 60;
	
	public function GroupFinderReadyPromptContent()
	{
		super();
	}
	
	private function configUI():Void
	{
		//If we aren't signed up, close immediately.
		if (!GroupFinder.IsClientSignedUp())
		{
			this._parent._parent.CloseWindowHandler();
		}
		m_HasAnswered = false;
		m_ReadyText._visible = false;
		m_AcceptButton.addEventListener("click", this, "AcceptClickHandler");
		m_AcceptButton.disableFocus = true;
		m_CancelButton.addEventListener("click", this, "CancelClickHandler");
		m_CancelButton.disableFocus = true;
		
		GroupFinder.SignalClientStartedGroupFinderActivity.Connect(Close, this);
		GroupFinder.SignalClientLeftGroupFinder.Connect(Close, this);
		GroupFinder.SignalClientJoinedGroupFinder.Connect(Close, this);
		GroupFinder.SignalGroupFinderReadyFailed.Connect(Close, this);
		GroupFinder.SignalGroupFinderMemberReady.Connect(UpdateReadyCount, this);
		
		SetLabels();
		SetInfo();
	}
	
	private function SetLabels():Void
	{
		m_MainText.text = LDBFormat.LDBGetText("GroupSearchGUI", "GroupFinderReadyPromptHeader");
		m_AcceptButton.label = LDBFormat.LDBGetText("GenericGUI", "Accept");
		m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
	}
	
	private function SetInfo():Void
	{
		m_DPSIcon._visible = false;
		m_TankIcon._visible = false;
		m_HealIcon._visible = false;
		m_NoRoleIcon._visible = false;
		m_RoleLabel.text = "";
		
		switch(GroupFinder.GetActiveRole())
		{
			case _global.Enums.LFGRoles.e_RoleDamage:
				m_DPSIcon._visible = true;
				m_RoleLabel.text = LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonLabel");
				break;
			case _global.Enums.LFGRoles.e_RoleTank:
				m_TankIcon._visible = true;
				m_RoleLabel.text = LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonLabel");
				break;
			case _global.Enums.LFGRoles.e_RoleHeal:
				m_HealIcon._visible = true;
				m_RoleLabel.text = LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonLabel");
				break;
			default:
				m_NoRoleIcon._visible = true;
		}
		
		m_QueueLabel.text = LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_" + GroupFinder.GetActiveQueue());
		
		m_SecondsRemaining = TIMEOUT;
		UpdateTimer();
		m_TimerInterval = setInterval( Delegate.create( this, UpdateTimer ), 1000 );
	}
	
	private function UpdateTimer():Void
	{
		m_SecondsRemaining -= 1;
		m_TimerText.text = TIMER_TEXT + " " + secondsToTimeString(m_SecondsRemaining);
		if (m_SecondsRemaining <= 0)
		{
			if (m_TimerInterval != undefined)
			{
				clearInterval(m_TimerInterval);
				m_TimerInterval = undefined;
			}
			Close();
		}
	}
	
	private function secondsToTimeString(seconds:Number):String
	{
		var h:Number=Math.floor(seconds/3600);
		var m:Number=Math.floor((seconds%3600)/60);
		var s:Number=Math.floor((seconds%3600)%60);
		var hStr:String = h == 0 ? "" : (h < 10 ? "0" + h.toString() + ":" : h.toString() + ":")
		var mStr:String = (m < 10 ? "0" + m.toString() : m.toString()) + ":";
		var sStr:String = s < 10 ? "0" + s.toString() : s.toString();
		return (hStr + mStr + sStr);
	}
	
	private function UpdateReadyCount(readyCount:Number, totalCount:Number)
	{
		if (totalCount > 0)
		{
			m_ReadyText._visible = true;
		}
		m_ReadyText.text = readyCount + "/" + totalCount + " " + LDBFormat.LDBGetText("GroupSearchGUI", "MembersReady");	
	}
	
	private function AcceptClickHandler():Void
	{
		GroupFinder.SendReady(true, false);
		m_HasAnswered = true;
		m_AcceptButton.disabled = true;
		m_CancelButton.disabled = true;
	}
	
	private function CancelClickHandler():Void
	{
		GroupFinder.SendReady(false, false);
		m_HasAnswered = true;
		m_AcceptButton.disabled = true;
		m_CancelButton.disabled = true;
	}
	
	private function Close():Void
	{
		if (m_TimerInterval != undefined)
		{
			clearInterval(m_TimerInterval);
			m_TimerInterval = undefined;
		}
		this._parent._parent.CloseWindowHandler();
	}
}