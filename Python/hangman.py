import subprocess
import time

MAX_FAILED_GUESSES = 6

def clear_screen():
  subprocess.run("cls", shell=True)

def build_gallow(missed):
  clear_screen()
  print(" +---+")
  print(" |  \\|")
  print(" {0}   |".format("O" if missed >= 1 else " "))
  print("{0}{1}{2}  |".format("/" if missed >= 2 else " ", "|" if missed >=3 else " ", "\\" if missed >= 4 else " "))
  print("{0} {1}  |".format("/" if missed >= 5 else " ", "\\" if missed >= 6 else " "))
  print("     |")
  print("     |")
  print(" =====")
  print()

def ask_letter(failed, success):
  valid = False
  letter = input("What is your guess? ")
  if letter in failed or letter in success:
    print("You have already guessed that letter.")
  else:
    if letter.isalpha() and len(letter) == 1:
      valid = True
    else:
      print("Please enter a single letter.")

  if not valid:
    time.sleep(1)
    return "-1"
  return letter.lower()

def show_stats(master_string, failed, success):
  letter_count = 0
  master_string_without_symbols = "".join([char for char in master_string if char.isalpha()]).lower()

  # for the characters in the string
  for char in master_string:
    if char.lower() in success:
      print(char, end=" ")
      letter_count += 1
    elif char.lower() not in master_string_without_symbols:
      print(char, end=" ")
    else:
        if char == " ":
          print(" ", end=" ")
        else:
          print("_", end=" ")
  print()
  print()

  # for the missed characters
  print("Missed characters:", end=" ")
  for char in failed:
    print(char, end=" ")

  print()
  print()

  return letter_count == len(master_string_without_symbols)
  
master_string = input("Enter the word/phrase to guess: ")
failed = []
success = []

i = 0
while i < MAX_FAILED_GUESSES:
  clear_screen()
  build_gallow(len(failed))
  if len(failed) > 0 or len(success) > 0:
    if show_stats(master_string, failed, success):
      break

  letter = ask_letter(failed, success)
  if letter != "-1":
    if letter.lower() in master_string.lower():
      success.append(letter.lower())
    else:
      failed.append(letter)
      i += 1

clear_screen()
build_gallow(len(failed))
show_stats(master_string, failed, success)