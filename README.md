FlamingoEditor
==============

FlamingoEditor is an editor, meant to visualize and modify data in FlamingoModel. It consists of five windows with tables showing the data:

    * Organizations
    * Locations
    * Routes
    * Services
    * Series

Data can be imported and exported to an application-specific XML format and imported from GTFS.


Compiling from source
---------------------

Create a location where you want to host your files.
```mkdir firstflamingo; cd firstflamingo```

Checkout the Flamingo Model:
```git clone https://github.com/firstflamingo/FlamingoModel```

Checkout this repository:
```git clone https://github.com/firstflamingo/FlamingoEditor```

You can now open FlamingoEditor.xcodeproj in Xcode, and run.


Importing Sample Data
---------------------

The repository includes a directory SampleData with data of the Dutch railway network:

    1. Organizations.xml
    2. Locations.xml
    3. Routes.xml
    4. Services.xml
    5. Series.xml

To import these files run FlamingoEditor and choose **File/Import XML...**  
The files must be imported in the indicated order.


Saving Data
-----------

FlamingoEditor is designed as a "shoebox-app" with one data file that gets automatically loaded.
This file lives at ```~/Library/FlamingoEditor/```  
Date can be manually saved with **File/Save**


Importing GTFS Data
-------------------

FlamingoEditor can import GTFS data from the Dutch railway network, as provided by ovapi.nl:

    1. Go to ```http://gtfs.ovapi.nl/ns/``` to get the latest version of the data and unzip the file
    2. Open FlamingoEditor and select the Series window
    3. Choose **File/Import GTFS...**
    4. Select the directory where the GTFS data is located

Importing GTFS data will take a significant amount of time (ca. one hour).