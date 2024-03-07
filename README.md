A Visual Scripting toolkit to create and use your own VS widgets.

This package lets you define your own VSNodes and their interactions. These can be used by your users to create custom behaviours in your app.

Check out the Demo: https://firebon.de:8081/VSDemo/

<p>
  <img src="https://firebon.de:8081/VSDemo/VSDemo.png"
    alt="An example of a node tree created with the package"/>
</p>

In case you want to use this package in Web make sure to add 
```html
<html oncontextmenu="event.preventDefault();"></html>
```
At the top of the index.html file

## Features

Use this plugin in your Flutter app to:

* Create you own nodes with typed inputs and outputs
* Interact with the nodes visualy on a scalable canvas
* Evaluate the nodes into a result (also possible without the UI component)
* Serialize and deserialize the nodes

## Usage

* [Interfaces](#interfaces)
* [Defining nodes](#defining-nodes)
* [Using VSNodeDataProvider](#using-VSNodeDataProvider)
* [Using VSNodeView](#using-VSNodeView)
* [Using InteractiveVSNodeView](#using-interactiveVSNodeView)

### Interfaces

Interfaces are used by nodes to create connections.
Interfaces have types and will only interact with interfaces of certain types.

Interfaces are split into 2 categories:
* Inputs
* Outputs

There are 6 base interfaces which each have an Input and Output varient:

* dynamic (As an Input: Will take any Output)
* bool (As an Input: Will take bool and dynamic Outputs)
* int (As an Input: Will take int, num and dynamic Outputs)
* double (As an Input: Will take double, num and dynamic Outputs)
* num (As an Input: Will take int, double, num and dynamic Outputs)
* string (As an Input: Will take string and dynamic Outputs)

All interfaces have a "type", type will be used for deserialization and should not be changed if it already reached production, as deserialization will fail.
Use "title" to add localization independent of serialization. 
Use "toolTip" to add a tool tip when hovering over an interface with the cursor.
Use "interfaceIconBuilder" to customise the interface Widget per interface instance, instead of for all interfaces of this type.

Lets look at how you can define your own interface if you want to use your own class for visual scripting

```dart
///Define an interface color that will be used by the UI for its input and output
///You can also define them in the classes if you would like input and output to have different colors
const Color _interfaceColor = Colors.pink;

///This is your input Interface
///It need to extend VSInputData and provide type and initialConnection to its super
class MyFirstInputData extends VSInputData {
  MyFirstInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  ///A list of Types this input will accept
  ///Define what outputs this input will interact with
  ///The dynamic output will be accepted by any input by default
  @override
  List<Type> get acceptedTypes => [
        MyFirstOutputData,
      ];

  ///Defines the color this interface will have in the UI fo the Icon and Lines between nodes
  @override
  Color get interfaceColor => _interfaceColor;

  ///You can take control over the interface Widget for a specific Interface type by overriding this function
  ///This is for all interafaces of this type, use interfaceIconBuilder to customise the Widget per instance of the interface
  @override
  Widget getInterfaceIcon({required BuildContext context, required GlobalKey anchor,}) {
    return MyWidget();
  }
}

///This is your output Interface
///It need to extend VSOutputData with a Type 
///The Type defines what the attached output function will return
///You need to pass type and outputFunction to the super
class MyFirstOutputData extends VSOutputData<MyCoolClass> {
  MyFirstOutputData({
    required super.type,
    super.title,
    super.toolTip,
    super.outputFunction,
    super.interfaceIconBuilder,
  });

  @override
  Color get interfaceColor => _interfaceColor;

  ///This can be done for booth types of interfaces
  @override
  Widget getInterfaceIcon({required BuildContext context, required GlobalKey anchor,}) {
    return MyWidget();
  }
}
```

Now that we know about interfaces lets look at nodes

### Defining nodes

All nodes are defined with a function.
The function will be called when creating new nodes or when deserializing them to make sure all classes are new instances.

All nodes have a "type", there cannot be multiple nodes defined with the same type. 
"type" will be used for deserialization and should not be changed if it already reached production, as deserialization will fail.
"type" will be displayed to the user as a fallback if no title is given.
Nodes have inputs, there cannot be multiple inputs with the same "name" defined in the same node. 
Nodes have outputs, there cannot be multiple outputs with the same "name" defined in the same node. 
The input data will be given to all outputs via a Map<String, dynamic>. The key is the name of the input and the value is what ever the input has received.

* [Normal nodes](#simple-nodes)
* [Widget nodes](#widget-nodes)
* [List nodes](#list-nodes)
* [Output nodes](#output-nodes)

#### Normal nodes

Normal nodes are all nodes that use VSNodeData.
These nodes expect inputs and return outputs.

You define one like this:

```dart
VSNodeData parseIntNode(Offset offset, VSOutputData? ref) {
  return VSNodeData(
    type: "Parse int",
    widgetOffset: offset,
    inputData: [
      VSStringInputData(
        name: "Input",
        initialConnection: ref,
      )
    ],
    outputData: [
      VSIntOutputData(
        name: "Output",
        outputFunction: (data) {
          return int.parse(data["Input"]);
        },
      ),
    ],
  );
}
```

#### Widget nodes

Widget nodes are all nodes that use VSWidgetNode.
They need a Widget (child) and a setValue/getValue function which will be used to serialize/deserialize the data

Widget nodes allow you to create a user input using any widget.
They cannot have any inputs and return one output.

You define one like this:

```dart
VSWidgetNode textInputNode(
  Offset offset,
  VSOutputData? ref,
  ) {
  final controller = TextEditingController();
  final inputWidget = TextField(
    controller: controller,
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    ),
  );

  return VSWidgetNode(
    type: "Input",
    widgetOffset: offset,
    outputData: VSStringOutputData(
      type: "Output",
      outputFunction: (data) => controller.text,
    ),
    child: Expanded(child: inputWidget),
    setValue: (value) => controller.text = value,
    getValue: () => controller.text,
  );
}
```

#### List nodes

List nodes are all nodes that use VSListNode.
They need an inputBuilder to create new interfaces in runtime.
The builder gets the index of the newly build interface as well as the connetion this interface will have.
Make sure to pass connection to the initialConnection of the interface in the builder, or it wont work correctly. 

You define one like this:

```dart
VSListNode sumNode(
  Offset offset,
  VSOutputData? ref,
) {
  return VSListNode(
    type: "Sum",
    toolTip: "Adds all supplied Numbers together",
    widgetOffset: offset,
    inputBuilder: (index, connection) => VSNumInputData(
      type: "Input $index",
      initialConnection: connection,
    ),
    outputData: [
      VSNumOutputData(
        type: "output",
        toolTip: "The sum of all supplied values",
        outputFunction: (data) {
          return data.values.reduce((value, element) => value + element);
        },
      )
    ],
  );
}
```

#### Output nodes

Output nodes are all nodes that use VSOutputNode.
They only take one input (dynamic) and can be used to evaluate your node tree

To access them you can use VSNodeManagers getOutputNodes function. This will return all outputs in an Iterable
VSOutputNode has a evaluate function that will return a MapEntry<String,dynamic> containing the name of the node as the key and the result as the value

You define one like this:

```dart
VSOutputNode outputNode(Offset offset, VSOutputData? ref) {
  return VSOutputNode(
    type: "Output",
    widgetOffset: offset,
    ref: ref,
  );
}
```

### Using VSNodeDataProvider

* [Preparing builders](#preparing-builders)
* [Using VSNodeManager directly](#using-VSNodeManager-directly)
* [Creating VSNodeDataProvider](#creating-VSNodeDataProvider)

#### Preparing builders

Now that we have our nodes defined we need to Move them into a collection and pass them to VSNodeDataProvider.
The collection will be passed down to VSNodeSerializationManager which will make sure all rules (mentioned here [Defining nodes](#defining-nodes)) are upheld and will create 2 maps:
* Map<String, VSNodeDataBuilder> _nodeBuilders (used for deserialization)
* Map<String, dynamic> contextNodeBuilders

contextNodeBuilders is passed to the context menu and defines the UI 

Our node builder collection could just be a list of functions like this:

```dart
final List<dynamic> nodeBuilders = [
  textInputNode,
  parseIntNode
  outputNode,
];
```

But since the UI will be created based on the collection we can also use VSSubgroups to group nodes.
VSSubgroups Define a name and a new collection of nodes.

```dart
final List<dynamic> nodeBuilders = [
  VSSubgroup(
    name: "Number",
    subgroup: [
      parseIntNode,
      parseDoubleNode,
      sumNode,
    ],
  ),
  VSSubgroup(
    name: "Logik",
    subgroup: [
      biggerNode,
      ifNode,
    ],
  ),
  textInputNode,
  outputNode,
];
```

This way your UI could look something like this:

<p>
  <img src="https://firebon.de:8081/VSDemo/ContextMenu.png"
    alt="An example a context menu using VSSubgroups" height="400"/>
</p>

### Using VSNodeManager directly

VSNodeManager is the heart of all node operations. It keeps track of the data and has some API that can be called to modify said data on a low level.

The node manager gets initialized with the nodeBuilders you want to use and optionaly any serialized Nodes.

If the serializedNodes parameter is passed it will try to derserialize the string and recreate all nodes
Its important to note that the deserialized nodes will use the supplied nodeBuilders to recreate the nodes.
This means if a node is not part of nodeBuilders it cannot be deserialized and will be lost.

```dart
final manager = VSNodeManager(
    nodeBuilders: nodeBuilders,
    serializedNodes: serializedNodes,
);
```

serializedNodes is just a string that can be optained by calling:
```dart
VSNodeManager.serializeNodes()
```

The VSNodeManager also exposes getOutputNodes, this will give you all output nodes that exist in the current node tree.
You can evaluate them to get the final result at said node.
```dart
VSNodeManager.getOutputNodes.map((e) => e.evaluate());
```

#### Creating VSNodeDataProvider
The VSNodeDataProvider takes an instance of VSNodeManager as parameter.
Optionaly you can also pass an instance of VSHistoryManger to track node history.
You can then call:

```dart
VSNodeDataProvider.historyManager!.undo()
VSNodeDataProvider.historyManager!.redo()
```

to move through the history.

A VSNodeDataProvider could be initialized like this:

```dart
final provider = VSNodeDataProvider(
  nodeManager: VSNodeManager(nodeBuilders: nodeBuilders),
  historyManager: VSHistoryManger(), 
);
```

Here as a full example with the nodeBuilders:

```dart
final List<dynamic> nodeBuilders = [
  textInputNode,
  VSSubgroup(
    name: "Number",
    subgroup: [
      parseIntNode,
      parseDoubleNode,
      sumNode,
    ],
  ),
  outputNode,
];

VSNodeDataProvider(
  nodeManager: VSNodeManager(nodeBuilders: nodeBuilders),
);
```

### Using VSNodeView

VSNodeView is the main UI widget.
It allows you to override: 
* The node UI
* The node title UI
* The context menu UI
* The selection area UI
in case you want to style them differently

It expects a VSNodeDataProvider and will inject it into the widget tree

```dart
VSNodeView(
    nodeDataProvider: nodeDataProvider,
),
```

### Using InteractiveVSNodeView

Wraps VSNodeView in a InteractiveViewer.
This allows the user to zoom and pan around a canvas.

You can pass a width and height parameter to define the canvas size.
If width or height are not given the screen width or height will be used instead.

The VSNodeDataProvider has a function "applyViewPortTransfrom" which will apply all viewport transformations (zoom, pan) to a given Offset.
This is neccesarry as Offsets ist mostly given in screen coordinates and thus dont work anymore once the viewport has been altered.

You can pass your own VSNodeView widget to change its settings specifically

```dart
InteractiveVSNodeView(
    width: 5000,
    height: 5000,
    nodeDataProvider: nodeDataProvider,
    baseNodeView: VSNodeView(
      nodeDataProvider: nodeDataProvider,
    ),
),
```

## Additional information

I designed this package so nodes can be interacted with over UI or code with the same interface.
The VSNodeDataProvider wraps VSNodeManager and handles all UI based interactions as well as the state. 
But you could just as well create your own state manager the wraps VSNodeManager and UI while preserving functionality. 

Feel free to create a ticket on the Github repo, I will try to answer as fast as possible, but I also work fulltime.
If you want to support me please check out my game on steam :D 
https://store.steampowered.com/app/2226140/Crypt_Architect/
