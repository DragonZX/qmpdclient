# installation prefix on *nix/osx
PREFIX = /usr/local


# Most people need not muck about below here

!contains(QT_MAJOR_VERSION, 4){
    error(QMPDClient requires Qt 4)
}

CONFIG += qt debug # release
#CONFIG -= debug # Needed to avoid console on win32
TEMPLATE = app
RESOURCES = qmpdclient.qrc
VERSION = 1.0.9
DEFINES += NAMEVER='"\\"QMPDClient $$VERSION\\""'
INCLUDEPATH += src

FORMS += \
	ui/aboutdialog.ui \
	ui/addradiodialog.ui \
	ui/controlpanel.ui \
	ui/coverartdialog.ui \
	ui/directorypanel.ui \
   	ui/jumptosongdialog.ui \
	ui/librarypanel.ui \
	ui/mainwindow.ui \
   	ui/metainfodialog.ui \
	ui/playlistpanel.ui \
	ui/playlistspanel.ui \
   	ui/preferencesdialog.ui \
	ui/radiopanel.ui

HEADERS += \
	src/aafilter.h \
	src/aboutdialog.h \
	src/abstractmodel.h \
	src/abstractview.h \
	src/abstractview_defn.h \
	src/abstractview_impl.h \
	src/albumview.h \
   	src/artistview.h \
   	src/config.h \
	src/controlpanel.h \
	src/coverartdialog.h \
	src/debug.h \
   	src/directorymodel.h \
	src/directorypanel.h \
   	src/directoryview.h \
	src/dynamicplaylist.h \
	src/fileview.h \
	src/headerview.h \
	src/iconmanager.h \
	src/idealbar.h \
	src/idealsplitter.h \
   	src/jumptosongdialog.h \
	src/libmpdclient.h \
	src/librarypanel.h \
	src/lineedit.h \
	src/macroexpander.h \
   	src/mainwindow.h \
   	src/metainfodialog.h \
   	src/mpd.h \
   	src/mpd_p.h \
	src/mpdcache.h \
	src/mpdcache_p.h \
   	src/mpdconnection.h \
   	src/mpddirectory.h \
	src/mpdentities.h \
	src/mpdoutput.h \
   	src/mpdsong.h \
   	src/mpdsonglist.h \
   	src/mpdsongmodel.h \
	src/mpdsongview.h \
   	src/mpdstats.h \
   	src/mpdstatus.h \
	src/notifications.h \
	src/passivepopup.h \
	src/playlistitemdelegate.h \
	src/playlistmodel.h \
	src/playlistspanel.h \
   	src/playlistsview.h \
   	src/preferencesdialog.h \
   	src/qmpdclient.h \
	src/playlistpanel.h \
   	src/playlistview.h \
	src/plconview.h \
	src/radiopanel.h \
   	src/radioview.h \
	src/reconnect.h \
	src/richtext.h \
	src/serverinfo.h \
	src/servermodel.h \
	src/shortcutmodel.h \
	src/shortcuts.h \
	src/songview.h \
	src/stringlistmodel.h \
	src/stringlistview.h \
	src/tagmodel.h \
   	src/tagguesser.h \
	src/timelabel.h \
	src/timeslider.h \
	src/trayicon.h \
	src/verticalbutton.h

SOURCES += \
	src/aafilter.cpp \
	src/aboutdialog.cpp \
	src/abstractmodel.cpp \
	src/abstractview.cpp \
	src/albumview.cpp \
   	src/artistview.cpp \
   	src/config.cpp \
	src/controlpanel.cpp \
	src/coverartdialog.cpp \
   	src/directorymodel.cpp \
	src/directorypanel.cpp \
   	src/directoryview.cpp \
	src/dynamicplaylist.cpp \
	src/fileview.cpp \
	src/headerview.cpp \
	src/iconmanager.cpp \
	src/idealbar.cpp \
	src/idealsplitter.cpp \
   	src/jumptosongdialog.cpp \
	src/libmpdclient.c \
	src/librarypanel.cpp \
	src/lineedit.cpp \
   	src/mainwindow.cpp \
   	src/metainfodialog.cpp \
   	src/mpd.cpp \
	src/mpdcache.cpp \
   	src/mpdconnection.cpp \
   	src/mpddirectory.cpp \
	src/mpdentities.cpp \
	src/mpdoutput.cpp \
   	src/mpdsong.cpp \
	src/mpdsonglist.cpp \
   	src/mpdsongmodel.cpp \
	src/mpdsongview.cpp \
	src/mpdstats.cpp \
	src/mpdstatus.cpp \
	src/notifications.cpp \
	src/passivepopup.cpp \
	src/playlistitemdelegate.cpp \
	src/playlistmodel.cpp \
	src/playlistpanel.cpp \
   	src/playlistview.cpp \
	src/playlistspanel.cpp \
   	src/playlistsview.cpp \
	src/plconview.cpp \
   	src/preferencesdialog.cpp \
   	src/qmpdclient.cpp \
	src/radiopanel.cpp \
   	src/radioview.cpp \
	src/reconnect.cpp \
	src/serverinfo.cpp \
	src/servermodel.cpp \
	src/shortcutmodel.cpp \
	src/shortcuts.cpp \
	src/songview.cpp \
	src/stringlistmodel.cpp \
	src/stringlistview.cpp \
   	src/tagguesser.cpp \
	src/tagmodel.cpp \
	src/timelabel.cpp \
	src/timeslider.cpp \
	src/trayicon.cpp \
	src/verticalbutton.cpp

MOC_DIR = .moc
OBJECTS_DIR = .obj
RCC_DIR = .res
UI_DIR = .ui

# Platform specific
win32 {
    debug {
        CONFIG += console
    }
    LIBS += -lws2_32
    RC_FILE = icons/resource.rc
    SOURCES += src/qmpdclient_win.cpp \
             src/notifications_nodbus.cpp
    # Installation in done through own installer on win32
}
unix {
    !mac {
        SOURCES += src/qmpdclient_x11.cpp

        # Check for dbus support
        contains(QT_CONFIG, qdbus){
            message(DBus notifier: enabled)
            CONFIG += qdbus
            SOURCES += src/notifications_dbus.cpp
        }
        else {
            message(DBus notifier: disabled (Qt is not compiled with dbus support))
            SOURCES += src/notifications_nodbus.cpp
        }
    }
    mac {
        RC_FILE = icons/qmpdclient.icns
        SOURCES += src/qmpdclient_mac.cpp \
	               src/notifications_nodbus.cpp
    }

    DEFINES += PREFIX='"\\"$$PREFIX\\""'
    TARGET = qmpdclient
    INSTALLS += target
    target.path = $$PREFIX/bin 
}