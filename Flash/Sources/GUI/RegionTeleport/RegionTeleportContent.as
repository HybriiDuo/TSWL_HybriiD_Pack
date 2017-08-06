import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import gfx.controls.Button;
import com.GameInterface.LoreNode;
import com.GameInterface.Lore;
import com.GameInterface.DistributedValue;
import com.GameInterface.SpellBase;
import com.GameInterface.Game.Character;
import com.Utils.Colors;
import GUI.RegionTeleport.RegionTeleportScrollPanel;

class GUI.RegionTeleport.RegionTeleportContent extends WindowComponentContent
{
	//Components created in .fla
	private var m_TeleportButton:Button;
	private var m_ScrollPanel:RegionTeleportScrollPanel;
	private var m_SelectPanelBG:MovieClip;
	private var m_SelectedDescription:TextField;
	private var m_SelectedTitle:TextField;
	private var m_SelectedMedia:MovieClip;
	private var m_ErrorText:TextField;

	//Variables
	private var m_FocusedTag:Number;

	//Statics
	private static var SELECT_PANEL_PADDING:Number = 10;
	private static var DEFAULT_IMAGE_RDB:Number = 9228446;
	private static var LDB_COOLDOWN:String = LDBFormat.LDBGetText("GenericGUI", "RegionTeleport_OnCooldown");
	private static var LDB_LOCKED:String = LDBFormat.LDBGetText("GenericGUI", "RegionTeleport_Locked");
	
	public function RegionTeleportContent()
	{
		super();
	}
	
	private function configUI():Void
	{
		m_TeleportButton.disableFocus = true;
		m_TeleportButton.addEventListener("click", this, "TeleportClickHandler");
		
		m_ScrollPanel.SetData(Lore.GetTeleportTree());
		m_ScrollPanel.SignalEntryFocused.Connect(SlotEntryFocused, this);
		m_ScrollPanel.SignalEntryActivated.Connect(SlotEntryActivated, this);
		SetLabels();
		FocusDefaultEntry();
	}
	
	private function SetLabels():Void
	{
		m_TeleportButton.label = LDBFormat.LDBGetText("GenericGUI", "RegionTeleport_Teleport");
	}
	
	private function SlotEntryFocused(loreNode:LoreNode):Void
	{
		UpdateFocusedEntry(loreNode);
	}
	
	private function SlotEntryActivated(nodeId:Number):Void
	{
		SpellBase.CastTeleportFromTag(nodeId);
		DistributedValue.SetDValue("regionTeleport_window", false);
	}
	
	private function FocusDefaultEntry():Void
	{
		m_SelectedTitle.text = LDBFormat.LDBGetText("GenericGUI", "RegionTeleport_DefaultTitle");
		m_SelectedDescription.text = LDBFormat.LDBGetText("GenericGUI", "RegionTeleport_DefaultDescription");
		m_TeleportButton.visible = false;
		m_ErrorText._visible = false;
		if (m_SelectedMedia != undefined)
		{
			m_SelectedMedia.removeMovieClip();
		}
		m_SelectedMedia = this.createEmptyMovieClip("m_SelectedMedia", this.getNextHighestDepth());
        LoadImage(m_SelectedMedia, DEFAULT_IMAGE_RDB);
	}
	
	private function UpdateFocusedEntry(loreNode:LoreNode):Void
	{
		m_FocusedTag = loreNode.m_Id;
		m_SelectedTitle.text = loreNode.m_Parent.m_Name + " - " + loreNode.m_Name;
		m_SelectedDescription.text = Lore.GetTagText(loreNode.m_Id);
		
		if (Character.GetClientCharacter().m_InvisibleBuffList[Lore.GetTagTeleportLockout(loreNode.m_Id)] != undefined)
		{
			m_TeleportButton._visible = false;
			m_ErrorText.text = LDB_COOLDOWN;
			m_ErrorText.textColor = Colors.e_ColorLightRed;
			m_ErrorText._visible = true;
		}
		else if(Lore.IsLocked(loreNode.m_Id))
		{
			m_TeleportButton._visible = false;
			m_ErrorText.text = LDB_LOCKED;
			m_ErrorText.textColor = Colors.e_ColorDarkGray;
			m_ErrorText._visible = true;
		}
		else
		{
			m_TeleportButton.visible = true;
			m_ErrorText._visible = false;
		}
		
		if (m_SelectedMedia != undefined)
		{
			m_SelectedMedia.removeMovieClip();
		}
		m_SelectedMedia = this.createEmptyMovieClip("m_SelectedMedia", this.getNextHighestDepth());
        LoadImage(m_SelectedMedia, loreNode.m_Icon);
	}
	
	private function LoadImage(container:MovieClip, mediaId:Number)
    {
		var imageLoader:MovieClipLoader = new MovieClipLoader();
        
        var path = com.Utils.Format.Printf( "rdb:%.0f:%.0f", _global.Enums.RDBID. e_RDB_GUI_Image, mediaId );
	
		imageLoader.addListener( this );
		imageLoader.loadClip( path, container );
    }
	
	private function onLoadInit( target:MovieClip )
    {
        target._y = m_SelectedTitle._y + m_SelectedTitle._height + SELECT_PANEL_PADDING;
        
        var imagePadding:Number = 4
        var h:Number = target._height;
        var w:Number = target._width;
        
        target.lineStyle(2, 0xFFFFFF);
        target.moveTo( -imagePadding, -imagePadding);
        target.lineTo( w + imagePadding, -imagePadding);
        target.lineTo( w + imagePadding, h + imagePadding);
        target.lineTo( -imagePadding, h + imagePadding);
        target.lineTo( -imagePadding, -imagePadding);
        
        target._x = m_SelectedTitle._x + m_SelectedTitle._width/2 - target._width/2;
		
		m_BonusSymbol._x = target._x + target._width - m_BonusSymbol._width - 10;
		m_BonusSymbol._y = target._y + target._height - m_BonusSymbol._height - 15;
		
		m_SelectedDescription._y = target._y + target._height + SELECT_PANEL_PADDING;
		m_SelectedDescription._height = m_TeleportButton._y - m_SelectedDescription._y + SELECT_PANEL_PADDING;
    }
	
	private function TeleportClickHandler():Void
	{
		SpellBase.CastTeleportFromTag(m_FocusedTag);
		DistributedValue.SetDValue("regionTeleport_window", false);
	}
}