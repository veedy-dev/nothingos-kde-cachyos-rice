#include <QCoreApplication>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusVariant>
#include <QHash>
#include <QSet>
#include <QTimer>
#include <QVariantMap>

class EdgeGroups final : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.nothingos.EdgeGroups")
    Q_PROPERTY(bool LeftVisible READ leftVisible)
    Q_PROPERTY(bool RightVisible READ rightVisible)

public:
    explicit EdgeGroups(QObject *parent = nullptr)
        : QObject(parent)
    {
        configureTimer(m_leftTimer, QStringLiteral("left"));
        configureTimer(m_rightTimer, QStringLiteral("right"));
        m_leftTimer.start();
        m_rightTimer.start();
    }

    bool leftVisible() const { return m_leftVisible; }
    bool rightVisible() const { return m_rightVisible; }

public slots:
    Q_SCRIPTABLE void ActivateDesktop(const QString &desktopId)
    {
        QDBusMessage message = QDBusMessage::createMethodCall(
            QStringLiteral("org.kde.KWin"),
            QStringLiteral("/VirtualDesktopManager"),
            QStringLiteral("org.freedesktop.DBus.Properties"),
            QStringLiteral("Set"));
        message << QStringLiteral("org.kde.KWin.VirtualDesktopManager")
                << QStringLiteral("current")
                << QVariant::fromValue(QDBusVariant(desktopId));
        QDBusConnection::sessionBus().send(message);
    }

    Q_SCRIPTABLE void SetHovered(const QString &group,
                                 const QString &member,
                                 bool hovered)
    {
        if (group != QLatin1String("left") && group != QLatin1String("right")) {
            return;
        }

        QSet<QString> &members = m_hovered[group];
        QTimer &timer = group == QLatin1String("left") ? m_leftTimer : m_rightTimer;

        if (hovered) {
            members.insert(member);
            timer.stop();
            setVisible(group, true);
        } else {
            members.remove(member);
            if (members.isEmpty()) {
                timer.start();
            }
        }
    }

private:
    void configureTimer(QTimer &timer, const QString &group)
    {
        timer.setInterval(10000);
        timer.setSingleShot(true);
        connect(&timer, &QTimer::timeout, this, [this, group]() {
            if (m_hovered[group].isEmpty()) {
                setVisible(group, false);
            }
        });
    }

    void setVisible(const QString &group, bool visible)
    {
        bool *state = group == QLatin1String("left")
            ? &m_leftVisible
            : &m_rightVisible;
        if (*state == visible) {
            return;
        }
        *state = visible;

        const QString property = group == QLatin1String("left")
            ? QStringLiteral("LeftVisible")
            : QStringLiteral("RightVisible");
        QVariantMap changed;
        changed.insert(property, visible);

        QDBusMessage signal = QDBusMessage::createSignal(
            QStringLiteral("/EdgeGroups"),
            QStringLiteral("org.freedesktop.DBus.Properties"),
            QStringLiteral("PropertiesChanged"));
        signal << QStringLiteral("org.nothingos.EdgeGroups")
               << changed
               << QStringList();
        QDBusConnection::sessionBus().send(signal);
    }

    QHash<QString, QSet<QString>> m_hovered;
    QTimer m_leftTimer;
    QTimer m_rightTimer;
    bool m_leftVisible = true;
    bool m_rightVisible = true;
};

int main(int argc, char **argv)
{
    QCoreApplication application(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("nothingos-edge-groups"));

    QDBusConnection bus = QDBusConnection::sessionBus();
    if (!bus.registerService(QStringLiteral("org.nothingos.EdgeGroups"))) {
        qCritical("Could not register org.nothingos.EdgeGroups");
        return 1;
    }

    EdgeGroups groups;
    if (!bus.registerObject(QStringLiteral("/EdgeGroups"),
                            &groups,
                            QDBusConnection::ExportAllSlots
                                | QDBusConnection::ExportAllProperties)) {
        qCritical("Could not register /EdgeGroups");
        return 1;
    }

    return application.exec();
}

#include "main.moc"
