STAR = "*"

num = 0
while not num % 2 != 0:
  num = int(input("Enter an odd number: "))
  if num % 2 == 0:
    print("That's not an odd number. Please try again.")

mid = int((num + 1) / 2)
for a1 in range(1, mid + 1):
    for a2 in range(mid - a1):
      print(" ", end = "")
    for a3 in range((a1 * 2) - 1):
      print("*", end = "")
    print()

for a1 in range(mid + 1, num + 1):
    for a2 in range(a1 - mid):
      print(" ", end = "")
    for a3 in range((num + 1 - a1) * 2 - 1):
      print("*", end = "")
    print()