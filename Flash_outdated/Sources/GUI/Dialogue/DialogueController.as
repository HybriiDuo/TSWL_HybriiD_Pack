import com.GameInterface.Utils;
import com.GameInterface.Log;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.Utils.ID32;
import com.GameInterface.DialogueBase;
import com.GameInterface.QuestsBase;
import com.GameInterface.VicinitySystem;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.Character;

var m_DialogueWindows:Object;

function onLoad()
{
	m_DialogueWindows = new Object();

    VicinitySystem.SignalDynelEnterVicinity.Connect( SlotDialogueEnterVicinity, this );
    VicinitySystem.SignalDynelLeaveVicinity.Connect( SlotDialogueLeaveVicinity, this );
    DialogueBase.SignalOpenChatWindow.Connect( SlotOpenDialogue, this );
    DialogueBase.SignalCloseChatWindow.Connect( SlotCloseDialogue, this );
    DialogueBase.SignalNPCChatTextReceived.Connect( SlotNPCChatTextReceived, this );
    DialogueBase.SignalNPCChatQuestionListReceived.Connect( SlotNPCChatQuestionListReceived, this );
    DialogueBase.SignalConversationInfoReceived.Connect( SlotConversationInfoReceived, this );
	QuestsBase.SignalOpenMissionWindow.Connect(SlotOpenMissionWindow, this);
}

function OnUnload()
{
	for (var prop in m_DialogueWindows)
	{
		if (m_DialogueWindows[prop] != undefined)
		{
			m_DialogueWindows[prop].EndConversation();
		}
	}
}

function ResizeHandler() : Void
{
	var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
	_y = visibleRect.y;
	_x = visibleRect.x;
}

function SlotDialogueEnterVicinity( dynelID:ID32)
{
	var dynel:Dynel = Dynel.GetDynel(dynelID);
	if (dynel.HasDialogue() || dynel.IsMissionGiver())
	{
		var dialogueWindow:MovieClip = m_DialogueWindows[dynelID];

		if ( dialogueWindow == undefined)
		{
			dialogueWindow = CreateDialogueWindow( dynelID);
		}
	}
}
function SlotDialogueLeaveVicinity( dynelID:ID32 )
{
	var window = m_DialogueWindows[dynelID];
	if (window != undefined)
	{
		window.tweenTo( 0.4, { _alpha:0 }, None.easeNone )
		window.onTweenComplete = function()
		{
			this.removeMovieClip();
		}
		m_DialogueWindows[dynelID].EndConversation();
		m_DialogueWindows[dynelID] = undefined;
	}
}

function SlotOpenMissionWindow(dynelID:ID32)
{
	var window = m_DialogueWindows[dynelID];
	if (window != undefined)
	{
		window.tweenEnd();
		if (!window.IsLocked())
		{
			window.LockToScreen(true);
			var lockX:Number = Stage["visibleRect"].width/2 + 100;
			var lockY:Number = Stage["visibleRect"].height/2 - window._height/2 - 100;
			window.tweenTo(0.5, {_x:lockX, _y:lockY, _xscale:90, _yscale:90}, None.easeNone)
			window.OpenFirstIncompleteMission();
		}
		else
		{
			window.LockToScreen(false);
			window.CloseAllMissionClips();
			window.CloseDialogue();
		}
	}
}

function SlotOpenDialogue(npcID:ID32)
{
}

function SlotCloseDialogue(npcID:ID32)
{
	if (m_DialogueWindows.hasOwnProperty(npcID.GetInstance().toString()))
	{
		m_DialogueWindows[npcID.GetInstance()].CloseDialogue();
	}
}

function SlotNPCChatTextReceived(npcID:ID32, text:String, type:Number)
{
}

function SlotNPCChatQuestionListReceived(npcID:ID32, questionArray:Array)
{
	if (m_DialogueWindows.hasOwnProperty(npcID.toString()))
	{
		m_DialogueWindows[npcID].SetQuestions(questionArray);
	}
}

function SlotConversationInfoReceived(npcID:ID32, topicDepthArray:Array)
{
	if (m_DialogueWindows.hasOwnProperty(npcID.toString()))
	{
		m_DialogueWindows[npcID].SetTopicDepths(topicDepthArray);
	}	
}

function CreateDialogueWindow(dynelID:ID32) : MovieClip
{
    var initObject:Object = new Object();
    initObject["m_DynelID"] =  dynelID;
	var window = this.attachMovie("DialogueWindow", "DialogueWindow" + dynelID.GetType()+"_"+dynelID.GetInstance(), this.getNextHighestDepth(), initObject );
	m_DialogueWindows[dynelID] = window;
    return window;
}
