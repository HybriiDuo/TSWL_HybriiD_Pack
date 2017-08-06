import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import mx.utils.Delegate;

class GUI.ScryWidgets.MuseumDisplayContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_Header:TextField;
	private var m_Description:TextField;
	private var m_UpgradeInstructions:TextField;
	private var m_CompleteText:TextField;
	private var m_UpgradeProgress_1:TextField;
	private var m_UpgradeRequirement_1:TextField;
	private var m_UpgradeProgress_2:TextField;
	private var m_UpgradeRequirement_2:TextField;
	private var m_UpgradeProgress_3:TextField;
	private var m_UpgradeRequirement_3:TextField;
	private var m_UpgradeProgress_4:TextField;
	private var m_UpgradeRequirement_4:TextField;
	private var m_UpgradeProgress_5:TextField;
	private var m_UpgradeRequirement_5:TextField;
	private var m_UpgradeProgress_6:TextField;
	private var m_UpgradeRequirement_6:TextField;
	private var m_UpgradeProgress_7:TextField;
	private var m_UpgradeRequirement_7:TextField;
	
	public function MuseumDisplayContent()
	{
		super();
	}
	
	private function SetData(dataArray:Array)
	{
		m_Header.htmlText = dataArray[0];
		m_Description.htmlText = dataArray[1];
		m_UpgradeProgress_1.htmlText = dataArray[2];
		m_UpgradeRequirement_1.htmlText = dataArray[3];
		m_UpgradeProgress_2.htmlText = dataArray[4];
		m_UpgradeRequirement_2.htmlText = dataArray[5];
		m_UpgradeProgress_3.htmlText = dataArray[6];
		m_UpgradeRequirement_3.htmlText = dataArray[7];
		m_UpgradeProgress_4.htmlText = dataArray[8];
		m_UpgradeRequirement_4.htmlText = dataArray[9];
		m_UpgradeProgress_5.htmlText = dataArray[10];
		m_UpgradeRequirement_5.htmlText = dataArray[11];
		m_UpgradeProgress_6.htmlText = dataArray[12];
		m_UpgradeRequirement_6.htmlText = dataArray[13];
		m_UpgradeProgress_7.htmlText = dataArray[14];
		m_UpgradeRequirement_7.htmlText = dataArray[15];
		m_UpgradeInstructions.htmlText = dataArray[16];

		var hasCompleteText:Boolean = dataArray[17] != undefined && dataArray[17].length > 0;
		m_CompleteText.htmlText = dataArray[17];
		m_CompleteText._visible = hasCompleteText;
		m_UpgradeInstructions._visible = !hasCompleteText;
		m_UpgradeProgress_1._visible = !hasCompleteText;
		m_UpgradeRequirement_1._visible = !hasCompleteText;
		m_UpgradeProgress_2._visible = !hasCompleteText;
		m_UpgradeRequirement_2._visible = !hasCompleteText;
		m_UpgradeProgress_3._visible = !hasCompleteText;
		m_UpgradeRequirement_3._visible = !hasCompleteText;
		m_UpgradeProgress_4._visible = !hasCompleteText;
		m_UpgradeRequirement_4._visible = !hasCompleteText;
		m_UpgradeProgress_5._visible = !hasCompleteText;
		m_UpgradeRequirement_5._visible = !hasCompleteText;
		m_UpgradeProgress_6._visible = !hasCompleteText;
		m_UpgradeRequirement_6._visible = !hasCompleteText;
		m_UpgradeProgress_7._visible = !hasCompleteText;
		m_UpgradeRequirement_7._visible = !hasCompleteText;
	}
}