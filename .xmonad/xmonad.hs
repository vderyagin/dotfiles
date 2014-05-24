import XMonad hiding ( (|||) )

import Control.Applicative
import qualified Data.Map as M
import Network.BSD
import System.Directory
import System.Environment
import System.Exit
import System.FilePath
import qualified XMonad.Actions.ConstrainedResize as Sqr
import XMonad.Actions.CycleRecentWS
import XMonad.Actions.CycleSelectedLayouts
import qualified XMonad.Actions.FlexibleResize as Flex
import XMonad.Actions.FloatKeys
import XMonad.Actions.GridSelect
import XMonad.Actions.NoBorders
import XMonad.Actions.PerWorkspaceKeys
import XMonad.Actions.SpawnOn
import XMonad.Actions.WindowGo
import XMonad.Actions.WithAll
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
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Prompt
import qualified XMonad.Prompt.AppLauncher as AL
import XMonad.Prompt.Input
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run

data SystemInfo = SystemInfo {
    homeDirectory :: FilePath,
    localHostName :: HostName,
    screenWidth :: Int,
    screenHeight :: Int
}

scrWidth :: HostName -> Int
scrWidth "thinkpad" = 1600
scrWidth "desktop" = 1920

scrHeight :: HostName -> Int
scrHeight "thinkpad" = 900
scrHeight "desktop" = 1080

getSystemInfo :: IO SystemInfo
getSystemInfo = do
    home <- getHomeDirectory
    host <- getHostName

    return SystemInfo {
        localHostName = host,
        homeDirectory = home,
        screenWidth = scrWidth host,
        screenHeight = scrHeight host
    }

main :: IO ()
main = do
    sysInfo <- getSystemInfo
    spawnPipe . myClock $ screenWidth sysInfo
    dz <- spawnPipe myStatusBar

    xmonad $ withUrgencyHook NoUrgencyHook $ myConfig dz sysInfo

myConfig dz sysInfo = foldl additionalKeysP conf myKeyMaps
  where
    conf = def {
      borderWidth        = myBorderWidth,
      clickJustFocuses   = False,
      focusFollowsMouse  = False,
      focusedBorderColor = myFocusedBorderColor,
      keys               = \c -> mkKeymap c (myAdditionalKeymap c),
      layoutHook         = myLayoutHook,
      logHook            = dynamicLogWithPP $ myDzenPP dz home,
      manageHook         = myManageHook sysInfo,
      modMask            = mod4Mask,
      mouseBindings      = myMouseBindings,
      normalBorderColor  = myNormalBorderColor,
      startupHook        = mapM_ checkKM myKeyMaps >> setWMName "LG3D",
      terminal           = myTerminal,
      workspaces         = myWorkspaces
    }
    myKeyMaps = [ myKeymap
                , namedScratchpadsKeymap sysInfo
                , myMultimediaKeymap host
                , myLanguageKeymap host ]
    home = homeDirectory sysInfo
    host = localHostName sysInfo
    checkKM = checkKeymap $ myConfig dz sysInfo

myDzenPP h homeDir = def {
    ppCurrent         = dzenColor myFgColor myOtherFgColor . wrap " " " ",
    ppHidden          = dzenColor myFgColor "",
    ppHiddenNoWindows = dzenColor myOtherFgColor "",
    ppUrgent          = dzenColor myBgColor myUrgentColor . wrap " " " ",
    ppSep             = " ",
    ppSort            = (. namedScratchpadFilterOutWorkspace) <$> ppSort def,
    ppOrder           = \(ws:l:_) -> [ws,l],
    ppOutput          = hPutStrLn h,
    ppLayout          = myLayoutIcon homeDir
}

myLayoutIcon :: FilePath -> String -> String
myLayoutIcon homeDir layoutName
  | layout `elem` layouts = icon
  | otherwise = noIcon
    where
      layout       = last . words $ layoutName
      layouts      = ["vertical", "horizontal", "tabs", "full", "Full", "grid"]
      icon         = dzenColor myFgColor myBgColor $ "^i(" ++ iconLocation ++ ")"
      noIcon       = dzenColor myUrgentColor myBgColor "?"
      iconLocation = homeDir </> ".icons" </> "dzen2" </> layout ++ ".xbm"

myWorkspaces :: [String]
myWorkspaces = map return "αβγδεζηθικλμν" ++ ["NSP"]

myWs :: Int -> String
myWs = (myWorkspaces !!) . subtract 1

cycleRecentWS' :: [KeySym] -> KeySym -> KeySym -> X ()
cycleRecentWS' = cycleWindowSets options
  where options w = map (W.view `flip` w) (recentTags w)
        recentTags w = map W.tag $ tail (wss w) ++ [head (wss w)]
        wss w = filter isNotScratchpad $ W.workspaces w
        isNotScratchpad ws = W.tag ws /= "NSP"

myFgColor            = "#333333"
myOtherFgColor       = "#d0d0d0"
myBgColor            = "#e5e5e5"
myUrgentColor        = "#bd4747"
myNormalBorderColor  = myOtherFgColor
myFocusedBorderColor = myUrgentColor

myStatusOffset = 350

myTerminal    = "urxvtc"
myBorderWidth = 1
myStatusBar   = "dzen2 -x '0' -w '" ++ show myStatusOffset ++ "' -ta 'l' -fn '" ++ myMonoDzFont ++ myDzDefArgs
myClock scrWidth = myDzenClock ++ " | dzen2 -x '" ++ show myStatusOffset ++ "' -w '" ++ show (scrWidth - myStatusOffset) ++ "' -ta 'r' -fn '" ++ myDzFont ++ myDzDefArgs
myDzenClock   = "while :; do date +'^fg(#2e5aa7)%A, %d^fg() - %T ' || exit 1; sleep 1; done"
myDzDefArgs   = "' -y '0' -h '16' -bg '" ++ myBgColor ++ "' -fg '" ++ myFgColor ++ "' -e 'onstart=lower'"

myMonoDzFont = "DejaVu Sans Mono-10"
myDzFont     = "DejaVu Sans-10"
myTabsFont   = "xft:DejaVu Sans:pixelsize=12"
myPromptFont = "xft:Consolas:pixelsize=15"

myTabConfig :: Theme
myTabConfig = def {
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

myXPConfig :: XPConfig
myXPConfig = def {
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

myAutoXPConfig :: XPConfig
myAutoXPConfig = myXPConfig {
    autoComplete = Just 1000
}

myGSConfig :: GSConfig Window
myGSConfig = def {
    gs_cellheight = 40,
    gs_cellwidth  = 150
}

myLayoutPrompt :: X ()
myLayoutPrompt = inputPromptWithCompl myAutoXPConfig "Layout"
    (mkComplFunFromList' ["vertical", "horizontal", "full", "tabs", "grid"])
    ?+ \l -> sendMessage $ JumpToLayout l

vertical = named "vertical" $ ResizableTall nmaster delta frac slaves
    where (nmaster, delta, frac, slaves) = (1, 1/100, 3/5, [1])

horizontal = named "horizontal" . Mirror $ ResizableTall nmaster delta frac slaves
    where (nmaster, delta, frac, slaves) = (1, 1/100, 1/2, [1])

grid = named "grid" Grid
tabs = named "tabs" $ tabbed shrinkText myTabConfig
full = named "full" Full

myLayoutHook = avoidStruts .
               smartBorders .
               mkToggle modifiers .
               onWorkspaces (map myWs [2..4]) tabsFirstLayout $
               defaultLayout
  where
    modifiers       = REFLECTX ?? REFLECTY ?? MIRROR ?? FULL ?? EOT
    defaultLayout   = vertical ||| horizontal ||| tabs ||| full ||| grid
    tabsFirstLayout = tabs ||| vertical ||| horizontal ||| full ||| grid

nsps :: SystemInfo -> [NamedScratchpad]
nsps sysInfo = [
    NS "terminal"
       "urxvtc -name sp_term -e tmux attach -d -t main"
       (resource =? "sp_term")
       (customFloating $ W.RationalRect ((w-1255)/w/2) ((h-760)/h/2) (1255/w) (760/h)),
    NS "dev-terminal"
       "urxvtc -b 7 -name sp_dev_term -e tmux attach -d -t dev"
       (resource =? "sp_dev_term")
       doFullFloat,
    NS "image-viewer"
       ""
       (className =? "feh" <||>
        className =? "Animate")
       doCenterFloat,
    NS "video-player"
       ""
       (className =? "MPlayer" <||>
        className =? "mpv" <||>
        title     =? "VLC" <||>
        className =? "Vlc" <||>
        className =? "ffplay" <||>
        className =? "Exe" <||>
        className =? "Plugin-container")
       doCenterFloat
    ]
  where [w, h] = map (toRational . ($ sysInfo)) [screenWidth, screenHeight]

isMenu :: Query Bool
isMenu = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_MENU"

doSink     = ask >>= doF . W.sink
myCFloats  = ["Gxmessage", "Xmessage", "Skype", "XClock", "Odeskteam-qt4"]
myCCFloats = ["Xfd", "Gtk-chtheme", "MPlayer", "xmoto", "Simsu", "Lxappearance", "ffplay", "Vlc", "Gtorrentviewer", "Animate", "Pinentry", "Pmount-gui", "mpv", "Ptbatterysystemtray", "CopyAgent"]
myTFloats  = ["glxgears", "Event Tester"]
myTCFloats = ["Clementine image viewer"]
myRIgnores = ["stalonetray", "desktop_window"]
myCSinks   = ["Dwarf_Fortress"]
myNSPHook = namedScratchpadManageHook . nsps
myAppsHook = composeAll . concat $ [
    [className =? c --> doFloat       | c <- myCFloats],
    [title     =? t --> doFloat       | t <- myTFloats],
    [title     =? t --> doCenterFloat | t <- myTCFloats],
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

myManageHook sysInfo = myAppsHook <+> manageDocks <+> manageSpawn <+> myNSPHook sysInfo

myKeymap :: [(String, X ())]
myKeymap = [
    ("M-<Page_Up>",      withFocused (keysResizeWindow (18, 18) (0.5, 0.5))),
    ("M-<Page_Down>",    withFocused (keysResizeWindow (-18, -18) (0.5, 0.5))),
    ("M-C-<L>",          withFocused (keysResizeWindow (-18, 0) (0.5, 0.5))),
    ("M-C-<R>",          withFocused (keysResizeWindow (18, 0) (0.5, 0.5))),
    ("M-C-<U>",          withFocused (keysResizeWindow (0, 18) (0.5, 0.5))),
    ("M-C-<D>",          withFocused (keysResizeWindow (0, -18) (0.5, 0.5))),
    ("M-M1-<L>",         withFocused (keysMoveWindow (-10, 0))),
    ("M-M1-<R>",         withFocused (keysMoveWindow (10, 0))),
    ("M-M1-<U>",         withFocused (keysMoveWindow (0, -10))),
    ("M-M1-<D>",         withFocused (keysMoveWindow (0, 10))),
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
    ("M-<F1>",           sendMessage $ JumpToLayout "vertical"),
    ("M-<F2>",           sendMessage $ JumpToLayout "horizontal"),
    ("M-<F3>",           sendMessage $ JumpToLayout "tabs"),
    ("M-<F4>",           sendMessage $ JumpToLayout "full"),
    ("M-<F5>",           sendMessage $ JumpToLayout "grid"),
    ("M-f",              sendMessage $ Toggle FULL),
    ("M-<R>",            sendMessage $ Toggle REFLECTX),
    ("M-<L>",            sendMessage $ Toggle REFLECTX),
    ("M-<U>",            sendMessage $ Toggle REFLECTY),
    ("M-<D>",            sendMessage $ Toggle REFLECTY),
    ("M-r",              sendMessage $ Toggle MIRROR),

    ("M-w", screenWorkspace 0 >>= flip whenJust (windows . W.view)),
    ("M-S-w", screenWorkspace 0 >>= flip whenJust (windows . W.shift)),
    ("M-e", screenWorkspace 1 >>= flip whenJust (windows . W.view)),
    ("M-S-e", screenWorkspace 1 >>= flip whenJust (windows . W.shift)),


    ("M-S-n",            refresh),
    ("M-S-m",            windows W.focusMaster),
    ("M-S-q",            io exitSuccess),
    ("M-S-a",            AL.launchApp myXPConfig (myTerminal ++ " -e")),
    ("M-<Print>",        spawn "scrot"),
    ("M-S-<Print>",      spawn "sleep 0.2 && scrot -s"),
    ("M-C-<Print>",      spawn "rake -g share_screenshot"),

    ("M-x <U>", spawn "pmount-gui"),
    ("M-x <D>", spawn "pmount-gui -u"),

    ("M-x k m", spawn "killall -9 mplayer mpv"),
    ("M-x k f", spawn "killall -9 firefox"),
    ("M-x k c", spawn "killall -9 chrome"),
    ("M-x k e", spawn "killall -9 emacs"),

    ("M-x m",     spawn "mpv tv:// -tv driver=v4l2:device=/dev/video0 -fps 60 -vf mirror,screenshot"),
    ("M-x M-m",   spawn "mpv tv:// -tv driver=v4l2:device=/dev/video0 -fps 60 -vf screenshot"),
    ("M-x M-e",   spawn "emacsclient -c -a ''"),
    ("M-x M-f",   spawn "firefox -no-remote" >> windows (W.view (myWs 1))),
    ("M-x M-c",   spawn "chromium" >> windows (W.view (myWs 1))),
    ("M-x M-C-c", spawn "chromium --incognito" >> windows (W.view (myWs 1))),
    ("M-x M-C-f", spawn "firefox -private-window" >> windows (W.view (myWs 1))),
    ("M-x M-p",   spawnHere "pcmanfm"),

    ("M-x e", raiseNextMaybe (spawn "emacsclient -c -a ''") (className =? "Emacs")),
    ("M-x f", raiseNextMaybe (spawnHere "firefox" >> windows (W.view (myWs 1)))
                             (className =? "Firefox" <&&> resource =? "Navigator")),
    ("M-x c", raiseNextMaybe (spawn "chromium" >> windows (W.view (myWs 1)))
                             (className =? "Chromium-browser")),
    ("M-x q", raiseNextMaybe (spawn "qpdfview --unique" >> windows (W.view (myWs 6)))
                             (className =? "Qpdfview")),
    ("M-x r", raiseNextMaybe (spawn "fbreader" >> windows (W.view (myWs 6)))
                             (className =? "Fbreader")),
    ("M-x p", raiseNextMaybe (spawnHere "pcmanfm") (className =? "Pcmanfm")),
    ("M-x t", raiseNextMaybe (spawnHere "transmission-gtk") (title =? "Transmission")),

    ("M-a", shellPromptHere myXPConfig),
    ("M-g", goToSelected myGSConfig),

    ("M-<Space>", bindOn [
        (myWs 1, cycleThroughLayouts ["full", "tabs"]),
        (myWs 2, cycleThroughLayouts ["full", "tabs"]),
        (myWs 3, cycleThroughLayouts ["full", "tabs"]),
        (myWs 4, cycleThroughLayouts ["full", "tabs"]),
        (myWs 5, cycleThroughLayouts ["full", "tabs"]),
        (myWs 6, cycleThroughLayouts ["full", "tabs"]),
        ("", cycleThroughLayouts ["full", "horizontal", "vertical", "tabs", "grid"])
    ]),

    ("M-q", spawn $ "ghc -e 'XMonad.recompile False >>= flip Control.Monad.unless System.Exit.exitFailure'"
                  ++ " && killall -9 dzen2; xmonad --restart"),
    ("M-d", spawnHere $ "dmenu_run -i -b -p 'Run:' -fn 'Consolas-12:normal' -l 10"
                      ++ " -nb '" ++ myOtherFgColor ++ "' -nf '" ++ myFgColor
                      ++ "' -sb '" ++ myFgColor ++ "' -sf '" ++ myOtherFgColor ++ "'")
    ]

namedScratchpadsKeymap :: SystemInfo -> [(String, X ())]
namedScratchpadsKeymap sysInfo = [
  ("M-p", openNamedScratchpad "terminal"),
  ("M-o", openNamedScratchpad "dev-terminal"),
  ("M-i", openNamedScratchpad "image-viewer"),
  ("M-m", openNamedScratchpad "video-player")
  ]
  where openNamedScratchpad = namedScratchpadAction $ nsps sysInfo

myMultimediaKeymap :: HostName -> [(String, X ())]
myMultimediaKeymap "desktop" = [
    ("<XF86AudioMute>",  spawn "amixer -q set Master toggle"),
    ("M-<XF86HomePage>", spawn "toggle_screen_orientation"),
    ("<XF86HomePage>",   spawn "sleep 0.5; xset dpms force suspend; rake --system lock_screen"),
    ("C-<XF86HomePage>", spawn "sleep 0.5; xset dpms force suspend"),

    ("<XF86Mail>",   spawn "mpc -q toggle"),
    ("M-<XF86Mail>", spawn "mpd_status"),

    ("<XF86AudioLowerVolume>", spawn "mpc -q volume -5"),
    ("<XF86AudioRaiseVolume>", spawn "mpc -q volume +5"),

    ("C-<XF86AudioLowerVolume>", spawn "mpc -q prev"),
    ("C-<XF86AudioRaiseVolume>", spawn "mpc -q next"),

    ("S-<XF86AudioLowerVolume>", spawn "mpc -q seek -00:00:10"),
    ("S-<XF86AudioRaiseVolume>", spawn "mpc -q seek +00:00:10"),

    ("M1-<XF86AudioLowerVolume>", spawn "mpc -q seek -10%"),
    ("M1-<XF86AudioRaiseVolume>", spawn "mpc -q seek +10%")
    ]

myMultimediaKeymap "thinkpad" = [
    ("<XF86AudioLowerVolume>", spawn "mpc -q volume -5"),
    ("<XF86AudioRaiseVolume>", spawn "mpc -q volume +5"),

    ("<XF86AudioPlay>",   spawn "mpc -q toggle"),
    ("M-<XF86AudioPlay>", spawn "mpd_status"),

    ("<XF86AudioPrev>", spawn "mpc -q prev"),
    ("<XF86AudioNext>", spawn "mpc -q next"),

    ("S-<XF86AudioPrev>", spawn "mpc -q seek -00:00:10"),
    ("S-<XF86AudioNext>", spawn "mpc -q seek +00:00:10"),

    ("M1-<XF86AudioPrev>", spawn "mpc -q seek -10%"),
    ("M1-<XF86AudioNext>", spawn "mpc -q seek +10%"),

    ("<XF86ScreenSaver>", spawn "rake --system lock_screen"),
    ("<XF86Display>", spawn "sleep 0.5; xset dpms force off"),

    ("<XF86Sleep>", spawn "sudo pm-suspend")
    ]

myLanguageKeymap :: HostName -> [(String, X ())]
myLanguageKeymap "desktop" =
  [ ("<XF86MenuKB>",   spawn "set_keyboard_layout")
  , ("M-<XF86MenuKB>", spawn "set_keyboard_layout english")
  ]

myLanguageKeymap "thinkpad" =
  [ ("<XF86Launch1>",   spawn "set_keyboard_layout")
  , ("M-<XF86Launch1>", spawn "set_keyboard_layout english")
  ]

myAdditionalKeymap :: XConfig Layout -> [(String, X ())]
myAdditionalKeymap conf = [
    ("M-S-<Space>",  setLayout $ XMonad.layoutHook conf),
    ("M-S-<Return>", spawn $ XMonad.terminal conf)
    ]
    ++
    [
    (m ++ i, windows $ f j)
       | (i, j) <- zip (map return "`1234567890-=") (XMonad.workspaces conf)
       , (m, f) <- [("M-", W.view), ("M-S-", W.shift)]
    ]

myMouseBindings (XConfig {XMonad.modMask = m}) = M.fromList [
    ((m, button1), \w -> focus w >> mouseMoveWindow w),
    ((m, button2), \w -> focus w >> windows W.shiftMaster),
    ((m, button3), \w -> focus w >> Flex.mouseResizeWindow w),
    ((m, button4), const $ windows W.focusUp),
    ((m, button5), const $ windows W.focusDown),
    ((m .|. shiftMask, button3), \w -> focus w >> Sqr.mouseResizeWindow w True),
    ((m .|. shiftMask, button4), const $ windows W.swapUp),
    ((m .|. shiftMask, button5), const $ windows W.swapDown)
    ]
