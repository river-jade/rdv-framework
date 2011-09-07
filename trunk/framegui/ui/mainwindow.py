'''
Created on 12.4.2010

@author: jlehtoma
'''

# Standard system imports

import sys
import platform
import pickle

# Qt modules

from PyQt4.QtCore import (pyqtSignature, QT_VERSION_STR, PYQT_VERSION_STR,
                          QString, Qt)
from PyQt4.QtGui import (QApplication, QMainWindow, QMessageBox, QFileDialog,
                         QWidget, QVBoxLayout, QTextEdit, QIcon, QPixmap,
                         QToolButton, QDialog)

# Package specific imports

from ui.ui_toolLoader import Ui_MainWindow
from ui.ui_helpDialog import Ui_Dialog

# Third-party imports

from yaml import safe_load
from formlayout import FormWidget
__version__ = "0.0.2"

class FrameGUIWindow(Ui_MainWindow, QMainWindow):
    '''
    classdocs
    '''

    def __init__(self, files=None, parent=None):
        '''
        Constructor
        '''
        # Create and update the main GUI window
        super(Ui_MainWindow, self).__init__(parent)
        self.setupUi(self)

        # Set up the console for GUI
        self.console = QConsole(self.dockWidgetContents_2)
        self.console.setEnabled(True)
        self.console.setTextInteractionFlags(Qt.TextSelectableByKeyboard|Qt.TextSelectableByMouse)
        self.console.setObjectName("console")
        self.verticalLayout_2.addWidget(self.console)

        self.helpDlg = None
        
        self.tabWidget.currentChanged.connect(self.update_ui)

        self.tools = {}

        # Add tool files if they're provided as parameters  
        if files is not None:
            for file in files:
                self.add_tool(file)

        # Start: Added by Bill and Ascelin
        # End : Added by Bill and Ascelin

    @pyqtSignature("")
    def on_actionLoadTool_triggered(self):
        file = QFileDialog.getOpenFileName(None,
                                    self.trUtf8("Select tool definition"),
                                    QString("../data"),
                                    self.trUtf8("*.yaml"),
                                    None)
        if file != QString(u''):
            self.add_tool(file)

    @pyqtSignature("")
    def on_actionAbout_triggered(self):
        QMessageBox.about(self, "About Sppeculate",
                """<b>FrameGUI</b> v %s
                <p>Copyright &copy; 2010 Joona Lehtomaki.
                All rights reserved.
                <p>Lorem Ipsum.
                <p>Python %s - Qt %s - PyQt %s on %s""" % (
                __version__, platform.python_version(),
                QT_VERSION_STR, PYQT_VERSION_STR, platform.system()))



    @pyqtSignature("")
    def on_runButton_clicked(self):
        #sys.stdout = self.console
        #r_home = r'C:\Users\jlehtoma\Documents\EclipseWorkspace\Framework\trunk\framework\R'
        #r_file = r'hg.simulation.R'
        #run_rfunction('source', fix_path(os.path.join(r_home, r_file)))


        #data = self.get_values('Parameters')
        #self.log(data)

        #f = open('GUI_params.pickle', 'w') 
        #pickle.dump (data,f)
        #f.close()

        # write the data stored in the gui to a pickle file
        for tabName in self.tools.keys():
            
            data = self.get_values(tabName)
            self.log(data)

            filename = tabName + ".pickle"
            f = open(filename, 'w') 
            pickle.dump (data,f)
            f.close()

        # here you can call the Rdv_run_sims_gui.main and pass the
        # data using
        # Rdv_run_sims_gui.main(data)
        
        # but instead going to try and pickle the data so it can be
        # read into Rdv_run_sims_gui from using unpickle 
        
        #f = open('GUI_params.pickle', 'w') 
        #pickle.dump (data,f)
        #f.close()
        
        #data = self.get_values('Scen1')
        #self.log(data)
        #f = open('GUI_params_s1.pickle', 'w') 
        #pickle.dump (data,f)
        #f.close()
        

        #run_rfunction('run.simulation', input, output, type=type,
        #              landscapes=landscapes)


    def add_tool(self, infile):
        try:
            
            # this is where the yaml file gets loaded 
            definition = safe_load(open(infile))
                
            for key, value in definition.iteritems():

                print "The list of tabs is"
                print self.tools.keys()
                
                formwidget = FormWidget(value, comment='', parent=self)
                tab = QWidget()
                tab.setObjectName(key)
                self.tabWidget.addTab(tab, key)
                vboxLayout = QVBoxLayout(tab)
                vboxLayout.setObjectName("vboxLayout")
                vboxLayout.addWidget(formwidget)

                helpButton = QToolButton(tab)
                icon = QIcon()
                icon.addPixmap(QPixmap(":/icons/icons/help_about.png"),
                               QIcon.Normal, QIcon.Off)
                helpButton.setIcon(icon)
                helpButton.setObjectName("helpButton")

                helpButton.clicked.connect(self.tool_help)

                vboxLayout.addWidget(helpButton)

                formwidget.show()
                self.tabWidget.setCurrentWidget(tab)
                self.tools[key] = formwidget
                self.log("Added tool <b>%s</b>" % key)

        except IOError, e:
            self.log('\n'.join(["Cannot load existing project file.", 
                                str(e)]))

    def get_values(self, tool):
        return self.tools[tool].get()

    def get_help(self, tool):
        return self.tools[tool].get_help()

    def log(self, msg):
        if isinstance(msg, str):
            self.console.append(msg)
        elif isinstance(msg, list):
            self.console.append('\n'.join([str(item) for item in msg]))
        elif isinstance(msg, dict):
            self.console.append('\n'.join([str(key) + ': '+ str(value) for key, value
                                          in msg.iteritems()]))

    def remove_tool(self, index):
        self.tabWidget.removeTab(index)

    def tool_help(self):
        tool = unicode(self.tabWidget.currentWidget().objectName())
        msg = '<br><br>'.join(self.get_help(tool))
        if self.helpDlg is None:
            self.helpDlg = HelpDialog(tool, msg, self)
        else:
            self.helpDlg.set_context(tool, msg)

        self.helpDlg.show()
        self.helpDlg.raise_()
        self.helpDlg.activateWindow()

    def update_ui(self):
        if self.helpDlg is not None:
            self.tool_help()

class HelpDialog(Ui_Dialog, QDialog):

    def __init__(self, name, text, parent=None):
        super(HelpDialog, self).__init__(parent)

        self.setupUi(self)
        self.setWindowTitle(QString('Help: ' + name))
        self.helpEdit.setText(text)

    def set_context(self, name, text):
        self.setWindowTitle(QString('Help: ' + name))
        self.helpEdit.setText(text)

class QConsole(QTextEdit):

    def write(self, msg):
        self.append(msg)

def main():
    # Create the main application
    app = QApplication(sys.argv)
    app.setOrganizationName("University of Helsinki")
    app.setOrganizationDomain("uh.fi")
    app.setApplicationName("Framegui")
    
    inFileNameList = ["../data/test_params.yaml", 
                      "../data/test_params_s1.yaml"]
    
    win = FrameGUIWindow(files=inFileNameList)
    win.show()    
    
    app.exec_()

if __name__ == '__main__':
    
    sys.exit(main())