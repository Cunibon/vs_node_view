## 1.2.3

**Changes**:
* Added additionalNodes to VSNodeDataProvider/VSNodeManager/VSNodeSerializationManager to allow adding nodes that will not be displayed in the context menu
* Made errors in evalutations be more informational 

## 1.2.2

**Fix**:
* Fixed read me

**Changes**:
* Added option to pass a VSNodeManager to the VSNodeDataProvider instead of it creating one

## 1.2.1

**Fix**:
* Fixed didUpdateWidget looping
* Fixed line jittering when pressing ALT
* Fixed lines sometimes drawing behind Nodes
* Fixed node drag feedback scaling issue

**Changes**:
* Added onLongPressStart to the default gestures that open the context menu
* Made missing NodeBuilder in deserialization fail nicely
* Added onBuilderMissing call to handle missing NodeBuilder

## 1.2.0

**Breaking**:
* Updated to new Flutter version 3.19.1
* Renamed VSInputDatas connectedNode to connectedInterface to be more accurat
* Made InteractiveVSNodeView take VSNodeView as an optional parameter to reduce duplicate code

**Features**:
* Added getInterfaceIcon function to Interfaces
* Added option to use your own interfaceIcon widget
* Added onUpdatedConnection function to nodes
* Added new Special Node VSListNode

## 1.1.0

**Breaking**:
* Split "name" of interfaces into "type" and "title" (Allows for localization without breaking serialization)

**Features**:
* Added loadSerializedNodes function
* Added tooltips to nodes and interfaces
* Exposed GestureDetector to allow for customization

## 1.0.2

**Fix**:
* Fixed deserialization sometimes failing for "int" that should be double

**Features**:
* Added clearNodes and removeNodes functions

**Changes**:
* Moved selection button to "Alt" as it intervered with inputs

## 1.0.1

* Added demo to README

## 1.0.0

* First release of vs_node_view

**Introduces**:
* Create you own nodes with typed inputs and outputs
* Interact with the nodes visualy on a scalable canvas
* Evaluate the nodes into a result (also possible without the UI component)
* Serialize and deserialize the nodes
