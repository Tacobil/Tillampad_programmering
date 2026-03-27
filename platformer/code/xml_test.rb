require "rexml/document"

file = File.read("data/maps/world.tmx")
doc = Document.new file

# doc.attributes -> []
# doc.elements -> []
