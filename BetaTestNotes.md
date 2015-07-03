# Status #

![http://cjass.xgm.ru/files/?status_01.png](http://cjass.xgm.ru/files/?status_01.png)

[Link to open bugs](http://code.google.com/p/cjass/issues/list?q=label:Type-Defect). [Changelog](http://code.google.com/p/cjass/w/edit/ChangeLog).

# How to instal the beta #

1. Download and instal [base build](http://cjass.xgm.ru/files/?cJassSetup.exe).

2. Download [latest beta](http://code.google.com/p/cjass/downloads/list).

3. Replace executable.

4. Edit `wehack.lua` (look root of NewGenWE):

```
-- cJass#1
have_ah = grim.exists("adichelper\\adichelper.exe")
if have_ah then
	ah_menu = wehack.addmenu("cJass")
	ah_enable = TogMenuEntry:New(ah_menu,"Enable AdicParser",nil,true)
	ah_enableopt = TogMenuEntry:New(ah_menu,"Enable AdicOptimizer",nil,true)

	-- Flags

	wehack.addmenuseparator(ah_menu)

	ah_opt_remove = TogMenuEntry:New(ah_menu,"Remove unused code",nil,true)
	ah_alf_flag = TogMenuEntry:New(ah_menu,"Locals auto flush",nil,true)
	ah_igno_cjbj = TogMenuEntry:New(ah_menu,"Compile for default cj and bj",nil,true)
	ah_mcm_mode = TogMenuEntry:New(ah_menu,"Modules compatibility mode",nil,true)
	ah_bxpr_true = TogMenuEntry:New(ah_menu,"Use 'null' as default boolexpr",nil,true)

	-- Game version switch
	wehack.addmenuseparator(ah_menu)

	ah_version = MenuEntryGroup:New(ah_menu,"Game version switch")

	ah_ver23m = SwitchMenuEntry:New(ah_version,"Compile for game version 1.23")
	ah_ver24m = SwitchMenuEntry:New(ah_version,"Compile for game version 1.24+",true)

	-- Updater items

	wehack.addmenuseparator(ah_menu)

	if (grim.getregpair(confregpath,"First launch passed") ~= "yes") then
		ah_firstlaunch = true
	end

	if ah_firstlaunch then
		if (wehack.runprocess2("AdicHelper\\AHupdate.exe /ask") == 6) then
			ah_enableupdate = true
		end

		grim.setregstring(confregpath,"First launch passed","yes")
		if ah_enableupdate then
			grim.setregstring(confregpath,"Enable AutoUpdate","on")
		else
			grim.setregstring(confregpath,"Enable AutoUpdate","off")
		end
	end

	ah_enableupdate = TogMenuEntry:New(ah_menu,"Enable AutoUpdate",nil,false)

	if ah_enableupdate.checked then
		wehack.execprocess("adichelper\\AHupdate.exe /silent")
	end

	ah_update = MenuEntry:New(ah_menu,"Check for updates now", function() wehack.execprocess("adichelper\\AHupdate.exe") end)
	ah_updateopt = MenuEntry:New(ah_menu,"AutoUpdate settings", function() wehack.runprocess2("adichelper\\AHupdate.exe /options") end)

	-- About box

-- cjDebug box

--wehack.addmenuseparator(ah_menu)

--ah_intmode = TogMenuEntry:New(ah_menu,"INT 03 mode",nil,true)

	wehack.addmenuseparator(ah_menu)
	ah_aboutm = MenuEntry:New(ah_menu,"About AdicHelper ...",function() wehack.execprocess("adichelper\\adichelper.exe") end)

end
-- /cJass#1

-- cJass#2
	if have_ah and ah_enable.checked then
		cmdline = "AdicHelper\\AdicHelper.exe /tmcrpre=\""..grimdir.."\\jasshelper\\clijasshelper.exe\" "
		if ah_version.checked == 1 then
			cmdline = cmdline .. " /v23"
		else
			cmdline = cmdline .. " /v24"
		end
		if jh_debug.checked then
			cmdline = cmdline .. " /dbg"
		end
		if ah_alf_flag.checked then
			cmdline = cmdline .. " /alf"
		end
		if ah_mcm_mode.checked then
			cmdline = cmdline .. " /mcm"
		end
		if ah_igno_cjbj.checked then
			cmdline = cmdline .. " /ibj=\"0\" /icj=\"0\""
		end
		if ah_bxpr_true.checked then
			cmdline = cmdline .. " /dbt"
		end
--if ah_intmode.checked then
--	cmdline = cmdline .. " /int"
--end
		cmdline = cmdline .. " /mappars=\"" .. mappath.."\""
		adicresult = wehack.runprocess2(cmdline)
		if adicresult == 1 then
			mapvalid = false
			return
		end
	end
-- /cJass#2
```

5. Try to save your map.

6. Post bugreports [there](http://code.google.com/p/cjass/issues/list).

7. If you have "SFmpq.dll missing" errors messages - try to copy SFmpq.dll from `jassnewgenpack*\AdicHelper\` to `jassnewgenpack*\bin\`, `jassnewgenpack*\jasshelper\` or `jassnewgenpack*\jasshelper\bin\`.

8. Edit cj\_types.j: go to JNGP golder --> AdicHelper --> Lib --> cj\_types.j (open it). Search for the line which says "while(cond) = whilenot not(cond)". If this line exists, erase it.

# Important #
You may disable adicParser and adicOptimizer in `cjass` menu (just uncheck it).