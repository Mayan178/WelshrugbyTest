// Register the related commands.
var dialogPath = FCKConfig.PluginsPath + 'moviePlayer/moviePlayer.html';
var moviePlayerDialogCmd = new FCKDialogCommand( FCKLang["DlgmoviePlayerTitle"], FCKLang["DlgmoviePlayerTitle"], dialogPath, 600, 520 );
FCKCommands.RegisterCommand( 'moviePlayer', moviePlayerDialogCmd ) ;

// Create the Flash toolbar button.
var omoviePlayerItem		= new FCKToolbarButton( 'moviePlayer', FCKLang["DlgmoviePlayerTitle"]) ;
omoviePlayerItem.IconPath	= FCKPlugins.Items['moviePlayer'].Path + 'moviePlayer.gif' ;

FCKToolbarItems.RegisterItem( 'moviePlayer', omoviePlayerItem ) ;			
// 'Flash' is the name used in the Toolbar config.

