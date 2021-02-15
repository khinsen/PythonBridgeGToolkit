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
	| commandFactory |
	commandFactory := self application newCommandFactory.
	commandFactory << aP3GGenerable.
	^ commandFactory send waitForValue
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
		priority: 5;
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
PBProxyObject >> gtDocStringFor: aView [
	<gtView>
	| docString |
	[ docString := self attributeAt: #'__doc__' ]
	on: PBPythonError do: [ ^ aView empty ].
	docString ifEmpty: [ ^ aView empty ].
	^ aView forward
		title: 'Docstring';
		priority: 4;
		object: [ docString ];
		view: #gtStringFor:;
		yourself
]
