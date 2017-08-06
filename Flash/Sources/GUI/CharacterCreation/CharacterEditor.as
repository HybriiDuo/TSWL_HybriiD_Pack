import mx.utils.Delegate;

import gfx.core.UIComponent;
import mx.transitions.easing.*;
import com.Utils.LDBFormat;
import com.Utils.Signal;

import gfx.controls.ButtonGroup;
import gfx.controls.Slider;
import gfx.controls.Label;
import gfx.controls.TextArea;

import GUI.CharacterCreation.CameraController;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.*;

dynamic class GUI.CharacterCreation.CharacterEditor extends UIComponent
{
    public var SignalBack:com.Utils.Signal;
    public var SignalForward:com.Utils.Signal;
    
    private var m_CameraController:CameraController;
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
	
	private var m_Title:Label;
    private var m_GenderSelector:MovieClip;
	private var m_FeatureSelectBox:MovieClip;
	private var m_HexGridPicker:MovieClip;
    private var m_CharacterSizeSliderLabel:MovieClip;
    private var m_CharacterSizeSlider:Slider;
    private var m_NavigationBar:MovieClip;
	private var m_BackButton:MovieClip;
	private var m_ForwardButton:MovieClip;
    private var m_HelpIcon:MovieClip;

	private var m_NameInputDefaultText:String;
	private var m_CurrentFeature:Number;
	
	private var FEATURE_HEAD:Number = 0;
	private var FEATURE_FACE:Number = 1;
	private var FEATURE_HAIR:Number = 2;
	private var FEATURE_EYEBROW:Number = 3
	private var FEATURE_EYE:Number = 4;
	private var FEATURE_MISC:Number = 5;
	private var FEATURE_MAKEUP:Number = 6;
    
    public function CharacterEditor()
    {
        SignalBack = new com.Utils.Signal;
        SignalForward = new com.Utils.Signal;		
    }
	
	 private function configUI()
    {		
		//set default gender to female
        m_CharacterCreationIF.SignalGenderChanged.Connect( SlotGenderChanged, this );
        SlotGenderChanged( m_CharacterCreationIF.GetGender() );
		
		m_CharacterCreationIF.SignalMakeupChanged.Connect( SlotMakeupChanged, this );
		
		var characterButtonGroup:ButtonGroup = new ButtonGroup("characterButtons");
		
		m_FeatureSelectBox.SignalFeatureSelected.Connect(FeatureSelected, this);
		m_FeatureSelectBox.SetCharacterCreationIF(m_CharacterCreationIF);
		
		m_HexGridPicker.SignalItemSelected.Connect(ItemSelected, this);
		m_HexGridPicker.SignalColorSelected.Connect(ColorSelected, this);
		m_HexGridPicker.SetCharacterCreationIF(m_CharacterCreationIF);
		
		m_BackButton.m_BackwardArrow._alpha = 100;
		m_ForwardButton.m_ForwardArrow._alpha = 100;
		
		m_GenderSelector.m_ButtonGenderMale.toggle = true;
		m_GenderSelector.m_ButtonGenderFemale.toggle = true;
      	
		var genderButtonGroup:ButtonGroup = new ButtonGroup("genderButtons");
		m_GenderSelector.m_ButtonGenderMale.group = genderButtonGroup;
		m_GenderSelector.m_ButtonGenderFemale.group = genderButtonGroup;
		
		m_GenderSelector.m_ButtonGenderMale.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "Tooltip_Male" ));
		m_GenderSelector.m_ButtonGenderFemale.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "Tooltip_Female" ));
		
		m_GenderSelector.m_ButtonGenderMale.addEventListener("click", this, "ClickedMale");
		m_GenderSelector.m_ButtonGenderFemale.addEventListener("click", this, "ClickedFemale");
		
		m_BackButton.SignalButtonSelected.Connect(BackToFactionSelection, this);
		m_ForwardButton.SignalButtonSelected.Connect(GoForward, this);
        
        m_CharacterSizeSlider.minimum = m_CharacterCreationIF.GetCharacterMinScale();
        m_CharacterSizeSlider.maximum = m_CharacterCreationIF.GetCharacterMaxScale();
        m_CharacterSizeSlider.liveDragging = true;
        m_CharacterSizeSlider.addEventListener( "change", this, "OnCharacterSizeSliderChanged" );
        
        m_CharacterCreationIF.SignalCharacterScaleChanged.Connect( SlotCharacterScaleChanged, this );
        SlotCharacterScaleChanged( m_CharacterCreationIF.GetCharacterScale() );
				
		m_CameraController.SetZoomMode( CameraController.e_ModeFace, 2 );
		
		SetLabels();
		LayoutHandler();
    }
	
	private function SetLabels()
	{		
		m_BackButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "ReselectFaction" );
        m_CharacterSizeSliderLabel.text = LDBFormat.LDBGetText( "CharCreationGUI", "CharacterSizeLabel" );
        
        TooltipUtils.AddTextTooltip( m_HelpIcon, LDBFormat.LDBGetText( "CharCreationGUI", "MouseNavigationInfo" ), 250, TooltipInterface.e_OrientationHorizontal,  true, false); 
        
		m_ForwardButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "SelectClothing" );
		m_Title.htmlText = LDBFormat.LDBGetText( "CharCreationGUI", "MainTitle" );
	}
	
	private function CenterHorizontal(component:MovieClip)
	{
		component._x = (Stage.width/2) - (component._width/2)
	}
	
	public function LayoutHandler()
	{		
		CenterHorizontal(m_Title);
		m_Title._y = 20;
		
		m_FeatureSelectBox._x = Stage.width/2 - Stage.width/4 - m_FeatureSelectBox._width/2 - 50;
		m_FeatureSelectBox._y = Stage.height/2 - m_HexGridPicker._height/2;
		
		m_HexGridPicker._y = Stage.height/2 - m_HexGridPicker._height/2;
		m_HexGridPicker._x = Stage.width/2 + Stage.width/4 - m_HexGridPicker._width/2 + 50;
		
		m_NavigationBar._width = Stage.width + 2;
		CenterHorizontal(m_NavigationBar);
		m_NavigationBar._y = Stage.height - m_NavigationBar._height;
		
		CenterHorizontal(m_CharacterSizeSlider);
		m_CharacterSizeSlider._y = m_NavigationBar._y - m_CharacterSizeSlider._height - 10;
		m_CharacterSizeSliderLabel._y = m_CharacterSizeSlider._y - 3;// - m_CharacterSizeSliderLabel._height - 5;
        m_CharacterSizeSliderLabel._x = m_CharacterSizeSlider._x - m_CharacterSizeSliderLabel._width -7;
		
		CenterHorizontal(m_GenderSelector);
		m_GenderSelector._y = m_CharacterSizeSlider._y - m_GenderSelector._height - 10;

        m_HelpIcon._x = Stage.width - m_HelpIcon._width - 20;
        m_HelpIcon._y = 20;
        
		m_BackButton._x = 10;
		m_BackButton._y = Stage.height - (m_NavigationBar._height / 2) - (m_BackButton._height / 2) + 5;
		m_ForwardButton._y = m_BackButton._y;
		m_ForwardButton._x = Stage.width - m_ForwardButton._width - 10;
	}
	
	private function FeatureSelected(featureIndex:Number)
	{
		m_CurrentFeature = featureIndex;
		m_HexGridPicker.SetTitle(LDBFormat.LDBGetText("CharCreationGUI", "FeatureSlot_" + featureIndex));
		var itemArray:Array = new Array();
		var colorArray:Array = new Array();
		switch(m_CurrentFeature)
		{
			case FEATURE_HEAD:		for (var i=0; i<m_CharacterCreationIF.GetBaseHeadCount(); i++)
									{
										var item:Object = new Object();
										item.m_ItemName = "Head " + i;
										item.m_IconID = m_CharacterCreationIF.GetBaseHeadIcon(i);
										item.m_Index = i;
										itemArray.push(item);
									}
									m_HexGridPicker.SetItems(itemArray, m_CharacterCreationIF.GetBaseHead());
									
									m_HexGridPicker.HideColors(false);
									for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetSkinColorIndexes().length ; ++i )
									{
										var color:Object = new Object();
										color._color = m_CharacterCreationIF.GetSkinColorValue(i);
										color.m_Index = i;
										colorArray.push(color);
									}
									m_HexGridPicker.SetColors(colorArray, m_CharacterCreationIF.GetSkinColorIndex());
									break;
									
			case FEATURE_FACE:		for (var i=0; i<m_CharacterCreationIF.GetFaceCount(); i++)
									{
										var item:Object = new Object();
										item.m_ItemName = "Face " + i;
										//These are pulled differently, stored as clips in the .fla
										item.m_IconName = "Face_"+i;
										item.m_Index = i;
										itemArray.push(item);
									}
									m_HexGridPicker.SetItems(itemArray, m_CharacterCreationIF.GetFace());
									
									m_HexGridPicker.HideColors(false);
									for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetSkinColorIndexes().length ; ++i )
									{
										var color:Object = new Object();
										color._color = m_CharacterCreationIF.GetSkinColorValue(i);
										color.m_Index = i;
										colorArray.push(color);
									}
									m_HexGridPicker.SetColors(colorArray, m_CharacterCreationIF.GetSkinColorIndex());
									break;
									
			case FEATURE_HAIR:		for (var i=0; i<m_CharacterCreationIF.GetHairStyleIndexes().length; i++)
									{
										var item:Object = new Object();
										item.m_ItemName = "Hair " + i;
										item.m_IconID = m_CharacterCreationIF.GetHairStyleIcon(i);
										item.m_Index = i;
										itemArray.push(item);
									}
									m_HexGridPicker.SetItems(itemArray, m_CharacterCreationIF.GetHairStyleIndex());
									
									m_HexGridPicker.HideColors(false);
									for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetHairColorIndexes().length ; ++i )
									{
										var color:Object = new Object();
										color._color = m_CharacterCreationIF.GetHairColorValue(i);
										color.m_Index = i;
										colorArray.push(color);
									}
									m_HexGridPicker.SetColors(colorArray, m_CharacterCreationIF.GetHairColorIndex());
									break;
									
			case FEATURE_EYEBROW:	for (var i=0; i<m_CharacterCreationIF.GetEyebrowCount(); i++)
									{
										var item:Object = new Object();
										item.m_ItemName = "Eyebrow " + i;
										item.m_IconID = m_CharacterCreationIF.GetEyebrowIcon(i);
										item.m_Index = i;
										itemArray.push(item);
									}
									m_HexGridPicker.SetItems(itemArray, m_CharacterCreationIF.GetEyebrow());
									
									m_HexGridPicker.HideColors(false);
									for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetFacialHairColorIndexes().length ; ++i )
									{
										var color:Object = new Object();
										color._color = m_CharacterCreationIF.GetFacialHairColorValue(i);
										color.m_Index = i;
										colorArray.push(color);
									}
									m_HexGridPicker.SetColors(colorArray, m_CharacterCreationIF.GetFacialHairColorIndex());
									break;
									
			case FEATURE_MAKEUP:	//Add an empty item for makeup
									var emptyItem:Object = new Object;
									emptyItem.m_ItemName = LDBFormat.LDBGetText( "CharCreationGUI", "NoItemSelected" );
									emptyItem.m_IconID = 0;
									emptyItem.m_Index = -1;
									itemArray.push( emptyItem );
									for (var i=0; i<m_CharacterCreationIF.GetMakeupCount(); i++)
									{
										var item:Object = new Object();
										item.m_ItemName = "Makeup " + i;
										item.m_IconID = m_CharacterCreationIF.GetMakeupIcon(i);
										item.m_Index = i;
										itemArray.push(item);
									}
									var makeupIndex = m_CharacterCreationIF.GetMakeup() + 1
									if (m_CharacterCreationIF.GetMakeup() > itemArray.length)
									{
										makeupIndex = 0;
									}
									m_HexGridPicker.SetItems(itemArray, makeupIndex);
									
									m_HexGridPicker.HideColors(false);
									for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetMakeupColorIndexes().length ; ++i )
									{
										var color:Object = new Object();
										color._color = m_CharacterCreationIF.GetMakeupColorValue(i);
										color.m_Index = i;
										colorArray.push(color);
									}
									m_HexGridPicker.SetColors(colorArray, m_CharacterCreationIF.GetMakeupColorIndex());
									break;
									
			case FEATURE_EYE:		m_HexGridPicker.HideColors(true);
									for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetEyeColorIndexes().length ; ++i )
									{
										var item:Object = new Object();
										item.m_ItemName = "Eye Color " + i;
										item.m_IconID = m_CharacterCreationIF.GetEyeColorIcon(i);
										item.m_Index = i;
										itemArray.push(item);
									}
									m_HexGridPicker.SetItems(itemArray, m_CharacterCreationIF.GetEyeColorIndex());
									break;
									
			case FEATURE_MISC:		//Add an empty item for misc features
									var emptyItem:Object = new Object;
									emptyItem.m_ItemName = LDBFormat.LDBGetText( "CharCreationGUI", "NoItemSelected" );
									emptyItem.m_IconID = 0;
									emptyItem.m_Index = -1;
									itemArray.push( emptyItem );
									for (var i=0; i<m_CharacterCreationIF.GetMiscFeatureIndexes().length; i++)
									{
										var item:Object = new Object();
										item.m_ItemName = "Facial Feature " + i;
										item.m_IconID = m_CharacterCreationIF.GetMiscFeatureIcon(i);
										item.m_Index = i;
										itemArray.push(item);
									}
									//+ 1 for the empty object
									m_HexGridPicker.SetItems(itemArray, m_CharacterCreationIF.GetMiscFeatureIndex() + 1);
									
									m_HexGridPicker.HideColors(true);
									break;
		}
	}
	
	private function ItemSelected(itemIndex:Number)
	{
		switch(m_CurrentFeature)
		{
			case FEATURE_HEAD:		m_CharacterCreationIF.SetBaseHead(itemIndex);
									break;
									
			case FEATURE_FACE:		m_CharacterCreationIF.SetFace(itemIndex);
									break;
									
			case FEATURE_HAIR:		m_CharacterCreationIF.SetHairStyleIndex(itemIndex);
									break;
			
			case FEATURE_EYEBROW:	m_CharacterCreationIF.SetEyebrow(itemIndex);
									break;
									
			case FEATURE_MAKEUP:	m_CharacterCreationIF.SetMakeup(itemIndex);
									break;
									
			case FEATURE_EYE:		m_CharacterCreationIF.SetEyeColorIndex(itemIndex);
									break;
									
			case FEATURE_MISC:		m_CharacterCreationIF.SetMiscFeatureIndex(itemIndex);
									break;
		}
	}
	
	private function ColorSelected(colorIndex:Number)
	{
		switch(m_CurrentFeature)
		{
			case FEATURE_HEAD:		m_CharacterCreationIF.SetSkinColorIndex(colorIndex);
									break;
									
			case FEATURE_FACE:		m_CharacterCreationIF.SetSkinColorIndex(colorIndex);
									break;
									
			case FEATURE_EYEBROW:	m_CharacterCreationIF.SetFacialHairColorIndex(colorIndex);
									break;
									
			case FEATURE_HAIR:		m_CharacterCreationIF.SetHairColorIndex(colorIndex);
									break;
									
			case FEATURE_MAKEUP:	m_CharacterCreationIF.SetMakeupColorIndex(colorIndex);
									break;
		}
	}
	
    private function SlotGenderChanged( gender:Number )
    {		
		if ( gender == _global.Enums.BreedSex.e_Sex_Male )
        {
            m_GenderSelector.m_ButtonGenderMale.selected = true;
        }
        else
        { 
            m_GenderSelector.m_ButtonGenderFemale.selected = true;
        }
		FeatureSelected(m_CurrentFeature);
		//We have to have this on a delay for some reason
		//Gender changed signal comes back before the gender is actually changed?
		//If we don't wait a little, the scene will flicker
        _global.setTimeout( Delegate.create( this, UnlockCamera ), 1000 );
    }
	
	private function UnlockCamera()
	{
		m_CameraController.SetLockPosUpdate(false);
	}
	
	private function SlotMakeupChanged(index:Number)
	{
		if (m_CurrentFeature == FEATURE_MAKEUP)
		{
			var colorArray:Array = new Array();
			for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetMakeupColorIndexes().length ; ++i )
			{
				var color:Object = new Object();
				color._color = m_CharacterCreationIF.GetMakeupColorValue(i);
				color.m_Index = i;
				colorArray.push(color);
			}
			m_HexGridPicker.SetColors(colorArray, m_CharacterCreationIF.GetMakeupColorIndex());
		}
	}
    
	private function BackToFactionSelection()
	{
		this.SignalBack.Emit();
	}
	
	private function GoForward()
	{
		SignalForward.Emit();
	}
	
	private function UpdateForwardButton():Void
    {
        m_ForwardButton.disabled = ( m_CharacterCreationIF.AreCurrentSettingsLocked() );
    }
	
	private function ClickedMale()
	{
		trace("CLICKED MALE");
		trace("CAMERA LOCKED");
		m_CameraController.SetLockPosUpdate(true);
        m_CharacterCreationIF.SetGender( _global.Enums.BreedSex.e_Sex_Male );
	}
	
	private function ClickedFemale()
	{
		trace("CLICKED FEMALE");
		trace("CAMERA LOCKED");
		m_CameraController.SetLockPosUpdate(true);
        m_CharacterCreationIF.SetGender( _global.Enums.BreedSex.e_Sex_Female );
	}
    
    private function OnCharacterSizeSliderChanged()
    {
        m_CharacterCreationIF.SetCharacterScale( m_CharacterSizeSlider.value );
	}
	
	private function SlotCharacterScaleChanged( value:Number )
    {
        m_CharacterSizeSlider.value = value;
    }
    
	//What even is this?
	//Probably debug, so removing it for now.
	/*
    private function DumpObjectMembers( value ) : String
    {
        if ( value == undefined )
        {
            return "undefined";
        }
        var type = typeof value;
        if ( type == "string" || type == "number"  || type == "boolean" || type == "function" )
        {
            return value.toString();
        }
        else
        {
            var result:String = "";
            for ( i in value )
            {
                result += ( result.length == 0 ) ? "{" : ", ";
                result += i + ":" + value[i].toString();
            }
            result += "}";
            return result;
        }
    }
	*/
}