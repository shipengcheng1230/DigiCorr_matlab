import DataType.*
import FilterModule.FilterModel

contextObj = Context.getInstance();

currentdata = CurrentData();
signaldata = SignalData();
pipinfo = PipInfo();
processdata = ProcessData(currentdata, signaldata, pipinfo);

contextObj.register('SignalData', signaldata);
contextObj.register('ProcessData', processdata);
contextObj.register('PipInfo', pipinfo);
contextObj.register('CurrentData', currentdata);

myfilter = FilterModel();
contextObj.register('Filter', myfilter);

manageview = ManageView();
