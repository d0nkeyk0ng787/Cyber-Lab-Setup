# AD Automation Scripts - README

### TODO

- [ ] Auto group script
- [ ] Auto DHCP & DNS
- [ ] Merge User, OU, & group scripts 

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
* If you have more then 1 VMSwitch, specify the name of the switch in the script at line 40

Template requirements:
* Simply enter in the required information in the format given. An example:
```csv
VMName Memory Path     NewVHDPath StorageSize ISOPath
DC1    2048   D:\VMS\  D:\VMS\    60          D:\ISOS\
```

### Pre AD Script
Script change requirements:
* Change the values for the 5 variables to match your networks requirements.

### Install AD Script
Script change requirements:
* Change domain name value
* Change the value of the password
