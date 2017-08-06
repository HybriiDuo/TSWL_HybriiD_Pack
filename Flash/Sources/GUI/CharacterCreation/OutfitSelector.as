import gfx.core.UIComponent;
import gfx.controls.Label;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.Tooltip.*;
import GUI.CharacterCreation.CameraController;

dynamic class GUI.CharacterCreation.OutfitSelector extends UIComponent
{
	private var m_Title:Label;
	private var m_NavigationBar:MovieClip;
	private var m_BackButton:MovieClip;
	private var m_ForwardButton:MovieClip;
	private var m_HelpIcon:MovieClip;
	private var m_OutfitSelectBox:MovieClip;
	private var m_HexGridPicker:MovieClip;
		
	public var SignalBack:com.Utils.Signal;
    public var SignalForward:com.Utils.Signal;    
    private var m_CameraController:CameraController;
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
	private var m_CurrentFeature:Number;
	
	private var FEATURE_HAT:Number = 0;
	private var FEATURE_ACCESSORY:Number = 1;
	private var FEATURE_CHEST:Number = 2;
	private var FEATURE_COAT:Number = 3;
	private var FEATURE_LEGS:Number = 4;
	private var FEATURE_SHOES:Number = 5;
	
	public function OutfitSelector()
    {
		SignalBack = new com.Utils.Signal;
        SignalForward = new com.Utils.Signal;		
	}
	
	private function configUI()
    {
		m_BackButton.m_BackwardArrow._alpha = 100;
		m_ForwardButton.m_ForwardArrow._alpha = 100;
		m_BackButton.SignalButtonSelected.Connect(BackToCharacterEditor, this);
		m_ForwardButton.SignalButtonSelected.Connect(GoForward, this);
		
		m_OutfitSelectBox.SignalFeatureSelected.Connect(FeatureSelected, this);
		m_OutfitSelectBox.SetCharacterCreationIF(m_CharacterCreationIF);
		
		m_HexGridPicker.SignalItemSelected.Connect(ItemSelected, this);
		//Currently we don't have colors for clothes
		//m_HexGridPicker.SignalColorSelected.Connect(ColorSelected, this);
		m_HexGridPicker.SetCharacterCreationIF(m_CharacterCreationIF);
		m_HexGridPicker.HideColors(true);
		
		m_CameraController.SetLockPosUpdate(false);
				
		SetLabels();
		LayoutHandler();
	}
	
	private function SetLabels()
	{
		m_BackButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "EditCharacter" );
        m_ForwardButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "SelectClass" );
        TooltipUtils.AddTextTooltip( m_HelpIcon, LDBFormat.LDBGetText( "CharCreationGUI", "MouseNavigationInfo" ), 250, TooltipInterface.e_OrientationHorizontal,  true, false); 
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
		
		m_HelpIcon._x = Stage.width - m_HelpIcon._width - 20;
        m_HelpIcon._y = 20;
		
		m_OutfitSelectBox._x = Stage.width/2 - Stage.width/4 - m_OutfitSelectBox._width/2 - 50;
		m_OutfitSelectBox._y = Stage.height/2 - m_HexGridPicker._height/2;
		
		m_HexGridPicker._y = Stage.height/2 - m_HexGridPicker._height/2;
		m_HexGridPicker._x = Stage.width/2 + Stage.width/4 - m_HexGridPicker._width/2 + 50;
		
		m_NavigationBar._width = Stage.width + 2;
		CenterHorizontal(m_NavigationBar);
		m_NavigationBar._y = Stage.height - m_NavigationBar._height;
		
		m_BackButton._x = 10;
		m_BackButton._y = Stage.height - (m_NavigationBar._height / 2) - (m_BackButton._height / 2) + 5;
		m_ForwardButton._y = m_BackButton._y;
		m_ForwardButton._x = Stage.width - m_ForwardButton._width - 10;
	}
	
	private function FeatureSelected(featureIndex:Number)
	{
		m_CurrentFeature = featureIndex;
		m_HexGridPicker.SetTitle(LDBFormat.LDBGetText("CharCreationGUI", "OutfitSlot_" + featureIndex));
		var itemArray:Array = new Array();
		//Currently we have no colors
		//var colorArray:Array = new Array();
		switch(m_CurrentFeature)
		{
			case FEATURE_HAT:		m_CameraController.SetZoomMode( CameraController.e_ModeFace, 1 );
									break;
									
			case FEATURE_ACCESSORY:	m_CameraController.SetZoomMode( CameraController.e_ModeFace, 1 );
									break;
									
			case FEATURE_CHEST:		m_CameraController.SetZoomMode( CameraController.e_ModeTop, 1 );
									break;
									
			case FEATURE_COAT:		m_CameraController.SetZoomMode( CameraController.e_ModeBody, 1 );
									break;
									
			case FEATURE_LEGS:		m_CameraController.SetZoomMode( CameraController.e_ModeLegs, 1 );
									break;
									
			case FEATURE_SHOES:		m_CameraController.SetZoomMode( CameraController.e_ModeFeet, 1 );
									break;
									
			default:				m_CameraController.SetZoomMode( CameraController.e_ModeBody, 1 );
		}
		
		var equipLocation:Number = GetEquipLocation(m_CurrentFeature);
		var addEmptyItem:Boolean = m_CharacterCreationIF.CanClothSlotBeEmpty( equipLocation );
		if ( addEmptyItem )
        {
            var emptyItem:Object = new Object;
            emptyItem.m_ItemName = LDBFormat.LDBGetText( "CharCreationGUI", "NoItemSelected" );
            emptyItem.m_IconID = 0;
            emptyItem.m_Index = -1;
            itemArray.push( emptyItem );
        }
        
		var count:Number = m_CharacterCreationIF.GetClothCount( equipLocation );
        for ( var i = 0 ; i < count ; ++i )
        {
            var item:Object = new Object;
            item.m_ItemName = m_CharacterCreationIF.GetClothName( equipLocation, i );
            item.m_IconID = m_CharacterCreationIF.GetClothIcon( equipLocation, i );
            item.m_Index = i;
            itemArray.push( item );
        }
		var currentIndex:Number = m_CharacterCreationIF.GetClothSelection( equipLocation );
		if (addEmptyItem)
		{
			currentIndex++;
		}
		m_HexGridPicker.SetItems(itemArray, currentIndex);
	}
	
	private function ItemSelected(itemIndex:Number)
	{
		m_CharacterCreationIF.WearCloth( GetEquipLocation(m_CurrentFeature), itemIndex );
	}
	
	private function GetEquipLocation(featureSlot:Number)
	{
		switch(featureSlot)
		{
			case FEATURE_HAT:		return _global.Enums.ItemEquipLocation.e_Wear_Hat;
			
			case FEATURE_ACCESSORY:	return _global.Enums.ItemEquipLocation.e_Wear_Face;
									
			case FEATURE_CHEST:		return _global.Enums.ItemEquipLocation.e_Wear_Chest;
									
			case FEATURE_COAT:		return _global.Enums.ItemEquipLocation.e_Wear_Back;
									
			case FEATURE_LEGS:		return _global.Enums.ItemEquipLocation.e_Wear_Legs;
									
			case FEATURE_SHOES:		return _global.Enums.ItemEquipLocation.e_Wear_Feet;
									
			default:				return 0;
		}
	}
	
	private function BackToCharacterEditor()
	{
		this.SignalBack.Emit();
	}
	
	private function GoForward()
	{
		m_CameraController.SetZoomMode( 0, 1 );
		SignalForward.Emit();
	}
}