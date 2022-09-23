# AD Automation Scripts - README

### Auto OU Script

Script change requirements:
* Change the path of the ouschema.csv file to wherever you have it installed.

Template requirements:
* Simply enter in the required information in the format given. An example:
```csv
Name      Path
XYZ       DC=lab,DC=local
Devices   OU=LAB,DC=xyz,DC=local
```

### Auto User Script
Script change requirements:
* Change the path of the userschema.csv file to wherever you have it installed.

Template requirements:
* Simply enter in the required information in the format given. An example:
```csv
FirstName  LastName  Username   Password  OU 
John       Smith john.smith	Password  OU=Employees,OU=Users,OU=XYZ,DC=xyz,DC=local
```

### Hyper-V VM Creator

Script change requirements:
* Change the path of the vmschema.csv file to wherever you have it installed.

Template requirements:
* Simply enter in the required information in the format given. An example:
```csv
VMName Memory Path     NewVHDPath StorageSize ISOPath
DC1    2048   D:\VMS\  D:\VMS\    60          D:\ISOS\
```
