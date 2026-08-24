import math

# Read the number
n = int(input())

# Check if prime and print
i = 2
sqrt = math.sqrt(n)
notPrime = False
while i <= math.floor(sqrt):
  if math.remainder(n, i) == 0:
    notPrime = True
  i += 1
  
if not notPrime:
  print("Prime")
else:
  print("Not Prime")