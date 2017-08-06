import gfx.controls.ListItemRenderer;
import com.Utils.Colors;
import com.GameInterface.Utils;

class GUI.LockoutTimers.LockoutListItemRenderer extends ListItemRenderer
{
	private var m_TimeText:TextField;
	private var m_Text:TextField;
	private var m_Name:String;
	private var m_Time:Number;
	private var m_TimerID:Number;
	private var m_TimerType:Number;
	private var m_IconName:String;
	private var m_Icon:MovieClip;
	
	private static var TYPE_BUFF = 0;
	private static var TYPE_MISSION = 1;
	
	public function LockoutListItemRenderer()
    {
        super();
    }
	
	 private function configUI()
	{
		super.configUI();
	}
	
    public function setData( data:Object ) : Void
    {
		super.setData(data);
		
		if (data != undefined)
        {
            this._visible = true;
			m_Name = data.m_Name;
			m_Text.text = m_Name;
			m_TimeText.text = "";
			m_TimerType = data.m_TimerType;
			m_IconName = data.m_IconName;
			if (m_Icon != undefined)
			{
				m_Icon.removeMovieClip();
			}
			m_Icon = attachMovie( m_IconName, "m_Icon", getNextHighestDepth());
			m_Icon._x = 3;
			m_Icon._y = 1;
			m_Icon._alpha = 75;
			if (data.m_TotalTime)
			{
				m_Text.textColor = Colors.e_ColorLightRed;
				m_TimeText.textColor = Colors.e_ColorLightRed;
				m_Time = data.m_TotalTime;
				m_TimeText.text = CalculateTimeString(m_Time);
				m_TimerID = setInterval(this, "OnUpdateTimer", 1000);
			}
			else
			{
				m_Text.textColor = Colors.e_ColorGreen;
			}
        }
        else
        {
            this._visible = false;
		}
    }
	
	//Timey-wimey wibbly-wobbly stuff beyond this point.
	private function CalculateTimeString(totalSeconds):String
	{
		var timeLeft = totalSeconds;
		if (m_TimerType == TYPE_BUFF)
		{
			var time = com.GameInterface.Utils.GetNormalTime() * 1000;
			timeLeft = (totalSeconds - time)/1000;
		}
		else { timeLeft = totalSeconds - Utils.GetServerSyncedTime(); }
		
		var totalMinutes = timeLeft/60;
		var hours = totalMinutes/60;
		var hoursString = String(Math.floor(hours));
		if (hoursString.length == 1) { hoursString = "0" + hoursString; }
		var seconds = timeLeft%60;
		var secondsString = String(Math.floor(seconds));
		if (secondsString.length == 1) { secondsString = "0" + secondsString; }
		var minutes = totalMinutes%60;
		var minutesString = String(Math.floor(minutes));
		if (minutesString.length == 1) { minutesString = "0" + minutesString; }
		return hoursString + ":" + minutesString + ":" + secondsString;
	}
	
	private function OnUpdateTimer()
	{
		//Hack to not do this if we've scrolled to a green entry
		if (m_Text.textColor != Colors.e_ColorGreen)
		{
			var timeLeft = m_Time;
			if(m_TimerType == TYPE_BUFF)
			{
				var time = com.GameInterface.Utils.GetNormalTime() * 1000;
				timeLeft = (m_Time - time)/1000;
			}
			else { timeLeft = m_Time - Utils.GetServerSyncedTime(); }
			if (timeLeft > 0)
			{
				m_TimeText.text = CalculateTimeString(m_Time);
			}
			else
			{
				m_Text.text = m_Name;
				m_Text.textColor = Colors.e_ColorGreen;
				m_TimeText.text = "";
				clearInterval( m_TimerID );
				m_TimerID = undefined;
			}
		}
	}
}