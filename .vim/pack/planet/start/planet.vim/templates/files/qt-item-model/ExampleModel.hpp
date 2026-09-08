#pragma once
#include <QAbstractListModel>
#include <QStringList>
class ExampleModel : public QAbstractListModel {
public:
    explicit ExampleModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}
    int rowCount(const QModelIndex &parent = {}) const override { return parent.isValid() ? 0 : values_.size(); }
    QVariant data(const QModelIndex &index, int role) const override {
        if (!index.isValid() || index.row() < 0 || index.row() >= values_.size() || role != Qt::DisplayRole) return {};
        return values_.at(index.row());
    }
private:
    QStringList values_{"First", "Second"};
};
