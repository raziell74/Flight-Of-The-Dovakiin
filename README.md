# Flight of the Dovakiin (FTOD)
This is a skyrim flight mod that takes the best aspects of several available flight mods and attempts to create a fluid flying experience.

-- FOTD V1.0 Change Log --
* SKSE and Papyrus scripts optimized
* Added Toggleable debug output to papyrus scripts
* Added Hover capability
* Sprinting is now available while in flight mode
* Updated Default flight controls
** Jump: Ascend
** Sneak: Descend
** Sprint: Fly faster while in flight mode
* Bug Fix: Sneak no longer activates after landing using the descend button
* Added a lore friendly spell to hide dragon wings
* Wings no longer disappear when in combat stance or indoors
* While in combat mode or indoors player does not enter flight mode when jumping.
* Jump height is increased and fall is slowed slightly when jumping with wings in combat mode or if indoors
* Flight mode no longer available while indoors. Indoor flight comes with its own slew of bugs
* Added flight reset spell. If the flight script ever bugs out, restarting it can sometimes resolve the issues
* Default descend speed doubled
* Increased default jump height to a realistic value when wings are not active
* Menus are now accessable while in flight mode. Fast Travel is disabled though to avoid possible bugs. Besides flying should be your new fast travel
* Added dynamic velocity functionality with new config variable to control velocity change transition time
** In laymens terms this features makes it so you gradually increase or decrease in speed. 
** Instead of going from a standstill to hyper speed instantly you'll gradually approach max speed, the same when you go back to a standstill you'll slow down and gradually come to a halt-
* Made collision detection more reponsive for forced landings. Now if you fly into a mountain or the ground you'll land
* Updated a few flight animations using the Hover animation assets from http://www.nexusmods.com/skyrim/mods/29646
* Removed original Real Flying wings, replaced with packaged Animated Dragon Wings from Anton. (Compatibility patch required if you already have it installed)