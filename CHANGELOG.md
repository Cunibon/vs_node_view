## 1.2.0

* Breaking:
* Updated to new Flutter version 3.19.1
* Renamed VSInputDatas connectedNode to connectedInterface to be more accurat
* Made InteractiveVSNodeView take VSNodeView as an optional parameter to reduce duplicate code

* Features:
* Added getInterfaceIcon function to Interfaces
* Added option to use your own interfaceIcon widget
* Added onUpdatedConnection function to nodes
* Added new Special Node VSListNode

## 1.1.0

* Breaking:
* Split "name" of interfaces into "type" and "title" (Allows for localization without breaking serialization)

* Added loadSerializedNodes function
* Added tooltips to nodes and interfaces
* Exposed GestureDetector to allow for customization

## 1.0.2

* Fixed deserialization sometimes failing for "int" that should be double
* Moved selection button to "Alt" as it intervered with inputs
* Added clearNodes and removeNodes functions

## 1.0.1

* Added demo to README

## 1.0.0

* First release of vs_node_view

Introduces:
* Create you own nodes with typed inputs and outputs
* Interact with the nodes visualy on a scalable canvas
* Evaluate the nodes into a result (also possible without the UI component)
* Serialize and deserialize the nodes
