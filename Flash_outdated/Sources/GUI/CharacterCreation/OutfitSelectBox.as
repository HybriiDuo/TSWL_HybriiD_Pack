import gfx.core.UIComponent;
import gfx.controls.ButtonGroup;
import gfx.controls.Button;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.CharacterCreation.CharacterCreation;

dynamic class GUI.CharacterCreation.OutfitSelectBox extends UIComponent
{  
	//PROPERTIES
	private var m_Header:TextField;
	private var m_Feature_0:Button;
	private var m_Feature_1:Button;
	private var m_Feature_2:Button;
	private var m_Feature_3:Button;
	private var m_Feature_4:Button;
	private var m_Feature_5:Button;
	
	//VARIABLES
	private var m_SelectedFeature:Number;
	private var SignalFeatureSelected:Signal;
	private var m_CharacterCreationIF:CharacterCreation;
	private var m_Initialized:Boolean;
	private var m_FeatureGroup:ButtonGroup;
	
	//STATICS
	private var NUM_FEATURES:Number = 6;
	
	public function OutfitSelectBox()
    {
		SignalFeatureSelected = new Signal();
	}
	
	private function configUI()
	{
		FillFeatureButtons();
		SetLabels();
		
		m_FeatureGroup = new ButtonGroup("featureButtons");
		for (var i:Number = 0; i < NUM_FEATURES; i++)
		{
			var featureButton:Button = this["m_Feature_"+i];
			featureButton.toggle = true;
			featureButton.group = m_FeatureGroup;
			featureButton.disableFocus = true;
		}
		
		m_FeatureGroup.addEventListener("change", this, "SelectedFeatureChanged");		
		
		m_Initialized = true;
		if (m_CharacterCreationIF != undefined)
		{
			m_FeatureGroup.setSelectedButton(m_Feature_0);
		}
	}
	
	private function SelectedFeatureChanged(event:Object)
	{
		for (var i:Number = 0; i < NUM_FEATURES; i++)
		{
			if (event.item == this["m_Feature_" + i])
			{
				m_SelectedFeature = i;
				SignalFeatureSelected.Emit(i);
			}
		}
	}
	
	private function FillFeatureButtons()
	{
		for (var i:Number = 0; i < NUM_FEATURES; i++)
		{
			var featureButton:MovieClip = this["m_Feature_" + i];			
			featureButton.m_Label.text = LDBFormat.LDBGetText("CharCreationGUI", "OutfitSlot_" + i);
		}
	}
	
	
	private function SetLabels()
	{
		m_Header.text = LDBFormat.LDBGetText("CharCreationGUI", "OutfitSelector_BoxHeader");
	}
	
	public function SetCharacterCreationIF(characterCreationIF:CharacterCreation)
	{
		m_CharacterCreationIF = characterCreationIF;
		if (m_Initialized)
		{
			m_FeatureGroup.setSelectedButton(m_Feature_0);
		}
	}
}