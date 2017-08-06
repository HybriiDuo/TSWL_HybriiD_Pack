import com.GameInterface.DistributedValue;
class com.Utils.Text
{
    /**
     * Method that tries to mimic the getTextExtent method in the TextFormat class, for now it only returns an object with the width and height property set
     * @param text:String - the knubot string or any other string
     * @param format:TextFormat - the textformat to use when getting the text extent
     * @param context:MovieClip - the context to create the textfield in, useful to get the textformat
     * @return Object - an object with the property, width and height set
     */
    public static function GetTextExtent( text:String, format:TextFormat, context:MovieClip) : Object
    {
        context = (context == null) ? _root : context;
        var textExtent:Object = { };
        
        var textfield:TextField = context.createTextField("tmp", context.getNextHighestDepth(), 0, 0, 0, 0);
        textfield.multiline = false;
        textfield.autoSize = "left";
        textfield.setNewTextFormat( format );
        textfield.text = "";
        textfield.text = text;
        
        textExtent["width"] = textfield._width;
        textExtent["height"] = textfield._height;
        
        textfield.removeTextField();
        
        return textExtent;
    }
	
	/**
	* This method returns a string of formatted numbers with commas inserted in the
	* thousands place for readability.
	*/
	public static function AddThousandsSeparator(inputNum:Number) : String
	{
		var delimiter:String = " ";
		if (DistributedValue.GetDValue("Language") == "en");
		{
			delimiter = ",";
		}
		var numString:String = inputNum.toString();
		var resultString:String = "";
		while(numString.length > 3)
		{
			var chunk:String = numString.substr(-3);
			numString = numString.substr(0, numString.length - 3);
			resultString = delimiter + chunk + resultString;
		}
		resultString = numString + resultString;
		return resultString;
	}
}