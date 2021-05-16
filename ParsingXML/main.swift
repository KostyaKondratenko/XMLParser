//
//  main.swift
//  ParsingXML
//
//  Created by Kostya Kondratenko on 16.05.2021.
//

import Foundation

class XMLNode {
    let tag: String
    var data: String
    let attributes: [String: String]
    var childNodes: [XMLNode]
    
    init(tag: String, data: String, attributes: [String: String], childNodes: [XMLNode]) {
        self.tag = tag
        self.data = data
        self.attributes = attributes
        self.childNodes = childNodes
    }
    
    func getAttribute(_ name: String) -> String? {
        attributes[name]
    }
    
    func getElementsByTag(_ name: String) -> [XMLNode] {
        var result: [XMLNode] = []
        
        for node in childNodes {
            if node.tag == name {
                result.append(node)
            }
            
            result += node.getElementsByTag(name)
        }
        
        return result
    }
}

class MicroDOM: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private var stack: [XMLNode] = []
    private var tree: XMLNode?
    
    init(data: Data) {
        parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }
    
    func parse() -> XMLNode? {
        parser.parse()
        
        guard parser.parserError == nil else {
            return nil
        }
        
        return tree
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        let node = XMLNode(tag: elementName, data: "", attributes: attributeDict, childNodes: [])
        stack.append(node)
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        let lastElement = stack.removeLast()
        
        if let last = stack.last {
            last.childNodes += [lastElement]
        } else {
            tree = lastElement
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        stack.last?.data = string
    }
}

let string = "<root><h1>Hello!</h1><h1>World!</h1></root>"
let dom = MicroDOM(data: Data(string.utf8))
let tree = dom.parse()
print(tree?.tag ?? "")

if let tags = tree?.getElementsByTag("h1") {
    for tag in tags {
        print(tag.data)
    }
}
