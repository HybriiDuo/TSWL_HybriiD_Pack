
var m_ComputerInterfaceWindow:MovieClip;

function onLoad()
{
 //   Log.Info2("Keypad", "onLoad()")    
}

//On Load
//function onLoad()
function LoadArgumentsReceived(args:Array):Void
{
    var skin:String = this[args[0]];
    m_ComputerInterfaceWindow.SetLayout(skin);
}
