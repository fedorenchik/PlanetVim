#pragma once
#include <QMainWindow>
#include "ui_mainwindow.h"
class MainWindow : public QMainWindow {
public:
    explicit MainWindow(QWidget *parent = nullptr) : QMainWindow(parent) { ui_.setupUi(this); }
private:
    Ui::MainWindow ui_;
};
