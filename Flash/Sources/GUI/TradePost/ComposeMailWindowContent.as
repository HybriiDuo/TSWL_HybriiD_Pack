//Imports
import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.Utils.Signal;
import mx.utils.Delegate;
import com.GameInterface.Tradepost;
import com.GameInterface.Game.Character;
import com.GameInterface.DistributedValue;
import com.Components.WindowComponentContent;
import GUI.TradePost.ComposeMailFriendsList;
import gfx.controls.Button;
import gfx.controls.TextInput;
import gfx.controls.TextArea;
import com.GameInterface.Friends;
import com.GameInterface.Guild.GuildBase;
import com.Components.FCButton;

//Class
class GUI.TradePost.ComposeMailWindowContent extends WindowComponentContent
{
    //Constants
    private static var MAX_EMAIL_CHARACTERS:Number = 3000;
    private static var HEADER_BUTTONS_GAP:Number = 4;
    
    private static var TO_LABEL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ToLabel");
    private static var MESSAGE_LABEL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_MessageLabel");
    private static var ERROR_SENDING_MAIL_MESSAGE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ErrorSendingMail");
    private static var SEND_MAIL_SUCCESS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_SendMailSuccess");
    private static var ERROR_ATTACHING_TO_MAIL:String = LDBFormat.LDBGetText("Tradepost", "AttachItemToMailError_ItemCanNotBeMailed");
    private static var SEND:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Send");
    private static var FRIENDS_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("Tradepost", "composeMailFriendRecipientTooltip");
    private static var CABAL_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("Tradepost", "composeMailGuildMemberRecipientTooltip");
    
    //Properties
    public var SignalCloseWindow:Signal;
    
    private var m_ToLabel:MovieClip;
    private var m_ToInput:TextInput;
    private var m_FriendsButton:FCButton;
    private var m_CabalButton:FCButton;
    private var m_BodyLabel:MovieClip;
    private var m_BodyInput:TextArea;
    private var m_SendButton:MovieClip;
    private var m_FriendsList:MovieClip;
        
    private var m_KeyListener:Object;
    
    //Constructor
    public function ComposeMailWindowContent()
    {
        super();
        
        SignalCloseWindow = new Signal();
		
        var keylistener:Object = new Object();
        keylistener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(keylistener);
    }
    
    //Config UI
    private function configUI():Void 
    {
        super.configUI();
        
        m_ToLabel.text = TO_LABEL;
        m_BodyLabel.text = MESSAGE_LABEL;
        
        m_ToInput.addEventListener("textChange", this, "UpdateSendButtonState");
        m_ToInput.textField.restrict = "0-9a-zA-ZàáâäåÀÁÂÃæÆçÇêéëèÊËÉÈïíîìÍÌÎÏñÑœŒôöòõóøÓÔÕØÖÒšŠúüûùÙÚÜÛÿŸýÝžŽ\\-"; //Character nicknames may only contain letters, numbers and hyphens.
        m_ToInput.maxChars = 40;
        
        m_FriendsButton.disabled = (Friends.GetTotalFriends() == 0) ? true : false;
        m_FriendsButton.disableFocus = true;
        m_FriendsButton.addEventListener("click", this, "ButtonClickHandler");
        m_FriendsButton.SetTooltipText(FRIENDS_BUTTON_TOOLTIP);
        
        m_CabalButton.disabled = (!GuildBase.HasGuild()) ? true : false;
        m_CabalButton.disableFocus = true;
        m_CabalButton.addEventListener("click", this, "ButtonClickHandler");
        m_CabalButton.SetTooltipText(CABAL_BUTTON_TOOLTIP);
        
        m_BodyInput.addEventListener("textChange", this, "UpdateSendButtonState");
        m_BodyInput.maxChars = MAX_EMAIL_CHARACTERS;
      
        m_SendButton.textField.autoSize = "center";
        m_SendButton.label = SEND;
        m_SendButton.disabled = true;
        m_SendButton.disableFocus = true;
        m_SendButton.addEventListener("click", this, "ButtonClickHandler");        
        
        if ( DistributedValue.DoesVariableExist("compose_mail_reply_to") )
        {
            var replyTo:String = DistributedValue.GetDValue("compose_mail_reply_to");
            DistributedValue.DeleteVariable("compose_mail_reply_to");
            m_ToInput.text = replyTo;
        }
        
        m_FriendsList = attachMovie("FriendsList", "m_FriendsList", getNextHighestDepth());
        m_FriendsList.SignalButtonResponse.Connect(SlotFriendsListResponse, this);
        m_FriendsList._x = width / 2 - m_FriendsList._width / 2;
        m_FriendsList._y = height / 2 - m_FriendsList._height / 2;
        
        SelectToInputField();
    }
    
    //On Unload
    private function onUnload():Void
    {
        Key.removeListener(m_KeyListener);
        Tradepost.CancelComposeMail();
    }
    
    //Slot Friends List Response
    private function SlotFriendsListResponse(selectedName:String):Void
    {
        if (selectedName)
        {
            m_ToInput.text = selectedName;
        }
        
        DisableControls(false);
        SelectToInputField();
    }
    
    //Update Send Button State
    private function UpdateSendButtonState():Void
    {
        var cash:Number = m_MailAttachments.m_ItemCounter.amount;
        var bodyString:String = m_BodyInput.text.split(" ").join("");
        
        m_SendButton.disabled = ((m_ToInput.text == "") || ((bodyString == "") && !HasItemsAttached() && cash == 0)) ? true : false;
    }
    
    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        switch(Key.getCode())
        {
            case Key.TAB:       if (Selection.getFocus() == m_ToInput.textField)
                                {
                                    Selection.setFocus(m_BodyInput.textField);
                                }
                                else if (Selection.getFocus() == m_BodyInput.textField)
                                {
                                    Selection.setFocus(m_ToInput.textField);
                                }
                                
                                break;

            case Key.ENTER:     if (Selection.getFocus() == m_ToInput.textField)
                                {
                                    Selection.setFocus(m_BodyInput.textField);
                                }	
                                
                                break;
        }
        
    }
    
    //Button Click Handler
    private function ButtonClickHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_FriendsButton:   DisableControls(true);
                                    m_FriendsList.OpenList(ComposeMailFriendsList.FRIENDS_LIST_TYPE);
                                    
                                    break;
                                    
            case m_CabalButton:     DisableControls(true);
                                    m_FriendsList.OpenList(ComposeMailFriendsList.CABAL_LIST_TYPE);
                                    
                                    break;
                                    
            case m_SendButton:      m_SendButton.disabled = true;
                                    Tradepost.SignalMailResult.Connect(SlotMailSent, this);
                                    Tradepost.SendMail( m_ToInput.text, m_BodyInput.text, 0 );
                                    
                                    break;
        }
    }

    //Disable Controls
    private function DisableControls(toggle:Boolean):Void
    {
        m_ToInput.disabled = toggle;
        m_BodyInput.disabled = toggle;
        
        UpdateSendButtonState();
    }
    
    //Select To Input Field
    private function SelectToInputField():Void
    {
        Selection.setFocus(m_ToInput.textField);
        Selection.setSelection(m_ToInput.textField.text.length, m_ToInput.textField.text.length);
    }
    
    private function SlotMailSent(succeed:Boolean, message:String):Void
    {
        Tradepost.SignalMailResult.Disconnect(SlotMailSent, this);
        if (succeed)
        {
            m_ToInput.text = "";
            m_BodyInput.text = "";
            com.GameInterface.Chat.SignalShowFIFOMessage.Emit(SEND_MAIL_SUCCESS, 0)
            SignalCloseWindow.Emit();
        }
    }
}