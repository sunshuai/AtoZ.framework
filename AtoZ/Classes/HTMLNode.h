
//  HTMLNode.h  StackOverflow
//  Created by Ben Reeves on 09/03/2010.  Copyright 2010 Ben Reeves. All rights reserved.


#define ParsingDepthUnlimited 0
#define      ParsingDepthSame -1
#define          ParsingDepth size_t
#define               EL_TYPE HTMLNodeType
#define                    EL HTMLNode

_EnumKind( HTMLNodeType,  HTMLHrefNode,   HTMLTextNode,   HTMLUnkownNode,
                     HTMLCodeNode,   HTMLSpanNode,        HTMLPNode,
                       HTMLLiNode,     HTMLUlNode,     HTMLImageNode,
                       HTMLOlNode,  HTMLStrongNode, HTMLPreNode,
                                                    HTMLBlockQuoteNode)
@CLASS(HTMLNode)

+ (INST) instanceWithXMLNode:(void*)xmlNode;

_RO     NSS * contents,         // plaintext contents of node
                  * allContents,      // plaintext contents of this node + all children
                  * rawContents,      // html contents of the node
                  * className;
_RO HTMLNode * firstChild,       // the first child element
                  * nextSibling,      // next sibling in tree
                  * previousSibling,  // previous sibling in tree
                  * tagName,
                  * parent;
_RO     NSA * children;         // the first level of children
_RO EL_TYPE   nodetype;         // if known

#pragma mark - Single node finders

/** 
@method findChildOfClass:
  Returns a single child of class
@method getAttributeNamed:
  Gets the attribute value matching tha name
@method findChildWithAttribute:matchingName:allowPartial:
  @param allowPartial Whether to match partial matches 
  @code
    <img src="http://www.google.com>
    [findChildWithAttribute:@"src" matchingName:"google.com" allowPartial:TRUE]
@method findChildTag:
  Looks for a tag name e.g. "h3"
*/

- (INST)           findChildTag:(NSS*)tagN;
- (INST)       findChildOfClass:(NSS*)classN;
- (NSS*)      getAttributeNamed:(NSS*)name;
- (INST) findChildWithAttribute:(NSS*)attr
                   matchingName:(NSS*)classN
                   allowPartial:(BOOL)p;

#pragma mark - Globbing finders

- (NSA*)             findChildTags:(NSS*)tagN;
- (NSA*)       findChildrenOfClass:(NSS*)classN;
- (NSA*) findChildrenWithAttribute:(NSS*)attr
                      matchingName:(NSS*)classN
                      allowPartial:(BOOL)p;
@end

//@class xmlNode;
