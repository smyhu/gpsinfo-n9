#ifndef GPSINFO_GPS_H
#define GPSINFO_GPS_H
#include <QtCore/QObject>
#include <QtCore/QVariant>
#include <QtCore/QSettings>
#include <QtLocation/QGeoSatelliteInfoSource>
#include <QtLocation/QGeoSatelliteInfo>

QTM_USE_NAMESPACE

class Satellites : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList inView READ inView NOTIFY changed)
    Q_PROPERTY(QVariantList inUse READ inUse NOTIFY changed)
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
public:
    Satellites(QObject *parent = 0);
    QVariantList inView() const;
    QVariantList inUse() const;
    bool available() const;
    bool active() const;
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void clear();
signals:
    void changed();
    void activeChanged();
private slots:
    void onView(const QList<QGeoSatelliteInfo> &list);
    void onUse(const QList<QGeoSatelliteInfo> &list);
    void fakeTick();
private:
    void rebuild();
    QGeoSatelliteInfoSource *m_src;
    bool m_active;
    QList<QGeoSatelliteInfo> m_view;
    QList<int> m_usePrn;
    QVariantList m_all, m_used;
};

class Helper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString language READ language CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
public:
    Helper(QObject *parent = 0);
    Q_INVOKABLE QVariant setting(const QString &key, const QVariant &def);
    Q_INVOKABLE void setSetting(const QString &key, const QVariant &value);
    Q_INVOKABLE void copy(const QString &text);
    QString language() const;
    QString version() const;
private:
    QSettings m_settings;
};
#include <QtNetwork/QNetworkAccessManager>
class TileNam : public QNetworkAccessManager
{
    Q_OBJECT
public:
    TileNam(QObject *parent = 0);
protected:
    QNetworkReply *createRequest(Operation op, const QNetworkRequest &req, QIODevice *data);
private slots:
    void onFinished(QNetworkReply *reply);
};
#include <QtCore/QSet>
#include <QtCore/QHash>
#include <QtCore/QStringList>
#include <QtCore/QDateTime>
/* Map tiles downloaded in the main thread and stored as files; QML shows the files.
 * (On Harmattan, network requests made from the QML image thread never finish.) */
#include <QtNetwork/QSslSocket>
#include <QtCore/QUrl>
#include <QtCore/QTimer>
/* One plain HTTP/1.0 GET over QTcpSocket / QSslSocket.
 * Bypasses QNetworkAccessManager, whose requests never finish on the phone. */
class TileJob : public QObject
{
    Q_OBJECT
public:
    TileJob(const QString &key, const QUrl &url, int redirects, QObject *parent);
    QString key;
    QUrl url;
    int redirects;
    int status;
    QByteArray body;
    QString error;
    QString location;
signals:
    void done(TileJob *job);
    void progress(int bytes);
private slots:
    void onConnected();
    void onRead();
    void onClosed();
    void onError();
    void onTimeout();
private:
    void finish();
    QSslSocket *m_sock;
    QByteArray m_buf;
    QTimer m_timer;
    bool m_finished;
};

class TileCache : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int revision READ revision NOTIFY revisionChanged)
    Q_PROPERTY(int pending READ pending NOTIFY stateChanged)
    Q_PROPERTY(int failed READ failed NOTIFY stateChanged)
    Q_PROPERTY(int bytes READ bytes NOTIFY bytesChanged)
public:
    TileCache(QObject *parent = 0);
    Q_INVOKABLE QString local(const QString &url);
    int revision() const { return m_revision; }
    int pending() const { return m_queue.size() + m_running; }
    int failed() const { return m_failed; }
    int bytes() const { return m_bytes; }
signals:
    void revisionChanged();
    void stateChanged();
    void bytesChanged();
private slots:
    void onDone(TileJob *job);
    void onProgress(int n);
    void next();
private:
    QString fileFor(const QString &url) const;
    void start(const QString &key, const QUrl &url, int redirects);
    QString m_dir;
    QStringList m_queue;
    QSet<QString> m_known;
    QHash<QString, QDateTime> m_failedAt;
    int m_running, m_revision, m_failed, m_bytes;
    bool m_debug;
};
#endif
