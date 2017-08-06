import com.PatcherInterface.Patcher;

var SCROLLBAR_PADDING:Number = 10;

m_ScrollBar._x = m_Background._x + m_Background._width - m_ScrollBar._width - SCROLLBAR_PADDING - 2;
m_ScrollBar._y = SCROLLBAR_PADDING;
m_ScrollBar._height = m_Background._height - SCROLLBAR_PADDING * 2;

m_TextArea.html = true;

function SlotPatchNotesUpdated( txt:String )
{
    var notes_css = new TextField.StyleSheet();

    notes_css.onLoad = function(success:Boolean)
    {
       if (success)
        {
            m_TextArea.textField.styleSheet = notes_css;
            m_TextArea.htmlText =  _root.patcher.UpdateHRefTags( txt );
            m_TextArea.position = 2; 
            m_TextArea.position = 1;
            
        }
        else
        {
            m_TextArea.htmlText = "css failed to load!";
        }
    }

    notes_css.load("patchnote.css");
}

Patcher.SignalPatchNotesDownloaded.Connect( SlotPatchNotesUpdated, this );