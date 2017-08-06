﻿//Imports
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.Lore;

//Class
class GUI.SkillHive.CharacterSkillsList extends MovieClip
{	
	private static var AUXILLIARY_SLOT_ACHIEVEMENT:Number = 5437;
	private static var AUGMENT_SLOT_ACHIEVEMENT:Number = 6277;
	private static var AEGIS_SLOT_ACHIEVEMENT:Number = 6817;
	
    //Properties
    private var m_NumAnimating:Number;
    private var m_SkillCategories:Array;
    
    public var SignalStartAnimation:Signal;
    public var SignalStopAnimation:Signal;
    
    //Constructor
    public function CharacterSkillsList()
    {
        m_NumAnimating = 0;
        m_SkillCategories = new Array();
        
        SignalStartAnimation = new Signal();
        SignalStopAnimation = new Signal();
        
        var meleeCategoryTitle:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "MeleeCategoryTitle");
        var rangedCategoryTitle:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "RangedCategoryTitle");
        var magicCategoryTitle:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "MagicCategoryTitle");
        var chakrasCategoryTitle:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "ChakrasCategoryTitle");
        var auxilliaryCategoryTitle:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "AuxilliaryCategoryTitle");
		var augmentCategoryTitle:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "AugmentCategoryTitle");
		var aegisCategoryTitle:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "AegisCategoryTitle");		

        var categoriesArray:Array = new Array();
		
        categoriesArray.push({
                                title:      meleeCategoryTitle,
                                subSkills:  [_global.Enums.CharacterSkills.e_FistWeapons, 
											 _global.Enums.CharacterSkills.e_Blades, 
											 _global.Enums.CharacterSkills.e_Hammers]
                            });
        categoriesArray.push({
                                title:      rangedCategoryTitle,
                                subSkills:  [_global.Enums.CharacterSkills.e_DualPistols, 
											 _global.Enums.CharacterSkills.e_Shotgun, 
											 _global.Enums.CharacterSkills.e_AssaultRifle]
                            });
        categoriesArray.push({
                                title:      magicCategoryTitle,
                                subSkills:  [_global.Enums.CharacterSkills.e_Elementalism, 
											 _global.Enums.CharacterSkills.e_Blood,
											 _global.Enums.CharacterSkills.e_Chaos]
                            });
        categoriesArray.push({
                                title:      chakrasCategoryTitle,
                                subSkills:  [_global.Enums.CharacterSkills.e_HeadChakra, 
											 _global.Enums.CharacterSkills.e_UpperTorsoChakra, 
											 _global.Enums.CharacterSkills.e_LowerTorsoChakra]
                            });
		if (!Lore.IsLocked(AUXILLIARY_SLOT_ACHIEVEMENT))
		{
			categoriesArray.push({
									title:      auxilliaryCategoryTitle,
									subSkills:  [_global.Enums.CharacterSkills.e_FlameThrower, 
												 _global.Enums.CharacterSkills.e_RocketLauncher, 
												 _global.Enums.CharacterSkills.e_Whip, 
												 _global.Enums.CharacterSkills.e_ChainSaw, 
												 _global.Enums.CharacterSkills.e_QuantumWeapon]
								});
		}
		
		if (!Lore.IsLocked(AUGMENT_SLOT_ACHIEVEMENT))
		{
			categoriesArray.push({
								 	title:		augmentCategoryTitle,
									subSkills:	[_global.Enums.CharacterSkills.e_AugmentDamage, 
												 _global.Enums.CharacterSkills.e_AugmentSupport, 
												 _global.Enums.CharacterSkills.e_AugmentHealing, 
												 _global.Enums.CharacterSkills.e_AugmentSurvivability]
								 });
		}
		
		if (!Lore.IsLocked(AEGIS_SLOT_ACHIEVEMENT))
		{
			categoriesArray.push({
								 	title:		aegisCategoryTitle,
									//TODO: Switch this to Aegis skill when it gets made
									subSkills:	[_global.Enums.CharacterSkills.e_Aegis]
								 });
		}
        
        for (var i:Number = 0; i < categoriesArray.length; i++)
        {
            var categoryContainer = attachMovie("CharacterSkillsCategoryContainer", "m_CategoryContainer_" + i, getNextHighestDepth());
            categoryContainer.SignalStartAnimation.Connect(SlotStartAnimation, this);
            categoryContainer.SignalStopAnimation.Connect(SlotStopAnimation, this);
            
            var thisScope = this;
            
            categoryContainer.m_Index = i;
            
            categoryContainer.onLoad = function()
            {
                this.SetLabel(categoriesArray[this.m_Index].title);  
                this.AddSkills(categoriesArray[this.m_Index].subSkills);
                
                thisScope.Animate();
            }
            
            m_SkillCategories.push(categoryContainer);
        }
    }
    
    //On Enter Frame
    public function onEnterFrame():Void
    {
        if (m_NumAnimating > 0)
        {
            Animate();
        }
    }
    
    //Animate
    public function Animate():Void
    {
        var newY:Number = 0;
            
        for (var i:Number = 0; i < m_SkillCategories.length; i++)
        {
            m_SkillCategories[i]._y = newY;
            newY += m_SkillCategories[i].GetBackgroundHeight();
        }
    }

    //Slot Start Function
    public function SlotStartAnimation():Void
    {
        m_NumAnimating++;
        SignalStartAnimation.Emit();
    }  
    
    //Slot Stop Function
    public function SlotStopAnimation():Void
    {
        m_NumAnimating--;
        SignalStopAnimation.Emit();
    }
	
    //Update Character Skill Points
	public function UpdateCharacterSkillPoints(newAmount:Number):Void
	{
        for (var i:Number = 0; i < m_SkillCategories.length; i++)
        {
            m_SkillCategories[i].UpdateCharacterSkillPoints(newAmount);
        }
	}
    
    //Get Background Height
    public function GetBackgroundHeight():Number
    {
        var totalHeight:Number = 0;
        
        for (var i:Number = 0; i < m_SkillCategories.length; i++)
        {
            totalHeight += m_SkillCategories[i].GetBackgroundHeight();
        }
        		
        return totalHeight;
    }
}