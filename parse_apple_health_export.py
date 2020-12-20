#!/usr/bin/env python3
""" Parse the apple health Export data
"""
import xml.etree.ElementTree as ET
# https://docs.python.org/3/library/xml.etree.elementtree.html#xml.etree.ElementTree.iterparse
def main():
    xml_data = '../health_data/apple_health_export/export.xml'
    tree = ET.parse(xml_data)

    return None



if __name__ == '__main__':
    VERBOSE = 1
    main()
