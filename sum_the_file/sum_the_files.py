with open("./randomInt100.txt", "r") as file:
    nums = [int(line.strip()) for line in file.readlines()[1:]]
print(f"The sum is: {sum(nums)}")
