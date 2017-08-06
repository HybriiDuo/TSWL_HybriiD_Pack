import gfx.core.UIComponent;
import gfx.controls.Button;
import com.GameInterface.Quests;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import mx.utils.Delegate;

class GUI.Mission.MissionRewardButton extends UIComponent
{
	private var m_ReportText:TextField;
	private var m_RewardText:TextField;
	private var m_ReportsIcon:MovieClip;
	private var m_Animation:MovieClip;
	private var m_HitArea:MovieClip;
    public static var SignalReportSent:Signal;
    
	private var m_AlignRight:Boolean;
    
    public function MissionRewardButton()
    {
        super();
        SignalReportSent = new Signal();
		m_AlignRight = false;
		Quests.SignalSendMissionReport.Connect(SlotSendMissionReportHotkeyPressed, this);

    }
    
    private function configUI()
    {
		m_Animation._xscale = 65;
		m_Animation._yscale = 70;
		m_Animation.gotoAndPlay("throttle");
		
		m_HitArea.onMouseRelease = Delegate.create(this, SendReport);
        SetText();
		AlignRight(m_AlignRight);
    }
    
    public function SetText()
    {
        var rewardQuests:Array = Quests.GetAllRewards();
        var numRewards:Number = rewardQuests.length;
        if (numRewards > 1)
        {
           m_ReportText.text = LDBFormat.LDBGetText("Quests", "Mission_SendReportPlural") + " ("+numRewards+")";
        }
        else
        {
           m_ReportText.text = LDBFormat.LDBGetText("Quests", "Mission_SendReport")
        }
		m_RewardText.text = LDBFormat.LDBGetText("Quests", "Mission_ClaimReward");     
		m_RewardText.text += " (<variable name='hotkey:SendReport'/ >)";
    }
    
    private function SendReport(event:Object)
    {
		trace("SendReport()");
		m_ReportsIcon.onMouseRelease = undefined;
        GUI.Mission.MissionSignals.SignalMissionReportSent.Emit();
    }
	
	public function AlignRight(alignRight:Boolean)
	{
		m_AlignRight = alignRight;
		var format:TextFormat = new TextFormat();
		if (alignRight)
		{
			format.align = 'left';
			m_ReportText._x = m_ReportsIcon._x + m_ReportsIcon._width + 7;
			m_RewardText._x = m_ReportText._x;
			m_HitArea._x = m_ReportText._x - 45;
		}
		else
		{
			format.align = 'right';
			m_ReportText._x = 0;
			m_RewardText._x = 0;
			m_HitArea._x = 0;
		}
		m_ReportText.setTextFormat(format);
		m_RewardText.setTextFormat(format);
		SetText();
	}

	public function SlotSendMissionReportHotkeyPressed(event:Object)
	{
		trace("SlotSendMissionReportHotkeyPressed()");
		SendReport();
	}
}