//Imports
import com.GameInterface.AccountManagement;
import com.GameInterface.DistributedValue;
import com.GameInterface.Utils;
import com.GameInterface.ProjectUtils;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.Utils.Colors;
import flash.geom.Rectangle;
import gfx.core.UIComponent;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import GUIFramework.SFClipLoader
import com.Utils.ID32;

//Class
dynamic class GUI.LoginCharacterSelection.Login extends UIComponent
{
    //Constants
    private static var NAVIGATION_BAR_GAP:Number = 10;
    private static var TEXT_INPUT_DEFAULT_STROKE_COLOR:Number = 0x666666;
    private static var TEXT_INPUT_HIGHLIGHT_STROKE_COLOR:Number = 0x0795C3;
    
    //Properties
	public var visibleRect:flash.geom.Rectangle;
	
	private var m_Background:MovieClip;
    private var m_BackgroundTitle:MovieClip;
	private var m_NavigationBar:MovieClip;
	private var m_QuitButton:MovieClip;
	private var m_SettingsButton:MovieClip;
	private var m_AccountButton:MovieClip;
    private var m_CreditsButton:MovieClip;
	private var m_UsernameInput:MovieClip;
	private var m_PasswordInput:MovieClip;
	private var m_LoginButton:MovieClip;
	private var m_SteamPlayButton:MovieClip;
	private var m_SteamLinkButton:MovieClip;
	private var m_SteamCreditsButton:MovieClip;
	private var m_SteamQuitButton:MovieClip;
	private var m_SteamSettingsButton:MovieClip;
	private var m_KeyListener:Object;
	private var m_BackgroundInitialWidth:Number;
	private var m_BackgroundInitialHeight:Number;
	private var bgUrl:String;
	private var w:Number;
	private var h:Number;
	
    //Constructor
    public function Login()
    {
		Stage.scaleMode = "noScale"
		visibleRect = Stage["visibleRect"];
		m_BackgroundInitialWidth = 1920;
		m_BackgroundInitialHeight = 1080;
		
        m_KeyListener = new Object();
		
        m_KeyListener.onKeyUp = Delegate.create(this, KeyListenerEventHandler); 
		this.gotoAndPlay(1);
    }
    
    //Key Listener Event Handler
    private function KeyListenerEventHandler():Void
    {
		switch(Key.getCode())
		{
			case Key.ENTER:     if (Selection.getFocus() == m_PasswordInput.textField || Selection.getFocus() == m_UsernameInput.textField)
								{
									Selection.setFocus(null);
									LoginToCharacterSelection();
								}
								
								break;
			
			case Key.TAB:       if (Selection.getFocus() == m_PasswordInput.textField)
								{
									m_UsernameInput.focused = true;
								}
								else if (Selection.getFocus() == m_UsernameInput.textField)
								{
									m_PasswordInput.focused = true;
								}
		}        
		
		CheckInputFields();
    }
    
    //On Load
    private function configUI():Void
    {
        Key.addListener(m_KeyListener);
        
        CheckInputFields();
       
        m_QuitButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Quit");
        m_QuitButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
		m_SettingsButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_CharacterSelectView_Settings");
        m_SettingsButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
		m_AccountButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "AccountManager");
        m_AccountButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
        m_CreditsButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "CreditsAllCaps");
        m_CreditsButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
		m_UsernameInput.m_HolderText.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Username");
        m_UsernameInput.addEventListener("focusIn", this, "TextFieldFocusEventHandler");
        m_UsernameInput.addEventListener("focusOut", this, "TextFieldFocusEventHandler");

        m_PasswordInput.m_HolderText.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Password");
        m_PasswordInput.addEventListener("focusIn", this, "TextFieldFocusEventHandler");
        m_PasswordInput.addEventListener("focusOut", this, "TextFieldFocusEventHandler");
        
		m_LoginButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Login");
        m_LoginButton.m_ForwardArrow._alpha = 50;
        m_LoginButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
		
		m_SteamPlayButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_Steam_Play");
		m_SteamPlayButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
		
		m_SteamQuitButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Quit");
		m_SteamQuitButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
		
		m_SteamSettingsButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_CharacterSelectView_Settings");
		m_SteamSettingsButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
		
		m_SteamCreditsButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "CreditsAllCaps");
		m_SteamCreditsButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
		
		m_SteamLinkButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_Steam_Link");
		m_SteamLinkButton.SignalButtonSelected.Connect(SlotButtonSelected, this);

        var userName:String = DistributedValue.GetDValue("Login_UserName", "");
        
        if (userName.length > 0)
        {
            m_UsernameInput.text = userName;
            m_UsernameInput.focused = true;
        }
		        
		LayoutHandler();
    }
    
    //On Unload
    private function onUnload():Void
    {
		Key.removeListener(m_KeyListener);
    }

    //Check Input Fields
    private function CheckInputFields():Void
    {
        if (m_UsernameInput.textField.text == "" || m_PasswordInput.textField.text == "")
        {
            m_LoginButton.disabled = true;
            m_LoginButton.m_ForwardArrow._alpha = 50;
        }
        else
        {
            m_LoginButton.disabled = false;
            m_LoginButton.m_ForwardArrow._alpha = 100;
        }
    }
    
    //Slot Button Selected
    public function SlotButtonSelected(target:Object):Void
    {        
        switch (target)
        {
			case m_SteamQuitButton:
            case m_QuitButton:      AccountManagement.GetInstance().QuitGame();
                                    break;
            
			case m_SteamSettingsButton:
            case m_SettingsButton:  DistributedValue.SetDValue("mainmenu_window", true);
                                    break;
            
			case m_SteamLinkButton:
            case m_AccountButton:   AccountManagement.GetInstance().ShowAccountPage();
                                    break;
            
			case m_SteamCreditsButton:
            case m_CreditsButton:   //SFClipLoader.LoadClip( "MediaPlayer.swf", "MediaPlayer", false, _global.Enums.ViewLayer.e_ViewLayerSplashScreenTop, 1, [{ Image: new ID32( _global.Enums.RDBID.e_RDB_FlashFile, 7740079 ) }] );
                                    DistributedValue.SetDValue("credits_window", true);
                                    break;
                                    
            case m_SteamPlayButton:
			case m_LoginButton:     LoginToCharacterSelection();
                                    break;
        }
    }
    
    //Login To Character Selection
    private function LoginToCharacterSelection():Void
    {
        AccountManagement.GetInstance().LoginAccount(m_UsernameInput.text, m_PasswordInput.text);
		m_PasswordInput.text = "";
    }
    
    //Text Field Focus Event Handler
	private function TextFieldFocusEventHandler(event:Object):Void
	{
		Selection.setSelection(0, event.target.text.length);
        
        switch (event.type)
        {
            case "focusIn":     Colors.ApplyColor(event.target.m_Stroke, TEXT_INPUT_HIGHLIGHT_STROKE_COLOR);
                                event.target.m_HolderText._visible = false;
                                break;
                                    
            case "focusOut":    Colors.ApplyColor(event.target.m_Stroke, TEXT_INPUT_DEFAULT_STROKE_COLOR);
                                event.target.m_HolderText._visible = (event.target.textField.text == "") ? true : false;
        }
	}
	
    //Layout Handler
	public function LayoutHandler():Void
	{		
        SetupBackground();
        
		w = Stage.width;
		h = Stage.height;
		
		var scale:Number = h/m_BackgroundInitialHeight;
		m_Background._xscale = m_Background._yscale = scale * 100;			
		
		m_Background._x = w/2 - m_Background._width/2;
		m_Background._y = h/2 - m_Background._height/2;
		
		m_BackgroundTitle._xscale = m_BackgroundTitle._yscale = scale * 100;
		m_BackgroundTitle._x = w - m_BackgroundTitle._width - 30;
		m_BackgroundTitle._y = h - m_NavigationBar._height - m_BackgroundTitle._height - 30;
		
		if (!AccountManagement.GetInstance().IsSteamClient())
		{
			m_SteamPlayButton._visible = false;
			m_SteamQuitButton._visible = false;
			m_SteamSettingsButton._visible = false;
			m_SteamCreditsButton._visible = false;
			m_SteamLinkButton._visible = false;
			
			m_NavigationBar._x = 0;
			m_NavigationBar._y = Stage.height - m_NavigationBar._height;
			m_NavigationBar._width = w + 2;
	
			m_QuitButton._x = NAVIGATION_BAR_GAP;
			VerticallyCenterButton(m_QuitButton);
			
			m_SettingsButton._x = m_QuitButton._x + m_QuitButton.m_Background._width + NAVIGATION_BAR_GAP;
			VerticallyCenterButton(m_SettingsButton);
			
			m_AccountButton._x = m_SettingsButton._x + m_SettingsButton.m_Background._width + NAVIGATION_BAR_GAP;
			VerticallyCenterButton(m_AccountButton);
			
			m_CreditsButton._x = m_AccountButton._x + m_AccountButton.m_Background._width + NAVIGATION_BAR_GAP;
			VerticallyCenterButton(m_CreditsButton);
			
			m_LoginButton._x = w - m_LoginButton.m_Background._width - NAVIGATION_BAR_GAP;
			VerticallyCenterButton(m_LoginButton);
	
			m_PasswordInput._x = m_LoginButton._x - m_PasswordInput._width - NAVIGATION_BAR_GAP;
			VerticallyCenterTextField(m_PasswordInput);
	
			m_UsernameInput._x = m_PasswordInput._x - m_UsernameInput._width - NAVIGATION_BAR_GAP;
			VerticallyCenterTextField(m_UsernameInput);
		}
		else
		{
			m_NavigationBar._visible = false;
			m_QuitButton._visible = false;
			m_SettingsButton._visible = false;
			m_AccountButton._visible = false;
			m_CreditsButton._visible = false;
			m_LoginButton._visible = false;
			m_PasswordInput._visible = false;
			m_UsernameInput._visible = false;
			
			
			m_SteamPlayButton._xscale = m_SteamPlayButton._yscale = scale * 100;
			m_SteamPlayButton._x = w/2 - m_SteamPlayButton._width/2;
			m_SteamPlayButton._y = h - m_SteamPlayButton._height - 5;
			
			m_SteamQuitButton._xscale = m_SteamQuitButton._yscale = scale * 100;
			m_SteamQuitButton._x = 10;
			m_SteamQuitButton._y = h - m_SteamQuitButton._height - 5;
			
			m_SteamSettingsButton._xscale = m_SteamSettingsButton._yscale = scale * 100;
			m_SteamSettingsButton._x = m_SteamQuitButton._x + m_SteamQuitButton._width + 10;
			m_SteamSettingsButton._y = h - m_SteamSettingsButton._height - 5;
			
			m_SteamCreditsButton._xscale = m_SteamCreditsButton._yscale = scale * 100;
			m_SteamCreditsButton._x = m_SteamSettingsButton._x + m_SteamSettingsButton._width + 10;
			m_SteamCreditsButton._y = h - m_SteamCreditsButton._height - 5;
			
			m_SteamLinkButton._xscale = m_SteamLinkButton._yscale = scale * 100;
			m_SteamLinkButton._x = w - m_SteamLinkButton._width - 10;
			m_SteamLinkButton._y = h - m_SteamLinkButton._height - 5;
		}
		if (m_ShowFacebookPrompt && !m_FacebookPrompt)
		{
			ShowFacebookPrompt();
		}
	}
    
    //Setup Background
    private function SetupBackground():Void
	{
        var stageRect:Rectangle = Stage["visibleRect"];		        
        AnimateBackground();
	}
    
    //Animate Background
    private function AnimateBackground():Void
    {

    }
    
    //Vertically Center Button
    private function VerticallyCenterButton(target:MovieClip):Void
    {
        target._y = m_NavigationBar._y + (m_NavigationBar._height / 2) - (target.m_Background._height / 2);
    }
    
    //Vertically Center Text Field
    private function VerticallyCenterTextField(target:MovieClip):Void
    {
        target._y = m_NavigationBar._y + (m_NavigationBar._height / 2) - (target.m_Stroke._height / 2) + 2;
    }
}
