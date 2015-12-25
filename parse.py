#! /usr/bin/python

import sys

from xml.dom import minidom

font_file = sys.argv[1]
font_name = font_file.split('/')[-1].replace('.svg', '')

doc = minidom.parse(font_file)

swift_output_string = """
internal struct Font {
    static let FontName = "%s"
}

public enum Icon: String {
""" % font_name

glyph_count = 0
for glyph in doc.getElementsByTagName('glyph'):
    name = glyph.getAttribute('glyph-name')
    if name:
        name = name.title().replace('-', '')
        unicode = glyph.getAttribute('unicode')
        unicode = unicode.encode('unicode-escape').decode()
        unicode = unicode.replace('u', 'u{') + '}'
        swift_output_string += '    case %s = "%s"\n' % (name, unicode)
        glyph_count += 1

swift_output_string += '}'

print(swift_output_string)

doc.unlink()
