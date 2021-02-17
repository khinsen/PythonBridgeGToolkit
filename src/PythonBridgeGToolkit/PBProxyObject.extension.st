Extension { #name : #PBProxyObject }

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> attributeAt: aSymbol [
	^ self evaluatePythonExpression:
		self => aSymbol
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> attributeDictionary [
	| d |
	d := self attributeAt: '__dict__'.
	(d isKindOf: PBProxyObject) ifFalse: [ ^ d ].
	"For classes, the __dict__ attribute is not a
	 dictionary, but a MappingProxyType, which is a
	 read-only variant of dictionary. Copy its items
	 into a dictionary to get it through
	 serialization."
	^ self evaluatePythonExpression:
		(#dict asP3GI callWith: { d })
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> evaluatePythonExpression: aP3GGenerable [
	^ self application evaluatePythonExpression: aP3GGenerable
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> fullPythonClassName [
	| typeExpr moduleExpr nameExpr fullNameExpr |
	typeExpr := #type asP3GI callWith: { self }.
	moduleExpr := typeExpr => #'__module__'.
	nameExpr := typeExpr => #'__name__'.
	fullNameExpr :=
		P3GBinaryOperator new
			left: (P3GBinaryOperator new
						left: moduleExpr;
						right: '.';
						operator: $+;
						yourself);
			right: nameExpr;
			operator: $+;
			yourself.
	^ self evaluatePythonExpression: fullNameExpr
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> gtAttributesFor: aView [
	<gtView>
	| attributes |
	[ attributes := self attributeDictionary ]
	on: PBPythonError do: [ ^ aView empty ].
	attributes ifEmpty: [ ^ aView empty ].
	^ aView columnedTree
		title: 'Attributes';
		priority: 3;
		items: [ attributes associations
					sorted: [ :a :b | a key <= b key ] ];
		children: [ :each | 
			each value isDictionary
				ifTrue: [ each value associations ]
				ifFalse: [ (each value isArray and: [ each value allSatisfy: #isDictionary ])
						ifTrue: [ each value collectWithIndex: [ :x :i | i -> x ] ]
						ifFalse: [ #() ] ] ];
		column: 'Name' text: [ :assoc | assoc key ];
		column: 'Value' text: [ :assoc | assoc value ];
		send: [ :assoc | assoc value ]
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> gtClassesFor: aView [
	<gtView>
	| classes |
	(self isinstanceOfPythonClass: #ModuleType fromModule: 'types')
		ifFalse: [ ^ aView empty ].
	classes := (self attributeDictionary associations
		select: [ :each | (each value isKindOf: PBProxyObject)
					and: [ each value pythonClass = 'type' ] ])
					asDictionary.
	classes ifEmpty: [ ^ aView empty ].
	^ aView list
		title: 'Classes';
		priority: -3;
		items: [ classes keys ];
		send: [ :each | classes at: each ];
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> gtDocStringFor: aView [
	<gtView>
	| docString |
	[ docString := self attributeAt: #'__doc__' ]
	on: PBPythonError do: [ ^ aView empty ].
	(docString isNil or: [ docString isEmpty ])
		ifTrue: [ ^ aView empty ].
	^ aView forward
		title: 'Docstring';
		priority: 5;
		object: [ docString ];
		view: #gtStringFor:;
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> gtFunctionsFor: aView [
	<gtView>
	| functions |
	(self isinstanceOfPythonClass: #ModuleType fromModule: 'types')
		ifFalse: [ ^ aView empty ].
	functions := (self attributeDictionary associations
		select: [ :each | (each value isKindOf: PBProxyObject)
					and: [ each value pythonClass = 'function' ] ])
					asDictionary.
	functions ifEmpty: [ ^ aView empty ].
	^ aView list
		title: 'Functions';
		priority: -5;
		items: [ functions keys ];
		send: [ :each | functions at: each ];
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> gtMatplotlibFigureFor: aView [
	<gtView>
	| commandFactory sourceCode |
	(self isinstanceOfPythonClass: #Figure fromModule: 'matplotlib.figure')
		ifFalse: [ ^ aView empty ].
	^ aView forward
		title: 'Figure';
		priority: -1;
		object: [  self matplotlibFigureAsPNG ];
		view: #gtFormFor:;
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> gtSourceCodeFor: aView [
	<gtView>
	| commandFactory sourceCode |
	(((self isinstanceOfPythonClass: #FunctionType fromModule: 'types')
		or: [ self isinstanceOfPythonClass: #MethodType fromModule: 'types' ])
		or: [ self isinstanceOfPythonClass: #type fromModule: 'builtins' ])
		ifFalse: [ ^ aView empty ].
	[ sourceCode := self sourceCode ]
	on: PBPythonError do: [ ^ aView empty ].
	^ aView forward
		title: 'Source';
		priority: -1;
		object: [ sourceCode ];
		view: #gtStringFor:;
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> gtStringFor: aView [
	<gtView>
	| string |
	[ string := self evaluatePythonExpression:
				(#'str' asP3GI callWith: { self }) ]
	on: PBPythonError do: [ ^ aView empty ].
	^ aView forward
		title: 'String';
		priority: 2;
		object: [ string ];
		view: #gtStringFor:;
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> isinstanceOfPythonClass: className fromModule: moduleName [
	| class |
	[ class := self application pythonClass: className fromModule: moduleName ]
	on: PBPythonError do: [ ^ false ].
	^ self evaluatePythonExpression:
		(#isinstance asP3GI callWith: { self. class })
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> matplotlibFigureAsPNG [
	"This method is meant to be used only with proxies wrapping
	 matplotlib Figure objects!"
	| commandFactory bytes |
	commandFactory := self application newCommandFactory.
	commandFactory << (#io asP3GI import).
	commandFactory << (#memfile asP3GI <- ((#io asP3GI => #BytesIO) 	callWith: #())).
	commandFactory << ((self => #savefig) callWith: { #memfile asP3GI} with: { #format -> 'png'} asDictionary).
	commandFactory << (#imagedata asP3GI <- ((#memfile asP3GI => #getvalue) callWith: #())).
	commandFactory << (((#memfile asP3GI) => #close) callWith: #()).
	commandFactory << #imagedata asP3GI.
	bytes := commandFactory sendAndWait.
	^ PNGReadWriter formFromStream: bytes readStream
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> sourceCode [
	"Source code retrieval works only for functions, classes,
	 and methods."
	| commandFactory |
	commandFactory := self application newCommandFactory.
	commandFactory << #inspect asP3GI import.
	commandFactory << ((#inspect asP3GI => #getsource) callWith: { self }).
	^ commandFactory send waitForValue
]
