/*
 * GPS Info for Nokia N9 (Harmattan) - native launcher.
 * Exposes satellite data (QtMobility QGeoSatelliteInfoSource) and a few
 * helpers (settings, clipboard, language) to the QML user interface.
 *
 * Copyright (c) 2026 smyhu. MIT License (see LICENSE).
 * Designed and written by Claude (Anthropic) together with smyhu.
 */
#include <QtGui/QApplication>
#include <QtGui/QClipboard>
#include <QtCore/QSettings>
#include <QtCore/QProcess>
#include <QtCore/QStringList>
#include <QtCore/QFile>
#include <QtCore/QTimer>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeNetworkAccessManagerFactory>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkDiskCache>
#include <QtNetwork/QNetworkConfigurationManager>
#include <QtGui/QDesktopServices>
#include <QtCore/QDir>
#include <QtCore/QCryptographicHash>
#include <QtLocation/QGeoSatelliteInfoSource>
#include <QtLocation/QGeoSatelliteInfo>
#include "gps.h"

QTM_USE_NAMESPACE

Satellites::Satellites(QObject *parent) : QObject(parent), m_src(0), m_active(false)
{
    m_src = QGeoSatelliteInfoSource::createDefaultSource(this);
    if (m_src) {
        connect(m_src, SIGNAL(satellitesInViewUpdated(QList<QGeoSatelliteInfo>)),
                this, SLOT(onView(QList<QGeoSatelliteInfo>)));
        connect(m_src, SIGNAL(satellitesInUseUpdated(QList<QGeoSatelliteInfo>)),
                this, SLOT(onUse(QList<QGeoSatelliteInfo>)));
    }
}

bool Satellites::available() const { return m_src != 0; }
bool Satellites::active() const { return m_active; }

void Satellites::start()
{
    if (m_active) return;
    if (m_src) m_src->startUpdates();
    m_active = true;
    emit activeChanged();
    if (!qgetenv("GPSINFO_FAKE").isEmpty()) fakeTick();   // test mode without a GPS
}

// test mode: a few satellites that slowly appear and get stronger
void Satellites::fakeTick()
{
    if (!m_active) return;
    static int step = 0;
    step++;
    QList<QGeoSatelliteInfo> view, use;
    static const int prn[] = {3, 7, 9, 14, 17, 22, 26, 30};
    static const int az[] = {40, 95, 150, 210, 260, 310, 20, 180};
    static const int el[] = {70, 35, 15, 50, 25, 60, 10, 80};
    for (int i = 0; i < 8 && i < step; ++i) {
        QGeoSatelliteInfo s;
        s.setPrnNumber(prn[i]);
        s.setSignalStrength(qMin(48, 12 + step * 2 + i * 3));
        s.setAttribute(QGeoSatelliteInfo::Azimuth, az[i]);
        s.setAttribute(QGeoSatelliteInfo::Elevation, el[i]);
        view.append(s);
        if (step > 4 && i < 5) use.append(s);
    }
    onView(view);
    onUse(use);
    QTimer::singleShot(1500, this, SLOT(fakeTick()));
}

void Satellites::stop()
{
    if (m_src && m_active) { m_src->stopUpdates(); m_active = false; emit activeChanged(); }
}

void Satellites::clear()
{
    m_view.clear(); m_usePrn.clear(); rebuild();
}

void Satellites::onView(const QList<QGeoSatelliteInfo> &list)
{
    m_view = list; rebuild();
}

void Satellites::onUse(const QList<QGeoSatelliteInfo> &list)
{
    m_usePrn.clear();
    for (int i = 0; i < list.size(); ++i) m_usePrn.append(list.at(i).prnNumber());
    // satellites in use that were not reported in view yet
    for (int i = 0; i < list.size(); ++i) {
        bool found = false;
        for (int j = 0; j < m_view.size(); ++j)
            if (m_view.at(j).prnNumber() == list.at(i).prnNumber()) { found = true; break; }
        if (!found) m_view.append(list.at(i));
    }
    rebuild();
}

void Satellites::rebuild()
{
    QVariantList all, used;
    for (int i = 0; i < m_view.size(); ++i) {
        const QGeoSatelliteInfo &s = m_view.at(i);
        QVariantMap m;
        m.insert("prn", s.prnNumber());
        m.insert("snr", s.signalStrength());
        m.insert("azimuth", s.hasAttribute(QGeoSatelliteInfo::Azimuth) ? s.attribute(QGeoSatelliteInfo::Azimuth) : -1.0);
        m.insert("elevation", s.hasAttribute(QGeoSatelliteInfo::Elevation) ? s.attribute(QGeoSatelliteInfo::Elevation) : -1.0);
        bool u = m_usePrn.contains(s.prnNumber());
        m.insert("used", u);
        all.append(m);
        if (u) used.append(m);
    }
    m_all = all; m_used = used;
    emit changed();
}

QVariantList Satellites::inView() const { return m_all; }
QVariantList Satellites::inUse() const { return m_used; }

/* ---------- helpers ---------- */

Helper::Helper(QObject *parent) : QObject(parent), m_settings("gpsinfo-n9", "gpsinfo-n9") {}

QVariant Helper::setting(const QString &key, const QVariant &def) { return m_settings.value(key, def); }
void Helper::setSetting(const QString &key, const QVariant &value) { m_settings.setValue(key, value); m_settings.sync(); }
void Helper::copy(const QString &text) { QApplication::clipboard()->setText(text); }
QString Helper::version() const { return QString(GPSINFO_VERSION); }

QString Helper::language() const
{
    QByteArray env = qgetenv("GPSINFO_LANG");
    if (!env.isEmpty()) return QString::fromLatin1(env);
    QProcess p;
    p.start("/usr/bin/gconftool-2", QStringList() << "-g" << "/meegotouch/i18n/language");
    if (p.waitForFinished(2000)) {
        QString l = QString::fromLatin1(p.readAllStandardOutput()).trimmed();
        if (!l.isEmpty()) return l;
    }
    return QString::fromLatin1(qgetenv("LANG"));
}

/* ---------- network for map tiles ----------
 * - own User-Agent (tile servers block the default Qt one),
 * - network always "accessible" (Harmattan bearer management may otherwise
 *   refuse requests from an app that did not open its own session),
 * - small disk cache for tiles. */
TileNam::TileNam(QObject *parent) : QNetworkAccessManager(parent)
{
    setNetworkAccessible(QNetworkAccessManager::Accessible);
    QNetworkDiskCache *cache = new QNetworkDiskCache(this);
    // one cache folder per manager (QML may create several, one per thread)
    static int count = 0;
    QString dir = QDir::homePath() + "/.cache/gpsinfo-n9/" + QString::number(count++);
    QDir().mkpath(dir);
    cache->setCacheDirectory(dir);
    cache->setMaximumCacheSize(30 * 1024 * 1024);
    setCache(cache);
    connect(this, SIGNAL(finished(QNetworkReply*)), this, SLOT(onFinished(QNetworkReply*)));
}

QNetworkReply *TileNam::createRequest(Operation op, const QNetworkRequest &req, QIODevice *data)
{
    QNetworkRequest r(req);
    r.setRawHeader("User-Agent", "gpsinfo-n9/" GPSINFO_VERSION " (Nokia N9; +https://github.com/smyhu/gpsinfo-n9)");
    r.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    if (networkAccessible() != QNetworkAccessManager::Accessible)
        setNetworkAccessible(QNetworkAccessManager::Accessible);
    if (!qgetenv("GPSINFO_DEBUG").isEmpty())
        qWarning("tile request: %s", qPrintable(r.url().toString()));
    return QNetworkAccessManager::createRequest(op, r, data);
}

void TileNam::onFinished(QNetworkReply *reply)
{
    if (!qgetenv("GPSINFO_DEBUG").isEmpty() && reply->error() == QNetworkReply::NoError)
        qWarning("tile ok %d: %s", reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt(),
                 qPrintable(reply->url().toString()));
    if (reply->error() != QNetworkReply::NoError)
        qWarning("tile error %d: %s (%s)", (int)reply->error(),
                 qPrintable(reply->errorString()), qPrintable(reply->url().toString()));
}

static const char *UA = "gpsinfo-n9/" GPSINFO_VERSION " (Nokia N9; +https://github.com/smyhu/gpsinfo-n9)";

TileJob::TileJob(const QString &k, const QUrl &u, int r, QObject *parent)
    : QObject(parent), key(k), url(u), redirects(r), status(0), m_finished(false)
{
    m_sock = new QSslSocket(this);
    connect(m_sock, SIGNAL(readyRead()), this, SLOT(onRead()));
    connect(m_sock, SIGNAL(disconnected()), this, SLOT(onClosed()));
    connect(m_sock, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(onError()));
    connect(&m_timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    m_timer.setSingleShot(true);
    m_timer.start(25000);
    bool tls = url.scheme() == "https";
    if (tls) {
        connect(m_sock, SIGNAL(encrypted()), this, SLOT(onConnected()));
        m_sock->connectToHostEncrypted(url.host(), url.port(443));
    } else {
        connect(m_sock, SIGNAL(connected()), this, SLOT(onConnected()));
        m_sock->connectToHost(url.host(), url.port(80));
    }
}

void TileJob::onConnected()
{
    QByteArray path = url.encodedPath();
    if (path.isEmpty()) path = "/";
    if (url.hasQuery()) path += "?" + url.encodedQuery();
    QByteArray req = "GET " + path + " HTTP/1.1\r\nHost: " + url.host().toLatin1() +
        "\r\nUser-Agent: " + QByteArray(UA) + "\r\nAccept: image/png,image/*\r\nConnection: close\r\n\r\n";
    m_sock->write(req);
}

void TileJob::onRead()
{
    QByteArray d = m_sock->readAll();
    m_buf += d;
    if (d.size() > 0) emit progress(d.size());
}

void TileJob::onClosed() { m_buf += m_sock->readAll(); finish(); }

void TileJob::onError()
{
    // the server closing the connection after the reply is normal for HTTP/1.0
    if (m_sock->error() == QAbstractSocket::RemoteHostClosedError) { onClosed(); return; }
    error = m_sock->errorString();
    finish();
}

void TileJob::onTimeout() { error = "timeout"; finish(); }

void TileJob::finish()
{
    if (m_finished) return;
    m_finished = true;
    m_timer.stop();
    int end = m_buf.indexOf("\r\n\r\n");
    if (error.isEmpty() && end > 0) {
        QList<QByteArray> lines = m_buf.left(end).split('\n');
        QList<QByteArray> first = lines.value(0).trimmed().split(' ');
        status = first.value(1).toInt();
        bool chunked = false;
        for (int i = 1; i < lines.size(); ++i) {
            QByteArray l = lines.at(i).trimmed();
            QByteArray low = l.toLower();
            if (low.startsWith("location:")) location = QString::fromLatin1(l.mid(9).trimmed());
            if (low.startsWith("transfer-encoding:") && low.contains("chunked")) chunked = true;
        }
        body = m_buf.mid(end + 4);
        if (chunked) {
            QByteArray out;
            int p = 0;
            while (p < body.size()) {
                int le = body.indexOf("\r\n", p);
                if (le < 0) break;
                bool okHex = false;
                int len = body.mid(p, le - p).split(';').value(0).trimmed().toInt(&okHex, 16);
                if (!okHex || len <= 0) break;
                out += body.mid(le + 2, len);
                p = le + 2 + len + 2;
            }
            body = out;
        }
    } else if (error.isEmpty()) {
        error = "empty reply";
    }
    m_sock->abort();
    emit done(this);
}

TileCache::TileCache(QObject *parent) : QObject(parent), m_running(0), m_revision(0), m_failed(0), m_bytes(0)
{
    m_debug = !qgetenv("GPSINFO_DEBUG").isEmpty();
    m_dir = QDir::homePath() + "/.cache/gpsinfo-n9/tiles";
    QDir().mkpath(m_dir);
}

QString TileCache::fileFor(const QString &url) const
{
    return m_dir + "/" + QString::fromLatin1(QCryptographicHash::hash(url.toUtf8(), QCryptographicHash::Md5).toHex()) + ".img";
}

QString TileCache::local(const QString &url)
{
    if (url.isEmpty()) return QString();
    QString f = fileFor(url);
    if (QFile::exists(f)) return QUrl::fromLocalFile(f).toString();
    if (!m_known.contains(url)) {
        if (m_failedAt.contains(url) && m_failedAt.value(url).secsTo(QDateTime::currentDateTime()) < 30)
            return QString();
        m_known.insert(url);
        m_queue.prepend(url);          // newest first: the tiles on screen now
        if (m_queue.size() > 60) m_known.remove(m_queue.takeLast());
        QTimer::singleShot(0, this, SLOT(next()));   // not inside the QML binding
    }
    return QString();
}

void TileCache::start(const QString &key, const QUrl &url, int redirects)
{
    if (m_debug) qWarning("tile request: %s", qPrintable(url.toString()));
    TileJob *job = new TileJob(key, url, redirects, this);
    connect(job, SIGNAL(done(TileJob*)), this, SLOT(onDone(TileJob*)));
    connect(job, SIGNAL(progress(int)), this, SLOT(onProgress(int)));
    m_running++;
}

void TileCache::next()
{
    while (m_running < 6 && !m_queue.isEmpty()) {
        QString url = m_queue.takeFirst();
        start(url, QUrl(url), 0);
    }
    emit stateChanged();
}

void TileCache::onProgress(int n)
{
    m_bytes += n;
    emit bytesChanged();
}

void TileCache::onDone(TileJob *job)
{
    m_running--;
    QString url = job->key;
    bool ok = false;
    if (job->error.isEmpty() && (job->status == 301 || job->status == 302 || job->status == 307 || job->status == 308)
            && !job->location.isEmpty() && job->redirects < 3) {
        start(url, job->url.resolved(QUrl(job->location)), job->redirects + 1);
    } else if (job->error.isEmpty() && job->status == 200 && job->body.size() > 0) {
        QString f = fileFor(url);
        QFile out(f + ".part");
        if (out.open(QIODevice::WriteOnly)) {
            out.write(job->body);
            out.close();
            QFile::remove(f);
            out.rename(f);
        }
        m_known.remove(url);
        m_revision++;
        ok = true;
        if (m_debug) qWarning("tile ok: %s (%d bytes)", qPrintable(url), job->body.size());
    } else {
        m_known.remove(url);
        m_failedAt.insert(url, QDateTime::currentDateTime());
        m_failed++;
        qWarning("tile error: HTTP %d %s (%s)", job->status, qPrintable(job->error), qPrintable(job->url.toString()));
    }
    job->deleteLater();
    next();
    if (ok) emit revisionChanged();
}

class TileNamFactory : public QDeclarativeNetworkAccessManagerFactory
{
public:
    QNetworkAccessManager *create(QObject *parent) { return new TileNam(parent); }
};

int main(int argc, char **argv)
{
    QApplication app(argc, argv);
    app.setApplicationName("gpsinfo-n9");
    QString base = "/opt/gpsinfo-n9/qml/";
    QByteArray dir = qgetenv("GPSINFO_QML");
    if (!dir.isEmpty()) base = QString::fromLatin1(dir);

    Satellites sats;
    Helper helper;
    TileCache tiles;
    QDeclarativeView view;
    TileNamFactory namFactory;
    view.engine()->setNetworkAccessManagerFactory(&namFactory);
    view.rootContext()->setContextProperty("sats", &sats);
    view.rootContext()->setContextProperty("helper", &helper);
    view.rootContext()->setContextProperty("tiles", &tiles);
    QObject::connect(view.engine(), SIGNAL(quit()), &app, SLOT(quit()));
    view.setSource(QUrl::fromLocalFile(base + "main.qml"));
    view.showFullScreen();
    int r = app.exec();
    sats.stop();
    return r;
}
