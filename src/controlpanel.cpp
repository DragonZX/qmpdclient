/*
 * QMPDClient - An MPD client written in Qt 4.
 * Copyright (C) 2005-2008 H�vard Tautra Knutsen <havtknut@tihlde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "config.h"
#include "controlpanel.h"
#include "coverartdialog.h"
#include "mpd.h"
#include "mpdconnection.h"
#include "mpdsong.h"
#include "richtext.h"
#include <QShortcut>
#include <QPixmap>
#include <QDir>

ControlPanel::ControlPanel(QWidget *parent) : QWidget(parent),
		m_coverArt(new CoverArtDialog(this)) {
	Q_ASSERT(m_coverArt);
	setupUi(this);
	coverArtButton->setVisible(false);

	connect(prevButton, SIGNAL(clicked()), MPD::instance(), SLOT(prev()));
	connect(playButton, SIGNAL(clicked()), MPD::instance(), SLOT(play()));
	connect(pauseButton, SIGNAL(clicked()), MPD::instance(), SLOT(pause()));
	connect(stopButton, SIGNAL(clicked()), MPD::instance(), SLOT(stop()));
	connect(nextButton, SIGNAL(clicked()), MPD::instance(), SLOT(next()));
	connect(volumeSlider, SIGNAL(valueChanged(int)), MPD::instance(), SLOT(setVolume(int)));
	connect(timeSlider, SIGNAL(timeChanged(int)), MPD::instance(), SLOT(seek(int)));
	connect(timeSlider, SIGNAL(valueChanged(int)), elapsedLabel, SLOT(setTime(int)));
	connect(MPD::instance(), SIGNAL(volumeUpdated(int)), volumeSlider, SLOT(setValue(int)));
	connect(MPD::instance(), SIGNAL(timeUpdated(int, int)), elapsedLabel, SLOT(setTime(int, int)));
	connect(MPD::instance(), SIGNAL(timeUpdated(int, int)), totalLabel, SLOT(setTime(int, int)));
	connect(MPD::instance(), SIGNAL(timeUpdated(int, int)), timeSlider, SLOT(setTime(int, int)));
	connect(MPD::instance(), SIGNAL(playingSongUpdated(const MPDSong &)), this, SLOT(setSong(const MPDSong &)));
	connect(Config::instance(), SIGNAL(showCoverArtChanged(bool)), this, SLOT(showCoverArtChanged(bool)));
	connect(coverArtButton, SIGNAL(clicked()), m_coverArt, SLOT(show()));

	// Short cuts
	m_fwdKey = new QShortcut(Qt::CTRL | Qt::Key_Right, this);
	m_rwdKey = new QShortcut(Qt::CTRL | Qt::Key_Left, this);
	m_volUpKey = new QShortcut(Qt::CTRL | Qt::Key_Up, this);
	m_volDnKey = new QShortcut(Qt::CTRL | Qt::Key_Down, this);
	m_fwdKey->setObjectName("nextSongKey");
	m_rwdKey->setObjectName("prevSongKey");
	m_volUpKey->setObjectName("volumeUpKey");
	m_volDnKey->setObjectName("volumeDownKey");
	connect(m_fwdKey, SIGNAL(activated()), MPD::instance(), SLOT(seekForward()));
	connect(m_rwdKey, SIGNAL(activated()), MPD::instance(), SLOT(seekBackward()));
	connect(m_volUpKey, SIGNAL(activated()), MPD::instance(), SLOT(volumeUp()));
	connect(m_volDnKey, SIGNAL(activated()), MPD::instance(), SLOT(volumeDown()));
	setSong(MPDSong());
}

void ControlPanel::updateTranslation() {
	retranslateUi(this);
	m_fwdKey->setWhatsThis(tr("Seek forward"));
	m_rwdKey->setWhatsThis(tr("Seek backward"));
	m_volUpKey->setWhatsThis(tr("Increase volume"));
	m_volDnKey->setWhatsThis(tr("Decrease volume"));
}

void ControlPanel::setSong(const MPDSong &s) {
	if (s.isNull()) {
		titleLabel->setText(MPDConnection::instance()->isConnected() ? "" : QString("<h3>%1</h3>").arg(tr("Not connected", "qmpdclient is not connected to MPD")));
		artistLabel->setText("");
		timeSlider->setEnabled(true);
		return;
	}

	// Disable time counting for streams
	timeSlider->setEnabled(s.type() != MPDSong::PLAYLISTSTREAM);

	// Ensure labels are not too small if window is hidden
	const int titleWidth = isVisible() ? titleLabel->width() : width() - 200;
	const int artistWidth = isVisible() ? artistLabel->width() : width() - 200;
	QString title = elideRichText("<h3>", s.title() , "</h3>", titleWidth);
	QString artist = s.artist();
	QString album = s.album();
	if (!artist.isEmpty() && !album.isEmpty())
		artist = elideRichText("<b>", QString("%1 - %2").arg(artist).arg(album), "</b>", artistWidth);
	else if (!artist.isEmpty())
		artist = elideRichText("<b>", artist, "</b>", artistWidth);
	else if (!album.isEmpty())
		artist += elideRichText("<b>", album, "</b>", artistWidth);

	titleLabel->setText(title);
	artistLabel->setText(artist);

	m_coverArt->setSong(s);
	const bool hasCoverArt = m_coverArt->hasCoverArt();
	if (hasCoverArt) {
		coverArtButton->setIcon(m_coverArt->coverArt());
		coverArtButton->setIconSize(QSize(50, 50));
	}
	coverArtButton->setVisible(Config::instance()->showCoverArt() && hasCoverArt);
}

void ControlPanel::showCoverArtChanged(bool a) {
	coverArtButton->setVisible(a && m_coverArt->hasCoverArt());
}