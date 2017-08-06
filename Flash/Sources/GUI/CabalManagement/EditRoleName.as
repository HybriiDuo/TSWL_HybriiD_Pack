import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.TextInput;

import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;

class GUI.CabalManagement.EditRoleName extends UIComponent
{
	private var m_Title:TextField;
	private var m_NameInput:TextInput;	
	
	private var m_ConfirmButton:Button;
	private var m_CancelButton:Button;
	
	private var SignalCancel:Signal;
	private var SignalEditName:Signal;
	
	private var m_CurrRole:String;
	private var m_RankNumber:String;
	
	private var m_KeyListener:Object;
	
	private function EditRoleName()
	{
		SignalCancel = new Signal;
		SignalEditName = new Signal;
	}
	
	private function configUI()
	{
		SetLabels();
		
		m_CancelButton.addEventListener("click", this, "CancelNameEdit");
		m_ConfirmButton.addEventListener("click", this, "ConfirmNameEdit");		
		
		m_CurrRole = _parent.m_RoleDropdown.dataProvider[_parent.m_RoleDropdown.selectedIndex];
		var index:Number = m_CurrRole.lastIndexOf(" ");
		m_RankNumber = m_CurrRole.substr(index, m_CurrRole.length);
		m_CurrRole = m_CurrRole.substr(0, index);
		m_NameInput.text = m_CurrRole;
		m_NameInput.addEventListener("textChange", this, "OnTextChanged");
		
		m_KeyListener = new Object();    
		m_KeyListener.onKeyUp = Delegate.create( this, function ()
		{
			if ( Key.getCode() == Key.ENTER ){ ConfirmNameEdit(); }
			else if (Key.getCode() == Key.ESCAPE){ CancelNameEdit(); }
		} );
		
		Key.addListener( m_KeyListener );
		
		Selection.setFocus(m_NameInput);
		Selection.setSelection(0, m_NameInput.text.length);
	}
	
	private function OnTextChanged()
	{
		m_ConfirmButton.disabled = false;
		if (m_NameInput.text == ""){ m_ConfirmButton.disabled = true; }
		if (m_NameInput.text.length > 15){ m_ConfirmButton.disabled = true; }
		if (m_NameInput.text.charAt(0) == " "){ m_ConfirmButton.disabled = true; }
		
	}
	
	private function SetLabels()
	{
		m_Title.text = LDBFormat.LDBGetText("GuildGUI","EditRoleName");
		m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI","Confirm");
		m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI","Cancel");
	}
	
	private function CancelNameEdit()
	{
		SignalCancel.Emit();
	}
	
	private function ConfirmNameEdit()
	{
		SignalEditName.Emit(m_NameInput.text, m_CurrRole, m_RankNumber);
	}
}