import XMonad hiding ( (|||) )

import qualified XMonad.StackSet as W

import XMonad.Actions.CycleRecentWS
import XMonad.Actions.CycleSelectedLayouts
import XMonad.Actions.FloatKeys
import XMonad.Actions.GridSelect
import XMonad.Actions.NoBorders
import XMonad.Actions.PerWorkspaceKeys
import XMonad.Actions.SpawnOn
import XMonad.Actions.WindowGo
import XMonad.Actions.WithAll
import qualified XMonad.Actions.ConstrainedResize as Sqr
import qualified XMonad.Actions.FlexibleResize as Flex

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook

import XMonad.Layout.Grid
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed

import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.Shell
import qualified XMonad.Prompt.AppLauncher as AL

import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.WorkspaceCompare

import System.Exit
import qualified Data.Map as M


main = do
    dzen  <- spawnPipe myStatusBar
    clock <- spawnPipe myClock

    xmonad $ withUrgencyHook NoUrgencyHook $ myConfig dzen

myConfig dzen = defaultConfig {
    borderWidth        = myBorderWidth,
    clickJustFocuses   = False,
    focusFollowsMouse  = False,
    focusedBorderColor = myFocusedBorderColor,
    keys               = \conf -> mkKeymap conf (myAdditionalKeymap conf),
    layoutHook         = myLayoutHook,
    logHook            = dynamicLogWithPP $ myDzenPP dzen,
    manageHook         = myManageHook,
    modMask            = mod4Mask,
    mouseBindings      = myMouseBindings,
    normalBorderColor  = myNormalBorderColor,
    startupHook        = return () >> checkKeymap (myConfig dzen) myKeymap >> setWMName "LG3D",
    terminal           = myTerminal,
    workspaces         = myWorkspaces
}
    `additionalKeysP` myKeymap

myDzenPP h = defaultPP {
    ppCurrent         = dzenColor myFgColor myOtherFgColor . wrap " " " ",
    ppHidden          = dzenColor myFgColor "",
    ppHiddenNoWindows = dzenColor myOtherFgColor "",
    ppUrgent          = dzenColor myBgColor myUrgentColor . dzenStrip . wrap " " " ",
    ppSep             = dzenColor "" "" " ",
    ppSort            = fmap (.namedScratchpadFilterOutWorkspace) $ ppSort defaultPP,
    ppOrder           = \(ws:l:_) -> [ws,l],
    ppOutput          = hPutStrLn h,
    ppLayout          = dzenColor "" "" . myLayoutIcon
}

myLayoutIcon name
  | name `elem` layouts = iconFor name
  | otherwise = noIcon
    where
      layouts      = ["tall", "mtall", "tabs", "tab_a", "full", "Full", "grid"]
      iconFor name = "^bg(" ++ myBgColor ++ ")^fg(" ++ myFgColor ++ ")^i(" ++ myDzDir ++ "/icons/" ++ name ++ ".xbm)^bg()^fg()"
      noIcon       = "^bg(" ++ myBgColor ++ ")^fg(" ++ myUrgentColor ++ ")?^bg()^fg()"

myWorkspaces = (map return "αβγδεζηθικλμν") ++ ["NSP"]
myWs n = (!!) myWorkspaces $ subtract 1 n

cycleRecentWS' :: [KeySym] -> KeySym -> KeySym -> X ()
cycleRecentWS' = cycleWindowSets options
 where options w = map (W.view `flip` w) (recentTags w)
       recentTags w = map W.tag $ tail (wss w) ++ [head (wss w)]
       wss w = filter (\ws -> W.tag ws /= "NSP") $ W.workspaces w

myFgColor            = "#333333"
myOtherFgColor       = "#d0d0d0"
myBgColor            = "#e5e5e5"
myUrgentColor        = "#bd4747"
myNormalBorderColor  = myOtherFgColor
myFocusedBorderColor = myUrgentColor

myTerminal    = "urxvtc"
myBorderWidth = 1
myStatusBar   = "dzen2 -x '0' -w '350' -ta 'l' -fn '" ++ myMonoDzFont ++ myDzDefArgs

myClock     = myDzenClock ++ " | dzen2 -x '350' -w '930' -ta 'r' -fn '" ++ myDzFont ++ myDzDefArgs
myDzenClock = "while :; do LC_ALL='uk_UA.UTF-8' date +'^fg(#2e5aa7)%A, %d^fg() - %T ' || exit 1; sleep 1; done"
myDzDefArgs = "' -y '0' -h '16' -bg '" ++ myBgColor ++ "' -fg '" ++ myFgColor ++ "' -e 'onstart=lower'"
myDzDir     = "/home/vderyagin/.xmonad"

myMonoDzFont = "DejaVu Sans Mono-10"
myDzFont     = "DejaVu Sans-10"
myTabsFont   = "xft:DejaVu Sans:pixelsize=12"
myPromptFont = "xft:Consolas:pixelsize=15"

myTabConfig = defaultTheme {
    inactiveColor       = myBgColor,
    activeColor         = myOtherFgColor,
    urgentColor         = myUrgentColor,
    inactiveBorderColor = myOtherFgColor,
    activeBorderColor   = myOtherFgColor,
    urgentBorderColor   = myUrgentColor,
    inactiveTextColor   = myFgColor,
    activeTextColor     = myFgColor,
    urgentTextColor     = myBgColor,
    decoHeight          = 17,
    fontName            = myTabsFont
}

myXPConfig = defaultXPConfig {
    font              = myPromptFont,
    bgColor           = myOtherFgColor,
    fgColor           = myFgColor,
    fgHLight          = myOtherFgColor,
    bgHLight          = myFgColor,
    promptBorderWidth = 0,
    position          = Bottom,
    height            = 16,
    historySize       = 50,
    historyFilter     = deleteAllDuplicates
}

myAutoXPConfig = myXPConfig {
    autoComplete = Just 1000
}

myGSConfig = defaultGSConfig {
    gs_cellheight = 40,
    gs_cellwidth  = 150
}

myLayoutPrompt = inputPromptWithCompl myAutoXPConfig "Layout"
    (mkComplFunFromList' ["tall", "mtall", "full", "tabs", "tab_a", "grid"])
    ?+ \l -> sendMessage $ JumpToLayout l

mytall  = ResizableTall nmaster delta1 frac slaves
    where
        nmaster = 1
        delta1  = 1/55
        frac    = 1/2
        slaves  = [1]

myMtall = Mirror (ResizableTall nmaster delta2 frac slaves)
    where
        nmaster = 1
        delta2  = 1/60
        frac    = 1/2
        slaves  = [1]

tall  = named "tall" mytall
mtall = named "mtall" myMtall
grid  = named "grid" Grid
tabs  = named "tabs" (tabbed shrinkText myTabConfig)
tab_a = named "tab_a" (tabbedAlways shrinkText myTabConfig)
full  = named "full" Full

myLdefault = tabs ||| full ||| mtall ||| tall ||| tab_a ||| grid

myLayoutHook = avoidStruts $ smartBorders $ mkToggle1 FULL $ myLdefault

nsps = [
    NS "goldendict"
       "goldendict"
       (title =? "GoldenDict")
       (customFloating $ W.RationalRect (1/10) (1/14) (4/5) (6/7)),
    NS "terminal"
       "urxvtc -geometry 120x40 -name sp_term -e tmux attach -d -t main"
       (resource =? "sp_term")
       (customFloating $ W.RationalRect (51/640) (159/1024) (215/256) (353/512)),
    NS "dev-terminal"
       "urxvtc -b 7 -name sp_dev_term -e tmux attach -d -t dev"
       (resource =? "sp_dev_term")
       doFullFloat,
    NS "gcolor"
       "gcolor2"
       (className =? "Gcolor2")
       (doSideFloat SE),
    NS "feh"
       ""
       (className =? "feh" <||>
        className =? "Animate")
       doCenterFloat,
    NS "video-player"
       ""
       (className =? "MPlayer" <||>
        title     =? "VLC" <||>
        className =? "Vlc" <||>
        className =? "ffplay" <||>
        className =? "Exe" <||>
        className =? "Plugin-container")
       doCenterFloat
    ]

isMenu     = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_MENU"
doSink     = ask >>= doF . W.sink
myCFloats  = ["Gxmessage", "Xmessage", "Skype", "XClock"]
myCCFloats = ["Xfd", "Gtk-chtheme", "MPlayer", "xmoto", "Simsu", "Lxappearance", "ffplay", "Vlc", "Gtorrentviewer", "Animate"]
myTFloats  = ["glxgears", "Event Tester"]
myRIgnores = ["stalonetray", "desktop_window"]
myCSinks   = ["Dwarf_Fortress"]
myNSPHook  = namedScratchpadManageHook nsps
myAppsHook = composeAll . concat $ [
    [className =? c --> doFloat       | c <- myCFloats],
    [title     =? t --> doFloat       | t <- myTFloats],
    [className =? f --> doCenterFloat | f <- myCCFloats],
    [className =? f --> doSink        | f <- myCSinks],
    [resource  =? i --> doIgnore      | i <- myRIgnores],
    [className =? "Chromium-browser" <||>
     className =? "Firefox" --> doShift (myWs 1)],
    [className =? "Firefox" <&&> resource /=? "Navigator" --> doCenterFloat],
    [resource  =? "VCLSalFrame" <||>
     resource  =? "VCLSalFrame.DocumentWindow" <||>
     title     =? "LibreOffice" <||>
     className =? "Soffice" <||>
     className =? "Evince" <||>
     className =? "Qpdfview" <||>
     className =? "Fbreader" <||>
     className =? "Kchmviewer" <||>
     className =? "Qcomicbook" --> doShift (myWs 6)],
    [isFullscreen --> doFullFloat],
    [isMenu       --> doFloat],
    [isDialog     --> doCenterFloat]
    ]

myManageHook = myAppsHook <+> manageDocks <+> manageSpawn <+> myNSPHook

myKeymap = [
    ("M-<Page_Up>",      withFocused (keysResizeWindow (18, 18) (0.5, 0.5))),
    ("M-<Page_Down>",    withFocused (keysResizeWindow (-18, -18) (0.5, 0.5))),
    ("M-<KP_Begin>",     withFocused (keysMoveWindowTo (640, 512) (0.5, 0.5))),
    ("M-<KP_End>",       withFocused (keysMoveWindowTo (0, 1024) (0, 1))),
    ("M-<KP_Page_Down>", withFocused (keysMoveWindowTo (1280, 1024) (1, 1))),
    ("M-<KP_Home>",      withFocused (keysMoveWindowTo (0, 0) (0, 0))),
    ("M-<KP_Page_Up>",   withFocused (keysMoveWindowTo (1280, 0) (1, 0))),
    ("M-<KP_Left>",      withFocused (keysMoveWindowTo (0, 512) (0, 0.5))),
    ("M-<KP_Right>",     withFocused (keysMoveWindowTo (1280, 512) (1, 0.5))),
    ("M-<KP_Up>",        withFocused (keysMoveWindowTo (640, 0) (0.5, 0))),
    ("M-<KP_Down>",      withFocused (keysMoveWindowTo (640, 1024) (0.5, 1))),
    ("M-M1-<L>",         withFocused (keysMoveWindow (-10, 0))),
    ("M-M1-<R>",         withFocused (keysMoveWindow (10, 0))),
    ("M-M1-<U>",         withFocused (keysMoveWindow (0, -10))),
    ("M-M1-<D>",         withFocused (keysMoveWindow (0, 10))),
    ("M-C-<L>",          withFocused (keysResizeWindow (-18, 0) (0.5, 0.5))),
    ("M-C-<R>",          withFocused (keysResizeWindow (18, 0) (0.5, 0.5))),
    ("M-C-<U>",          withFocused (keysResizeWindow (0, 18) (0.5, 0.5))),
    ("M-C-<D>",          withFocused (keysResizeWindow (0, -18) (0.5, 0.5))),
    ("M-<Backspace>",    focusUrgent),
    ("M-S-<Backspace>",  clearUrgents),
    ("M-<Tab>",          windows W.focusDown),
    ("M-j",              windows W.focusDown),
    ("M-k",              windows W.focusUp),
    ("M-S-<Tab>",        windows W.focusUp),
    ("M-S-j",            windows W.swapDown),
    ("M-S-k",            windows W.swapUp),
    ("M-<Return>",       windows W.swapMaster),
    ("M-n",              cycleRecentWS' [xK_Super_L] xK_n xK_m),
    ("M-,",              sendMessage (IncMasterN 1)),
    ("M-.",              sendMessage (IncMasterN (-1))),
    ("M-b",              sendMessage ToggleStruts),
    ("M-S-b",            withFocused toggleBorder),
    ("M-S-c",            kill),
    ("M-C-c",            killAll),
    ("M-h",              sendMessage Shrink),
    ("M-l",              sendMessage Expand),
    ("M-S-l",            sendMessage MirrorShrink),
    ("M-S-h",            sendMessage MirrorExpand),
    ("M-t",              withFocused $ windows . W.sink),
    ("M-S-t",            sinkAll),
    ("M-<Esc>",          myLayoutPrompt),
    ("M-<F1>",           sendMessage $ JumpToLayout "mtall"),
    ("M-<F2>",           sendMessage $ JumpToLayout "tall"),
    ("M-<F3>",           sendMessage $ JumpToLayout "full"),
    ("M-<F4>",           sendMessage $ JumpToLayout "tabs"),
    ("M-<F5>",           sendMessage $ JumpToLayout "grid"),
    ("M-f",              sendMessage $ Toggle FULL),
    ("M-S-n",            refresh),
    ("M-S-m",            windows W.focusMaster),
    ("M-S-q",            io (exitWith ExitSuccess)),
    ("M-S-a",            AL.launchApp myXPConfig (myTerminal ++ " -e")),
    ("M-<Print>",        spawn "scrot"),
    ("M-S-<Print>",      spawn "sleep 0.2 && scrot -s"),
    ("M-C-<Print>",      spawn "rake -g share_screenshot"),

    ("M-p", namedScratchpadAction nsps "terminal"),
    ("M-o", namedScratchpadAction nsps "dev-terminal"),
    ("M-]", namedScratchpadAction nsps "gcolor"),
    ("M-i", namedScratchpadAction nsps "feh"),
    ("M-w", namedScratchpadAction nsps "goldendict"),
    ("M-m", namedScratchpadAction nsps "video-player"),

    -- both may be replaced by "eject -T"
    ("M-x <U>", spawn "eject -t"),
    ("M-x <D>", spawn "eject"),

    ("M-x k m", spawn "killall -9 mplayer"),
    ("M-x k f", spawn "killall -9 firefox"),
    ("M-x k c", spawn "killall -9 chrome"),
    ("M-x k e", spawn "killall -9 emacs"),

    ("M-x m",      spawn "mplayer -fs tv:// -tv driver=v4l2:device=/dev/video0 -fps 60 -vf mirror,screenshot"),
    ("M-x M-m",    spawn "mplayer -fs tv:// -tv driver=v4l2:device=/dev/video0 -fps 60 -vf screenshot"),
    ("M-x M-e",    spawn "emacsclient -c -a ''"),
    ("M-x M-f",   (spawn "firefox -no-remote") >> (windows $ W.view (myWs 1))),
    ("M-x M-c",   (spawn "chromium") >> (windows $ W.view (myWs 1))),
    ("M-x M-C-c", (spawn "chromium --incognito") >> (windows $ W.view (myWs 1))),
    ("M-x M-C-f", (spawn "firefox -private") >> (windows $ W.view (myWs 1))),
    ("M-x M-p",    spawnHere "pcmanfm"),

    ("M-x e", raiseNextMaybe (spawn "emacsclient -c -a ''") (className =? "Emacs")),
    ("M-x f", raiseNextMaybe ((spawnHere "firefox") >> (windows $ W.view (myWs 1)))
                             (className =? "Firefox" <&&> resource =? "Navigator")),
    ("M-x c", raiseNextMaybe ((spawn "chromium") >> (windows $ W.view (myWs 1)))
                             (className =? "Chromium-browser")),
    ("M-x q", raiseNextMaybe ((spawn "qpdfview --unique") >> (windows $ W.view (myWs 6)))
                             (className =? "Qpdfview")),
    ("M-x r", raiseNextMaybe ((spawn "fbreader") >> (windows $ W.view (myWs 6)))
                             (className =? "Fbreader")),
    ("M-x p", raiseNextMaybe (spawnHere "pcmanfm") (className =? "Pcmanfm")),
    ("M-x t", raiseNextMaybe (spawnHere "transmission-gtk") (title =? "Transmission")),

    ("M-a", shellPromptHere myXPConfig),
    ("M-g", goToSelected myGSConfig),

    ("M-<Space>", bindOn [
        ((myWs 1), cycleThroughLayouts ["full", "tabs"]),
        ((myWs 2), cycleThroughLayouts ["full", "tabs"]),
        ((myWs 3), cycleThroughLayouts ["full", "tabs"]),
        ((myWs 4), cycleThroughLayouts ["full", "tabs"]),
        ((myWs 5), cycleThroughLayouts ["full", "tabs"]),
        ((myWs 6), cycleThroughLayouts ["full", "tabs"]),
        ("", cycleThroughLayouts ["full", "mtall", "tall", "tabs", "tab_a", "grid"])
    ]),

    ("M-q", spawn $ "ghc -e 'XMonad.recompile False >>= flip Control.Monad.unless System.Exit.exitFailure'"
                  ++ " && killall -9 dzen2; xmonad --restart"),
    ("M-d", spawnHere $ "dmenu_run -i -b -p 'Run:' -fn 'Consolas-12:normal' -l 10"
                      ++ " -nb '" ++ myOtherFgColor ++ "' -nf '" ++ myFgColor
                      ++ "' -sb '" ++ myFgColor ++ "' -sf '" ++ myOtherFgColor ++ "'"),
    ("<XF86Mail>",               spawn "mpc -q toggle"),
    ("<XF86AudioPlay>",          spawn "mpc -q prev"),
    ("<XF86AudioMute>",          spawn "mpc -q next"),
    ("<XF86AudioRaiseVolume>",   spawn "mpc -q volume +5"),
    ("<XF86AudioLowerVolume>",   spawn "mpc -q volume -5"),
    ("S-<XF86AudioRaiseVolume>", spawn "mpc -q volume +1"),
    ("S-<XF86AudioLowerVolume>", spawn "mpc -q volume -1"),
    ("C-<XF86AudioRaiseVolume>", spawn "mpc -q volume 100"),
    ("C-<XF86AudioLowerVolume>", spawn "mpc -q volume 0"),
    ("C-<XF86AudioPlay>",        spawn "mpc -q seek -00:00:10"),
    ("C-<XF86AudioMute>",        spawn "mpc -q seek +00:00:10"),
    ("S-<XF86AudioPlay>",        spawn "mpc -q seek -10%"),
    ("S-<XF86AudioMute>",        spawn "mpc -q seek +10%"),
    ("<XF86HomePage>",           spawn "mpc -q random"),
    ("C-<XF86HomePage>",         spawn "mpc -q shuffle"),
    ("<XF86Favorites>",          spawn "mpc -q clear"),
    ("S-<XF86Favorites>",        spawn "mpc -q crop"),
    ("<XF86Calculator>",         spawn "amixer -q set Master toggle"),
    ("C-<XF86Calculator>",       spawn "rake --system lock_screen"),
    ("<XF86MyComputer>",         spawn "mpd_status"),

    ("M-<F10>", spawn "emxkb 0"), -- english
    ("M-<F11>", spawn "emxkb 1"), -- ukrainian
    ("M-<F12>", spawn "emxkb 2")  -- russian
    ]
myAdditionalKeymap conf = [
    ("M-S-<Space>",  setLayout $ XMonad.layoutHook conf),
    ("M-S-<Return>", spawn $ XMonad.terminal conf)
    ]
    ++
    [
    (m ++ i, windows $ f j)
       | (i, j) <- zip ("`" : (map show [1..9]) ++ ["0", "-", "="]) (XMonad.workspaces conf)
       , (m, f) <- [("M-", W.view), ("M-S-", W.shift)]
    ]
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $ [
    ((modMask, button1), (\w -> focus w >> mouseMoveWindow w)),
    ((modMask, button2), (\w -> focus w >> windows W.shiftMaster)),
    ((modMask, button3), (\w -> focus w >> Flex.mouseResizeWindow w)),
    ((modMask, button4), (\w -> windows W.focusUp)),
    ((modMask, button5), (\w -> windows W.focusDown)),
    ((modMask .|. shiftMask, button3), (\w -> focus w >> Sqr.mouseResizeWindow w True )),
    ((modMask .|. shiftMask, button4), (\w -> windows W.swapUp)),
    ((modMask .|. shiftMask, button5), (\w -> windows W.swapDown))
    ]