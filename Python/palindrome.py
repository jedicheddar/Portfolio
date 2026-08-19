newstr = ""
str = input("Please enter a word/phrase: ")
for char in str:
  if char.isalnum():
    newstr += char

i = 0
palindrone = True
newstr = newstr.lower()
midpoint = int(len(newstr) / 2)
while i <= midpoint and palindrone:
  if newstr[midpoint - i] != newstr[midpoint + i]:
    palindrone = False
  i += 1

if palindrone:
  print("The word/phrase is a palindrone")
else:
  print("The word/phrase is not a palindrone")
  
input()