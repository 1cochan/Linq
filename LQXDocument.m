//
//  LQXDocument.m
//  LinqTestApp
//
//  Copyright (c) 2013 Ryuji Samejima. All rights reserved.
//

#import "LQXDocument.h"
#import "NSEnumerator+Query.h"

#pragma mark - interface

@interface LQXName()

@property (nonatomic,readwrite) NSString *localName;
@property (nonatomic,readwrite) NSString *nameSpaceName;

@end

@interface LQXObject()

@property (nonatomic,readwrite) LQXDocument *document;
@property (nonatomic,readwrite) LQXElement *parent;

@end

@interface LQXAttribute()

@property (nonatomic,readwrite) LQXName *xName;

@end

@interface LQXNode()
@end

@interface LQXComment()

@end

@interface LQXContainer()

-(void)addObject:(id)object;
@property (nonatomic,readwrite) NSMutableArray *nodeArray;

@end

@interface LQXElement()

@property (nonatomic,readwrite) LQXName *xName;
@property (nonatomic,readwrite) NSMutableArray *attributeArray;

-(void)addObject:(id)object;

@end

@interface LQXDocument()

@property (nonatomic,readwrite) LQXElement *root;

-(void)addObject:(id)object;

@end

#pragma mark - implementation
#pragma mark LQXName
@implementation LQXName

+(LQXName*)name:(NSString*)name {
    return [[LQXName alloc]init:name];
}

+(LQXName*)nameSpace:(NSString*)nameSpace localName:(NSString*)localName {
    return [[LQXName alloc]initWithNameSpace:nameSpace localName:localName];
}


-(LQXName*)init:(NSString*)name {
    if ((self = [super init])) {
        if (name.length == 0) {
            self.nameSpaceName = @"";
        } else if (![[name substringToIndex:1]isEqualToString:@"{"]) {
            self.nameSpaceName = @"";
            self.localName = name;
        } else {
            NSRange endBlace = [name rangeOfString:@"}"];
            if (endBlace.location != NSNotFound) {
                self.nameSpaceName = [name substringWithRange:NSMakeRange(1, endBlace.location - 1)];
                self.localName = [name substringFromIndex:endBlace.location + 1];
            } else {
                self.localName = name;
            }
        }
    }
    return self;
}
-(LQXName*)initWithNameSpace:(NSString*)nameSpace localName:(NSString*)localName {
    if ((self = [super init])) {
        self.nameSpaceName = nameSpace;
        self.localName = localName;
    }
    return self;
}

-(NSString*)toString {
    if ([self.nameSpaceName isEqualToString:@""]) {
        return _localName;
    } else {
        return [NSString stringWithFormat:@"{%@}%@",_nameSpaceName,_localName];
    }
}

-(NSString *)description {
    return [self toString];
}

@end

#pragma mark LQXNameSpace

@implementation LQXDeclaration

+(LQXDeclaration*)declareWithEncoding:(NSStringEncoding)encoding version:(NSString*)version {
    return [[LQXDeclaration alloc]initWithEncoding:encoding version:version];
}

-(LQXDeclaration*)initWithEncoding:(NSStringEncoding)encoding version:(NSString*)version {
    if ((self = [super init])) {
        self.encoding = encoding;
        self.version = version;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<?xml version=\"%@\" encoding=\"%@\"?>\n",self.version, CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.encoding))];
}
@end

#pragma mark LQXObject

@implementation LQXObject

@end

#pragma mark LQXAttribute

@implementation LQXAttribute {
    NSString *_value;
}

//@property (readonly) NSString *nextAttribute;
//@property (readonly) NSString *previousAttribute;;

@dynamic name;
-(NSString *)name {
    return [self.xName toString];
}

@dynamic value;
-(NSString *)value {
    return _value;
}
-(void)setValue:(NSString *)value {
    _value = value;
}

@dynamic nodeType;
-(XmlNodeType)nodeType {
    return XmlNodeTypeAttribute;
}

+(LQXAttribute*)attributeWithAttribute:(LQXAttribute*)attribute {
    return [[LQXAttribute alloc]initWithAttribute:attribute];
}
+(LQXAttribute*)attribute:(NSString*)name value:(NSString*)value {
    return [[LQXAttribute alloc]init:name value:value];
}
+(LQXAttribute*)attributeWithXName:(LQXName*)name value:(NSString*)value {
    return [[LQXAttribute alloc]initWithXName:name value:value];
}

-(LQXAttribute*)initWithAttribute:(LQXAttribute*)attribute {
    if ((self = [super init])) {
        _xName = [LQXName name:attribute.name];
        _value = attribute.value;
    }
    return self;
}

-(LQXAttribute*)init:(NSString*)name value:(NSString*)value {
    if ((self = [super init])) {
        _xName = [LQXName name:name];
        _value = value;
    }
    return self;
}

-(LQXAttribute*)initWithXName:(LQXName*)name value:(NSString*)value {
    if ((self = [super init])) {
        _xName = name;
        _value = value;
    }
    return self;
}

-(void)remove {
    if (self.parent != nil) {
        [self.parent.attributeArray removeObject:[self.parent.attributes singleOrNil:^BOOL(id item) {
            return [((LQXAttribute*)item).name isEqualToString:self.name];
        }]];
    }
}

-(NSString *)description {
    return [NSString stringWithFormat:@" %@=\"%@\"",self.xName.localName, self.value];
}

@end

#pragma mark LQXNode

@implementation LQXNode

//-(void)addAfterSelf:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
//
//}
//-(void)addBeforeSelf:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
//
//}
//-(NSEnumerator*)ancestors {
//
//}
//-(NSEnumerator*)ancestors:(LQXName*)name {
//
//}
//-(NSEnumerator*)elementsAfterSelf;
//-(NSEnumerator*)elementsAfterSelf:(LQXName*)name;
//-(NSEnumerator*)elementsBeforeSelf;
//-(NSEnumerator*)elementsBeforeSelf:(LQXName*)name;
//-(NSEnumerator*)nodesAfterSelf;
//-(NSEnumerator*)nodesBeforeSelf;
-(void)remove {
    [self.parent.nodeArray removeObject:self];
}

@end

#pragma mark LQXComment

@implementation LQXComment {
    id _value;
}

@dynamic nodeType;
-(XmlNodeType)nodeType {
    return XmlNodeTypeComment;
}

+(LQXComment*)comment:(NSString*)value {
    return [[LQXComment alloc]init:value];
}

+(LQXComment*)commentWithComment:(LQXComment*)comment {
    return [[LQXComment alloc]initWithComment:comment];
}

-(LQXComment*)init:(NSString*)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

-(LQXComment*)initWithComment:(LQXComment*)comment {
    if ((self = [super init])) {
        _value = comment.value;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<!--%@-->\n",self.value];
}

@end

#pragma mark LQXContainer

@class LQXElement;

@implementation LQXContainer {
}

-(void)add:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    va_list list;
    va_start(list, firstObject);
    [self addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [self addObject:object];
    }
    va_end(list);
}

-(NSEnumerator*)descendants {
    return [self.nodeArray.objectEnumerator selectMany:^id(id item) {
        return item;
    }];
}
-(NSEnumerator*)descendants:(NSString*)name {
    return [[[self.nodeArray.objectEnumerator selectMany:^id(id item) {
        return item;
    }]ofClass:[LQXElement class]]where:^BOOL(id item) {
        LQXElement *element = item;
        return [element.name isEqualToString:name];
    }];
}

-(NSEnumerator*)descendantsWithName:(LQXName*)name {
    return [[[self.nodeArray.objectEnumerator selectMany:^id(id item) {
        return item;
    }]ofClass:[LQXElement class]]where:^BOOL(id item) {
        LQXElement *element = item;
        return [element.name isEqualToString:[name toString]];
    }];
}
-(LQXElement*)element:(NSString*)name {
    return [[self.nodeArray.objectEnumerator ofClass:[LQXElement class]]singleOrNil:^BOOL(id item) {
        LQXElement *element = item;
        return [element.name isEqualToString:name];
    }];
}
-(LQXElement*)elementWithName:(LQXName*)name {
    return [[self.nodeArray.objectEnumerator ofClass:[LQXElement class]]singleOrNil:^BOOL(id item) {
        LQXElement *element = item;
        return [element.name isEqualToString:[name toString]];
    }];
}

-(NSEnumerator*)elements {
    return [self.nodeArray.objectEnumerator ofClass:[LQXElement class]];
}
-(NSEnumerator*)elements:(NSString*)name {
    return [[self.nodeArray.objectEnumerator ofClass:[LQXElement class]]where:^BOOL(id item) {
        LQXElement *element = item;
        return [element.name isEqualToString:name];
    }];
}
-(NSEnumerator*)elementsWithName:(LQXName*)name {
    return [[self.nodeArray.objectEnumerator ofClass:[LQXElement class]]where:^BOOL(id item) {
        LQXElement *element = item;
        return [element.name isEqualToString:[name toString]];
    }];
}

-(void)removeNodes {
    self.nodeArray = [[NSMutableArray alloc]init];
}

//継承したLQXElement or LQXDocumentに委譲する
-(void)addObject:(id)object { }

@end

#pragma mark LQXElement

@implementation LQXElement {
    id _value;
}


@dynamic name;
-(NSString *)name {
    return [_xName toString];
}

@dynamic value;
-(NSString *)value {
    return _value;
}
-(void)setValue:(NSString *)value {
    _value = value;
}

@dynamic nodeType;
-(XmlNodeType)nodeType {
    return XmlNodeTypeElement;
}

@dynamic firstAttribute;
-(LQXAttribute *)firstAttribute {
    if (self.attributeArray.count != 0) {
        return [self.attributeArray objectAtIndex:0];
    } else {
        return nil;
    }
}

@dynamic hasAttributes;
-(BOOL)hasAttributes {
    return (self.attributeArray.count != 0);
}

@dynamic hasElements;
-(BOOL)hasElements {
    return ([self.elements count] != 0);
}

+(LQXElement*)elementWithElement:(LQXElement*)element {
    return [[LQXElement alloc]initWithElement:element];
}
+(LQXElement*)element:(NSString*)name {
    return [[LQXElement alloc]init:name];
}
+(LQXElement*)elementWithXName:(LQXName*)name {
    return [[LQXElement alloc]initWithXName:name];
}
+(LQXElement*)element:(NSString*)name value:(NSString*)value {
    return [[LQXElement alloc]init:name value:value];
}
+(LQXElement*)elementWithXName:(LQXName*)name value:(NSString*)value {
    return [[LQXElement alloc]initWithXName:name value:value];
}
+(LQXElement*)element:(NSString*)name objects:(id)firstObject, ... {
    LQXElement *element = [LQXElement element:name];
    va_list list;
    va_start(list, firstObject);
    [element addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [element addObject:object];
    }
    va_end(list);
    return element;
}
+(LQXElement*)elementWithXName:(LQXName*)name objects:(id)firstObject, ... {
    LQXElement *element = [LQXElement elementWithXName:name];
    va_list list;
    va_start(list, firstObject);
    [element addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [element addObject:object];
    }
    va_end(list);
    return element;
}

+(LQXElement*)load:(NSString*)filename {
    NSString *path = [[NSBundle mainBundle]pathForResource:filename ofType:@"xml"];
    LQXElement *result;
    int ret;
    xmlTextReaderPtr  reader;
    const char *input_file = [path cStringUsingEncoding:NSUTF8StringEncoding];
    reader = xmlReaderForFile(input_file, NULL, 0);
    if (NULL == reader) {
        fprintf(stderr, "Failed to parse %s\n", input_file);
        return nil;
    }
    
    /* Parse XML */
    while (1 == (ret = xmlTextReaderRead(reader))) {
        result = [self processNode:reader target:result];
    }
    
    if (0 != ret) {
        fprintf(stderr, "%s : failed to parse\n", input_file);
    }
    
    /* Free reader */
    xmlFreeTextReader(reader);
    
    xmlCleanupParser();
    
    return result;
}

+(LQXElement *)processNode:(xmlTextReaderPtr)reader target:(LQXElement *)target {
    
    const xmlChar *name;
    const xmlChar *value;
    int            ret;
    
    /* Print node infos */
    name = xmlTextReaderConstName(reader);
    if (NULL == name) {
        name = BAD_CAST "--";
    }
    
    switch (xmlTextReaderNodeType(reader)) {
        case XML_READER_TYPE_ELEMENT:
            NSLog(@"XML_READER_TYPE_ELEMENT [%s]",name);
            if (target == nil) {
                target = [LQXElement element:[NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding]];
            } else {
                LQXElement *newTarget = [LQXElement element:[NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding]];
                [target add:newTarget, nil];
                target = newTarget;

            }
            BOOL isEmpty = (1 == xmlTextReaderIsEmptyElement(reader));
            if (1 == xmlTextReaderHasAttributes(reader)) {
                ret = xmlTextReaderMoveToFirstAttribute(reader);
                while(1 == ret) {
                    name = xmlTextReaderConstName(reader);
                    value = xmlTextReaderConstValue(reader);
                    [target add:[LQXAttribute
                                 attribute:[NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding]
                                 value:[NSString stringWithCString:(const char*)value encoding:NSUTF8StringEncoding]], nil];
                    ret = xmlTextReaderMoveToNextAttribute(reader);
                }
            }
            if (isEmpty) {
                target = target.parent;
            }
            break;
        case XML_READER_TYPE_TEXT:
            NSLog(@"XML_READER_TYPE_TEXT [%s]",name);
            if (1 == xmlTextReaderHasValue(reader)) {
                value = xmlTextReaderConstValue(reader);
                target.value = [NSString stringWithCString:(const char*)value encoding:NSUTF8StringEncoding];
            }
            break;
        case XML_READER_TYPE_COMMENT: {
            NSLog(@"XML_READER_TYPE_COMMENT [%s]",name);
            if (1 == xmlTextReaderHasValue(reader)) {
                value = xmlTextReaderConstValue(reader);
                target.value = [NSString stringWithCString:(const char*)value encoding:NSUTF8StringEncoding];
                LQXComment *newTarget = [LQXComment comment:[NSString stringWithCString:(const char*)value encoding:NSUTF8StringEncoding]];
                [target add:newTarget, nil];
            }
        } break;
        case XML_READER_TYPE_END_ELEMENT:
            NSLog(@"XML_READER_TYPE_END_ELEMENT [%s]",name);
            //親が無い＝ルート要素なのでチェックする
            if (target.parent != nil) {
                target = target.parent;
            }
            break;
        case XML_READER_TYPE_XML_DECLARATION:
            NSLog(@"XML_READER_TYPE_XML_DECLARATION [%s]",name);
            break;
        case XML_READER_TYPE_DOCUMENT:
            NSLog(@"XML_READER_TYPE_DOCUMENT [%s]",name);
            break;
        case XML_READER_TYPE_ATTRIBUTE:
            NSLog(@"XML_READER_TYPE_ATTRIBUTE [%s]",name);
            break;
        case XML_READER_TYPE_CDATA:
            NSLog(@"XML_READER_TYPE_CDATA [%s]",name);
            break;
        case XML_READER_TYPE_ENTITY_REFERENCE:
            NSLog(@"XML_READER_TYPE_ENTITY_REFERENCE [%s]",name);
            break;
        case XML_READER_TYPE_ENTITY:
            NSLog(@"XML_READER_TYPE_ENTITY [%s]",name);
            break;
        case XML_READER_TYPE_PROCESSING_INSTRUCTION:
            NSLog(@"XML_READER_TYPE_PROCESSING_INSTRUCTION [%s]",name);
            break;
        case XML_READER_TYPE_DOCUMENT_TYPE:
            NSLog(@"XML_READER_TYPE_DOCUMENT_TYPE [%s]",name);
            break;
        case XML_READER_TYPE_DOCUMENT_FRAGMENT:
            NSLog(@"XML_READER_TYPE_DOCUMENT_FRAGMENT [%s]",name);
            break;
        case XML_READER_TYPE_NOTATION:
            NSLog(@"XML_READER_TYPE_NOTATION [%s]",name);
            break;
        case XML_READER_TYPE_WHITESPACE:
            NSLog(@"XML_READER_TYPE_WHITESPACE [%s]",name);
            break;
        case XML_READER_TYPE_SIGNIFICANT_WHITESPACE:
            NSLog(@"XML_READER_TYPE_SIGNIFICANT_WHITESPACE [%s]",name);
            break;
        case XML_READER_TYPE_END_ENTITY:
            NSLog(@"XML_READER_TYPE_END_ENTITY [%s]",name);
            break;
        default:
            break;
    }
    return target;
}

-(LQXElement*)initWithElement:(LQXElement*)element {
    if ((self = [super init])) {
        self.xName = [[LQXName alloc]init];
        self.attributeArray = [element.attributeArray.objectEnumerator toMutableArray];
        self.nodeArray = [element.nodeArray.objectEnumerator toMutableArray];
    }
    return self;
}
-(LQXElement*)init:(NSString*)name {
    if ((self = [super init])) {
        self.xName = [LQXName name:name];
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
    }
    return self;
}
-(LQXElement*)initWithXName:(LQXName*)name {
    if ((self = [super init])) {
        self.xName = name;
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(LQXElement*)init:(NSString*)name value:(NSString*)value {
    if ((self = [super init])) {
        self.xName = [LQXName name:name];
        _value = value;
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
    }
    return self;
}
-(LQXElement*)initWithXName:(LQXName*)name value:(NSString*)value {
    if ((self = [super init])) {
        _xName = name;
        _value = value;
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(LQXElement*)init:(NSString*)name objects:(id)firstObject, ... {
    va_list list;
    if ((self = [super init])) {
        self.xName = [LQXName name:name];
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
        va_start(list, firstObject);
        [self addObject:firstObject];
        id object;
        while((object = va_arg(list, id))) {
            [self addObject:object];
        }
        va_end(list);
    }
    return self;
}
-(LQXElement*)initWithXName:(LQXName*)name objects:(id)firstObject, ... {
    va_list list;
    if ((self = [super init])) {
        self.xName = name;
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
        va_start(list, firstObject);
        [self addObject:firstObject];
        id object;
        while((object = va_arg(list, id))) {
            [self addObject:object];
        }
        va_end(list);
    }
    return self;
}

-(void)addObject:(id)object {
    if (object == nil) {
        // 何もしない
    } else if ([object isKindOfClass:[LQXObject class]]) {
        LQXObject *xObject = object;
        xObject.parent = self;
        xObject.document = self.document;
        switch (xObject.nodeType) {
            case XmlNodeTypeAttribute:
                [self.attributeArray addObject:xObject];
                break;
            case XmlNodeTypeComment:
            case XmlNodeTypeElement:
                [self.nodeArray addObject:xObject];
                break;
            default:
                break;
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        for (id item in object) {
            [self addObject:item];
        }
    } else if ([object isKindOfClass:[NSString class]]) {
        LQXElement *xElement = [LQXElement elementWithXName:[LQXName name:object]];
        xElement.parent = self;
        xElement.document = self.document;
        [self.nodeArray addObject:xElement];
    }
}

-(LQXAttribute*)attribute:(NSString*)name {
    return [self.attributeArray.objectEnumerator singleOrNil:^BOOL(id item) {
        LQXAttribute *attribute = item;
        return [attribute.name isEqualToString:name];
    }];
}

-(LQXAttribute*)attributeWithName:(LQXName*)name {
    return [self.attributeArray.objectEnumerator singleOrNil:^BOOL(id item) {
        LQXAttribute *attribute = item;
        return [attribute.name isEqualToString:[name toString]];
    }];
}
-(NSEnumerator*)attributes {
    return self.attributeArray.objectEnumerator;
}

-(NSEnumerator*)attributes:(NSString*)name {
    return [self.attributeArray.objectEnumerator where:^BOOL(id item) {
        LQXAttribute *attribute = item;
        return [attribute.name isEqualToString:name];
    }];
}

-(NSEnumerator*)attributesWithName:(LQXName*)name {
    return [self.attributeArray.objectEnumerator where:^BOOL(id item) {
        LQXAttribute *attribute = item;
        return [attribute.name isEqualToString:[name toString]];
    }];
}
-(void)removeAll {
    self.attributeArray = [[NSMutableArray alloc]init];
    self.nodeArray = [[NSMutableArray alloc]init];
}
-(void)removeAttributes {
    self.attributeArray = [[NSMutableArray alloc]init];
}

-(void)setAttribute:(NSString*)name value:(NSString*)value {
    if (value == nil) {
        [self.attributeArray removeObject:[self.attributeArray.objectEnumerator firstOrNil:^BOOL(id item) {
            return [((LQXAttribute*)item).name isEqualToString:name];
        }]];
    } else {
        [self.attributeArray addObject:[LQXAttribute attribute:name value:value]];
    }
}

-(void)setAttributeWithName:(LQXName*)name value:(NSString*)value {
    if (value == nil) {
        [self.attributeArray removeObject:[self.attributeArray.objectEnumerator firstOrNil:^BOOL(id item) {
            return [((LQXAttribute*)item).name isEqualToString:[name toString]];
        }]];
    } else {
        [self.attributeArray addObject:[LQXAttribute attributeWithXName:name value:value]];
    }
}

-(void)setElement:(NSString*)name value:(NSString*)value {
    if (value == nil) {
        [self.nodeArray removeObject:[self.nodeArray.objectEnumerator firstOrNil:^BOOL(id item) {
            return [((LQXElement*)item).name isEqualToString:name];
        }]];
    } else {
        [self.nodeArray addObject:[LQXElement element:name value:value]];
    }
}

-(void)setElementWithName:(LQXName*)name value:(NSString*)value {
    if (value == nil) {
        [self.nodeArray removeObject:[self.nodeArray.objectEnumerator firstOrNil:^BOOL(id item) {
            return [((LQXElement*)item).name isEqualToString:[name toString]];
        }]];
    } else {
        [self.nodeArray addObject:[[LQXElement alloc]initWithXName:name value:value]];
    }
}

-(NSString *)description {
    static NSInteger depth;
    NSMutableString *result;
    NSString *name;
    if (self.parent == nil || [self.xName.nameSpaceName isEqualToString:@""] || [self.xName.nameSpaceName isEqualToString:self.parent.xName.nameSpaceName]) {
        name = [NSString stringWithFormat:@"%@",self.xName.localName];
    } else {
        name = [NSString stringWithFormat:@"%@:%@",self.xName.nameSpaceName,self.xName.localName];
    }
    NSMutableString *space = [NSMutableString stringWithString:@""];
    [[NSEnumerator repeat:@"  " count:depth]forEach:^(id item) {
        [space appendString:item];
    }];
    result = [NSMutableString stringWithFormat:@"%@<%@",space,name];
    if (self.hasAttributes) {
        for (LQXAttribute *attr in self.attributes) {
            [result appendString:[attr description]];
        }
    }
    if (self.nodeArray.count != 0) {
        [result appendString:@">\n"];
        for (id elem in self.nodeArray) {
            depth++;
            if ([elem isKindOfClass:[LQXElement class]]) {
                [result appendString:[elem description]];
            } else {
                [result appendFormat:@"  %@%@",space,[elem description]];
            }
            depth--;
        }
        [result appendFormat:@"%@</%@>\n",space, self.xName.localName];
    } else if (self.value != nil) {
        [result appendFormat:@">%@</%@>\n",self.value, self.xName.localName];
    } else {
        [result appendString:@" />\n"];
    }
    return result;
}
@end

#pragma mark LQXDocument

@implementation LQXDocument

@dynamic root;
-(LQXElement *)root {
    return [self.elements firstOrNil];
}

@dynamic nodeType;
-(XmlNodeType)nodeType {
    return XmlNodeTypeDocument;
}

+(LQXDocument*)document {
    return [[LQXDocument alloc]init];
}
+(LQXDocument*)documentWithDocument:(LQXDocument*)document {
    return [[LQXDocument alloc]initWithDocument:document];
}
+(LQXDocument*)documentWithObject:(id)firstObject, ... {
    LQXDocument *document = [LQXDocument document];
    va_list list;
    va_start(list, firstObject);
    [document addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [document addObject:object];
    }
    va_end(list);
    return document;
}
+(LQXDocument*)documentWithDeclaration:(LQXDeclaration*)declaration objects:(id)firstObject, ... {
    LQXDocument *document = [LQXDocument document];
    document.declaration = declaration;
    va_list list;
    va_start(list, firstObject);
    [document addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [document addObject:object];
    }
    va_end(list);
    return document;
}

+(LQXDocument*)load:(NSString*)filename {
    NSString *path = [[NSBundle mainBundle]pathForResource:filename ofType:@"xml"];
    LQXDocument *result = [LQXDocument document];
    LQXElement *element;
    int ret;
    xmlTextReaderPtr  reader;
    const char *input_file = [path cStringUsingEncoding:NSUTF8StringEncoding];
    reader = xmlReaderForFile(input_file, NULL, 0);
    if (NULL == reader) {
        fprintf(stderr, "Failed to parse %s\n", input_file);
        return nil;
    }
    
    /* Parse XML */
    while (1 == (ret = xmlTextReaderRead(reader))) {
        element = [LQXElement processNode:reader target:element];
    }
    
    if (0 != ret) {
        fprintf(stderr, "%s : failed to parse\n", input_file);
    }
    
    /* Free reader */
    xmlFreeTextReader(reader);
    
    xmlCleanupParser();
    
    [result addObject:element];
    return result;
}

-(LQXDocument*)init {
    self.nodeArray = [[NSMutableArray alloc]init];
    if ((self = [super init])) {
        self.declaration = [LQXDeclaration declareWithEncoding:NSUTF8StringEncoding version:@"1.0"];
        [self addObject:@"Root"];
    }
    return self;
}
-(LQXDocument*)initWithDocument:(LQXDocument*)document {
    self.nodeArray = [[NSMutableArray alloc]init];
    if ((self = [super init])) {
        self.declaration = document.declaration;
        [self addObject:document.root];
    }
    return self;
}
-(LQXDocument*)initWithObjects:(id)firstObject, ... {
    self.nodeArray = [[NSMutableArray alloc]init];
    va_list list;
    if ((self = [super init])) {
        self.declaration = [LQXDeclaration declareWithEncoding:NSUTF8StringEncoding version:@"1.0"];
        [self addObject:firstObject];
        va_start(list, firstObject);
        id object;
        while((object = va_arg(list, id))) {
            [self addObject:object];
        }
        va_end(list);
    }
    return self;
}
-(LQXDocument*)initWithDeclaration:(LQXDeclaration*)declaration objects:(id)firstObject, ... {
    self.nodeArray = [[NSMutableArray alloc]init];
    va_list list;
    if ((self = [super init])) {
        self.declaration = declaration;
        [self addObject:firstObject];
        va_start(list, firstObject);
        id object;
        while((object = va_arg(list, id))) {
            [self addObject:object];
        }
        va_end(list);
    }
    return self;
}

-(void)addObject:(id)object {
    if (object == nil) {
        // 何もしない
    } else if ([object isKindOfClass:[LQXElement class]]) {
        NSArray *elements = [self.elements toArray];
        if (elements.count != 0) {
            for (id obj in elements) {
                [self.nodeArray removeObject:obj];
            }
        }
        [self.nodeArray addObject:object];
    } else if ([object isKindOfClass:[NSString class]]) {
        NSArray *elements = [self.elements toArray];
        if (elements.count != 0) {
            for (id obj in elements) {
                [self.nodeArray removeObject:obj];
            }
        }
        [self.nodeArray addObject:[LQXElement element:object]];
    }
}

-(NSString *)description {
    NSMutableString *result = [NSMutableString stringWithString:[self.declaration description]];
    LQXElement *root = self.root;
    if (root != nil) {
        [result appendString:[self.root description]];
    }
    return result;
}

@end

