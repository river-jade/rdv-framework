def open_file(file_name):
  
  fileToWrite = open(file_name, 'w')
  # TODO catch errors
  return fileToWrite

def writeHTMLTop(title, fileToWrite):

   p1 = """<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'><html xmlns='http://www.w3.org/1999/xhtml'><head><title>"""
   p2 = """</title></head><body>"""
   print (" writing %s%s%s" % (p1, title, p2))
   fileToWrite.write("%s%s%s" % (p1, title, p2))

def writeHTMLBottom(fileToWrite):

   fileToWrite.write("</body>\n</html>")
   fileToWrite.close()

def writeHTMLTable(tableTitle, imageNames, imageTitles, tablewidth, fileToWrite):

  part1 = "<td align='center'><a href='"    
  part2="'><img src='"
  part3="' width='100' height='100' border='0' /></a><br/>"
  part4="</td>"

  print ("Got %d image names to write" % len(imageNames))
  fileToWrite.write("""<h3>%s</h3>""" % tableTitle)
  
  fileToWrite.write("""<table border='1'>\n""")
  
  for i in range(0,len(imageNames)):

    fullString = "%s%s%s%s%s%s%s" % (part1, imageNames[i], part2, imageNames[i], part3, imageTitles[i], part4)
    
    if (i == 0):
      print ("writing the first row, i is %d" % i)
      fileToWrite.write("""<tr>\n""")

    fileToWrite.write(fullString)

    if (i == (tablewidth-1)):
      print ("ending a row, i is %d" % i)
      fileToWrite.write("""</tr>\n""")
      if (i < len(imageNames)-1):
        print ("starting a new row, because i is %d" % i)
        fileToWrite.write("""<tr>\n""")
      
    elif (i > tablewidth):
      if ((i % tablewidth) == 0):
        print ("ending a row, i is %d" % i)
        fileToWrite.write("""</tr>\n""")
        if (i < len(imageNames)-1):
          print ("starting a new row, because i is %d" % i)
          fileToWrite.write("""<tr>\n""")
          
  fileToWrite.write("""</tr>\n""")
  fileToWrite.write("""</table>""")
    
def writeURL(title, fileLink, fileToWrite):

  fileToWrite.write("%s%s%s%s%s" % ("""<p><a href='""",fileLink,"""'>""",title,"""</a></p>"""))
