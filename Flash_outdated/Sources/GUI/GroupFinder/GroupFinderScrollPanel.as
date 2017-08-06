import gfx.core.UIComponent;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import mx.utils.Delegate;
import GUI.GroupFinder.PlayfieldEntry;
import com.GameInterface.Game.TeamInterface;
import com.Utils.LDBFormat;
import com.Utils.Signal;

class GUI.GroupFinder.GroupFinderScrollPanel extends UIComponent
{
	//Components created in .fla
	private var m_Background:MovieClip;
	
	//Variables
	private var m_ListContent:MovieClip;
	private var m_Mask:MovieClip;
	private var m_ScrollBar:MovieClip;
	private var m_PlayfieldEntries:Array;
	private var m_AllDisabled:Boolean;
	
	public var SignalEntryToggled:Signal;
	public var SignalEntryFocused:Signal;

	//Statics
	private static var TDB_RANDOM_DUNGEONS = LDBFormat.LDBGetText("GroupSearchGUI", "RandomDungeons");
	private static var TDB_RANDOM_NIGHTMARE_DUNGEON_MAIN = LDBFormat.LDBGetText("GroupSearchGUI", "RandomNightmareDungeonMain");
	private static var TDB_RANDOM_NIGHTMARE_DUNGEON_AEGIS = LDBFormat.LDBGetText("GroupSearchGUI", "RandomNightmareDungeonAegis");
	private static var TDB_RANDOM_ELITE_DUNGEON = LDBFormat.LDBGetText("GroupSearchGUI", "RandomEliteDungeon");
	private static var TDB_RANDOM_ELITE_DUNGEON_AEGIS = LDBFormat.LDBGetText("GroupSearchGUI", "RandomEliteDungeonsAegis");
	private static var TDB_DUNGEONS = LDBFormat.LDBGetText("GroupSearchGUI", "dungeons");
	private static var TDB_RAIDS = LDBFormat.LDBGetText("GroupSearchGUI", "Raid");
	private static var TDB_SCENARIOS = LDBFormat.LDBGetText("GroupSearchGUI", "Scenarios");
	private static var TDB_PVP = LDBFormat.LDBGetText("GroupSearchGUI", "PvP");
	private static var TDB_NORMAL = LDBFormat.LDBGetText("GroupSearchGUI", "normalDifficulty");
	private static var TDB_ELITE = LDBFormat.LDBGetText("GroupSearchGUI", "eliteDifficulty");
	private static var TDB_ELITE_HEADER = LDBFormat.LDBGetText("GroupSearchGUI", "eliteHeader");
	private static var TDB_SOLO = LDBFormat.LDBGetText("GroupSearchGUI", "solo");
	private static var TDB_DUO = LDBFormat.LDBGetText("GroupSearchGUI", "duo");
	private static var TDB_NIGHTMARE = LDBFormat.LDBGetText("GroupSearchGUI", "nightmareDifficulty");
	private static var TDB_ERROR_RANDOM_SELECTED = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorRandomSelected");
	private static var TDB_ERROR_IN_RAID = LDBFormat.LDBGetText("GroupSearchGUI", "ErrorInRaid");
	
	private static var ENTRY_PADDING:Number = 1;
	private static var SCROLL_SPEED:Number = 10;
	private static var SCROLL_PADDING:Number = 3;
	
	//private static var RANDOM_DUNGEONS:Number = 0;
	private static var DUNGEONS:Number = 0;
	private static var SCENARIOS:Number = 1;
	private static var PVP:Number = 2;
	//private static var RAIDS:Number = 4;
	
	private static var HEADER_ENTRY = -1;
	private static var DUNGEON_NM_MAIN_IMAGE:Number = 9136837;
	private static var DUNGEON_NM_AEGIS_IMAGE:Number = 9136845;
	private static var DUNGEON_ELITE_IMAGE:Number = 9136843;
	private static var DUNGEON_ELITE_AEGIS_IMAGE:Number = 9136845;
	private static var SCENARIOS_IMAGE:Number = 9306829;
	
	public function GroupFinderScrollPanel() 
	{
		super();
		SignalEntryToggled = new Signal();
		SignalEntryFocused = new Signal();
		m_AllDisabled = false;
	}
	
	public function SetData(dungeonPlayfields:Array, raidPlayfields:Array, scenarioPlayfields:Array, pvpPlayfields:Array):Void
	{
		RemoveContent();
		CreateContent(dungeonPlayfields, raidPlayfields, scenarioPlayfields, pvpPlayfields);
	}
	
	private function CreateContent(dungeonPlayfields:Array, raidPlayfields:Array, scenarioPlayfields:Array, pvpPlayfields:Array):Void
	{
		m_PlayfieldEntries = new Array();
		m_ListContent = this.createEmptyMovieClip("m_ListContent", this.getNextHighestDepth());
		
		//var randomDungeonEntry:PlayfieldEntry = PlayfieldEntry(m_ListContent.attachMovie("PlayfieldEntry", "PlayfieldEntry_RandomDungeons", m_ListContent.getNextHighestDepth()));
		//var randomDungeonsArray:Array = GetRandomDungeonsArray();
		//randomDungeonEntry.SetData(TDB_RANDOM_DUNGEONS, HEADER_ENTRY, 0 /*no difficulty*/, 0 /*no image*/, randomDungeonsArray, 0, false);
		//randomDungeonEntry.SignalEntrySizeChanged.Connect(LayoutEntries, this);
		//randomDungeonEntry.SignalEntryToggled.Connect(SlotRandomEntryToggled, this);
		//randomDungeonEntry.SignalEntryFocused.Connect(SlotEntryFocused, this);
		//m_PlayfieldEntries[RANDOM_DUNGEONS] = randomDungeonEntry;
		
		var normalDungeonsObject:Object = {playfieldName:TDB_NORMAL, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Normal, image:0, subEntries:GetPlayfieldsForDifficulty(dungeonPlayfields, _global.Enums.LFGDifficulty.e_Mode_Normal), depth:0, isRandom:false};
		var eliteDungeonsObject:Object = {playfieldName:TDB_ELITE_HEADER, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, image:0, subEntries:GetEliteDungeons(), depth:0, isRandom:false};
		//var nightmareDungeonsObject:Object = {playfieldName:TDB_NIGHTMARE, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Nightmare, image:0, subEntries:GetPlayfieldsForDifficulty(dungeonPlayfields, _global.Enums.LFGDifficulty.e_Mode_Nightmare), depth:0, isRandom:false};

		var dungeonEntry:PlayfieldEntry = PlayfieldEntry(m_ListContent.attachMovie("PlayfieldEntry", "PlayfieldEntry_Dungeons", m_ListContent.getNextHighestDepth()));
		var dungeonDifficultiesArray:Array = [/*nightmareDungeonsObject,*/ eliteDungeonsObject, normalDungeonsObject];
		dungeonEntry.SetData(TDB_DUNGEONS, HEADER_ENTRY, 0 /*no difficulty*/, 0 /*no image*/, dungeonDifficultiesArray, 0, false);
		dungeonEntry.SignalEntrySizeChanged.Connect(LayoutEntries, this);
		dungeonEntry.SignalEntryToggled.Connect(SlotEntryToggled, this);
		dungeonEntry.SignalEntryFocused.Connect(SlotEntryFocused, this);
		m_PlayfieldEntries[DUNGEONS] = dungeonEntry;		
		
		var eliteSoloScenariosObject:Object = {playfieldName:TDB_ELITE, queueId:_global.Enums.LFGQueues.e_ScenarioSoloElite1, difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, image:SCENARIOS_IMAGE, subEntries:new Array(), depth:1, isRandom:false};
		//var nightmareSoloScenariosObject:Object = {playfieldName:TDB_NIGHTMARE, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Nightmare, image:0, subEntries:GetPlayfieldsForDifficulty(scenarioPlayfields, _global.Enums.LFGDifficulty.e_Mode_Nightmare), depth:1, isRandom:false};
		var soloScenariosArray:Array = [eliteSoloScenariosObject/*, nightmareSoloScenariosObject*/];
		
		var eliteDuoScenariosObject:Object = {playfieldName:TDB_ELITE, queueId:_global.Enums.LFGQueues.e_ScenarioDuoElite1, difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, image:SCENARIOS_IMAGE, subEntries:new Array(), depth:1, isRandom:false};
		//var nightmareDuoScenariosObject:Object = {playfieldName:TDB_NIGHTMARE, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Nightmare, image:0, subEntries:GetPlayfieldsForDifficulty(scenarioPlayfields, _global.Enums.LFGDifficulty.e_Mode_DuoNightmare), depth:1, isRandom:false};
		var duoScenariosArray:Array = [eliteDuoScenariosObject/*, nightmareDuoScenariosObject*/];
		
		var soloScenariosObject:Object = {playfieldName:TDB_SOLO, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, image:0, subEntries:soloScenariosArray, depth:0, isRandom:false};
		var duoScenariosObject:Object = {playfieldName:TDB_DUO, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, image:0, subEntries:duoScenariosArray, depth:0, isRandom:false};
		
		var scenarioEntry:PlayfieldEntry = PlayfieldEntry(m_ListContent.attachMovie("PlayfieldEntry", "PlayfieldEntry_Scenarios", m_ListContent.getNextHighestDepth()));
		var scenarioDifficultiesArray:Array = [soloScenariosObject, duoScenariosObject];
		scenarioEntry.SetData(TDB_SCENARIOS, HEADER_ENTRY, _global.Enums.LFGDifficulty.e_Mode_Elite, 0, scenarioDifficultiesArray, 0, false);
		scenarioEntry.SignalEntrySizeChanged.Connect(LayoutEntries, this);
		scenarioEntry.SignalEntryToggled.Connect(SlotEntryToggled, this);
		scenarioEntry.SignalEntryFocused.Connect(SlotEntryFocused, this);
		m_PlayfieldEntries[SCENARIOS] = scenarioEntry;
		
		var pvpEntry:PlayfieldEntry = PlayfieldEntry(m_ListContent.attachMovie("PlayfieldEntry", "PlayfieldEntry_Scenarios", m_ListContent.getNextHighestDepth()));
		pvpEntry.SetData(TDB_PVP, HEADER_ENTRY, 0, 0, ParsePvPPlayfields(pvpPlayfields), 0, false);
		pvpEntry.SignalEntrySizeChanged.Connect(LayoutEntries, this);
		pvpEntry.SignalEntryToggled.Connect(SlotEntryToggled, this);
		pvpEntry.SignalEntryFocused.Connect(SlotEntryFocused, this);
		m_PlayfieldEntries[PVP] = pvpEntry;
		
		//var eliteRaidsObject:Object = {playfieldName:TDB_ELITE, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, image:0, subEntries:GetPlayfieldsForDifficulty(raidPlayfields, _global.Enums.LFGDifficulty.e_Mode_Elite), depth:0, isRandom:false};
		//var nightmareRaidsObject:Object = {playfieldName:TDB_NIGHTMARE, queueId:HEADER_ENTRY, difficulty:_global.Enums.LFGDifficulty.e_Mode_Nightmare, image:0, subEntries:GetPlayfieldsForDifficulty(raidPlayfields, _global.Enums.LFGDifficulty.e_Mode_Nightmare), depth:0, isRandom:false};
		
		//var raidEntry:PlayfieldEntry = PlayfieldEntry(m_ListContent.attachMovie("PlayfieldEntry", "PlayfieldEntry_Raids", m_ListContent.getNextHighestDepth()));
		//var raidDifficultiesArray:Array = [nightmareRaidsObject, eliteRaidsObject];
		//raidEntry.SetData(TDB_RAIDS, HEADER_ENTRY, 0 /*no difficulty*/, 0 /*no image*/, raidDifficultiesArray, 0, false);
		//raidEntry.SignalEntrySizeChanged.Connect(LayoutEntries, this);
		//raidEntry.SignalEntryToggled.Connect(SlotEntryToggled, this);
		//raidEntry.SignalEntryFocused.Connect(SlotEntryFocused, this);
		//m_PlayfieldEntries[RAIDS] = raidEntry;
		
		CreateScrollBar();
		//TODO: Save state?
		//randomDungeonEntry.Expand();
		dungeonEntry.Expand();
		//raidEntry.Expand();
		scenarioEntry.Expand();
		pvpEntry.Expand();
	}
	
	private function RemoveContent():Void
	{
		if (m_PlayfieldEntries != undefined)
		{
			m_PlayfieldEntries = undefined;
		}
		if (m_ListContent != undefined)
		{
			m_ListContent.removeMovieClip();
		}
		// remove the mask if any
        if (m_Mask != undefined)
        {
            this.setMask(null);
            m_Mask.removeMovieClip();
        }        
        // remove the scrollbar if any
        if (m_ScrollBar != undefined)
        {
            m_ScrollBar.removeMovieClip();
        }
	}
	
	private function LayoutEntries():Void
	{
		var entryY:Number = 0;
		for (var i:Number = 0; i<m_PlayfieldEntries.length; i++)
		{
			m_PlayfieldEntries[i]._y = entryY;
			m_PlayfieldEntries[i].LayoutSubEntries();
			entryY += m_PlayfieldEntries[i].GetFullHeight() + ENTRY_PADDING;
		}
		ContentSizeUpdated();
	}
	
	private function ContentSizeUpdated():Void
	{
		m_ScrollBar.setScrollProperties( m_Background._height, 0, m_ListContent._height - m_Background._height); 
		if (m_ListContent._height > m_Background._height)
		{
			Mouse.addListener( this );
			m_ScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
			if (m_ListContent._height + m_ListContent._y < m_Background._height)
			{
				m_ListContent.tweenEnd(false);
				m_ListContent.tweenTo(0.1, { _y: m_Background._height - m_ListContent._height }, None.easeNone);
			}
		}
		else
		{
			Mouse.removeListener( this );
			m_ScrollBar.removeEventListener("scroll", this, "OnScrollbarUpdate");
			m_ListContent.tweenEnd(false);
			m_ListContent.tweenTo(0.1, { _y: 0 }, None.easeNone);
			m_ScrollBar.position = 0;
		}
		UpdateScrollbarVisibility();
	}
	
	private function CreateScrollBar():Void
	{
		m_Mask = com.GameInterface.ProjectUtils.SetMovieClipMask(m_ListContent, this, m_Background._height);
		
		m_ScrollBar = attachMovie("ScrollBar", "m_ScrollBar", this.getNextHighestDepth());
		m_ScrollBar._y = 0
		m_ScrollBar._x = this._width - m_ScrollBar._width/2 + SCROLL_PADDING;
		m_ScrollBar.setScrollProperties( m_Background._height, 0, m_ListContent._height - m_Background._height); 
		m_ScrollBar._height = m_Background._height;
		m_ScrollBar.trackMode = "scrollPage"
		m_ScrollBar.trackScrollPageSize = m_Background._height;
		m_ScrollBar.disableFocus = true;
	}
	
	private function OnScrollbarUpdate(event:Object) : Void
    {
        var target:MovieClip = event.target;
        var pos:Number = event.target.position;
        
        m_ListContent._y = -pos;        
        Selection.setFocus(null);
    }
	
	private function onMouseWheel( delta:Number ):Void
    {
        if ( Mouse["IsMouseOver"]( this ) )
        {
            var newPos:Number = m_ScrollBar.position + -(delta * SCROLL_SPEED);
            var event:Object = { target : m_ScrollBar };
            
            m_ScrollBar.position = Math.min(Math.max(0.0, newPos), m_ScrollBar.maxPosition);
            
            OnScrollbarUpdate(event);
        }
    }
	
	private function UpdateScrollbarVisibility():Void
	{
		if (m_ListContent._height > m_Background._height)
		{
			m_ScrollBar._visible = true;
		}
		else
		{
			m_ScrollBar._visible = false;
		}
	}
	
	private function GetEliteDungeons()
	{
		var returnArray:Array = new Array();
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon1), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon1, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon2), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon2, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon3), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon3, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon4), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon4, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon5), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon5, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon6), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon6, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon7), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon7, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon8), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon8, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon9), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon9, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		returnArray.push({playfieldName: LDBFormat.LDBGetText("GroupSearchGUI", "QueueName_"+_global.Enums.LFGQueues.e_EliteRandomDungeon10), 
						  queueId:_global.Enums.LFGQueues.e_EliteRandomDungeon10, 
						  difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, 
						  image:DUNGEON_NM_MAIN_IMAGE,
						  subEntries:new Array(),
						  depth:-1 /*This will be overwritten*/,
						  isRandom:false});
		return returnArray;
	}
	
	private function GetPlayfieldsForDifficulty(playfields:Array, difficulty:Number):Array
	{
		var returnArray:Array = new Array();
		for (var i=0; i<playfields.length; i++)
		{
			if (playfields[i].HasDifficultyMode(difficulty))
			{
				returnArray.push({playfieldName:LDBFormat.LDBGetText("Playfieldnames", playfields[i].m_InstanceId), 
								  queueId:playfields[i].m_Queues[difficulty], 
								  difficulty:difficulty, 
								  image:playfields[i].m_Image,
								  subEntries:new Array(),
								  depth:-1 /*This will be overwritten*/,
								  isRandom:false});
			}
		}
		return returnArray;
	}
	
	private function ParsePvPPlayfields(playfields:Array):Array
	{
		var returnArray:Array = new Array();
		for (var i=0; i<playfields.length; i++)
		{
			returnArray.push({playfieldName:LDBFormat.LDBGetText("Playfieldnames", playfields[i].m_InstanceId), 
							  queueId:playfields[i].m_InstanceId, 
							  difficulty:_global.Enums.LFGDifficulty.e_Mode_Normal, 
							  image:playfields[i].m_Image,
							  subEntries:new Array(),
							  depth:-1 /*This will be overwritten*/,
							  isRandom:false});
		}
		return returnArray;
	}

	private function GetRandomDungeonsArray():Array
	{
		var randomDungeons:Array = new Array();
		randomDungeons.push({playfieldName:TDB_RANDOM_NIGHTMARE_DUNGEON_MAIN, queueId:_global.Enums.LFGQueues.e_DungeonRandomNMMain, difficulty:_global.Enums.LFGDifficulty.e_Mode_Nightmare, image:DUNGEON_NM_MAIN_IMAGE, subEntries:new Array(), depth:1, isRandom:true});
		randomDungeons.push({playfieldName:TDB_RANDOM_NIGHTMARE_DUNGEON_AEGIS, queueId:_global.Enums.LFGQueues.e_DungeonRandomNMAEGIS, difficulty:_global.Enums.LFGDifficulty.e_Mode_Nightmare, image:DUNGEON_NM_AEGIS_IMAGE, subEntries:new Array(), depth:1, isRandom:true});
		randomDungeons.push({playfieldName:TDB_RANDOM_ELITE_DUNGEON, queueId:_global.Enums.LFGQueues.e_DungeonRandomElite, difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, image:DUNGEON_ELITE_IMAGE, subEntries:new Array(), depth:1, isRandom:true});
		randomDungeons.push({playfieldName:TDB_RANDOM_ELITE_DUNGEON_AEGIS, queueId:_global.Enums.LFGQueues.e_DungeonRandomEliteAEGIS, difficulty:_global.Enums.LFGDifficulty.e_Mode_Elite, image:DUNGEON_ELITE_AEGIS_IMAGE, subEntries:new Array(), depth:1, isRandom:true});
		return randomDungeons;
	}
	
	private function SlotRandomEntryToggled(select:Boolean):Void
	{
		if (m_AllDisabled)
		{
			//Everything is disabled at a higher level
			return;
		}
		//Ignore the value passed in as it will only give you whether the top category is selected
		//We need to iterate over the random entries and determine if any of them are selected
		var selectedEntries:Array = new Array();
		//m_PlayfieldEntries[RANDOM_DUNGEONS].FillSelectedEntriesArray(selectedEntries);
		//Disable non random entries if there are random entries selected
		m_PlayfieldEntries[DUNGEONS].SetDisabled(selectedEntries.length > 0, TDB_ERROR_RANDOM_SELECTED, true);
		//m_PlayfieldEntries[RAIDS].SetDisabled(selectedEntries.length > 0, TDB_ERROR_RANDOM_SELECTED, true);
		m_PlayfieldEntries[SCENARIOS].SetDisabled(selectedEntries.length > 0, TDB_ERROR_RANDOM_SELECTED, true);
		m_PlayfieldEntries[PVP].SetDisabled(selectedEntries.length > 0, TDB_ERROR_RANDOM_SELECTED, true);
		SlotEntryToggled(select);
	}
	
	private function SlotEntryToggled(select:Boolean):Void
	{
		SignalEntryToggled.Emit();
	}
	
	private function SlotEntryFocused(id:Number, image:Number, isRandom:Boolean):Void
	{
		//m_PlayfieldEntries[RANDOM_DUNGEONS].SetFocusById(id);
		m_PlayfieldEntries[DUNGEONS].SetFocusById(id);
		//m_PlayfieldEntries[RAIDS].SetFocusById(id);
		m_PlayfieldEntries[SCENARIOS].SetFocusById(id);
		m_PlayfieldEntries[PVP].SetFocusById(id);
		SignalEntryFocused.Emit(id, image, isRandom);
	}
	
	public function GetSelectedEntries():Array
	{
		var selectedEntries:Array = new Array()
		//m_PlayfieldEntries[RANDOM_DUNGEONS].FillSelectedEntriesArray(selectedEntries);
		m_PlayfieldEntries[DUNGEONS].FillSelectedEntriesArray(selectedEntries);
		//m_PlayfieldEntries[RAIDS].FillSelectedEntriesArray(selectedEntries);
		m_PlayfieldEntries[SCENARIOS].FillSelectedEntriesArray(selectedEntries);
		m_PlayfieldEntries[PVP].FillSelectedEntriesArray(selectedEntries);
		return selectedEntries;
	}
	
	public function SetPrivateTeam(privateTeam:Boolean):Void
	{
		//m_PlayfieldEntries[RANDOM_DUNGEONS].SetPrivateTeam(privateTeam);
		m_PlayfieldEntries[DUNGEONS].SetPrivateTeam(privateTeam);
		//m_PlayfieldEntries[RAIDS].SetPrivateTeam(privateTeam);
		m_PlayfieldEntries[SCENARIOS].SetPrivateTeam(privateTeam);
		m_PlayfieldEntries[PVP].SetPrivateTeam(privateTeam);
	}
	
	public function DisableAllEntries(disable:Boolean, error:String):Void
	{
		m_AllDisabled = disable;
		//m_PlayfieldEntries[RANDOM_DUNGEONS].SetDisabled(disable, error, false);
		m_PlayfieldEntries[DUNGEONS].SetDisabled(disable, error, false);
		//m_PlayfieldEntries[RAIDS].SetDisabled(disable, error, false);
		m_PlayfieldEntries[SCENARIOS].SetDisabled(disable, error, false);
		m_PlayfieldEntries[PVP].SetDisabled(disable, error, false);
		
		//If we are re-enabling them, we need to rerun other checks
		if (disable == false)
		{
			SlotRandomEntryToggled(disable, TDB_ERROR_RANDOM_SELECTED, true);
			DisableNonRaidContent(TeamInterface.GetClientRaidInfo() != undefined);
		}
	}
	
	public function DisableNonRaidContent(disable:Boolean):Void
	{
		if (m_AllDisabled)
		{
			//Everything is disabled at a higher level
			return;
		}
		//m_PlayfieldEntries[RANDOM_DUNGEONS].SetDisabled(disable, TDB_ERROR_IN_RAID, true);
		m_PlayfieldEntries[DUNGEONS].SetDisabled(disable, TDB_ERROR_IN_RAID, true);
		m_PlayfieldEntries[SCENARIOS].SetDisabled(disable, TDB_ERROR_IN_RAID, true);
		m_PlayfieldEntries[PVP].SetDisabled(disable, TDB_ERROR_IN_RAID, true);
		//If we are re-enabling them, we need to rerun the random selection check
		if (disable == false)
		{
			SlotRandomEntryToggled(disable, TDB_ERROR_RANDOM_SELECTED, true);
		}
	}
}