import com.Components.WindowComponentContent;
import com.Components.FCButton;
import com.GameInterface.GroupFinder;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import com.Utils.Archive;
import gfx.controls.Button;
import mx.utils.Delegate;

class GUI.GroupFinder.GroupFinderRoleSelectionContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_MainText:TextField;
	private var m_TankRole:FCButton;
	private var m_DPSRole:FCButton;
	private var m_HealRole:FCButton;
	private var m_TankLabel:TextField;
	private var m_DPSLabel:TextField;
	private var m_HealLabel:TextField;
	private var m_TimerText:TextField;
	private var m_AcceptButton:Button;
	private var m_CancelButton:Button;

	//Variables
	private var m_TimerInterval:Number;
	private var m_SecondsRemaining:Number;
	
	//Statics
	private static var TIMER_TEXT:String = LDBFormat.LDBGetText("GroupSearchGUI", "GroupFinderReadyTimer");
	//TODO: Maybe get this from the server to avoid a desync? It probably doesn't matter much.
	private static var TIMEOUT:Number = 60;
	
	public function GroupFinderRoleSelectionContent()
	{
		super();
	}
	
	private function configUI():Void
	{
		SetLabels();
		m_AcceptButton.addEventListener("click", this, "AcceptClickHandler");
		m_AcceptButton.disableFocus = true;
		m_CancelButton.addEventListener("click", this, "CancelClickHandler");
		m_CancelButton.disableFocus = true;
		
		var roleButtonArray = new Array(m_TankRole, m_DPSRole, m_HealRole);
		for (var i:Number = 0; i < roleButtonArray.length; i++)
        {
            roleButtonArray[i].toggle = true;
            roleButtonArray[i].disableFocus = true;
            roleButtonArray[i].selected = false;
            roleButtonArray[i].addEventListener("click", this, "RoleButtonClickHandler");
        }
		
		GroupFinder.SignalClientLeftGroupFinder.Connect(Close, this);
		GroupFinder.SignalClientJoinedGroupFinder.Connect(Close, this);
		GroupFinder.SignalClientStartedGroupFinderActivity.Connect(Close, this);
		
		m_SecondsRemaining = TIMEOUT;
		UpdateTimer();
		m_TimerInterval = setInterval( Delegate.create( this, UpdateTimer ), 1000 );
		
		UpdateAcceptButton();
	}
	
	private function SetLabels():Void
	{
		m_MainText.text = LDBFormat.LDBGetText("GroupSearchGUI", "RoleSelectDescription");
		
		m_AcceptButton.label = LDBFormat.LDBGetText("GenericGUI", "Accept");
		m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
		
		m_TankLabel.text = LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonLabel");
		m_DPSLabel.text = LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonLabel");
		m_HealLabel.text = LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonLabel");
		
		m_TankRole.SetTooltipMaxWidth(250);
		m_DPSRole.SetTooltipMaxWidth(250);
		m_HealRole.SetTooltipMaxWidth(250);
		m_TankRole.SetTooltipText(LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonTooltip"));
        m_DPSRole.SetTooltipText(LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonTooltip"));
        m_HealRole.SetTooltipText(LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonTooltip"));
	}
	
	private function UpdateTimer():Void
	{
		m_SecondsRemaining -= 1;
		m_TimerText.text = TIMER_TEXT + " " + secondsToTimeString(m_SecondsRemaining);
		if (m_SecondsRemaining <= 0)
		{
			clearInterval(m_TimerInterval);
			m_TimerInterval = undefined;
			this._parent._parent.CloseWindowHandler();
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
	
	private function UpdateAcceptButton():Void
	{
		if (m_TankRole.selected || m_DPSRole.selected || m_HealRole.selected)
		{
			m_AcceptButton.disabled = false;
			return;
		}
		m_AcceptButton.disabled = true;
	}
	
	private function RoleButtonClickHandler():Void
	{
		UpdateAcceptButton();
	}
	
	private function AcceptClickHandler():Void
	{
		var selectedRoles:Array = new Array();
		if (m_TankRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleTank);}
		if (m_DPSRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleDamage);}
		if (m_HealRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleHeal);}
		GroupFinder.SendRoles(selectedRoles);
		Close();
	}
	
	private function CancelClickHandler():Void
	{
		//Sending an empty roles array will invalidate the team early
		GroupFinder.SendRoles(new Array());
		Close();
	}
	
	public function SetRoles(rolesArray:Array):Void
	{
		for (var i:Number = 0; i < rolesArray.length; i++)
		{
			if (rolesArray[i] == _global.Enums.LFGRoles.e_RoleTank){m_TankRole.selected = true;}
			if (rolesArray[i] == _global.Enums.LFGRoles.e_RoleDamage){m_DPSRole.selected = true;}
			if (rolesArray[i] == _global.Enums.LFGRoles.e_RoleHeal){m_HealRole.selected = true;}
		}
		UpdateAcceptButton();
	}
	
	public function BuildArchive():Archive
	{
		var archive:Archive = new Archive();
		var selectedRoles:Array = new Array();
		if (m_TankRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleTank);}
		if (m_DPSRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleDamage);}
		if (m_HealRole.selected){selectedRoles.push(_global.Enums.LFGRoles.e_RoleHeal);}
		for (var i:Number = 0; i < selectedRoles.length; i++)
        {
            archive.AddEntry("SelectedRoles", selectedRoles[i]);
        }
		return archive;
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