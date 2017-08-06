import gfx.core.UIComponent;
import gfx.controls.ButtonGroup;
import gfx.controls.Button;
import gfx.controls.TileList;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.CharacterCreation.CharacterCreation;

dynamic class GUI.CharacterCreation.HexGridPicker extends UIComponent
{  
	//PROPERTIES
	private var m_Title:TextField;
	private var m_ColorTitle:TextField;
	private var m_ItemList:TileList;
	private var m_ColorList:TileList;
	private var m_ColorDividerTop:MovieClip;
	private var m_ColorDividerBottom:MovieClip;
	private var m_Background:MovieClip;
	
	//VARIABLES
	private var SignalItemSelected:Signal;
	private var SignalColorSelected:Signal;
	private var m_SelectedItemIndex:Number;
	private var m_SelectedColorIndex:Number;
	private var m_CharacterCreationIF:CharacterCreation;
	private var m_Initialized:Boolean;
	
	//STATICS
	private var MAX_COLORS:Number = 30;
	
	public function HexGridPicker()
    {
		SignalItemSelected = new Signal();
		SignalColorSelected = new Signal();
	}
	
	private function configUI()
	{
		m_ItemList.addEventListener( "change", this, "SelectedItemChanged" );
		m_ColorList.addEventListener( "change", this, "SelectedColorChanged" );
		m_ColorTitle.text = LDBFormat.LDBGetText("CharCreationGUI", "Color");
		
		m_Initialized = true;
		if (m_CharacterCreationIF != undefined)
		{
			if (m_SelectedItemIndex != undefined)
			{
				SetSelectedItem(m_SelectedItemIndex);
			}
			if (m_SelectedColorIndex != undefined)
			{
				SetSelectedColor(m_SelectedColorIndex);
			}
		}
	}
	
	private function SelectedItemChanged(event:Object)
	{
		var selectedItem:Object = m_ItemList.dataProvider[ event.index ];
		
		//For some reason scaleform gridList lets you select disabled elements
		//So we have to handle that manually
		if (selectedItem == undefined)
		{
			m_ItemList.selectedIndex = m_SelectedItemIndex;
		}
        else if (m_SelectedItemIndex != event.index )
        {
            m_SelectedItemIndex = event.index;
			SignalItemSelected.Emit(selectedItem.m_Index);
        }
	}
	
	private function SelectedColorChanged(event:Object)
	{
		var selectedColor:Object = m_ColorList.dataProvider[ event.index ];
		
		//For some reason scaleform gridList lets you select disabled elements
		//So we have to handle that manually
		if (selectedColor == undefined)
		{
			m_ColorList.selectedIndex = m_SelectedColorIndex;
		}
        else if (m_SelectedColorIndex != selectedColor.m_Index )
        {
            m_SelectedColorIndex = selectedColor.m_Index;
			SignalColorSelected.Emit(m_SelectedColorIndex);
        }
	}
	
	public function SetTitle(newTitle:String)
	{
		m_Title.text = newTitle;
	}
	
	public function SetItems(itemArray:Array, currentSelection:Number)
	{
		m_ItemList.removeEventListener( "change", this, "SelectedItemChanged" );
		m_ItemList.dataProvider = [];
        m_ItemList.dataProvider = itemArray;
		m_ItemList.invalidateData();
        m_ItemList.addEventListener( "change", this, "SelectedItemChanged" );
		
		if (currentSelection != undefined)
		{
			SetSelectedItem(currentSelection);
		}
	}
	
	public function SetColors(colorArray:Array, currentSelection:Number)
	{
		m_ColorList.removeEventListener( "change", this, "SelectedColorChanged" );
		m_ColorList.dataProvider = [];
        m_ColorList.dataProvider = colorArray;		
		m_ColorList.invalidateData();
        m_ColorList.addEventListener( "change", this, "SelectedColorChanged" );
		
		if (currentSelection != undefined)
		{
			SetSelectedColor(currentSelection);
		}
	}
	
	public function SetSelectedItem(currentSelection:Number)
	{
		m_ItemList.removeEventListener( "change", this, "SelectedItemChanged" );
		m_SelectedItemIndex = currentSelection;
		m_ItemList.selectedIndex = currentSelection;
		m_ItemList.addEventListener( "change", this, "SelectedItemChanged" );
	}
	
	public function SetSelectedColor(currentSelection:Number)
	{
		m_ColorList.removeEventListener( "change", this, "SelectedColorChanged" );
		m_SelectedColorIndex = currentSelection;
		m_ColorList.selectedIndex = currentSelection;
		m_ColorList.addEventListener( "change", this, "SelectedColorChanged" );
	}
	
	public function HideColors(hideColors:Boolean)
	{
		m_ColorDividerTop._visible = !hideColors;
		m_ColorDividerBottom._visible = !hideColors;
		m_ColorTitle._visible = !hideColors;
		for (var i:Number = 1; i <= MAX_COLORS; i++)
		{
			this["Color_"+i]._visible = !hideColors;
		}
		m_Background._height = hideColors ? 550 : 658.95;
	}
	
	public function SetCharacterCreationIF(characterCreationIF:CharacterCreation)
	{
		m_CharacterCreationIF = characterCreationIF;
		if (m_Initialized)
		{
			if (m_SelectedItemIndex != undefined)
			{
				SetSelectedItem(m_SelectedItemIndex);
			}
			if (m_SelectedColorIndex != undefined)
			{
				SetSelectedColor(m_SelectedColorIndex);
			}
		}
	}
}